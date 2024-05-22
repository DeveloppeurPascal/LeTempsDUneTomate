unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, Olf.FMX.AboutDialog,
  Olf.FMX.SelectDirectory, FMX.Media;

type
  TForm1 = class(TForm)
    Button1: TButton;
    OlfSelectDirectoryDialog1: TOlfSelectDirectoryDialog;
    OlfAboutDialog1: TOlfAboutDialog;
    MediaPlayer1: TMediaPlayer;
    MediaPlayerControl1: TMediaPlayerControl;
    procedure Button1Click(Sender: TObject);
  private
  protected
    procedure TraiterLaVideo(const AFilePath: string; Const ASaison: integer;
      var AEpisode: integer);
    procedure TraiterLEpisode(const AFilePath: string;
      Const ASaison, AEpisode, EpisodeDeLaSaison: integer;
      const DureeEpisodeEnSecondes: int64);
    procedure LancerCommandeEtAttendre(const Cmd: string);
    function SecondesToHHMMSS(const DureeEnSecondes: int64): string;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.IOUtils,
  System.Math,
  uConsts;

procedure TForm1.Button1Click(Sender: TObject);
var
  VideoFolder: string;
  VideoFiles: TStringDynArray;
  Saison, Episode: integer;
begin
  if OlfSelectDirectoryDialog1.Execute and
    TDirectory.Exists(OlfSelectDirectoryDialog1.Directory) then
  begin
    VideoFiles := TDirectory.GetFiles(OlfSelectDirectoryDialog1.Directory,
      function(const Path: string; const SearchRec: TSearchRec): Boolean
      begin
        result := string(SearchRec.Name).tolower.EndsWith('.mp4');
      end);
    if (length(VideoFiles) > 0) then
    begin
      // TODO : trier la liste
      Episode := 0;
      for Saison := 1 to length(VideoFiles) do
        TraiterLaVideo(VideoFiles[Saison - 1], Saison, Episode);
    end;
    // TODO : traiter le cas où pas de fichier
  end;
  // TODO : traiter le cas où pas de dossier sélectionné ou inexistant
end;

procedure TForm1.LancerCommandeEtAttendre(const Cmd: string);
begin
  // TODO : à compléter
  showmessage(Cmd);
end;

function TForm1.SecondesToHHMMSS(const DureeEnSecondes: int64): string;
var
  heures, minutes, secondes: int64;
begin
  secondes := DureeEnSecondes mod 60;
  minutes := DureeEnSecondes div 60;
  heures := minutes div 60;
  minutes := minutes mod 60;
  result := heures.tostring + ':' + minutes.tostring + ':' + secondes.tostring;
end;

procedure TForm1.TraiterLaVideo(const AFilePath: string; const ASaison: integer;
var AEpisode: integer);
begin
  // - récupération de sa durée et découpage en N vidéo de 20 à 25 minutes pour ne pas avoir une vidéo de fin vide (ou cumuler la fin de la première avec le début de la suivante)
  // => TMediaPlayer + lecture vidéo + get timestamp (si possible)
  MediaPlayer1.FileName := AFilePath;
  MediaPlayer1.Play;
  tthread.CreateAnonymousThread(
    procedure
    var
      DureeTotaleEnSecondes, NbEpisodes, DureeEpisodeEnSecondes: int64;
      EpisodeDeLaSaison: integer;
    begin
      sleep(2000); // TODO : à retirer
      tthread.Synchronize(nil,
        procedure
        begin
          DureeTotaleEnSecondes := round(MediaPlayer1.Duration /
            MediaTimeScale);
          MediaPlayer1.Stop;
        end);

      // TODO : à faire en thread une fois la récupération de la durée de la vidéo effectuée

      NbEpisodes := ceil(DureeTotaleEnSecondes / CDureeEpisodeEnSecondes);
      if (NbEpisodes < 1) then
        exit;

      DureeEpisodeEnSecondes := round(DureeTotaleEnSecondes / NbEpisodes);
      for EpisodeDeLaSaison := 0 to NbEpisodes - 1 do
      begin
//        inc(AEpisode);
//        TraiterLEpisode(AFilePath, ASaison, AEpisode, EpisodeDeLaSaison,
//          DureeEpisodeEnSecondes);
        TraiterLEpisode(AFilePath, ASaison, EpisodeDeLaSaison, EpisodeDeLaSaison,
          DureeEpisodeEnSecondes);
      end;
    end).start;
