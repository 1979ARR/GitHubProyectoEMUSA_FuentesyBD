ALTER TABLE IMPOR.MITEM
 DROP PRIMARY KEY CASCADE;

DROP TABLE IMPOR.MITEM CASCADE CONSTRAINTS;

CREATE TABLE IMPOR.MITEM
(
  MITEM_CODIGO             NUMBER(10)           NOT NULL,
  UNIDAD_CODIGO            CHAR(3 BYTE)         NOT NULL,
  COLOR_CODIGO             CHAR(4 BYTE),
  MITEM_STOCK_TOTAL        NUMBER(15,3),
  PROVEEDOR_CODIGO         CHAR(6 BYTE),
  MITEM_ESTADO             CHAR(1 BYTE),
  MITEM_FEC_APERTURA       DATE                 DEFAULT SYSDATE,
  MITEM_FEC_ANULACION      DATE,
  MITEM_FEC_ULT_MODIF      DATE,
  MITEM_GRAMAJE            NUMBER(6,2),
  DESCRIPCION_TAMANO       CHAR(20 BYTE),
  MARCA_CODIGO             CHAR(4 BYTE),
  LINEA_CODIGO             CHAR(3 BYTE),
  SUBLINEA_CODIGO          CHAR(3 BYTE),
  MITEM_ESPESOR            NUMBER(15,3),
  MITEM_DENSIDAD           VARCHAR2(10 BYTE),
  MITEM_COD_ANTIGUO        NUMBER(10),
  MITEM_USUARIO            VARCHAR2(20 BYTE),
  MITEM_SERIAL             VARCHAR2(20 BYTE),
  MITEM_USUARIO_MODIF      VARCHAR2(20 BYTE),
  MITEM_DESCRIP_ADICIONAL  VARCHAR2(200 BYTE),
  MITEM_PORC_SOLIDOS       NUMBER(9,6),
  MITEM_FLAG_EVAL_TINTAS   CHAR(1 BYTE),
  MITEM_TIPO_ITEM          CHAR(1 BYTE),
  MITEM_COD_ITEM_EQ_CP     VARCHAR2(15 BYTE),
  MITEM_TIPO_USO           CHAR(1 BYTE),
  TSTR_CODIGO              NUMBER(10)           DEFAULT NULL,
  STR_EQUIV_MP_SEC         NUMBER(10),
  STR_MP_BASE_SEC          NUMBER(10),
  PARTIDA_CODIGO           NUMBER(10),
  MITEM_P_USUARIO          VARCHAR2(20 BYTE),
  MITEM_P_FECHA            DATE                 DEFAULT sysdate,
  MITEM_P_USUARIO_MODIF    VARCHAR2(20 BYTE),
  MITEM_P_FECHA_MODIF      DATE,
  TCOLOR_CODIGO            NUMBER(10),
  TTE_CODIGO               CHAR(2 BYTE),
  MITEM_CODIGO_ASIGNADO    NUMBER(10),
  MITEM_TAM_TOLER_MIN      NUMBER(15,3),
  MITEM_TAM_TOLER_MAX      NUMBER(15,3),
  MITEM_PROV_CODIGO        VARCHAR2(10 BYTE),
  MITEM_FECHA_MOV          DATE,
  MITEM_CONSIGNACION       NUMBER(1)            DEFAULT 0                     NOT NULL,
  MITEM_MERMA              NUMBER               DEFAULT 0,
  MITEM_CODPRODSUNAT       VARCHAR2(8 BYTE),
  COD_CAT                  CHAR(2 BYTE),
  COD_SUBCAT               CHAR(3 BYTE),
  MITEM_CLASIF_PELETIZA    NUMBER(10),
  MITEM_ANTIBLOCK          VARCHAR2(10 BYTE),
  MITEM_SLIP               VARCHAR2(10 BYTE),
  MITEM_MELT_INDEX         VARCHAR2(10 BYTE)
)
TABLESPACE TEALMACEN
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          1032K
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

