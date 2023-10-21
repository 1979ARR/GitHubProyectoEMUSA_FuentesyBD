ALTER TABLE IMPOR.BOBINA
 DROP PRIMARY KEY CASCADE;

DROP TABLE IMPOR.BOBINA CASCADE CONSTRAINTS;

CREATE TABLE IMPOR.BOBINA
(
  BOBI_CODIGO             NUMBER(10)            NOT NULL,
  BOBI_SERIE              CHAR(3 BYTE)          NOT NULL,
  CODIGO_UBICACION        CHAR(8 BYTE),
  TARA_CODIGO             NUMBER(10),
  ALMACEN_SERIE           CHAR(3 BYTE)          NOT NULL,
  SUBALMNUM               CHAR(3 BYTE),
  MITEM_CODIGO            NUMBER(10)            NOT NULL,
  BOBI_DESCRIPCION        VARCHAR2(50 BYTE),
  UNIDAD_CODIGO           CHAR(3 BYTE)          NOT NULL,
  BOBI_PESO               NUMBER(15,3)          DEFAULT 0,
  BOBI_ESTADO             CHAR(1 BYTE)          DEFAULT '0',
  BOBI_FECHA_INGRESO      DATE,
  BOBI_FECHA_SALIDA       DATE,
  BOBINA_LONGITUD         NUMBER(15,3),
  BOBINA_PESO_BRUTO       NUMBER(15,3),
  PLANTA_SERIE            CHAR(3 BYTE),
  HORD_TRAB_SECUENCIAL    NUMBER(10),
  PLANTA_SERIE_PROD       CHAR(3 BYTE)          DEFAULT '001',
  PORDEN_INT_PANASA       NUMBER(10),
  BOBI_PESO_STOCK         NUMBER(15,3),
  BOBI_OBSERVACIONES      VARCHAR2(50 BYTE),
  BOBINA_INVENTARIADA     CHAR(1 BYTE)          DEFAULT '0',
  UBI_ALMACEN_SERIE       CHAR(3 BYTE),
  UBI_SUBALMNUM           CHAR(3 BYTE),
  UBIFISI_CODIGO          CHAR(8 BYTE),
  UBI_ALMACEN_SERIE_ANT   CHAR(3 BYTE),
  UBI_SUBALMNUM_ANT       CHAR(3 BYTE),
  UBIFISI_CODIGO_ANT      CHAR(8 BYTE),
  BOBI_FECHA_DEPURA       DATE,
  USU_DEPURA              VARCHAR2(20 BYTE),
  USU_ULT_MODIF           VARCHAR2(20 BYTE),
  BOBI_FEC_ULT_MODIF      DATE,
  BOBI_FECHA_ALTA_DEPURA  DATE,
  BOBI_FEC_LEIDA          DATE,
  NUMERO_INVENTARIO       NUMBER(8),
  BOBI_FEC_PROD           DATE,
  BOBI_PREC_COMP_DOL      NUMBER(20,6),
  BOBI_PREC_COMP_SOL      NUMBER(20,6),
  BOBI_SERIE_REF          CHAR(3 BYTE),
  BOBI_CODIGO_REF         NUMBER(10),
  BCA_CODIGO              NUMBER(10),
  BOBI_TERMINAL_SERIE     CHAR(15 BYTE),
  COSTO_UNITARIO_SOL      NUMBER(15,3),
  COSTO_UNITARIO_DOL      NUMBER(15,3),
  HPROG_CODIGO            NUMBER(10),
  PROCESO_CODIGO          NUMBER(10)
)
TABLESPACE TEALMA_TB_GR
PCTUSED    0
PCTFREE    20
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          34304K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_SERIE IS 'Serie de la lectora portatil, para procesos en batch';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_ESTADO IS '0: Activa
1: Descargada
2: Separada (pre-despachada)';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_FECHA_INGRESO IS 'Fecha de ingreso de la bobina.';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_FECHA_SALIDA IS 'Fecha de Salida de la Bobina.  Si la bobina sale en varias Oias (parcialmente), guarda la ultima fecha de salida.';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_OBSERVACIONES IS 'Observaciones Varias de la Bobina';

