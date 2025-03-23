unit FileUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  Dialogs,
  SysUtils;

function SelectSaveFile: string;
function SelectOpenFile: string;

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

function SelectOpenFile: string;
var
  OpenDialog: TOpenDialog;
begin
  Result := ''; // Retorna string vazia caso o usuário cancele

  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter := 'Arquivos JSON (*.json)|*.json';
    OpenDialog.DefaultExt := 'json';
    OpenDialog.Title := 'Abrir arquivo JSON';
    OpenDialog.Options := [ofFileMustExist, ofPathMustExist];

    if OpenDialog.Execute then
      Result := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;
end;

end.

