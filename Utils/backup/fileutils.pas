unit FileUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  Dialogs,
  SysUtils;

function SelectSaveFile: string;

implementation

function SelectSaveFile: string;
var
  SaveDialog: TSaveDialog;
begin
  Result := ''; // Retorna string vazia caso o usuário cancele

  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.Filter := 'Arquivos JSON (*.json)|*.json';
    SaveDialog.DefaultExt := 'json';
    SaveDialog.Title := 'Salvar arquivo JSON';
    SaveDialog.Options := [ofOverwritePrompt, ofPathMustExist];

    if SaveDialog.Execute then
      Result := SaveDialog.FileName;
  finally
    SaveDialog.Free;
  end;
end;

end.

