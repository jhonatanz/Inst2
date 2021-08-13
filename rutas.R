library(tidyverse)
rm(list = ls())
source("funciones.R")
plano<-read_csv("entradas/CONTEO.csv", guess_max = 2000)%>%
  select(Type, Handle, Layer, `Referenced Block`, Length, `Position:X`, `Position:Y`, `Vertex:X`, `Vertex:Y`, `Attributes:dest`)%>%
  rename(Block_Ref = `Referenced Block`, Pos_X = `Position:X`, Pos_Y = `Position:Y`, Ver_X = `Vertex:X`, Ver_Y = `Vertex:Y`, 
         Name = `Attributes:dest`)

# se crea una tabla de los vértices de las poli-lineas del plano
lineas<-plano%>%
  filter(Type == "Polyline" | Type == "Vertex")
# Se asignan las mismas características a los vertex de las poli-lineas  
p_handle<-character()
p_length<-numeric()
p_layer<-character()
for(i in seq_along(lineas$Type)){
  if(is.na(lineas$Handle[i])){
    lineas$Handle[i]<-p_handle
    lineas$Length[i]<-p_length
    lineas$Layer[i]<-p_layer
  }else{
    p_handle<-lineas$Handle[i]
    p_length<-lineas$Length[i]
    p_layer<-lineas$Layer[i]
  }
}
lineas<-lineas%>%
  filter(Type == "Vertex" & str_detect(Layer, "^ARBOL_"))

# Tabla de los nodos del plano
nodos<-plano%>%
  filter(str_detect(Block_Ref, "^NODO"))

# Tabla s_lineas, resume las lineas, define los nombres e incluye las longitudes
s_lineas<-lineas%>%
  group_by(Handle)%>%
  summarise(Handle, Layer, Length, m_x = max(Ver_X), m_y = max(Ver_Y))%>%
  ungroup()%>%
  unique()%>%
  mutate(t = 1, n = case_when(
    str_detect(Layer, ".+AEREO") ~ "CO",
    str_detect(Layer, ".+BANCO") ~ "BD",
    str_detect(Layer, ".+BAND") ~ "BP"))%>%
  group_by(n)%>%
  mutate(c = case_when(
    str_count(cumsum(t)) == 1 ~ paste0("00", cumsum(t)),
    str_count(cumsum(t)) == 2 ~ paste0("0", cumsum(t)),
    str_count(cumsum(t)) == 3 ~ paste0(cumsum(t))),
    name = paste(n, c, sep = "-"))
l<-matrix(nrow = length(s_lineas$Handle), ncol = 2)
for(i in seq_along(s_lineas$Handle)){
  l1<-buscar_nodos(s_lineas$Handle[i], nodos)
  l[i,]<-l1
}
s_lineas<-s_lineas%>%
  bind_cols(as_tibble(l), .name_repair = "unique")%>%
  rename(Nodo1 = V1, Nodo2 = V2)%>%
  ungroup()%>%
  select(-t, -n, -c)

## Segregación por tipo de señal
s_lineas_D<-s_lineas%>%
  filter(str_detect(Layer, "^ARBOL_D"))
s_lineas_A<-s_lineas%>%
  filter(str_detect(Layer, "^ARBOL_A"))
s_lineas_C<-s_lineas%>%
  filter(str_detect(Layer, "^ARBOL_C"))

# Generación de rutas
# Lista de cables
cables_2_JBI<-read_csv("entradas/tabla3.csv")%>%
  filter(str_detect(Dest, "^JBI") & !is.na(Cable1))%>%
  group_by(Cable1)%>%
  summarise(Cable1, Origen, Dest, Tipo_Sig, Pares = max(Par1))%>%
  unique()%>%
  ungroup()%>%
  rename(Cable = Cable1)
cables_2_GAB<-read_csv("entradas/tabla3.csv")%>%
  group_by(Cable2)%>%
  summarise(Cable2, Origen1 = Origen, Dest, Cntrl, Tipo_Sig, Pares = max(Par2))%>%
  mutate(Cntrl = str_replace(Cntrl, "PLC", "GAB"),  Origen = ifelse(Cntrl == Dest, Origen1, Dest))%>%
  select(-Origen1, -Dest)%>%
  rename(Dest = Cntrl, Cable = Cable2)%>%
  unique()%>%
  ungroup()
cables<-bind_rows(cables_2_JBI, cables_2_GAB)

# lista de rutas para Arbol_A
cables_A<-cables%>%
  filter(Tipo_Sig == "A")%>%
  left_join(select(nodos, Name, Handle), by = c("Origen" = "Name"))%>%
  rename(H_Origen = Handle)%>%
  left_join(select(nodos, Name, Handle), by = c("Dest" = "Name"))%>%
  rename(H_Dest = Handle)
if(sum(is.na(cables_A$H_Origen))!=0 | sum(is.na(cables_A$H_Dest))!=0){
  print("Advertencia: Algunos origenes o destinos no fueron encontrados en el plano")
}else{
  lista_cab<-vector(mode = "list", length = length(cables_t$Cable))
  for(i in seq_along(cables_t$Cable)){
    l<-ruta(cables_t$H_Origen[i], cables_t$H_Dest[i], NA, s_lineas_A)
    lista_cab[i]<-list(l$rut)
  }
  # Convertimos la lista a una matriz
  matriz<-as_tibble(t(sapply(lista_cab, "length<-", max(lengths(lista_cab)))))
  cables_t<-bind_cols(cables_t, matriz)
}

# Hasta este punto ya hemos obtenido un dataframe con la ruta correspondiente a cada cable del arbol A, hace falta usar mejor los nombres
# que los handles