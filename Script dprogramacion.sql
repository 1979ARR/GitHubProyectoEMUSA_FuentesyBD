ALTER TABLE IMPOR.DPROGRAMACION
 DROP PRIMARY KEY CASCADE;

DROP TABLE IMPOR.DPROGRAMACION CASCADE CONSTRAINTS;

CREATE TABLE IMPOR.DPROGRAMACION
(
  HPROG_CODIGO          NUMBER(10)              NOT NULL,
  HORD_TRAB_SECUENCIAL  NUMBER(10),
  MITEM_CODIGO          NUMBER(10)              NOT NULL,
  DPROG_NRO_BANDAS      NUMBER(3),
  DPROG_METROS          NUMBER(12,2),
  DPROG_PESO            NUMBER(12,2),
  DPROG_PORC_MERMA      NUMBER(6,3),
  DPROG_ESTADO          CHAR(1 BYTE)            DEFAULT '0'                   NOT NULL,
  USER_NEW              VARCHAR2(20 BYTE),
  USER_EDIT             VARCHAR2(20 BYTE),
  DATE_NEW              DATE,
  DATE_EDIT             DATE,
  HPED_NUMERO           NUMBER(10),
  PLANTA_SERIE          CHAR(3 BYTE),
  PROCESO_CODIGO        NUMBER(10),
  DPROG_STOCK_SEPARADO  CHAR(1 BYTE)            DEFAULT '0',
  DPACKING_CODIGO       NUMBER(10),
  DPROG_FECHA_ENTREGA   VARCHAR2(14 BYTE),
  DPROG_PESO_PT         NUMBER(12),
  DPROG_QPROGRAMADO     NUMBER(12,2),
  DPROG_ASIG_MAT        CHAR(1 BYTE)            DEFAULT 0                     NOT NULL,
  EST_PREPROG           CHAR(1 BYTE)            DEFAULT 0                     NOT NULL,
  OP_PADRE              NUMBER(10)
)
TABLESPACE TEPRODUCCION
PCTUSED    0
PCTFREE    20
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          200K
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


ALTER TABLE IMPOR.DPROGRAMACION ADD (
  PRIMARY KEY
 (HPROG_CODIGO, PLANTA_SERIE, PROCESO_CODIGO, MITEM_CODIGO)
    USING INDEX 
    TABLESPACE USERS
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          64K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE IMPOR.DPROGRAMACION ADD (
  FOREIGN KEY (MITEM_CODIGO) 
 REFERENCES IMPOR.MITEM (MITEM_CODIGO),
  FOREIGN KEY (PLANTA_SERIE, HORD_TRAB_SECUENCIAL) 
 REFERENCES IMPOR.HORDEN_TRABAJO (PLANTA_SERIE,HORD_TRAB_SECUENCIAL));