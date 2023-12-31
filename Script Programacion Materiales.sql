ALTER TABLE IMPOR.PROGRAMACION_MATERIALES
 DROP PRIMARY KEY CASCADE;

DROP TABLE IMPOR.PROGRAMACION_MATERIALES CASCADE CONSTRAINTS;

CREATE TABLE IMPOR.PROGRAMACION_MATERIALES
(
  HPROG_CODIGO    NUMBER(10)                    NOT NULL,
  MITEM_CODIGO    NUMBER(10),
  USER_NEW        VARCHAR2(20 BYTE),
  USER_EDIT       VARCHAR2(20 BYTE),
  DATE_NEW        DATE,
  DATE_EDIT       DATE,
  PLANTA_SERIE    CHAR(3 BYTE)                  NOT NULL,
  PROCESO_CODIGO  NUMBER(10),
  MITEM_SEC       NUMBER(10)                    DEFAULT 1
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


ALTER TABLE IMPOR.PROGRAMACION_MATERIALES ADD (
  PRIMARY KEY
 (HPROG_CODIGO, PLANTA_SERIE, PROCESO_CODIGO, MITEM_CODIGO, MITEM_SEC)
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

ALTER TABLE IMPOR.PROGRAMACION_MATERIALES ADD (
  FOREIGN KEY (MITEM_CODIGO) 
 REFERENCES IMPOR.MITEM (MITEM_CODIGO));
