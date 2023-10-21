ALTER TABLE IMPOR.DOIA
 DROP PRIMARY KEY CASCADE;

DROP TABLE IMPOR.DOIA CASCADE CONSTRAINTS;

CREATE TABLE IMPOR.DOIA
(
  ALMACEN_SERIE            CHAR(3 BYTE)         NOT NULL,
  MITEM_CODIGO             NUMBER(10)           NOT NULL,
  CODIGO_TRANSACCION       CHAR(4 BYTE)         NOT NULL,
  SUBALMNUM                CHAR(3 BYTE)         NOT NULL,
  UNIDAD_CODIGO            CHAR(3 BYTE)         NOT NULL,
  HOIA_SECUENCIAL          NUMBER(10)           NOT NULL,
  CODIGO_UBICACION         CHAR(8 BYTE)         NOT NULL,
  DOIA_CANTIDAD_ORDENADA   NUMBER(15,3),
  DOIA_HOJA_DESP           CHAR(1 BYTE)         DEFAULT '0',
  DOIA_PRECIO_COMPRA       NUMBER(20,6),
  DOIA_COSTO_PROMEDIO      NUMBER(20,6),
  DOIA_PESO_TARA           NUMBER(15,3),
  DOIA_NRO_BULTOS          NUMBER(15,3),
  UNIDAD_BULTOS            CHAR(3 BYTE),
  MITEM_CODIGO_PADRE       NUMBER(10),
  UNIDAD_CODIGO_PADRE      CHAR(3 BYTE),
  ALMACEN_SERIE_PADRE      CHAR(3 BYTE),
  DOIA_COSTO_PROMEDIO_DOL  NUMBER(20,6),
  PALETA_CODIGO            NUMBER(10),
  EMBARQUE_CODIGO          CHAR(6 BYTE),
  COLOR1                   VARCHAR2(12 BYTE),
  COLOR2                   VARCHAR2(12 BYTE),
  COLOR3                   VARCHAR2(12 BYTE),
  DOIA_PRECIO_OC_MODIF     NUMBER(20,6)
)
TABLESPACE TEALMACEN
PCTUSED    0
PCTFREE    20
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          8304K
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

COMMENT ON COLUMN IMPOR.DOIA.DOIA_HOJA_DESP IS 'Bandera que indica si el ítem ha sido incluido ya en alguna hoja de despacho (ruta dentro del almacen).';

COMMENT ON COLUMN IMPOR.DOIA.DOIA_PRECIO_COMPRA IS 'Precio de Compra de acuerdo el Tipo de Moneda';

COMMENT ON COLUMN IMPOR.DOIA.DOIA_COSTO_PROMEDIO IS 'Costo en la Moneda Nacional';

COMMENT ON COLUMN IMPOR.DOIA.PALETA_CODIGO IS 'Paleta en que va el item, tanto en Despacho (2004) como Traslado_Embarque (2009), cuando se despacha como NO Elemento.';


CREATE INDEX IMPOR.XIF146DOIA ON IMPOR.DOIA
(ALMACEN_SERIE, CODIGO_TRANSACCION, HOIA_SECUENCIAL)
LOGGING
TABLESPACE TEALMACEN
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


CREATE INDEX IMPOR.XIF1542DOIA ON IMPOR.DOIA
(ALMACEN_SERIE, EMBARQUE_CODIGO, PALETA_CODIGO)
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


CREATE INDEX IMPOR.XIF382DOIA ON IMPOR.DOIA
(MITEM_CODIGO, UNIDAD_CODIGO, ALMACEN_SERIE, SUBALMNUM, CODIGO_UBICACION)
LOGGING
TABLESPACE TEALMACEN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          8904K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX IMPOR.XIF882DOIA ON IMPOR.DOIA
(MITEM_CODIGO_PADRE, UNIDAD_CODIGO_PADRE, ALMACEN_SERIE_PADRE)
LOGGING
TABLESPACE TEALMA_IN
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1000K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER IMPOR.TD_DOIA AFTER DELETE ON IMPOR.DOIA FOR EACH ROW
DECLARE
v_cantidad number;
lReg NUMBER;
dHProcSec hproc.hproc_secuencial%type;
dHProcCodTran hproc.codigo_transaccion%type;
dHProcSerieOt hproc.planta_serie%type;
dHProcSecOt hproc.hord_trab_secuencial%type;
dCant NUMBER(15,3);
v_considerar number;
dCantDPreDesp NUMBER(15,3);
dCantDPreDev NUMBER(15,3);
sEstadoHPre char(1);
dSignoEstandar number;
sEstado char(1);
dBobiPeso NUMBER(15,3);
dBobiPesoStock NUMBER(15,3);
dSecPordenIntPanasa number(10);
v_ult_usu hoia.usuario_ult_modif%type;
v_estado char(1);
v_trans_sec number;
v_cadena varchar2(100);
v_reg number;
v_transaccion tipo_transaccion.codigo_transaccion%type;

-- Cursor que barre los Eoias del DOia parámetro
CURSOR C_EOIA IS
 SELECT     eoia.ALMACEN_SERIE,  eoia.MITEM_CODIGO, eoia.UNIDAD_CODIGO,
     eoia.HOIA_SECUENCIAL, eoia.BOBI_CODIGO, eoia.BOBI_SERIE,
     eoia.CODIGO_TRANSACCION, eoia.EOIA_BOBI_PESO,
     decode(bb_padre.bobi_codigo,NULL,eoia.almacen_serie,bb_padre.almacen_serie_padre) bobi_almacen_padre,
     decode(bb_padre.bobi_codigo,NULL,eoia.bobi_serie,bb_padre.bobi_serie_padre) bobi_serie_padre,
     decode(bb_padre.bobi_codigo,NULL,eoia.BOBI_CODIGO,bb_padre.bobi_codigo_padre) bobi_codigo_padre,
     bb_hijo.bobi_serie bobi_almacen_hijo, bb_hijo.bobi_serie bobi_serie_hijo, bb_hijo.bobi_codigo bobi_codigo_hijo
 FROM    eoia, bobina_bobina bb_hijo, bobina_bobina bb_padre
 WHERE    eoia.hoia_secuencial = :OLD.hoia_secuencial and
    eoia.almacen_serie = :OLD.almacen_serie and
    eoia.codigo_transaccion = :OLD.codigo_transaccion and
    eoia.mitem_codigo = :OLD.mitem_codigo and
    eoia.unidad_codigo = :OLD.unidad_codigo and
    bb_hijo.almacen_serie_padre(+) = eoia.almacen_serie and
    bb_hijo.bobi_serie_padre(+) = eoia.bobi_serie and
    bb_hijo.bobi_codigo_padre(+) = eoia.bobi_codigo and
    bb_padre.almacen_serie(+) = eoia.almacen_serie and
    bb_padre.bobi_serie(+) = eoia.bobi_serie and
    bb_padre.bobi_codigo(+) = eoia.bobi_codigo;

