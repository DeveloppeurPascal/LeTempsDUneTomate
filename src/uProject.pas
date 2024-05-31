unit uProject;

interface

type
  TProject = class
  private
    class procedure SetEndBackgroundImage(const Value: string); static;
    class procedure SetOverlayImage(const Value: string); static;
    class procedure SetStartBackgroundImage(const Value: string); static;
    class procedure SetTitle(const Value: string); static;
    class procedure SetVideoDuration(const Value: integer); static;
    class procedure SetVideoFilePrefix(const Value: string); static;
    class function GetEndBackgroundImage: string; static;
    class function GetOverlayImage: string; static;
    class function GetStartBackgroundImage: string; static;
    class function GetTitle: string; static;
    class function GetVideoDuration: integer; static;
    class function GetVideoFilePrefix: string; static;
  protected
  public
    class property Title: string read GetTitle write SetTitle;
    class property VideoFilePrefix: string read GetVideoFilePrefix
      write SetVideoFilePrefix;
    class property VideoDuration: integer read GetVideoDuration
      write SetVideoDuration;
    class property StartBackgroundImage: string read GetStartBackgroundImage
      write SetStartBackgroundImage;
    class property EndBackgroundImage: string read GetEndBackgroundImage
      write SetEndBackgroundImage;
    class property OverlayImage: string read GetOverlayImage
      write SetOverlayImage;
    class procedure Open(const FromPath: string);
    class procedure Save;
    class procedure Close;
    class procedure Cancel;
    class function isOpened: boolean;
    class function GetFolder: string;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.Types,
  System.SysUtils,
  Olf.RTL.CryptDecrypt,
  Olf.RTL.Params,
  uConfig;

var
  ProjectFile: TParamsFile;

  { TProject }

class procedure TProject.Cancel;
begin
  ProjectFile.Cancel;
end;

class procedure TProject.Close;
begin
  freeandnil(ProjectFile);
end;

class function TProject.GetEndBackgroundImage: string;
begin
  result := ProjectFile.getValue('EndImg', tConfig.DefaultEndBackgroundImage);
end;

class function TProject.GetFolder: string;
begin
  result := tpath.GetDirectoryName(ProjectFile.getFilePath);
end;

class function TProject.GetOverlayImage: string;
begin
  result := ProjectFile.getValue('OverImg', tConfig.DefaultOverlayImage);
end;

class function TProject.GetStartBackgroundImage: string;
begin
  result := ProjectFile.getValue('StartImg',
    tConfig.DefaultStartBackgroundImage);
end;

class function TProject.GetTitle: string;
begin
  result := ProjectFile.getValue('Title', '');
end;

class function TProject.GetVideoDuration: integer;
begin
  result := ProjectFile.getValue('MvD', tConfig.DefaultVideoDuration);
end;

class function TProject.GetVideoFilePrefix: string;
begin
  result := ProjectFile.getValue('MvF', '');
end;

class function TProject.isOpened: boolean;
begin
  result := assigned(ProjectFile);
end;

class procedure TProject.Open(const FromPath: string);
var
  FileName: string;
begin
  if not tdirectory.Exists(FromPath) then
    raise exception.Create('This folder doesn''t exist !');

  if assigned(ProjectFile) then
    freeandnil(ProjectFile);

  ProjectFile := TParamsFile.Create;
{$IFDEF RELEASE}
  FileName := tpath.combine(FromPath, 'ltdut.cfg');
{$ELSE}
  FileName := tpath.combine(FromPath, 'ltdut.par');
{$ENDIF}
  ProjectFile.setFilePath(FileName, false);

{$IFDEF RELEASE }
  ProjectFile.onCryptProc := function(Const AParams: string): TStream
    var
      Keys: TByteDynArray;
      ParStream: TStringStream;
    begin
      ParStream := TStringStream.Create(AParams);
      try
{$I '..\_PRIVATE\src\ProjectFileXORKey.inc'}
        result := TOlfCryptDecrypt.XORCrypt(ParStream, Keys);
      finally
        ParStream.free;
      end;
    end;
  ProjectFile.onDecryptProc := function(Const AStream: TStream): string
    var
      Keys: TByteDynArray;
      Stream: TStream;
      StringStream: TStringStream;
    begin
{$I '..\_PRIVATE\src\ProjectFileXORKey.inc'}
      result := '';
      Stream := TOlfCryptDecrypt.XORdeCrypt(AStream, Keys);
      try
        if assigned(Stream) and (Stream.Size > 0) then
        begin
          StringStream := TStringStream.Create;
          try
            Stream.Position := 0;
            StringStream.CopyFrom(Stream);
            result := StringStream.DataString;
          finally
            StringStream.free;
          end;
        end;
      finally
        Stream.free;
      end;
    end;
{$ENDIF}
  ProjectFile.Load;
end;

class procedure TProject.Save;
begin
  ProjectFile.Save;
end;

class procedure TProject.SetEndBackgroundImage(const Value: string);
begin
  ProjectFile.setValue('EndImg', Value);
end;

class procedure TProject.SetOverlayImage(const Value: string);
begin
  ProjectFile.setValue('OverImg', Value);
end;

class procedure TProject.SetStartBackgroundImage(const Value: string);
begin
  ProjectFile.setValue('StartImg', Value);
end;

class procedure TProject.SetTitle(const Value: string);
begin
  ProjectFile.setValue('Title', Value);
end;

class procedure TProject.SetVideoDuration(const Value: integer);
begin
  ProjectFile.setValue('MvD', Value);
end;

class procedure TProject.SetVideoFilePrefix(const Value: string);
begin
  ProjectFile.setValue('MvF', Value);
end;

initialization

ProjectFile := nil;

end.
