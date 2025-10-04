program NaplataApp;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  System.UITypes,
  FireDAC.VCLUI.Wait,
  uDM in 'uDM.pas' {DM: TDataModule},
  fMain in 'fMain.pas' {frmMain},
  fLogin in 'fLogin.pas' {frmLogin},
  fOrder in 'fOrder.pas' {frmOrder},
  fPayment in 'fPayment.pas' {frmPayment},
  fCloseDay in 'fCloseDay.pas' {frmCloseDay};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  DM.InitDB(ExtractFilePath(ParamStr(0)) + 'cafebar.db');
  Application.CreateForm(TfrmLogin, frmLogin);
  if frmLogin.ShowModal = mrOk then
  begin
    FreeAndNil(frmLogin);
    Application.CreateForm(TfrmMain, frmMain);
    frmMain.Show;
    Application.Run;
  end
  else
  begin
    FreeAndNil(frmLogin);
  end;
end.
