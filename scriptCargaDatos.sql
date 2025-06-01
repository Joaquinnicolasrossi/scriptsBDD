USE [GD1C2025];
GO

--------------------------------------------------------------------------------
-- 1) DESHABILITO TODAS LAS FOREIGN KEYS DEL ESQUEMA CNEJ
--------------------------------------------------------------------------------
EXEC sp_MSforeachtable 
    @command1 = '
        IF ''?'' LIKE ''%CNEJ.%''  
            ALTER TABLE ? NOCHECK CONSTRAINT ALL
    ';
GO


--------------------------------------------------------------------------------
-- 2) CTE PARA ARMAR LA TABLA CONTACTO
--------------------------------------------------------------------------------
;WITH CTE_Contactos AS (
    SELECT DISTINCT
        Cliente_Telefono   AS telefono,
        Cliente_Mail       AS mail
    FROM gd_esquema.Maestra
    WHERE Cliente_Telefono IS NOT NULL

    UNION

    SELECT DISTINCT
        Sucursal_telefono  AS telefono,
        Sucursal_mail      AS mail
    FROM gd_esquema.Maestra
    WHERE Sucursal_telefono IS NOT NULL

    UNION

    SELECT DISTINCT
        Proveedor_Telefono AS telefono,
        Proveedor_Mail     AS mail
    FROM gd_esquema.Maestra
    WHERE Proveedor_Telefono IS NOT NULL
)
INSERT INTO CNEJ.Contacto (con_numero, con_telefono, con_mail)
SELECT
    ROW_NUMBER() OVER (ORDER BY telefono, mail) AS con_numero,
    telefono,
    mail
FROM CTE_Contactos;
GO


--------------------------------------------------------------------------------
-- 3.1) POBLO PROVINCIA
--------------------------------------------------------------------------------
;WITH DistinctProvincia AS (
    SELECT DISTINCT Sucursal_Provincia AS nombre
    FROM gd_esquema.Maestra
    WHERE Sucursal_Provincia IS NOT NULL

    UNION

    SELECT DISTINCT Cliente_Provincia
    FROM gd_esquema.Maestra
    WHERE Cliente_Provincia IS NOT NULL

    UNION

    SELECT DISTINCT Proveedor_Provincia
    FROM gd_esquema.Maestra
    WHERE Proveedor_Provincia IS NOT NULL
)
INSERT INTO CNEJ.Provincia (pro_numero, pro_nombre)
SELECT
    ROW_NUMBER() OVER (ORDER BY nombre) AS pro_numero,
    nombre AS pro_nombre
FROM DistinctProvincia;
GO


--------------------------------------------------------------------------------
-- 3.2) POBLO LOCALIDAD
--------------------------------------------------------------------------------
;WITH DistinctLocalidad AS (
    SELECT DISTINCT Sucursal_Localidad AS nombre
    FROM gd_esquema.Maestra
    WHERE Sucursal_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT Cliente_Localidad
    FROM gd_esquema.Maestra
    WHERE Cliente_Localidad IS NOT NULL

    UNION

    SELECT DISTINCT Proveedor_Localidad
    FROM gd_esquema.Maestra
    WHERE Proveedor_Localidad IS NOT NULL
)
INSERT INTO CNEJ.Localidad (loc_numero, loc_nombre)
SELECT
    ROW_NUMBER() OVER (ORDER BY nombre) AS loc_numero,
    nombre AS loc_nombre
FROM DistinctLocalidad;
GO


--------------------------------------------------------------------------------
-- 3.3) POBLO MATERIAL (solo campos comunes)
--------------------------------------------------------------------------------
;WITH DistinctMaterial AS (
    SELECT DISTINCT
        Material_Tipo,
        Material_Nombre,
        Material_Descripcion,
        Material_Precio
    FROM gd_esquema.Maestra
    WHERE Material_Tipo IS NOT NULL
)
INSERT INTO CNEJ.Material (mat_numero, mat_tipo, mat_nombre, mat_descripcion, mat_precio)
SELECT
    ROW_NUMBER() OVER (ORDER BY Material_Tipo, Material_Nombre) AS mat_numero,
    Material_Tipo,
    Material_Nombre,
    Material_Descripcion,
    Material_Precio
FROM DistinctMaterial;
GO


