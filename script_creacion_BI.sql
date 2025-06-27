/*  DROP TABLAS EXISTENTES (para recrear desde cero)  */
IF OBJECT_ID('CNEJ.BI_Hecho_PedFac','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_PedFac;
IF OBJECT_ID('CNEJ.BI_Hecho_VentaModelo','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_VentaModelo;
IF OBJECT_ID('CNEJ.BI_Hecho_Envio','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Envio;
IF OBJECT_ID('CNEJ.BI_Hecho_Facturacion','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Facturacion;
IF OBJECT_ID('CNEJ.BI_Hecho_Compra','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Compra;
IF OBJECT_ID('CNEJ.BI_Hecho_Pedido','U') IS NOT NULL DROP TABLE CNEJ.BI_Hecho_Pedido;

IF OBJECT_ID('CNEJ.BI_Stg_PedFac','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_PedFac;
IF OBJECT_ID('CNEJ.BI_Stg_VentaModelo','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_VentaModelo;
IF OBJECT_ID('CNEJ.BI_Stg_Facturacion','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_Facturacion;
IF OBJECT_ID('CNEJ.BI_Stg_Pedido','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_Pedido;

IF OBJECT_ID('CNEJ.BI_Dim_RangoEtario','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_RangoEtario;
IF OBJECT_ID('CNEJ.BI_Dim_Turno','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Turno;
IF OBJECT_ID('CNEJ.BI_Dim_EstadoPedido','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_EstadoPedido;
IF OBJECT_ID('CNEJ.BI_Dim_Modelo','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Modelo;
IF OBJECT_ID('CNEJ.BI_Dim_Material','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Material;
IF OBJECT_ID('CNEJ.BI_Dim_Sucursal','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Sucursal;
IF OBJECT_ID('CNEJ.BI_Dim_Cliente','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Cliente;
IF OBJECT_ID('CNEJ.BI_Dim_Ubicacion','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Ubicacion;
IF OBJECT_ID('CNEJ.BI_Dim_Tiempo','U') IS NOT NULL DROP TABLE CNEJ.BI_Dim_Tiempo;
GO

USE GD1C2025;
GO

/************************************ CREACION DE DIMENSIONES ************************************/

IF OBJECT_ID('BI_Dim_Tiempo','U') IS NOT NULL DROP TABLE BI_Dim_Tiempo;
CREATE TABLE CNEJ.BI_Dim_Tiempo (
	TiempoKey INT IDENTITY(1,1) PRIMARY KEY, 
	Anio INT NOT NULL,
	Cuatrimestre INT NOT NULL,
	Mes INT NOT NULL
);

IF OBJECT_ID('BI_Dim_Ubicacion','U') IS NOT NULL DROP TABLE BI_Dim_Ubicacion;
CREATE TABLE CNEJ.BI_Dim_Ubicacion (
    UbicacionKey INT IDENTITY(1,1) PRIMARY KEY,
    Provincia NVARCHAR(255) NOT NULL,
    Localidad NVARCHAR(255) NOT NULL
);

IF OBJECT_ID('BI_Dim_Cliente','U') IS NOT NULL DROP TABLE BI_Dim_Cliente;
CREATE TABLE CNEJ.BI_Dim_Cliente (
    ClienteKey INT IDENTITY(1,1) PRIMARY KEY,
    ClienteDni BIGINT NOT NULL,
    FechaNacimiento DATE NULL
);

IF OBJECT_ID('BI_Dim_Sucursal','U') IS NOT NULL DROP TABLE BI_Dim_Sucursal;
CREATE TABLE CNEJ.BI_Dim_Sucursal (
    SucursalKey INT IDENTITY(1,1) PRIMARY KEY,
    SucursalNumero BIGINT NOT NULL,
    Direccion NVARCHAR(255) NULL
);

IF OBJECT_ID('BI_Dim_Material','U') IS NOT NULL DROP TABLE BI_Dim_Material;
CREATE TABLE CNEJ.BI_Dim_Material (
    MaterialKey INT IDENTITY(1,1) PRIMARY KEY,
    MaterialNumero BIGINT NOT NULL,
    Tipo NVARCHAR(255) NOT NULL,
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(255) NULL,
    Precio DECIMAL(18,2) NULL
);

IF OBJECT_ID('BI_Dim_Modelo','U') IS NOT NULL DROP TABLE BI_Dim_Modelo;
CREATE TABLE CNEJ.BI_Dim_Modelo (
    ModeloKey INT IDENTITY(1,1) PRIMARY KEY,
    ModeloNumero BIGINT NOT NULL,
    Tipo NVARCHAR(255) NULL,
    Descripcion NVARCHAR(255) NULL,
    Precio DECIMAL(18,2) NULL
);

IF OBJECT_ID('BI_Dim_EstadoPedido','U') IS NOT NULL DROP TABLE BI_Dim_EstadoPedido;
CREATE TABLE CNEJ.BI_Dim_EstadoPedido (
    EstadoKey INT IDENTITY(1,1) PRIMARY KEY,
    Estado NVARCHAR(255) NOT NULL
);

IF OBJECT_ID('BI_Dim_Turno','U') IS NOT NULL DROP TABLE BI_Dim_Turno;
CREATE TABLE CNEJ.BI_Dim_Turno (
    TurnoKey INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL,
    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL
);

IF OBJECT_ID('BI_Dim_RangoEtario','U') IS NOT NULL DROP TABLE BI_Dim_RangoEtario;
CREATE TABLE CNEJ.BI_Dim_RangoEtario (
    RangoKey INT IDENTITY(1,1) PRIMARY KEY,
    Rango NVARCHAR(20) NOT NULL
);

/************************************ CREACION DE TABLAS DE STAGING ************************************/

IF OBJECT_ID('CNEJ.BI_Stg_Pedido','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_Pedido;
CREATE TABLE CNEJ.BI_Stg_Pedido (
  PedidoNumero  DECIMAL(18,0) PRIMARY KEY,
  PedFecha      DATETIME2(6) NOT NULL,
  PedTotal      DECIMAL(18,2) NOT NULL,
  PedSucursal   BIGINT NOT NULL,
  PedCliente    BIGINT NOT NULL,
  PedEstado     NVARCHAR(255) NOT NULL,
  Provincia     NVARCHAR(255) NOT NULL,
  Localidad     NVARCHAR(255) NOT NULL
);

IF OBJECT_ID('CNEJ.BI_Stg_Facturacion','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_Facturacion;
CREATE TABLE CNEJ.BI_Stg_Facturacion (
    DetFactID       BIGINT       PRIMARY KEY,
    FactFecha       DATETIME2(6) NOT NULL,
    DetFactSubtotal DECIMAL(18,2)NOT NULL,
    FactSucursal    BIGINT       NOT NULL,
    FactCliente     BIGINT       NOT NULL,
    PedNumero       DECIMAL(18,0)NOT NULL,
    PedEstado       NVARCHAR(255)NOT NULL,
    Provincia       NVARCHAR(255)NOT NULL,
    Localidad       NVARCHAR(255)NOT NULL
);

IF OBJECT_ID('CNEJ.BI_Stg_VentaModelo','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_VentaModelo;
CREATE TABLE CNEJ.BI_Stg_VentaModelo (
  DetPedNumero      BIGINT        PRIMARY KEY,
  PedFecha          DATETIME2(6)  NOT NULL,
  Cantidad          INT           NOT NULL,
  ModeloNumero      BIGINT        NOT NULL,
  SucursalNumero    BIGINT        NOT NULL,
  Provincia         NVARCHAR(255) NOT NULL,
  Localidad         NVARCHAR(255) NOT NULL,
  ClienteDni        BIGINT        NOT NULL
);

IF OBJECT_ID('CNEJ.BI_Stg_PedFac','U') IS NOT NULL DROP TABLE CNEJ.BI_Stg_PedFac;
CREATE TABLE CNEJ.BI_Stg_PedFac (
  DetPedNumero   BIGINT       PRIMARY KEY,
  PedFecha       DATETIME2(6) NOT NULL,
  FacFecha       DATETIME2(6) NOT NULL,
  SucursalNumero BIGINT       NOT NULL,
  Dias           INT          NOT NULL
);
GO

/************************************ POBLACION DE DIMENSIONES ************************************/

DECLARE @minDate DATE, @maxDate DATE;
SELECT @minDate = MIN(CONVERT(date,ped_fecha)) FROM CNEJ.Pedido;
SELECT @maxDate = MAX(CONVERT(date,fac_fecha)) FROM CNEJ.Factura;
IF @minDate IS NULL SET @minDate = (SELECT MIN(CONVERT(date,com_fecha)) FROM CNEJ.Compra);
IF @maxDate IS NULL SET @maxDate = (SELECT MAX(CONVERT(date,env_fecha_real)) FROM CNEJ.Envio);
;WITH Calendario AS (
    SELECT @minDate AS Fecha UNION ALL
    SELECT DATEADD(DAY,1,Fecha) FROM Calendario WHERE Fecha<@maxDate
), DistinctMeses AS (
    SELECT DISTINCT YEAR(Fecha) AS Anio,
           ((MONTH(Fecha)-1)/4)+1 AS Cuatrimestre,
           MONTH(Fecha) AS Mes
    FROM Calendario
)
INSERT INTO CNEJ.BI_Dim_Tiempo(Anio,Cuatrimestre,Mes)
SELECT Anio,Cuatrimestre,Mes FROM DistinctMeses OPTION(MAXRECURSION 0);

INSERT INTO CNEJ.BI_Dim_Ubicacion(Provincia,Localidad)
SELECT DISTINCT p.pro_nombre,l.loc_nombre
FROM CNEJ.Provincia p CROSS JOIN CNEJ.Localidad l
WHERE EXISTS(SELECT 1 FROM CNEJ.Sucursal s WHERE s.suc_provincia=p.pro_numero AND s.suc_localidad=l.loc_numero)
   OR EXISTS(SELECT 1 FROM CNEJ.Cliente c WHERE c.cli_provincia=p.pro_numero AND c.cli_localidad=l.loc_numero);

INSERT INTO CNEJ.BI_Dim_Cliente(ClienteDni,FechaNacimiento)
SELECT DISTINCT cli_dni,CONVERT(date,cli_fecha_nac) FROM CNEJ.Cliente;

INSERT INTO CNEJ.BI_Dim_Sucursal(SucursalNumero,Direccion)
SELECT DISTINCT suc_numero,suc_direccion FROM CNEJ.Sucursal;

INSERT INTO CNEJ.BI_Dim_Material(MaterialNumero,Tipo,Nombre,Descripcion,Precio)
SELECT DISTINCT mat_numero,mat_tipo,mat_nombre,mat_descripcion,mat_precio FROM CNEJ.Material;

INSERT INTO CNEJ.BI_Dim_Modelo(ModeloNumero,Tipo,Descripcion,Precio)
SELECT DISTINCT mod_numero,mod_tipo,mod_descripcion,mod_precio FROM CNEJ.Modelo;

INSERT INTO CNEJ.BI_Dim_EstadoPedido(Estado)
SELECT DISTINCT ped_estado FROM CNEJ.Pedido;

INSERT INTO CNEJ.BI_Dim_Turno(Nombre,HoraInicio,HoraFin)
VALUES('08:00-14:00','08:00','14:00'),('14:00-20:00','14:00','20:00');

INSERT INTO CNEJ.BI_Dim_RangoEtario(Rango)
VALUES('<25'),('25-35'),('35-50'),('>50');

/************************************ POBLACION TABLAS DE STAGING ************************************/

INSERT INTO CNEJ.BI_Stg_Pedido
  (PedidoNumero,PedFecha,PedTotal,PedSucursal,PedCliente,PedEstado,Provincia,Localidad)
SELECT
  p.ped_numero,
  p.ped_fecha,
  p.ped_total,
  p.ped_sucursal,
  p.ped_cliente,
  p.ped_estado,
  pr.pro_nombre,
  lo.loc_nombre
FROM CNEJ.Pedido AS p
JOIN CNEJ.Sucursal  AS s  ON s.suc_numero    = p.ped_sucursal
JOIN CNEJ.Provincia AS pr ON pr.pro_numero   = s.suc_provincia
JOIN CNEJ.Localidad  AS lo ON lo.loc_numero   = s.suc_localidad;

INSERT INTO CNEJ.BI_Stg_Facturacion
    (DetFactID,FactFecha,DetFactSubtotal,FactSucursal,FactCliente,PedNumero,PedEstado,Provincia,Localidad)
SELECT
  df.det_fac_numero                     AS DetFactID,
  f.fac_fecha                           AS FactFecha,
  df.det_fac_subtotal                   AS DetFactSubtotal,
  f.fac_sucursal                        AS FactSucursal,
  f.fac_cliente                         AS FactCliente,
  dp.ped_numero                         AS PedNumero,
  p.ped_estado                          AS PedEstado,
  pr.pro_nombre                         AS Provincia,
  lo.loc_nombre                         AS Localidad
FROM CNEJ.Detalle_Factura AS df
  JOIN CNEJ.Factura       AS f  ON f.fac_numero     = df.det_fac_fac_num
  JOIN CNEJ.Detalle_Pedido AS dp ON dp.det_ped_numero = df.det_fac_det_pedido
  JOIN CNEJ.Pedido         AS p  ON p.ped_numero     = dp.ped_numero
  JOIN CNEJ.Sucursal       AS s  ON s.suc_numero     = f.fac_sucursal
  JOIN CNEJ.Provincia      AS pr ON pr.pro_numero    = s.suc_provincia
  JOIN CNEJ.Localidad      AS lo ON lo.loc_numero    = s.suc_localidad;

INSERT INTO CNEJ.BI_Stg_VentaModelo
  (DetPedNumero,PedFecha,Cantidad,ModeloNumero,SucursalNumero,Provincia,Localidad,ClienteDni)
SELECT
  dp.det_ped_numero                         AS DetPedNumero,
  p.ped_fecha                               AS PedFecha,
  dp.det_ped_cantidad                       AS Cantidad,
  sl.sil_modelo                             AS ModeloNumero,
  p.ped_sucursal                            AS SucursalNumero,
  pr.pro_nombre                             AS Provincia,
  lo.loc_nombre                             AS Localidad,
  p.ped_cliente                             AS ClienteDni
FROM CNEJ.Detalle_Pedido AS dp
JOIN CNEJ.Pedido         AS p  ON p.ped_numero   = dp.ped_numero
JOIN CNEJ.Sillon         AS sl ON sl.sil_numero  = dp.sil_numero
JOIN CNEJ.Sucursal       AS suc ON suc.suc_numero = p.ped_sucursal
JOIN CNEJ.Provincia      AS pr ON pr.pro_numero  = suc.suc_provincia
JOIN CNEJ.Localidad      AS lo ON lo.loc_numero  = suc.suc_localidad;

INSERT INTO CNEJ.BI_Stg_PedFac
  (DetPedNumero,PedFecha,FacFecha,SucursalNumero,Dias)
SELECT DISTINCT
  dp.det_ped_numero                        AS DetPedNumero,
  p.ped_fecha                              AS PedFecha,
  f.fac_fecha                              AS FacFecha,
  p.ped_sucursal                           AS SucursalNumero,
  DATEDIFF(DAY, p.ped_fecha, f.fac_fecha)  AS Dias
FROM CNEJ.Detalle_Pedido AS dp
JOIN CNEJ.Detalle_Factura AS df
  ON df.det_fac_det_pedido = dp.det_ped_numero
JOIN CNEJ.Pedido AS p
  ON p.ped_numero = dp.ped_numero
JOIN CNEJ.Factura AS f
  ON f.fac_numero = df.det_fac_fac_num;
GO

/************************************ CREACION DE TABLAS DE HECHOS ************************************/

IF OBJECT_ID('BI_Hecho_Pedido','U') IS NOT NULL DROP TABLE BI_Hecho_Pedido;
CREATE TABLE CNEJ.BI_Hecho_Pedido(
    TiempoKey   INT NOT NULL,
    SucursalKey INT NOT NULL,
    ClienteKey  INT NOT NULL,
    EstadoKey   INT NOT NULL,
    TurnoKey    INT NOT NULL,
    RangoKey    INT NOT NULL,
    UbicacionKey INT NOT NULL,    -- ubicación de la sucursal
    Total       DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Pedido PRIMARY KEY (TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey),
    FOREIGN KEY(UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey),
    FOREIGN KEY(TiempoKey)   REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey) REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(ClienteKey)  REFERENCES CNEJ.BI_Dim_Cliente(ClienteKey),
    FOREIGN KEY(EstadoKey)   REFERENCES CNEJ.BI_Dim_EstadoPedido(EstadoKey),
    FOREIGN KEY(TurnoKey)    REFERENCES CNEJ.BI_Dim_Turno(TurnoKey),
    FOREIGN KEY(RangoKey)    REFERENCES CNEJ.BI_Dim_RangoEtario(RangoKey)
);

IF OBJECT_ID('BI_Hecho_Compra','U') IS NOT NULL DROP TABLE BI_Hecho_Compra;
CREATE TABLE CNEJ.BI_Hecho_Compra(
    TiempoKey   INT NOT NULL,
    SucursalKey INT NOT NULL,
    MaterialKey INT NOT NULL,
    TotalCompra DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Compra PRIMARY KEY (TiempoKey,SucursalKey,MaterialKey),
    FOREIGN KEY(TiempoKey)    REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey)  REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(MaterialKey)  REFERENCES CNEJ.BI_Dim_Material(MaterialKey)
);

IF OBJECT_ID('BI_Hecho_Facturacion','U') IS NOT NULL DROP TABLE BI_Hecho_Facturacion;
CREATE TABLE CNEJ.BI_Hecho_Facturacion(
    TiempoKey   INT NOT NULL,
    SucursalKey INT NOT NULL,
    ClienteKey  INT NOT NULL,
    EstadoKey   INT NOT NULL,
    TurnoKey    INT NOT NULL,
    RangoKey    INT NOT NULL,
    UbicacionKey INT NOT NULL,    -- ubicación de la sucursal
    Monto       DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Facturacion PRIMARY KEY (TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey),
    FOREIGN KEY(UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey),
    FOREIGN KEY(TiempoKey)   REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey) REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(ClienteKey)  REFERENCES CNEJ.BI_Dim_Cliente(ClienteKey),
    FOREIGN KEY(EstadoKey)   REFERENCES CNEJ.BI_Dim_EstadoPedido(EstadoKey),
    FOREIGN KEY(TurnoKey)    REFERENCES CNEJ.BI_Dim_Turno(TurnoKey),
    FOREIGN KEY(RangoKey)    REFERENCES CNEJ.BI_Dim_RangoEtario(RangoKey)
);

IF OBJECT_ID('BI_Hecho_Envio','U') IS NOT NULL DROP TABLE BI_Hecho_Envio;
CREATE TABLE CNEJ.BI_Hecho_Envio(
    TiempoKey    INT NOT NULL,
    SucursalKey  INT NOT NULL,
    ClienteKey   INT NOT NULL,
    UbicacionKey INT NOT NULL,    -- ubicación del cliente
    CostoTotal   DECIMAL(18,2) NOT NULL,
    Cumplido     BIT NOT NULL,
    CONSTRAINT PK_Hecho_Envio PRIMARY KEY (TiempoKey,SucursalKey,ClienteKey,UbicacionKey),
    FOREIGN KEY(UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey),
    FOREIGN KEY(TiempoKey)   REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey) REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(ClienteKey)  REFERENCES CNEJ.BI_Dim_Cliente(ClienteKey)
);

IF OBJECT_ID('CNEJ.BI_Hecho_VentaModelo','U') IS NOT NULL
  DROP TABLE CNEJ.BI_Hecho_VentaModelo;
GO
CREATE TABLE CNEJ.BI_Hecho_VentaModelo (
  DetPedNumero   BIGINT NOT NULL PRIMARY KEY,
  TiempoKey      INT    NOT NULL,
  UbicacionKey   INT    NOT NULL,
  RangoKey       INT    NOT NULL,
  ModeloKey      INT    NOT NULL,
  CantidadVendida INT   NOT NULL,
  FOREIGN KEY(TiempoKey)    REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
  FOREIGN KEY(UbicacionKey) REFERENCES CNEJ.BI_Dim_Ubicacion(UbicacionKey),
  FOREIGN KEY(RangoKey)     REFERENCES CNEJ.BI_Dim_RangoEtario(RangoKey),
  FOREIGN KEY(ModeloKey)    REFERENCES CNEJ.BI_Dim_Modelo(ModeloKey)
);
GO

IF OBJECT_ID('CNEJ.BI_Hecho_PedFac','U') IS NOT NULL
  DROP TABLE CNEJ.BI_Hecho_PedFac;
GO
CREATE TABLE CNEJ.BI_Hecho_PedFac (
  DetPedNumero BIGINT NOT NULL PRIMARY KEY,
  TiempoKey    INT    NOT NULL,
  SucursalKey  INT    NOT NULL,
  Dias         INT    NOT NULL,
  FOREIGN KEY(TiempoKey)   REFERENCES CNEJ.BI_Dim_Tiempo(TiempoKey),
  FOREIGN KEY(SucursalKey) REFERENCES CNEJ.BI_Dim_Sucursal(SucursalKey)
);
GO

/************************************ POBLACION DE TABLAS DE HECHOS ************************************/

INSERT INTO CNEJ.BI_Hecho_Pedido
  (TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey,Total)
SELECT
  dt.TiempoKey,
  ds.SucursalKey,
  dc.ClienteKey,
  de.EstadoKey,
  dtur.TurnoKey,
  dr.RangoKey,
  dub.UbicacionKey,
  st.PedTotal
FROM CNEJ.BI_Stg_Pedido AS st
  JOIN CNEJ.BI_Dim_Tiempo       AS dt
    ON dt.Anio         = YEAR(st.PedFecha)
   AND dt.Mes          = MONTH(st.PedFecha)
   AND dt.Cuatrimestre = ((MONTH(st.PedFecha)-1)/4)+1
  JOIN CNEJ.BI_Dim_Sucursal     AS ds
    ON ds.SucursalNumero = st.PedSucursal
  JOIN CNEJ.BI_Dim_Cliente      AS dc
    ON dc.ClienteDni = st.PedCliente
  JOIN CNEJ.BI_Dim_EstadoPedido AS de
    ON de.Estado = st.PedEstado
  JOIN CNEJ.BI_Dim_Turno        AS dtur
    ON CONVERT(time, st.PedFecha) >= dtur.HoraInicio
   AND CONVERT(time, st.PedFecha) <  dtur.HoraFin
  JOIN CNEJ.BI_Dim_RangoEtario  AS dr
    ON dr.Rango = CASE
         WHEN DATEDIFF(YEAR, dc.FechaNacimiento, st.PedFecha) <  25 THEN '<25'
         WHEN DATEDIFF(YEAR, dc.FechaNacimiento, st.PedFecha) BETWEEN 25 AND 35 THEN '25-35'
         WHEN DATEDIFF(YEAR, dc.FechaNacimiento, st.PedFecha) BETWEEN 36 AND 50 THEN '35-50'
         ELSE '>50'
       END
  JOIN CNEJ.BI_Dim_Ubicacion    AS dub
    ON dub.Provincia = st.Provincia
   AND dub.Localidad = st.Localidad;

INSERT INTO CNEJ.BI_Hecho_Compra(TiempoKey,SucursalKey,MaterialKey,TotalCompra)
SELECT
	dt.TiempoKey,
	s.SucursalKey,
	m.MaterialKey,
	SUM(dc.det_com_subtotal) AS TotalCompra
FROM CNEJ.Compra c
JOIN CNEJ.Detalle_Compra dc ON dc.com_numero = c.com_numero
JOIN CNEJ.BI_Dim_Tiempo dt ON dt.Anio = YEAR(c.com_fecha)
	AND dt.Mes = MONTH(c.com_fecha)
	AND dt.Cuatrimestre = ((MONTH(c.com_fecha)-1)/4)+1
JOIN CNEJ.BI_Dim_Sucursal s ON s.SucursalNumero = c.com_sucursal
JOIN CNEJ.BI_Dim_Material m ON m.MaterialNumero = dc.mat_numero
GROUP BY dt.TiempoKey, s.SucursalKey, m.MaterialKey;

INSERT INTO CNEJ.BI_Hecho_Facturacion
  (TiempoKey, SucursalKey, ClienteKey, EstadoKey, TurnoKey, RangoKey, UbicacionKey, Monto)
SELECT
  dt.TiempoKey,
  ds.SucursalKey,
  dc.ClienteKey,
  de.EstadoKey,
  dtur.TurnoKey,
  dr.RangoKey,
  dub.UbicacionKey,
  SUM(st.DetFactSubtotal) AS Monto
FROM CNEJ.BI_Stg_Facturacion AS st
  JOIN CNEJ.BI_Dim_Tiempo        AS dt
    ON dt.Anio         = YEAR(st.FactFecha)
   AND dt.Mes          = MONTH(st.FactFecha)
   AND dt.Cuatrimestre = ((MONTH(st.FactFecha)-1)/4)+1
  JOIN CNEJ.BI_Dim_Sucursal     AS ds
    ON ds.SucursalNumero = st.FactSucursal
  JOIN CNEJ.BI_Dim_Cliente      AS dc
    ON dc.ClienteDni   = st.FactCliente
  JOIN CNEJ.BI_Dim_EstadoPedido AS de
    ON de.Estado       = st.PedEstado
  JOIN CNEJ.BI_Dim_Turno        AS dtur
    ON CONVERT(time, st.FactFecha) >= dtur.HoraInicio
   AND CONVERT(time, st.FactFecha) <  dtur.HoraFin
  JOIN CNEJ.BI_Dim_RangoEtario  AS dr
    ON dr.Rango       = CASE
         WHEN DATEDIFF(YEAR, dc.FechaNacimiento, st.FactFecha) < 25 THEN '<25'
         WHEN DATEDIFF(YEAR, dc.FechaNacimiento, st.FactFecha) BETWEEN 25 AND 35 THEN '25-35'
         WHEN DATEDIFF(YEAR, dc.FechaNacimiento, st.FactFecha) BETWEEN 36 AND 50 THEN '35-50'
         ELSE '>50'
       END
  JOIN CNEJ.BI_Dim_Ubicacion    AS dub
    ON dub.Provincia   = st.Provincia
   AND dub.Localidad   = st.Localidad

GROUP BY
  dt.TiempoKey,
  ds.SucursalKey,
  dc.ClienteKey,
  de.EstadoKey,
  dtur.TurnoKey,
  dr.RangoKey,
  dub.UbicacionKey;
GO

INSERT INTO CNEJ.BI_Hecho_Envio(TiempoKey,SucursalKey,ClienteKey,UbicacionKey,CostoTotal,Cumplido)
SELECT
  dt.TiempoKey,
  s.SucursalKey,
  c.ClienteKey,
  u_c.UbicacionKey,
  e.env_importe_traslado + e.env_importe_subida,
  CASE WHEN e.env_fecha_real <= e.env_fecha_programada THEN 1 ELSE 0 END
FROM CNEJ.Envio e
JOIN CNEJ.Factura f ON f.fac_numero = e.env_factura
JOIN CNEJ.BI_Dim_Tiempo dt ON dt.Anio=YEAR(e.env_fecha_programada)
    AND dt.Mes=MONTH(e.env_fecha_programada)
    AND dt.Cuatrimestre=((MONTH(e.env_fecha_programada)-1)/4)+1
JOIN CNEJ.BI_Dim_Sucursal s ON s.SucursalNumero=f.fac_sucursal
JOIN CNEJ.Cliente cli ON cli.cli_dni = f.fac_cliente
JOIN CNEJ.BI_Dim_Cliente c ON c.ClienteDni=cli.cli_dni
JOIN CNEJ.BI_Dim_Ubicacion u_c ON u_c.Provincia = (SELECT pro_nombre FROM CNEJ.Provincia WHERE pro_numero=cli.cli_provincia)
    AND u_c.Localidad = (SELECT loc_nombre FROM CNEJ.Localidad WHERE loc_numero=cli.cli_localidad);

INSERT INTO CNEJ.BI_Hecho_VentaModelo
  (DetPedNumero,TiempoKey,UbicacionKey,RangoKey,ModeloKey,CantidadVendida)
SELECT
  st.DetPedNumero,
  dt.TiempoKey,
  ub.UbicacionKey,
  dr.RangoKey,
  m.ModeloKey,
  st.Cantidad
FROM CNEJ.BI_Stg_VentaModelo AS st
JOIN CNEJ.BI_Dim_Tiempo       AS dt
  ON dt.Anio         = YEAR(st.PedFecha)
 AND dt.Mes          = MONTH(st.PedFecha)
 AND dt.Cuatrimestre = ((MONTH(st.PedFecha)-1)/4)+1
JOIN CNEJ.BI_Dim_Modelo       AS m
  ON m.ModeloNumero = st.ModeloNumero
JOIN CNEJ.BI_Dim_RangoEtario  AS dr
  ON dr.Rango = CASE
       WHEN DATEDIFF(YEAR, (SELECT FechaNacimiento FROM CNEJ.BI_Dim_Cliente WHERE ClienteDni=st.ClienteDni), st.PedFecha) < 25 THEN '<25'
       WHEN DATEDIFF(YEAR, (SELECT FechaNacimiento FROM CNEJ.BI_Dim_Cliente WHERE ClienteDni=st.ClienteDni), st.PedFecha) BETWEEN 25 AND 35 THEN '25-35'
       WHEN DATEDIFF(YEAR, (SELECT FechaNacimiento FROM CNEJ.BI_Dim_Cliente WHERE ClienteDni=st.ClienteDni), st.PedFecha) BETWEEN 36 AND 50 THEN '35-50'
       ELSE '>50'
     END
JOIN CNEJ.BI_Dim_Ubicacion    AS ub
  ON ub.Provincia = st.Provincia
 AND ub.Localidad = st.Localidad;
GO

INSERT INTO CNEJ.BI_Hecho_PedFac
  (DetPedNumero,TiempoKey,SucursalKey,Dias)
SELECT
  st.DetPedNumero,
  dt.TiempoKey,
  ds.SucursalKey,
  st.Dias
FROM CNEJ.BI_Stg_PedFac     AS st
JOIN CNEJ.BI_Dim_Tiempo     AS dt
  ON dt.Anio         = YEAR(st.PedFecha)
 AND dt.Mes          = MONTH(st.PedFecha)
 AND dt.Cuatrimestre = ((MONTH(st.PedFecha)-1)/4)+1
JOIN CNEJ.BI_Dim_Sucursal   AS ds
  ON ds.SucursalNumero = st.SucursalNumero;
GO

/************************************ VISTAS ************************************/

CREATE OR ALTER VIEW CNEJ.BI_Vista_Ganancias AS
SELECT
dt.Anio,
dt.Mes,
f.SucursalKey,
SUM(f.Monto) AS TotalIngresos,
SUM(ISNULL(c.TotalCompra, 0)) AS TotalEgresos,
SUM(f.Monto) - SUM(ISNULL(c.TotalCompra, 0)) AS Ganancia
FROM CNEJ.BI_Hecho_Facturacion AS f
JOIN CNEJ.BI_Dim_Tiempo AS dt ON f.TiempoKey = dt.TiempoKey
LEFT JOIN CNEJ.BI_Hecho_Compra AS c
ON c.TiempoKey = f.TiempoKey
AND c.SucursalKey = f.SucursalKey
GROUP BY dt.Anio, dt.Mes, f.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_FacturaPromedioMensual AS
SELECT
dt.Anio,
dt.Cuatrimestre,
f.SucursalKey,
SUM(f.Monto) / 4.0 AS PromedioMensualPorCuatrimestre
FROM CNEJ.BI_Hecho_Facturacion AS f
JOIN CNEJ.BI_Dim_Tiempo AS dt ON f.TiempoKey = dt.TiempoKey
GROUP BY dt.Anio, dt.Cuatrimestre, f.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_RendimientoModelos AS
WITH RankedVentas AS (
  SELECT
    vm.TiempoKey,
    vm.UbicacionKey,
    vm.RangoKey,
    vm.ModeloKey,
    vm.CantidadVendida,
    ROW_NUMBER() OVER (
      PARTITION BY vm.TiempoKey, vm.UbicacionKey, vm.RangoKey
      ORDER BY vm.CantidadVendida DESC
    ) AS rn
  FROM CNEJ.BI_Hecho_VentaModelo AS vm
)
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  rv.UbicacionKey,
  rv.RangoKey,
  rv.ModeloKey,
  rv.CantidadVendida
FROM RankedVentas AS rv
JOIN CNEJ.BI_Dim_Tiempo    AS dt ON rv.TiempoKey    = dt.TiempoKey
WHERE rv.rn <= 3;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_VolumenPedidos AS
SELECT
dt.Anio,
dt.Mes,
p.SucursalKey,
p.TurnoKey,
COUNT(*) AS CantidadPedidos
FROM CNEJ.BI_Hecho_Pedido AS p
JOIN CNEJ.BI_Dim_Tiempo AS dt ON p.TiempoKey = dt.TiempoKey
GROUP BY dt.Anio, dt.Mes, p.SucursalKey, p.TurnoKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_ConversionPedidos AS
SELECT
dt.Anio,
dt.Cuatrimestre,
p.SucursalKey,
p.EstadoKey,
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY dt.Anio, dt.Cuatrimestre, p.SucursalKey)
AS PorcentajePorEstado
FROM CNEJ.BI_Hecho_Pedido AS p
JOIN CNEJ.BI_Dim_Tiempo AS dt ON p.TiempoKey = dt.TiempoKey
GROUP BY dt.Anio, dt.Cuatrimestre, p.SucursalKey, p.EstadoKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_TiempoFabricacion AS
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  pf.SucursalKey,
  AVG(pf.Dias) AS DiasPromedio
FROM CNEJ.BI_Hecho_PedFac AS pf
JOIN CNEJ.BI_Dim_Tiempo    AS dt  
  ON pf.TiempoKey = dt.TiempoKey
GROUP BY
  dt.Anio,
  dt.Cuatrimestre,
  pf.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_PromedioCompras AS
SELECT
  dt.Anio,
  dt.Mes,
  hc.SucursalKey,
  AVG(hc.TotalCompra) AS PromedioCompra
FROM CNEJ.BI_Hecho_Compra hc
JOIN CNEJ.BI_Dim_Tiempo dt ON hc.TiempoKey = dt.TiempoKey
GROUP BY dt.Anio, dt.Mes, hc.SucursalKey;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_ComprasTipoMaterial AS
SELECT
  dt.Anio,
  dt.Cuatrimestre,
  hc.SucursalKey,
  m.Tipo AS TipoMaterial,
  SUM(hc.TotalCompra) AS TotalGastado
FROM CNEJ.BI_Hecho_Compra hc
JOIN CNEJ.BI_Dim_Tiempo dt ON hc.TiempoKey = dt.TiempoKey
JOIN CNEJ.BI_Dim_Material m ON hc.MaterialKey = m.MaterialKey
GROUP BY dt.Anio, dt.Cuatrimestre, hc.SucursalKey, m.Tipo;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_CumplimientoEnvios AS
SELECT
  dt.Anio,
  dt.Mes,
  COUNT(CASE WHEN e.Cumplido = 1 THEN 1 END) * 100.0 / COUNT(*) AS PorcentajeCumplidos
FROM CNEJ.BI_Hecho_Envio e
JOIN CNEJ.BI_Dim_Tiempo dt ON e.TiempoKey = dt.TiempoKey
GROUP BY dt.Anio, dt.Mes;
GO

CREATE OR ALTER VIEW CNEJ.BI_Vista_LocalidadesCostoEnvio AS
WITH Costos AS (
  SELECT
    u.Provincia,
    u.Localidad,
    SUM(e.CostoTotal) AS TotalEnvio,
    ROW_NUMBER() OVER (ORDER BY SUM(e.CostoTotal) DESC) AS rn
  FROM CNEJ.BI_Hecho_Envio e
  JOIN CNEJ.BI_Dim_Ubicacion u ON e.UbicacionKey = u.UbicacionKey
  GROUP BY u.Provincia, u.Localidad
)
SELECT Provincia, Localidad, TotalEnvio
FROM Costos
WHERE rn <= 3;
GO

SELECT * FROM CNEJ.BI_Vista_Ganancias;
SELECT * FROM CNEJ.BI_Vista_FacturaPromedioMensual;
SELECT * FROM CNEJ.BI_Vista_RendimientoModelos;
SELECT * FROM CNEJ.BI_Vista_VolumenPedidos;
SELECT * FROM CNEJ.BI_Vista_ConversionPedidos;
SELECT * FROM CNEJ.BI_Vista_TiempoFabricacion;
SELECT * FROM CNEJ.BI_Vista_PromedioCompras;
SELECT * FROM CNEJ.BI_Vista_ComprasTipoMaterial;
SELECT * FROM CNEJ.BI_Vista_CumplimientoEnvios;
SELECT * FROM CNEJ.BI_Vista_LocalidadesCostoEnvio;