-- Cursor que barre los Doias del Oia parámetro
CURSOR C_DOIA (p_transaccion tipo_transaccion.codigo_transaccion%type) IS
 SELECT    hoia.almacen_serie, hoia.codigo_transaccion, nvl(hoia.hpre_secuencial, 0) hpre_secuencial,
    dpre_despacho.dpre_cantidad, tipo_transaccion.signo_estandar
 FROM    hoia, dpre_despacho, tipo_transaccion
 WHERE    hoia.hoia_secuencial = :OLD.hoia_secuencial and
    hoia.almacen_serie = :OLD.almacen_serie and
    hoia.codigo_transaccion = :OLD.codigo_transaccion and
    dpre_despacho.almacen_serie(+) = hoia.almacen_serie and
    dpre_despacho.codigo_transaccion(+) = p_transaccion and
    dpre_despacho.hpre_secuencial(+) = hoia.hpre_secuencial and
    dpre_despacho.mitem_codigo(+) = :OLD.mitem_codigo and
    dpre_despacho.unidad_codigo(+) = :OLD.unidad_codigo and
    tipo_transaccion.codigo_transaccion = hoia.codigo_transaccion;

BEGIN
 -- INICIO
 -- Se verifica si alguna de las bobinas correspondientes al Item, ha Salido al siguiente proceso
/* FOR R_EOIA IN C_EOIA LOOP
    if nvl(R_EOIA.bobi_codigo_hijo,0) <> 0 then
        raise_application_error(-20999, 'No puede eliminar el Item. La Bobina: ' ||
            R_EOIA.bobi_serie || '-' || R_EOIA.bobi_codigo || ' tiene Movimientos. Ver Trazabilidad.');
    end if;
 END LOOP; */

 -- Signo de la Transaccion
 SELECT SIGNO_ESTANDAR INTO dSignoEstandar FROM tipo_transaccion WHERE codigo_transaccion = :OLD.codigo_transaccion;
 IF dSignoEstandar = 1 THEN
    -- Ingreso AMP.. verifica no hayan Salidas AMP posteriores
    SELECT    count(*) INTO v_reg FROM eoia, bobina
    WHERE    eoia.almacen_serie = :OLD.almacen_serie and eoia.codigo_transaccion = :OLD.codigo_transaccion and
        eoia.hoia_secuencial = :OLD.hoia_secuencial and eoia.mitem_codigo = :OLD.mitem_codigo and
        eoia.unidad_codigo = :OLD.unidad_codigo and
        bobina.almacen_serie = eoia.almacen_serie and bobina.bobi_serie = eoia.bobi_serie and
        bobina.bobi_codigo = eoia.bobi_codigo and round(bobina.bobi_peso, 3) + 0 <> round(bobina.bobi_peso_stock, 3);
    IF v_reg > 0 THEN
        raise_application_error(-20999, 'Al menos 1 bobina del Item que desea eliminar, ha tenido Salida de AMP - Ver Trazabilidad');
    END IF;
 ELSE
    IF :OLD.codigo_transaccion <> '2006' THEN
        -- Salidas Diversas AMP: verifica no hayan Ingresos AMP posteriores
        SELECT    count(*) INTO v_reg FROM eoia, bobina_bobina bb, eoia eoia_h, tipo_transaccion tt
        WHERE    eoia.almacen_serie = :OLD.almacen_serie and eoia.codigo_transaccion = :OLD.codigo_transaccion and
            eoia.hoia_secuencial = :OLD.hoia_secuencial and eoia.mitem_codigo = :OLD.mitem_codigo and
            eoia.unidad_codigo = :OLD.unidad_codigo and
            bb.almacen_serie_padre = eoia.almacen_serie and bb.bobi_serie_padre = eoia.bobi_serie and
            bb.bobi_codigo_padre = eoia.bobi_codigo and bb.bb_estado || '' <> 'X' and
            eoia_h.almacen_serie = bb.almacen_serie and eoia_h.bobi_serie = bb.bobi_serie and
            eoia_h.bobi_codigo = bb.bobi_codigo and
            tt.codigo_transaccion = eoia.codigo_transaccion and tt.signo_estandar = 1;
        IF v_reg > 0 THEN
            raise_application_error(-20999, 'Al menos 1 bobina del Item que desea eliminar, ha tenido Ingresos al AMP posteriores' ||
                ' - Ver Trazabilidad');
        END IF;
    ELSE
        -- Salidas a Produccion: verifica no haya recepcion de APP
        SELECT    count(*) INTO v_reg FROM eoia, bobina_bobina bb, eproc
        WHERE    eoia.almacen_serie = :OLD.almacen_serie and eoia.codigo_transaccion = :OLD.codigo_transaccion and
            eoia.hoia_secuencial = :OLD.hoia_secuencial and eoia.mitem_codigo = :OLD.mitem_codigo and
            eoia.unidad_codigo = :OLD.unidad_codigo and
            bb.almacen_serie_padre = eoia.almacen_serie and bb.bobi_serie_padre = eoia.bobi_serie and
            bb.bobi_codigo_padre = eoia.bobi_codigo and bb.bb_estado || '' <> 'X' and
            eproc.almacen_serie = bb.almacen_serie and eproc.bobi_serie = bb.bobi_serie and
            eproc.bobi_codigo = bb.bobi_codigo and eproc.codigo_transaccion = '1011';
        IF v_reg > 0 THEN
            raise_application_error(-20999, 'Al menos 1 bobina del Item que desea eliminar, ha tenido recepción en Ingresos APP posteriores'
                || ' - Ver Trazabilidad');
        END IF;
    END IF;
 END IF;

 -- Obtenemos el Ultimo Usuario... de Eliminación del Item de Oia
 SELECT usuario_ult_modif INTO v_ult_usu FROM hoia
 WHERE almacen_serie = :OLD.almacen_serie and hoia_secuencial = :OLD.hoia_secuencial and codigo_transaccion = :OLD.codigo_transaccion;
 v_cadena := 'Ubicó Datos Oia';

 -- Se obtienen datos de PROCESOS
 select     count(*) into lReg from oia_proc
 where     almacen_serie = :OLD.almacen_serie and codigo_transaccion = :OLD.codigo_transaccion and
     hoia_secuencial = :OLD.hoia_secuencial;
 IF nvl(lReg,0) > 0 THEN
    select     HPROC_SECUENCIAL, HPROC_CODIGO_TRANSACCION, PLANTA_SERIE, HORD_TRAB_SECUENCIAL
    into     dHProcSec, dHProcCodTran, dHProcSerieOt, dHProcSecOt
    from     oia_proc
    where    almacen_serie = :OLD.almacen_serie and codigo_transaccion = :OLD.codigo_transaccion and
        hoia_secuencial = :OLD.hoia_secuencial;
    -- Se elimina del EPROC
    select     count(*) into lReg from eproc
    where    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt and
        codigo_transaccion = dHProcCodTran and hproc_secuencial = dHProcSec and
        almacen_serie = :OLD.almacen_serie and mitem_codigo = :OLD.mitem_codigo AND unidad_codigo = :OLD.unidad_codigo;
    if nvl(lReg,0) > 0 then -- Si existe en EPROC
        FOR R_EOIA IN C_EOIA LOOP
            if :OLD.codigo_transaccion = '2006' then
                -- Se actualiza en Control de Calidad si hubo muestras de la Bobina (NULL)
                select     count(*) into lReg from hmuestra_cc
                where    almacen_serie = R_EOIA.ALMACEN_SERIE and bobi_serie = R_EOIA.BOBI_SERIE and
                    bobi_codigo = R_EOIA.BOBI_CODIGO and hcc_estado <> 'X';
                if nvl(lReg,0) > 0 then
                    update     hmuestra_cc
                    set    planta_serie = NULL, hord_trab_secuencial = NULL
                    where     almacen_serie = R_EOIA.ALMACEN_SERIE and bobi_serie = R_EOIA.BOBI_SERIE and
                        bobi_codigo = R_EOIA.BOBI_CODIGO and hcc_estado <> 'X';
                end if;
            end if;

            delete     from eproc
            where    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt and
                codigo_transaccion = dHProcCodTran and hproc_secuencial = dHProcSec and
                almacen_serie = :OLD.almacen_serie and mitem_codigo = :OLD.mitem_codigo AND
                unidad_codigo = :OLD.unidad_codigo and bobi_serie = R_EOIA.BOBI_SERIE and bobi_codigo = R_EOIA.BOBI_CODIGO;
        END LOOP;
    end if;

    -- Se elimina del DPROC
    select     count(*) into lReg from dproc
    where    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt and
        codigo_transaccion = dHProcCodTran and hproc_secuencial = dHProcSec and
        mitem_codigo = :OLD.mitem_codigo AND unidad_codigo = :OLD.unidad_codigo;
    if nvl(lReg,0) > 0 then
        delete     dproc
        where    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt and
            codigo_transaccion = dHProcCodTran and hproc_secuencial = dHProcSec and
            mitem_codigo = :OLD.mitem_codigo AND unidad_codigo = :OLD.unidad_codigo;
    end if;
 END IF;