--------------------------------------------------------------------------------
-- 3.4) POBLO MODELO (Sillon_Modelo_Codigo viene en Maestra)
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Modelo (mod_numero, mod_tipo, mod_descripcion, mod_precio)
SELECT DISTINCT
    CAST(Sillon_Modelo_Codigo AS BIGINT)       AS mod_numero,
    Sillon_Modelo                             AS mod_tipo,
    Sillon_Modelo_Descripcion                 AS mod_descripcion,
    Sillon_Modelo_Precio                      AS mod_precio
FROM gd_esquema.Maestra
WHERE Sillon_Modelo_Codigo IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 3.5) POBLO MEDIDA (las cuatro columnas de medida)
--------------------------------------------------------------------------------
;WITH DistinctMedida AS (
    SELECT DISTINCT
        Sillon_Medida_Alto        AS med_alto,
        Sillon_Medida_Ancho       AS med_ancho,
        Sillon_Medida_Profundidad AS med_profundidad,
        Sillon_Medida_Precio      AS med_precio
    FROM gd_esquema.Maestra
    WHERE Sillon_Medida_Alto IS NOT NULL
)
INSERT INTO CNEJ.Medida (med_numero, med_alto, med_ancho, med_profundidad, med_precio)
SELECT
    ROW_NUMBER() OVER (ORDER BY med_alto, med_ancho, med_profundidad) AS med_numero,
    med_alto,
    med_ancho,
    med_profundidad,
    med_precio
FROM DistinctMedida;
GO


--------------------------------------------------------------------------------
-- 4.1) POBLO SUCURSAL (depende de Provincia, Localidad, Contacto)
--------------------------------------------------------------------------------
;WITH CTE_Sucursal AS (
    SELECT DISTINCT
        CAST(Sucursal_NroSucursal AS BIGINT) AS suc_numero,
        Sucursal_Provincia                  AS suc_provincia,
        Sucursal_Localidad                  AS suc_localidad,
        Sucursal_Direccion                  AS suc_direccion,
        Sucursal_telefono                   AS suc_telefono,
        Sucursal_mail                       AS suc_mail
    FROM gd_esquema.Maestra
    WHERE Sucursal_NroSucursal IS NOT NULL
)
INSERT INTO CNEJ.Sucursal
    (suc_numero, suc_provincia, suc_localidad, suc_contacto, suc_direccion)
SELECT
    S.suc_numero,
    P.pro_numero,
    L.loc_numero,
    C.con_numero,
    S.suc_direccion
FROM CTE_Sucursal AS S
    LEFT JOIN CNEJ.Provincia AS P
        ON P.pro_nombre = S.suc_provincia
    LEFT JOIN CNEJ.Localidad AS L
        ON L.loc_nombre = S.suc_localidad
    LEFT JOIN CNEJ.Contacto AS C
        ON C.con_telefono = S.suc_telefono
       AND C.con_mail     = S.suc_mail;
GO


--------------------------------------------------------------------------------
-- 4.2) POBLO CLIENTE (depende de Provincia, Localidad, Contacto)
--------------------------------------------------------------------------------
;WITH CTE_Cliente AS (
    SELECT DISTINCT
        CAST(Cliente_Dni           AS BIGINT) AS cli_dni,
        Cliente_Provincia                    AS cli_provincia,
        Cliente_Localidad                    AS cli_localidad,
        Cliente_Direccion                    AS cli_direccion,
        Cliente_Telefono                     AS cli_telefono,
        Cliente_Mail                         AS cli_mail,
        Cliente_Nombre                       AS cli_nombre,
        Cliente_Apellido                     AS cli_apellido,
        Cliente_FechaNacimiento              AS cli_fecha_nac
    FROM gd_esquema.Maestra
    WHERE Cliente_Dni IS NOT NULL
)
INSERT INTO CNEJ.Cliente
    (cli_dni, cli_provincia, cli_localidad, cli_contacto,
     cli_nombre, cli_apellido, cli_fecha_nac, cli_direccion)
SELECT
    Cc.cli_dni,
    P.pro_numero,
    L.loc_numero,
    C.con_numero,
    Cc.cli_nombre,
    Cc.cli_apellido,
    Cc.cli_fecha_nac,
    Cc.cli_direccion
FROM CTE_Cliente AS Cc
    LEFT JOIN CNEJ.Provincia AS P
        ON P.pro_nombre = Cc.cli_provincia
    LEFT JOIN CNEJ.Localidad AS L
        ON L.loc_nombre = Cc.cli_localidad
    LEFT JOIN CNEJ.Contacto AS C
        ON C.con_telefono = Cc.cli_telefono
       AND C.con_mail     = Cc.cli_mail;
GO


