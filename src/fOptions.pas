unit fOptions;

interface

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
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Controls.Presentation;

type
  TfrmOptions = class(TForm)
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout1: TGridPanelLayout;
    lblFFmpegPath: TLabel;
    btnFFmpegDownload: TButton;
    edtFFmpegPath: TEdit;
    btnFFmpegPathChoose: TEllipsesEditButton;
    btnSaveAndClose: TButton;
    btnCancel: TButton;
    OpenDialogFFmpeg: TOpenDialog;
    lblVideoFPS: TLabel;
    edtVideoFPS: TEdit;
    lblVideoHeight: TLabel;
    edtVideoHeight: TEdit;
    lblVideoWidth: TLabel;
    edtVideoWidth: TEdit;
    lblEndBackgroundImageDuration: TLabel;
    edtEndBackgroundImageDuration: TEdit;
    lblEndBackgroundImagePath: TLabel;
    edtEndBackgroundImagePath: TEdit;
    lblVideoDuration: TLabel;
    edtVideoDuration: TEdit;
    lblAndNowDuration: TLabel;
    edtAndNowDuration: TEdit;
    lblPreviouslyDuration: TLabel;
    edtPreviouslyDuration: TEdit;
    lblOverlayImagePath: TLabel;
    edtOverlayImagePath: TEdit;
    lblStartBackgroundImageDuration: TLabel;
    edtStartBackgroundImageDuration: TEdit;
    lblStartBackgroundImagePath: TLabel;
    edtStartBackgroundImagePath: TEdit;
    btnStartBackgroundImagePathChoose: TEllipsesEditButton;
    OpenDialogImage: TOpenDialog;
    btnOverlayImagePathChoose: TEllipsesEditButton;
    btnEndBackgroundImagePathChoose: TEllipsesEditButton;
    procedure btnFFmpegDownloadClick(Sender: TObject);
    procedure btnFFmpegPathChooseClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveAndCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnStartBackgroundImagePathChooseClick(Sender: TObject);
    procedure btnOverlayImagePathChooseClick(Sender: TObject);
    procedure btnEndBackgroundImagePathChooseClick(Sender: TObject);
  private
    procedure SaveConfig;
    procedure InitConfigFields;
    function HasChanged: Boolean;
  public
  end;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  System.IOUtils,
  u_urlOpen,
  uConfig;

procedure TfrmOptions.btnCancelClick(Sender: TObject);
begin
  InitConfigFields;
  close;
end;

procedure TfrmOptions.btnFFmpegDownloadClick(Sender: TObject);
begin
  url_open_in_browser('https://ffmpeg.org/download.html');
end;

procedure TfrmOptions.btnFFmpegPathChooseClick(Sender: TObject);
begin
  if (not edtFFmpegPath.Text.IsEmpty) and tfile.exists(edtFFmpegPath.Text) then
  begin
    OpenDialogFFmpeg.InitialDir := tpath.getdirectoryname(edtFFmpegPath.Text);
    OpenDialogFFmpeg.FileName := edtFFmpegPath.Text;
  end
  else if OpenDialogFFmpeg.InitialDir.IsEmpty then
    OpenDialogFFmpeg.InitialDir := tpath.GetDownloadsPath;

  if OpenDialogFFmpeg.Execute and tfile.exists(OpenDialogFFmpeg.FileName) then
    edtFFmpegPath.Text := OpenDialogFFmpeg.FileName;
end;

procedure TfrmOptions.btnSaveAndCloseClick(Sender: TObject);
begin
  SaveConfig;
  close;
end;

procedure TfrmOptions.btnStartBackgroundImagePathChooseClick(Sender: TObject);
begin
  if (not edtStartBackgroundImagePath.Text.IsEmpty) and
    tfile.exists(edtStartBackgroundImagePath.Text) then
  begin
    OpenDialogImage.InitialDir := tpath.getdirectoryname
      (edtStartBackgroundImagePath.Text);
    OpenDialogImage.FileName := edtStartBackgroundImagePath.Text;
  end
  else if OpenDialogImage.InitialDir.IsEmpty then
    OpenDialogImage.InitialDir := tpath.GetPicturesPath;

  if OpenDialogImage.Execute and tfile.exists(OpenDialogImage.FileName) then
    edtStartBackgroundImagePath.Text := OpenDialogImage.FileName;
end;

