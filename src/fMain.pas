unit fMain;

interface

{$IF Defined(MACOS)}
{$ELSEIF not Defined(DEBUG)}
{$MESSAGE FATAL 'Programme non testé pour cette plateforme. A exécuter en DEBUG uniquement. Merci de reporter les correctifs éventuels sous forme de PULL REQUEST.'}
{$ENDIF}

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  Olf.FMX.AboutDialog,
  Olf.FMX.SelectDirectory,
  FMX.Media,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  System.ImageList,
  FMX.ImgList,
  Olf.FMX.TextImageFrame,
  FMX.Objects,
  FMX.Layouts,
  FMX.Edit,
  uDMLogo;

type
  TfrmMain = class(TForm)
    Button1: TButton;
    OlfSelectDirectoryDialog1: TOlfSelectDirectoryDialog;
    OlfAboutDialog1: TOlfAboutDialog;
    MediaPlayer1: TMediaPlayer;
    MediaPlayerControl1: TMediaPlayerControl;
    Memo1: TMemo;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure OlfAboutDialog1URLClick(const AURL: string);
    procedure FormCreate(Sender: TObject);
  private
  protected
    /// <summary>
    /// Traite une vidéo: fait son découpage en épisode
    /// </summary>
    procedure TraiterLaSaison(const AFilePath: string;
      var Saison, Episode: integer);
    /// <summary>
    /// Traite un épisode extrait de la vidéo complète : création de la page de titre, de l'extrait, du raccourci, ...
    /// </summary>
    procedure TraiterLEpisode(const AFilePath: string; Const Saison: integer;
      var Episode: integer; const EpisodeDeLaSaison: integer;
      const DureeEpisodeEnSecondes: int64);
    /// <summary>
    /// Execute FFmpeg avec les paramètres passés le le chemin du fichier de destination à générer
    /// </summary>
    /// <remarks>
    /// La fin de la commande est déterminée par la taille (ou son changement) et l'existence du fichier à obtenir.
    /// </remarks>
    procedure ExecuteFFmpegAndWait(const AParams, DestinationFilePath: string);
    /// <summary>
    /// converti une durée en secondes vers un format HHH:MM:SS textuel (pour la ligne de commande de FFmpeg)
    /// </summary>
    function SecondesToHHMMSS(const DureeEnSecondes: int64): string;
    /// <summary>
    /// Ajoute une vidéo dans la file d'attente de traitement
    /// </summary>
    procedure AddVideoFile(const FilePath: string);
    /// <summary>
    /// Extrait la prochaine vidéo à traiter de la file d'attente de fichiers à traiter
    /// </summary>
    function GetVideoFile: string;
    /// <summary>
    /// Video la file d'attente, fichier par fichier pour générer les épisodes
    /// </summary>
    procedure TraiteFileDAttente;
    /// <summary>
    /// Ajoute le texte dans le TMemo à l'écran en guise d'historique (en faisant attention aux threads)
    /// </summary>
    procedure AddLog(Text: string; isTitle: boolean = false);
    /// <summary>
    /// Retourne le chemin vers la vidéo avec overlay "précédemment" depuis le chemin d'un épisode
    /// </summary>
    function GetPrecedemmentFilePath(const EpisodeFilePath: string): string;
    /// <summary>
    /// Affichage d'un texte graphique par dessus une image
    /// </summary>
    /// <remarks>
    /// inspiré de GenerateVideoTitlePages() de Video Title Page Generator
    /// https://videotitlepagegenerator.olfsoftware.fr
    /// </remarks>
    procedure CreateStartCover(Const Title: string;
      Const Saison, Episode: integer; Const FileName: string);
    procedure CreateEndCover(Const Title: string;
      Const Saison, Episode: integer; Const FileName: string);
    function getConvertedCharImageIndex(Sender: TOlfFMXTextImageFrame;
      AChar: char): integer;
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
{$IF Defined(MACOS)}
  Posix.Stdlib,
{$ELSEIF Defined(MSWINDOWS)}
  Winapi.ShellAPI,
  Winapi.Windows,
{$ENDIF}
  System.Generics.Collections,
  System.IOUtils,
  System.Math,
  uConsts,
  u_urlOpen,
  udmAdobeStock_286917767;

