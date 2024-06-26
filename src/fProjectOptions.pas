unit fProjectOptions;

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
  TfrmProjectOptions = class(TForm)
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout1: TGridPanelLayout;
    btnSaveAndClose: TButton;
    btnCancel: TButton;
    lblVideoFPS: TLabel;
    edtVideoFPS: TEdit;
    lblVideoHeight: TLabel;
    edtVideoHeight: TEdit;
    lblVideoWidth: TLabel;
    edtVideoWidth: TEdit;
    lblEndBackgroundImageDuration: TLabel;
    edtEndBackgroundImageDuration: TEdit;
    lblVideoDuration: TLabel;
    edtVideoDuration: TEdit;
    lblAndNowDuration: TLabel;
    edtAndNowDuration: TEdit;
    lblPreviouslyDuration: TLabel;
    edtPreviouslyDuration: TEdit;
    lblStartBackgroundImageDuration: TLabel;
    edtStartBackgroundImageDuration: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveAndCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    procedure SaveConfig;
    procedure InitProjectFields;
    function HasChanged: Boolean;
  public
  end;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  System.IOUtils,
  uProject;

procedure TfrmProjectOptions.btnCancelClick(Sender: TObject);
begin
  InitProjectFields;
  close;
end;

procedure TfrmProjectOptions.btnSaveAndCloseClick(Sender: TObject);
begin
  SaveConfig;
  close;
end;

procedure TfrmProjectOptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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

procedure TfrmProjectOptions.FormCreate(Sender: TObject);
begin
  InitProjectFields;
end;

function TfrmProjectOptions.HasChanged: Boolean;
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

procedure TfrmProjectOptions.InitProjectFields;
var
  i: integer;
  e: TEdit;
begin
  edtStartBackgroundImageDuration.TagString :=
    tproject.StartBackgroundImageDuration.tostring;
  edtEndBackgroundImageDuration.TagString :=
    tproject.EndBackgroundImageDuration.tostring;
  edtVideoDuration.TagString := tproject.VideoDuration.tostring;
  edtPreviouslyDuration.TagString := tproject.PreviouslyDuration.tostring;
  edtAndNowDuration.TagString := tproject.AndNowDuration.tostring;
  edtVideoWidth.TagString := tproject.VideoWidth.tostring;
  edtVideoHeight.TagString := tproject.VideoHeight.tostring;
  edtVideoFPS.TagString := tproject.VideoFPS.tostring;

  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TEdit then
    begin
      e := VertScrollBox1.Content.Children[i] as TEdit;
      e.Text := e.TagString;
    end;
end;

procedure TfrmProjectOptions.SaveConfig;
begin
  tproject.StartBackgroundImageDuration :=
    edtStartBackgroundImageDuration.Text.ToInteger;
  tproject.EndBackgroundImageDuration :=
    edtEndBackgroundImageDuration.Text.ToInteger;
  tproject.VideoDuration := edtVideoDuration.Text.ToInteger;
  tproject.PreviouslyDuration := edtPreviouslyDuration.Text.ToInteger;
  tproject.AndNowDuration := edtAndNowDuration.Text.ToInteger;
  tproject.VideoWidth := edtVideoWidth.Text.ToInteger;
  tproject.VideoHeight := edtVideoHeight.Text.ToInteger;
  tproject.VideoFPS := edtVideoFPS.Text.ToInteger;
  TProject.Save;

  InitProjectFields;
end;

end.