COMMENT ON COLUMN IMPOR.MITEM.UNIDAD_CODIGO IS 'Código de la unidad base, con la que se va a trabajar.';

COMMENT ON COLUMN IMPOR.MITEM.MITEM_PORC_SOLIDOS IS 'Valor que identifica el porcentaje de sólidos de la tinta virgen, que viene dado por el proveedor.  Útil para la obtención del costo de la tinta en la evaluación de OT.';

COMMENT ON COLUMN IMPOR.MITEM.MITEM_FLAG_EVAL_TINTAS IS 'Flag utilizado para identificar los items de la linea solvente, que se usan para la obtención del costo de tintas en la evaluación de OT.  Solo aplica para items de la linea "solvente".';

COMMENT ON COLUMN IMPOR.MITEM.MITEM_TIPO_ITEM IS 'Identifica si el item es de stock ("3"), no stock ("2") o servicios ("1").  La asignación es análoga a los valores de la tabla tipo_linea';

COMMENT ON COLUMN IMPOR.MITEM.MITEM_COD_ITEM_EQ_CP IS 'Codigo del Item Equivalente segun codificacion del Cliente o Proveedor';

COMMENT ON COLUMN IMPOR.MITEM.MITEM_TIPO_USO IS 'Aplica para Solventes.- diferenciación de solventes
"0" = Limpieza de Máquina
"1" = Produccion (Tinta)';


CREATE INDEX IMPOR.XAK1MITEM_SERIAL ON IMPOR.MITEM
(MITEM_SERIAL)
LOGGING
TABLESPACE TEALMACEN
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


CREATE INDEX IMPOR.XIE1MITEM ON IMPOR.MITEM
(MITEM_GRAMAJE)
LOGGING
TABLESPACE TEALMA_IN
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


CREATE INDEX IMPOR.XIF1498MITEM ON IMPOR.MITEM
(TSTR_CODIGO)
LOGGING
TABLESPACE TEALMACEN
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


CREATE INDEX IMPOR.XIF1549MITEM ON IMPOR.MITEM
(STR_MP_BASE_SEC)
LOGGING
TABLESPACE TECONTA_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          152K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1551MITEM ON IMPOR.MITEM
(STR_EQUIV_MP_SEC)
LOGGING
TABLESPACE TECONTA_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          152K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF1572MITEM ON IMPOR.MITEM
(PARTIDA_CODIGO)
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


CREATE INDEX IMPOR.XIF240MITEM ON IMPOR.MITEM
(UNIDAD_CODIGO)
LOGGING
TABLESPACE TEALMA_IN
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


CREATE INDEX IMPOR.XIF318MITEM ON IMPOR.MITEM
(DESCRIPCION_TAMANO)
LOGGING
TABLESPACE TEALMA_IN
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


CREATE INDEX IMPOR.XIF454MITEM ON IMPOR.MITEM
(LINEA_CODIGO, SUBLINEA_CODIGO)
LOGGING
TABLESPACE TEALMA_IN
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


CREATE INDEX IMPOR.XIF455MITEM ON IMPOR.MITEM
(MARCA_CODIGO)
LOGGING
TABLESPACE TEALMA_IN
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


CREATE INDEX IMPOR.XIF590MITEM ON IMPOR.MITEM
(PROVEEDOR_CODIGO)
LOGGING
TABLESPACE TEALMA_IN
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


