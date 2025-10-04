unit fLogin;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Dialogs,
  Vcl.ExtCtrls, uDM;

type
  TfrmLogin = class(TForm)
    edtUser: TEdit;
    edtPass: TEdit;
    btnLogin: TButton;
    lblU: TLabel;
    lblP: TLabel;
    lblHint: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  if edtUser.Text = '' then edtUser.Text := 'radnik';
  if edtPass.Text = '' then edtPass.Text := '1234';
end;

procedure TfrmLogin.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnLoginClick(btnLogin);
  end;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
begin
  if DM.Authenticate(edtUser.Text, edtPass.Text) then
  begin
    ShowMessage('DBG: auth result TRUE for user=' + edtUser.Text);
    ModalResult := mrOk;
    Close;
  end
  else
    ShowMessage('DBG: auth result FALSE for user=' + edtUser.Text + ' (Pogrešni kredencijali)');
end;

end.