--------------------------------------------------------------------------------
-- 4.3) POBLO SILLON (evito duplicados por Sillon_Codigo)
--------------------------------------------------------------------------------
;WITH CTE_SillonDistinct AS (
    SELECT
        CAST(Sillon_Codigo AS BIGINT)         AS sil_numero,
        Material_Tipo,
        Material_Nombre,
        Material_Descripcion,
        Material_Precio,
        Sillon_Modelo_Codigo                  AS sil_modelo,
        Sillon_Medida_Alto,
        Sillon_Medida_Ancho,
        Sillon_Medida_Profundidad,
        Sillon_Medida_Precio
    FROM (
        SELECT 
            Sillon_Codigo,
            Material_Tipo,
            Material_Nombre,
            Material_Descripcion,
            Material_Precio,
            Sillon_Modelo_Codigo,
            Sillon_Medida_Alto,
            Sillon_Medida_Ancho,
            Sillon_Medida_Profundidad,
            Sillon_Medida_Precio,
            ROW_NUMBER() OVER (
                PARTITION BY Sillon_Codigo
                ORDER BY Sillon_Codigo
            ) AS rn
        FROM gd_esquema.Maestra
        WHERE Sillon_Codigo IS NOT NULL
    ) AS sub
    WHERE rn = 1
)
INSERT INTO CNEJ.Sillon (sil_numero, sil_material, sil_modelo, sil_medida)
SELECT
    D.sil_numero,
    M1.mat_numero,
    CAST(D.sil_modelo AS BIGINT),
    M2.med_numero
FROM CTE_SillonDistinct AS D
    INNER JOIN CNEJ.Material AS M1
        ON M1.mat_tipo        = D.Material_Tipo
       AND M1.mat_nombre      = D.Material_Nombre
       AND M1.mat_descripcion = D.Material_Descripcion
       AND M1.mat_precio      = D.Material_Precio
    INNER JOIN CNEJ.Medida AS M2
        ON M2.med_alto        = D.Sillon_Medida_Alto
       AND M2.med_ancho       = D.Sillon_Medida_Ancho
       AND M2.med_profundidad = D.Sillon_Medida_Profundidad
       AND M2.med_precio      = D.Sillon_Medida_Precio;
GO


--------------------------------------------------------------------------------
-- 5.1) POBLO PEDIDO
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Pedido
    (ped_numero, ped_sucursal, ped_cliente, ped_fecha, ped_estado, ped_total)
SELECT DISTINCT
    CAST(Pedido_Numero AS DECIMAL(18,0))    AS ped_numero,
    CAST(Sucursal_NroSucursal AS BIGINT)     AS ped_sucursal,
    CAST(Cliente_Dni AS BIGINT)              AS ped_cliente,
    Pedido_Fecha                            AS ped_fecha,
    Pedido_Estado                           AS ped_estado,
    CAST(Pedido_Total AS DECIMAL(18,2))     AS ped_total
FROM gd_esquema.Maestra
WHERE Pedido_Numero IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 5.2) POBLO DETALLE_PEDIDO (sólo filas con datos de Sillón)
--------------------------------------------------------------------------------
;WITH CTE_DetallePedidoGen AS (
    SELECT DISTINCT
        CAST(Pedido_Numero           AS DECIMAL(18,0))  AS ped_numero,
        CAST(Sillon_Codigo           AS BIGINT)         AS sil_numero,
        CAST(Detalle_Pedido_Cantidad AS BIGINT)         AS det_pedi_cant,
        CAST(Detalle_Pedido_Precio   AS DECIMAL(18,2))  AS det_pedi_precio,
        CAST(Detalle_Pedido_SubTotal AS DECIMAL(18,2))  AS det_pedi_subt,

        ROW_NUMBER() OVER (
            ORDER BY 
                CAST(Pedido_Numero AS DECIMAL(18,0)),
                CAST(Sillon_Codigo AS BIGINT),
                CAST(Detalle_Pedido_Cantidad AS BIGINT),
                CAST(Detalle_Pedido_Precio AS DECIMAL(18,2)),
                CAST(Detalle_Pedido_SubTotal AS DECIMAL(18,2))
        ) AS det_ped_numero
    FROM gd_esquema.Maestra
    WHERE Detalle_Pedido_Cantidad IS NOT NULL
      AND Sillon_Codigo IS NOT NULL
)
INSERT INTO CNEJ.Detalle_Pedido
    (det_ped_numero, sil_numero, ped_numero, det_ped_cantidad, det_ped_precio, det_ped_subtotal)
