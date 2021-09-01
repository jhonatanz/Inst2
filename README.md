# Inst2
## Scripts para la automatización del desarrollo de ingenierías

En este conjunto de scripts se desarrolla un método para la generación automática de planos y tablas propias del desarrollo de ingenierías de automatización.
Como entrada se tiene una lista de señales en el formato establecido en el archivo "lista_sig.csv", las instrucciones de llenado se dejarán posteriormente en el mismo archivo.

## Manual de uso

A continuación se explica como es el proceso para generación de entregables, el proceso es secuencial en el orden que se presenta aqui:

### Trabajo previo

Antes de usar los scripts que hacen parte de este proyecto se debe elaborar una lista de señales de acuerdo con el formato establecido en la carpeta "entradas". El archivo debe llamarse "list_sig.csv" y los campos deben llenarse de acuerdo con los siguientes criterios:

1. Los tags de las señales no deben repetirse.
2. Las señales por convención van del origen en campo hacia el cuarto de control.
3. Las IO tipo S (Soft) no tienen asociado destino ni tipo de señal. En caso que la señal soft se deba usar para alguna lógica de control en el controlador, deberá configurarse en este, de otro modo, solo se configurarán en el/los HMI que corresponda.

### Diagramas de conexionado

De la lista de señales se generan automáticamente los diagramas de conexionado, el procedimiento consiste en dos pasos:

1. Ejecución del script "diag_conn.R": el script procesa la lista de señales para generar la "tabla3.csv" en la carpeta "entradas", en donde ya están generados y conectados los cables del proyecto. Asi mismo, el script genera varios script en JS para su ejecución en QCAD.
2. Ejecución de los scripts JS: el script "diag_conn.R" genera varios scripts, especificamente, genera un script por cada caja de conexionado o gabinete. Cada script JS deberá correrse en QCAD para generar el plano correspondiente a la caja o gabinete

### Digramas de lazo

La "tabla3.csv" generada previamente se usa como entrada para la generación de los diagramas de lazo por parte del script "diag_lazos.R", similar a lo visto en la generación de diagramas de conexionado:

1. Ejecución del script "diag_lazos.R": Se genera un script JS para ejecución en QCAD, también genera la tabla "b_cajas.csv" en la carpeta "salidas" con un reporte del tamaño de las borneras en cada caja.
2. Ejecución del script JS de lazos: en el paso anterior se generó un solo script JS "lazos.js", este se ejecuta en QCAD y genera automáticamente los lazos.

### Rutas

El script "rutas.R" genera varias tablas que se usan para el desarrollo de varios reportes:

1. Tabla de rutas: contiene la ruta de canalización de cada uno de los cables del proyecto, en el archivo "rutas.csv" en la carpeta "entradas"
2. Lista de conduits: lista de los segmentos de conduits del proyecto con las longitudes de cada segmento, en el archivo "l_cond.csv" en la carpeta "entradas"
3. Localización de lineas: una tabla con la ubicación de los segmentos de conduit, en el archivo "loc_lineas.csv" en la carpeta "salidas"
4. Localización de nodos: una tabla con la ubicación de cada nodo de la localización, un nodo es todo elemento en el que se tiene el extremo de algun conduit, esto cubre instrumentos, cajas, gabinetes, conduletas, puntos de halado, etc.

### Reportes

El script "reportes.R" genera dos reportes adicionales para su uso dentro de la ingeniería:

1. Longitud rutas: tabla del rutas de canalizaciones con las longitudes asociadas a cada cable, en el archivo "l_rutas.csv" en la carpeta "salidas".
2. Reporte de conduits: tabla de conduits con la memoria de calculo de llenado de cada conduit, en el archivo "rep_cond.csv" en la carpeta "salidas"

### Pendientes

1. Encontrar un modo de plasmar directamente en el plano de rutas los tags de los nodos
2. plasmar en el plano de rutas los tags de los conduits
3. generar un reporte para los bancos de ductos, hasta ahora solo tenemos reporte de los conduits pero no del banco general
4. en la tabla l_cond incluir una columna para incluir las longitudes verticales
5. en la tabla l_rutas incluir las longitudes verticales en el calculo de longitud del cable

