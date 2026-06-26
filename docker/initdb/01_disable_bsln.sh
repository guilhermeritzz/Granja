#!/usr/bin/env bash
# =============================================================================
#  Desabilita o job interno SYS.BSLN_MAINTAIN_STATS_JOB do Oracle XE.
#
#  Esse job tenta atualizar baselines de estatisticas usando o pacote
#  DBSNMP.BSLN_INTERNAL, que NAO vem instalado nas imagens XE. Resultado: a
#  cada start o alert log registra um erro INOFENSIVO:
#     ORA-12012: error on auto execute of job "SYS"."BSLN_MAINTAIN_STATS_JOB"
#     PLS-00201: identifier 'DBSNMP.BSLN_INTERNAL' must be declared
#
#  Nao afeta o schema GRANJA nem o funcionamento do banco. Desabilitamos o job
#  apenas para manter o log limpo nos proximos restarts do container.
#
#  Observacao: o job executa durante o ALTER DATABASE OPEN, ANTES dos scripts
#  de init rodarem. Por isso, no PRIMEIRO boot de um volume novo o erro ainda
#  aparece UMA vez; a partir do segundo start ele nao volta mais.
# =============================================================================

# Best-effort: nunca aborta a inicializacao do container ("|| true").
sqlplus -S -L "SYS/${ORACLE_PASSWORD}@//localhost:1521/XE AS SYSDBA" <<SQL || true
SET ECHO OFF
SET FEEDBACK OFF
BEGIN
  DBMS_SCHEDULER.DISABLE('SYS.BSLN_MAINTAIN_STATS_JOB', force => TRUE);
EXCEPTION
  WHEN OTHERS THEN NULL;  -- job pode nao existir em alguma versao da imagem
END;
/
EXIT
SQL

echo ">> [Granja] Job BSLN_MAINTAIN_STATS_JOB desabilitado (log limpo nos proximos starts)."