/* Creación de dimensiones (prefijo BI_) */

-- BI_Dim_Tiempo (año, cuatrimestre, mes)
IF OBJECT_ID('BI_Dim_Tiempo','U') IS NOT NULL DROP TABLE BI_Dim_Tiempo;
CREATE TABLE BI_Dim_Tiempo (
	TiempoKey INT IDENTITY(1,1) PRIMARY KEY, -- ahora es la PK
	Anio INT NOT NULL,
	Cuatrimestre INT NOT NULL,
	Mes INT NOT NULL
);

-- BI_Dim_Ubicacion (provincia, localidad)
IF OBJECT_ID('BI_Dim_Ubicacion','U') IS NOT NULL DROP TABLE BI_Dim_Ubicacion;
CREATE TABLE BI_Dim_Ubicacion (
    UbicacionKey INT IDENTITY(1,1) PRIMARY KEY,
    Provincia NVARCHAR(255) NOT NULL,
    Localidad NVARCHAR(255) NOT NULL
);

-- BI_Dim_Cliente (dni, fecha_nac)
IF OBJECT_ID('BI_Dim_Cliente','U') IS NOT NULL DROP TABLE BI_Dim_Cliente;
CREATE TABLE BI_Dim_Cliente (
    ClienteKey INT IDENTITY(1,1) PRIMARY KEY,
    ClienteDni BIGINT NOT NULL,
    FechaNacimiento DATE NULL
);

-- BI_Dim_Sucursal (numero, direccion)
IF OBJECT_ID('BI_Dim_Sucursal','U') IS NOT NULL DROP TABLE BI_Dim_Sucursal;
CREATE TABLE BI_Dim_Sucursal (
    SucursalKey INT IDENTITY(1,1) PRIMARY KEY,
    SucursalNumero BIGINT NOT NULL,
    Direccion NVARCHAR(255) NULL
);

-- BI_Dim_Material (numero, tipo, nombre, descripcion, precio)
IF OBJECT_ID('BI_Dim_Material','U') IS NOT NULL DROP TABLE BI_Dim_Material;
CREATE TABLE BI_Dim_Material (
    MaterialKey INT IDENTITY(1,1) PRIMARY KEY,
    MaterialNumero BIGINT NOT NULL,
    Tipo NVARCHAR(255) NOT NULL,
    Nombre NVARCHAR(255) NOT NULL,
    Descripcion NVARCHAR(255) NULL,
    Precio DECIMAL(18,2) NULL
);

-- BI_Dim_Modelo (numero, tipo, descripcion, precio)
IF OBJECT_ID('BI_Dim_Modelo','U') IS NOT NULL DROP TABLE BI_Dim_Modelo;
CREATE TABLE BI_Dim_Modelo (
    ModeloKey INT IDENTITY(1,1) PRIMARY KEY,
    ModeloNumero BIGINT NOT NULL,
    Tipo NVARCHAR(255) NULL,
    Descripcion NVARCHAR(255) NULL,
    Precio DECIMAL(18,2) NULL
);

-- BI_Dim_EstadoPedido (estado)
IF OBJECT_ID('BI_Dim_EstadoPedido','U') IS NOT NULL DROP TABLE BI_Dim_EstadoPedido;
CREATE TABLE BI_Dim_EstadoPedido (
    EstadoKey INT IDENTITY(1,1) PRIMARY KEY,
    Estado NVARCHAR(255) NOT NULL
);

-- BI_Dim_Turno (nombre, hora_inicio, hora_fin)
IF OBJECT_ID('BI_Dim_Turno','U') IS NOT NULL DROP TABLE BI_Dim_Turno;
CREATE TABLE BI_Dim_Turno (
    TurnoKey INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL,
    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL
);

-- BI_Dim_RangoEtario (rango)
IF OBJECT_ID('BI_Dim_RangoEtario','U') IS NOT NULL DROP TABLE BI_Dim_RangoEtario;
CREATE TABLE BI_Dim_RangoEtario (
    RangoKey INT IDENTITY(1,1) PRIMARY KEY,
    Rango NVARCHAR(20) NOT NULL
);

/* Población de dimensiones */

-- BI_Dim_Tiempo: distinct año/cuatrimestre/mes
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
INSERT INTO BI_Dim_Tiempo(Anio,Cuatrimestre,Mes)
SELECT Anio,Cuatrimestre,Mes FROM DistinctMeses OPTION(MAXRECURSION 0);