SELECT
    D.det_ped_numero,
    D.sil_numero,
    D.ped_numero,
    D.det_pedi_cant,
    D.det_pedi_precio,
    D.det_pedi_subt
FROM CTE_DetallePedidoGen AS D;
GO

--------------------------------------------------------------------------------
-- 5.3) POBLO FACTURA
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Factura
    (fac_numero, fac_sucursal, fac_cliente, fac_fecha, fac_total)
SELECT DISTINCT
    CAST(Factura_Numero AS BIGINT)           AS fac_numero,
    CAST(Sucursal_NroSucursal AS BIGINT)     AS fac_sucursal,
    CAST(Cliente_Dni AS BIGINT)              AS fac_cliente,
    Factura_Fecha                            AS fac_fecha,
    CAST(Factura_Total AS DECIMAL(18,2))     AS fac_total
FROM gd_esquema.Maestra
WHERE Factura_Numero IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 5.4) POBLO DETALLE_FACTURA (vinculando cada factura con la PRIMERA línea de pedido)
--------------------------------------------------------------------------------

-- Primero, obtenemos para cada Pedido_Numero el "primer" det_ped_numero:
;WITH CTE_FirstDetallePedido AS (
    SELECT 
        ped_numero,
        MIN(det_ped_numero) AS first_det_ped_numero
    FROM CNEJ.Detalle_Pedido
    GROUP BY ped_numero
)
INSERT INTO CNEJ.Detalle_Factura
    (det_fac_numero, det_fac_det_pedido, det_fac_precio, det_fac_cantidad, det_fac_subtotal, det_fac_fac_num)
SELECT
    -- Genera un PK único para Detalle_Factura
    ROW_NUMBER() OVER (
        ORDER BY 
            CAST(M.Factura_Numero AS BIGINT),
            CAST(M.Pedido_Numero  AS DECIMAL(18,0))
    ) AS det_fac_numero,

    -- Tomamos el det_ped_numero “primero” de ese pedido:
    F.first_det_ped_numero AS det_fac_det_pedido,

    CAST(M.Detalle_Factura_Precio    AS DECIMAL(18,2))  AS det_fac_precio,
    CAST(M.Detalle_Factura_Cantidad  AS DECIMAL(18,0))  AS det_fac_cantidad,
    CAST(M.Detalle_Factura_SubTotal  AS DECIMAL(18,2))  AS det_fac_subtotal,

    CAST(M.Factura_Numero AS BIGINT) AS det_fac_fac_num
FROM gd_esquema.Maestra AS M
    INNER JOIN CTE_FirstDetallePedido AS F
        ON F.ped_numero = CAST(M.Pedido_Numero AS DECIMAL(18,0))
WHERE M.Detalle_Factura_Precio IS NOT NULL;
GO

--------------------------------------------------------------------------------
-- 5.5) POBLO CANCELACION
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Cancelacion
    (ped_canc_numero, can_pedido, can_fecha, can_motivo)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY Pedido_Numero, Pedido_Cancelacion_Fecha
    ) AS ped_canc_numero,
    CAST(Pedido_Numero             AS DECIMAL(18,0)) AS can_pedido,
    Pedido_Cancelacion_Fecha                         AS can_fecha,
    Pedido_Cancelacion_Motivo                        AS can_motivo
FROM gd_esquema.Maestra
WHERE Pedido_Cancelacion_Fecha IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 5.6) POBLO ENVIO
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Envio
    (env_numero, env_factura, env_fecha_programada, env_fecha_real,
     env_importe_traslado, env_importe_subida, env_total)
SELECT DISTINCT
    CAST(Envio_Numero AS DECIMAL(18,0))                 AS env_numero,
    CAST(Factura_Numero       AS BIGINT)                 AS env_factura,
    Envio_Fecha_Programada    AS env_fecha_programada,
    Envio_Fecha               AS env_fecha_real,
    CAST(Envio_ImporteTraslado AS DECIMAL(18,2))         AS env_importe_traslado,
    CAST(Envio_ImporteSubida   AS DECIMAL(18,2))         AS env_importe_subida,
    CAST(Envio_Total           AS DECIMAL(18,2))         AS env_total
