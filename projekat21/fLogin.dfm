
object frmLogin: TfrmLogin
  Caption = 'Prijava'
  ClientHeight = 180
  ClientWidth = 300
  OnShow = FormShow
  object lblU: TLabel
    Left = 24
    Top = 24
    Caption = 'Korisnik'
  end
  object lblP: TLabel
    Left = 24
    Top = 64
    Caption = 'Lozinka'
  end
  object edtUser: TEdit
    Left = 100
    Top = 20
    Width = 160
  end
  object edtPass: TEdit
    Left = 100
    Top = 60
    Width = 160
    PasswordChar = '*'
  end
  object btnLogin: TButton
    Left = 180
    Top = 120
    Width = 80
    Height = 26
    Caption = 'Prijavi se'
    OnClick = btnLoginClick
  end
  object lblHint: TLabel
    Left = 24
    Top = 120
    Caption = 'Demo: radnik/1234'
  end
end