-- Eliminación del EOIA/DOIA
 FOR R_EOIA IN C_EOIA LOOP
    -- Tratamiento del Padre ----------------------------------
 /*
    IF :OLD.codigo_transaccion in ('1005', '1001', '1002') THEN
        if R_EOIA.BOBI_SERIE_PADRE = '009' then
            -- Anula las bobinas de Compra/Importacion
            UPDATE bobina
            SET    bobina.bobi_estado = 'X'
            WHERE    almacen_serie = R_EOIA.BOBI_ALMACEN_PADRE and
                bobi_serie = R_EOIA.BOBI_SERIE_PADRE and
                bobi_codigo = R_EOIA.BOBI_CODIGO_PADRE;
        end if;
    END IF;
 */

    IF dSignoEstandar > 0 THEN -- Ingreso
        -- Anula la bobina tenga o no padre
        UPDATE bobina
        SET    bobi_estado = 'X',
            bobi_fec_ult_modif = sysdate,
            usu_ult_modif = v_ult_usu
        WHERE    almacen_serie = R_EOIA.ALMACEN_SERIE and
            bobi_serie = R_EOIA.BOBI_SERIE and
            bobi_codigo = R_EOIA.BOBI_CODIGO;
    ELSIF dSignoEstandar < 0 THEN-- Salida
        sEstado := '8';
        IF :OLD.codigo_transaccion = '2006' THEN
            -- En Salidas a Produccion, donde siempre se genera una bobina Temporal (0) en Salidas.. se regresa a Stock APP el Padre..
            -- es decir, el que efectivamente salió a Producción.
            UPDATE    bobina
            SET    bobi_estado = sEstado,
                bobi_peso_stock = decode( sign( nvl(bobi_peso_stock,0) - nvl(R_EOIA.EOIA_BOBI_PESO,0) * dSignoEstandar), -1, 0,
                    nvl(bobi_peso_stock,0) - nvl(R_EOIA.EOIA_BOBI_PESO,0) * dSignoEstandar),
                bobi_fecha_salida = decode( sign(nvl(bobi_peso_stock,0) - nvl(R_EOIA.EOIA_BOBI_PESO,0) * dSignoEstandar), 0,
                    NULL, -1, NULL, bobi_fecha_salida),
                bobi_fec_ult_modif = sysdate,
                usu_ult_modif = v_ult_usu
            WHERE    almacen_serie = R_EOIA.BOBI_ALMACEN_PADRE AND bobi_serie = R_EOIA.BOBI_SERIE_PADRE AND
                bobi_codigo = R_EOIA.BOBI_CODIGO_PADRE;
        ELSE
            -- En otras Salidas, donde NO se genera una bobina Temporal (0) en Salidas.. se regresa a Stock APP la bobina original..
            UPDATE    bobina
            SET    bobi_estado = sEstado,
                bobi_peso_stock = decode( sign( nvl(bobi_peso_stock,0) - nvl(R_EOIA.EOIA_BOBI_PESO,0) * dSignoEstandar), -1, 0,
                    nvl(bobi_peso_stock,0) - nvl(R_EOIA.EOIA_BOBI_PESO,0) * dSignoEstandar),
                bobi_fecha_salida = decode( sign(nvl(bobi_peso_stock,0) - nvl(R_EOIA.EOIA_BOBI_PESO,0) * dSignoEstandar), 0,
                    NULL, -1, NULL, bobi_fecha_salida),
                bobi_fec_ult_modif = sysdate,
                usu_ult_modif = v_ult_usu
            WHERE    almacen_serie = R_EOIA.ALMACEN_SERIE and bobi_serie = R_EOIA.BOBI_SERIE and
                bobi_codigo = R_EOIA.BOBI_CODIGO;
        END IF;
    END IF;

    -- Se elimina del EOIA
    DELETE     eoia
    WHERE    almacen_serie = :OLD.almacen_serie and codigo_transaccion = :OLD.codigo_transaccion and
        hoia_secuencial = :OLD.hoia_secuencial and
        mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo and
        bobi_serie = R_EOIA.BOBI_SERIE AND bobi_codigo = R_EOIA.bobi_codigo;

    IF dSignoEstandar > 0 or (dSignoEstandar < 0 and :OLD.codigo_transaccion = '2006') THEN
                     -- En los Ingresos... o en las Salidas a Producción...
        -- Se verifica si se generó Bobina_Bobina
        SELECT     count(*) INTO lReg FROM    bobina_bobina
        WHERE    almacen_serie = R_EOIA.almacen_serie and bobi_serie = R_EOIA.bobi_serie and
            bobi_codigo = R_EOIA.bobi_codigo;
        IF nvl(lReg,0) > 0 THEN
            -- Elimina referencia a la bobina de Ingreso.. o a la bobina Temporal (0) generada en la Salida a Produccion
            DELETE bobina_bobina
            WHERE    almacen_serie = R_EOIA.almacen_serie and bobi_serie = R_EOIA.bobi_serie and
                bobi_codigo = R_EOIA.bobi_codigo;

            -- Elimina la bobina de Ingreso.. o a la bobina Temporal (0) generada en la Salida a Produccion
            DELETE     bobina
            WHERE    almacen_serie = R_EOIA.almacen_serie and bobi_serie = R_EOIA.bobi_serie and
                bobi_codigo = R_EOIA.bobi_codigo;
        END IF;
    END IF;
 END LOOP;

 v_transaccion := :OLD.codigo_transaccion;
 IF v_transaccion in ('2006', '1009') THEN
    v_transaccion := '2006';
 END IF;
 FOR R_DOIA IN C_DOIA(v_transaccion) LOOP

       -- Actualizamos la cantidad recibida para aquellas Oias asociadas a porden_intpa (pej, compras, importaciones, tx almacenes)
    select     PORDEN_INT_PANASA into dSecPordenIntPanasa from hoia
    where    almacen_serie = :OLD.almacen_serie and codigo_transaccion = :OLD.codigo_transaccion and
        hoia_secuencial = :OLD.hoia_secuencial;
    v_cadena := 'Ubicó PordenIntPanasa de Oia';

    if nvl(dSecPordenIntPanasa,0) > 0 then
        UPDATE     dorden_intpa
        SET    dordpa_cantidad_recibida = nvl(dordpa_cantidad_recibida,0) - nvl(:OLD.doia_cantidad_ordenada,0)*dSignoEstandar
        WHERE     almacen_serie = :OLD.almacen_serie and porden_int_panasa = dSecPordenIntPanasa and
            mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;

        -- Actualizamos estado de la Orden de Ingreso
        SELECT    nvl(pordpa_estado, '0') INTO v_estado FROM porden_intpa
        WHERE     almacen_serie = :OLD.almacen_serie and porden_int_panasa = dSecPordenIntPanasa;
        v_cadena := 'Ubicó Datos de PordenIntPanasa';

        IF v_estado = '2' THEN
             v_estado := '1'; -- Hacia Ingreso Parcial
        ELSIF v_estado = '1' THEN
            SELECT     nvl(dordpa_cantidad_recibida, 0) INTO v_cantidad FROM dorden_intpa
            WHERE     almacen_serie = :OLD.almacen_serie and porden_int_panasa = dSecPordenIntPanasa and
                mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;
            v_cadena := 'Ubicó Datos de DordenIntPanasa';
            IF v_cantidad = 0 THEN
                v_estado := '0'; -- Hacia Generado, no cantidad recibida
            END IF;
        ELSE
            raise_application_error(-20999,'TD_DOIA. Estado Inválido de la Orden de Ingreso: ' || v_estado );
        END IF;
        UPDATE     porden_intpa
        SET    pordpa_estado = v_estado
        WHERE     almacen_serie = :OLD.almacen_serie and porden_int_panasa = dSecPordenIntPanasa;
        -- Actualizamos estado de Orden de Transferencia, si hubiera
        SELECT    nvl(htrans_almacen_secuencial, 0) INTO v_trans_sec FROM porden_intpa
        WHERE     almacen_serie = :OLD.almacen_serie and porden_int_panasa = dSecPordenIntPanasa;
        IF v_trans_sec > 0 THEN
            SELECT     nvl(htrans_estado, '0') INTO v_estado FROM htrans_almacen
            WHERE    almacen_destino = :OLD.almacen_serie and htrans_almacen_secuencial = v_trans_sec;
            v_cadena := 'Ubicó Datos de HTransAlmacen';
            IF v_estado = '1' THEN
                v_estado := '0'; -- Si la Orden de Transf está Terminada, se activa
                -- En otro caso, si está Activa o Truncada, queda tal cual
            END IF;
            UPDATE    htrans_almacen
            SET    htrans_estado = v_estado
            WHERE    almacen_destino = :OLD.almacen_serie and htrans_almacen_secuencial = v_trans_sec;
        END IF;
    end if;
    ----------------------------------------------------------------------

    -- Vemos si hay OT asociada
    SELECT    planta_serie, hord_trab_secuencial INTO dHProcSerieOt, dHProcSecOt FROM hoia
    WHERE    almacen_serie = :OLD.almacen_serie and codigo_transaccion = :OLD.codigo_transaccion and
        hoia_secuencial = :OLD.hoia_secuencial;
    v_cadena := 'Ubicó Datos de OT de Oia';

    -- Se actualiza las cantidades (cuando hay OT) y estado en la Orden de Salida
    IF R_DOIA.hpre_secuencial > 0 THEN
       SELECT    count(*) INTO lReg FROM dpre_despacho
         WHERE    hpre_secuencial = R_DOIA.hpre_secuencial and codigo_transaccion = v_transaccion and
        mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;
       IF nvl(lReg,0) > 0 THEN
        SELECT     count(*) INTO lReg FROM dpre_despacho
        WHERE    almacen_serie = :OLD.almacen_serie and hpre_secuencial = R_DOIA.hpre_secuencial and
            codigo_transaccion = v_transaccion and
            mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;
        IF nvl(lReg,0) > 0 THEN
            IF nvl(dHProcSecOt,0) > 0 THEN
                -- Se actualiza las cantidades (cuando hay OT)
                UPDATE    dpre_despacho
                SET    dpre_cantidad = nvl(dpre_cantidad,0) + :OLD.doia_cantidad_ordenada * R_DOIA.signo_estandar
                WHERE    hpre_secuencial = R_DOIA.hpre_secuencial and codigo_transaccion = v_transaccion and
                    mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;

                -- Se actualiza la cantidad en la Orden de Trabajo
                SELECT    count(*) into lReg from dorden_trabajo
                WHERE    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt and
                    mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;
                IF nvl(lReg,0) > 0 THEN
                    UPDATE    dorden_trabajo
                    SET    dord_trab_cantidad = nvl(dord_trab_cantidad,0) +
                        :OLD.doia_cantidad_ordenada * R_DOIA.signo_estandar
                    WHERE    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt and
                        mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;
                END IF;

                -- Se actualiza estado de la Orden de Trabajo
                SELECT     nvl(hord_estado, '0') INTO v_estado FROM horden_trabajo
                WHERE    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt;
                IF v_estado = '3' THEN
                    v_estado := '2'; -- Terminado -> Hacia PreDespacho Parcial
                    -- Si está en PreDespacho Parcial, no hace nada, pues no se mantiene registro de la cantidad despachada
                END IF;
                UPDATE    horden_trabajo
                SET    hord_estado = v_estado
                WHERE    planta_serie = dHProcSerieOt and hord_trab_secuencial = dHProcSecOt;
            END IF;

            -- Se actualiza estado de Orden de Salida
            SELECT    nvl(hpre_estado, '0') INTO v_estado FROM hpre_despacho
            WHERE     almacen_serie = :OLD.almacen_serie and hpre_secuencial = R_DOIA.hpre_secuencial and
                codigo_transaccion = v_transaccion;
            v_cadena := 'Ubicó Datos de HPreDespacho';
            IF v_estado = '3' THEN
                 v_estado := '2'; -- PreDespacho Total -> Hacia PreDespacho Parcial
                -- Si está en PreDespacho Parcial, no hace nada, pues no se mantiene registro de la cantidad despachada
            END IF;
            UPDATE     hpre_despacho
            SET    hpre_estado = v_estado
            WHERE     almacen_serie = :OLD.almacen_serie and hpre_secuencial = R_DOIA.hpre_secuencial and
                codigo_transaccion = v_transaccion;
        END IF;
       END IF;

       -- Actualizamos estado de Orden de Transferencia, si hubiera
       SELECT    nvl(htrans_almacen_secuencial, 0) INTO v_trans_sec FROM hpre_despacho
       WHERE    almacen_serie = :OLD.almacen_serie and hpre_secuencial = R_DOIA.hpre_secuencial and
        codigo_transaccion = v_transaccion;
       v_cadena := 'Ubicó Datos de Transf. de HPreDespacho';
       IF v_trans_sec > 0 THEN
        SELECT     nvl(htrans_estado, '0') INTO v_estado FROM htrans_almacen
        WHERE    almacen_origen = :OLD.almacen_serie and htrans_almacen_secuencial = v_trans_sec;
        v_cadena := 'Ubicó Datos de Transf.';
        IF v_estado = '1' THEN
            v_estado := '0'; -- Si la Orden de Transf está Terminada, se activa
            -- En otro caso, si está Activa o Truncada, queda tal cual
        END IF;
        UPDATE    htrans_almacen
        SET    htrans_estado = v_estado
        WHERE    almacen_destino = :OLD.almacen_serie and htrans_almacen_secuencial = v_trans_sec;
       END IF;
    END IF;

    -----------------------------------------------------------------------
    SELECT sf_considerar_saldo_oia(:OLD.almacen_serie, :OLD.hoia_secuencial, :OLD.codigo_transaccion,
        :OLD.mitem_codigo, :OLD.unidad_codigo) INTO v_considerar FROM dual;
    IF v_considerar <> 2 THEN
          -- Actualizar Stocks...
          -- Se Actualiza el Stock en ITEM_UBICACION -----------
          update item_ubicacion
          set     iubi_stock_fisico = nvl(iubi_stock_fisico,0) - :OLD.doia_cantidad_ordenada * R_DOIA.signo_estandar
          where almacen_serie = :OLD.almacen_serie and
        mitem_codigo = :OLD.mitem_codigo and
        unidad_codigo = :OLD.unidad_codigo and
        subalmnum = :OLD.subalmnum and
        codigo_ubicacion = :OLD.codigo_ubicacion;

           select iubi_stock_fisico into dCant from item_ubicacion
           where almacen_serie = :OLD.almacen_serie and
        mitem_codigo = :OLD.mitem_codigo and
        unidad_codigo = :OLD.unidad_codigo and
        subalmnum = :OLD.subalmnum and
        codigo_ubicacion = :OLD.codigo_ubicacion;
            v_cadena := 'Ubicó Datos de ItemUbicacion';
            if nvl(dCant,0) < 0 then
        raise_application_error(-20999, 'El stock del Item: ' || :OLD.mitem_codigo || '-' || :OLD.unidad_codigo ||
            ' es NEGATIVO (' || dCant || ')' );
            end if;
    END IF;
     -----------------------------------------------------------------------
 END LOOP;
 -- FIN
 EXCEPTION
    WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
        raise_application_error(-20999,'TD_DOIA. Muchas Filas o Data no Found! ' ||
            'hoia = ' || :OLD.hoia_secuencial || ' alm_serie = ' || :OLD.almacen_serie || ' ctran = ' ||
            :OLD.codigo_transaccion || ' item = ' || :OLD.mitem_codigo || '-' || :OLD.unidad_codigo || ' / ' || trim(v_cadena));
    WHEN OTHERS THEN
        raise_application_error(-20999, 'TD_DOIA: ' || SUBSTR(SQLERRM, 1, 100));
