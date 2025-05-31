-- Desactiva restricciones para poder borrar en orden
EXEC sp_MSforeachtable 
    'ALTER TABLE ? NOCHECK CONSTRAINT ALL'

Elimina todas las tablas del esquema CNEJ
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += 'DROP TABLE CNEJ.[' + t.name + '];' + CHAR(13)
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'CNEJ';

EXEC sp_executesql @sql;

-- EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

USE [GD1C2025]
GO

-- CREATE SCHEMA [CNEJ]
-- GO

------------------ TABLAS MAESTRAS (SIN DEPENDENCIAS) --------------------------

CREATE TABLE CNEJ.Provincia (
    pro_nombre NVARCHAR(255),
    pro_numero BIGINT,
    PRIMARY KEY(pro_numero)
);

CREATE TABLE CNEJ.Localidad (
    loc_nombre NVARCHAR(255),
    loc_numero BIGINT,
    PRIMARY KEY(loc_numero)
);

CREATE TABLE CNEJ.Material (
    mat_numero BIGINT,
    mat_tipo NVARCHAR(255),
    mat_nombre NVARCHAR(255),
    mat_descripcion NVARCHAR(255),
    mat_precio DECIMAL(18, 2),
    PRIMARY KEY(mat_numero)
);

CREATE TABLE CNEJ.Modelo (
    mod_numero BIGINT,
    mod_tipo NVARCHAR(255),
    mod_descripcion NVARCHAR(255),
    mod_precio DECIMAL(18, 2),
    PRIMARY KEY(mod_numero)
);

CREATE TABLE CNEJ.Medida (
    med_numero BIGINT,
    med_alto decimal(18, 2),
    med_ancho decimal(18, 2),
    med_profundidad decimal(18, 2),
    med_precio decimal(18, 2),
    PRIMARY KEY (med_numero)     
);

CREATE TABLE CNEJ.Contacto (
    con_numero BIGINT,
    con_mail NVARCHAR(255),
    con_telefono NVARCHAR(255),
    PRIMARY KEY(con_numero)
);

---------------- TABLAS QUE SOLO REFERENCIAN MAESTRAS -------------------

CREATE TABLE CNEJ.Sillon (
    sil_numero BIGINT,
    sil_material BIGINT,
    sil_modelo BIGINT,
    sil_medida BIGINT,
    PRIMARY KEY (sil_numero),
    FOREIGN KEY (sil_material) REFERENCES CNEJ.Material(mat_numero),
    FOREIGN KEY (sil_modelo) REFERENCES CNEJ.Modelo(mod_numero),
    FOREIGN KEY (sil_medida) REFERENCES CNEJ.Medida(med_numero)
);

CREATE TABLE CNEJ.Cliente (
    cli_dni BIGINT,
    cli_provincia BIGINT,
    cli_localidad BIGINT,
    cli_contacto BIGINT,
    cli_nombre NVARCHAR(255),
    cli_apellido NVARCHAR(255),
    cli_fecha_nac DATETIME2(6),
    cli_direccion NVARCHAR(255),
    PRIMARY KEY(cli_dni),
    FOREIGN KEY(cli_provincia) REFERENCES CNEJ.Provincia(pro_numero),
    FOREIGN KEY(cli_localidad) REFERENCES CNEJ.Localidad(loc_numero),
    FOREIGN KEY(cli_contacto) REFERENCES CNEJ.Contacto(con_numero)
);

CREATE TABLE CNEJ.Sucursal (
    suc_numero BIGINT,
    suc_provincia BIGINT,
    suc_localidad BIGINT,
    suc_contacto BIGINT,
    suc_direccion NVARCHAR(255),
    PRIMARY KEY(suc_numero),
    FOREIGN KEY(suc_provincia) REFERENCES CNEJ.Provincia(pro_numero),
    FOREIGN KEY(suc_localidad) REFERENCES CNEJ.Localidad(loc_numero),
    FOREIGN KEY(suc_contacto) REFERENCES CNEJ.Contacto(con_numero)
);

--------------------------------------------------------------------------

CREATE TABLE CNEJ.Pedido (
    ped_numero DECIMAL(18, 0),
    ped_sucursal BIGINT,
    ped_cliente BIGINT,
    ped_fecha DATETIME2(6),
    ped_estado NVARCHAR(255),
    ped_total DECIMAL(18, 2),
    PRIMARY KEY(ped_numero),
    FOREIGN KEY(ped_sucursal) REFERENCES CNEJ.Sucursal(suc_numero),
    FOREIGN KEY(ped_cliente) REFERENCES CNEJ.Cliente(cli_dni)
);

CREATE TABLE CNEJ.Detalle_Pedido (
    det_ped_numero BIGINT,
    sil_numero BIGINT,
    ped_numero DECIMAL(18,0),
    det_ped_cantidad BIGINT,
    det_ped_precio DECIMAL(18,2),
    det_ped_subtotal DECIMAL(18,2),
    PRIMARY KEY(det_ped_numero),
    FOREIGN KEY (sil_numero) REFERENCES CNEJ.Sillon(sil_numero),
    FOREIGN KEY (ped_numero) REFERENCES CNEJ.Pedido(ped_numero)
);