type
  TBitmap = FMX.Graphics.TBitmap;

var
  VideosATraiter: TQueue<string>;

procedure TfrmMain.AddLog(Text: string; isTitle: boolean);
begin
  tthread.Queue(nil,
    procedure
    begin
      if isTitle then
      begin
        Memo1.lines.Add('');
        Memo1.lines.Add('**********');
        Memo1.lines.Add('* ' + Text);
        Memo1.lines.Add('**********');
        Memo1.lines.Add('');
      end
      else
        Memo1.lines.Add(Text);
      Memo1.GoToTextEnd;
    end);
end;

procedure TfrmMain.AddVideoFile(const FilePath: string);
begin
  System.TMonitor.Enter(VideosATraiter);
  try
    VideosATraiter.Enqueue(FilePath);
  finally
    System.TMonitor.Exit(VideosATraiter);
  end;
  AddLog('Fichier "' + tpath.GetFileNameWithoutExtension(FilePath) +
    '" ajouté à la file d''attente.');
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  VideoFiles: TStringDynArray;
  i: integer;
begin
  if OlfSelectDirectoryDialog1.Execute and
    TDirectory.Exists(OlfSelectDirectoryDialog1.Directory) then
  begin
    VideoFiles := TDirectory.GetFiles(OlfSelectDirectoryDialog1.Directory,
      function(const Path: string; const SearchRec: TSearchRec): boolean
      begin
        result := string(SearchRec.Name).tolower.EndsWith('.mp4');
      end);
    if (length(VideoFiles) > 0) then
    begin
      // TODO : trier la liste

      for i := 0 to length(VideoFiles) - 1 do
        AddVideoFile(VideoFiles[i]);

      TraiteFileDAttente;
    end;
    // TODO : traiter le cas où pas de fichier
  end;
  // TODO : traiter le cas où pas de dossier sélectionné ou inexistant
end;

procedure TfrmMain.CreateEndCover(const Title: string;
const Saison, Episode: integer; Const FileName: string);
var
  img: timage;
  txtTitle, txtEpisode: TOlfFMXTextImageFrame;
  lTitle, lEpisode: TLayout;
  bmp: TBitmap;
begin
  img := timage.create(self);
  try
    img.parent := self;
    img.width := CVideoWidth / img.Bitmap.BitmapScale;
    img.height := CVideoHeight / img.Bitmap.BitmapScale;
    img.Bitmap.LoadFromFile(CPageFinEpisode);

    lTitle := TLayout.create(self);
    try
      lTitle.parent := img;
      lTitle.Align := TAlignLayout.contents;

      txtTitle := TOlfFMXTextImageFrame.create(self);
      try
        txtTitle.parent := lTitle;
        txtTitle.Font := dmAdobeStock_286917767.ImageList;
        txtTitle.OnGetImageIndexOfUnknowChar := getConvertedCharImageIndex;
        txtTitle.Align := TAlignLayout.Center;
        txtTitle.height := img.height * 0.1;
        txtTitle.Text := Title;
        // TODO : contrôler que ça déborde pas en largeur

        lEpisode := TLayout.create(self);
        try
          lEpisode.parent := img;
          lEpisode.Align := TAlignLayout.Bottom;
          lEpisode.margins.Bottom := img.height * 0.1;
          lEpisode.margins.Right := lEpisode.margins.Bottom;
          lEpisode.height := txtTitle.height * 0.6;

          txtEpisode := TOlfFMXTextImageFrame.create(self);
          try
            txtEpisode.parent := lEpisode;
            txtEpisode.Font := dmAdobeStock_286917767.ImageList;
            txtEpisode.OnGetImageIndexOfUnknowChar :=
              getConvertedCharImageIndex;
            txtEpisode.Align := TAlignLayout.Center;
            txtEpisode.height := lEpisode.height;
            txtEpisode.Text := 'A bientôt pour la suite...';

            bmp := img.MakeScreenshot;
            try
              bmp.SaveToFile(FileName);
            finally
              bmp.free;
            end;
          finally
            txtEpisode.free;
          end;
        finally
          lEpisode.free;
        end;
      finally
        txtTitle.free;
      end;
    finally
      lTitle.free;
    end;
  finally
    img.free;
  end;
