-- =============================================================================
--  Granja - Modulo de Pesagem e Mortalidade de Aves
--  02_procedures.sql  -  Stored Procedures e Functions (regra de negocio PL/SQL)
--
--  Implementado como objetos STANDALONE (procedures/functions de schema), sem
--  package. Toda a escrita do Delphi passa por estas procedures.
--
--  Codigos de erro  (RAISE_APPLICATION_ERROR):
--    -20001  Quantidade pesada ultrapassa a quantidade inicial do lote
--    -20002  Quantidade morta acumulada ultrapassa a quantidade inicial do lote
--    -20003  Lote / registro nao encontrado
--    -20004  Parametro invalido
--    -20005  Quantidade inicial menor que o ja registrado (pesagem/mortalidade)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Limpeza (ignora "objeto nao existe"; remove tambem o package antigo, se houver).
-- ---------------------------------------------------------------------------
BEGIN
  FOR r IN (SELECT object_name, object_type
              FROM user_objects
             WHERE object_type IN ('PROCEDURE','FUNCTION','PACKAGE')
               AND object_name IN (
                 'PKG_GRANJA',
                 'INSERIR_LOTE','ATUALIZAR_LOTE','EXCLUIR_LOTE',
                 'INSERIR_PESAGEM','ATUALIZAR_PESAGEM','EXCLUIR_PESAGEM',
                 'INSERIR_MORTALIDADE','ATUALIZAR_MORTALIDADE','EXCLUIR_MORTALIDADE',
                 'LER_LOTE_FOR_UPDATE','RECALCULAR_PESO_MEDIO',
                 'MORTES_ACUMULADAS','MORTES_ACUMULADAS_EXCETO','PERC_MORTALIDADE'))
  LOOP
    EXECUTE IMMEDIATE 'DROP ' || r.object_type || ' ' || r.object_name;
  END LOOP;
END;
/

-- ===========================================================================
-- Functions de apoio (consulta do indicador de saude)
-- ===========================================================================
CREATE OR REPLACE FUNCTION MORTES_ACUMULADAS (p_id_lote IN NUMBER) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(QUANTIDADE_MORTA), 0)
    INTO v_total
    FROM TAB_MORTALIDADE
   WHERE ID_LOTE_FK = p_id_lote;
  RETURN v_total;
END MORTES_ACUMULADAS;
/

-- Mortes acumuladas do lote desconsiderando um registro (usado na edicao, para a
-- validacao nao contar a propria mortalidade que esta sendo alterada).
CREATE OR REPLACE FUNCTION MORTES_ACUMULADAS_EXCETO (p_id_lote IN NUMBER,
                                                     p_id_mort IN NUMBER) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(QUANTIDADE_MORTA), 0)
    INTO v_total
    FROM TAB_MORTALIDADE
   WHERE ID_LOTE_FK = p_id_lote
     AND ID_MORTALIDADE <> NVL(p_id_mort, -1);
  RETURN v_total;
END MORTES_ACUMULADAS_EXCETO;
/

CREATE OR REPLACE FUNCTION PERC_MORTALIDADE (p_id_lote IN NUMBER) RETURN NUMBER IS
  v_qtd_inicial TAB_LOTE_AVES.QUANTIDADE_INICIAL%TYPE;
