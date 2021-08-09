# Inst2
## Scripts para la automatización del desarrollo de ingenierias

En este conjunto de scripts se desarrolla un metodo para la generacion automatica de planos y tablas propias del desarrollo de ingenierias de automatización.
Como entrada se tiene una lista de señales en el formato establecido en el archivo "lista_sig.csv", las instrucciones de llenado se dejarán posteriormente en 
el mismo archivo.

Los scripts deberán ser ejecutados en el siguiente orden:
- diag_conn.R
- diag_lazos.R

El primer script genera el archivo "tabla3.csv" que es la entrada para el script de diagrama de lazos, si el primero ya se ejecutó una vez no es necesario 
ejecutarlo de nuevo para que el script de lazos funcione correctamente. Adicional a la tabla 3, el script "diag_conn.R" genera varios nuevos script en javascript 
que se usan como entrada para la generacion automatica de los planos en la herramienta de dibujo QCAD. Por ahora se tienen que ejecutar manualmente los scripts en
QCAD, pero en un futuro se prevee la generacion automatica de los dibujos directamente desde R. Los scripts de R hacen toda la manipulacion de datos necesaria para 
crear una tabla ordenada y llena de información que luego es usada como entrada para los scripts de javascript para la generacion de los planos, el uso de 
javascript es necesario dado que es el lenguaje que entiende QCAD para el desarrollo de los planos.

El segundo script funciona de forma analoga al primero, en R se transforman los datos para crear un dataframe (tabla) de entrada al script de javascript que genera 
los dibujos en QCAD.

La continuación del desarrollo prevee la inclusión de un nuevo script para el conteo de materiales desde la planimetria de rutas, tambien numerosos reportes para:

- Reportes de Entradas/Salidas del sistema de control
- Lista de cables
- Lista de conduits
- Calculo de llenado de conduits
- Guia de cableado
- Lista de materiales
