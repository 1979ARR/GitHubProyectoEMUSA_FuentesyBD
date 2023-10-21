ALTER TABLE IMPOR.EOIA
 DROP PRIMARY KEY CASCADE;

DROP TABLE IMPOR.EOIA CASCADE CONSTRAINTS;

CREATE TABLE IMPOR.EOIA
(
  ALMACEN_SERIE         CHAR(3 BYTE)            NOT NULL,
  MITEM_CODIGO          NUMBER(10)              NOT NULL,
  UNIDAD_CODIGO         CHAR(3 BYTE)            NOT NULL,
  SUBALMNUM             CHAR(3 BYTE)            NOT NULL,
  CODIGO_UBICACION      CHAR(8 BYTE)            NOT NULL,
  HOIA_SECUENCIAL       NUMBER(10)              NOT NULL,
  BOBI_CODIGO           NUMBER(10)              NOT NULL,
  BOBI_SERIE            CHAR(3 BYTE)            NOT NULL,
  CODIGO_TRANSACCION    CHAR(4 BYTE)            NOT NULL,
  EOIA_BOBI_PESO        NUMBER(15,3),
  R_MAQUINA_SALIDA_APP  NUMBER(10),
  R_PROCESO_SALIDA_APP  NUMBER(10),
  EOIA_CANT_REAL_APP    NUMBER(15,3),
  PALETA_CODIGO         NUMBER(10),
  EMBARQUE_CODIGO       CHAR(6 BYTE),
  EOIA_METROS           NUMBER(15,3),
  SEC_REF               NUMBER(10),
  COSTO_UNIT_SOL        NUMBER(20,6),
  COSTO_UNIT_DOL        NUMBER(20,6)
)
TABLESPACE TEALMA_TB_GR
PCTUSED    0
PCTFREE    20
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          38904K
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

COMMENT ON COLUMN IMPOR.EOIA.BOBI_SERIE IS 'Serie de la lectora portatil, para procesos en batch';

COMMENT ON COLUMN IMPOR.EOIA.PALETA_CODIGO IS 'Paleta en que va la bobina, tanto en Despacho (2004) como Traslado_Embarque (2009), cuando se despacha en Elementos.';

COMMENT ON COLUMN IMPOR.EOIA.EOIA_METROS IS 'Metros registrados en la Devolucion del Clisse (metros corridos por el clisse)';


CREATE INDEX IMPOR.XIE1EOIA_HOIA ON IMPOR.EOIA
(ALMACEN_SERIE, CODIGO_TRANSACCION, HOIA_SECUENCIAL)
LOGGING
TABLESPACE TEALMA_IN_GR
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


CREATE INDEX IMPOR.XIE2EOIA ON IMPOR.EOIA
(MITEM_CODIGO, UNIDAD_CODIGO)
LOGGING
TABLESPACE TEALMA_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          2M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1055EOIA ON IMPOR.EOIA
(R_PROCESO_SALIDA_APP)
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


CREATE INDEX IMPOR.XIF1056EOIA ON IMPOR.EOIA
(R_MAQUINA_SALIDA_APP)
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


CREATE INDEX IMPOR.XIF1066EOIA_2 ON IMPOR.EOIA
(ALMACEN_SERIE, EMBARQUE_CODIGO, PALETA_CODIGO)
LOGGING
TABLESPACE TEALMA_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          8000K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF412EOIA ON IMPOR.EOIA
(MITEM_CODIGO, UNIDAD_CODIGO, HOIA_SECUENCIAL, ALMACEN_SERIE, SUBALMNUM, 
CODIGO_UBICACION, CODIGO_TRANSACCION)
LOGGING
TABLESPACE TEALMA_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          47400K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF413EOIA ON IMPOR.EOIA
(BOBI_CODIGO, BOBI_SERIE, ALMACEN_SERIE)
LOGGING
TABLESPACE TEALMA_IN_GR
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          21000K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER IMPOR.TD_EOIA
AFTER DELETE ON eoia for each row
declare
vreg number;
v_signo number;
BEGIN
 SELECT signo_estandar INTO v_signo FROM tipo_transaccion WHERE codigo_transaccion = :OLD.codigo_transaccion;

 IF :OLD.bobi_serie = '009' and :OLD.codigo_transaccion in ('1005', '1001', '1002') THEN
    	-- Bobinas de Pre-Etiquetado de AMP, o de otras transacciones
	vreg := 0;
