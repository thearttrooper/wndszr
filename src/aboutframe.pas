// aboutframe.pas
//
// Copyright Wave Software Limited.
//

unit aboutframe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls;

type
  TfrmAbout = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    lblVersion: TLabel;
    lblCopyright1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses fileversioninfo, strings;

{$R *.dfm}

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  fvi: TFileVersionInfo;
begin
  fvi := TFileVersionInfo.Create;

  try
    fvi.GetVersionInfo(Application.ExeName);

    lblVersion.Caption := Format(
      rsVersion,
      [
        fvi.Major,
        fvi.Minor,
        fvi.Release,
        fvi.Build
      ]);
  finally
    FreeAndNil(fvi);
  end;

end;

end.