END;
/


CREATE OR REPLACE TRIGGER IMPOR.TU_DOIA_PED
AFTER UPDATE OF ALMACEN_SERIE, CODIGO_TRANSACCION, HOIA_SECUENCIAL, MITEM_CODIGO, UNIDAD_CODIGO, DOIA_CANTIDAD_ORDENADA ON IMPOR.DOIA REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW
DECLARE
v_guia_serie hguia_salida.guia_serie%type;
v_hguia_sec number;
v_codtran hguia_salida.codigo_transaccion%type;
v_nro_pedidos number := 0;
v_ped_serie hpedido.pedido_serie%type;
v_ped_numero number;

-- Barre los Pedidos asociados al Item de la Oia de Dev, del trigger
-- Obtiene valores cuando la Dev Guia se ligó a bobinas guiadas
CURSOR 	C_pedidos (p_alm almacen.almacen_serie%type, p_hoia hoia.hoia_secuencial%type, p_codtran hoia.codigo_transaccion%type,
	p_item item_unidad.mitem_codigo%type, p_und item_unidad.unidad_codigo%type) IS
 SELECT	hot.pedido_serie, hot.hped_numero,
	sum(decode(p_und, 'KGS', eproc.eproc_bobi_peso, eproc.cantidad_equivalente)) peso
 FROM	oia_proc op, eproc, horden_trabajo hot
 WHERE	op.almacen_serie = p_alm and op.hoia_secuencial = p_hoia and
	op.codigo_transaccion = p_codtran and
	eproc.hproc_secuencial = op.hproc_secuencial and eproc.planta_serie = op.planta_serie and
	eproc.hord_trab_secuencial = op.hord_trab_secuencial and eproc.codigo_transaccion = op.hproc_codigo_transaccion and
	eproc.proceso_codigo + 0 = 23 and eproc.mitem_codigo = p_item and
	decode(p_und, 'KGS', eproc.unidad_codigo, eproc.unidad_equivalente) = p_und and
	hot.planta_serie = eproc.planta_serie and hot.hord_trab_secuencial = eproc.hord_trab_secuencial
 GROUP BY hot.pedido_serie, hot.hped_numero;

