object frmLogin: TfrmLogin
  Caption = 'Prijava'
  ClientHeight = 160
  ClientWidth = 300
  Position = poScreenCenter
  OnShow = FormShow
  object lblU: TLabel
    Left = 16
    Top = 16
    Caption = 'Korisnik'
  end
  object lblP: TLabel
    Left = 16
    Top = 56
    Caption = 'Lozinka'
  end
  object lblHint: TLabel
    Left = 16
    Top = 128
    Caption = 'radnik/1234, menadzer/9999'
  end
  object edtUser: TEdit
    Left = 96
    Top = 12
    Width = 180
    Height = 21
    TabOrder = 0
  end
  object edtPass: TEdit
    Left = 96
    Top = 52
    Width = 180
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object btnLogin: TButton
    Left = 96
    Top = 88
    Width = 100
    Height = 25
    Caption = 'Prijavi se'
    TabOrder = 2
    OnClick = btnLoginClick
  end
end
