library(tidyverse)
rm(list = ls())

rutas<-read_csv("entradas/rutas.csv")
l_conduits<-read_csv("entradas/l_cond.csv")
conduits<-rutas%>%
  pivot_longer(starts_with("V"), names_to = "Consec", values_to ="Cond")%>%
  filter(!is.na(Cond))%>%
  arrange(Cond, Cable)%>%
  mutate(tipo_cab = paste("TIPO", Pares, Tipo_Sig))%>%
  left_join(l_conduits, by =c("Cond"= "name"))

l_cables<-conduits%>%
  group_by(Cable)%>%
  summarise(long = sum(long))

# Generación rutas de cables con longitudes
rutas<-rutas%>%
  left_join(l_cables)%>%
  mutate(tipo_cab = paste("TIPO", Pares, Tipo_Sig))
names(rutas)<-gsub("V", "SEG", names(rutas))

write_csv(rutas, "salidas/l_rutas.csv")

tipos<-read_csv("entradas/tipo_cables.csv")
tipos<-tipos%>%
  mutate(area=pi*(OD/2)^2)

## Tabla de llenado de conduits
conduits<-conduits%>%
  left_join(tipos)

## Calculo de ocupación
area_cond<-conduits%>%
  group_by(Cond)%>%
  summarise(cant_cab = n(), a_tot = sum(area))%>%
  ungroup()%>%
  # Se calcula el diámetro nominal del conduit, en este caso usando IMC
  mutate(porc = ifelse(cant_cab == 1, 0.53,
                       ifelse(cant_cab == 2, 0.31, 0.4)),
         ar_min = a_tot/porc,
         cond_sel = ifelse(ar_min < 0.959, "1 in", 
                           ifelse(ar_min < 2.225, "1 1/2 in", 
                                  ifelse(ar_min < 3.630, "2 in", paste(ceiling(ar_min/3.630), "x 2 in")))
         )
  )
area_cond<-area_cond%>%
  left_join(l_conduits, by =c("Cond"= "name"))

# Reporte de conduits
rep_cond<-conduits%>%
  select(Cond, Cable)%>%
  group_by(Cond)%>%
  mutate(t=1, No_cable = paste("cable", cumsum(t)))%>%
  pivot_wider(names_from = No_cable, values_from = Cable)%>%
  select(-t)%>%
  left_join(area_cond)
write_csv(rep_cond, "salidas/rep_cond.csv")