-- BI_Dim_Ubicacion
INSERT INTO BI_Dim_Ubicacion(Provincia,Localidad)
SELECT DISTINCT p.pro_nombre,l.loc_nombre
FROM CNEJ.Provincia p CROSS JOIN CNEJ.Localidad l
WHERE EXISTS(SELECT 1 FROM CNEJ.Sucursal s WHERE s.suc_provincia=p.pro_numero AND s.suc_localidad=l.loc_numero)
   OR EXISTS(SELECT 1 FROM CNEJ.Cliente c WHERE c.cli_provincia=p.pro_numero AND c.cli_localidad=l.loc_numero);

-- BI_Dim_Cliente
INSERT INTO BI_Dim_Cliente(ClienteDni,FechaNacimiento)
SELECT DISTINCT cli_dni,CONVERT(date,cli_fecha_nac) FROM CNEJ.Cliente;

-- BI_Dim_Sucursal
INSERT INTO BI_Dim_Sucursal(SucursalNumero,Direccion)
SELECT DISTINCT suc_numero,suc_direccion FROM CNEJ.Sucursal;

-- BI_Dim_Material
INSERT INTO BI_Dim_Material(MaterialNumero,Tipo,Nombre,Descripcion,Precio)
SELECT DISTINCT mat_numero,mat_tipo,mat_nombre,mat_descripcion,mat_precio FROM CNEJ.Material;

-- BI_Dim_Modelo
INSERT INTO BI_Dim_Modelo(ModeloNumero,Tipo,Descripcion,Precio)
SELECT DISTINCT mod_numero,mod_tipo,mod_descripcion,mod_precio FROM CNEJ.Modelo;

-- BI_Dim_EstadoPedido
INSERT INTO BI_Dim_EstadoPedido(Estado)
SELECT DISTINCT ped_estado FROM CNEJ.Pedido;

-- BI_Dim_Turno
INSERT INTO BI_Dim_Turno(Nombre,HoraInicio,HoraFin)
VALUES('08:00-14:00','08:00','14:00'),('14:00-20:00','14:00','20:00');

-- BI_Dim_RangoEtario
INSERT INTO BI_Dim_RangoEtario(Rango)
VALUES('<25'),('25-35'),('35-50'),('>50');

/* Creación de tablas de hechos, ahora incluyendo UbicacionKey */

-- BI_Hecho_Pedido
IF OBJECT_ID('BI_Hecho_Pedido','U') IS NOT NULL DROP TABLE BI_Hecho_Pedido;
CREATE TABLE BI_Hecho_Pedido(
    TiempoKey   INT NOT NULL,
    SucursalKey INT NOT NULL,
    ClienteKey  INT NOT NULL,
    EstadoKey   INT NOT NULL,
    TurnoKey    INT NOT NULL,
    RangoKey    INT NOT NULL,
    UbicacionKey INT NOT NULL,    -- ubicación de la sucursal
    Total       DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Pedido PRIMARY KEY (TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey),
    FOREIGN KEY(UbicacionKey) REFERENCES BI_Dim_Ubicacion(UbicacionKey),
    FOREIGN KEY(TiempoKey)   REFERENCES BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey) REFERENCES BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(ClienteKey)  REFERENCES BI_Dim_Cliente(ClienteKey),
    FOREIGN KEY(EstadoKey)   REFERENCES BI_Dim_EstadoPedido(EstadoKey),
    FOREIGN KEY(TurnoKey)    REFERENCES BI_Dim_Turno(TurnoKey),
    FOREIGN KEY(RangoKey)    REFERENCES BI_Dim_RangoEtario(RangoKey)
);

-- BI_Hecho_Compra
IF OBJECT_ID('BI_Hecho_Compra','U') IS NOT NULL DROP TABLE BI_Hecho_Compra;
CREATE TABLE BI_Hecho_Compra(
    TiempoKey   INT NOT NULL,
    SucursalKey INT NOT NULL,
    MaterialKey INT NOT NULL,
    TotalCompra DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Compra PRIMARY KEY (TiempoKey,SucursalKey,MaterialKey),
    FOREIGN KEY(TiempoKey)    REFERENCES BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey)  REFERENCES BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(MaterialKey)  REFERENCES BI_Dim_Material(MaterialKey)
);

