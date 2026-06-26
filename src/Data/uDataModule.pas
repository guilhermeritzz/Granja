unit uDataModule;

{ -----------------------------------------------------------------------------
  DataModule de acesso a dados 
  ----------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Classes, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.Oracle, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.UI,
  FireDAC.Comp.Client,
  FireDAC.Phys.OracleDef, FireDAC.Comp.DataSet,
  uLote, uPesagem, uMortalidade;

type
  TDataModuleGranja = class(TDataModule)
    FDConnection1: TFDConnection;
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    qryLotes: TFDQuery;
    dsLotes: TDataSource;
    qryPesagens: TFDQuery;
    dsPesagens: TDataSource;
    qryMortalidades: TFDQuery;
    dsMortalidades: TDataSource;
    qryLotesID_LOTE: TFMTBCDField;
    qryLotesDESCRICAO: TStringField;
    qryLotesDATA_ENTRADA: TDateTimeField;
    qryLotesQUANTIDADE_INICIAL: TFMTBCDField;
    qryLotesPESO_MEDIO_GERAL: TBCDField;
    qryPesagensID_PESAGEM: TFMTBCDField;
    qryPesagensDATA_PESAGEM: TDateTimeField;
    qryPesagensPESO_MEDIO: TBCDField;
    qryPesagensQUANTIDADE_PESADA: TFMTBCDField;
    qryMortalidadesID_MORTALIDADE: TFMTBCDField;
    qryMortalidadesDATA_MORTALIDADE: TDateTimeField;
    qryMortalidadesQUANTIDADE_MORTA: TFMTBCDField;
    qryMortalidadesOBSERVACAO: TStringField;
  private
    { Cria um TFDQuery transitorio ligado a conexao (o chamador o libera). }
    function NovoComando: TFDQuery;
  public
    procedure Conectar;
    function Conectado: Boolean;

    // ---- Leitura para os grids (SQL no design-time) ----
    procedure AbrirLotes;
    procedure AbrirPesagens(AIdLote: Integer);
    procedure AbrirMortalidades(AIdLote: Integer);

    // ---- Lote ----
    function InserirLote(ALote: TLote): Integer;
    procedure AtualizarLote(ALote: TLote);
    procedure ExcluirLote(AIdLote: Integer);
    { Leitura por entidade (o chamador e dono do objeto e deve liberar). }
    function ObterLote(AIdLote: Integer): TLote;

    // ---- Pesagem ----
    function InserirPesagem(APesagem: TPesagem): Integer;
    procedure AtualizarPesagem(APesagem: TPesagem);
    procedure ExcluirPesagem(AIdPesagem: Integer);
    function ObterPesagem(AIdPesagem: Integer): TPesagem;

    // ---- Mortalidade (retorna o acumulado para o indicador de saude) ----
    procedure InserirMortalidade(AMort: TMortalidade; out AAcumulada: Integer; out APercentual: Double);
    procedure AtualizarMortalidade(AMort: TMortalidade; out AAcumulada: Integer; out APercentual: Double);
    procedure ExcluirMortalidade(AIdMortalidade: Integer; out AAcumulada: Integer; out APercentual: Double);
    function ObterMortalidade(AIdMortalidade: Integer): TMortalidade;

    // ---- Apoio ----
    function MortesAcumuladas(AIdLote: Integer): Integer;
    { Mortes do lote desconsiderando um registro (usado na edicao de mortalidade). }
    function MortesAcumuladasExceto(AIdLote, AIdMortalidade: Integer): Integer;
    function PercMortalidade(AIdLote: Integer): Double;
  end;

var
  dmGranja: TDataModuleGranja;

implementation

{$R *.dfm}

uses
  Winapi.Windows, uConfig;

{ ----------------------------- Conexao ----------------------------------- }

procedure TDataModuleGranja.Conectar;
var
  Cfg: TConfiguracao;
begin
  Cfg := TConfig.Carregar;

  // OCI 32 bits e localizacao do tnsnames.ora.
  if Cfg.TNSAdmin <> '' then
    SetEnvironmentVariable('TNS_ADMIN', PChar(Cfg.TNSAdmin));
  if Cfg.OCIPath <> '' then
    FDPhysOracleDriverLink1.VendorLib := Cfg.OCIPath;

  FDConnection1.Connected := False;
  FDConnection1.Params.Clear;
  FDConnection1.Params.DriverID := 'Ora';
  FDConnection1.Params.Database := Cfg.Server;     // alias TNS ou EZConnect
  FDConnection1.Params.UserName := Cfg.User;
  FDConnection1.Params.Password := Cfg.Password;
  FDConnection1.LoginPrompt := False;
  FDConnection1.Connected := True;
end;

function TDataModuleGranja.Conectado: Boolean;
begin
  Result := FDConnection1.Connected;
end;

function TDataModuleGranja.NovoComando: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FDConnection1;
end;

{ ----------------------------- Leitura (grids) --------------------------- }

procedure TDataModuleGranja.AbrirLotes;
begin
  // SQL definido no design-time (propriedade SQL da query).
  qryLotes.Close;
  qryLotes.Open;
end;

procedure TDataModuleGranja.AbrirPesagens(AIdLote: Integer);
begin
  // SQL definido no design-time; aqui so passa o parametro do lote.
  qryPesagens.Close;
  qryPesagens.ParamByName('id').AsInteger := AIdLote;
  qryPesagens.Open;
end;

procedure TDataModuleGranja.AbrirMortalidades(AIdLote: Integer);
begin
  // SQL definido no design-time; aqui so passa o parametro do lote.
  qryMortalidades.Close;
  qryMortalidades.ParamByName('id').AsInteger := AIdLote;
  qryMortalidades.Open;
end;

{ ----------------------------- Lote -------------------------------------- }

function TDataModuleGranja.InserirLote(ALote: TLote): Integer;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'BEGIN INSERIR_LOTE(:p_desc, :p_data, :p_qtd, :p_id); END;';
    Q.ParamByName('p_desc').AsString    := ALote.Descricao;
    Q.ParamByName('p_data').AsDateTime  := ALote.DataEntrada;
    Q.ParamByName('p_qtd').AsInteger    := ALote.QuantidadeInicial;
    Q.ParamByName('p_id').ParamType     := ptOutput;
    Q.ParamByName('p_id').DataType      := ftInteger;
    Q.ExecSQL;
    Result := Q.ParamByName('p_id').AsInteger;
  finally
    Q.Free;
  end;
end;

procedure TDataModuleGranja.AtualizarLote(ALote: TLote);
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'BEGIN ATUALIZAR_LOTE(:p_id, :p_desc, :p_data, :p_qtd); END;';
    Q.ParamByName('p_id').AsInteger    := ALote.Id;
    Q.ParamByName('p_desc').AsString   := ALote.Descricao;
    Q.ParamByName('p_data').AsDateTime := ALote.DataEntrada;
    Q.ParamByName('p_qtd').AsInteger   := ALote.QuantidadeInicial;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TDataModuleGranja.ExcluirLote(AIdLote: Integer);
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text := 'BEGIN EXCLUIR_LOTE(:p_id); END;';
    Q.ParamByName('p_id').AsInteger := AIdLote;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TDataModuleGranja.ObterLote(AIdLote: Integer): TLote;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'SELECT ID_LOTE, DESCRICAO, DATA_ENTRADA, QUANTIDADE_INICIAL, PESO_MEDIO_GERAL ' +
      '  FROM TAB_LOTE_AVES WHERE ID_LOTE = :p_id';
    Q.ParamByName('p_id').AsInteger := AIdLote;
    Q.Open;
    if Q.IsEmpty then
      raise Exception.CreateFmt('Lote %d nao encontrado.', [AIdLote]);

    Result := TLote.Create;
    Result.Id                := Q.FieldByName('ID_LOTE').AsInteger;
    Result.Descricao         := Q.FieldByName('DESCRICAO').AsString;
    Result.DataEntrada       := Q.FieldByName('DATA_ENTRADA').AsDateTime;
    Result.QuantidadeInicial := Q.FieldByName('QUANTIDADE_INICIAL').AsInteger;
    Result.PesoMedioGeral    := Q.FieldByName('PESO_MEDIO_GERAL').AsFloat;
    Result.MortesAcumuladas  := MortesAcumuladas(AIdLote);
  finally
    Q.Free;
  end;
end;

{ ----------------------------- Pesagem ----------------------------------- }

function TDataModuleGranja.InserirPesagem(APesagem: TPesagem): Integer;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'BEGIN INSERIR_PESAGEM(:p_id_lote, :p_data, :p_peso, :p_qtd, :p_id); END;';
    Q.ParamByName('p_id_lote').AsInteger := APesagem.IdLote;
    Q.ParamByName('p_data').AsDateTime   := APesagem.Data;
    Q.ParamByName('p_peso').AsFloat      := APesagem.PesoMedio;
    Q.ParamByName('p_qtd').AsInteger     := APesagem.QuantidadePesada;
    Q.ParamByName('p_id').ParamType      := ptOutput;
    Q.ParamByName('p_id').DataType       := ftInteger;
    Q.ExecSQL;
    Result := Q.ParamByName('p_id').AsInteger;
  finally
    Q.Free;
  end;
end;

procedure TDataModuleGranja.AtualizarPesagem(APesagem: TPesagem);
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'BEGIN ATUALIZAR_PESAGEM(:p_id, :p_data, :p_peso, :p_qtd); END;';
    Q.ParamByName('p_id').AsInteger    := APesagem.Id;
    Q.ParamByName('p_data').AsDateTime := APesagem.Data;
    Q.ParamByName('p_peso').AsFloat    := APesagem.PesoMedio;
    Q.ParamByName('p_qtd').AsInteger   := APesagem.QuantidadePesada;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TDataModuleGranja.ExcluirPesagem(AIdPesagem: Integer);
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text := 'BEGIN EXCLUIR_PESAGEM(:p_id); END;';
    Q.ParamByName('p_id').AsInteger := AIdPesagem;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TDataModuleGranja.ObterPesagem(AIdPesagem: Integer): TPesagem;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    // Traz tambem a quantidade inicial do lote, deixando a entidade pronta
    // para revalidar sem depender da tela.
    Q.SQL.Text :=
      'SELECT P.ID_PESAGEM, P.ID_LOTE_FK, P.DATA_PESAGEM, P.PESO_MEDIO, ' +
      '       P.QUANTIDADE_PESADA, L.QUANTIDADE_INICIAL ' +
      '  FROM TAB_PESAGEM P ' +
      '  JOIN TAB_LOTE_AVES L ON L.ID_LOTE = P.ID_LOTE_FK ' +
      ' WHERE P.ID_PESAGEM = :p_id';
    Q.ParamByName('p_id').AsInteger := AIdPesagem;
    Q.Open;
    if Q.IsEmpty then
      raise Exception.CreateFmt('Pesagem %d nao encontrada.', [AIdPesagem]);

    Result := TPesagem.Create;
    Result.Id                    := Q.FieldByName('ID_PESAGEM').AsInteger;
    Result.IdLote                := Q.FieldByName('ID_LOTE_FK').AsInteger;
    Result.Data                  := Q.FieldByName('DATA_PESAGEM').AsDateTime;
    Result.PesoMedio             := Q.FieldByName('PESO_MEDIO').AsFloat;
    Result.QuantidadePesada      := Q.FieldByName('QUANTIDADE_PESADA').AsInteger;
    Result.QuantidadeInicialLote := Q.FieldByName('QUANTIDADE_INICIAL').AsInteger;
  finally
    Q.Free;
  end;
end;

{ --------------------------- Mortalidade --------------------------------- }

procedure TDataModuleGranja.InserirMortalidade(AMort: TMortalidade;
  out AAcumulada: Integer; out APercentual: Double);
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'BEGIN INSERIR_MORTALIDADE(:p_id_lote, :p_data, :p_qtd, :p_obs, :p_acum, :p_perc); END;';
    Q.ParamByName('p_id_lote').AsInteger := AMort.IdLote;
    Q.ParamByName('p_data').AsDateTime   := AMort.Data;
    Q.ParamByName('p_qtd').AsInteger     := AMort.QuantidadeMorta;
    Q.ParamByName('p_obs').AsString      := AMort.Observacao;
    Q.ParamByName('p_acum').ParamType    := ptOutput;
    Q.ParamByName('p_acum').DataType     := ftInteger;
    Q.ParamByName('p_perc').ParamType    := ptOutput;
    Q.ParamByName('p_perc').DataType     := ftFloat;
    Q.ExecSQL;
    AAcumulada  := Q.ParamByName('p_acum').AsInteger;
    APercentual := Q.ParamByName('p_perc').AsFloat;
  finally
    Q.Free;
  end;
end;

procedure TDataModuleGranja.AtualizarMortalidade(AMort: TMortalidade;
  out AAcumulada: Integer; out APercentual: Double);
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'BEGIN ATUALIZAR_MORTALIDADE(:p_id, :p_data, :p_qtd, :p_obs, :p_acum, :p_perc); END;';
    Q.ParamByName('p_id').AsInteger    := AMort.Id;
    Q.ParamByName('p_data').AsDateTime := AMort.Data;
    Q.ParamByName('p_qtd').AsInteger   := AMort.QuantidadeMorta;
    Q.ParamByName('p_obs').AsString    := AMort.Observacao;
    Q.ParamByName('p_acum').ParamType  := ptOutput;
    Q.ParamByName('p_acum').DataType   := ftInteger;
    Q.ParamByName('p_perc').ParamType  := ptOutput;
    Q.ParamByName('p_perc').DataType   := ftFloat;
    Q.ExecSQL;
    AAcumulada  := Q.ParamByName('p_acum').AsInteger;
    APercentual := Q.ParamByName('p_perc').AsFloat;
  finally
    Q.Free;
  end;
end;

procedure TDataModuleGranja.ExcluirMortalidade(AIdMortalidade: Integer;
  out AAcumulada: Integer; out APercentual: Double);
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'BEGIN EXCLUIR_MORTALIDADE(:p_id, :p_acum, :p_perc); END;';
    Q.ParamByName('p_id').AsInteger   := AIdMortalidade;
    Q.ParamByName('p_acum').ParamType := ptOutput;
    Q.ParamByName('p_acum').DataType  := ftInteger;
    Q.ParamByName('p_perc').ParamType := ptOutput;
    Q.ParamByName('p_perc').DataType  := ftFloat;
    Q.ExecSQL;
    AAcumulada  := Q.ParamByName('p_acum').AsInteger;
    APercentual := Q.ParamByName('p_perc').AsFloat;
  finally
    Q.Free;
  end;
end;

function TDataModuleGranja.ObterMortalidade(AIdMortalidade: Integer): TMortalidade;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text :=
      'SELECT M.ID_MORTALIDADE, M.ID_LOTE_FK, M.DATA_MORTALIDADE, ' +
      '       M.QUANTIDADE_MORTA, M.OBSERVACAO, L.QUANTIDADE_INICIAL ' +
      '  FROM TAB_MORTALIDADE M ' +
      '  JOIN TAB_LOTE_AVES L ON L.ID_LOTE = M.ID_LOTE_FK ' +
      ' WHERE M.ID_MORTALIDADE = :p_id';
    Q.ParamByName('p_id').AsInteger := AIdMortalidade;
    Q.Open;
    if Q.IsEmpty then
      raise Exception.CreateFmt('Mortalidade %d nao encontrada.', [AIdMortalidade]);

    Result := TMortalidade.Create;
    Result.Id                    := Q.FieldByName('ID_MORTALIDADE').AsInteger;
    Result.IdLote                := Q.FieldByName('ID_LOTE_FK').AsInteger;
    Result.Data                  := Q.FieldByName('DATA_MORTALIDADE').AsDateTime;
    Result.QuantidadeMorta       := Q.FieldByName('QUANTIDADE_MORTA').AsInteger;
    Result.Observacao            := Q.FieldByName('OBSERVACAO').AsString;
    Result.QuantidadeInicialLote := Q.FieldByName('QUANTIDADE_INICIAL').AsInteger;
    // Mortes ja registradas no lote, desconsiderando este proprio registro.
    Result.MortesJaRegistradas   := MortesAcumuladasExceto(Result.IdLote, Result.Id);
  finally
    Q.Free;
  end;
end;

{ ----------------------------- Apoio ------------------------------------- }

function TDataModuleGranja.MortesAcumuladas(AIdLote: Integer): Integer;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text := 'SELECT MORTES_ACUMULADAS(:p_id) AS V FROM DUAL';
    Q.ParamByName('p_id').AsInteger := AIdLote;
    Q.Open;
    Result := Q.FieldByName('V').AsInteger;
  finally
    Q.Free;
  end;
end;

function TDataModuleGranja.MortesAcumuladasExceto(AIdLote, AIdMortalidade: Integer): Integer;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text := 'SELECT MORTES_ACUMULADAS_EXCETO(:p_lote, :p_mort) AS V FROM DUAL';
    Q.ParamByName('p_lote').AsInteger := AIdLote;
    Q.ParamByName('p_mort').AsInteger := AIdMortalidade;
    Q.Open;
    Result := Q.FieldByName('V').AsInteger;
  finally
    Q.Free;
  end;
end;

function TDataModuleGranja.PercMortalidade(AIdLote: Integer): Double;
var
  Q: TFDQuery;
begin
  Q := NovoComando;
  try
    Q.SQL.Text := 'SELECT PERC_MORTALIDADE(:p_id) AS V FROM DUAL';
    Q.ParamByName('p_id').AsInteger := AIdLote;
    Q.Open;
    Result := Q.FieldByName('V').AsFloat;
  finally
    Q.Free;
  end;
end;

end.
