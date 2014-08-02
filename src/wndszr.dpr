// wndszr.dpr
//
// Copyright Wave Software Limited.
//

program wndszr;

{$R *.dres}

uses
  Forms,
  mainframe in 'mainframe.pas' {frmMainframe},
  aboutframe in 'aboutframe.pas' {frmAbout},
  strings in 'strings.pas',
  fileversioninfo in 'fileversioninfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Window Sizer';
  Application.CreateForm(TfrmMainframe, frmMainframe);
  Application.Run;
end.
