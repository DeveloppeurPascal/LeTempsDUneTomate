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
  File last update : 2025-10-16T10:42:09.121+02:00
  Signature : 5c2f41e88673d6bff276177a5f7b001608e13250
  ***************************************************************************
*)

unit uConfig;

interface

type
  tConfig = class
  private
    class procedure SetDefaultEndBackgroundImage(const Value: string); static;
    class procedure SetDefaultOverlayImage(const Value: string); static;
    class procedure SetDefaultStartBackgroundImage(const Value: string); static;
    class procedure SetDefaultVideoDuration(const Value: integer); static;
    class procedure SetDefaultVideoHeight(const Value: integer); static;
    class procedure SetDefaultVideoWidth(const Value: integer); static;
    class function GetDefaultEndBackgroundImage: string; static;
    class function GetDefaultOverlayImage: string; static;
    class function GetDefaultStartBackgroundImage: string; static;
    class function GetDefaultVideoDuration: integer; static;
    class function GetDefaultVideoHeight: integer; static;
    class function GetDefaultVideoWidth: integer; static;
    class function GetFFmpegPath: string; static;
    class procedure SetFFmpegPath(const Value: string); static;
    class function GetDefaultEndBackgroundImageDuration: integer; static;
    class function GetDefaultPreviouslyDuration: integer; static;
    class function GetDefaultStartBackgroundImageDuration: integer; static;
    class procedure SetDefaultEndBackgroundImageDuration
      (const Value: integer); static;
    class procedure SetDefaultPreviouslyDuration(const Value: integer); static;
    class procedure SetDefaultStartBackgroundImageDuration
      (const Value: integer); static;
    class function GetDefaultAndNowDuration: integer; static;
    class procedure SetDefaultAndNowDuration(const Value: integer); static;
    class function GetDefaultVideoFPS: integer; static;
    class procedure SetDefaultVideoFPS(const Value: integer); static;
  protected
  public
    class property FFmpegPath: string read GetFFmpegPath write SetFFmpegPath;
    class property DefaultStartBackgroundImage: string
      read GetDefaultStartBackgroundImage write SetDefaultStartBackgroundImage;
    class property DefaultStartBackgroundImageDuration: integer
      read GetDefaultStartBackgroundImageDuration
      write SetDefaultStartBackgroundImageDuration;
    class property DefaultEndBackgroundImage: string
      read GetDefaultEndBackgroundImage write SetDefaultEndBackgroundImage;
    class property DefaultEndBackgroundImageDuration: integer
      read GetDefaultEndBackgroundImageDuration
      write SetDefaultEndBackgroundImageDuration;
    class property DefaultOverlayImage: string read GetDefaultOverlayImage
      write SetDefaultOverlayImage;
    class property DefaultVideoDuration: integer read GetDefaultVideoDuration
      write SetDefaultVideoDuration;
    class property DefaultPreviouslyDuration: integer
      read GetDefaultPreviouslyDuration write SetDefaultPreviouslyDuration;
    class property DefaultAndNowDuration: integer read GetDefaultAndNowDuration
      write SetDefaultAndNowDuration;
    class property DefaultVideoWidth: integer read GetDefaultVideoWidth
      write SetDefaultVideoWidth;
    class property DefaultVideoHeight: integer read GetDefaultVideoHeight
      write SetDefaultVideoHeight;
    class property DefaultVideoFPS: integer read GetDefaultVideoFPS
      write SetDefaultVideoFPS;
    class procedure Save;
    class procedure Cancel;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.Types,
  System.SysUtils,
  Olf.RTL.CryptDecrypt,
  Olf.RTL.Params,
  uConsts;

var
  ConfigFile: TParamsFile;

procedure initConfig;
begin
  ConfigFile := TParamsFile.Create;
  ConfigFile.InitDefaultFileNameV2('OlfSoftware', 'LeTempsDUneTomate', false);
{$IFDEF RELEASE }
  ConfigFile.onCryptProc := function(Const AParams: string): TStream
    var
      Keys: TByteDynArray;
      ParStream: TStringStream;
    begin
      ParStream := TStringStream.Create(AParams);
      try
{$I '..\_PRIVATE\src\ConfigFileXORKey.inc'}
        result := TOlfCryptDecrypt.XORCrypt(ParStream, Keys);
      finally
        ParStream.free;
      end;
    end;
  ConfigFile.onDecryptProc := function(Const AStream: TStream): string
    var
      Keys: TByteDynArray;
      Stream: TStream;
      StringStream: TStringStream;
    begin
{$I '..\_PRIVATE\src\ConfigFileXORKey.inc'}
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
  ConfigFile.load;
