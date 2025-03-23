unit JSONUtils;

{$mode Delphi}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser;

type
  TJSONStorage = class
  public
    class procedure SaveToFile(const AFileName, AComponents, AEvents: string);
    class function LoadFromFile(const AFileName: string; out AComponents, AEvents: string): Boolean;
  end;

implementation

class procedure TJSONStorage.SaveToFile(const AFileName, AComponents, AEvents: string);
var
  JSONRoot, JSONEvents: TJSONObject;
  JSONFile: TStringList;
begin
  // Converte AComponents em um JSON válido
  JSONRoot := GetJSON(AComponents) as TJSONObject;

  try
    // Converte AEvents em JSON válido e adiciona ao root
    if AEvents <> '' then
      JSONRoot.Add('events', GetJSON(AEvents))  // Agora 'events' será um objeto JSON válido
    else
      JSONRoot.Add('events', TJSONObject.Create); // Garante que exista a tag 'events' vazia

    JSONFile := TStringList.Create;
    try
      JSONFile.Text := JSONRoot.AsJSON;
      JSONFile.SaveToFile(AFileName);
    finally
      JSONFile.Free;
    end;
  finally
    JSONRoot.Free;
  end;
end;

class function TJSONStorage.LoadFromFile(const AFileName: string; out AComponents, AEvents: string): Boolean;
var
  JSONFile: TStringList;
  JSONData: TJSONObject;
begin
  Result := False;
  AComponents := '';
  AEvents := '';

  if not FileExists(AFileName) then
    Exit;

  JSONFile := TStringList.Create;
  try
    JSONFile.LoadFromFile(AFileName);
    JSONData := GetJSON(JSONFile.Text) as TJSONObject;
    try
      // Retorna TODO o JSON original
      AComponents := JSONData.AsJSON;
      // Retorna apenas a parte correspondente a "events"
      if JSONData.FindPath('events') <> nil then
        AEvents := JSONData.FindPath('events').AsJSON
      else
        AEvents := '';

      Result := True;
    finally
      JSONData.Free;
    end;
  finally
    JSONFile.Free;
  end;
end;



end.

