## Funcion de generacion de diagramas de conexionado
GEN <- function(df_caja, dest){
  sel<-df_caja%>%
    filter(Dest == dest)%>%
    arrange(TS, borne1)
  pth<-paste("salidas/", dest, ".js", sep = "")
  if(file.exists(pth)){
    file.remove(pth)
  }
  for(i in 1:nrow(sel)){
    d<-paste0("\"", sel[i, ], "\"", collapse = ", ")
    d<-paste("var a", i, "=[", d, "];", sep = "")
    write(d, file = pth, ncolumns = 1, append = T)
  }
  e<-paste0("a", 1:nrow(sel), collapse = ", ")
  e<-paste0("var diag = [", e, "];")
  write(e, file = pth, ncolumns = 1, append = T)
  file.append(pth, "entradas/d_conn_JB.js")
}


## Función de asignación de IO
asig_IO <- function(IO){
  # Asigna el canal, modulo y rack a cada señal en un controlador, tiene que estar filtrada la entrada por controlador
  cod_old <- IO$Tipo_IO[1]
  ch <- 0
  mx_old <- IO$ch_md[1]
  res_old <- 1
  md <- 0
  md_old <- 0
  rk <- 0
  ch_out<-vector(mode = "numeric", length = length(IO$ch_md))
  md_out<-vector(mode = "numeric", length = length(IO$ch_md))
  rk_out<-vector(mode = "numeric", length = length(IO$ch_md))
  for(i in 1:length(IO$ch_md)){
    cod <- IO$Tipo_IO[i]
    mx <- IO$ch_md[i]
    if(cod == cod_old ){
      ch <- ch+1
    }else{
      ch <- ch+(mx_old-res_old)
    }
    res <- (ch-1) %% mx
    if((res == 0 & ch != 0) | cod != cod_old){
      md <- md+1
      ch <- 1
    }
    if((md-1) %% 12 == 0 & md != md_old){
      rk <- rk+1
    }
    ch_out[i] <- ch
    md_out[i] <- md
    rk_out[i] <- rk
    cod_old <- cod
    mx_old <- mx
    res_old <- res
    md_old <- md
  }
  IO_out<-bind_cols(IO, ch = ch_out, md = md_out, rk = rk_out)
  return(IO_out)
}