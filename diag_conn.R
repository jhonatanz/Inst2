# Segunda iteración del paquete de instrumentación
# Diagramas de conexionado
library(tidyverse)
rm(list = ls())
source("funciones.R")
# Definicion de los pares permitidos y el porcentaje de reservas
pares_perm = c(1, 2, 4, 8, 12, 16, 24)
reserva <- 1.25

# Selección, filtrado y procesamiento de los datos de entrada
entr<-read_csv("entradas/list_sig.csv")%>%
  select(`Tag señal`, Origen, `Tipo de I/O`, `Tipo de señal`, destino, Controlador)%>%
  rename("Tag_Sig" = "Tag señal", "Tipo_IO" = "Tipo de I/O", "Tipo_Sig" = "Tipo de señal",
         "Dest" = "destino", "Cntrl" = "Controlador")%>%
  filter(Tipo_IO != "S")%>%
  mutate(Tipo_Sig = case_when(
    Tipo_Sig == "Sink 24 VDC" ~ "D",
    Tipo_Sig == "4-20 mA" ~ "A",
    Tipo_Sig == "3-wire RTD" ~ "R",
    Tipo_Sig == "TC" ~ "T"))

## Creación de los cables de dispositivos en campo (tabla1)
cab <- entr %>%
  group_by(Origen, Tipo_Sig, Dest, Cntrl) %>%
  summarise(pares = n())%>%
  ungroup()%>%
  # se crea un tag previo de cable y se define la cantidad de cables requeridos por cada origen/tipo
  mutate(cb_req = ceiling(reserva*pares/max(pares_perm)),
         cable_prev = paste("CB", Origen, Tipo_Sig, sep = "-"))

# Asignación de cables a dispositivos de campo
cables<-matrix(nrow = 0, ncol = 5)
res<-as.matrix(entr[0,])
for(i in 1:length(cab$Origen)){
  # Verificacion de si los pares requerido se ajustan a los pares permitidos
  ifelse(sum(cab$pares[i]==pares_perm), add_res<-0, add_res<-1)
  for(j in 1:cab$cb_req[i]){
    cable <- paste(cab$cable_prev[i], j, sep = "-")
    for(k in 1:cab$pares[i]){
      cable1<-c(cab$Origen[i], cable, k, cab$Tipo_Sig[i], "nor")
      cables<-rbind(cables, cable1, deparse.level = 0)
    }
    # Adición de pares de reserva para ajustarse a los pares permitidos
    if(add_res==1){
      par_req<-pares_perm[which(pares_perm/cab$pares[i]>1)[1]]
      for(m in 1:(par_req-cab$pares[i])){
        cable2<-c(cab$Origen[i], cable1[2], cab$pares[i]+m, cab$Tipo_Sig[i], "res")
        cables<-rbind(cables, cable2, deparse.level = 0)
        r<-c("ZZZZZZZZ", cab$Origen[i], NA, cab$Tipo_Sig[i], cab$Dest[i], cab$Cntrl[i])
        res<-rbind(res, r, deparse.level = 0)
      }
    }
  }
}
cables<-as_tibble(cables)%>%
  arrange(V1, V4, V3)%>%
  rename("Cable1" = "V2", "Par1" = "V3")
res<-as_tibble(res)

# Construcción de la tabla1 adicionando las columnas de Cable1 y Par1
if(nrow(res)==0){
  tabla1<-entr
}else{
  tabla1<-bind_rows(entr, res)
}

tabla1<-tabla1%>%
  arrange(Origen, Tipo_Sig, Tag_Sig)%>%
  bind_cols(select(cables, Cable1, Par1))%>%
  mutate(Par1 = as.numeric(Par1))

# Limpieza de variables
rm(cab, res, cables, add_res, cable, cable1, cable2, i, j, k, m, par_req, r)

## Creación de Cables Multiconductores

# Calculo de cantidad de pares por tipo de señal requeridos en cada caja
cab <- tabla1 %>%
  filter(str_detect(Dest, "^JBI"))%>%
  group_by(Dest, Tipo_Sig, Cntrl)%>%
  summarise(pares = n())%>%
  ungroup()%>%
  # se crea un tag de cable previo y se define la cantidad de cables requeridos por cada origen/tipo
  mutate(cb_req = ceiling(reserva*pares/max(pares_perm)),
         cable = paste("CB", Dest, Tipo_Sig, sep = "-"),
         pares = ceiling(reserva*pares))%>%
  rename("Origen" = "Dest", "Dest" = "Cntrl")

# Se determina la cantidad de cables requeridos para respetar la máxima cantidad permitida de pares,
# Se define la cantidad final de pares y numero de tag asignado a cada cable

# Si hay casos en los que se requiere mas de un multicoductor porque las señales superan los pares permitidos:
if(max(cab$cb_req)>1){
  cab2<-cab[0, ]
  for(l in 1:(max(cab$cb_req)-1)){
    cab1<-cab%>%
      filter(cb_req>l)%>%
      mutate(pares = pares-l*max(pares_perm))
    cab2<-bind_rows(cab2, cab1)
  }
  cab<-bind_rows(cab, cab2)%>%
    mutate(pares = ifelse(pares>max(pares_perm), max(pares_perm), pares),
           cb_req = 1)
}

# Definicion final de los cables
cab<-cab%>%
  arrange(Origen, Tipo_Sig)%>%
  group_by(Origen, Tipo_Sig)%>%
  mutate(cable = paste(cable, cumsum(cb_req), sep = "-"))

