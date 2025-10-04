unit fLogin;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Dialogs, System.SysUtils;

type
  TfrmLogin = class(TForm)
    edtUser: TEdit;
    edtPass: TEdit;
    btnLogin: TButton;
    lblU: TLabel;
    lblP: TLabel;
    lblHint: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  edtUser.Text := 'radnik';
  edtPass.Text := '1234';
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var u,p: string;
begin
  u := LowerCase(Trim(edtUser.Text));
  p := edtPass.Text;
  if ((u='radnik') and (p='1234')) or ((u='menadzer') and (p='9999')) then
    ModalResult := mrOK
  else
    ShowMessage('Pogrešni kredencijali');
end;

end.
