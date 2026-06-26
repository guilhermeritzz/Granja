#!/usr/bin/env bash
# =============================================================================
#  Executado automaticamente pela imagem gvenzl/oracle-xe no PRIMEIRO start,
#  depois que o usuario da aplicacao (APP_USER = GRANJA) ja foi criado.
#
#  Conecta explicitamente como o usuario da aplicacao e cria os objetos na
#  ordem correta, garantindo que tabelas/procedures pertencam ao schema GRANJA
#  (independente de como a imagem executa scripts .sql avulsos).
# =============================================================================
set -e

DB_DIR="/opt/granja/db"
echo ">> [Granja] Criando schema como usuario ${APP_USER} ..."

sqlplus -S -L "${APP_USER}/${APP_USER_PASSWORD}@//localhost:1521/XE" <<SQL
WHENEVER SQLERROR EXIT SQL.SQLCODE
SET DEFINE OFF
SET ECHO OFF
@${DB_DIR}/01_schema.sql
@${DB_DIR}/02_procedures.sql
@${DB_DIR}/03_seed.sql
EXIT
SQL

echo ">> [Granja] Schema criado com sucesso (tabelas, procedures/functions e seed)."
