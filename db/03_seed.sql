-- =============================================================================
--  Granja - Modulo de Pesagem e Mortalidade de Aves
--  03_seed.sql  -  Dados de exemplo
--
--  Insere 3 lotes via as procedures, com pesagens e mortalidades que deixam cada
--  lote em uma faixa diferente do indicador de saude:
--    LOTE 1  -> mortalidade ~3%   (VERDE   / Saudavel)
--    LOTE 2  -> mortalidade ~8%   (AMARELO / Atencao)
--    LOTE 3  -> mortalidade ~12%  (VERMELHO/ Critico)
-- =============================================================================
SET SERVEROUTPUT ON

DECLARE
  v_id_lote1   NUMBER;
  v_id_lote2   NUMBER;
  v_id_lote3   NUMBER;
  v_id_aux     NUMBER;
  v_acum       NUMBER;
  v_perc       NUMBER;
BEGIN
  -- ---- Lote 1: 10.000 aves ----
  INSERIR_LOTE('Lote Galpao A - Frango de Corte', TRUNC(SYSDATE)-40, 10000, v_id_lote1);
  INSERIR_PESAGEM(v_id_lote1, TRUNC(SYSDATE)-30, 0.85, 100, v_id_aux);
  INSERIR_PESAGEM(v_id_lote1, TRUNC(SYSDATE)-15, 1.95, 100, v_id_aux);
  INSERIR_MORTALIDADE(v_id_lote1, TRUNC(SYSDATE)-25, 180, 'Ajuste de temperatura', v_acum, v_perc);
  INSERIR_MORTALIDADE(v_id_lote1, TRUNC(SYSDATE)-10, 120, 'Refugo natural',        v_acum, v_perc);
  DBMS_OUTPUT.PUT_LINE('Lote 1 (id='||v_id_lote1||') mortalidade acumulada = '||v_perc||'%');

  -- ---- Lote 2: 8.000 aves ----
  INSERIR_LOTE('Lote Galpao B - Frango de Corte', TRUNC(SYSDATE)-35, 8000, v_id_lote2);
  INSERIR_PESAGEM(v_id_lote2, TRUNC(SYSDATE)-20, 1.10, 80, v_id_aux);
  INSERIR_MORTALIDADE(v_id_lote2, TRUNC(SYSDATE)-22, 400, 'Onda de calor',     v_acum, v_perc);
  INSERIR_MORTALIDADE(v_id_lote2, TRUNC(SYSDATE)-12, 240, 'Problema sanitario',v_acum, v_perc);
  DBMS_OUTPUT.PUT_LINE('Lote 2 (id='||v_id_lote2||') mortalidade acumulada = '||v_perc||'%');

  -- ---- Lote 3: 5.000 aves ----
  INSERIR_LOTE('Lote Galpao C - Frango de Corte', TRUNC(SYSDATE)-50, 5000, v_id_lote3);
  INSERIR_PESAGEM(v_id_lote3, TRUNC(SYSDATE)-25, 2.30, 60, v_id_aux);
  INSERIR_MORTALIDADE(v_id_lote3, TRUNC(SYSDATE)-30, 350, 'Estresse de transporte', v_acum, v_perc);
  INSERIR_MORTALIDADE(v_id_lote3, TRUNC(SYSDATE)-18, 250, 'Surto respiratorio',     v_acum, v_perc);
  DBMS_OUTPUT.PUT_LINE('Lote 3 (id='||v_id_lote3||') mortalidade acumulada = '||v_perc||'%');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('>> Seed concluido com sucesso.');
END;
/