end;

procedure TfrmMain.CreateStartCover(const Title: string;
const Saison, Episode: integer; Const FileName: string);
var
  img: timage;
  txtTitle, txtEpisode: TOlfFMXTextImageFrame;
  lTitle, lEpisode: TLayout;
  bmp: TBitmap;
begin
  img := timage.create(self);
  try
    img.parent := self;
    img.width := CVideoWidth / img.Bitmap.BitmapScale;
    img.height := CVideoHeight / img.Bitmap.BitmapScale;
    img.Bitmap.LoadFromFile(CPageIntro);

    lTitle := TLayout.create(self);
    try
      lTitle.parent := img;
      lTitle.Align := TAlignLayout.contents;

      txtTitle := TOlfFMXTextImageFrame.create(self);
      try
        txtTitle.parent := lTitle;
        txtTitle.Font := dmAdobeStock_286917767.ImageList;
        txtTitle.OnGetImageIndexOfUnknowChar := getConvertedCharImageIndex;
        txtTitle.Align := TAlignLayout.Center;
        txtTitle.height := img.height * 0.1;
        txtTitle.Text := Title;
        // TODO : contrôler que ça déborde pas en largeur

        lEpisode := TLayout.create(self);
        try
          lEpisode.parent := img;
          lEpisode.Align := TAlignLayout.Bottom;
          lEpisode.margins.Bottom := img.height * 0.05;
          lEpisode.margins.Right := lEpisode.margins.Bottom;
          lEpisode.height := txtTitle.height * 0.6;

          txtEpisode := TOlfFMXTextImageFrame.create(self);
          try
            txtEpisode.parent := lEpisode;
            txtEpisode.Font := dmAdobeStock_286917767.ImageList;
            txtEpisode.OnGetImageIndexOfUnknowChar :=
              getConvertedCharImageIndex;
            txtEpisode.Align := TAlignLayout.Center;
            txtEpisode.height := lEpisode.height;
            txtEpisode.Text := 'Episode ' + Episode.ToString;

            bmp := img.MakeScreenshot;
            try
              bmp.SaveToFile(FileName);
            finally
              bmp.free;
            end;
          finally
            txtEpisode.free;
          end;
        finally
          lEpisode.free;
        end;
      finally
        txtTitle.free;
      end;
    finally
      lTitle.free;
    end;
  finally
    img.free;
  end;
end;