BEGIN
 -- Si fue un Ingreso por Devolución del Cliente: pej. Devolución de Guía
 IF :OLD.codigo_transaccion  =  '1004' THEN
	SELECT	guia_serie_ref, nvl(hguia_secuencial_ref, 0) INTO v_guia_serie, v_hguia_sec FROM hoia
	WHERE 	almacen_serie = :OLD.almacen_serie and hoia_secuencial = :OLD.hoia_secuencial and codigo_transaccion = :OLD.codigo_transaccion;
	IF v_hguia_sec > 0 THEN
		SELECT	codigo_transaccion INTO v_codtran FROM hguia_salida WHERE guia_serie = v_guia_serie and hguia_secuencial = v_hguia_sec;
		IF v_codtran = '2004' THEN
			-- Actualizamos cantidad pedida
			FOR FILA IN C_pedidos(:OLD.almacen_serie, :OLD.hoia_secuencial, :OLD.codigo_transaccion,
				:OLD.mitem_codigo, :OLD.unidad_codigo) LOOP
				-- Esto se ejecuta si se ligaron bobinas o elementos en la Devolucion!
				UPDATE	dpedido
				SET	dped_cant_dev = nvl(dped_cant_dev, 0) - FILA.peso
				WHERE	pedido_serie = FILA.pedido_serie and hped_numero = FILA.hped_numero and
					mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;
				v_nro_pedidos := v_nro_pedidos + 1;
			END LOOP;

			IF v_nro_pedidos = 0 THEN
				-- Si no se ligaron elementos: se digitó cantidades en la Devolución
 				SELECT	dpedido.pedido_serie, dpedido.hped_numero
				INTO	v_ped_serie, v_ped_numero
				FROM	hguia_salida, hoia_guia, hoia, pedido_pre_despacho ppd, dpedido
				WHERE	hguia_salida.guia_serie = v_guia_serie and hguia_salida.hguia_secuencial = v_hguia_sec and
					hoia_guia.guia_serie = hguia_salida.guia_serie and
					hoia_guia.hguia_secuencial = hguia_salida.hguia_secuencial and
					hoia_guia.goi_estado <> 'X' and
					hoia.almacen_serie = hoia_guia.almacen_serie and hoia.hoia_secuencial = hoia_guia.hoia_secuencial and
					hoia.codigo_transaccion = hoia_guia.codigo_transaccion and
					ppd.almacen_serie = hoia.almacen_serie and ppd.hpre_secuencial = hoia.hpre_secuencial and
					ppd.codigo_transaccion = hoia.codigo_transaccion and
					dpedido.pedido_serie = ppd.pedido_serie and dpedido.hped_numero = ppd.hped_numero and
					dpedido.mitem_codigo + 0 = :OLD.mitem_codigo and dpedido.unidad_codigo || '' = :OLD.unidad_codigo and
					nvl(dpedido.dped_estado, '0') || '' <> 'X' and rownum < 2
				ORDER BY 2 asc;

				-- Actualiza cantidad devuelta en el pedido mas antiguo (menor nro de pedido)
				UPDATE	dpedido
				SET	dped_cant_dev = nvl(dped_cant_dev, 0) - nvl(:OLD.doia_cantidad_ordenada, 0)
				WHERE	pedido_serie = v_ped_serie and hped_numero = v_ped_numero and
					mitem_codigo = :OLD.mitem_codigo and unidad_codigo = :OLD.unidad_codigo;
			END IF;
		END IF;
	END IF;

	-- Si es un Ingreso por Devolución del Cliente: pej. Devolución de Guía
	IF :NEW.codigo_transaccion  = '1004' THEN
		SELECT	guia_serie_ref, nvl(hguia_secuencial_ref, 0) INTO v_guia_serie, v_hguia_sec FROM hoia
		WHERE 	almacen_serie = :NEW.almacen_serie and hoia_secuencial = :NEW.hoia_secuencial and
			codigo_transaccion = :NEW.codigo_transaccion;
		IF v_hguia_sec > 0 THEN
			SELECT	codigo_transaccion INTO v_codtran FROM hguia_salida
			WHERE guia_serie = v_guia_serie and hguia_secuencial = v_hguia_sec;
			IF v_codtran = '2004' THEN
				-- Actualizamos cantidad pedida
				v_nro_pedidos := 0;
				FOR FILA IN C_pedidos(:NEW.almacen_serie, :NEW.hoia_secuencial, :NEW.codigo_transaccion,
					:NEW.mitem_codigo, :NEW.unidad_codigo) LOOP
					-- Esto se ejecuta si se ligaron bobinas o elementos en la Devolucion!
					UPDATE	dpedido
					SET	dped_cant_dev = nvl(dped_cant_dev, 0) + FILA.peso
					WHERE	pedido_serie = FILA.pedido_serie and hped_numero = FILA.hped_numero and
						mitem_codigo = :NEW.mitem_codigo and unidad_codigo = :NEW.unidad_codigo;
					v_nro_pedidos := v_nro_pedidos + 1;
				END LOOP;

				IF v_nro_pedidos = 0 THEN
					-- Si no se ligaron elementos: se digitó cantidades en la Devolución
 					SELECT	dpedido.pedido_serie, dpedido.hped_numero
					INTO	v_ped_serie, v_ped_numero
					FROM	hguia_salida, hoia_guia, hoia, pedido_pre_despacho ppd, dpedido
					WHERE	hguia_salida.guia_serie = v_guia_serie and hguia_salida.hguia_secuencial = v_hguia_sec and
						hoia_guia.guia_serie = hguia_salida.guia_serie and
						hoia_guia.hguia_secuencial = hguia_salida.hguia_secuencial and
						hoia_guia.goi_estado <> 'X' and
						hoia.almacen_serie = hoia_guia.almacen_serie and
						hoia.hoia_secuencial = hoia_guia.hoia_secuencial and
						hoia.codigo_transaccion = hoia_guia.codigo_transaccion and
						ppd.almacen_serie = hoia.almacen_serie and ppd.hpre_secuencial = hoia.hpre_secuencial and
						ppd.codigo_transaccion = hoia.codigo_transaccion and
						dpedido.pedido_serie = ppd.pedido_serie and dpedido.hped_numero = ppd.hped_numero and
						dpedido.mitem_codigo + 0 = :NEW.mitem_codigo and
						dpedido.unidad_codigo || '' = :NEW.unidad_codigo and
						nvl(dpedido.dped_estado, '0') || '' <> 'X' and rownum < 2
					ORDER BY 2 asc;

					-- Actualiza cantidad devuelta en el pedido mas antiguo (menor nro de pedido)
					UPDATE	dpedido
					SET	dped_cant_dev = nvl(dped_cant_dev, 0) + nvl(:NEW.doia_cantidad_ordenada, 0)
					WHERE	pedido_serie = v_ped_serie and hped_numero = v_ped_numero and
						mitem_codigo = :NEW.mitem_codigo and unidad_codigo = :NEW.unidad_codigo;
				END IF;
			END IF;
		END IF;
	END IF;
 END IF;
