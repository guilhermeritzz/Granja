program Granja;

uses
  Vcl.Forms,
  uFrmPrincipal in 'src\View\uFrmPrincipal.pas' {FrmPrincipal},
  uDataModule in 'src\Data\uDataModule.pas' {dmGranja: TDataModule},
  uConfig in 'src\Data\uConfig.pas',
  uEntidadeBase in 'src\Model\uEntidadeBase.pas',
  uLote in 'src\Model\uLote.pas',
  uPesagem in 'src\Model\uPesagem.pas',
  uMortalidade in 'src\Model\uMortalidade.pas',
  uIndicadorSaude in 'src\Components\uIndicadorSaude.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Granja - Pesagem e Mortalidade';
  Application.CreateForm(TDataModuleGranja, dmGranja);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.