end;

{ tConfig }

class procedure tConfig.Cancel;
begin
  ConfigFile.Cancel;
end;

class function tConfig.GetDefaultAndNowDuration: integer;
begin
  result := ConfigFile.getValue('ReplayAndNowD', CDureePreviouslyAndNow);
end;

class function tConfig.GetDefaultEndBackgroundImage: string;
begin
  result := ConfigFile.getValue('EndImg', '');
end;

class function tConfig.GetDefaultEndBackgroundImageDuration: integer;
begin
  result := ConfigFile.getValue('EndImgD', CDureeFin);
end;

class function tConfig.GetDefaultOverlayImage: string;
begin
  result := ConfigFile.getValue('OverImg', '');
end;

class function tConfig.GetDefaultPreviouslyDuration: integer;
begin
  result := ConfigFile.getValue('ReplayPrevD', CDureePreviously);
end;

class function tConfig.GetDefaultStartBackgroundImage: string;
begin
  result := ConfigFile.getValue('StartImg', '');
end;

class function tConfig.GetDefaultStartBackgroundImageDuration: integer;
begin
  result := ConfigFile.getValue('StartImgD', CDureeIntro);
end;

class function tConfig.GetDefaultVideoDuration: integer;
begin
  result := ConfigFile.getValue('MvD', CDureeEpisodeEnMinutes);
end;

class function tConfig.GetDefaultVideoFPS: integer;
begin
  result := ConfigFile.getValue('VidFPS', CVideoFPS);
end;

class function tConfig.GetDefaultVideoHeight: integer;
begin
  result := ConfigFile.getValue('MvH', CVideoHeight);
end;

class function tConfig.GetDefaultVideoWidth: integer;
begin
  result := ConfigFile.getValue('MvW', CVideoWidth);
end;

class function tConfig.GetFFmpegPath: string;
begin
  result := ConfigFile.getValue('FFmpeg', '');
end;

class procedure tConfig.Save;
begin
  ConfigFile.Save;
end;

class procedure tConfig.SetDefaultAndNowDuration(const Value: integer);
begin
  ConfigFile.setValue('ReplayAndNowD', Value);
end;

class procedure tConfig.SetDefaultEndBackgroundImage(const Value: string);
begin
  ConfigFile.setValue('EndImg', Value);
end;

class procedure tConfig.SetDefaultEndBackgroundImageDuration
  (const Value: integer);
begin
  ConfigFile.setValue('EndImgD', Value);
end;

class procedure tConfig.SetDefaultOverlayImage(const Value: string);
begin
  ConfigFile.setValue('OverImg', Value);
end;

class procedure tConfig.SetDefaultPreviouslyDuration(const Value: integer);
begin
  ConfigFile.setValue('ReplayPrevD', Value);
end;

class procedure tConfig.SetDefaultStartBackgroundImage(const Value: string);
begin
  ConfigFile.setValue('StartImg', Value);
end;

class procedure tConfig.SetDefaultStartBackgroundImageDuration
  (const Value: integer);
begin
  ConfigFile.setValue('StartImgD', Value);
end;

class procedure tConfig.SetDefaultVideoDuration(const Value: integer);
begin
  ConfigFile.setValue('MvD', Value);
end;

class procedure tConfig.SetDefaultVideoFPS(const Value: integer);
begin
  ConfigFile.setValue('VidFPS', Value);
end;

class procedure tConfig.SetDefaultVideoHeight(const Value: integer);
begin
  ConfigFile.setValue('MvH', Value);
end;

class procedure tConfig.SetDefaultVideoWidth(const Value: integer);
begin
  ConfigFile.setValue('MvW', Value);
end;

class procedure tConfig.SetFFmpegPath(const Value: string);
begin
  ConfigFile.setValue('FFmpeg', Value);
end;

initialization

initConfig;

finalization

ConfigFile.free;

end.
