unit Form.Utils.ComponentFactory.Interfaces;

{$mode Delphi}{$H+}

interface

uses
  Classes,
  SysUtils,
  Generics.Collections;

type
  IComponentBase = interface
    ['{744D28B0-0336-662C-08D4-5B92002FD262}']

    function GetProperties: TArray<string>;
    procedure SetProperties(AProperties: TArray<string>);

    procedure ApplyProperties(AProperties: TStringList);
    function GetProperites(): TStringList;
    property Properties: TArray<string> read GetProperties write SetProperties;
  end;

  IInputComponent = interface(IComponentBase)
    ['{BBDFF680-8325-A83B-299B-E32D42696880}']

	  function GetValue: Variant;
	  procedure SetValue(AValue: Variant);

    procedure ApplyProperties(AProperties: TStringList);
    function GetProperites(): TStringList;

    property Value: Variant read GetValue write SetValue;
	end;

  IDisplayComponent = interface(IComponentBase)
    ['{BAA1CEBE-ADC1-EF25-D0EA-92EB67258A60}']

    procedure SetText(AText: string);
    function GetText: string;

    procedure ApplyProperties(AProperties: TStringList);
    function GetProperites(): TStringList;

    property Text: string read GetText write SetText;
  end;

  IActionComponent = interface(IComponentBase)
    ['{B477F3E0-2A4C-424F-E9EE-AC5B0FF27B2E}']

    procedure ApplyProperties(AProperties: TStringList);
    function GetProperites(): TStringList;

	end;

implementation

end.