-- BI_Hecho_Facturacion
IF OBJECT_ID('BI_Hecho_Facturacion','U') IS NOT NULL DROP TABLE BI_Hecho_Facturacion;
CREATE TABLE BI_Hecho_Facturacion(
    TiempoKey   INT NOT NULL,
    SucursalKey INT NOT NULL,
    ClienteKey  INT NOT NULL,
    EstadoKey   INT NOT NULL,
    TurnoKey    INT NOT NULL,
    RangoKey    INT NOT NULL,
    UbicacionKey INT NOT NULL,    -- ubicación de la sucursal
    Monto       DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Hecho_Facturacion PRIMARY KEY (TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey),
    FOREIGN KEY(UbicacionKey) REFERENCES BI_Dim_Ubicacion(UbicacionKey),
    FOREIGN KEY(TiempoKey)   REFERENCES BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey) REFERENCES BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(ClienteKey)  REFERENCES BI_Dim_Cliente(ClienteKey),
    FOREIGN KEY(EstadoKey)   REFERENCES BI_Dim_EstadoPedido(EstadoKey),
    FOREIGN KEY(TurnoKey)    REFERENCES BI_Dim_Turno(TurnoKey),
    FOREIGN KEY(RangoKey)    REFERENCES BI_Dim_RangoEtario(RangoKey)
);

-- BI_Hecho_Envio
IF OBJECT_ID('BI_Hecho_Envio','U') IS NOT NULL DROP TABLE BI_Hecho_Envio;
CREATE TABLE BI_Hecho_Envio(
    TiempoKey    INT NOT NULL,
    SucursalKey  INT NOT NULL,
    ClienteKey   INT NOT NULL,
    UbicacionKey INT NOT NULL,    -- ubicación del cliente
    CostoTotal   DECIMAL(18,2) NOT NULL,
    Cumplido     BIT NOT NULL,
    CONSTRAINT PK_Hecho_Envio PRIMARY KEY (TiempoKey,SucursalKey,ClienteKey,UbicacionKey),
    FOREIGN KEY(UbicacionKey) REFERENCES BI_Dim_Ubicacion(UbicacionKey),
    FOREIGN KEY(TiempoKey)   REFERENCES BI_Dim_Tiempo(TiempoKey),
    FOREIGN KEY(SucursalKey) REFERENCES BI_Dim_Sucursal(SucursalKey),
    FOREIGN KEY(ClienteKey)  REFERENCES BI_Dim_Cliente(ClienteKey)
);

/* Población de hechos */

-- Hecho Pedido
INSERT INTO BI_Hecho_Pedido(TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey,Total)
SELECT
  dt.TiempoKey,
  s.SucursalKey,
  c.ClienteKey,
  ep.EstadoKey,
  t.TurnoKey,
  re.RangoKey,
  u_s.UbicacionKey,
  p.ped_total
FROM CNEJ.Pedido p
JOIN BI_Dim_Tiempo dt ON dt.Anio=YEAR(p.ped_fecha)
    AND dt.Mes=MONTH(p.ped_fecha)
    AND dt.Cuatrimestre=((MONTH(p.ped_fecha)-1)/4)+1
JOIN BI_Dim_Sucursal s ON s.SucursalNumero=p.ped_sucursal
JOIN BI_Dim_Cliente c ON c.ClienteDni=p.ped_cliente
JOIN BI_Dim_EstadoPedido ep ON ep.Estado = p.ped_estado
JOIN BI_Dim_Turno t ON CONVERT(time,p.ped_fecha) BETWEEN t.HoraInicio AND t.HoraFin
JOIN BI_Dim_RangoEtario re ON re.Rango = 
    CASE
      WHEN DATEDIFF(YEAR,c.FechaNacimiento,p.ped_fecha) < 25 THEN '<25'
      WHEN DATEDIFF(YEAR,c.FechaNacimiento,p.ped_fecha) BETWEEN 25 AND 35 THEN '25-35'
      WHEN DATEDIFF(YEAR,c.FechaNacimiento,p.ped_fecha) BETWEEN 36 AND 50 THEN '35-50'
      ELSE '>50'
    END
JOIN BI_Dim_Ubicacion u_s ON u_s.Provincia = (SELECT pro_nombre FROM CNEJ.Provincia WHERE pro_numero=s.SucursalNumero)
    AND u_s.Localidad = (SELECT loc_nombre FROM CNEJ.Localidad WHERE loc_numero=(SELECT suc_localidad FROM CNEJ.Sucursal WHERE suc_numero=s.SucursalNumero));

-- Hecho Compra
INSERT INTO BI_Hecho_Compra(TiempoKey,SucursalKey,MaterialKey,TotalCompra)
SELECT
	dt.TiempoKey,
	s.SucursalKey,
	m.MaterialKey,
	SUM(dc.det_com_subtotal) AS TotalCompra