/*     	No puede ejecutarse por el Trigger TD_DOIA: se levanta error Mutating
	Por ahora no se pueden modificar las bobinas recibidas en una Orden de Compra
	UPDATE	doia
     	SET	doia_nro_bultos = decode( sign( doia_nro_bultos - 1), 0, 0, -1, 0, null, 0, doia_nro_bultos - 1)
     	WHERE	almacen_serie = :OLD.almacen_serie and hoia_secuencial = :OLD.hoia_secuencial and
		codigo_transaccion = :OLD.codigo_transaccion and mitem_codigo = :OLD.mitem_codigo and
		unidad_codigo = :OLD.unidad_codigo and subalmnum = :OLD.subalmnum and
		codigo_ubicacion = :OLD.codigo_ubicacion; */
 ELSIF :OLD.bobi_serie = '002' THEN
	IF :OLD.codigo_transaccion in ('1011', '2016', '2031', '2032') THEN
		-- Decrementa los Stocks, cuando se elimina una eoia del Ingreso al Almacen PT o al Almacen MP
		-- Incrementa los Stocks cuando se elimina una eoia de Salida a Merma de PT o de PT hacia PP
		UPDATE 	item_ubicacion
	          	SET	iubi_stock_fisico = iubi_stock_fisico - :OLD.eoia_bobi_peso * v_signo
          		WHERE	mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo and
			subalmnum = :OLD.subalmnum and almacen_serie = :OLD.almacen_serie and
			codigo_ubicacion = :OLD.codigo_ubicacion;
	END IF;
 END IF;
END;
/


CREATE OR REPLACE TRIGGER IMPOR.TI_EOIA
AFTER INSERT ON IMPOR.EOIA for each row
declare
v_bobi_cod  number;
v_longitud   number;
v_planta_serie char(3);
v_hproc_secuencial number;
v_hord_trab number;

