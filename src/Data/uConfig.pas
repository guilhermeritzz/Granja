unit uConfig;

{ -----------------------------------------------------------------------------
  Leitura da configuracao de conexao a partir de um arquivo .ini (Granja.ini),
  localizado na mesma pasta do executavel.

      [Database]
      Server   = GRANJA                 ; alias do tnsnames.ora (ou host:porta/servico)
      User     = GRANJA
      Password = granja123

      [Oracle]
      OCIPath  = C:\app\instantClient\oci.dll
      TNSAdmin = C:\app\instantClient\network\admin
  ----------------------------------------------------------------------------- }

interface

type
  TConfiguracao = record
    Server: string;     // alias TNS
    User: string;
    Password: string;
    OCIPath: string;    // caminho do oci.dll de 32 bits
    TNSAdmin: string;   // pasta network\admin que contem o tnsnames.ora
  end;

  TConfig = class
  public
    class function ArquivoPadrao: string;
    class procedure CriarPadrao(const AArquivo: string);
    class function Carregar(const AArquivo: string = ''): TConfiguracao;
  end;

implementation

uses
  System.SysUtils, System.IniFiles, System.IOUtils, System.Classes;

const
  // Conteudo padrao gerado automaticamente quando o Granja.ini nao existe.
  // Mantem-se em sincronia com config\Granja.ini.example.
  CConfigPadrao =
    '; ============================================================================'#13#10 +
    ';  Granja - configuracao de conexao'#13#10 +
    ';'#13#10 +
    ';  Ajuste os valores conforme o seu ambiente.'#13#10 +
    '; ============================================================================'#13#10 +
    ''#13#10 +
    '[Database]'#13#10 +
    '; Alias definido no tnsnames.ora (recomendado).'#13#10 +
    '; Alternativa EZConnect (dispensa o tnsnames): Server = localhost:1521/XE'#13#10 +
    'Server   = GRANJA'#13#10 +
    'User     = GRANJA'#13#10 +
    'Password = granja123'#13#10 +
    ''#13#10 +
    '[Oracle]'#13#10 +
    '; Caminho do oci.dll de 32 BITS (Instant Client 11.2). O app deve ser Win32.'#13#10 +
    'OCIPath  = C:\app\instantClient\oci.dll'#13#10 +
    '; Pasta network\admin que contem o tnsnames.ora (define a variavel TNS_ADMIN).'#13#10 +
    'TNSAdmin = C:\app\instantClient\network\admin'#13#10;

class function TConfig.ArquivoPadrao: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'Granja.ini');
end;

class procedure TConfig.CriarPadrao(const AArquivo: string);
var
  Pasta: string;
begin
  Pasta := ExtractFilePath(AArquivo);
  if (Pasta <> '') and not TDirectory.Exists(Pasta) then
    TDirectory.CreateDirectory(Pasta);
  TFile.WriteAllText(AArquivo, CConfigPadrao, TEncoding.UTF8);
end;

class function TConfig.Carregar(const AArquivo: string): TConfiguracao;
var
  Arquivo: string;
  Ini: TIniFile;
begin
  Arquivo := AArquivo;
  if Arquivo = '' then
    Arquivo := ArquivoPadrao;

  // Se nao existir, cria automaticamente com os valores padrao na pasta do exe.
  if not TFile.Exists(Arquivo) then
    CriarPadrao(Arquivo);

  Ini := TIniFile.Create(Arquivo);
  try
    Result.Server   := Ini.ReadString('Database', 'Server',   '');
    Result.User     := Ini.ReadString('Database', 'User',     '');
    Result.Password := Ini.ReadString('Database', 'Password', '');
    Result.OCIPath  := Ini.ReadString('Oracle',   'OCIPath',  '');
    Result.TNSAdmin := Ini.ReadString('Oracle',   'TNSAdmin', '');
  finally
    Ini.Free;
  end;

  if Result.Server = '' then
    raise Exception.Create('Configuracao [Database].Server nao informada no Granja.ini.');
  if Result.User = '' then
    raise Exception.Create('Configuracao [Database].User nao informada no Granja.ini.');
end;

end.