COMMENT ON COLUMN IMPOR.BOBINA.BOBINA_INVENTARIADA IS '1 -> Bobina fue inventariada con lectora de código de barras.
2 -> Bobina no fue inventariada con lectora de código de barras.  (Por defecto).
Útil para la Depuración de Bobinas.';

COMMENT ON COLUMN IMPOR.BOBINA.UBIFISI_CODIGO IS 'Ubicación física de la bobina.  Cuando se realiza el inventario de bobinas, la ubicación leída en las lectoras se almacenará en este campo.  El valor que hubiese se copiará hacia la ubicación ANTERIOR.';

COMMENT ON COLUMN IMPOR.BOBINA.UBIFISI_CODIGO_ANT IS 'Ubicación de la bobina, antes del último inventario con lectora.  Cuando se haga el inventario con lectora, se copiará la ubicación leída en ubifisi_codigo y el valor que hubiese tenido ubifisi_codigo se copiará hacia este campo ANTERIOR.';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_FECHA_DEPURA IS 'Fecha de Depuración de la Bobina (D)';

COMMENT ON COLUMN IMPOR.BOBINA.USU_ULT_MODIF IS 'Usuario de última modificación de la bobina.  Pej. cuando se le modifica la ubicación o cuando se regresa la bobina de Depurada hacia Stock.';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_FEC_ULT_MODIF IS 'Fecha de Ultima Modificacion...';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_FECHA_ALTA_DEPURA IS 'Fecha en que se levantó la Depuración de la Bobina y pasó a estado de Stock AMP (8)';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_FEC_LEIDA IS 'Fecha de lectura de la bobina (lectora de código de barras)';

COMMENT ON COLUMN IMPOR.BOBINA.NUMERO_INVENTARIO IS 'N° de Inventario que depuró una bobina.';

COMMENT ON COLUMN IMPOR.BOBINA.BOBI_FEC_PROD IS 'Fecha en que la bobina se produjo en APP.  Pej. si una bobina impresa se imprimió en junio 2005 y se transfiere a otro almacen en julio 2005 y luego va a merma, entonces la fecha de producción de la bobina que irá a merma es de junio 2005';


CREATE INDEX IMPOR.IDX_BOBINA_ITEM_UND ON IMPOR.BOBINA
(MITEM_CODIGO, UNIDAD_CODIGO, BOBI_ESTADO)
LOGGING
TABLESPACE TEPRODUCCION
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          10632K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.IDX_BOBINA_SERIE_CODIGO ON IMPOR.BOBINA
(BOBI_SERIE, BOBI_CODIGO)
LOGGING
TABLESPACE TEPRODU_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          11024K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XAK1BOBINA_FEC_PROD ON IMPOR.BOBINA
(BOBI_FEC_PROD)
LOGGING
TABLESPACE TEPRODU_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          304K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIE10BOB_ITEM_ESTADO ON IMPOR.BOBINA
(MITEM_CODIGO, BOBI_ESTADO)
LOGGING
TABLESPACE TEPRODU_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          4M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIE11BOBINA ON IMPOR.BOBINA
(BOBI_FECHA_INGRESO)
LOGGING
TABLESPACE TEPRODU_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          304K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIE13BOBI_REF ON IMPOR.BOBINA
(BOBI_SERIE_REF, BOBI_CODIGO_REF)
LOGGING
TABLESPACE TEPRODU_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          400K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIE7BOBI_ESTADO ON IMPOR.BOBINA
(BOBI_ESTADO)
LOGGING
TABLESPACE TEALMACEN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIE7BOB_SERIE_ESTADO ON IMPOR.BOBINA
(BOBI_SERIE, BOBI_ESTADO)
LOGGING
TABLESPACE TEPRODU_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          10M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIE8BOBINA_INVENT ON IMPOR.BOBINA
(BOBINA_INVENTARIADA)
LOGGING
TABLESPACE TEALMA_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          5M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIE9BOBINA_FEC_LEIDA ON IMPOR.BOBINA
(BOBI_FEC_LEIDA)
LOGGING
TABLESPACE TEPRODUCCION
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          304K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1005BOBINA ON IMPOR.BOBINA
(ALMACEN_SERIE, PORDEN_INT_PANASA)
LOGGING
TABLESPACE TEPRODU_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1154BOBINA ON IMPOR.BOBINA
(UBI_ALMACEN_SERIE, UBI_SUBALMNUM, UBIFISI_CODIGO)
LOGGING
TABLESPACE TEALMA_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          5M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1156BOBINA ON IMPOR.BOBINA
(UBI_ALMACEN_SERIE_ANT, UBI_SUBALMNUM_ANT, UBIFISI_CODIGO_ANT)
LOGGING
TABLESPACE TEALMACEN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          512K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1314BOBINA ON IMPOR.BOBINA
(ALMACEN_SERIE, NUMERO_INVENTARIO)
LOGGING
TABLESPACE TEPRODUCCION
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          304K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1574BOBINA ON IMPOR.BOBINA
(BCA_CODIGO)
LOGGING
TABLESPACE TEALMA_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          200K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF399BOBINA ON IMPOR.BOBINA
(MITEM_CODIGO, UNIDAD_CODIGO, CODIGO_UBICACION, ALMACEN_SERIE, SUBALMNUM)
LOGGING
TABLESPACE TEALMA_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          27944K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF528BOBINA ON IMPOR.BOBINA
(TARA_CODIGO)
LOGGING
TABLESPACE TEALMACEN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          9400K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF765BOBINA ON IMPOR.BOBINA
(PLANTA_SERIE, HORD_TRAB_SECUENCIAL)
LOGGING
TABLESPACE TEALMACEN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          13504K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER IMPOR.TI_BOBINA
BEFORE INSERT ON bobina
FOR EACH ROW
DECLARE
nreg number;
v_nro_inventario number;
v_fecprod date;