function TfrmMain.getConvertedCharImageIndex(Sender: TOlfFMXTextImageFrame;
AChar: char): integer;
begin
  result := -1;
  if (result < 0) and CharInSet(AChar, ['a' .. 'z']) then
    result := Sender.getImageIndexOfChar('_' + AChar);
  if (result < 0) and CharInSet(AChar, ['a' .. 'z']) then
    result := Sender.getImageIndexOfChar(chr(ord('A') + ord(AChar) - ord('a')));
  if (result < 0) and (AChar = '?') then
    result := Sender.getImageIndexOfChar('interrogation');
  if (result < 0) and (AChar = '$') then
    result := Sender.getImageIndexOfChar('dollar');
  if (result < 0) and (AChar = '!') then
    result := Sender.getImageIndexOfChar('exclamation');
  if (result < 0) and (AChar = '&') then
    result := Sender.getImageIndexOfChar('et');
  if (result < 0) and (AChar = '%') then
    result := Sender.getImageIndexOfChar('pourcent');
  if (result < 0) and (AChar = '''') then
    result := Sender.getImageIndexOfChar('apostrophe');
  if (result < 0) and (AChar = ',') then
    result := Sender.getImageIndexOfChar('virgule');
  if (result < 0) and (AChar = '=') then
    result := Sender.getImageIndexOfChar('egale');
  if (result < 0) and (AChar = '-') then
    result := Sender.getImageIndexOfChar('moins');
  if (result < 0) and (AChar = '+') then
    result := Sender.getImageIndexOfChar('plus');
  if (result < 0) and (AChar = 'à') then
    result := Sender.getImageIndexOfChar('_agrave');
  if (result < 0) and (AChar = 'à') then
    result := getConvertedCharImageIndex(Sender, 'a');
  if (result < 0) and (AChar = 'é') then
    result := Sender.getImageIndexOfChar('_eaigu');
  if (result < 0) and (AChar = 'è') then
    result := Sender.getImageIndexOfChar('_egrave');
  if (result < 0) and (AChar = 'ê') then
    result := Sender.getImageIndexOfChar('_ecirconflexe');
  if (result < 0) and (AChar = 'ë') then
    result := Sender.getImageIndexOfChar('_etrema');
  if (result < 0) and CharInSet(AChar, ['é', 'è', 'ê', 'ë']) then
    result := getConvertedCharImageIndex(Sender, 'e');
  if (result < 0) and (AChar = 'ô') then
    result := Sender.getImageIndexOfChar('_ocirconflexe');
  if (result < 0) and (AChar = 'ö') then
    result := Sender.getImageIndexOfChar('_otrema');
  if (result < 0) and CharInSet(AChar, ['ô', 'ö']) then
    result := getConvertedCharImageIndex(Sender, 'o');
  if (result < 0) and (AChar = 'î') then
    result := Sender.getImageIndexOfChar('_icirconflexe');
  if (result < 0) and (AChar = 'ï') then
    result := Sender.getImageIndexOfChar('_itrema');
  if (result < 0) and CharInSet(AChar, ['î', 'ï']) then
    result := getConvertedCharImageIndex(Sender, 'i');
  if (result < 0) and (AChar = 'û') then
    result := Sender.getImageIndexOfChar('_ucirconflexe');
  if (result < 0) and (AChar = 'ü') then
    result := Sender.getImageIndexOfChar('_utrema');
  if (result < 0) and (AChar = 'ù') then
    result := Sender.getImageIndexOfChar('_ugrave');
  if (result < 0) and CharInSet(AChar, ['û', 'ü', 'ù']) then
    result := getConvertedCharImageIndex(Sender, 'u');
  if (result < 0) and (AChar = 'oe') then
    result := Sender.getImageIndexOfChar('_oe');
  if (result < 0) and (AChar = 'OE') then
    result := Sender.getImageIndexOfChar('OE');
  if (result < 0) and (AChar = '.') then
    result := Sender.getImageIndexOfChar('point');
  if (result < 0) and (AChar = ':') then
    result := Sender.getImageIndexOfChar('deuxpoint');
  if (result < 0) and (AChar = ':') then
    result := Sender.getImageIndexOfChar('deux-point');
  if (result < 0) and (AChar = ';') then
    result := Sender.getImageIndexOfChar('pointvirgule');
  if (result < 0) and (AChar = ';') then
    result := Sender.getImageIndexOfChar('point-virgule');
  if (result < 0) and CharInSet(AChar, ['.', ',', ';', ':', '!', '''']) then
    result := getConvertedCharImageIndex(Sender, ' ');
end;

function TfrmMain.GetPrecedemmentFilePath(const EpisodeFilePath
  : string): string;
begin
  result := tpath.Combine(tpath.GetDirectoryName(EpisodeFilePath),
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '_precedemment.mp4');
end;

function TfrmMain.GetVideoFile: string;
begin
  System.TMonitor.Enter(VideosATraiter);
  try
    if (VideosATraiter.Count > 0) then
      result := VideosATraiter.Dequeue
    else
      result := '';
  finally
    System.TMonitor.Exit(VideosATraiter);
  end;
end;

procedure TfrmMain.ExecuteFFmpegAndWait(const AParams,
  DestinationFilePath: string);
var
  LParams: string;
begin
{$IFDEF DEBUG}
  LParams := '-y ' + AParams;
  AddLog('"' + CFFmpeg + '" ' + LParams + ' "' + DestinationFilePath + '"');
{$ELSE}
  LParams := '-y -loglevel error ' + AParams;
{$ENDIF}
{$IF Defined(MSWINDOWS)}
  ShellExecute(0, CFFmpeg, PWideChar(LParams + ' "' + DestinationFilePath +
    '"'), nil, nil, SW_SHOWNORMAL);
{$ELSEIF Defined(MACOS)}
  _system(PAnsiChar(ansistring('"' + CFFmpeg + '" ' + LParams + ' "' +
    DestinationFilePath + '"')));
{$ELSE}
{$MESSAGE FATAL 'Platform not available.'}
{$ENDIF}
  AddLog('Commande traitée.');
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  caption := OlfAboutDialog1.Titre + ' v' + OlfAboutDialog1.VersionNumero;
  // TODO : à compléter (debug, nom projet, ...)
end;

procedure TfrmMain.OlfAboutDialog1URLClick(const AURL: string);
begin
  url_Open_In_Browser(AURL);
end;

function TfrmMain.SecondesToHHMMSS(const DureeEnSecondes: int64): string;
  function ToString2(nb: int64): string;
  begin
    result := nb.ToString;
    while (result.length < 2) do
      result := '0' + result;
  end;

var
  heures, minutes, secondes: int64;
begin
  secondes := DureeEnSecondes mod 60;
  minutes := DureeEnSecondes div 60;
  heures := minutes div 60;
  minutes := minutes mod 60;
  result := ToString2(heures) + ':' + ToString2(minutes) + ':' +
    ToString2(secondes);
end;

procedure TfrmMain.TraiteFileDAttente;
begin
  Button1.enabled := false;
  Edit1.enabled := Button1.enabled;

  tthread.CreateAnonymousThread(
    procedure
    var
      VideoFilePath: string;
      Saison, Episode: integer;
    begin
      AddLog('Démarrage du traitement.', true);
      Saison := 0;
      Episode := 0;
      while (not tthread.CheckTerminated) do
      begin
        VideoFilePath := GetVideoFile;

        if VideoFilePath.IsEmpty then
          break;

        TraiterLaSaison(VideoFilePath, Saison, Episode);
      end;
      AddLog('Fin du traitement.', true);
      tthread.Queue(nil,
        procedure
        begin
          Button1.enabled := true;
          Edit1.enabled := Button1.enabled;
        end);
    end).Start;
end;

procedure TfrmMain.TraiterLaSaison(const AFilePath: string;
var Saison, Episode: integer);

var
  Erreur: boolean;
  DureeTotaleEnSecondes, NbEpisodes, DureeEpisodeEnSecondes: int64;
  EpisodeDeLaSaison: integer;
  i: integer;
begin
  inc(Saison);

  AddLog('Saison ' + Saison.ToString + ' => ' +
    tpath.GetFileNameWithoutExtension(AFilePath), true);

  Erreur := false;
  // - récupération de sa durée et découpage en N vidéo de 20 à 25 minutes pour ne pas avoir une vidéo de fin vide (ou cumuler la fin de la première avec le début de la suivante)
  // => TMediaPlayer + lecture vidéo + get timestamp (si possible)
  tthread.Synchronize(nil,
    procedure
    begin
      try
        MediaPlayer1.FileName := AFilePath;
        MediaPlayer1.Play;
      except
        Erreur := true;
        raise;
      end;
    end);

  if Erreur then
    Exit;

  i := 0;
  repeat
    sleep(1000);
    tthread.Synchronize(nil,
      procedure
      begin
        if (MediaPlayer1.Duration > 0) then
        begin
          DureeTotaleEnSecondes := round(MediaPlayer1.Duration /
            MediaTimeScale);
          MediaPlayer1.Stop;
        end;
      end);
    inc(i);
  until tthread.CheckTerminated or (DureeTotaleEnSecondes > 0) or (i > 60);

  AddLog('Durée de la vidéo : ' + SecondesToHHMMSS(DureeTotaleEnSecondes));

  if DureeTotaleEnSecondes < 1 then
    Exit;

  NbEpisodes := ceil(DureeTotaleEnSecondes / CDureeEpisodeEnSecondes);

  AddLog('Nb épisodes : ' + NbEpisodes.ToString);

  if (NbEpisodes < 1) then
    Exit;

  DureeEpisodeEnSecondes := round(DureeTotaleEnSecondes / NbEpisodes);

  AddLog('Durée d''un épisode : ' + SecondesToHHMMSS(DureeEpisodeEnSecondes));

  for EpisodeDeLaSaison := 1 to NbEpisodes do
    TraiterLEpisode(AFilePath, Saison, Episode, EpisodeDeLaSaison,
      DureeEpisodeEnSecondes);
end;

procedure TfrmMain.TraiterLEpisode(const AFilePath: string;
Const Saison: integer; var Episode: integer; const EpisodeDeLaSaison: integer;
const DureeEpisodeEnSecondes: int64);
var
  EpisodeFilePath, VersionCourteFilePath, EpisodeFinalFilePath,
    ImgStartFilePath, ImgEndFilePath: string;
  TempDir, FinalDir: string;
  lEpisode: integer;
begin
  inc(Episode);
  lEpisode := Episode;

  AddLog('Traitement épisode ' + Episode.ToString);

  TempDir := tpath.Combine(tpath.GetDirectoryName(AFilePath), 'temp');
  if not TDirectory.Exists(TempDir) then
    TDirectory.CreateDirectory(TempDir);

  FinalDir := tpath.Combine(tpath.GetDirectoryName(AFilePath), 'final');
  if not TDirectory.Exists(FinalDir) then
    TDirectory.CreateDirectory(FinalDir);

  EpisodeFilePath := tpath.Combine(TempDir, 'episode_' + Saison.ToString + '_' +
    Episode.ToString + '.mp4');

  AddLog('=> extraction depuis la vidéo complète');

  // - découpage en X épisodes : la première de la durée normale, les suivantes de la durée + 10s (démarrage en fin de la précédente)
  if (EpisodeDeLaSaison = 1) then
    // => ./FFmpeg -ss 00:00 -to 20:00 -i VideoSource.mp4 ContenuDeLEpisode001.mp4
    ExecuteFFmpegAndWait('-ss 00:00 -to ' +
      SecondesToHHMMSS(DureeEpisodeEnSecondes) + ' -i "' + AFilePath + '"',
      EpisodeFilePath)
  else
    // => ./FFmpeg -ss 19:50 -to 40:00 -i VideoSource.mp4 ContenuDeLEpisodeXXX.mp4
    ExecuteFFmpegAndWait('-ss ' + SecondesToHHMMSS(DureeEpisodeEnSecondes *
      (EpisodeDeLaSaison - 1) - CDureeRattrapageEpisodePrecedent) + ' -to ' +
      SecondesToHHMMSS(DureeEpisodeEnSecondes * EpisodeDeLaSaison) + ' -i "' +
      AFilePath + '"', EpisodeFilePath);

  VersionCourteFilePath :=
    tpath.Combine(tpath.GetDirectoryName(EpisodeFilePath),
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '_short.mp4');

  AddLog('=> génération de la version courte');

  // - création des versions courtes de chaque épisode
  if EpisodeDeLaSaison = 1 then
    // => ./ffmpeg -r 600 -i ContenuDeLEpisode001.mp4 -r 30 -t 50 -map 0:v VersionCourte.mp4
    ExecuteFFmpegAndWait('-r ' + round(30 * DureeEpisodeEnSecondes / 60)
      .ToString + ' -i "' + EpisodeFilePath + '" -r 30 -t 50 -map 0:v',
      VersionCourteFilePath)
  else
    // => ./ffmpeg -r 600 -ss 0:10 -i ContenuDeLEpisodeXXX.mp4 -r 30 -t 50 -map 0:v VersionCourte.mp4
    ExecuteFFmpegAndWait('-r ' + round(30 * DureeEpisodeEnSecondes / 60)
      .ToString + ' -ss 10 -i "' + EpisodeFilePath + '" -r 30 -t 50 -map 0:v',
      VersionCourteFilePath);

  AddLog('=> ajout de l''overlay "Précédemment"');

  // - ajout du "précédemment" aux versions courtes
  // => ./ffmpeg -i VersionCourte.mkv  -i precedemment.png -filter_complex overlay VersionCourteAUtiliser.mp4
  ExecuteFFmpegAndWait('-i "' + VersionCourteFilePath + '" -i "' + CPrecedemment
    + '"  -filter_complex overlay', GetPrecedemmentFilePath(EpisodeFilePath));

  AddLog('=> génération des images de début et fin');

  // - création des images d'intro de chaque épisode
  // => faire des PNG dans Delphi en 1920x1080
  ImgStartFilePath := tpath.Combine(tpath.GetDirectoryName(EpisodeFilePath),
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '-start.png');
  tthread.Synchronize(nil,
    procedure
    begin
      CreateStartCover(Edit1.Text, Saison, lEpisode, ImgStartFilePath);
    end);

  ImgEndFilePath := tpath.Combine(tpath.GetDirectoryName(EpisodeFilePath),
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '-end.png');
  tthread.Synchronize(nil,
    procedure
    begin
      CreateEndCover(Edit1.Text, Saison, lEpisode, ImgEndFilePath);
    end);

  EpisodeFinalFilePath := tpath.Combine(FinalDir,
    tpath.GetFileName(EpisodeFilePath));

  AddLog('=> export de la vidéo finale');

  // - recomposition de chaque épisode pour version finale (cover+précédemment+contenu+à suivre)
  if EpisodeDeLaSaison = 1 then
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisode001.png -i ContenuDeLEpisode001.mkv -loop 1 -t 5 -i ASuivre.png -filter_complex 'concat=n=3;adelay=3s:all=1' EpisodeAPublier001.mkv
    ExecuteFFmpegAndWait('-loop 1 -t ' + cdureeintro.ToString + ' -i "' +
      ImgStartFilePath + '" -i "' + EpisodeFilePath + '" -loop 1 -t ' +
      cdureefin.ToString + ' -i "' + ImgEndFilePath +
      '" -filter_complex ''concat=n=3;adelay=' + cdureeintro.ToString +
      's:all=1''', EpisodeFinalFilePath)
  else
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisodeXXX.png -i VersionCourteAUtiliser(XXX-1).mkv -i ContenuDeLEpisodeXXX.mkv -loop 1 -t 5 -i ASuivre.png -filter_complex 'concat=n=4;adelay=53s:all=1' EpisodeAPublierXXX.mkv
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisodeXXX.png -i VersionCourteAUtiliser(XXX-1).mkv -i ContenuDeLEpisodeXXX.mkv -loop 1 -t 5 -i TheEndPourYouTube.png -filter_complex 'concat=n=4;adelay=53s:all=1' EpisodeAPublierXXX.mkv
    ExecuteFFmpegAndWait('-loop 1 -t ' + cdureeintro.ToString + ' -i "' +
      ImgStartFilePath + '" -i "' + GetPrecedemmentFilePath
      (tpath.Combine(TempDir, 'episode_' + Saison.ToString + '_' + (Episode - 1)
      .ToString + '.mp4')) + '" -i "' + EpisodeFilePath + '" -loop 1 -t ' +
      cdureefin.ToString + ' -i "' + ImgEndFilePath +
      '" -filter_complex ''concat=n=4;adelay=' + (cdureeintro + CDureeRecap)
      .ToString + 's:all=1''', EpisodeFinalFilePath);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
VideosATraiter := TQueue<string>.create;

finalization

VideosATraiter.free;

end.
