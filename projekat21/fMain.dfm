
object frmMain: TfrmMain
  Caption = 'Capi Bar - POS'
  ClientHeight = 520
  ClientWidth = 640
  OnCreate = FormCreate
  object pnlTop: TPanel
    Align = alTop
    Height = 48
    Caption = ''
    object btnCloseDay: TButton
      Left = 8
      Top = 10
      Width = 120
      Height = 28
      Caption = 'Zatvori dan'
      OnClick = btnCloseDayClick
    end
    object btnReload: TButton
      Left = 140
      Top = 10
      Width = 80
      Height = 28
      Caption = 'Osvezi'
      OnClick = btnReloadClick
    end
    object lblShift: TLabel
      Left = 240
      Top = 16
      Caption = 'Smena: '
    end
  end
  object scrollTables: TScrollBox
    Align = alClient
  end
end
