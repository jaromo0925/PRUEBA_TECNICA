--PRUEBA TÉCNICA
--Tablas a utilizar
create database CONSUMO;

use CONSUMO;

#SE CREAN LAS TABLAS REQUERIDAD
CREATE TABLE clientes (
    identificacion VARCHAR(20) NOT NULL PRIMARY KEY,   
    nombre VARCHAR(100) NOT NULL,                
    tipo_documento VARCHAR(20) NOT NULL,         
    clasificacion VARCHAR(50),                   
    tipo_tarjeta VARCHAR(20),                    
    fecha_apertura_tarjeta DATE,                 
    estado_tarjeta VARCHAR(20)                   
);



CREATE TABLE categorias_consumo (
    codigo_categoria INT NOT NULL PRIMARY KEY, 
    nombre_categoria VARCHAR(50) NOT NULL,                   
    ciudad VARCHAR(50),                                       
    departamento VARCHAR(50)                                  
)


CREATE TABLE transacciones (
    id_transaccion INT NOT NULL PRIMARY KEY, 
    identificacion VARCHAR(20) NOT NULL,                   
    fecha_transaccion DATE NOT NULL,                       
    codigo_categoria INT NOT NULL,                         
    estado VARCHAR(20),                                    
    valor_compra DECIMAL(10, 2) NOT NULL ,                
 FOREIGN KEY (identificacion) REFERENCES clientes(identificacion),
 FOREIGN KEY (codigo_categoria) REFERENCES categorias_consumo(codigo_categoria)
);



#Preferencias de Consumo
SELECT c.identificacion,
       c.nombre,
       rc.nombre_categoria,
       rc.ultima_transaccion
FROM clientes c
JOIN (
    SELECT ta.identificacion,
           ta.codigo_categoria,
           ta.nombre_categoria,
           ta.total_gasto,
           ta.total_transacciones,
           ta.ultima_transaccion,
           @rank := IF(@prev_identificacion = ta.identificacion, @rank + 1, 1) AS rank,
           @prev_identificacion := ta.identificacion
    FROM (
        SELECT t.identificacion,
               t.codigo_categoria,
               c.nombre_categoria,
               SUM(t.valor_compra) AS total_gasto,
               COUNT(t.id_transaccion) AS total_transacciones,
               MAX(t.fecha_transaccion) AS ultima_transaccion
        FROM Transacciones t
        JOIN Categorias_consumo c ON t.codigo_categoria = c.codigo_Categoria
        WHERE t.estado = 'Aprobada'
        AND t.fecha_transaccion BETWEEN '2023-01-01' AND '2023-06-01' 
        GROUP BY t.identificacion, t.codigo_categoria, c.nombre_categoria
        ORDER BY t.identificacion, total_gasto DESC, total_transacciones DESC
    ) ta
    CROSS JOIN (SELECT @rank := 0, @prev_identificacion := '') AS init
) rc ON c.identificacion = rc.identificacion
WHERE rc.rank <= 3 -- Para obtener las n primeras categorías preferidas
ORDER BY c.identificacion, rc.rank;



