# Segunda iteración paquete de instrumentación
# Generación de diagrama de lazos de control
library(tidyverse)
rm(list = ls())
source("funciones.R")

# Constantes usadas
# Cantidad de slots por rack
SR<-12
# Primer slot permitido para instalación de módulos IO
PS<-2
# Cantidad de canales por tipo de modulo IO
c_DI<-16
c_DO<-16
c_AI<-8
c_AO<-8
c_RTD<-6
c_TC<-6
# Construcción tabla 4, lazos de control
sig_cabl<-read_csv("entradas/tabla3.csv")%>%
  filter(Tag_Sig != "RESERVA")
tabla4<-read_csv("entradas/list_sig.csv")%>%
  select(`Tag señal`, Origen, `Locación`, Lazo, Servicio, `Tipo de I/O`, `Set Al`, `Un Ing`, 
         HMI, Interbloqueos, `Log de eventos`, Tendencia, `Histórico`)%>%
  rename(Tag_Sig = `Tag señal`, Tipo_IO = `Tipo de I/O`, Set_Al = `Set Al`, Und_Ing = `Un Ing`,
         Interl = Interbloqueos, Log_Ev = `Log de eventos`, Tend = Tendencia, Hist = `Histórico`,
         Loc = `Locación`)%>%
  left_join(sig_cabl)%>%
  mutate(ch_md = case_when(
           Tipo_IO == "AI" ~ c_AI,
           Tipo_IO == "AO" ~ c_AO,
           Tipo_IO == "DI" ~ c_DI,
           Tipo_IO == "DO" ~ c_DO,
           Tipo_IO == "RTD" ~ c_RTD,
           Tipo_IO == "TC" ~ c_TC
           )
         )

# Conteo de controladores
CNTRL<-tabla4%>%
  filter(Tipo_IO != "S")%>%
  group_by(Cntrl)%>%
  summarise()

# Asignación del IO
IO<-tabla4%>%
  select(Tag_Sig, Tipo_IO, ch_md, Cntrl)%>%
  arrange(Cntrl, Tipo_IO)
IO_Out<-tibble(IO[0,], ch = numeric(), md= numeric(), rk = numeric())

for(i in CNTRL$Cntrl){
  IO1<-filter(IO, Cntrl == i & Tipo_IO != "S")
  IO1<-asig_IO(IO1)
  IO_Out<-bind_rows(IO_Out, IO1)
}

# Conjunción con la tabla de lazos.
tabla4<-tabla4%>%
  left_join(IO_Out)

# Limpieza de variables
rm(CNTRL, IO, IO_Out, IO1, i, sig_cabl)

# Resumen de lazos
resumen<-tabla4%>%
  group_by(Lazo)%>%
  summarise()

## Generación del numero de pagina de cada señal cableada (indice para señales)

# Arrancamos de la pagina 3, para dejar una portada y un indice
pg<-3
ind_sig<-matrix(nrow = 0, ncol = 7)
soft<-matrix(nrow = 0, ncol = 7)
s<-0
for(i in resumen$Lazo){
  test<-tabla4%>%
    filter(Lazo == i)
  ind_sig1<-vector(mode = "character", 7)
  soft1<-vector(mode = "character", 7)
  ocup_acc<-0
  for(j in 1:nrow(test)){
    if(test$Tipo_IO[[j]] != "S"){
      k = j+1
      c_S<-0
      s<-s+1
      soft2<-matrix(nrow = 0, ncol = 7)
      if(k<=nrow(test)){
        while(test$Tipo_IO[k] == "S"){
          c_S<-c_S+1
          soft1<-c(test$Tag_Sig[k], test$Lazo[k], 0, 0, 0, 0, s)
          soft2<-rbind(soft2, soft1, deparse.level = 0)
          if(k+1<=nrow(test)){
            k<-k+1
          }else{
            break
          }
        }
      }
      ocup<-ifelse(c_S<3, 36, 36+10.5*(c_S-2))
      ocup_acc<-ocup_acc+ocup
      if(ocup_acc>108){
        pg<-pg+1
        ocup_acc<-ocup
      }
      ind_sig1<-c(test$Tag_Sig[j], test$Lazo[j], c_S, ocup, ocup_acc, pg, s)
      ind_sig<-rbind(ind_sig, ind_sig1, deparse.level = 0)
      soft2[, 6]<-pg
      soft<-rbind(soft, soft2, deparse.level = 0)
    }
  }
  pg<-pg+1
}
ind_sig<-as_tibble(ind_sig)%>%
  rename(Tag_Sig = V1, Lazo = V2, Cant_Soft = V3, Altura = V4, Alt_Acum = V5, Pag = V6, Conj_Sig = V7)
