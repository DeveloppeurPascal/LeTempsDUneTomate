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
  uDMLogo,
  FMX.Menus;

type
  TfrmMain = class(TForm)
    OlfSelectDirectoryDialog1: TOlfSelectDirectoryDialog;
    OlfAboutDialog1: TOlfAboutDialog;
    MediaPlayer1: TMediaPlayer;
    mmoLog: TMemo;
    edtTitle: TEdit;
    edtVideoNamePrefixe: TEdit;
    edtImgBackgroundEnd: TEdit;
    edtImgOverlay: TEdit;
    edtImgBackgroundStart: TEdit;
    lProject: TLayout;
    ToolBar1: TToolBar;
    btnOpenProject: TButton;
    btnQuit: TButton;
    btnAbout: TButton;
    btnCloseProject: TButton;
    btnStart: TButton;
    lBlockScreen: TLayout;
    aniBlockScreen: TAniIndicator;
    rBlockScreen: TRectangle;
    GridPanelLayout1: TGridPanelLayout;
    btnSaveProject: TButton;
    btnCancel: TButton;
    edtImgBackgroundStartSelect: TEllipsesEditButton;
    edtImgOverlaySelect: TEllipsesEditButton;
    edtImgBackgroundEndSelect: TEllipsesEditButton;
    OpenDialog1: TOpenDialog;
    MainMenu1: TMainMenu;
    mnuMacOS: TMenuItem;
    mnuFile: TMenuItem;
    mnuProject: TMenuItem;
    mnuTools: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    mnuToolsOptions: TMenuItem;
    mnuProjectOptions: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSave: TMenuItem;
    mnuFileClose: TMenuItem;
    mnuFileQuit: TMenuItem;
    mnuProjectStart: TMenuItem;
    procedure OlfAboutDialog1URLClick(const AURL: string);
    procedure FormCreate(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnOpenProjectClick(Sender: TObject);
    procedure btnCloseProjectClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure edtImgBackgroundStartSelectClick(Sender: TObject);
    procedure edtImgOverlaySelectClick(Sender: TObject);
    procedure edtImgBackgroundEndSelectClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveProjectClick(Sender: TObject);
    procedure mnuProjectOptionsClick(Sender: TObject);
    procedure mnuToolsOptionsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure InitMainMenuForMacOS;
    procedure InitProjectFields;
    function ProjectFieldsHasChanged: Boolean;
  protected
    /// <summary>
    /// Traite une vidéo: fait son découpage en épisode
    /// </summary>
    procedure TraiterLaSaison(const AFilePath: string;
      var Saison, Episode: integer; const YTVS_TubeCode, YTVS_SerialCode
      : integer);
    /// <summary>
    /// Traite un épisode extrait de la vidéo complète : création de la page de titre, de l'extrait, du raccourci, ...
    /// </summary>
    procedure TraiterLEpisode(const AFilePath: string; Const Saison: integer;
      var Episode: integer; const EpisodeDeLaSaison: integer;
      const DureeEpisodeEnSecondes: int64;
      const YTVS_TubeCode, YTVS_SeasonCode: integer;
      const YTVS_RecordDate: string);
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
    procedure AddLog(Text: string; isTitle: Boolean = false);
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
    procedure InitMainFormCaption;
    procedure InitAboutDialogDescriptionAndLicense;
    procedure PicResize(const FromFilePath, ToFilePath: string;
      const NewWidth: integer = -1; const NewHeight: integer = -1);
    procedure UpdateButtons;
    procedure BlockScreen(Const AEnabled: Boolean);
    procedure InitProjectOnScreen;
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
  u_urlOpen,
  udmAdobeStock_286917767,
  uConfig,
  uProject,
  YTVideoSeries.API,
  fOptions,
  fProjectOptions,
  FMX.DialogService;

type
  TBitmap = FMX.Graphics.TBitmap;

var
  VideosATraiter: TQueue<string>;

procedure TfrmMain.AddLog(Text: string; isTitle: Boolean);
begin
  tthread.Queue(nil,
    procedure
    begin
      if isTitle then
      begin
        mmoLog.lines.Add('');
        mmoLog.lines.Add('**********');
        mmoLog.lines.Add('* ' + Text);
        mmoLog.lines.Add('**********');
        mmoLog.lines.Add('');
      end
      else
        mmoLog.lines.Add(Text);
      mmoLog.GoToTextEnd;
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

procedure TfrmMain.BlockScreen(const AEnabled: Boolean);
begin
  if AEnabled then
  begin
    lBlockScreen.Visible := true;
    lBlockScreen.BringToFront;
    rBlockScreen.BringToFront;
    aniBlockScreen.Enabled := true;
    aniBlockScreen.BringToFront;
    ToolBar1.Visible := false;
  end
  else
  begin
    aniBlockScreen.Enabled := false;
    lBlockScreen.Visible := false;
    ToolBar1.Visible := true;
  end;
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  OlfAboutDialog1.Execute;
end;

procedure TfrmMain.btnCancelClick(Sender: TObject);
begin
  InitProjectFields;
end;

procedure TfrmMain.btnCloseProjectClick(Sender: TObject);
begin
  if tproject.isOpened and ProjectFieldsHasChanged then
  begin
    TDialogService.MessageDialog
      ('Do you want to save your changes before closing ?',
      tmsgdlgtype.mtConfirmation, mbyesno, tmsgdlgbtn.mbYes, 0,
      procedure(const AModalResult: TModalResult)
      begin
        case AModalResult of
          mryes:
            tthread.forcequeue(nil,
              procedure
              begin
                btnSaveProjectClick(Sender);
                btnCloseProjectClick(Sender);
              end);
        else
          tthread.forcequeue(nil,
            procedure
            begin
              btnCancelClick(Sender);
              btnCloseProjectClick(Sender);
            end);
        end;
      end);
  end
  else
  begin
    tproject.Close;
    InitProjectOnScreen;

    UpdateButtons;
  end;
end;

procedure TfrmMain.btnOpenProjectClick(Sender: TObject);
begin
  if OlfSelectDirectoryDialog1.Execute and
    TDirectory.Exists(OlfSelectDirectoryDialog1.Directory) then
  begin
    tproject.Open(OlfSelectDirectoryDialog1.Directory);
    InitProjectOnScreen;
  end;

  UpdateButtons;
end;

procedure TfrmMain.btnQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnSaveProjectClick(Sender: TObject);
begin
  tproject.Title := edtTitle.Text;
  tproject.VideoFilePrefix := edtVideoNamePrefixe.Text;
  tproject.StartBackgroundImage := edtImgBackgroundStart.Text;
  tproject.OverlayImage := edtImgOverlay.Text;
  tproject.EndBackgroundImage := edtImgBackgroundEnd.Text;
  tproject.save;

  InitProjectFields;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
var
  VideoFiles: TStringDynArray;
  i: integer;
begin
  if ProjectFieldsHasChanged then
    raise exception.create
      ('You have unsaved changes on the project, save or cancel them before starting.');

  VideoFiles := TDirectory.GetFiles(tproject.GetFolder,
    function(const Path: string; const SearchRec: TSearchRec): Boolean
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
end;

procedure TfrmMain.CreateEndCover(const Title: string;
const Saison, Episode: integer; Const FileName: string);
var
  img: timage;
  txtTitle, txtEpisode: TOlfFMXTextImageFrame;
  lTitle, lEpisode: TLayout;
  bmp: TBitmap;
begin
  if tfile.Exists(FileName) then
    Exit;

  img := timage.create(self);
  try
    img.parent := self;
    img.width := tproject.VideoWidth / img.Bitmap.BitmapScale;
    img.height := tproject.VideoHeight / img.Bitmap.BitmapScale;
    img.Bitmap.LoadFromFile(tproject.EndBackgroundImage);

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
  if tfile.Exists(FileName) then
    Exit;

  img := timage.create(self);
  try
    img.parent := self;
    img.width := tproject.VideoWidth / img.Bitmap.BitmapScale;
    img.height := tproject.VideoHeight / img.Bitmap.BitmapScale;
    img.Bitmap.LoadFromFile(tproject.StartBackgroundImage);

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

procedure TfrmMain.edtImgBackgroundEndSelectClick(Sender: TObject);
begin
  if OpenDialog1.InitialDir.IsEmpty then
    OpenDialog1.InitialDir := tproject.GetFolder;

  if OpenDialog1.Execute then
    edtImgBackgroundEnd.Text := OpenDialog1.FileName;
end;

procedure TfrmMain.edtImgBackgroundStartSelectClick(Sender: TObject);
begin
  if OpenDialog1.InitialDir.IsEmpty then
    OpenDialog1.InitialDir := tproject.GetFolder;

  if OpenDialog1.Execute then
    edtImgBackgroundStart.Text := OpenDialog1.FileName;
end;

procedure TfrmMain.edtImgOverlaySelectClick(Sender: TObject);
begin
  if OpenDialog1.InitialDir.IsEmpty then
    OpenDialog1.InitialDir := tproject.GetFolder;

  if OpenDialog1.Execute then
    edtImgOverlay.Text := OpenDialog1.FileName;
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

procedure TfrmMain.InitAboutDialogDescriptionAndLicense;
begin
  OlfAboutDialog1.Licence.Text :=
    'This program is distributed as shareware. If you use it (especially for ' +
    'commercial or income-generating purposes), please remember the author and '
    + 'contribute to its development by purchasing a license.' + slinebreak +
    slinebreak +
    'This software is supplied as is, with or without bugs. No warranty is offered '
    + 'as to its operation or the data processed. Make backups!';
  OlfAboutDialog1.Description.Text :=
    'The tomato''s time is an utility developed in Delphi and based on the FFmpeg '
    + 'bookshop to cut long videos in series of 20 to 25 minutes (the time of a pomodoro, '
    + 'hence its title). New videos are then composed of a starting image, an end image, '
    + 'an excerpt from the previous video and the content of the current episode.'
    + slinebreak + slinebreak +
    'The whole works by using FFmpeg command line on videos stored in a folder.'
    + slinebreak + slinebreak + '*****************' + slinebreak +
    '* Publisher info' + slinebreak + slinebreak +
    'This application was developed by Patrick Prémartin.' + slinebreak +
    slinebreak +
    'It is published by OLF SOFTWARE, a company registered in Paris (France) under the reference 439521725.'
    + slinebreak + slinebreak + '****************' + slinebreak +
    '* Personal data' + slinebreak + slinebreak +
    'This program is autonomous in its current version. It does not depend on the Internet and communicates nothing to the outside world.'
    + slinebreak + slinebreak + 'We have no knowledge of what you do with it.' +
    slinebreak + slinebreak +
    'No information about you is transmitted to us or to any third party.' +
    slinebreak + slinebreak +
    'We use no cookies, no tracking, no stats on your use of the application.' +
    slinebreak + slinebreak + '**********************' + slinebreak +
    '* User support' + slinebreak + slinebreak +
    'If you have any questions or require additional functionality, please leave us a message on the application''s website or on its code repository.'
    + slinebreak + slinebreak + 'To find out more, visit ' +
    OlfAboutDialog1.URL;
end;

procedure TfrmMain.InitMainFormCaption;
begin
{$IFDEF DEBUG}
  caption := '[DEBUG] ';
{$ELSE}
  caption := '';
{$ENDIF}
  caption := caption + OlfAboutDialog1.Titre + ' v' +
    OlfAboutDialog1.VersionNumero;
end;

procedure TfrmMain.InitMainMenuForMacOS;
begin
{$IFDEF MACOS}
  mnuMacOS.Visible := true;
  mnuFileQuit.shortcut := scCommand + ord('Q'); // 4177;
  mnuHelpAbout.parent := mnuMacOS;
  mnuHelp.Visible := (mnuHelp.children[0].childrencount > 0);
  mnuToolsOptions.parent := mnuMacOS;
  mnuTools.Visible := (mnuTools.children[0].childrencount > 0);
{$ELSE}
  mnuMacOS.Visible := false;
{$ENDIF}
  mnuHelpAbout.Text := '&About ' + OlfAboutDialog1.Titre;
end;

procedure TfrmMain.InitProjectOnScreen;
begin
  if tproject.isOpened then
  begin
    lProject.Visible := true;
    InitProjectFields;
  end
  else
    lProject.Visible := false;
end;

procedure TfrmMain.InitProjectFields;
var
  i: integer;
  e: TEdit;
begin
  edtTitle.TagString := tproject.Title;
  edtVideoNamePrefixe.TagString := tproject.VideoFilePrefix;
  edtImgBackgroundStart.TagString := tproject.StartBackgroundImage;
  edtImgOverlay.TagString := tproject.OverlayImage;
  edtImgBackgroundEnd.TagString := tproject.EndBackgroundImage;

  for i := 0 to lProject.childrencount - 1 do
    if lProject.children[i] is TEdit then
    begin
      e := lProject.children[i] as TEdit;
      e.Text := e.TagString;
    end;
end;

procedure TfrmMain.mnuProjectOptionsClick(Sender: TObject);
var
  frm: TfrmProjectOptions;
begin
  frm := TfrmProjectOptions.create(self);
  try
    frm.ShowModal;
  finally
    frm.free;
  end;
end;

procedure TfrmMain.mnuToolsOptionsClick(Sender: TObject);
var
  frm: TFrmOptions;
begin
  frm := TFrmOptions.create(self);
  try
    frm.ShowModal;
  finally
    frm.free;
  end;
end;

procedure TfrmMain.ExecuteFFmpegAndWait(const AParams,
  DestinationFilePath: string);
var
  LParams: string;
begin
  if tfile.Exists(DestinationFilePath) then
    Exit;

{$IFDEF DEBUG}
  LParams := '-y ' + AParams;
  AddLog('"' + tconfig.FFmpegPath + '" ' + LParams + ' "' +
    DestinationFilePath + '"');
{$ELSE}
  LParams := '-y -loglevel error ' + AParams;
{$ENDIF}
{$IF Defined(MSWINDOWS)}
  ShellExecute(0, pwidechar(tconfig.FFmpegPath),
    pwidechar(LParams + ' "' + DestinationFilePath + '"'), nil, nil,
    SW_SHOWNORMAL);
{$ELSEIF Defined(MACOS)}
  _system(PAnsiChar(ansistring('"' + tconfig.FFmpegPath + '" ' + LParams + ' "'
    + DestinationFilePath + '"')));
{$ELSE}
{$MESSAGE FATAL 'Platform not available.'}
{$ENDIF}
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if tproject.isOpened and ProjectFieldsHasChanged then
  begin
    CanClose := false;
    TDialogService.MessageDialog
      ('Do you want to save your changes before closing ?',
      tmsgdlgtype.mtConfirmation, mbyesno, tmsgdlgbtn.mbYes, 0,
      procedure(const AModalResult: TModalResult)
      begin
        case AModalResult of
          mryes:
            tthread.forcequeue(nil,
              procedure
              begin
                btnSaveProjectClick(Sender);
                Close;
              end);
        else
          tthread.forcequeue(nil,
            procedure
            begin
              btnCancelClick(Sender);
              Close;
            end);
        end;
      end);
  end
  else
  begin
    if tproject.isOpened then
      tproject.Close;

    CanClose := true;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  BlockScreen(false);
  InitMainFormCaption;
  InitAboutDialogDescriptionAndLicense;
  UpdateButtons;
  InitMainMenuForMacOS;
  InitProjectOnScreen;
end;

procedure TfrmMain.OlfAboutDialog1URLClick(const AURL: string);
begin
  url_Open_In_Browser(AURL);
end;

procedure TfrmMain.PicResize(const FromFilePath, ToFilePath: string;
const NewWidth, NewHeight: integer);
var
  btm1, btm2: TBitmap;
  ratiow, ratioh, ratio: single;
  w, h: integer;
  x, y: integer;
  ChangeLargeur, ChangeHauteur: Boolean;
begin
  if not tfile.Exists(FromFilePath) then
    Exit;

  if tfile.Exists(ToFilePath) then
    Exit;

  ChangeLargeur := NewWidth > 0;
  ChangeHauteur := NewHeight > 0;

  btm1 := TBitmap.CreateFromFile(FromFilePath);
  try
    if ChangeLargeur then
      ratiow := btm1.width / NewWidth
    else
      ratiow := 0;
    if ChangeHauteur then
      ratioh := btm1.height / NewHeight
    else
      ratioh := 0;
    if ((ratiow = 0) or (ratioh < ratiow)) and (ratioh > 0) then
      ratio := ratioh
    else if ((ratioh = 0) or (ratiow < ratioh)) and (ratiow > 0) then
      ratio := ratiow
    else
      ratio := 0;
    if (ratio = 0) then
      ratio := 1;
    btm1.Resize(ceil(btm1.width / ratio), ceil(btm1.height / ratio));
    if ratiow = 0 then
      w := btm1.width
    else
      w := NewWidth;
    if ratioh = 0 then
      h := btm1.height
    else
      h := NewHeight;
    btm2 := TBitmap.create(w, h);
    try
      x := ((btm1.width - w) div 2);
      y := ((btm1.height - h) div 2);
      tthread.Synchronize(nil,
        procedure
        begin
          btm2.CopyFromBitmap(btm1, trect.create(x, y, x + w, y + h), 0, 0);
        end);
      btm2.SaveToFile(ToFilePath);
    finally
      FreeAndNil(btm2);
    end;
  finally
    FreeAndNil(btm1);
  end;
end;

function TfrmMain.ProjectFieldsHasChanged: Boolean;
var
  i: integer;
  e: TEdit;
begin
  result := false;

  if not tproject.isOpened then
    Exit;

  for i := 0 to lProject.childrencount - 1 do
    if lProject.children[i] is TEdit then
    begin
      e := lProject.children[i] as TEdit;
      result := e.TagString <> e.Text;
      if result then
        break;
    end;
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
  BlockScreen(true);
  try
    tthread.CreateAnonymousThread(
      procedure
      var
        VideoFilePath: string;
        Saison, Episode: integer;
        YTVS_TubeCode, YTVS_SerialCode: integer;
      begin
        AddLog('Démarrage du traitement.', true);

        YTVS_TubeCode := YTVideoSeries_GetTubeCode;
        if (YTVS_TubeCode > 0) then
          YTVS_SerialCode := YTVideoSeries_GetSerialCode(tproject.Title)
        else
          YTVS_SerialCode := -1;
        Saison := 0;
        Episode := 0;
        while (not tthread.CheckTerminated) do
        begin
          VideoFilePath := GetVideoFile;

          if VideoFilePath.IsEmpty then
            break;

          TraiterLaSaison(VideoFilePath, Saison, Episode, YTVS_TubeCode,
            YTVS_SerialCode);
        end;
        AddLog('Fin du traitement.' + ' (' + DateTimeToStr(now) + ')', true);
        tthread.Queue(nil,
          procedure
          begin
            BlockScreen(false);
            showmessage('Fin de traitement');
          end);
      end).Start;
  except
    BlockScreen(false);
  end;
end;

procedure TfrmMain.TraiterLaSaison(const AFilePath: string;
var Saison, Episode: integer; const YTVS_TubeCode, YTVS_SerialCode: integer);
var
  Erreur: Boolean;
  DureeTotaleEnSecondes, NbEpisodes, DureeEpisodeEnSecondes: int64;
  EpisodeDeLaSaison: integer;
  i: integer;
  YTVS_SeasonCode, YTVS_EpisodeCode: integer;
  YTVS_SeasonLabel, YTVS_RecordDate: string;
begin
  inc(Saison);

  AddLog('Saison ' + Saison.ToString + ' => ' +
    tpath.GetFileNameWithoutExtension(AFilePath), true);
  AddLog(DateTimeToStr(now));

  if (YTVS_SerialCode > 0) then
  begin
    YTVS_SeasonLabel := tpath.GetFileNameWithoutExtension(AFilePath);
    YTVS_SeasonCode := YTVideoSeries_GetSeasonCode(YTVS_SerialCode,
      YTVS_SeasonLabel);
    if (YTVS_SeasonCode > 0) then
    begin
      YTVS_RecordDate := '';
      for i := 1 to 8 do
        if CharInSet(YTVS_SeasonLabel.Chars[i - 1], ['0' .. '9']) then
          YTVS_RecordDate := YTVS_RecordDate + YTVS_SeasonLabel.Chars[i - 1]
        else
        begin
          YTVS_RecordDate := '';
          break;
        end;
      YTVideoSeries_UpdateSeason(YTVS_SeasonCode, Saison, YTVS_RecordDate);
      // Crée un épisode pour la saison (en diffusion sur SerialStreameur en général)
      YTVS_EpisodeCode := YTVideoSeries_GetEpisodeCode(YTVS_SeasonCode,
        YTVS_SeasonLabel);
      YTVideoSeries_UpdateEpisode(YTVS_EpisodeCode, 0, YTVS_RecordDate);
    end;
  end
  else
    YTVS_SeasonCode := -1;

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

  NbEpisodes := ceil(DureeTotaleEnSecondes / (tproject.VideoDuration * 60));

  AddLog('Nb épisodes : ' + NbEpisodes.ToString);

  if (NbEpisodes < 1) then
    Exit;

  DureeEpisodeEnSecondes := round(DureeTotaleEnSecondes / NbEpisodes);

  AddLog('Durée d''un épisode : ' + SecondesToHHMMSS(DureeEpisodeEnSecondes));

  for EpisodeDeLaSaison := 1 to NbEpisodes do
    TraiterLEpisode(AFilePath, Saison, Episode, EpisodeDeLaSaison,
      DureeEpisodeEnSecondes, YTVS_TubeCode, YTVS_SeasonCode, YTVS_RecordDate);
end;

procedure TfrmMain.TraiterLEpisode(const AFilePath: string;
Const Saison: integer; var Episode: integer; const EpisodeDeLaSaison: integer;
const DureeEpisodeEnSecondes: int64; const YTVS_TubeCode, YTVS_SeasonCode
  : integer; const YTVS_RecordDate: string);
var
  EpisodeFilePath, VersionCourteFilePath, EpisodeFinalFilePath,
    ImgStart1920FilePath, ImgStart1280FilePath, ImgEndFilePath: string;
  TempDir, FinalDir: string;
  lEpisode: integer;
  YTVS_EpisodeCode: integer;
  YTVS_EpisodeLabel: string;
begin
  inc(Episode);
  lEpisode := Episode;

  AddLog('Traitement épisode ' + Episode.ToString + ' (' +
    DateTimeToStr(now) + ')');

  TempDir := tpath.Combine(tpath.GetDirectoryName(AFilePath), 'temp');
  if not TDirectory.Exists(TempDir) then
    TDirectory.CreateDirectory(TempDir);

  FinalDir := tpath.Combine(tpath.GetDirectoryName(AFilePath), 'final');
  if not TDirectory.Exists(FinalDir) then
    TDirectory.CreateDirectory(FinalDir);

  EpisodeFilePath := tpath.Combine(TempDir, tproject.VideoFilePrefix + '_' +
    Saison.ToString + '_' + Episode.ToString + '.mp4');

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
      (EpisodeDeLaSaison - 1) - tproject.AndNowDuration) + ' -to ' +
      SecondesToHHMMSS(DureeEpisodeEnSecondes * EpisodeDeLaSaison) + ' -i "' +
      AFilePath + '"', EpisodeFilePath);

  VersionCourteFilePath :=
    tpath.Combine(tpath.GetDirectoryName(EpisodeFilePath),
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '_short.mp4');

  AddLog('=> génération de la version courte');

  // - création des versions courtes de chaque épisode
  if EpisodeDeLaSaison = 1 then
    // => ./ffmpeg -r 600 -i ContenuDeLEpisode001.mp4 -r 30 -t 50 -map 0:v VersionCourte.mp4
    ExecuteFFmpegAndWait('-r ' + round(tproject.VideoFPS *
      DureeEpisodeEnSecondes / 60).ToString + ' -i "' + EpisodeFilePath +
      '" -r ' + tproject.VideoFPS.ToString + ' -t ' +
      (tproject.PreviouslyDuration - tproject.AndNowDuration).ToString +
      ' -map 0:v', VersionCourteFilePath)
  else
    // => ./ffmpeg -r 600 -ss 0:10 -i ContenuDeLEpisodeXXX.mp4 -r 30 -t 50 -map 0:v VersionCourte.mp4
    ExecuteFFmpegAndWait('-r ' + round(tproject.VideoFPS *
      DureeEpisodeEnSecondes / 60).ToString + ' -ss 10 -i "' + EpisodeFilePath +
      '" -r ' + tproject.VideoFPS.ToString + ' -t ' +
      (tproject.PreviouslyDuration - tproject.AndNowDuration).ToString +
      ' -map 0:v', VersionCourteFilePath);

  AddLog('=> ajout de l''overlay "Précédemment"');

  // - ajout du "précédemment" aux versions courtes
  // => ./ffmpeg -i VersionCourte.mkv  -i precedemment.png -filter_complex overlay VersionCourteAUtiliser.mp4
  ExecuteFFmpegAndWait('-i "' + VersionCourteFilePath + '" -i "' +
    tproject.OverlayImage + '"  -filter_complex overlay',
    GetPrecedemmentFilePath(EpisodeFilePath));

  AddLog('=> génération des images de début, de fin et pour YouTube');

  // - création des images d'intro de chaque épisode
  // => faire des PNG dans Delphi en 1920x1080
  ImgStart1920FilePath := tpath.Combine(tpath.GetDirectoryName(EpisodeFilePath),
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '-1920x1080.png');
  if not tfile.Exists(ImgStart1920FilePath) then
    tthread.Synchronize(nil,
      procedure
      begin
        CreateStartCover(tproject.Title, Saison, lEpisode,
          ImgStart1920FilePath);
      end);

  // => copie de l'image de départ en 1280x720 pour YouTube
  ImgStart1280FilePath := tpath.Combine(FinalDir,
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '-1280x720.png');
  PicResize(ImgStart1920FilePath, ImgStart1280FilePath, 1280);

  // => faire des PNG dans Delphi en 1920x1080
  ImgEndFilePath := tpath.Combine(tpath.GetDirectoryName(EpisodeFilePath),
    tpath.GetFileNameWithoutExtension(EpisodeFilePath) + '-end.png');
  if not tfile.Exists(ImgEndFilePath) then
    tthread.Synchronize(nil,
      procedure
      begin
        CreateEndCover(tproject.Title, Saison, lEpisode, ImgEndFilePath);
      end);

  EpisodeFinalFilePath := tpath.Combine(FinalDir,
    tpath.GetFileName(EpisodeFilePath));

  AddLog('=> export de la vidéo finale');

  // - recomposition de chaque épisode pour version finale (cover+précédemment+contenu+à suivre)
  if EpisodeDeLaSaison = 1 then
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisode001.png -i ContenuDeLEpisode001.mkv -loop 1 -t 5 -i ASuivre.png -filter_complex 'concat=n=3;adelay=3s:all=1' EpisodeAPublier001.mkv
    ExecuteFFmpegAndWait('-loop 1 -t ' + tproject.StartBackgroundImageDuration.
      ToString + ' -i "' + ImgStart1920FilePath + '" -i "' + EpisodeFilePath +
      '" -loop 1 -t ' + tproject.EndBackgroundImageDuration.ToString + ' -i "' +
      ImgEndFilePath + '" -filter_complex ''concat=n=3;adelay=' +
      tproject.StartBackgroundImageDuration.ToString + 's:all=1''',
      EpisodeFinalFilePath)
  else
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisodeXXX.png -i VersionCourteAUtiliser(XXX-1).mkv -i ContenuDeLEpisodeXXX.mkv -loop 1 -t 5 -i ASuivre.png -filter_complex 'concat=n=4;adelay=53s:all=1' EpisodeAPublierXXX.mkv
    // => ./ffmpeg -loop 1 -t 3 -i CoverEpisodeXXX.png -i VersionCourteAUtiliser(XXX-1).mkv -i ContenuDeLEpisodeXXX.mkv -loop 1 -t 5 -i TheEndPourYouTube.png -filter_complex 'concat=n=4;adelay=53s:all=1' EpisodeAPublierXXX.mkv
    ExecuteFFmpegAndWait('-loop 1 -t ' + tproject.StartBackgroundImageDuration.
      ToString + ' -i "' + ImgStart1920FilePath + '" -i "' +
      GetPrecedemmentFilePath(tpath.Combine(TempDir, tproject.VideoFilePrefix +
      '_' + Saison.ToString + '_' + (Episode - 1).ToString + '.mp4')) + '" -i "'
      + EpisodeFilePath + '" -loop 1 -t ' + tproject.EndBackgroundImageDuration.
      ToString + ' -i "' + ImgEndFilePath +
      '" -filter_complex ''concat=n=4;adelay=' +
      (tproject.StartBackgroundImageDuration + tproject.PreviouslyDuration -
      tproject.AndNowDuration).ToString + 's:all=1''', EpisodeFinalFilePath);

  if (YTVS_TubeCode > 0) and (YTVS_SeasonCode > 0) then
  begin
    YTVS_EpisodeLabel := tpath.GetFileNameWithoutExtension
      (EpisodeFinalFilePath);
    YTVS_EpisodeCode := YTVideoSeries_GetEpisodeCode(YTVS_SeasonCode,
      YTVS_EpisodeLabel);
    if (YTVS_EpisodeCode > 0) then
    begin
      YTVideoSeries_UpdateEpisode(YTVS_EpisodeCode, Episode, YTVS_RecordDate);
      YTVideoSeries_CreateVideoTube(YTVS_EpisodeCode, YTVS_TubeCode);
    end;
  end;
end;

procedure TfrmMain.UpdateButtons;
begin
  btnOpenProject.Visible := not tproject.isOpened;
  btnStart.Visible := not btnOpenProject.Visible;
  btnCloseProject.Visible := not btnOpenProject.Visible;

  mnuFileOpen.Enabled := btnOpenProject.Visible;
  mnuProject.Enabled := not mnuFileOpen.Enabled;
  mnuProjectStart.Enabled := btnStart.Visible;
  mnuFileSave.Enabled := btnCloseProject.Visible;
  mnuFileClose.Enabled := btnCloseProject.Visible;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
VideosATraiter := TQueue<string>.create;

finalization

VideosATraiter.free;

end.