CREATE INDEX IMPOR.XIF591MITEM ON IMPOR.MITEM
(COLOR_CODIGO)
LOGGING
TABLESPACE TEALMA_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          256K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER IMPOR.ti_b_mitem
BEFORE INSERT ON mitem
FOR EACH ROW
DECLARE
v_cadena item_descrip.item_descripcio%type;
v_cadizq item_descrip.item_descripcio%type;
v_cadder item_descrip.item_descripcio%type;
v_pos number;
BEGIN
 v_cadena := :NEW.mitem_descrip_adicional;
 v_pos := instr (v_cadena, '"');
 WHILE v_pos > 0 LOOP
         v_cadizq := substr(v_cadena, 1, v_pos - 1);
         v_cadder := substr(v_cadena, v_pos + 1);
         v_cadena := v_cadizq || '''' || v_cadder;
         v_pos := instr (v_cadena, '"');
 END LOOP;
 :NEW.mitem_descrip_adicional := v_cadena;
END;
/


CREATE OR REPLACE TRIGGER IMPOR.tu_b_mitem
BEFORE UPDATE OF mitem_descrip_adicional ON mitem
FOR EACH ROW
DECLARE
v_cadena item_descrip.item_descripcio%type;
v_cadizq item_descrip.item_descripcio%type;
v_cadder item_descrip.item_descripcio%type;
v_pos number;
BEGIN
 v_cadena := :NEW.mitem_descrip_adicional;
 v_pos := instr (v_cadena, '"');
 WHILE v_pos > 0 LOOP
         v_cadizq := substr(v_cadena, 1, v_pos - 1);
         v_cadder := substr(v_cadena, v_pos + 1);
         v_cadena := v_cadizq || '''' || v_cadder;
         v_pos := instr (v_cadena, '"');
 END LOOP;
 :NEW.mitem_descrip_adicional := v_cadena;
END;
/


ALTER TABLE IMPOR.MITEM ADD (
  PRIMARY KEY
 (MITEM_CODIGO)
    USING INDEX 
    TABLESPACE TEALMACEN
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          400K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE IMPOR.MITEM ADD (
  CONSTRAINT FK_MITEM_CATEGORIA_COD_CAT 
 FOREIGN KEY (COD_CAT) 
 REFERENCES IMPOR.CATEGORIA (COD_CAT),
  CONSTRAINT FK_MITEM_SUBCATE_COD_SUBCAT 
 FOREIGN KEY (COD_SUBCAT) 
 REFERENCES IMPOR.SUBCATEGORIA (COD_SUBCAT),
  FOREIGN KEY (UNIDAD_CODIGO) 
 REFERENCES IMPOR.MUNIDAD (UNIDAD_CODIGO),
  FOREIGN KEY (DESCRIPCION_TAMANO) 
 REFERENCES IMPOR.TAMANO_CONVERTIDO (DESCRIPCION_TAMANO),
  FOREIGN KEY (LINEA_CODIGO, SUBLINEA_CODIGO) 
 REFERENCES IMPOR.SUBLINEA (LINEA_CODIGO,SUBLINEA_CODIGO),
  FOREIGN KEY (MARCA_CODIGO) 
 REFERENCES IMPOR.MARCA (MARCA_CODIGO),
  FOREIGN KEY (COLOR_CODIGO) 
 REFERENCES IMPOR.COLOR (COLOR_CODIGO),
  FOREIGN KEY (PROVEEDOR_CODIGO) 
 REFERENCES IMPOR.CLIENTE_PROVEEDOR (CLIENTE_CODIGO),
  FOREIGN KEY (TSTR_CODIGO) 
 REFERENCES IMPOR.TESTRUCT_GRUPO (TSTR_CODIGO),
  FOREIGN KEY (STR_MP_BASE_SEC) 
 REFERENCES IMPOR.STR_MP_BASE (STR_MP_BASE_SEC),
  FOREIGN KEY (STR_EQUIV_MP_SEC) 
 REFERENCES IMPOR.STR_MP_EQUIV (STR_EQUIV_MP_SEC),
  FOREIGN KEY (PARTIDA_CODIGO) 
 REFERENCES IMPOR.TPARTIDA_ARANCELARIA (PARTIDA_CODIGO),
  FOREIGN KEY (TCOLOR_CODIGO) 
 REFERENCES IMPOR.TCOLOR_TINTA (TCOLOR_CODIGO),
  FOREIGN KEY (TTE_CODIGO) 
 REFERENCES IMPOR.TTINTA_ESTADO (TTE_CODIGO));

GRANT SELECT ON IMPOR.MITEM TO DMCUBO;