BEGIN
  SELECT QUANTIDADE_INICIAL INTO v_qtd_inicial
    FROM TAB_LOTE_AVES WHERE ID_LOTE = p_id_lote;

  IF NVL(v_qtd_inicial,0) = 0 THEN
    RETURN 0;
  END IF;
  RETURN ROUND(MORTES_ACUMULADAS(p_id_lote) * 100 / v_qtd_inicial, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Lote ' || p_id_lote || ' nao encontrado.');
END PERC_MORTALIDADE;
/

-- ===========================================================================
-- Procedures auxiliares (privadas no sentido logico)
-- ===========================================================================

-- Carrega o lote travando a linha (evita corrida entre validar e gravar).
CREATE OR REPLACE PROCEDURE LER_LOTE_FOR_UPDATE (p_id_lote IN  NUMBER,
                                                 r_lote    OUT TAB_LOTE_AVES%ROWTYPE) IS
BEGIN
  SELECT * INTO r_lote
    FROM TAB_LOTE_AVES
   WHERE ID_LOTE = p_id_lote
     FOR UPDATE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Lote ' || p_id_lote || ' nao encontrado.');
END LER_LOTE_FOR_UPDATE;
/

-- Recalcula o peso medio geral (media ponderada pela quantidade pesada).
CREATE OR REPLACE PROCEDURE RECALCULAR_PESO_MEDIO (p_id_lote IN NUMBER) IS
  v_peso TAB_LOTE_AVES.PESO_MEDIO_GERAL%TYPE;
BEGIN
  SELECT NVL(SUM(PESO_MEDIO * QUANTIDADE_PESADA) / NULLIF(SUM(QUANTIDADE_PESADA),0), 0)
    INTO v_peso
    FROM TAB_PESAGEM
   WHERE ID_LOTE_FK = p_id_lote;

  UPDATE TAB_LOTE_AVES
     SET PESO_MEDIO_GERAL = ROUND(v_peso, 2)
   WHERE ID_LOTE = p_id_lote;
END RECALCULAR_PESO_MEDIO;
/

-- ===========================================================================
-- Lote
-- ===========================================================================
CREATE OR REPLACE PROCEDURE INSERIR_LOTE (p_descricao  IN  VARCHAR2,
                                          p_data       IN  DATE,
                                          p_quantidade IN  NUMBER,
                                          p_id_lote    OUT NUMBER) IS
BEGIN
  IF TRIM(p_descricao) IS NULL THEN
    RAISE_APPLICATION_ERROR(-20004, 'Descricao do lote e obrigatoria.');
  END IF;
  IF NVL(p_quantidade,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Quantidade inicial deve ser maior que zero.');
  END IF;

  p_id_lote := SEQ_LOTE.NEXTVAL;

  INSERT INTO TAB_LOTE_AVES (ID_LOTE, DESCRICAO, DATA_ENTRADA, QUANTIDADE_INICIAL, PESO_MEDIO_GERAL)
  VALUES (p_id_lote, p_descricao, NVL(p_data, SYSDATE), p_quantidade, 0);
END INSERIR_LOTE;
/

CREATE OR REPLACE PROCEDURE ATUALIZAR_LOTE (p_id_lote    IN NUMBER,
                                            p_descricao  IN VARCHAR2,
                                            p_data       IN DATE,
                                            p_quantidade IN NUMBER) IS
  r_lote       TAB_LOTE_AVES%ROWTYPE;
  v_mortes     NUMBER;
  v_max_pesada NUMBER;
BEGIN
  LER_LOTE_FOR_UPDATE(p_id_lote, r_lote);

  IF TRIM(p_descricao) IS NULL THEN
    RAISE_APPLICATION_ERROR(-20004, 'Descricao do lote e obrigatoria.');
  END IF;
  IF NVL(p_quantidade,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Quantidade inicial deve ser maior que zero.');
  END IF;

  -- Nao permitir reduzir a quantidade inicial abaixo do que ja foi lancado.
  v_mortes := MORTES_ACUMULADAS(p_id_lote);
  SELECT NVL(MAX(QUANTIDADE_PESADA),0) INTO v_max_pesada
    FROM TAB_PESAGEM WHERE ID_LOTE_FK = p_id_lote;

  IF p_quantidade < v_mortes THEN
    RAISE_APPLICATION_ERROR(-20005,
      'Quantidade inicial (' || p_quantidade || ') menor que a mortalidade ja registrada (' || v_mortes || ').');
  END IF;
  IF p_quantidade < v_max_pesada THEN
    RAISE_APPLICATION_ERROR(-20005,
      'Quantidade inicial (' || p_quantidade || ') menor que a maior pesagem registrada (' || v_max_pesada || ').');
  END IF;

  UPDATE TAB_LOTE_AVES
     SET DESCRICAO          = p_descricao,
         DATA_ENTRADA       = NVL(p_data, DATA_ENTRADA),
         QUANTIDADE_INICIAL = p_quantidade
   WHERE ID_LOTE = p_id_lote;
END ATUALIZAR_LOTE;
/

CREATE OR REPLACE PROCEDURE EXCLUIR_LOTE (p_id_lote IN NUMBER) IS
BEGIN
  DELETE FROM TAB_LOTE_AVES WHERE ID_LOTE = p_id_lote;
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Lote ' || p_id_lote || ' nao encontrado.');
  END IF;
  -- Pesagens e mortalidades sao removidas em cascata (ON DELETE CASCADE).
END EXCLUIR_LOTE;
/

-- ===========================================================================
-- Pesagem
-- ===========================================================================
CREATE OR REPLACE PROCEDURE INSERIR_PESAGEM (p_id_lote     IN  NUMBER,
                                             p_data        IN  DATE,
                                             p_peso_medio  IN  NUMBER,
                                             p_qtd_pesada  IN  NUMBER,
                                             p_id_pesagem  OUT NUMBER) IS
  r_lote TAB_LOTE_AVES%ROWTYPE;
BEGIN
  LER_LOTE_FOR_UPDATE(p_id_lote, r_lote);

  IF NVL(p_peso_medio,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Peso medio deve ser maior que zero.');
  END IF;
  IF NVL(p_qtd_pesada,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Quantidade pesada deve ser maior que zero.');
  END IF;

  -- Quantidade pesada nao pode ultrapassar a quantidade inicial do lote.
  IF p_qtd_pesada > r_lote.QUANTIDADE_INICIAL THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Quantidade pesada (' || p_qtd_pesada || ') ultrapassa a quantidade inicial do lote (' ||
      r_lote.QUANTIDADE_INICIAL || ').');
  END IF;

  p_id_pesagem := SEQ_PESAGEM.NEXTVAL;

  INSERT INTO TAB_PESAGEM (ID_PESAGEM, ID_LOTE_FK, DATA_PESAGEM, PESO_MEDIO, QUANTIDADE_PESADA)
  VALUES (p_id_pesagem, p_id_lote, NVL(p_data, SYSDATE), p_peso_medio, p_qtd_pesada);

  -- Atualizar o peso medio geral do lote.
  RECALCULAR_PESO_MEDIO(p_id_lote);
END INSERIR_PESAGEM;
/

CREATE OR REPLACE PROCEDURE ATUALIZAR_PESAGEM (p_id_pesagem IN NUMBER,
                                               p_data       IN DATE,
                                               p_peso_medio IN NUMBER,
                                               p_qtd_pesada IN NUMBER) IS
  r_lote    TAB_LOTE_AVES%ROWTYPE;
  v_id_lote TAB_PESAGEM.ID_LOTE_FK%TYPE;
BEGIN
  SELECT ID_LOTE_FK INTO v_id_lote FROM TAB_PESAGEM WHERE ID_PESAGEM = p_id_pesagem;
  LER_LOTE_FOR_UPDATE(v_id_lote, r_lote);

  IF NVL(p_peso_medio,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Peso medio deve ser maior que zero.');
  END IF;
  IF NVL(p_qtd_pesada,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Quantidade pesada deve ser maior que zero.');
  END IF;
  IF p_qtd_pesada > r_lote.QUANTIDADE_INICIAL THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Quantidade pesada (' || p_qtd_pesada || ') ultrapassa a quantidade inicial do lote (' ||
      r_lote.QUANTIDADE_INICIAL || ').');
  END IF;

  UPDATE TAB_PESAGEM
     SET DATA_PESAGEM      = NVL(p_data, DATA_PESAGEM),
         PESO_MEDIO        = p_peso_medio,
         QUANTIDADE_PESADA = p_qtd_pesada
   WHERE ID_PESAGEM = p_id_pesagem;

  RECALCULAR_PESO_MEDIO(v_id_lote);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Pesagem ' || p_id_pesagem || ' nao encontrada.');
END ATUALIZAR_PESAGEM;
/

CREATE OR REPLACE PROCEDURE EXCLUIR_PESAGEM (p_id_pesagem IN NUMBER) IS
  v_id_lote TAB_PESAGEM.ID_LOTE_FK%TYPE;
BEGIN
  SELECT ID_LOTE_FK INTO v_id_lote FROM TAB_PESAGEM WHERE ID_PESAGEM = p_id_pesagem;

  DELETE FROM TAB_PESAGEM WHERE ID_PESAGEM = p_id_pesagem;
  RECALCULAR_PESO_MEDIO(v_id_lote);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Pesagem ' || p_id_pesagem || ' nao encontrada.');
END EXCLUIR_PESAGEM;
/

-- ===========================================================================
-- Mortalidade
-- ===========================================================================
CREATE OR REPLACE PROCEDURE INSERIR_MORTALIDADE (p_id_lote        IN  NUMBER,
                                                 p_data           IN  DATE,
                                                 p_qtd_morta      IN  NUMBER,
                                                 p_observacao     IN  VARCHAR2,
                                                 p_mort_acumulada OUT NUMBER,
                                                 p_perc_acumulado OUT NUMBER) IS
  r_lote     TAB_LOTE_AVES%ROWTYPE;
  v_ja_morto NUMBER;
  v_id_mort  NUMBER;
BEGIN
  LER_LOTE_FOR_UPDATE(p_id_lote, r_lote);

  IF NVL(p_qtd_morta,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Quantidade morta deve ser maior que zero.');
  END IF;

  v_ja_morto := MORTES_ACUMULADAS(p_id_lote);

  -- Mortes acumuladas + novas nao podem ultrapassar a quantidade inicial.
  IF (v_ja_morto + p_qtd_morta) > r_lote.QUANTIDADE_INICIAL THEN
    RAISE_APPLICATION_ERROR(-20002,
      'Mortalidade acumulada (' || (v_ja_morto + p_qtd_morta) ||
      ') ultrapassa a quantidade inicial do lote (' || r_lote.QUANTIDADE_INICIAL || ').');
  END IF;

  v_id_mort := SEQ_MORTALIDADE.NEXTVAL;

  INSERT INTO TAB_MORTALIDADE (ID_MORTALIDADE, ID_LOTE_FK, DATA_MORTALIDADE, QUANTIDADE_MORTA, OBSERVACAO)
  VALUES (v_id_mort, p_id_lote, NVL(p_data, SYSDATE), p_qtd_morta, p_observacao);

  -- Devolver mortalidade acumulada para o indicador de saude.
  p_mort_acumulada := v_ja_morto + p_qtd_morta;
  p_perc_acumulado := ROUND(p_mort_acumulada * 100 / r_lote.QUANTIDADE_INICIAL, 2);
END INSERIR_MORTALIDADE;
/

CREATE OR REPLACE PROCEDURE ATUALIZAR_MORTALIDADE (p_id_mortalidade IN  NUMBER,
                                                   p_data           IN  DATE,
                                                   p_qtd_morta      IN  NUMBER,
                                                   p_observacao     IN  VARCHAR2,
                                                   p_mort_acumulada OUT NUMBER,
                                                   p_perc_acumulado OUT NUMBER) IS
  r_lote    TAB_LOTE_AVES%ROWTYPE;
  v_id_lote TAB_MORTALIDADE.ID_LOTE_FK%TYPE;
  v_outras  NUMBER;
BEGIN
  SELECT ID_LOTE_FK INTO v_id_lote FROM TAB_MORTALIDADE WHERE ID_MORTALIDADE = p_id_mortalidade;
  LER_LOTE_FOR_UPDATE(v_id_lote, r_lote);

  IF NVL(p_qtd_morta,0) <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Quantidade morta deve ser maior que zero.');
  END IF;

  -- Soma das demais mortalidades (exceto a que esta sendo editada).
  SELECT NVL(SUM(QUANTIDADE_MORTA),0) INTO v_outras
    FROM TAB_MORTALIDADE
   WHERE ID_LOTE_FK = v_id_lote
     AND ID_MORTALIDADE <> p_id_mortalidade;

  IF (v_outras + p_qtd_morta) > r_lote.QUANTIDADE_INICIAL THEN
    RAISE_APPLICATION_ERROR(-20002,
      'Mortalidade acumulada (' || (v_outras + p_qtd_morta) ||
      ') ultrapassa a quantidade inicial do lote (' || r_lote.QUANTIDADE_INICIAL || ').');
  END IF;

  UPDATE TAB_MORTALIDADE
     SET DATA_MORTALIDADE = NVL(p_data, DATA_MORTALIDADE),
         QUANTIDADE_MORTA = p_qtd_morta,
         OBSERVACAO       = p_observacao
   WHERE ID_MORTALIDADE = p_id_mortalidade;

  p_mort_acumulada := v_outras + p_qtd_morta;
  p_perc_acumulado := ROUND(p_mort_acumulada * 100 / r_lote.QUANTIDADE_INICIAL, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Mortalidade ' || p_id_mortalidade || ' nao encontrada.');
END ATUALIZAR_MORTALIDADE;
/

CREATE OR REPLACE PROCEDURE EXCLUIR_MORTALIDADE (p_id_mortalidade IN  NUMBER,
                                                 p_mort_acumulada OUT NUMBER,
                                                 p_perc_acumulado OUT NUMBER) IS
  v_id_lote TAB_MORTALIDADE.ID_LOTE_FK%TYPE;
BEGIN
  SELECT ID_LOTE_FK INTO v_id_lote FROM TAB_MORTALIDADE WHERE ID_MORTALIDADE = p_id_mortalidade;

  DELETE FROM TAB_MORTALIDADE WHERE ID_MORTALIDADE = p_id_mortalidade;

  p_mort_acumulada := MORTES_ACUMULADAS(v_id_lote);
  p_perc_acumulado := PERC_MORTALIDADE(v_id_lote);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'Mortalidade ' || p_id_mortalidade || ' nao encontrada.');
END EXCLUIR_MORTALIDADE;
/

PROMPT >> Procedures e functions criadas com sucesso (sem package).
