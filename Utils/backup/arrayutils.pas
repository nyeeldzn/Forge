unit ArrayUtils;

{$mode ObjFPC}{$H+}

interface

uses
    Classes, SysUtils;

function StringInArray(const AValue: string; const AArray: TArray<string>): Boolean;

implementation

function StringInArray(const AValue: string; const AArray: TArray<string>): Boolean;
var
  Item: string;
begin
  Result := False;
  for Item in AArray do
  begin
    if SameText(Item, AValue) then // Comparação case-insensitive
    begin
      Result := True;
      Exit;
    end;
  end;
end;


end.

