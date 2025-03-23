program Forge;

{$mode objfpc}{$H+}

uses
    {$IFDEF UNIX}
    cthreads,
    {$ENDIF}
    {$IFDEF HASAMIGA}
    athreads,
    {$ENDIF}
    Interfaces, // this includes the LCL widgetset
    Forms,
    anchordockpkg,
    DesignTimeForm,
    PopUpUtils,
    FileUtils,
		Form.Utils.NewComponentPopUp,
    Form.Utils.PalleteTools,
		Form.Utils.ComponentsBoard,
    Form.Utils.ComponentFactory,
    Form.Utils.ToolBar,
    Form.Utils.ComponentFactory.Interfaces,
		Form.Utils.Components.ResizeHandle,
    Form.Utils.Components.ResizeFrame,
    Form.Utils.ComponentProperties,
    ArrayUtils,
    Constants,
    Form.Utils.Component.Events,
    Form.Utils.EventManager,
    Form.Utils.EventEditForm,
    JSONUtils;

{$R *.res}

begin
    RequireDerivedFormResource:=True;
		Application.Scaled:=True;
    Application.Initialize;
		Application.CreateForm(TForm1, Form1);
    Application.Run;
end.