END;
/


CREATE OR REPLACE TRIGGER IMPOR.TI_DOIA_PED
AFTER INSERT ON IMPOR.DOIA FOR EACH ROW
DECLARE
v_guia_serie hguia_salida.guia_serie%type;
v_hguia_sec number;
v_codtran hguia_salida.codigo_transaccion%type;
v_ped_serie hpedido.pedido_serie%type;
v_ped_numero hpedido.hped_numero%type;
v_nro_pedidos number := 0;
v_pedido_serie hpedido.pedido_serie%type;
v_hped_numero number;
v_embarque hoia.embarque_codigo%type;
v_reg number;
v_usuario hoia.tus_codigo%type;
v_hproc_secuencial number;
v_hord_trab number;

-- Barre los Pedidos asociados al Item de la Oia de Dev, del trigger
-- Obtiene valores cuando la Dev Guia se ligó a bobinas guiadas
CURSOR     C_pedidos IS
 SELECT    hot.pedido_serie, hot.hped_numero,
    sum(decode(:NEW.unidad_codigo, 'KGS', eproc.eproc_bobi_peso, eproc.cantidad_equivalente)) peso
 FROM    oia_proc op, eproc, horden_trabajo hot
 WHERE    op.almacen_serie = :NEW.almacen_serie and op.hoia_secuencial = :NEW.hoia_secuencial and
    op.codigo_transaccion = :NEW.codigo_transaccion and
    eproc.hproc_secuencial = op.hproc_secuencial and eproc.planta_serie = op.planta_serie and
    eproc.hord_trab_secuencial = op.hord_trab_secuencial and eproc.codigo_transaccion = op.hproc_codigo_transaccion and
    eproc.proceso_codigo + 0 = 23 and eproc.mitem_codigo = :NEW.mitem_codigo and
    decode(:NEW.unidad_codigo, 'KGS', eproc.unidad_codigo, eproc.unidad_equivalente) = :NEW.unidad_codigo and
    hot.planta_serie = eproc.planta_serie and hot.hord_trab_secuencial = eproc.hord_trab_secuencial
 GROUP BY hot.pedido_serie, hot.hped_numero;

