
object frmCloseDay: TfrmCloseDay
  Caption = 'Zatvaranje dana'
  ClientHeight = 360
  ClientWidth = 520
  object pnlTop: TPanel
    Align = alTop
    Height = 40
    object lblTitle: TLabel
      Left = 8
      Top = 12
      Caption = 'X/Z izvestaj'
    end
    object btnRefresh: TButton
      Left = 420
      Top = 8
      Width = 80
      Height = 24
      Caption = 'Osvezi'
      OnClick = btnRefreshClick
    end
  end
  object memo: TMemo
    Align = alClient
  end
end
