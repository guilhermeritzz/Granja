<h1 align="center">Granja</h1>
<p align="center"><strong>Módulo de Pesagem e Mortalidade de Aves</strong></p>

<p align="center">
  <img alt="Delphi 12" src="https://img.shields.io/badge/Delphi-12%20Athens-E62128">
  <img alt="Plataforma" src="https://img.shields.io/badge/Plataforma-Win32-0078D6">
  <img alt="Oracle XE" src="https://img.shields.io/badge/Oracle-XE%2011.2-F80000">
  <img alt="FireDAC" src="https://img.shields.io/badge/Data-FireDAC%20%2F%20OCI-555555">
</p>

Aplicação desktop em **Delphi (VCL)** para o controle de lotes de aves, contemplando o
lançamento de **pesagens** e **mortalidades** com validações de regra de negócio, acesso
a dados via **Stored Procedures PL/SQL** em **Oracle** e um **indicador visual de saúde
do lote** (verde / amarelo / vermelho).

---

## Sumário

- [Visão geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e execução](#instalação-e-execução)
- [Roteiro de teste](#roteiro-de-teste)

---

## Visão geral

| Recurso | Descrição |
|---------|-----------|
| **Gestão de lotes** | Cadastro, edição e listagem de lotes de aves em `DBGrid`. |
| **Pesagem** | Lançamento de pesagens com recálculo automático do peso médio geral do lote. |
| **Mortalidade** | Registro de mortes com cálculo da mortalidade acumulada e do percentual. |
| **Validações em camadas** | Regras aplicadas no cliente (entidades) e **espelhadas** nas procedures. |
| **Indicador de saúde** | Painel colorido conforme a mortalidade acumulada do lote. |

---

## Arquitetura

A aplicação segue uma separação clara de responsabilidades, com a escrita isolada em
Stored Procedures PL/SQL (objetos standalone, sem package):

```
View  →  Data (DataModule)  →  Stored Procedures (PL/SQL)
```

As entidades de `Model` carregam os dados e concentram as validações no cliente, que são
**espelhadas** dentro das procedures, garantindo defesa em camadas. O modelo é usado de
ponta a ponta: além da escrita, a **leitura** também retorna entidades
(`dmGranja.ObterLote/ObterPesagem/ObterMortalidade`), e a regra de faixa de saúde é **única**
(`TLote.ClassificarFaixa`), reaproveitada pelo componente visual — sem limiares duplicados.

```
Granja/
├─ Granja.dpr / Granja.dproj      Projeto Delphi 12 (compilação em Win32)
├─ src/
│  ├─ Model/                      Entidades de negócio (POO + herança)
│  │   ├─ uEntidadeBase.pas       TEntidadeBase / TLancamentoLote (abstratas)
│  │   ├─ uLote.pas               TLote (regra única de faixa: ClassificarFaixa)
│  │   ├─ uPesagem.pas            TPesagem (valida qtd. pesada × inicial)
│  │   └─ uMortalidade.pas        TMortalidade (valida acumulado × inicial)
│  ├─ Components/
│  │   └─ uIndicadorSaude.pas     TIndicadorSaudeLote (TPanel; reusa ClassificarFaixa)
│  ├─ Data/
│  │   ├─ uConfig.pas             Leitura da conexão a partir do Granja.ini
│  │   └─ uDataModule.pas/.dfm    DataModule FireDAC: selects de leitura (grids) +
│  │                              escrita via Stored Procedures e leitura por entidade (Obter*)
│  └─ View/
│      └─ uFrmPrincipal.pas/.dfm  Tela principal — PageControl com 3 abas
├─ db/
│  ├─ 01_schema.sql               Tabelas, sequences e constraints
│  ├─ 02_procedures.sql           Stored Procedures e Functions (standalone, sem package)
│  └─ 03_seed.sql                 Dados de exemplo
├─ docker/
│  ├─ docker-compose.yml          Oracle XE 11.2 (gvenzl/oracle-xe:11-slim)
│  ├─ .env.example                Variáveis de ambiente (copiar para .env)
│  └─ initdb/00_run_all.sh        Criação do schema sob o usuário GRANJA
└─ config/
   └─ Granja.ini.example          Modelo de configuração de conexão
```

---

## Pré-requisitos

| Item | Observação |
|------|------------|
| **Docker Desktop** | Para subir o Oracle XE 11.2. |
| **Delphi 12 (Athens)** | Compilação do projeto na plataforma **Win32**. |
| **Oracle Instant Client 32 bits 11.2** | Já incluído na pasta `instantClient` deste repositório. |

> [!WARNING]
> **Arquitetura 32 bits.** O Instant Client fornecido é de **32 bits (11.2)**. Por isso,
> a aplicação **deve ser compilada e executada em Win32**. Um build Win64 não conseguirá
> carregar o `oci.dll` e não estabelecerá a conexão.

---

## Instalação e execução

### 1. Subir o banco de dados (Oracle no Docker)

```bash
cd Granja/docker
copy .env.example .env      # Windows (ou: cp .env.example .env)
docker compose up -d
```

Acompanhe a inicialização — o primeiro start cria o banco e executa os scripts:

```bash
docker logs -f granja-oracle
```

Aguarde as mensagens de saúde do banco e a linha de confirmação:

```
>> [Granja] Schema criado com sucesso (tabelas, procedures/functions e seed).
```

O container expõe a porta **1521**, cria o usuário **GRANJA** e executa automaticamente
`01_schema.sql`, `02_procedures.sql` e `03_seed.sql`.

> [!TIP]
> **Conferência rápida (opcional):**
> ```bash
> docker exec -it granja-oracle sqlplus GRANJA/granja123@//localhost:1521/XE
> SQL> SELECT table_name FROM user_tables;
> SQL> SELECT id_lote, descricao, quantidade_inicial, peso_medio_geral FROM tab_lote_aves;
> ```

### 2. Preparar o Oracle Instant Client (TNS)

Copie a pasta do client para **`C:\app\instantClient`**, de modo que o caminho do TNS
fique exatamente:

```
C:\app\instantClient\network\admin\tnsnames.ora
```

No Windows, a partir da raiz do repositório:

```powershell
xcopy /E /I /Y instantClient\instantClient C:\app\instantClient
```

O `tnsnames.ora` fornecido **já contém** a entrada utilizada pela aplicação:

```
GRANJA =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE)
    )
  )
```

### 3. Configurar o aplicativo (`Granja.ini`)

Copie o modelo para a **pasta onde o executável será gerado** e renomeie para
`Granja.ini`. Para a configuração padrão (Debug/Win32):

```powershell
mkdir Granja\Win32\Debug 2> NUL
copy config\Granja.ini.example Granja\Win32\Debug\Granja.ini
```

Conteúdo padrão (ajuste conforme necessário):

```ini
[Database]
Server   = GRANJA            ; alias do tnsnames.ora
User     = GRANJA
Password = granja123

[Oracle]
OCIPath  = C:\app\instantClient\oci.dll
TNSAdmin = C:\app\instantClient\network\admin
```

> [!NOTE]
> Alternativa sem tnsnames (EZConnect): substitua por `Server = localhost:1521/XE`.

### 4. Compilar e executar

1. Abra **`Granja\Granja.dproj`** no Delphi 12.
2. Selecione a plataforma **Win32** e a configuração **Debug** (ou Release).
3. Execute com **Run** (F9). O Delphi gera o `Granja.res` na primeira compilação.

---

## Roteiro de teste

| # | Passo | Resultado esperado |
|---|-------|--------------------|
| 1 | **Lista de lotes** | A aba *Lista* abre com os 3 lotes do seed. |
| 2 | **Incluir lote** — `Incluir` → Descrição / Data / Qtde. Inicial → `Gravar` | Lote criado. Para editar, **duplo-clique** na linha do grid. |
| 3 | **Pesagem** — selecione um lote → *Pesagem* → `Incluir` → Data / Peso Médio / Qtde. Pesada → `Gravar` | Peso Médio Geral recalculado. *Qtde. Pesada* > *Qtde. Inicial* é bloqueada (`ORA-20001`). |
| 4 | **Mortalidade** — *Mortalidade* → `Incluir` → Data / Qtde. Morta / Observação → `Gravar` | Exceder a *Qtde. Inicial* é bloqueado (`ORA-20002`). |
| 5 | **Indicador de saúde** | Cor conforme a mortalidade acumulada: **verde** (< 5%), **amarelo** (5%–10%), **vermelho** (> 10%). |

> [!NOTE]
> Os botões respeitam o estado da operação: durante uma inclusão/edição, apenas
> `Gravar`/`Cancelar` ficam ativos; em navegação, `Incluir`/`Excluir`. O `Atualizar`
> faz refresh do grid (há também auto-refresh após gravar/excluir).
