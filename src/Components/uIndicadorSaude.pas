unit uIndicadorSaude;

{ -----------------------------------------------------------------------------
  Componente visual de saude do lote.

  TIndicadorSaudeLote e um descendente de TPanel que pinta sua cor conforme a
  mortalidade acumulada do lote:
      < 5%   -> verde   (Saudavel)
      5%-10% -> amarelo (Atencao)
      > 10%  -> vermelho (Critico)

  E criado em runtime pelo formulario (nao precisa ser instalado na paleta da
  IDE), bastando definir a propriedade Percentual.
  ----------------------------------------------------------------------------- }

interface

uses
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls, uLote;

type
  TIndicadorSaudeLote = class(TPanel)
  private
    FPercentual: Double;
    procedure SetPercentual(const Value: Double);
    procedure Atualizar;
  public
    constructor Create(AOwner: TComponent); override;
    { Atalho: define o percentual a partir de uma entidade TLote. }
    procedure CarregarDeLote(ALote: TLote);
    procedure Limpar;

    property Percentual: Double read FPercentual write SetPercentual;
  end;

implementation

uses
  System.SysUtils, System.UITypes;

constructor TIndicadorSaudeLote.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  ParentBackground := False;
  Font.Style := [fsBold];
  Font.Color := clBlack;
  Alignment := taCenter;
  Caption := 'Indicador de Saude';
  FPercentual := 0;
  Atualizar;
end;

procedure TIndicadorSaudeLote.SetPercentual(const Value: Double);
begin
  FPercentual := Value;
  Atualizar;
end;

procedure TIndicadorSaudeLote.Atualizar;
var
  Faixa: TFaixaSaude;
  Texto: string;
begin
  // Reaproveita a regra de faixa definida na entidade de dominio (sem duplicar limiares).
  Faixa := TLote.ClassificarFaixa(FPercentual);

  case Faixa of
    fsSaudavel:
      begin
        Color := clGreen;
        Font.Color := clWhite;
        Texto := 'SAUDAVEL';
      end;
    fsAtencao:
      begin
        Color := clYellow;
        Font.Color := clBlack;
        Texto := 'ATENCAO';
      end;
    fsCritico:
      begin
        Color := clRed;
        Font.Color := clWhite;
        Texto := 'CRITICO';
      end;
  end;

  Caption := Format('%s  -  Mortalidade: %.2f%%', [Texto, FPercentual]);
end;

procedure TIndicadorSaudeLote.CarregarDeLote(ALote: TLote);
begin
  if Assigned(ALote) then
    Percentual := ALote.PercentualMortalidade
  else
    Limpar;
end;

procedure TIndicadorSaudeLote.Limpar;
begin
  FPercentual := 0;
  Color := clBtnFace;
  Font.Color := clGrayText;
  Caption := 'Selecione um lote';
end;

end.
