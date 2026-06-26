unit uMortalidade;

{ Mortalidade (TAB_MORTALIDADE). }

interface

uses
  uEntidadeBase;

type
  TMortalidade = class(TLancamentoLote)
  private
    FQuantidadeMorta: Integer;
    FObservacao: string;
    FMortesJaRegistradas: Integer;
  public
    { Validacao espelhada na procedure INSERIR_MORTALIDADE. }
    function Validar(out AErro: string): Boolean; override;

    property QuantidadeMorta: Integer read FQuantidadeMorta write FQuantidadeMorta;
    property Observacao: string read FObservacao write FObservacao;
    { Mortes ja lancadas para o lote, desconsiderando este registro. }
    property MortesJaRegistradas: Integer read FMortesJaRegistradas write FMortesJaRegistradas;
  end;

implementation

uses
  System.SysUtils;

function TMortalidade.Validar(out AErro: string): Boolean;
begin
  AErro := '';
  if Data = 0 then
    AErro := 'Informe a data da mortalidade.'
  else if FQuantidadeMorta <= 0 then
    AErro := 'A quantidade morta deve ser maior que zero.'
  else if (FMortesJaRegistradas + FQuantidadeMorta) > QuantidadeInicialLote then
    AErro := Format('A mortalidade acumulada (%d) nao pode ultrapassar a quantidade inicial do lote (%d).',
                    [FMortesJaRegistradas + FQuantidadeMorta, QuantidadeInicialLote]);

  Result := AErro = '';
end;

end.