BEGIN
 IF :NEW.bobi_peso < 0 THEN
	raise_application_error(-20999,'Error, La bobina ' || :NEW.bobi_serie || '-' || to_char(:NEW.bobi_codigo) || ' tiene Peso Negativo! (' ||
	to_char(:NEW.bobi_peso) || ')');
 END IF;

 -- Insertar el Item-Unidad en item_ubicacion, si es necesario
 SELECT	count(*) INTO nreg FROM item_ubicacion
 WHERE	item_ubicacion.almacen_serie = :NEW.almacen_serie and item_ubicacion.mitem_codigo = :NEW.mitem_codigo and
	item_ubicacion.unidad_codigo = :NEW.unidad_codigo and item_ubicacion.subalmnum = :NEW.subalmnum and
	item_ubicacion.codigo_ubicacion = :NEW.codigo_ubicacion;
 IF nreg = 0 THEN
   INSERT INTO item_ubicacion(item_ubicacion.almacen_serie, item_ubicacion.mitem_codigo, item_ubicacion.unidad_codigo,
	item_ubicacion.subalmnum, item_ubicacion.codigo_ubicacion)
   VALUES (:NEW.almacen_serie, :NEW.mitem_codigo, :NEW.unidad_codigo,
	:NEW.subalmnum, :NEW.codigo_ubicacion);
 END IF;

 v_nro_inventario := 0;
 -- Vemos si estamos en Inventario (Bobinas, Ambito Total, Abierto)
 SELECT 	nvl(max(numero_inventario), 0) INTO v_nro_inventario FROM toma_inventario
 WHERE 	almacen_serie = :NEW.almacen_serie and fecha_fin IS NULL and
	tipo_invent = '1' and ambito_invent = '0' and estado_inventario = '0';

 -- Stock de bobina: AMP (PreEtiq, Stock) / APP (PP, PT)
 IF :NEW.bobi_estado in ('7',  '8', '5', '0') THEN
    IF :NEW.bobi_estado = '8' THEN
       -- Si el estado es de Stock AMP
       :NEW.bobi_peso_stock := :NEW.bobi_peso;
    END IF;
     IF v_nro_inventario > 0 THEN
	:NEW.bobina_inventariada := '1';
     END IF;
 ELSIF :NEW.bobi_estado = '9' THEN
    -- Si el estado es de Salida AMP
    :NEW.bobi_peso_stock := 0;
 END IF;
-- Actualiza la fecha de leída, si se da el caso
 IF :NEW.bobina_inventariada = '1' and :NEW.bobi_fec_leida IS NULL THEN
    :NEW.bobi_fec_leida := SYSDATE;
 END IF;

