-- =============================================================================
--  Granja - Modulo de Pesagem e Mortalidade de Aves
--  01_schema.sql  -  Estrutura de tabelas, sequences e constraints
--
--  Banco.....: Oracle Database XE 11.2
--  Executar..: conectado como o usuario da aplicacao (GRANJA)
--  Idempotente: pode ser reexecutado (faz DROP dos objetos antes de criar)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Limpeza (ignora erro "objeto nao existe" para permitir reexecucao)
-- ---------------------------------------------------------------------------
BEGIN
  FOR r IN (SELECT table_name FROM user_tables
             WHERE table_name IN ('TAB_MORTALIDADE','TAB_PESAGEM','TAB_LOTE_AVES'))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;

  FOR r IN (SELECT sequence_name FROM user_sequences
             WHERE sequence_name IN ('SEQ_LOTE','SEQ_PESAGEM','SEQ_MORTALIDADE'))
  LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || r.sequence_name;
  END LOOP;
END;
/

-- ---------------------------------------------------------------------------
-- TAB_LOTE_AVES
--   PESO_MEDIO_GERAL: campo mantido automaticamente pela procedure de pesagem
--   (peso medio geral do lote).
-- ---------------------------------------------------------------------------
CREATE TABLE TAB_LOTE_AVES (
  ID_LOTE             NUMBER          NOT NULL,
  DESCRICAO           VARCHAR2(100)   NOT NULL,
  DATA_ENTRADA        DATE            DEFAULT SYSDATE NOT NULL,
  QUANTIDADE_INICIAL  NUMBER          NOT NULL,
  PESO_MEDIO_GERAL    NUMBER(10,2)    DEFAULT 0,
  CONSTRAINT PK_LOTE_AVES PRIMARY KEY (ID_LOTE),
  CONSTRAINT CK_LOTE_QTD_INICIAL CHECK (QUANTIDADE_INICIAL > 0)
);

COMMENT ON TABLE  TAB_LOTE_AVES                    IS 'Lotes de aves alojados na granja';
COMMENT ON COLUMN TAB_LOTE_AVES.PESO_MEDIO_GERAL   IS 'Peso medio ponderado do lote, recalculado a cada pesagem';

-- ---------------------------------------------------------------------------
-- TAB_PESAGEM
-- ---------------------------------------------------------------------------
CREATE TABLE TAB_PESAGEM (
  ID_PESAGEM          NUMBER          NOT NULL,
  ID_LOTE_FK          NUMBER          NOT NULL,
  DATA_PESAGEM        DATE            DEFAULT SYSDATE NOT NULL,
  PESO_MEDIO          NUMBER(10,2)    NOT NULL,
  QUANTIDADE_PESADA   NUMBER          NOT NULL,
  CONSTRAINT PK_PESAGEM PRIMARY KEY (ID_PESAGEM),
  CONSTRAINT FK_PESAGEM_LOTE FOREIGN KEY (ID_LOTE_FK)
       REFERENCES TAB_LOTE_AVES (ID_LOTE) ON DELETE CASCADE,
  CONSTRAINT CK_PESAGEM_QTD  CHECK (QUANTIDADE_PESADA > 0),
  CONSTRAINT CK_PESAGEM_PESO CHECK (PESO_MEDIO > 0)
);

CREATE INDEX IX_PESAGEM_LOTE ON TAB_PESAGEM (ID_LOTE_FK);

-- ---------------------------------------------------------------------------
-- TAB_MORTALIDADE
-- ---------------------------------------------------------------------------
CREATE TABLE TAB_MORTALIDADE (
  ID_MORTALIDADE      NUMBER          NOT NULL,
  ID_LOTE_FK          NUMBER          NOT NULL,
  DATA_MORTALIDADE    DATE            DEFAULT SYSDATE NOT NULL,
  QUANTIDADE_MORTA    NUMBER          NOT NULL,
  OBSERVACAO          VARCHAR2(255),
  CONSTRAINT PK_MORTALIDADE PRIMARY KEY (ID_MORTALIDADE),
  CONSTRAINT FK_MORTALIDADE_LOTE FOREIGN KEY (ID_LOTE_FK)
       REFERENCES TAB_LOTE_AVES (ID_LOTE) ON DELETE CASCADE,
  CONSTRAINT CK_MORTALIDADE_QTD CHECK (QUANTIDADE_MORTA > 0)
);

CREATE INDEX IX_MORTALIDADE_LOTE ON TAB_MORTALIDADE (ID_LOTE_FK);

-- ---------------------------------------------------------------------------
-- Sequences (XE 11.2 nao possui colunas IDENTITY)
-- ---------------------------------------------------------------------------
CREATE SEQUENCE SEQ_LOTE        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_PESAGEM     START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_MORTALIDADE START WITH 1 INCREMENT BY 1 NOCACHE;

PROMPT >> Schema criado com sucesso (3 tabelas + 3 sequences).