soft<-as_tibble(soft)%>%
  rename(Tag_Sig = V1, Lazo = V2, Cant_Soft = V3, Altura = V4, Alt_Acum = V5, Pag = V6, Conj_Sig = V7)
ind_sig<-bind_rows(ind_sig, soft)

tabla4<-tabla4%>%
  left_join(ind_sig)%>%
  mutate(Conj_Sig = as.numeric(Conj_Sig), Pag = as.numeric(Pag))

# Limpieza de variables
rm(ind_sig, resumen, soft, soft2, test, i, ind_sig1, j, k, ocup, ocup_acc, pg, s, soft1, c_S)

## Construcción de la matriz de hojas
fact<-vector(mode = "numeric", length = 0)
p_req<-max(as.numeric(tabla4$Pag))
p_sel<-10*ceiling(p_req/10)
for(i in 1:p_sel){
  if(p_sel%%i == 0){
    fact<-c(fact, i)
  }
}
filas<-fact[length(fact)/2]
columnas<-fact[length(fact)/2+1]
k<-1
mat_hoj<-matrix(nrow = 0, ncol = 3)
for(i in 1:columnas){
  for(j in 1:filas){
    mat_hoj1<-c(k, i-1, j-1)
    mat_hoj<-rbind(mat_hoj, mat_hoj1, deparse.level = 0)
    k = k+1
  }
}
mat_hoj<-as_tibble(mat_hoj[1:p_req, ])%>%
  rename(Pag = V1, Fila = V2, Columna = V3)
  #mutate(Pag = as.character(Pag))

tabla4<-tabla4%>%
  left_join(mat_hoj)

# Limpieza de variables
rm(mat_hoj, columnas, fact, filas, i, j, k, mat_hoj1, p_req, p_sel)

## Tablas de salida para generación de lazos
pth<-"salidas/lazos.js"
if(file.exists(pth)){
  file.remove(pth)
}

for(i in min(tabla4$Pag):max(tabla4$Pag)){
  sel1<-filter(tabla4, Pag == i)
  for(j in min(sel1$Conj_Sig):max(sel1$Conj_Sig)){
    sel2<-filter(sel1, Conj_Sig == j)
    for(k in 1:nrow(sel2)){
      d<-paste0("\"", sel2[k, ], "\"", collapse = ", ")
      d<-paste("var a", k, "=[", d, "];", sep = "")
      write(d, file = pth, ncolumns = 1, append = T)
    }
    e<-paste0("a", 1:nrow(sel2), collapse = ", ")
    e<-paste0("var s", j, "= [", e, "];")
    write(e, file = pth, ncolumns = 1, append = T)
  }
  f<-paste0("s", min(sel1$Conj_Sig):max(sel1$Conj_Sig), collapse = ", ")
  f<-paste0("var pag", i, "= [", f, "];")
  write(f, file = pth, ncolumns = 1, append = T)
}
g<-paste0("pag", min(tabla4$Pag):max(tabla4$Pag), collapse = ", ")
g<-paste0("var diag = [", g, "];")
write(g, file = pth, ncolumns = 1, append = T)
file.append(pth, "entradas/d_lazo_ini.js")

## Reportes