/* En Desarrollo ...
 --**************************************************************************
 -- Se actualiza el stock en la tabla ITEM_UBI_EST_BOB ----------------------
 -- Se obtiene la Unidad de la O/T
 -- Insertar el Item-Unidad en item_ubicacion, si es necesario
 SELECT	count(*)
 INTO	nreg
 FROM	item_ubi_est_bob iueb
WHERE	iueb.almacen_serie = :NEW.almacen_serie and
	iueb.mitem_codigo = :NEW.mitem_codigo and
	iueb.unidad_codigo = :NEW.unidad_codigo and
	iueb.subalmnum = :NEW.subalmnum and
	iueb.codigo_ubicacion = :NEW.codigo_ubicacion and
	iueb.IUEB_EST_BOB = :NEW.bobi_estado;
 IF nreg = 0 THEN
   INSERT INTO item_ubi_est_bob(almacen_serie, mitem_codigo, unidad_codigo,
	subalmnum, codigo_ubicacion, IUEB_EST_BOB, IUEB_ULT_FEC_MODIF, IUEB_STOCK)
   VALUES (:NEW.almacen_serie, :NEW.mitem_codigo, :NEW.unidad_codigo,
	:NEW.subalmnum, :NEW.codigo_ubicacion, :NEW.bobi_estado, sysdate, :NEW.BOBI_PESO);
 END IF;
*/

END;
/


CREATE OR REPLACE TRIGGER IMPOR.TUB_BOBINA_UBIC
BEFORE UPDATE OF UBI_ALMACEN_SERIE, UBI_SUBALMNUM, UBIFISI_CODIGO ON IMPOR.BOBINA FOR EACH ROW
BEGIN
 :NEW.ubi_almacen_serie_ant := :OLD.ubi_almacen_serie;
 :NEW.ubi_subalmnum_ant := :OLD.ubi_subalmnum;
 :NEW.ubifisi_codigo_ant := :OLD.ubifisi_codigo;
END;
/


CREATE OR REPLACE TRIGGER IMPOR.TU_A_BOBINA_ESTADO
AFTER UPDATE OF BOBI_ESTADO ON IMPOR.BOBINA FOR EACH ROW
DECLARE
v_reg number;
v_proceso number;
v_hcc number;
v_cadena varchar2(50);
BEGIN
 IF :NEW.bobi_estado = 'X' THEN
   -- Verificar si la bobina está referenciada en Muestras de CC
   SELECT count(*) INTO v_reg FROM hmuestra_cc
   WHERE	almacen_serie = :NEW.almacen_serie and bobi_serie = :NEW.bobi_serie and
	bobi_codigo = :NEW.bobi_codigo and hcc_estado || '' <> 'X';
   IF v_reg > 0 THEN
     IF v_reg = 1 THEN
	SELECT 	proceso_codigo, hcc_secuencial INTO v_proceso, v_hcc FROM hmuestra_cc
	WHERE	almacen_serie = :NEW.almacen_serie and bobi_serie = :NEW.bobi_serie and
		bobi_codigo = :NEW.bobi_codigo and hcc_estado || '' <> 'X';
	IF v_proceso = 48 THEN
		v_cadena := 'la muestra de MP Nº ' || to_char(v_hcc);
	ELSE
		v_cadena := 'la muestra de PP Nº ' || to_char(v_hcc);
	END IF;
	raise_application_error(-20999,'No puede anular la bobina ' || :NEW.bobi_serie || '-' || to_char(:NEW.bobi_codigo) || ' pues está referenciada en ' ||
		trim(v_cadena) || ' / Anular la muestras referida desde Control de Calidad');
     ELSE
	raise_application_error(-20999,'No puede anular la bobina ' || :NEW.bobi_serie || '-' || to_char(:NEW.bobi_codigo) || ' pues está referenciada en ' ||
		to_char(v_reg) || ' muestras de Control de Calidad (MP o PP) / Anular las muestras referidas desde Control de Calidad');
      END IF;
   END IF;

    -- Borra los registros de bobina_bobina, donde la bobina es hija de otras
    DELETE BOBINA_BOBINA
    WHERE  bobina_bobina.almacen_serie = :NEW.almacen_serie and
	bobina_bobina.bobi_serie = :NEW.bobi_serie and
	bobina_bobina.bobi_codigo = :NEW.bobi_codigo;

   -- Borra los registros de bobina_bobina, donde la bobina es padre de otras
   DELETE BOBINA_BOBINA
   WHERE bobina_bobina.almacen_serie_padre = :NEW.almacen_serie and
	bobina_bobina.bobi_serie_padre = :NEW.bobi_serie and
	bobina_bobina.bobi_codigo_padre = :NEW.bobi_codigo;

   IF :NEW.bobi_serie = '009' THEN
      -- Borra las eoias relacionadas a las bobinas de pre-etiquetado (AMP)
      DELETE  eoia
      WHERE   eoia.almacen_serie = :NEW.almacen_serie and
	    eoia.bobi_serie = :NEW.bobi_serie and
	    eoia.bobi_codigo = :NEW.bobi_codigo;
   END IF;

   -- Elimina bobina_prov
   DELETE	bobina_prov
   WHERE	almacen_serie = :NEW.almacen_serie and bobi_serie = :NEW.bobi_serie and bobi_codigo = :NEW.bobi_codigo;

   -- Elimina bobina_cli
   DELETE	bobina_cli
   WHERE	almacen_serie = :NEW.almacen_serie and bobi_serie = :NEW.bobi_serie and bobi_codigo = :NEW.bobi_codigo;

 END IF;
