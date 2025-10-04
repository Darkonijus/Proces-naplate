program NaplataApp;

uses
  System.SysUtils,
  System.UITypes,
  Vcl.Forms,
  fLogin in 'fLogin.pas' {frmLogin},
  fMain in 'fMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  frmLogin := TfrmLogin.Create(nil);
  try
    if frmLogin.ShowModal = mrOK then
    begin
      Application.CreateForm(TfrmMain, frmMain);
      Application.Run;
    end
    else
      Exit;
  finally
    frmLogin.Free;
  end;
end.
