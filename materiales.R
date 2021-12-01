library(tidyverse)
rm(list = ls())
tipicos<-read_csv("entradas/tipicos.csv")%>%
  filter(`Referenced Block`=="A4_vert_JZ" | `Referenced Block`=="Lin_list_mat")%>%
  select(`Referenced Block`, `Position:X`, `Position:Y`, `Attributes:DESCRIPCION`, 
         `Attributes:ITEM`, `Attributes:QTY`, `Attributes:SIZE`, `Attributes:Sub_titulo`)%>%
  rename(Ref = `Referenced Block`, Pos_X = `Position:X`, Pos_Y = `Position:Y`, Desc = `Attributes:DESCRIPCION`,
         Item = `Attributes:ITEM`, Cant = `Attributes:QTY`, Size = `Attributes:SIZE`, Subt = `Attributes:Sub_titulo`)
tip<-tipicos%>%
  filter(Ref=="A4_vert_JZ")%>%
  select(Ref, Pos_X, Pos_Y, Subt)%>%
  arrange(Pos_Y, Pos_X)
mat<-tipicos%>%
  filter(Ref=="Lin_list_mat")%>%
  select(-Subt)
tip_out<-character()
pg_out<-numeric()
for(i in 1:length(mat$Ref)){
  pg<-last(which(mat$Pos_X[i]>=tip$Pos_X & mat$Pos_Y[i]>=tip$Pos_Y))
  t<-tip$Subt[pg]
  tip_out<-c(tip_out, t)
  pg_out<-c(pg_out, pg)
}
mat_n<-bind_cols(mat, tip = tip_out, pg = pg_out)%>%
  arrange(pg, Item)
write_csv(mat_n, "salidas/materiales.csv")