EXCEPTION
 WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
     raise_application_error(-20999,'No Data Found or Too Many Rows!! -> tu_bobina_estado');
END;
/


CREATE OR REPLACE TRIGGER IMPOR.TU_B_BOBINA_INV
BEFORE UPDATE OF BOBINA_INVENTARIADA ON IMPOR.BOBINA FOR EACH ROW
BEGIN
 IF :NEW.bobina_inventariada = '1' THEN
    IF :NEW.bobi_fec_leida IS NULL THEN
       :NEW.bobi_fec_leida := sysdate;
    END IF;
 ELSE
   :NEW.bobi_fec_leida := NULL;
 END IF;
EXCEPTION
 WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
     raise_application_error(-20999,'No Data Found or Too Many Rows!! -> TU_B_BOBINA_INV');
END;
/


CREATE OR REPLACE TRIGGER IMPOR.TU_B_BOBINA_PESO
BEFORE UPDATE OF BOBI_PESO ON IMPOR.BOBINA FOR EACH ROW
BEGIN
 IF :NEW.bobi_peso < 0 THEN
	raise_application_error(-20999,'Error, La bobina ' || :NEW.bobi_serie || '-' || to_char(:NEW.bobi_codigo) || ' tiene Peso Negativo! (' ||
	to_char(:NEW.bobi_peso) || ')');
 END IF;

END;
/


