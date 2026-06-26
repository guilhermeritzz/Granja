unit uEntidadeBase;

{ -----------------------------------------------------------------------------
  Hierarquia de entidades 
  ----------------------------------------------------------------------------- }

interface

type
  TEntidadeBase = class abstract
  private
    FId: Integer;
    FData: TDateTime;
  public
    constructor Create; virtual;
    { Valida as regras da entidade. Retorna False e preenche AErro quando invalida. }
    function Validar(out AErro: string): Boolean; virtual; abstract;

    property Id: Integer read FId write FId;
    property Data: TDateTime read FData write FData;
  end;

  TLancamentoLote = class abstract(TEntidadeBase)
  private
    FIdLote: Integer;
    FQuantidadeInicialLote: Integer;
  public
    property IdLote: Integer read FIdLote write FIdLote;
    { Quantidade inicial do lote ao qual o lancamento pertence (usada nas validacoes). }
    property QuantidadeInicialLote: Integer read FQuantidadeInicialLote write FQuantidadeInicialLote;
  end;

implementation

uses
  System.SysUtils;

constructor TEntidadeBase.Create;
begin
  inherited Create;
  FData := Now;
end;

end.