CREATE TABLE CNEJ.Factura (
    fac_numero BIGINT,
    fac_sucursal BIGINT,
    fac_cliente BIGINT,
    fac_fecha DATETIME2(6),
    fac_total DECIMAL(18, 2),
    PRIMARY KEY (fac_numero),
    FOREIGN KEY (fac_sucursal) REFERENCES CNEJ.Sucursal(suc_numero),
    FOREIGN KEY (fac_cliente) REFERENCES CNEJ.Cliente(cli_dni)
);

CREATE TABLE CNEJ.Detalle_Factura (
    det_fac_numero BIGINT,
    det_fac_det_pedido BIGINT,
    det_fac_precio DECIMAL(18, 2),
    det_fac_cantidad DECIMAL(18, 0),
    det_fac_subtotal DECIMAL(18, 2),
    det_fac_fac_num BIGINT,
    PRIMARY KEY(det_fac_numero),
    FOREIGN KEY (det_fac_det_pedido) REFERENCES CNEJ.Detalle_Pedido(det_ped_numero),
    FOREIGN KEY (det_fac_fac_num) REFERENCES CNEJ.Factura(fac_numero)
);

CREATE TABLE CNEJ.Cancelacion (
    ped_canc_numero BIGINT,
    can_pedido DECIMAL(18, 0),
    can_fecha DATETIME2(6),
    can_motivo NVARCHAR(255),
    PRIMARY KEY(ped_canc_numero),
    FOREIGN KEY(can_pedido) REFERENCES CNEJ.Pedido(ped_numero)
);

CREATE TABLE CNEJ.Envio (
    env_numero DECIMAL(18, 0),
    env_factura BIGINT,
    env_fecha_programada DATETIME2(6),
    env_fecha_real DATETIME2(6),
    env_importe_traslado DECIMAL(18, 2),
    env_importe_subida DECIMAL(18, 2),
    env_total DECIMAL(18, 2),
    PRIMARY KEY(env_numero),
    FOREIGN KEY (env_factura) REFERENCES CNEJ.Factura(fac_numero)
);

CREATE TABLE CNEJ.Proveedor (
    pro_cuit NVARCHAR(255),
    pro_contacto BIGINT,
    pro_provincia BIGINT,
    pro_localidad BIGINT,
    pro_razon_social NVARCHAR(255),
    pro_direccion NVARCHAR(255),
    PRIMARY KEY(pro_cuit),
    FOREIGN KEY (pro_contacto) REFERENCES CNEJ.Contacto(con_numero),
    FOREIGN KEY (pro_provincia) REFERENCES CNEJ.Provincia(pro_numero),
    FOREIGN KEY (pro_localidad) REFERENCES CNEJ.Localidad(loc_numero)
);

CREATE TABLE CNEJ.Compra (
    com_numero DECIMAL(18, 0),
    com_proveedor NVARCHAR(255),
    com_fecha DATETIME2(6),
    com_sucursal BIGINT,
    com_total DECIMAL(18, 2),
    PRIMARY KEY(com_numero),
    FOREIGN KEY(com_proveedor) REFERENCES CNEJ.Proveedor(pro_cuit),
    FOREIGN KEY(com_sucursal) REFERENCES CNEJ.Sucursal(suc_numero)
);

CREATE TABLE CNEJ.Detalle_Compra (
    det_com_numero BIGINT,
    mat_numero BIGINT,
    com_numero DECIMAL(18, 0),
    det_com_precio DECIMAL(18, 2),
    det_com_cantidad DECIMAL(18, 0),
    det_com_subtotal DECIMAL(18, 2),
    PRIMARY KEY (det_com_numero),
    FOREIGN KEY (mat_numero) REFERENCES CNEJ.Material(mat_numero),
    FOREIGN KEY (com_numero) REFERENCES CNEJ.Compra(com_numero)
);

CREATE TABLE CNEJ.Madera (
    mad_numero BIGINT,
    mad_material BIGINT,
    mad_color NVARCHAR(255),
    mad_dureza NVARCHAR(255),
    PRIMARY KEY (mad_numero),
    FOREIGN KEY (mad_material) REFERENCES CNEJ.Material(mat_numero)
);

CREATE TABLE CNEJ.Tela (
    tel_numero BIGINT,
    tel_material BIGINT,
    tel_color NVARCHAR(255),
    tel_textura NVARCHAR(255),
    PRIMARY KEY (tel_numero),
    FOREIGN KEY (tel_material) REFERENCES CNEJ.Material(mat_numero)
);

CREATE TABLE CNEJ.Relleno (
    rel_numero BIGINT,
    rel_material BIGINT,
    rel_densidad DECIMAL(38, 2),
    PRIMARY KEY(rel_numero),
    FOREIGN KEY (rel_material) REFERENCES CNEJ.Material(mat_numero)
);