CREATE OR REPLACE TRIGGER IMPOR.TU_B_BOBINA_ESTADO
BEFORE UPDATE OF BOBI_ESTADO ON IMPOR.BOBINA FOR EACH ROW
DECLARE
v_reg number;
BEGIN
 IF :NEW.bobi_estado = 'X' THEN
   -- Se saca del grupo de bobinas inventariadas
   :NEW.bobina_inventariada := '0';
   :NEW.bobi_fec_leida := NULL;
 ELSIF :NEW.bobi_estado = '5' THEN
   IF :OLD.bobi_estado = '6' or :OLD.bobi_estado = 'D'  /*or  :OLD.bobi_estado = '0' */ THEN
     :NEW.BOBI_FECHA_SALIDA := NULL; -- Se anuló de una Salida APP, no registra Fecha de Salida, pasó a Stock APP, o la bobina estuvo Depurada de APP
   ELSIF :OLD.bobi_estado = '5' THEN
     -- No haca nada.  En ventana de bobinas inventariadas, cuando se cambia el flag de inventariada de una bobina a NO inventariada, se actualiza el estado,
     -- pero no se cambia, sigue siendo 5.
     v_reg := v_reg;
   ELSE
     raise_application_error(-20999,'Estado previo inválido para la bobina ' || :NEW.bobi_serie || '-' || to_char(:NEW.bobi_codigo) || ' :' || :OLD.bobi_estado );
   END IF;
 ELSIF :NEW.bobi_estado = '6' THEN
    IF :NEW.bobi_fecha_salida IS NULL THEN
       :NEW.bobi_fecha_salida := sysdate; -- No hubo fecha de salida, se coloca el sysdate, en Salida APP
    END IF;
 ELSIF :NEW.bobi_estado = '0' THEN
    :NEW.bobi_fecha_salida := NULL;
 ELSIF :NEW.bobi_estado = '1' THEN
    IF :NEW.bobi_fecha_salida IS NULL THEN
       :NEW.bobi_fecha_salida := sysdate; -- No hubo fecha de salida, se coloca el sysdate, en Guía de Salida
    END IF;
 ELSIF :NEW.bobi_estado = '2' THEN
    IF :OLD.bobi_estado = '1' or :OLD.bobi_estado = 'D' THEN
     :NEW.BOBI_FECHA_SALIDA := NULL; -- Se anuló de una Guía de Salida, pasó a Oia de Despacho, o la bobina estuvo Depurada de APT
    END IF;
 ELSIF :NEW.bobi_estado = '8' THEN
    IF :OLD.bobi_estado = '2' or :OLD.bobi_estado = '9' or :OLD.bobi_estado = 'D' THEN
     :NEW.BOBI_FECHA_SALIDA := NULL; -- Se anuló de una Oia de Despacho o de una Salida AMP, pasó a Stock AMP, o la bobina estuvo Depurada de AMP
    END IF;
 ELSIF :NEW.bobi_estado = '9' THEN
    IF :NEW.bobi_fecha_salida IS NULL THEN
       :NEW.bobi_fecha_salida := sysdate; -- No hubo fecha de salida, se coloca el sysdate, en Salida AMP
    END IF;
 END IF;
END;
/


ALTER TABLE IMPOR.BOBINA ADD (
  PRIMARY KEY
 (ALMACEN_SERIE, BOBI_SERIE, BOBI_CODIGO)
    USING INDEX 
    TABLESPACE TEALMA_IN_GR
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          17104K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE IMPOR.BOBINA ADD (
  CONSTRAINT R_1005 
 FOREIGN KEY (ALMACEN_SERIE, PORDEN_INT_PANASA) 
 REFERENCES IMPOR.PORDEN_INTPA (ALMACEN_SERIE,PORDEN_INT_PANASA),
  FOREIGN KEY (ALMACEN_SERIE, MITEM_CODIGO, UNIDAD_CODIGO, SUBALMNUM, CODIGO_UBICACION) 
 REFERENCES IMPOR.ITEM_UBICACION (ALMACEN_SERIE,MITEM_CODIGO,UNIDAD_CODIGO,SUBALMNUM,CODIGO_UBICACION),
  FOREIGN KEY (TARA_CODIGO) 
 REFERENCES IMPOR.TARA (TARA_CODIGO),
  FOREIGN KEY (PLANTA_SERIE_PROD) 
 REFERENCES IMPOR.TPLANTA (PLANTA_SERIE),
  FOREIGN KEY (PLANTA_SERIE, HORD_TRAB_SECUENCIAL) 
 REFERENCES IMPOR.HORDEN_TRABAJO (PLANTA_SERIE,HORD_TRAB_SECUENCIAL),
  FOREIGN KEY (UBI_ALMACEN_SERIE, UBI_SUBALMNUM, UBIFISI_CODIGO) 
 REFERENCES IMPOR.UBICACION_FISICA (ALMACEN_SERIE,SUBALMNUM,UBIFISI_CODIGO),
  FOREIGN KEY (UBI_ALMACEN_SERIE_ANT, UBI_SUBALMNUM_ANT, UBIFISI_CODIGO_ANT) 
 REFERENCES IMPOR.UBICACION_FISICA (ALMACEN_SERIE,SUBALMNUM,UBIFISI_CODIGO),
  FOREIGN KEY (ALMACEN_SERIE, NUMERO_INVENTARIO) 
 REFERENCES IMPOR.TOMA_INVENTARIO (ALMACEN_SERIE,NUMERO_INVENTARIO),
  FOREIGN KEY (BCA_CODIGO) 
 REFERENCES IMPOR.TBOB_CALIF (BCA_CODIGO));

GRANT INSERT, SELECT, UPDATE ON IMPOR.BOBINA TO MCODE;
