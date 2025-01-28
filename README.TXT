PRUEBA TÉCNICA
Fecha: 27 de enero de 2024 
Descripción del proceso

1. PROCESAMIENTO DE ARCHIVOS HTML EN PYTHON

Descripción del problema:

Descripción
Este script procesa archivos HTML para convertir las imágenes referenciadas en las etiquetas <img> a su equivalente codificado en Base64. El objetivo es reemplazar las referencias a archivos de imagen con cadenas codificadas que se puedan incrustar directamente en el HTML, lo que es útil para mejorar la portabilidad de los archivos HTML o para servirlos en entornos donde no se puedan acceder a las imágenes de manera separada.

Pasos realizados
1. Importación de librerías
Se importan las librerías necesarias para:

os: Manejo de rutas y directorios.
base64: Codificación de las imágenes a formato Base64.
pathlib.Path: Manejo de rutas de archivos de manera multiplataforma.
typing: Uso de anotaciones de tipos (List, Union, Dict) para mayor claridad en el código.
html.parser.HTMLParser: Procesamiento y manipulación de contenido HTML.

2. Clase ImageProcessor
La clase ImageProcessor analiza las etiquetas <img> dentro de los archivos HTML y realiza las siguientes tareas:

Identifica las imágenes referenciadas mediante el atributo src de las etiquetas <img>.
Intenta cargar la imagen desde el sistema de archivos.
Convierte la imagen a una cadena Base64.
Reemplaza el atributo src original con la cadena Base64.
Registra las imágenes procesadas y las que fallaron al procesarse.
Métodos principales:

handle_starttag: Procesa etiquetas de inicio, especialmente <img>, y realiza la conversión a Base64.
handle_endtag: Agrega las etiquetas de cierre al contenido HTML resultante.
handle_data: Agrega el contenido textual entre las etiquetas al HTML resultante.

3. Clase HTMLProcessor
Esta clase se encarga de:

Recibir una lista de rutas (archivos o directorios).
Identificar todos los archivos HTML en la lista.
Procesar cada archivo HTML utilizando ImageProcessor.
Métodos principales:

find_html_files: Busca archivos HTML en los directorios o rutas indicados.
process_files: Procesa los archivos HTML encontrados, generando un archivo con el sufijo _processed.html para cada archivo procesado.
Resultados:

Los resultados se almacenan en un diccionario con dos claves principales:
success: Registra las imágenes procesadas correctamente.
fail: Registra las imágenes que fallaron en el procesamiento o los errores al procesar archivos HTML.

4. Ejecución principal
En el bloque principal (if __name__ == "__main__"), se define la lista de entradas (input_paths) que incluye directorios y archivos individuales a procesar. Posteriormente:

Se instancia un objeto de la clase HTMLProcessor.
Se ejecuta el procesamiento de los archivos HTML.
Se imprime un reporte en consola con los resultados.

2. PREFERENCIAS DE CONSUMO

Para la elaboración del proyecto se creó un esquema de bases de datos para alamcenar la información de clientes, categorías de consumo y transacciones,
ademas de generar  consultas para identificar categorías de consumo preferidas por los clientes.

Esquema de Base de datos:

Nombre de la base de datos: Consumo.

Tablas:

1. Clientes:

En esta tabla se almacena la información de los clientes, incluyendo su nombre, identificación, tipo de documento, clasificación, tipo de tarjeta, fecha de apertura y estado de la tarjeta.

2. Categoría de Consumo:

En esta tabla se registran las categorías de consumo relacionadas con las transacciones, donde se incluye: código de la categoria, nombre de la categoria, ciudad y departamento.

3. Transacciones:

Registra las transacciones realizadas por los clientes, incluyendo detalles de identificación del cliente, id de la transacción, estado, valor de la compra, código de la categoría, fecha de la transacción.

Para dar solución se siguieron los siguientes pasos:

   - 
2. Cargue de Información a la base de datos utilizando PENTAHO.

La información del archivo con los datos a utilizar se cargo a la base de datos utilizando Pentaho, donde se realizó validación de los datos duplicados.


Consultas Principales:

A. Preferencias de consumo:

Esta consulta se diseñó para identificar las preferencias de consumo preferidas por cada cliente, basadas en el número de transacciones aporbadas dentro de un periodo de tiempo.

Descripción:

- Datos Obtenidos:

   * Identificación y nombre de cliente.
   * Categorías de consumo más relevantes.
   * Fecha de la última transacción de la categoría.

- Filtros aplicados:

   * Se utilizó el estado de la transacción con valor "Aprobada".
   * Rango de fechas de las transacciones.

- Consideraciones:

    * Se ordenaros los registros por cliente y el número de transacciones.
    * Selección de las n categorías principales por cliente ajustable con "rc.rank <= n".


3. RACHAS

Para la elaboración del proyecto permite realizar análisis de las rachas consecutivas de niveles de deuda de clientes teniendo en cuenta su saldo mensual. En la información, tambien se considera el impacto de los retiros realizados por los clientes.

Esquema de base de datos:

Se crearon las tablas: Historia y Retiros.

Historia:

Guarda información de saldos de los clientes por mes. 

Campos: Identificación, Corte_mes, Saldo.

Retiros: Registra información de los retiros realizados por los clientes.

Campos: Identificación, fecha_retiro.


- Cargue de Información:

La información del archivo rachas.xlsx fue cargada en las tablas de la base de datos utilizando Pentaho.


Creación de la Consulta:

1. Clasificación de los niveles de deuda:
La consulta realiza la clasificación de los clientes en niveles segun el saldo en el mes correspondiente teniendo en cuenta los cirterios definidos.

2. Se asegura que todos los meses estén presentes para cada clientes, incluso si no tienen registros en la tabla hsitoris.

3. Identificación de Rachas:
Se realiza resumen de fechas donde se identifican:
 - Fecha inicio.
 - Fecha fin.
 - Duración de la racha.

4. Filtro de rachas:
Se selecciona la racha más larga para cada cliente.

5. La consulta final arroja los siguientes resultados:
- Identificación del cliente.
- Nivel: Nivel de deuda durante la racha.
- Racha: Duración.
- Fecha fin: Fecha fin de la racha.

Las Consultas fueron creadas en MySQL

