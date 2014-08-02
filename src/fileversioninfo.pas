{
 FileVersionInfo.pas

 Copyright (C) 1994-2007 IntelliCorp, Inc.
 All rights reserved.
}

unit fileversioninfo;

interface

type
  TFileVersionInfo = class
  public
    constructor Create;
    destructor Destroy; override;

  public
    procedure GetVersionInfo(const pathname: string);

  private
    procedure Initialize;
    function ReadVersionInfo(const pathname: string): Boolean;

  private
    FAvailable: Boolean;
    FMajor: Integer;
    FMinor: Integer;
    FRelease: Integer;
    FBuild: Integer;

  public
    property Available: Boolean read FAvailable default false;
    property Major: Integer read FMajor default 0;
    property Minor: Integer read FMinor default 0;
    property Release: Integer read FRelease default 0;
    property Build: Integer read FBuild default 0;
  end;

implementation

uses
  Windows,
  SysUtils;

constructor TFileVersionInfo.Create;
begin
  inherited;

  Initialize;
end;

destructor TFileVersionInfo.Destroy;
begin
  inherited;
end;

procedure TFileVersionInfo.GetVersionInfo(const pathname: string);
begin
  FAvailable := ReadVersionInfo(pathname);
end;

procedure TFileVersionInfo.Initialize;
begin
  FAvailable := false;

  FMajor := 0;
  FMinor := 0;
  FRelease := 0;
  FBuild := 0;
end;

function TFileVersionInfo.ReadVersionInfo(const pathname: string): Boolean;
var
  info: PVSFixedFileInfo;
  infoSize: UINT;
  h: DWORD;
  buffer: Pointer;
  bufferSize: DWORD;
begin
  Result := true;

  bufferSize := GetFileVersionInfoSize(PChar(pathname), h);

  if bufferSize <> 0 then
  begin
    GetMem(buffer, bufferSize);

    try
      if GetFileVersionInfo(PChar(pathname), h, bufferSize, buffer) then
      begin
        if VerQueryValue(buffer, '\', Pointer(info), infoSize) then
        begin
          FMajor := HiWord(info^.dwFileVersionMS);
          FMinor := LoWord(info^.dwFileVersionMS);
          FRelease := HiWord(info^.dwFileVersionLS);
          FBuild := LoWord(info^.dwFileVersionLS);
        end
        else
          Result := false;
      end
      else
        Result := false;
    finally
      FreeMem(buffer, bufferSize);
    end;
  end
  else
    Result := false;
end;

end.
