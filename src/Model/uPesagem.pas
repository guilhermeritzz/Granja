unit uPesagem;

{ Entidade de negocio: Pesagem (TAB_PESAGEM). }

interface

uses
  uEntidadeBase;

type
  TPesagem = class(TLancamentoLote)
  private
    FPesoMedio: Double;
    FQuantidadePesada: Integer;
  public
    { Validacao espelhada na procedure INSERIR_PESAGEM. }
    function Validar(out AErro: string): Boolean; override;

    property PesoMedio: Double read FPesoMedio write FPesoMedio;
    property QuantidadePesada: Integer read FQuantidadePesada write FQuantidadePesada;
  end;

implementation

uses
  System.SysUtils;

function TPesagem.Validar(out AErro: string): Boolean;
begin
  AErro := '';
  if Data = 0 then
    AErro := 'Informe a data da pesagem.'
  else if FPesoMedio <= 0 then
    AErro := 'O peso medio deve ser maior que zero.'
  else if FQuantidadePesada <= 0 then
    AErro := 'A quantidade pesada deve ser maior que zero.'
  else if FQuantidadePesada > QuantidadeInicialLote then
    AErro := Format('A quantidade pesada (%d) nao pode ultrapassar a quantidade inicial do lote (%d).',
                    [FQuantidadePesada, QuantidadeInicialLote]);

  Result := AErro = '';
end;

end.
