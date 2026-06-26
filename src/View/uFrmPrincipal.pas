unit uFrmPrincipal;

{ -----------------------------------------------------------------------------
Cada aba possui sua propria maquina de estados (Navegacao / Inclusao / Edicao)
  que habilita/desabilita os botoes e campos conforme a acao em andamento.
  Todas as gravacoes passam pelas Stored Procedures (via dmGranja).
  ----------------------------------------------------------------------------- }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB,
  uDataModule,
  uEntidadeBase, uLote, uPesagem, uMortalidade, uIndicadorSaude;

type
  TModoEdicao = (meNavegacao, meInclusao, meEdicao);

  TFrmPrincipal = class(TForm)
    PageControl1: TPageControl;
    tabLista: TTabSheet;
    tabPesagem: TTabSheet;
    tabMortalidade: TTabSheet;

    // ---- Aba Lista ----
    pnlBarraLista: TPanel;
    btnLoteIncluir: TButton;
    btnLoteExcluir: TButton;
    btnLoteGravar: TButton;
    btnLoteCancelar: TButton;
    gridLotes: TDBGrid;
    pnlLoteDados: TPanel;
    lblLoteId: TLabel;
    edtLoteId: TEdit;
    lblLoteDescricao: TLabel;
    edtLoteDescricao: TEdit;
    lblLoteEntrada: TLabel;
    dtpLoteEntrada: TDateTimePicker;
    lblLoteQtd: TLabel;
    edtLoteQtdInicial: TEdit;
    lblLotePeso: TLabel;
    edtLotePesoMedio: TEdit;

    // ---- Aba Pesagem ----
    pnlCabPesagem: TPanel;
    lblPesLoteId: TLabel;
    edtPesLoteId: TEdit;
    lblPesLoteDesc: TLabel;
    edtPesLoteDesc: TEdit;
    lblPesLoteEntrada: TLabel;
    edtPesLoteEntrada: TEdit;
    lblPesLoteQtd: TLabel;
    edtPesLoteQtd: TEdit;
    pnlBarraPesagem: TPanel;
    btnPesIncluir: TButton;
    btnPesExcluir: TButton;
    btnPesGravar: TButton;
    btnPesCancelar: TButton;
    btnPesAtualizar: TButton;
    gridPesagens: TDBGrid;
    pnlPesEdit: TPanel;
    lblPesData: TLabel;
    dtpPesData: TDateTimePicker;
    lblPesPeso: TLabel;
    edtPesPeso: TEdit;
    lblPesQtd: TLabel;
    edtPesQtd: TEdit;

    // ---- Aba Mortalidade ----
    pnlCabMort: TPanel;
    lblMortLoteId: TLabel;
    edtMortLoteId: TEdit;
    lblMortLoteDesc: TLabel;
    edtMortLoteDesc: TEdit;
    lblMortLoteEntrada: TLabel;
    edtMortLoteEntrada: TEdit;
    lblMortLoteQtd: TLabel;
    edtMortLoteQtd: TEdit;
    pnlBarraMort: TPanel;
    btnMortIncluir: TButton;
    btnMortExcluir: TButton;
    btnMortGravar: TButton;
    btnMortCancelar: TButton;
    btnMortAtualizar: TButton;
    gridMortalidades: TDBGrid;
    pnlMortEdit: TPanel;
    lblMortData: TLabel;
    dtpMortData: TDateTimePicker;
    lblMortQtd: TLabel;
    edtMortQtd: TEdit;
    lblMortObs: TLabel;
    edtMortObs: TEdit;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
    // Lote
    procedure btnLoteIncluirClick(Sender: TObject);
    procedure btnLoteExcluirClick(Sender: TObject);
    procedure btnLoteGravarClick(Sender: TObject);
    procedure btnLoteCancelarClick(Sender: TObject);
    procedure gridLotesDblClick(Sender: TObject);
    // Pesagem
    procedure btnPesIncluirClick(Sender: TObject);
    procedure btnPesExcluirClick(Sender: TObject);
    procedure btnPesGravarClick(Sender: TObject);
    procedure btnPesCancelarClick(Sender: TObject);
    procedure btnPesAtualizarClick(Sender: TObject);
    procedure gridPesagensDblClick(Sender: TObject);
    // Mortalidade
    procedure btnMortIncluirClick(Sender: TObject);
    procedure btnMortExcluirClick(Sender: TObject);
    procedure btnMortGravarClick(Sender: TObject);
    procedure btnMortCancelarClick(Sender: TObject);
    procedure btnMortAtualizarClick(Sender: TObject);
    procedure gridMortalidadesDblClick(Sender: TObject);
  private
    FLoteAtual: TLote;
    FModoLista: TModoEdicao;
    FModoPesagem: TModoEdicao;
    FModoMortalidade: TModoEdicao;
    FIdPesagemEdit: Integer;
    FIdMortEdit: Integer;
    FIndLista: TIndicadorSaudeLote;
    FIndMort: TIndicadorSaudeLote;

    procedure dsLotesDataChange(Sender: TObject; Field: TField);

    function LoteSelecionado: Boolean;
    procedure CarregarLoteAtual;
    procedure AtualizarIndicadores;
    procedure PreencherCabecalhos;
    procedure LimparCabecalhos;
    procedure PreencherEditLote;

    procedure SetModoLista(AModo: TModoEdicao);
    procedure SetModoPesagem(AModo: TModoEdicao);
    procedure SetModoMortalidade(AModo: TModoEdicao);

    function StrParaPeso(const S: string): Double;
    function EntidadeValida(AEntidade: TEntidadeBase): Boolean;
    procedure Erro(const AMsg: string);
    procedure Aviso(const AMsg: string);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