FROM gd_esquema.Maestra
WHERE Envio_Numero IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 5.7) POBLO PROVEEDOR
--------------------------------------------------------------------------------
;WITH CTE_Proveedor AS (
    SELECT DISTINCT
        Proveedor_Cuit         AS pro_cuit,
        Proveedor_Provincia    AS pro_provincia,
        Proveedor_Localidad    AS pro_localidad,
        Proveedor_RazonSocial  AS pro_razon_social,
        Proveedor_Direccion    AS pro_direccion,
        Proveedor_Telefono     AS prov_telefono,
        Proveedor_Mail         AS prov_mail
    FROM gd_esquema.Maestra
    WHERE Proveedor_Cuit IS NOT NULL
)
INSERT INTO CNEJ.Proveedor
    (pro_cuit, pro_contacto, pro_provincia, pro_localidad, pro_razon_social, pro_direccion)
SELECT
    Pv.pro_cuit,
    C.con_numero,
    Pr.pro_numero,
    L.loc_numero,
    Pv.pro_razon_social,
    Pv.pro_direccion
FROM CTE_Proveedor AS Pv
    LEFT JOIN CNEJ.Provincia AS Pr
        ON Pr.pro_nombre = Pv.pro_provincia
    LEFT JOIN CNEJ.Localidad AS L
        ON L.loc_nombre = Pv.pro_localidad
    LEFT JOIN CNEJ.Contacto AS C
        ON C.con_telefono = Pv.prov_telefono
       AND C.con_mail     = Pv.prov_mail;
GO


--------------------------------------------------------------------------------
-- 5.8) POBLO COMPRA
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Compra
    (com_numero, com_proveedor, com_fecha, com_sucursal, com_total)
SELECT DISTINCT
    CAST(Compra_Numero AS DECIMAL(18,0))   AS com_numero,
    Proveedor_Cuit                         AS com_proveedor,
    Compra_Fecha                           AS com_fecha,
    CAST(Sucursal_NroSucursal AS BIGINT)    AS com_sucursal,
    CAST(Compra_Total AS DECIMAL(18,2))    AS com_total
FROM gd_esquema.Maestra
WHERE Compra_Numero IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 5.9) POBLO DETALLE_COMPRA con ROW_NUMBER para PK única
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Detalle_Compra
    (det_com_numero, mat_numero, com_numero, det_com_precio, det_com_cantidad, det_com_subtotal)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY Compra_Numero, Material_Tipo, Material_Nombre
    ) AS det_com_numero,
    M.mat_numero                                AS mat_numero,
    CAST(Compra_Numero                AS DECIMAL(18,0))  AS com_numero,
    CAST(Detalle_Compra_Precio        AS DECIMAL(18,2))  AS det_com_precio,
    CAST(Detalle_Compra_Cantidad      AS DECIMAL(18,0))  AS det_com_cantidad,
    CAST(Detalle_Compra_SubTotal      AS DECIMAL(18,2))  AS det_com_subtotal
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE Detalle_Compra_Precio IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 6) POBLO LOS SUBTIPOS DE MATERIAL: MADERA, TELA Y RELLENO
--------------------------------------------------------------------------------

-- 6.1) Madera
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Madera (mad_numero, mad_material, mad_color, mad_dureza)
SELECT DISTINCT
    M.mat_numero               AS mad_numero,
    M.mat_numero               AS mad_material,
    G.Madera_Color             AS mad_color,
    G.Madera_Dureza            AS mad_dureza
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE G.Madera_Color IS NOT NULL;
GO

-- 6.2) Tela
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Tela (tel_numero, tel_material, tel_color, tel_textura)
SELECT DISTINCT
    M.mat_numero               AS tel_numero,
    M.mat_numero               AS tel_material,
    G.Tela_Color               AS tel_color,
    G.Tela_Textura             AS tel_textura
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE G.Tela_Color IS NOT NULL;
GO

-- 6.3) Relleno
--------------------------------------------------------------------------------
INSERT INTO CNEJ.Relleno (rel_numero, rel_material, rel_densidad)
SELECT DISTINCT
    M.mat_numero                                   AS rel_numero,
    M.mat_numero                                   AS rel_material,
    CAST(G.Relleno_Densidad AS DECIMAL(38,2))      AS rel_densidad
FROM gd_esquema.Maestra AS G
    INNER JOIN CNEJ.Material AS M
        ON M.mat_tipo   = G.Material_Tipo
       AND M.mat_nombre = G.Material_Nombre
WHERE G.Relleno_Densidad IS NOT NULL;
GO


--------------------------------------------------------------------------------
-- 7) VUELVO A HABILITAR TODAS LAS FK PARA VALIDAR INTEGRIDAD
--------------------------------------------------------------------------------
EXEC sp_MSforeachtable 
    @command1 = '
        IF ''?'' LIKE ''%CNEJ.%''  
            ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL
    ';
GO