# Generación de los pares de cada multiconductor
cables<-matrix(nrow = 0, ncol = 5)
for(i in 1:length(cab$Origen)){
  cab$pares[i]<-ifelse(sum(cab$pares[i]==pares_perm), cab$pares[i], 
                       pares_perm[which(pares_perm/cab$pares[i]>1)[1]])
  # Generación de los pares en cada multiconductor
  for(k in 1:cab$pares[i]){
    cable1<-c(cab$Origen[i], cab$cable[i], k, cab$Tipo_Sig[i], cab$Dest[i])
    cables<-rbind(cables, cable1, deparse.level = 0)
  }
}
cables<-as_tibble(cables)%>%
  mutate(V3=as.numeric(V3))%>%
  rename("Dest" = "V1", "Cable2" = "V2", "Par2" = "V3", "Tipo_Sig" = "V4", "Cntrl" = "V5")%>%
  mutate(Cab=as.numeric(str_sub(Cable2, -1, -1)))

## Creación de la tabla 2, diagrama de conexionado de cajas
tabla2<-tabla1%>%
  filter(str_detect(Dest, "^JBI"))%>%
  group_by(Dest, Tipo_Sig)%>%
  mutate(t=1, Par2 = cumsum(t), Cab = (Par2-1)%/%max(pares_perm)+1)%>%
  ungroup()%>%
  group_by(Dest, Tipo_Sig, Cab)%>%
  mutate(Par2 = cumsum(t))%>%
  ungroup()%>%
  right_join(cables)%>%
  arrange(Dest, Tipo_Sig, Cable2, Par2)

# Limpieza de variables
rm(cables, cab, cab1, cab2, cable1, i, k, l)

# Creación de borneras en la caja de conexionado
tabla2<-tabla2%>%
  mutate(
    c_bornes = case_when(
      Tipo_Sig == "D" ~ 2,
      Tipo_Sig == "A" ~ 3,
      Tipo_Sig == "R" ~ 4,
      Tipo_Sig == "T" ~ 2))%>%
  group_by(Dest, Tipo_Sig)%>%
  mutate(b = cumsum(c_bornes), 
         Jborne1 = b - c_bornes + 1,
         Jborne2 = b - c_bornes + 2,
         Jborne3 = ifelse(c_bornes > 2, b-c_bornes + 3, NA),
         Jborne4 = ifelse(c_bornes > 3, b-c_bornes + 4, NA),
         JTS = paste("TS", Tipo_Sig, sep = "-"))%>%
  ungroup()%>%
  select(-c_bornes, -b, -Cab, -t)

## Tabla 3 Conexionado con gabinetes

tabla3<-tabla1%>%
  full_join(tabla2)%>%
  arrange(Cntrl, Tipo_Sig, Cable2)%>%
  mutate(
    c_bornes = case_when(
      Tipo_Sig == "D" ~ 2,
      Tipo_Sig == "A" ~ 3,
      Tipo_Sig == "R" ~ 4,
      Tipo_Sig == "T" ~ 2))%>%
  group_by(Cntrl, Tipo_Sig)%>%
  mutate(b = cumsum(c_bornes), 
         Gborne1 = b - c_bornes + 1,
         Gborne2 = b - c_bornes + 2,
         Gborne3 = ifelse(c_bornes > 2, b-c_bornes + 3, NA),
         Gborne4 = ifelse(c_bornes > 3, b-c_bornes + 4, NA),
         GTS = paste("TS", Tipo_Sig, sep = "-"))%>%
  ungroup()

# Para las señales que van directamente al controlador, se define que el Cable2/Par2 = Cable1/Par1
tabla3$Cable2[is.na(tabla3$Jborne1)]<-tabla3$Cable1[is.na(tabla3$Jborne1)]
tabla3$Par2[is.na(tabla3$Jborne1)]<-tabla3$Par1[is.na(tabla3$Jborne1)]

# Identificación de reservas
tabla3$Tag_Sig[tabla3$Tag_Sig == "ZZZZZZZZ"]<-"RESERVA"
tabla3$Tag_Sig[is.na(tabla3$Tag_Sig)]<-"RESERVA"

## Generación de reportes, se genera un reporte por cada caja o gabinete

# Bornes y Borneras por caja

b_cajas<-tabla3%>%
  filter(str_detect(Dest, "^JBI"))%>%
  group_by(Dest, JTS)%>%
  summarise(bornes = max(cumsum(c_bornes)))
print(b_cajas)

# Cajas
d_cajas<-tabla3%>%
  filter(str_detect(Dest, "^JBI"))%>%
  select(Tag_Sig, Origen, Tipo_Sig, Cable1, Par1, "TS" = JTS, "borne1"="Jborne1", Jborne2, Jborne3,
         Jborne4, Cable2, Par2, Dest, Cntrl)

cajas<-d_cajas%>%
  group_by(Dest)%>%
  summarise(n())

for(i in cajas$Dest){
  GEN(d_cajas, i)
}

# Gabinetes
d_gab<-tabla3%>%
  select(Tag_Sig, Origen, Tipo_Sig, Cable2, Par2, "TS" = GTS, "borne1"="Gborne1", Gborne2, Gborne3,
         Gborne4, Cable1, Par1, Dest1 = Dest, Dest = Cntrl)%>%
  mutate(Cable1 = NA, Par1 = NA)

gab<-d_gab%>%
  group_by(Dest)%>%
  summarise(n())

for(i in gab$Dest){
  GEN(d_gab, i)
}
write_csv(tabla3, "entradas/tabla3.csv")
write_csv(b_cajas, "salidas/b_cajas.csv")