BEGIN
 IF (:NEW.bobi_serie = '009' and :NEW.codigo_transaccion in ('1005', '1001', '1002')) THEN
    -- Bobinas de Pre-Etiquetado de AMP, o de otras transacciones
    UPDATE	doia
    SET		doia_nro_bultos = decode( doia_nro_bultos, null, 1, doia_nro_bultos + 1)
    WHERE		almacen_serie = :NEW.almacen_serie and
		hoia_secuencial = :NEW.hoia_secuencial and
		codigo_transaccion = :NEW.codigo_transaccion and
		mitem_codigo = :NEW.mitem_codigo and
		unidad_codigo = :NEW.unidad_codigo and
		subalmnum = :NEW.subalmnum and
		codigo_ubicacion = :NEW.codigo_ubicacion;
 END IF;
 
   /*     SELECT  hoia.hord_trab_secuencial
        INTO   v_hord_trab
        FROM  hoia
        WHERE    
        hoia.almacen_serie = :NEW.almacen_serie and hoia.hoia_secuencial = :NEW.hoia_secuencial and
        hoia.codigo_transaccion = :NEW.codigo_transaccion and hoia.HORD_TRAB_SECUENCIAL='134549';
 
   IF :NEW.codigo_transaccion = '2006' and v_hord_trab='134549' THEN        
        SELECT  hoia.hord_trab_secuencial
        INTO   v_hord_trab
        FROM  hoia
        WHERE    
        hoia.almacen_serie = :NEW.almacen_serie and hoia.hoia_secuencial = :NEW.hoia_secuencial and
        hoia.codigo_transaccion = :NEW.codigo_transaccion and hoia.HORD_TRAB_SECUENCIAL='134549';
                        
        select hproc.hproc_secuencial ,hproc.PLANTA_SERIE
        into v_hproc_secuencial,v_planta_serie FROM hproc
        where  hproc.hord_trab_secuencial='134549' and
        hproc.almacen_serie = :NEW.almacen_serie and
        hproc.codigo_transaccion = :NEW.codigo_transaccion;  
        
        select  tamano_convertido.mitem_tamano1  into v_longitud from tamano_convertido,mitem where  tamano_convertido.descripcion_tamano = mitem.descripcion_tamano 
        and MITEM.MITEM_CODIGO=:new.mitem_codigo;                
        v_bobi_cod := sf_siguiente_bobi_codigo ('002');  
        
       INSERT INTO eproc ( HPROC_SECUENCIAL,  PLANTA_SERIE,  HORD_TRAB_SECUENCIAL,  ALMACEN_SERIE,  MITEM_CODIGO,  UNIDAD_CODIGO,  BOBI_SERIE,
             CODIGO_TRANSACCION,  PROCESO_CODIGO,  BOBI_CODIGO,  MAQUINA_CODIGO,  HMOT_CODIGO,  DMOT_CODIGO,  EPROC_BOBI_LONGITUD,
             EPROC_BOBI_PESO, EPROC_BOBI_PESO_BRUTO,  UNIDAD_EQUIVALENTE,  CANTIDAD_EQUIVALENTE,  CONDICION_CODIGO, BALANZA_CODIGO,  PLANTA_SERIE_PROD, 
             R_ALMACEN_SERIE_AMP,  R_MITEM_CODIGO_AMP,  R_UNIDAD_CODIGO_AMP,  TRANSF_PT,  TSI_CODIGO,  PROV_PT)
        VALUES
             ( v_hproc_secuencial ,v_planta_serie,v_hord_trab,:new.almacen_serie,'88975',:new.unidad_codigo,'002','1011','48',v_bobi_cod,'46','02','14',v_longitud,:new.EOIA_BOBI_PESO,
             :new.EOIA_BOBI_PESO,'BOB','1','135','02',:new.almacen_serie,:new.almacen_serie,:new.mitem_codigo,:new.unidad_codigo,'0',1,'0'); 
        END IF;*/
 
 
END;
/


ALTER TABLE IMPOR.EOIA ADD (
  PRIMARY KEY
 (ALMACEN_SERIE, MITEM_CODIGO, UNIDAD_CODIGO, HOIA_SECUENCIAL, SUBALMNUM, CODIGO_UBICACION, BOBI_SERIE, BOBI_CODIGO, CODIGO_TRANSACCION)
    USING INDEX 
    TABLESPACE TEALMA_IN_GR
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          55456K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE IMPOR.EOIA ADD (
  FOREIGN KEY (ALMACEN_SERIE, SUBALMNUM, CODIGO_TRANSACCION, HOIA_SECUENCIAL, MITEM_CODIGO, UNIDAD_CODIGO, CODIGO_UBICACION) 
 REFERENCES IMPOR.DOIA (ALMACEN_SERIE,SUBALMNUM,CODIGO_TRANSACCION,HOIA_SECUENCIAL,MITEM_CODIGO,UNIDAD_CODIGO,CODIGO_UBICACION),
  FOREIGN KEY (R_PROCESO_SALIDA_APP) 
 REFERENCES IMPOR.PROCESO (PROCESO_CODIGO),
  FOREIGN KEY (R_MAQUINA_SALIDA_APP) 
 REFERENCES IMPOR.MAQUINA (MAQUINA_CODIGO),
  FOREIGN KEY (PALETA_CODIGO, EMBARQUE_CODIGO, ALMACEN_SERIE) 
 REFERENCES IMPOR.DPALETA (PALETA_CODIGO,EMBARQUE_CODIGO,ALMACEN_SERIE),
  FOREIGN KEY (ALMACEN_SERIE, BOBI_SERIE, BOBI_CODIGO) 
 REFERENCES IMPOR.BOBINA (ALMACEN_SERIE,BOBI_SERIE,BOBI_CODIGO));

GRANT SELECT ON IMPOR.EOIA TO MCODE;
