#PRUEBA TÉCNICA
#Se importan las librerias que se van a utilizar
#Descripción del proceso
import os #Manejar rutas de archivos y los directorios que se vayan a utilizar
import base64 #Codificar imágenes en Base64
from pathlib import Path #Manejo de rutas de archivos 
from typing import List, Union, Dict #List:Manejo de listas Dict:Manejo de Diccionarios
from html.parser import HTMLParser #Manipular y procesar el contenido html

#Se define la clase para analizar y que pueda procesar las imágenes que se consigan dentro de los html
#Constructor
class ImageProcessor(HTMLParser):
    def __init__(self, base_path: Path):
        super().__init__()
        self.base_path = base_path
        self.images = []
        self.processed_images = []
        self.failed_images = [] 
        self.result_html = ""

    def handle_starttag(self, tag, attrs): #Se procesan la imágenes de apertura
        if tag == "img": #Verifica si la etiqueta es img para cosneguir el valor del atributo que tiene src
            attrs_dict = dict(attrs)
            img_src = attrs_dict.get("src")
            #Si src no está vacio muestra la ruta de la imágen
            #realiza la conversión a Base64 y actualiza el atributo src de la etiqueta con la cadena codificada
            #Si se presenta algun error agrega la imággen a failed_images
            if img_src:
                self.images.append(img_src)
                try:
                    img_path = (self.base_path / img_src).resolve()
                    with open(img_path, "rb") as img_file:
                        img_data = img_file.read()
                        base64_data = base64.b64encode(img_data).decode("utf-8")
                        attrs_dict["src"] = f"data:image/{img_path.suffix[1:]};base64,{base64_data}"
                        self.processed_images.append(img_src)
                except Exception:
                    self.failed_images.append(img_src)
            #Se reconstruye la etiqueta <img> con los atributos actualizados y los agrega a result_html
            attrs_string = " ".join(f'{k}="{v}"' for k, v in attrs_dict.items())
            self.result_html += f"<{tag} {attrs_string}>"
        else:
            attrs_string = " ".join(f'{k}="{v}"' for k, v in attrs)
            self.result_html += f"<{tag} {attrs_string}>"
     #Se procesan etiquetas de cierre
    def handle_endtag(self, tag):
        self.result_html += f"</{tag}>"
    #Se procesa el contenido de las etiquetaas
    def handle_data(self, data):
        self.result_html += data
#Se procesa el listado de archivos o los directorios HTML
class HTMLProcessor:
    #Constructor 
    def __init__(self, input_list: List[Union[str, Path]]):
        self.input_list = [Path(item) for item in input_list] #input_list: lista de rutas proporcionadas
        self.result = {"success": {}, "fail": {}} #Se crea un diccionario para que almacene los resultados

    def find_html_files(self) -> List[Path]: #Busca todos los archivos html en el directorio o lista indicada
        #Se recopilan los archivos .html 
        html_files = []
        for item in self.input_list:
            if item.is_dir():
                html_files.extend(item.rglob("*.html"))
            elif item.is_file() and item.suffix == ".html":
                html_files.append(item)
        return html_files

    def process_files(self): #Se obtiene los archivos html que se van a procesar 
        html_files = self.find_html_files()
        #Lee contenido del archivo html
        for html_file in html_files:
            try:
                with open(html_file, "r", encoding="utf-8") as file:
                    content = file.read()
                #Instancia ImageProcessor y lo utiliza para analizar el contenido html
                processor = ImageProcessor(base_path=html_file.parent)
                processor.feed(content)

                # Se guarda el archivo html que se proceso en un nuevo archivo _processed.html
                output_file = html_file.with_name(f"{html_file.stem}_processed.html")
                with open(output_file, "w", encoding="utf-8") as file:
                    file.write(processor.result_html)

                # Se utiliza para registas las imágenes procesas y las fallidas
                self.result["success"][str(html_file)] = processor.processed_images
                self.result["fail"][str(html_file)] = processor.failed_images
            #se utiliza para manejar los errores que se presenten durtante la ejecución y procesamiento
            except Exception as e:
                self.result["fail"][str(html_file)] = [f"Error processing file: {e}"]
        #Retorna los resultados
        return self.result


if __name__ == "__main__":
    input_paths = ["./html_files", "./example.html"]  # Lista de directorios o archivos
    processor = HTMLProcessor(input_paths)
    report = processor.process_files()

    print("Reporte de procesamiento:")
    print(report)
