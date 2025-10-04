
object frmPayment: TfrmPayment
  Caption = 'Placanje'
  ClientHeight = 220
  ClientWidth = 420
  OnShow = FormShow
  object pnlTop: TPanel
    Align = alTop
    Height = 56
    object lblAmount: TLabel
      Left = 8
      Top = 16
      Caption = 'Za naplatu: 0.00 | Gotovina: 0.00 | Kartica: 0.00'
    end
  end
  object btnCash: TButton
    Left = 8
    Top = 80
    Width = 120
    Height = 40
    Caption = 'Gotovina'
    OnClick = btnCashClick
  end
  object btnCard: TButton
    Left = 150
    Top = 80
    Width = 120
    Height = 40
    Caption = 'Kartica'
    OnClick = btnCardClick
  end
  object btnMix: TButton
    Left = 292
    Top = 80
    Width = 120
    Height = 40
    Caption = 'Mix'
    OnClick = btnMixClick
  end
  object btnIssue: TButton
    Left = 292
    Top = 150
    Width = 120
    Height = 36
    Caption = 'Izdaj racun'
    OnClick = btnIssueClick
  end
end