BEGIN
 -- Si es un Ingreso por Devolución del Cliente: pej. Devolución de Guía
 IF :NEW.codigo_transaccion = '1004' THEN
    SELECT    guia_serie_ref, nvl(hguia_secuencial_ref, 0) INTO v_guia_serie, v_hguia_sec FROM hoia
    WHERE     almacen_serie = :NEW.almacen_serie and hoia_secuencial = :NEW.hoia_secuencial and codigo_transaccion = :NEW.codigo_transaccion;
    IF v_hguia_sec > 0 THEN
        SELECT    codigo_transaccion INTO v_codtran FROM hguia_salida WHERE guia_serie = v_guia_serie and hguia_secuencial = v_hguia_sec;
        IF v_codtran = '2004' THEN
            -- Actualizamos cantidad pedida
            FOR FILA IN C_pedidos LOOP
                -- Esto se ejecuta si se ligaron bobinas o elementos en la Devolucion!
                UPDATE    dpedido
                SET    dped_cant_dev = nvl(dped_cant_dev, 0) + FILA.peso
                WHERE    pedido_serie = FILA.pedido_serie and hped_numero = FILA.hped_numero and
                    mitem_codigo = :NEW.mitem_codigo and unidad_codigo = :NEW.unidad_codigo;
                v_nro_pedidos := v_nro_pedidos + 1;
            END LOOP;

            IF v_nro_pedidos = 0 THEN
                -- Si no se ligaron elementos: se digitó cantidades en la Devolución
                 SELECT    dpedido.pedido_serie, dpedido.hped_numero
                INTO    v_ped_serie, v_ped_numero
                FROM    hguia_salida, hoia_guia, hoia, pedido_pre_despacho ppd, dpedido
                WHERE    hguia_salida.guia_serie = v_guia_serie and hguia_salida.hguia_secuencial = v_hguia_sec and
                    hoia_guia.guia_serie = hguia_salida.guia_serie and
                    hoia_guia.hguia_secuencial = hguia_salida.hguia_secuencial and
                    hoia_guia.goi_estado <> 'X' and
                    hoia.almacen_serie = hoia_guia.almacen_serie and hoia.hoia_secuencial = hoia_guia.hoia_secuencial and
                    hoia.codigo_transaccion = hoia_guia.codigo_transaccion and
                    ppd.almacen_serie = hoia.almacen_serie and ppd.hpre_secuencial = hoia.hpre_secuencial and
                    ppd.codigo_transaccion = hoia.codigo_transaccion and
                    dpedido.pedido_serie = ppd.pedido_serie and dpedido.hped_numero = ppd.hped_numero and
                    dpedido.mitem_codigo + 0 = :NEW.mitem_codigo and dpedido.unidad_codigo || '' = :NEW.unidad_codigo and
                    nvl(dpedido.dped_estado, '0') || '' <> 'X' and rownum < 2
                ORDER BY 2 asc;

                -- Actualiza cantidad devuelta en el pedido mas antiguo (menor nro de pedido)
                UPDATE    dpedido
                SET    dped_cant_dev = nvl(dped_cant_dev, 0) + nvl(:NEW.doia_cantidad_ordenada, 0)
                WHERE    pedido_serie = v_ped_serie and hped_numero = v_ped_numero and
                    mitem_codigo = :NEW.mitem_codigo and unidad_codigo = :NEW.unidad_codigo;
            END IF;
        END IF;
    END IF;
 END IF;
 -- Si es un Pre-Despacho
 IF :NEW.codigo_transaccion = '2004' THEN
    SELECT    hoia.embarque_codigo, ppd.pedido_serie, ppd.hped_numero, hoia.tus_codigo
    INTO     v_embarque, v_pedido_serie, v_hped_numero, v_usuario
    FROM     hoia, hpre_despacho hpre, pedido_pre_despacho ppd
    WHERE    hoia.almacen_serie = :NEW.almacen_serie and hoia.hoia_secuencial = :NEW.hoia_secuencial and
        hoia.codigo_transaccion = :NEW.codigo_transaccion and hpre.almacen_serie = hoia.almacen_serie and
        hpre.hpre_secuencial = hoia.hpre_secuencial and hpre.codigo_transaccion = hoia.codigo_transaccion and
        ppd.almacen_serie = hpre.almacen_serie and ppd.hpre_secuencial = hpre.hpre_secuencial and
        ppd.codigo_transaccion = hpre.codigo_transaccion;

    IF v_embarque IS NOT NULL THEN
        SELECT    count(*) INTO v_reg FROM demb_ped
        WHERE    almacen_serie = :NEW.almacen_serie and embarque_codigo = v_embarque and
            pedido_serie = v_pedido_serie and hped_numero = v_hped_numero and
            mitem_codigo = :NEW.mitem_codigo and unidad_codigo = :NEW.unidad_codigo;
        IF v_reg = 0 THEN
            SELECT    count(*) INTO v_reg FROM hemb_ped
            WHERE    almacen_serie = :NEW.almacen_serie and embarque_codigo = v_embarque and
                pedido_serie = v_pedido_serie and hped_numero = v_hped_numero;
            IF v_reg = 0 THEN
                INSERT INTO hemb_ped ( pedido_serie, hped_numero, embarque_codigo, almacen_serie,
                    pe_fecha_grab, pe_usu_grab, pe_ult_fecha, pe_ult_usuario)
                VALUES (v_pedido_serie, v_hped_numero, v_embarque, :NEW.almacen_serie,
                    sysdate, v_usuario, sysdate, v_usuario);
            END IF;
            INSERT INTO demb_ped ( pedido_serie, hped_numero, almacen_serie, embarque_codigo,
                mitem_codigo, unidad_codigo, de_cantidad, de_genera)
            VALUES (v_pedido_serie, v_hped_numero, :NEW.almacen_serie, v_embarque,
                :NEW.mitem_codigo, :NEW.unidad_codigo, 0, '0');
        END IF;
    END IF;
 END IF;
 
 
 /*SELECT hoia.hord_trab_secuencial  INTO v_hord_trab  FROM  hoia  WHERE    
                hoia.almacen_serie = :NEW.almacen_serie and hoia.hoia_secuencial = :NEW.hoia_secuencial and
                hoia.codigo_transaccion = :NEW.codigo_transaccion and HOIA.HORD_TRAB_SECUENCIAL='134549';     
              
  IF :NEW.codigo_transaccion = '2006' and v_hord_trab='134549' THEN
    
      SELECT hproc.hproc_secuencial into v_hproc_secuencial from hproc  where 
                hproc.hord_trab_secuencial='134549' and
                hproc.almacen_serie = :NEW.almacen_serie and
                hproc.codigo_transaccion = :NEW.codigo_transaccion; 
    INSERT INTO dproc ( HPROC_SECUENCIAL,PLANTA_SERIE, HORD_TRAB_SECUENCIAL,
                             ALMACEN_SERIE, MITEM_CODIGO, UNIDAD_CODIGO, DPROC_CANTIDAD, CODIGO_TRANSACCION,DPROC_NUM_BOB)
      VALUES
                             ( v_hproc_secuencial,'001',v_hord_trab,:new.almacen_serie, '88975' , :new.UNIDAD_CODIGO,:new.DOIA_CANTIDAD_ORDENADA,:new.CODIGO_TRANSACCION,'1' );
    END IF;*/ 
