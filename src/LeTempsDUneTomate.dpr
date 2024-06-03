program LeTempsDUneTomate;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  Olf.FMX.SelectDirectory in '..\lib-externes\Delphi-FMXExtend-Library\src\Olf.FMX.SelectDirectory.pas',
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm},
  Olf.RTL.Language in '..\lib-externes\librairies\src\Olf.RTL.Language.pas',
  u_urlOpen in '..\lib-externes\librairies\src\u_urlOpen.pas',
  uConsts in 'uConsts.pas',
  udmAdobeStock_286917767 in '..\_PRIVATE\AdobeStock_286917767\udmAdobeStock_286917767.pas' {dmAdobeStock_286917767: TDataModule},
  Olf.FMX.TextImageFrame in '..\lib-externes\librairies\src\Olf.FMX.TextImageFrame.pas' {OlfFMXTextImageFrame: TFrame},
  uDMLogo in 'uDMLogo.pas' {dmLogo: TDataModule},
  Olf.RTL.Params in '..\lib-externes\librairies\src\Olf.RTL.Params.pas',
  uConfig in 'uConfig.pas',
  Olf.RTL.CryptDecrypt in '..\lib-externes\librairies\src\Olf.RTL.CryptDecrypt.pas',
  uProject in 'uProject.pas',
  uDB in '..\lib-externes\YTVideoSeries\src\uDB.pas' {db: TDataModule},
  Olf.RTL.GenRandomID in '..\lib-externes\librairies\src\Olf.RTL.GenRandomID.pas',
  YTVideoSeries.API in 'YTVideoSeries.API.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmAdobeStock_286917767, dmAdobeStock_286917767);
  Application.CreateForm(TdmLogo, dmLogo);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
