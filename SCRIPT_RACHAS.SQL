--PRUEBA TÉCNICA
#Rachas
#Creación de tablas a utilizar

create table historia (
    identificacion VARCHAR(50),
    corte_mes DATE,
    saldo NUMERIC(18, 2)
);

create table retiros (
    identificacion VARCHAR(50),
    fecha_retiro DATE
);

#Codigo de la consulta

WITH niveles AS (
    -- Clasificación de los niveles de deuda según su saldo
    SELECT 
        h.identificacion,
        h.corte_mes,
        CASE 
            WHEN h.saldo >= 0 AND h.saldo < 300000 THEN 'N0'
            WHEN h.saldo >= 300000 AND h.saldo < 1000000 THEN 'N1'
            WHEN h.saldo >= 1000000 AND h.saldo < 3000000 THEN 'N2'
            WHEN h.saldo >= 3000000 AND h.saldo < 5000000 THEN 'N3'
            WHEN h.saldo >= 5000000 THEN 'N4'
        END AS nivel,
        COALESCE(r.fecha_retiro, '9999-12-31') AS fecha_retiro -- Fecha de retiro
    FROM historia h
    LEFT JOIN retiros r ON h.identificacion = r.identificacion
),
meses_completos AS (
 --meses completos
    SELECT 
        n.identificacion,
        m.corte_mes,
        CASE 
            WHEN n.nivel IS NULL AND m.corte_mes <= n.fecha_retiro THEN 'N0'
            ELSE n.nivel
        END AS nivel
    FROM (
        SELECT DISTINCT corte_mes FROM historia -- meses únicos
    ) m
    CROSS JOIN (SELECT DISTINCT identificacion, fecha_retiro FROM niveles) n
    LEFT JOIN niveles k ON n.identificacion = k.identificacion AND m.corte_mes = k.corte_mes
),
rachas AS (
    -- Calcular las rachas consecutivas por cliente y nivel
    SELECT 
        mc.identificacion,
        mc.nivel,
        mc.corte_mes,
        ROW_NUMBER() OVER (PARTITION BY mc.identificacion, mc.nivel ORDER BY mc.corte_mes) 
        - ROW_NUMBER() OVER (PARTITION BY mc.identificacion ORDER BY mc.corte_mes) AS grupo_racha
    FROM meses_completos mc
),
resumen_rachas AS (
    -- Resumir las rachas con su duración y fechas de inicio/fin
    SELECT 
        r.identificacion,
        r.nivel,
        MIN(r.corte_mes) AS fecha_inicio,
        MAX(r.corte_mes) AS fecha_fin,
        COUNT(*) AS racha
    FROM rachas r
    GROUP BY r.identificacion, r.nivel, grupo_racha
),
rachas_filtradas AS (
    -- Filtrar las rachas mayores o iguales a n
    SELECT *
    FROM resumen_rachas
    WHERE racha >= 3 -- Nivel de preferencia
),
racha_final AS (
    -- Seleccionar la racha más larga y priorizar por fecha más reciente
    SELECT 
        rf.identificacion,
        rf.nivel,
        rf.racha,
        rf.fecha_fin
    FROM rachas_filtradas rf
    WHERE NOT EXISTS (
        SELECT 1
        FROM rachas_filtradas rf2
        WHERE rf2.identificacion = rf.identificacion
          AND rf2.racha > rf.racha
          OR (rf2.racha = rf.racha AND rf2.fecha_fin > rf.fecha_fin)
    )
)
-- Resultado final
SELECT *
FROM racha_final
ORDER BY identificacion, fecha_fin DESC;