FROM CNEJ.Compra c
JOIN CNEJ.Detalle_Compra dc ON dc.com_numero = c.com_numero
JOIN BI_Dim_Tiempo dt ON dt.Anio = YEAR(c.com_fecha)
	AND dt.Mes = MONTH(c.com_fecha)
	AND dt.Cuatrimestre = ((MONTH(c.com_fecha)-1)/4)+1
JOIN BI_Dim_Sucursal s ON s.SucursalNumero = c.com_sucursal
JOIN BI_Dim_Material m ON m.MaterialNumero = dc.mat_numero
GROUP BY dt.TiempoKey, s.SucursalKey, m.MaterialKey;

-- Hecho Facturacion
INSERT INTO BI_Hecho_Facturacion(TiempoKey,SucursalKey,ClienteKey,EstadoKey,TurnoKey,RangoKey,UbicacionKey,Monto)
SELECT
  dt.TiempoKey,
  s.SucursalKey,
  c.ClienteKey,
  ep.EstadoKey,
  t.TurnoKey,
  re.RangoKey,
  u_s.UbicacionKey,
  df.det_fac_subtotal
FROM CNEJ.Detalle_Factura df
JOIN CNEJ.Factura f ON f.fac_numero=df.det_fac_fac_num
JOIN CNEJ.Pedido p ON p.ped_numero=df.det_fac_det_pedido
JOIN BI_Dim_Tiempo dt ON dt.Anio=YEAR(f.fac_fecha)
    AND dt.Mes=MONTH(f.fac_fecha)
    AND dt.Cuatrimestre=((MONTH(f.fac_fecha)-1)/4)+1
JOIN BI_Dim_Sucursal s ON s.SucursalNumero=f.fac_sucursal
JOIN BI_Dim_Cliente c ON c.ClienteDni=f.fac_cliente
JOIN BI_Dim_EstadoPedido ep ON ep.Estado = p.ped_estado
JOIN BI_Dim_Turno t ON CONVERT(time,f.fac_fecha) BETWEEN t.HoraInicio AND t.HoraFin
JOIN BI_Dim_RangoEtario re ON re.Rango = 
    CASE
      WHEN DATEDIFF(YEAR,c.FechaNacimiento,f.fac_fecha) < 25 THEN '<25'
      WHEN DATEDIFF(YEAR,c.FechaNacimiento,f.fac_fecha) BETWEEN 25 AND 35 THEN '25-35'
      WHEN DATEDIFF(YEAR,c.FechaNacimiento,f.fac_fecha) BETWEEN 36 AND 50 THEN '35-50'
      ELSE '>50'
    END
JOIN BI_Dim_Ubicacion u_s ON u_s.Provincia = (SELECT pro_nombre FROM CNEJ.Provincia WHERE pro_numero=s.SucursalNumero)
    AND u_s.Localidad = (SELECT loc_nombre FROM CNEJ.Localidad WHERE loc_numero=(SELECT suc_localidad FROM CNEJ.Sucursal WHERE suc_numero=s.SucursalNumero));

-- Hecho Envío
INSERT INTO BI_Hecho_Envio(TiempoKey,SucursalKey,ClienteKey,UbicacionKey,CostoTotal,Cumplido)
SELECT
  dt.TiempoKey,
  s.SucursalKey,
  c.ClienteKey,
  u_c.UbicacionKey,
  e.env_importe_traslado + e.env_importe_subida,
  CASE WHEN e.env_fecha_real <= e.env_fecha_programada THEN 1 ELSE 0 END
FROM CNEJ.Envio e
JOIN CNEJ.Factura f ON f.fac_numero = e.env_factura
JOIN BI_Dim_Tiempo dt ON dt.Anio=YEAR(e.env_fecha_programada)
    AND dt.Mes=MONTH(e.env_fecha_programada)
    AND dt.Cuatrimestre=((MONTH(e.env_fecha_programada)-1)/4)+1
JOIN BI_Dim_Sucursal s ON s.SucursalNumero=f.fac_sucursal
JOIN CNEJ.Cliente cli ON cli.cli_dni = f.fac_cliente
JOIN BI_Dim_Cliente c ON c.ClienteDni=cli.cli_dni
JOIN BI_Dim_Ubicacion u_c ON u_c.Provincia = (SELECT pro_nombre FROM CNEJ.Provincia WHERE pro_numero=cli.cli_provincia)
    AND u_c.Localidad = (SELECT loc_nombre FROM CNEJ.Localidad WHERE loc_numero=cli.cli_localidad);