END ;
/


ALTER TABLE IMPOR.DOIA ADD (
  PRIMARY KEY
 (ALMACEN_SERIE, SUBALMNUM, CODIGO_TRANSACCION, HOIA_SECUENCIAL, MITEM_CODIGO, UNIDAD_CODIGO, CODIGO_UBICACION)
    USING INDEX 
    TABLESPACE TEALMACEN
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          11464K
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE IMPOR.DOIA ADD (
  FOREIGN KEY (ALMACEN_SERIE, CODIGO_TRANSACCION, HOIA_SECUENCIAL) 
 REFERENCES IMPOR.HOIA (ALMACEN_SERIE,CODIGO_TRANSACCION,HOIA_SECUENCIAL),
  FOREIGN KEY (ALMACEN_SERIE, MITEM_CODIGO, UNIDAD_CODIGO, SUBALMNUM, CODIGO_UBICACION) 
 REFERENCES IMPOR.ITEM_UBICACION (ALMACEN_SERIE,MITEM_CODIGO,UNIDAD_CODIGO,SUBALMNUM,CODIGO_UBICACION),
  FOREIGN KEY (UNIDAD_BULTOS) 
 REFERENCES IMPOR.MUNIDAD (UNIDAD_CODIGO),
  FOREIGN KEY (ALMACEN_SERIE_PADRE, MITEM_CODIGO_PADRE, UNIDAD_CODIGO_PADRE) 
 REFERENCES IMPOR.ITEM_UNIDAD_ALMACEN (ALMACEN_SERIE,MITEM_CODIGO,UNIDAD_CODIGO),
  FOREIGN KEY (PALETA_CODIGO, EMBARQUE_CODIGO, ALMACEN_SERIE) 
 REFERENCES IMPOR.DPALETA (PALETA_CODIGO,EMBARQUE_CODIGO,ALMACEN_SERIE));

GRANT SELECT ON IMPOR.DOIA TO MCODE;
