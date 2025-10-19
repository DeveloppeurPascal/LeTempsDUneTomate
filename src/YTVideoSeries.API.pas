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
  File last update : 2025-10-16T10:42:09.116+02:00
  Signature : a740da2002ff713c9ca9f5e74ff4fced92b55d57
  ***************************************************************************
*)

unit YTVideoSeries.API;

interface

function YTVideoSeries_GetTubeCode: integer;

function YTVideoSeries_GetSerialCode(const SerialLabel: string;
  const AutoCreate: boolean = true): integer;

function YTVideoSeries_GetSeasonCode(const SerialCode: integer;
  const SeasonLabel: string; const AutoCreate: boolean = true): integer;

procedure YTVideoSeries_UpdateSeason(const Code, OrderInSerial: integer;
  const RecordDate: string);

function YTVideoSeries_GetEpisodeCode(const SeasonCode: integer;
  const EpisodeLabel: string; const AutoCreate: boolean = true): integer;

procedure YTVideoSeries_UpdateEpisode(const Code, OrderInSeason: integer;
  const RecordDate: string);

procedure YTVideoSeries_CreateVideoTube(const VideoCode, TubeCode: integer);

implementation

uses
  System.Sysutils,
  FireDAC.Comp.Client,
  uDB,
  Olf.RTL.GenRandomID;

const
  CTubeLeTempsDUneTomate = 'YouTube - Le temps d''une tomate';

var
  YTVideoSeriesDB: tdb;

function getDB: TFDConnection;
begin
  if not assigned(YTVideoSeriesDB) then
    YTVideoSeriesDB := tdb.Create(nil);

  result := YTVideoSeriesDB.FDConnection1;
end;

function YTVideoSeries_GetTubeCode: integer;
begin
  try
    result := getDB.ExecSQLScalar('select code from tube where label=:1',
      [CTubeLeTempsDUneTomate]);
  except
    result := -1;
  end;
end;

function YTVideoSeries_GetSerialCode(const SerialLabel: string;
  const AutoCreate: boolean = true): integer;
begin
  try
    result := getDB.ExecSQLScalar('select code from serial where (label=:1)',
      [SerialLabel]);
  except
    result := -1;
  end;
  if (result < 1) and AutoCreate then
  begin
    getDB.ExecSQL('insert into serial (id,label) values (:1,:2)',
      [TOlfRandomIDGenerator.getIDBase62(15), SerialLabel]);
    result := YTVideoSeries_GetSerialCode(SerialLabel, false);
  end;
end;

function YTVideoSeries_GetSeasonCode(const SerialCode: integer;
  const SeasonLabel: string; const AutoCreate: boolean = true): integer;
begin
  try
    result := getDB.ExecSQLScalar
      ('select code from season where (serial_code=:1) and (label=:2)',
      [SerialCode, SeasonLabel]);
  except
    result := -1;
  end;
  if (result < 1) and AutoCreate then
  begin
    getDB.ExecSQL('insert into season (id,serial_code,label) values (:1,:2,:3)',
      [TOlfRandomIDGenerator.getIDBase62(15), SerialCode, SeasonLabel]);
    result := YTVideoSeries_GetSeasonCode(SerialCode, SeasonLabel, false);
  end;
end;

procedure YTVideoSeries_UpdateSeason(const Code, OrderInSerial: integer;
  const RecordDate: string);
begin
  if RecordDate.isempty then
    getDB.ExecSQL('update season set order_in_serial=:1 where code=:2',
      [OrderInSerial, Code])
  else
    getDB.ExecSQL
      ('update season set order_in_serial=:1, record_date=:2 where code=:3',
      [OrderInSerial, RecordDate, Code]);
end;

function YTVideoSeries_GetEpisodeCode(const SeasonCode: integer;
  const EpisodeLabel: string; const AutoCreate: boolean = true): integer;
var
  SerialCode: integer;
begin
  try
    result := getDB.ExecSQLScalar
      ('select code from video where (season_code=:1) and (label=:2)',
      [SeasonCode, EpisodeLabel]);
  except
    result := -1;
  end;
  if (result < 1) and AutoCreate then
  begin
    try
      SerialCode := getDB.ExecSQLScalar
        ('select serial_code from season where code=:1', [SeasonCode]);
    except
      result := -1;
      exit;
    end;
    getDB.ExecSQL
      ('insert into video (id,serial_code,season_code,label) values (:1,:2,:3,:4)',
      [TOlfRandomIDGenerator.getIDBase62(15), SerialCode, SeasonCode,
      EpisodeLabel]);
    result := YTVideoSeries_GetEpisodeCode(SeasonCode, EpisodeLabel, false);
  end;
end;

procedure YTVideoSeries_UpdateEpisode(const Code, OrderInSeason: integer;
  const RecordDate: string);
begin
  if RecordDate.isempty then
    getDB.ExecSQL('update video set order_in_season=:1 where code=:2',
      [OrderInSeason, Code])
  else
    getDB.ExecSQL
      ('update video set order_in_season=:1, record_date=:2 where code=:3',
      [OrderInSeason, RecordDate, Code]);
end;

procedure YTVideoSeries_CreateVideoTube(const VideoCode, TubeCode: integer);
var
  Code: integer;
begin
  try
    Code := getDB.ExecSQLScalar
      ('select tube_code from video_tube where (tube_code=:1) and (video_code=:2)',
      [TubeCode, VideoCode]);
  except
    Code := -1;
  end;
  if (Code < 1) then
    getDB.ExecSQL
      ('insert into video_tube (tube_code, video_code) values (:1,:2)',
      [TubeCode, VideoCode]);
end;

initialization

YTVideoSeriesDB := nil;

finalization

YTVideoSeriesDB.free;

end.
