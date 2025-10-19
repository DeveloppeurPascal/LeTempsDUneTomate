(* C2PP
  ***************************************************************************

  Le temps d'une tomate

  Copyright 2024-2025 Patrick PREMARTIN under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://developpeur-pascal.fr/le-temps-d-une-tomate.html

  Project site :
  https://github.com/DeveloppeurPascal/LeTempsDUneTomate

  ***************************************************************************
  File last update : 2025-10-16T10:42:09.123+02:00
  Signature : 80e734795ec1b898533d7abbf9bfb8e92855327e
  ***************************************************************************
*)

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
    class function GetAndNowDuration: integer; static;
    class function GetEndBackgroundImageDuration: integer; static;
    class function GetPreviouslyDuration: integer; static;
    class function GetStartBackgroundImageDuration: integer; static;
    class procedure SetAndNowDuration(const Value: integer); static;
    class procedure SetEndBackgroundImageDuration(const Value: integer); static;
    class procedure SetPreviouslyDuration(const Value: integer); static;
    class procedure SetStartBackgroundImageDuration
      (const Value: integer); static;
    class function GetVideoHeight: integer; static;
    class function GetVideoWidth: integer; static;
    class procedure SetVideoHeight(const Value: integer); static;
    class procedure SetVideoWidth(const Value: integer); static;
    class function GetVideoFPS: integer; static;
    class procedure SetVideoFPS(const Value: integer); static;
  protected
  public
    class property Title: string read GetTitle write SetTitle;
    class property VideoFilePrefix: string read GetVideoFilePrefix
      write SetVideoFilePrefix;
    class property VideoDuration: integer read GetVideoDuration
      write SetVideoDuration;
    class property StartBackgroundImage: string read GetStartBackgroundImage
      write SetStartBackgroundImage;
    class property StartBackgroundImageDuration: integer
      read GetStartBackgroundImageDuration
      write SetStartBackgroundImageDuration;
    class property OverlayImage: string read GetOverlayImage
      write SetOverlayImage;
    class property PreviouslyDuration: integer read GetPreviouslyDuration
      write SetPreviouslyDuration;
    class property AndNowDuration: integer read GetAndNowDuration
      write SetAndNowDuration;
    class property EndBackgroundImage: string read GetEndBackgroundImage
      write SetEndBackgroundImage;
    class property EndBackgroundImageDuration: integer
      read GetEndBackgroundImageDuration write SetEndBackgroundImageDuration;
    class property VideoWidth: integer read GetVideoWidth write SetVideoWidth;
    class property VideoHeight: integer read GetVideoHeight
      write SetVideoHeight;
    class property VideoFPS: integer read GetVideoFPS write SetVideoFPS;
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

class function TProject.GetAndNowDuration: integer;
begin
  result := ProjectFile.getValue('AndNowD', tConfig.DefaultAndNowDuration);
end;

class function TProject.GetEndBackgroundImage: string;
begin
  result := ProjectFile.getValue('EndImg', tConfig.DefaultEndBackgroundImage);
end;

class function TProject.GetEndBackgroundImageDuration: integer;
begin
  result := ProjectFile.getValue('EndImgD',
    tConfig.DefaultEndBackgroundImageDuration);
end;

class function TProject.GetFolder: string;
begin
  result := tpath.GetDirectoryName(ProjectFile.getFilePath);
end;

class function TProject.GetOverlayImage: string;
begin
  result := ProjectFile.getValue('OverImg', tConfig.DefaultOverlayImage);
end;

class function TProject.GetPreviouslyDuration: integer;
begin
  result := ProjectFile.getValue('PrevD', tConfig.DefaultPreviouslyDuration);
end;

class function TProject.GetStartBackgroundImage: string;
begin
  result := ProjectFile.getValue('StartImg',
    tConfig.DefaultStartBackgroundImage);
end;

class function TProject.GetStartBackgroundImageDuration: integer;
begin
  result := ProjectFile.getValue('StartImgD',
    tConfig.DefaultStartBackgroundImageDuration);
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

class function TProject.GetVideoFPS: integer;
begin
  result := ProjectFile.getValue('VidFPS', tConfig.DefaultVideoFPS);
end;

class function TProject.GetVideoHeight: integer;
begin
  result := ProjectFile.getValue('VidH', tConfig.DefaultVideoHeight);
end;

class function TProject.GetVideoWidth: integer;
begin
  result := ProjectFile.getValue('VidW', tConfig.DefaultVideoWidth);
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

class procedure TProject.SetAndNowDuration(const Value: integer);
begin
  ProjectFile.setValue('AndNowD', Value);
end;

class procedure TProject.SetEndBackgroundImage(const Value: string);
begin
  ProjectFile.setValue('EndImg', Value);
end;

class procedure TProject.SetEndBackgroundImageDuration(const Value: integer);
begin
  ProjectFile.setValue('EndImgD', Value);
end;

class procedure TProject.SetOverlayImage(const Value: string);
begin
  ProjectFile.setValue('OverImg', Value);
end;

class procedure TProject.SetPreviouslyDuration(const Value: integer);
begin
  ProjectFile.setValue('PrevD', Value);
end;

class procedure TProject.SetStartBackgroundImage(const Value: string);
begin
  ProjectFile.setValue('StartImg', Value);
end;

class procedure TProject.SetStartBackgroundImageDuration(const Value: integer);
begin
  ProjectFile.setValue('StartImgD', Value);
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

class procedure TProject.SetVideoFPS(const Value: integer);
begin
  ProjectFile.setValue('VidFPS', Value);
end;

class procedure TProject.SetVideoHeight(const Value: integer);
begin
  ProjectFile.setValue('VidH', Value);
end;

class procedure TProject.SetVideoWidth(const Value: integer);
begin
  ProjectFile.setValue('VidW', Value);
end;

initialization

ProjectFile := nil;

end.
