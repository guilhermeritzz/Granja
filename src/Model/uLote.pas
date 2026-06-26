unit uLote;

{ Entidade de negocio: Lote de aves (TAB_LOTE_AVES). }

interface

uses
  uEntidadeBase;

type
  TFaixaSaude = (fsSaudavel, fsAtencao, fsCritico);

  TLote = class(TEntidadeBase)
  private
    FDescricao: string;
    FQuantidadeInicial: Integer;
    FPesoMedioGeral: Double;
    FMortesAcumuladas: Integer;
    function GetDataEntrada: TDateTime;
    procedure SetDataEntrada(const Value: TDateTime);
  public
    function Validar(out AErro: string): Boolean; override;

    { Regra unica de classificacao de saude: < 5% verde,
      5%-10% amarelo, > 10% vermelho. Centralizada aqui para ser reaproveitada
      tambem pelo componente visual (evita duplicar os limiares). }
    class function ClassificarFaixa(APercentual: Double): TFaixaSaude; static;

    { % de mortalidade acumulada sobre a quantidade inicial. }
    function PercentualMortalidade: Double;
    { Classificacao de saude deste lote conforme a faixa acima. }
    function FaixaSaude: TFaixaSaude;

    property Descricao: string read FDescricao write FDescricao;
    property DataEntrada: TDateTime read GetDataEntrada write SetDataEntrada;
    property QuantidadeInicial: Integer read FQuantidadeInicial write FQuantidadeInicial;
    property PesoMedioGeral: Double read FPesoMedioGeral write FPesoMedioGeral;
    property MortesAcumuladas: Integer read FMortesAcumuladas write FMortesAcumuladas;
  end;

implementation

uses
  System.SysUtils;

{ DataEntrada e apenas um alias semantico para a propriedade Data herdada. }
function TLote.GetDataEntrada: TDateTime;
begin
  Result := Data;
end;

procedure TLote.SetDataEntrada(const Value: TDateTime);
begin
  Data := Value;
end;

function TLote.Validar(out AErro: string): Boolean;
begin
  AErro := '';
  if Trim(FDescricao) = '' then
    AErro := 'Informe a descricao do lote.'
  else if FQuantidadeInicial <= 0 then
    AErro := 'A quantidade inicial deve ser maior que zero.';

  Result := AErro = '';
end;

function TLote.PercentualMortalidade: Double;
begin
  if FQuantidadeInicial <= 0 then
    Result := 0
  else
    Result := FMortesAcumuladas * 100 / FQuantidadeInicial;
end;

class function TLote.ClassificarFaixa(APercentual: Double): TFaixaSaude;
begin
  if APercentual < 5 then
    Result := fsSaudavel
  else if APercentual <= 10 then
    Result := fsAtencao
  else
    Result := fsCritico;
end;

function TLote.FaixaSaude: TFaixaSaude;
begin
  Result := ClassificarFaixa(PercentualMortalidade);
end;

end.