{ ================================ Infra =================================== }

procedure TFrmPrincipal.Erro(const AMsg: string);
begin
  MessageDlg(AMsg, mtError, [mbOK], 0);
end;

procedure TFrmPrincipal.Aviso(const AMsg: string);
begin
  MessageDlg(AMsg, mtWarning, [mbOK], 0);
end;

function TFrmPrincipal.EntidadeValida(AEntidade: TEntidadeBase): Boolean;
var
  Msg: string;
begin
  Result := AEntidade.Validar(Msg);
  if not Result then
    Aviso(Msg);
end;

function TFrmPrincipal.StrParaPeso(const S: string): Double;
var
  fs: TFormatSettings;
  T: string;
begin
  fs := TFormatSettings.Create;
  T := Trim(S);
  T := StringReplace(T, '.', fs.DecimalSeparator, [rfReplaceAll]);
  T := StringReplace(T, ',', fs.DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(T, 0, fs);
end;

{ ============================== Ciclo de vida ============================= }

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FLoteAtual := TLote.Create;
  gridLotes.DataSource        := dmGranja.dsLotes;
  gridPesagens.DataSource     := dmGranja.dsPesagens;
  gridMortalidades.DataSource := dmGranja.dsMortalidades;
  FIndLista := TIndicadorSaudeLote.Create(Self);
  FIndLista.Parent := pnlLoteDados;
  FIndLista.SetBounds(pnlLoteDados.Width - 290, 18, 270, 64);
  FIndLista.Anchors := [akTop, akRight];

  FIndMort := TIndicadorSaudeLote.Create(Self);
  FIndMort.Parent := pnlCabMort;
  FIndMort.SetBounds(pnlCabMort.Width - 290, 12, 270, 48);
  FIndMort.Anchors := [akTop, akRight];

  try
    dmGranja.Conectar;
    dmGranja.AbrirLotes;
  except
    on E: Exception do
      Erro('Falha ao conectar no banco de dados:'#13#10 + E.Message);
  end;

  dmGranja.dsLotes.OnDataChange := dsLotesDataChange;

  SetModoLista(meNavegacao);
  SetModoPesagem(meNavegacao);
  SetModoMortalidade(meNavegacao);
  CarregarLoteAtual;

  // Sempre inicia na aba Lista.
  PageControl1.ActivePage := tabLista;
end;

procedure TFrmPrincipal.FormDestroy(Sender: TObject);
begin
  FLoteAtual.Free;
end;

{ ============================== Lote selecionado ========================= }

function TFrmPrincipal.LoteSelecionado: Boolean;
begin
  Result := dmGranja.qryLotes.Active and (not dmGranja.qryLotes.IsEmpty);
end;

procedure TFrmPrincipal.dsLotesDataChange(Sender: TObject; Field: TField);
begin
  // So recarrega quando esta navegando (nao durante uma edicao de lote).
  if FModoLista = meNavegacao then
    CarregarLoteAtual;
end;

procedure TFrmPrincipal.CarregarLoteAtual;
var
  Id: Integer;
begin
  if not LoteSelecionado then
  begin
    FreeAndNil(FLoteAtual);
    FLoteAtual := TLote.Create;          // mantem FLoteAtual sempre valido
    FIndLista.Limpar;
    FIndMort.Limpar;
    LimparCabecalhos;
    edtLoteId.Clear;
    edtLoteDescricao.Clear;
    edtLoteQtdInicial.Clear;
    edtLotePesoMedio.Clear;
    Exit;
  end;

  // Le o lote selecionado como entidade (regra/estado vem do repositorio).
  Id := dmGranja.qryLotes.FieldByName('ID_LOTE').AsInteger;
  FreeAndNil(FLoteAtual);
  FLoteAtual := dmGranja.ObterLote(Id);

  PreencherEditLote;
  PreencherCabecalhos;
  AtualizarIndicadores;

  btnLoteExcluir.Enabled := FModoLista = meNavegacao;
end;

procedure TFrmPrincipal.AtualizarIndicadores;
begin
  FIndLista.CarregarDeLote(FLoteAtual);
  FIndMort.CarregarDeLote(FLoteAtual);
end;

procedure TFrmPrincipal.PreencherEditLote;
begin
  edtLoteId.Text         := IntToStr(FLoteAtual.Id);
  edtLoteDescricao.Text  := FLoteAtual.Descricao;
  dtpLoteEntrada.Date    := FLoteAtual.DataEntrada;
  edtLoteQtdInicial.Text := IntToStr(FLoteAtual.QuantidadeInicial);
  edtLotePesoMedio.Text  := FormatFloat('0.00', FLoteAtual.PesoMedioGeral);
end;

procedure TFrmPrincipal.PreencherCabecalhos;
begin
  edtPesLoteId.Text       := IntToStr(FLoteAtual.Id);
  edtPesLoteDesc.Text     := FLoteAtual.Descricao;
  edtPesLoteEntrada.Text  := DateToStr(FLoteAtual.DataEntrada);
  edtPesLoteQtd.Text      := IntToStr(FLoteAtual.QuantidadeInicial);

  edtMortLoteId.Text      := IntToStr(FLoteAtual.Id);
  edtMortLoteDesc.Text    := FLoteAtual.Descricao;
  edtMortLoteEntrada.Text := DateToStr(FLoteAtual.DataEntrada);
  edtMortLoteQtd.Text     := IntToStr(FLoteAtual.QuantidadeInicial);
end;

procedure TFrmPrincipal.LimparCabecalhos;
begin
  edtPesLoteId.Clear;  edtPesLoteDesc.Clear;  edtPesLoteEntrada.Clear;  edtPesLoteQtd.Clear;
  edtMortLoteId.Clear; edtMortLoteDesc.Clear; edtMortLoteEntrada.Clear; edtMortLoteQtd.Clear;
end;

{ ============================== Troca de aba ============================= }

procedure TFrmPrincipal.PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
begin
  // Nao permite trocar de aba com uma inclusao/edicao em andamento.
  AllowChange := (FModoLista = meNavegacao) and
                 (FModoPesagem = meNavegacao) and
                 (FModoMortalidade = meNavegacao);
  if not AllowChange then
    Aviso('Conclua ou cancele a operacao em andamento antes de trocar de aba.');
end;

procedure TFrmPrincipal.PageControl1Change(Sender: TObject);
begin
  if (PageControl1.ActivePage = tabPesagem) or (PageControl1.ActivePage = tabMortalidade) then
  begin
    if not LoteSelecionado then
    begin
      Aviso('Selecione um lote na aba Lista antes de lancar pesagens/mortalidades.');
      PageControl1.ActivePage := tabLista;
      Exit;
    end;
    PreencherCabecalhos;
    if PageControl1.ActivePage = tabPesagem then
      dmGranja.AbrirPesagens(FLoteAtual.Id)
    else
      dmGranja.AbrirMortalidades(FLoteAtual.Id);
  end;
end;

{ ================================ Aba Lista ============================== }

procedure TFrmPrincipal.SetModoLista(AModo: TModoEdicao);
var
  Edicao: Boolean;
begin
  FModoLista := AModo;
  Edicao := AModo in [meInclusao, meEdicao];

  edtLoteDescricao.Enabled  := Edicao;
  dtpLoteEntrada.Enabled    := Edicao;
  edtLoteQtdInicial.Enabled := Edicao;
  gridLotes.Enabled         := not Edicao;

  btnLoteIncluir.Enabled  := not Edicao;
  btnLoteExcluir.Enabled  := (not Edicao) and LoteSelecionado;
  btnLoteGravar.Enabled   := Edicao;
  btnLoteCancelar.Enabled := Edicao;
end;

procedure TFrmPrincipal.btnLoteIncluirClick(Sender: TObject);
begin
  SetModoLista(meInclusao);
  edtLoteId.Text         := '(novo)';
  edtLoteDescricao.Text  := '';
  dtpLoteEntrada.Date    := Date;
  edtLoteQtdInicial.Text := '';
  edtLotePesoMedio.Text  := '0.00';
  edtLoteDescricao.SetFocus;
end;

procedure TFrmPrincipal.gridLotesDblClick(Sender: TObject);
begin
  if (FModoLista = meNavegacao) and LoteSelecionado then
  begin
    SetModoLista(meEdicao);
    PreencherEditLote;
    edtLoteDescricao.SetFocus;
  end;
end;

procedure TFrmPrincipal.btnLoteGravarClick(Sender: TObject);
var
  Lote: TLote;
  NovoId: Integer;
begin
  Lote := TLote.Create;
  try
    if FModoLista = meEdicao then
      Lote.Id := FLoteAtual.Id;
    Lote.Descricao         := Trim(edtLoteDescricao.Text);
    Lote.DataEntrada       := dtpLoteEntrada.Date;
    Lote.QuantidadeInicial := StrToIntDef(Trim(edtLoteQtdInicial.Text), 0);

    if not EntidadeValida(Lote) then
      Exit;

    try
      if FModoLista = meInclusao then
        NovoId := dmGranja.InserirLote(Lote)
      else
      begin
        dmGranja.AtualizarLote(Lote);
        NovoId := Lote.Id;
      end;
    except
      on E: Exception do
      begin
        Erro(E.Message);
        Exit;
      end;
    end;

    SetModoLista(meNavegacao);
    dmGranja.AbrirLotes;
    dmGranja.qryLotes.Locate('ID_LOTE', NovoId, []);
    CarregarLoteAtual;
  finally
    Lote.Free;
  end;
end;

procedure TFrmPrincipal.btnLoteCancelarClick(Sender: TObject);
begin
  SetModoLista(meNavegacao);
  CarregarLoteAtual;
end;

procedure TFrmPrincipal.btnLoteExcluirClick(Sender: TObject);
begin
  if not LoteSelecionado then
    Exit;

  if MessageDlg(Format('Excluir o lote %d - %s?'#13#10 +
       'Todas as pesagens e mortalidades vinculadas serao removidas.',
       [FLoteAtual.Id, FLoteAtual.Descricao]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    dmGranja.ExcluirLote(FLoteAtual.Id);
    dmGranja.AbrirLotes;
    CarregarLoteAtual;
  except
    on E: Exception do
      Erro(E.Message);
  end;
end;

{ =============================== Aba Pesagem ============================= }

procedure TFrmPrincipal.SetModoPesagem(AModo: TModoEdicao);
var
  Edicao: Boolean;
begin
  FModoPesagem := AModo;
  Edicao := AModo in [meInclusao, meEdicao];

  dtpPesData.Enabled := Edicao;
  edtPesPeso.Enabled := Edicao;
  edtPesQtd.Enabled  := Edicao;
  gridPesagens.Enabled := not Edicao;

  btnPesIncluir.Enabled   := not Edicao;
  btnPesExcluir.Enabled   := not Edicao;
  btnPesGravar.Enabled    := Edicao;
  btnPesCancelar.Enabled  := Edicao;
  btnPesAtualizar.Enabled := not Edicao;
end;

procedure TFrmPrincipal.btnPesIncluirClick(Sender: TObject);
begin
  if not LoteSelecionado then
  begin
    Aviso('Selecione um lote.');
    Exit;
  end;
  FIdPesagemEdit := 0;
  SetModoPesagem(meInclusao);
  dtpPesData.Date := Date;
  edtPesPeso.Text := '';
  edtPesQtd.Text  := '';
  edtPesPeso.SetFocus;
end;

procedure TFrmPrincipal.gridPesagensDblClick(Sender: TObject);
var
  Pes: TPesagem;
begin
  if (FModoPesagem = meNavegacao) and dmGranja.qryPesagens.Active and (not dmGranja.qryPesagens.IsEmpty) then
  begin
    FIdPesagemEdit := dmGranja.qryPesagens.FieldByName('ID_PESAGEM').AsInteger;
    Pes := dmGranja.ObterPesagem(FIdPesagemEdit);   // leitura via entidade
    try
      SetModoPesagem(meEdicao);
      dtpPesData.Date := Pes.Data;
      edtPesPeso.Text := FormatFloat('0.00', Pes.PesoMedio);
      edtPesQtd.Text  := IntToStr(Pes.QuantidadePesada);
      edtPesPeso.SetFocus;
    finally
      Pes.Free;
    end;
  end;
end;

procedure TFrmPrincipal.btnPesGravarClick(Sender: TObject);
var
  Pes: TPesagem;
begin
  Pes := TPesagem.Create;
  try
    Pes.IdLote                := FLoteAtual.Id;
    Pes.QuantidadeInicialLote := FLoteAtual.QuantidadeInicial;
    Pes.Data                  := dtpPesData.Date;
    Pes.PesoMedio             := StrParaPeso(edtPesPeso.Text);
    Pes.QuantidadePesada      := StrToIntDef(Trim(edtPesQtd.Text), 0);
    if FModoPesagem = meEdicao then
      Pes.Id := FIdPesagemEdit;

    if not EntidadeValida(Pes) then
      Exit;

    try
      if FModoPesagem = meInclusao then
        dmGranja.InserirPesagem(Pes)
      else
        dmGranja.AtualizarPesagem(Pes);
    except
      on E: Exception do
      begin
        Erro(E.Message);
        Exit;
      end;
    end;

    SetModoPesagem(meNavegacao);
    dmGranja.AbrirPesagens(FLoteAtual.Id);          // auto-refresh do grid
    // Peso medio geral do lote mudou -> recarrega o lote.
    dmGranja.AbrirLotes;
    dmGranja.qryLotes.Locate('ID_LOTE', FLoteAtual.Id, []);
    CarregarLoteAtual;
    PageControl1.ActivePage := tabPesagem;
  finally
    Pes.Free;
  end;
end;

procedure TFrmPrincipal.btnPesCancelarClick(Sender: TObject);
begin
  SetModoPesagem(meNavegacao);
end;

procedure TFrmPrincipal.btnPesExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  if not (dmGranja.qryPesagens.Active and (not dmGranja.qryPesagens.IsEmpty)) then
    Exit;

  Id := dmGranja.qryPesagens.FieldByName('ID_PESAGEM').AsInteger;
  if MessageDlg(Format('Excluir a pesagem %d?', [Id]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    dmGranja.ExcluirPesagem(Id);
    dmGranja.AbrirPesagens(FLoteAtual.Id);
    dmGranja.AbrirLotes;
    dmGranja.qryLotes.Locate('ID_LOTE', FLoteAtual.Id, []);
    CarregarLoteAtual;
    PageControl1.ActivePage := tabPesagem;
  except
    on E: Exception do
      Erro(E.Message);
  end;
end;

procedure TFrmPrincipal.btnPesAtualizarClick(Sender: TObject);
begin
  if LoteSelecionado then
    dmGranja.AbrirPesagens(FLoteAtual.Id);
end;

{ ============================= Aba Mortalidade ========================== }

procedure TFrmPrincipal.SetModoMortalidade(AModo: TModoEdicao);
var
  Edicao: Boolean;
begin
  FModoMortalidade := AModo;
  Edicao := AModo in [meInclusao, meEdicao];

  dtpMortData.Enabled := Edicao;
  edtMortQtd.Enabled  := Edicao;
  edtMortObs.Enabled  := Edicao;
  gridMortalidades.Enabled := not Edicao;

  btnMortIncluir.Enabled   := not Edicao;
  btnMortExcluir.Enabled   := not Edicao;
  btnMortGravar.Enabled    := Edicao;
  btnMortCancelar.Enabled  := Edicao;
  btnMortAtualizar.Enabled := not Edicao;
end;

procedure TFrmPrincipal.btnMortIncluirClick(Sender: TObject);
begin
  if not LoteSelecionado then
  begin
    Aviso('Selecione um lote.');
    Exit;
  end;
  FIdMortEdit := 0;
  SetModoMortalidade(meInclusao);
  dtpMortData.Date := Date;
  edtMortQtd.Text  := '';
  edtMortObs.Text  := '';
  edtMortQtd.SetFocus;
end;

procedure TFrmPrincipal.gridMortalidadesDblClick(Sender: TObject);
var
  Mort: TMortalidade;
begin
  if (FModoMortalidade = meNavegacao) and dmGranja.qryMortalidades.Active and (not dmGranja.qryMortalidades.IsEmpty) then
  begin
    FIdMortEdit := dmGranja.qryMortalidades.FieldByName('ID_MORTALIDADE').AsInteger;
    Mort := dmGranja.ObterMortalidade(FIdMortEdit);   // leitura via entidade
    try
      SetModoMortalidade(meEdicao);
      dtpMortData.Date := Mort.Data;
      edtMortQtd.Text  := IntToStr(Mort.QuantidadeMorta);
      edtMortObs.Text  := Mort.Observacao;
      edtMortQtd.SetFocus;
    finally
      Mort.Free;
    end;
  end;
end;

procedure TFrmPrincipal.btnMortGravarClick(Sender: TObject);
var
  Mort: TMortalidade;
  Acum: Integer;
  Perc: Double;
begin
  Mort := TMortalidade.Create;
  try
    Mort.IdLote                := FLoteAtual.Id;
    Mort.QuantidadeInicialLote := FLoteAtual.QuantidadeInicial;
    Mort.Data                  := dtpMortData.Date;
    Mort.QuantidadeMorta       := StrToIntDef(Trim(edtMortQtd.Text), 0);
    Mort.Observacao            := Trim(edtMortObs.Text);
    if FModoMortalidade = meEdicao then
    begin
      Mort.Id := FIdMortEdit;
      // Mortes ja registradas exceto o proprio registro (calculo no banco/repositorio).
      Mort.MortesJaRegistradas := dmGranja.MortesAcumuladasExceto(FLoteAtual.Id, FIdMortEdit);
    end
    else
      Mort.MortesJaRegistradas := dmGranja.MortesAcumuladas(FLoteAtual.Id);

    if not EntidadeValida(Mort) then
      Exit;

    try
      if FModoMortalidade = meInclusao then
        dmGranja.InserirMortalidade(Mort, Acum, Perc)
      else
        dmGranja.AtualizarMortalidade(Mort, Acum, Perc);
    except
      on E: Exception do
      begin
        Erro(E.Message);
        Exit;
      end;
    end;

    // Atualiza o indicador com o acumulado retornado pela procedure (req. 4.c).
    FLoteAtual.MortesAcumuladas := Acum;
    AtualizarIndicadores;

    SetModoMortalidade(meNavegacao);
    dmGranja.AbrirMortalidades(FLoteAtual.Id);      // auto-refresh do grid
  finally
    Mort.Free;
  end;
end;

procedure TFrmPrincipal.btnMortCancelarClick(Sender: TObject);
begin
  SetModoMortalidade(meNavegacao);
end;

procedure TFrmPrincipal.btnMortExcluirClick(Sender: TObject);
var
  Id, Acum: Integer;
  Perc: Double;
begin
  if not (dmGranja.qryMortalidades.Active and (not dmGranja.qryMortalidades.IsEmpty)) then
    Exit;

  Id := dmGranja.qryMortalidades.FieldByName('ID_MORTALIDADE').AsInteger;
  if MessageDlg(Format('Excluir a mortalidade %d?', [Id]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    dmGranja.ExcluirMortalidade(Id, Acum, Perc);
    FLoteAtual.MortesAcumuladas := Acum;
    AtualizarIndicadores;
    dmGranja.AbrirMortalidades(FLoteAtual.Id);
  except
    on E: Exception do
      Erro(E.Message);
  end;
end;

procedure TFrmPrincipal.btnMortAtualizarClick(Sender: TObject);
begin
  if LoteSelecionado then
    dmGranja.AbrirMortalidades(FLoteAtual.Id);
end;

end.
