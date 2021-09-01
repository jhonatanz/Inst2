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

# Función de búsqueda de nodos de cada linea
buscar_nodos<-function(linea, nodos){
  nod<-vector(mode = "character", length = 0)
  cord<-lineas%>%
    filter(Handle == linea)
  for(i in 1:length(cord$Ver_X)){
    vec_l1<-round(nodos$Pos_X, 2) == round(cord$Ver_X[i], 2)
    vec_l2<-round(nodos$Pos_Y, 2) == round(cord$Ver_Y[i], 2)
    vec_l<-vec_l1&vec_l2
    if(sum(vec_l)==1){
      nod<-c(nod, nodos$Handle[vec_l])
    }
  }
  return(nod)
}

### Función buscar hijos
buscar_hijos<-function(n_origen, l_origen = NA, s_lineas){
  if(is.na(l_origen)){
    hijos<-s_lineas
  }else{
    hijos<-s_lineas%>%
      filter(Handle != l_origen)
  }
  hijos<-hijos%>%
    filter(Nodo1 == n_origen | Nodo2 == n_origen)%>%
    mutate(Nodo = ifelse(Nodo1 == n_origen, Nodo2, Nodo1))%>%
    select(Handle, Nodo, name)
  return(hijos)
}

### Función de búsqueda de ruta de un cable
ruta<-function(n_orig, n_dest, l_orig = NA, s_lineas){
  hijos<-buscar_hijos(n_orig, l_orig, s_lineas)
  ind_dest<-which(hijos$Nodo == n_dest) # Genera cero cuando no hay coincidencia y vacío cuando no hay hijos
  if(sum(ind_dest)!=0){ # si no hay coincidencia o hijos, la suma daría cero, es decir que entramos aquí solo si encontramos el destino
    r<-list(rut = hijos$name[ind_dest], exito = T) #reemplazado Handle
    return(r)
  }else{
    if(length(hijos$Nodo)==0){
      r<-list(rut = character(), exito = F)
      return(r)
    }else{
      for(i in seq_along(hijos$Nodo)){
        r<-ruta(hijos$Nodo[i], n_dest, hijos$Handle[i], s_lineas)
        if(r$exito){
          r$rut<-c(hijos$name[i], r$rut) #reemplazado Handle
          return(r)
          break
        }
      }
      return(r)
    }
  }
}

### Función rutas para cada árbol
rutas_arbol<-function(cables, tipo, s_lineas, nodos){
  cables_t<-cables%>%
    filter(Tipo_Sig == tipo)%>%
    left_join(select(nodos, Name, Handle), by = c("Origen" = "Name"))%>%
    rename(H_Origen = Handle)%>%
    left_join(select(nodos, Name, Handle), by = c("Dest" = "Name"))%>%
    rename(H_Dest = Handle)
  if(sum(is.na(cables_t$H_Origen))!=0 | sum(is.na(cables_t$H_Dest))!=0){
    print("Advertencia: Algunos origenes o destinos no fueron encontrados en el plano")
  }else{
    lista_cab<-vector(mode = "list", length = length(cables_t$Cable))
    for(i in seq_along(cables_t$Cable)){
      l<-ruta(cables_t$H_Origen[i], cables_t$H_Dest[i], NA, s_lineas)
      lista_cab[i]<-list(l$rut)
    }
    # Convertimos la lista a una matriz
    matriz<-as_tibble(t(sapply(lista_cab, "length<-", max(lengths(lista_cab)))))
    rutas<-bind_cols(cables_t, matriz)
    return(rutas)
  }
}