end;

procedure TForm1.TraiterLEpisode(const AFilePath: string;
const ASaison, AEpisode, EpisodeDeLaSaison: integer;
const DureeEpisodeEnSecondes: int64);
var
  Cmd: string;
  EpisodeFilePath: string;
  TempDir: string;
begin
  TempDir := tpath.combine(tpath.GetDirectoryName(AFilePath), 'temp');
  if not TDirectory.Exists(TempDir) then
    TDirectory.CreateDirectory(TempDir);

  EpisodeFilePath := tpath.combine(TempDir, 'episode_' + ASaison.tostring + '_'
    + AEpisode.tostring + '.mp4');

  // - découpage en X épisodes : la première de la durée normale, les suivantes de la durée + 10s (démarrage en fin de la précédente)
  if (EpisodeDeLaSaison = 0) then
    // => ./FFmpeg -ss 00:00 -to 20:00 -i VideoSource.mp4 ContenuDeLEpisode001.mp4
    LancerCommandeEtAttendre(cffmpeg + ' -ss 00:00 -to ' +
      SecondesToHHMMSS(DureeEpisodeEnSecondes) + ' -i "' + AFilePath + '" "' +
      EpisodeFilePath + '"')
  else
    // => ./FFmpeg -ss 19:50 -to 40:00 -i VideoSource.mp4 ContenuDeLEpisodeXXX.mp4
    LancerCommandeEtAttendre(cffmpeg + ' -ss ' +
      SecondesToHHMMSS(DureeEpisodeEnSecondes * (EpisodeDeLaSaison - 1) -
      CDureeRattrapageEpisodePrecedent) + ' -to ' +
      SecondesToHHMMSS(DureeEpisodeEnSecondes * EpisodeDeLaSaison) + ' -i "' +
      AFilePath + '" "' + EpisodeFilePath + '"')

    // - création des versions courtes de chaque épisode
    // => ./ffmpeg -r 600 -i ContenuDeLEpisode001.mp4 -r 30 -t 50 -map 0:v VersionCourte.mp4
    // => ./ffmpeg -r 600 -ss 0:10 -i ContenuDeLEpisodeXXX.mp4 -r 30 -t 50 -map 0:v VersionCourte.mp4
    //
    // - ajout du "précédemment" aux versions courtes
    // => ./ffmpeg -i VersionCourte.mkv  -i precedemment.png -filter_complex overlay VersionCourteAUtiliser.mp4
    //
    // - création des images d'intro de chaque épisode
    // => faire des PNG dans Delphi en 1920x1080
    //
    // - recomposition de chaque épisode pour version finale (cover+précédemment+contenu+à suivre)
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisode001.png -i ContenuDeLEpisode001.mkv -loop 1 -t 5 -i ASuivre.png -filter_complex 'concat=n=3' EpisodeAPublier001.mkv
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisodeXXX.png -i VersionCourteAUtiliser(XXX-1).mkv -i ContenuDeLEpisodeXXX.mkv -loop 1 -t 5 -i ASuivre.png -filter_complex 'concat=n=4' EpisodeAPublierXXX.mkv
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisodeXXX.png -i VersionCourteAUtiliser(XXX-1).mkv -i ContenuDeLEpisodeXXX.mkv -loop 1 -t 5 -i TheEndPourYouTube.png -filter_complex 'concat=n=4' EpisodeAPublierXXX.mkv

end;

end.