procedure TfrmOptions.btnOverlayImagePathChooseClick(Sender: TObject);
begin
  if (not edtOverlayImagePath.Text.IsEmpty) and
    tfile.exists(edtOverlayImagePath.Text) then
  begin
    OpenDialogImage.InitialDir := tpath.getdirectoryname
      (edtOverlayImagePath.Text);
    OpenDialogImage.FileName := edtOverlayImagePath.Text;
  end
  else if OpenDialogImage.InitialDir.IsEmpty then
    OpenDialogImage.InitialDir := tpath.GetPicturesPath;

  if OpenDialogImage.Execute and tfile.exists(OpenDialogImage.FileName) then
    edtOverlayImagePath.Text := OpenDialogImage.FileName;
end;

procedure TfrmOptions.btnEndBackgroundImagePathChooseClick(Sender: TObject);
begin
  if (not edtEndBackgroundImagePath.Text.IsEmpty) and
    tfile.exists(edtEndBackgroundImagePath.Text) then
  begin
    OpenDialogImage.InitialDir := tpath.getdirectoryname
      (edtEndBackgroundImagePath.Text);
    OpenDialogImage.FileName := edtEndBackgroundImagePath.Text;
  end
  else if OpenDialogImage.InitialDir.IsEmpty then
    OpenDialogImage.InitialDir := tpath.GetPicturesPath;

  if OpenDialogImage.Execute and tfile.exists(OpenDialogImage.FileName) then
    edtEndBackgroundImagePath.Text := OpenDialogImage.FileName;
end;

procedure TfrmOptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if HasChanged then
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
                btnSaveAndCloseClick(Sender);
              end);
        else
          tthread.forcequeue(nil,
            procedure
            begin
              btnCancelClick(Sender);
            end);
        end;
      end);
  end
  else
    CanClose := true;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
begin
  InitConfigFields;
end;

function TfrmOptions.HasChanged: Boolean;
var
  i: integer;
  e: TEdit;
begin
  result := false;
  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TEdit then
    begin
      e := VertScrollBox1.Content.Children[i] as TEdit;
      result := e.TagString <> e.Text;
      if result then
        break;
    end;
end;

procedure TfrmOptions.InitConfigFields;
var
  i: integer;
  e: TEdit;
begin
  edtFFmpegPath.TagString := tconfig.FFmpegPath;
  edtStartBackgroundImagePath.TagString := tconfig.DefaultStartBackgroundImage;
  edtStartBackgroundImageDuration.TagString :=
    tconfig.DefaultStartBackgroundImageDuration.tostring;
  edtEndBackgroundImagePath.TagString := tconfig.DefaultEndBackgroundImage;
  edtEndBackgroundImageDuration.TagString :=
    tconfig.DefaultEndBackgroundImageDuration.tostring;
  edtOverlayImagePath.TagString := tconfig.DefaultOverlayImage;
  edtVideoDuration.TagString := tconfig.DefaultVideoDuration.tostring;
  edtPreviouslyDuration.TagString := tconfig.DefaultPreviouslyDuration.tostring;
  edtAndNowDuration.TagString := tconfig.DefaultAndNowDuration.tostring;
  edtVideoWidth.TagString := tconfig.DefaultVideoWidth.tostring;
  edtVideoHeight.TagString := tconfig.DefaultVideoHeight.tostring;
  edtVideoFPS.TagString := tconfig.DefaultVideoFPS.tostring;

  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TEdit then
    begin
      e := VertScrollBox1.Content.Children[i] as TEdit;
      e.Text := e.TagString;
    end;
end;

procedure TfrmOptions.SaveConfig;
begin
  tconfig.FFmpegPath := edtFFmpegPath.Text;
  tconfig.DefaultStartBackgroundImage := edtStartBackgroundImagePath.Text;
  tconfig.DefaultStartBackgroundImageDuration :=
    edtStartBackgroundImageDuration.Text.ToInteger;
  tconfig.DefaultEndBackgroundImage := edtEndBackgroundImagePath.Text;
  tconfig.DefaultEndBackgroundImageDuration :=
    edtEndBackgroundImageDuration.Text.ToInteger;
  tconfig.DefaultOverlayImage := edtOverlayImagePath.Text;
  tconfig.DefaultVideoDuration := edtVideoDuration.Text.ToInteger;
  tconfig.DefaultPreviouslyDuration := edtPreviouslyDuration.Text.ToInteger;
  tconfig.DefaultAndNowDuration := edtAndNowDuration.Text.ToInteger;
  tconfig.DefaultVideoWidth := edtVideoWidth.Text.ToInteger;
  tconfig.DefaultVideoHeight := edtVideoHeight.Text.ToInteger;
  tconfig.DefaultVideoFPS := edtVideoFPS.Text.ToInteger;
  tconfig.Save;

  InitConfigFields;
end;

end.
