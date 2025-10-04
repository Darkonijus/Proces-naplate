object frmMain: TfrmMain
  Caption = 'Capi Bar - Mini POS'
  ClientHeight = 420
  ClientWidth = 620
  Position = poScreenCenter
  OnCreate = FormCreate
  object pnlTop: TPanel
    Align = alTop
    Height = 40
    object btnCloseDay: TButton
      Left = 8
      Top = 8
      Width = 90
      Height = 25
      Caption = 'Zatvori dan'
      OnClick = btnCloseDayClick
    end
    object lblShift: TLabel
      Left = 120
      Top = 12
      Caption = 'Smena: 1'
    end
    object lblTotal: TLabel
      Left = 220
      Top = 12
      Caption = 'Ukupno: 0.00'
    end
  end
  object pnlBtns: TPanel
    Align = alTop
    Height = 48
    object btnEspresso: TButton
      Left = 8
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Espresso'
      OnClick = btnEspressoClick
    end
    object btnCap: TButton
      Left = 106
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Cappuccino'
      OnClick = btnCapClick
    end
    object btnVoda: TButton
      Left = 204
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Voda'
      OnClick = btnVodaClick
    end
    object btnRemove: TButton
      Left = 302
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Obriši stavku'
      OnClick = btnRemoveClick
    end
    object btnPayCash: TButton
      Left = 410
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Plati gotovinom'
      OnClick = btnPayCashClick
    end
    object btnPayCard: TButton
      Left = 508
      Top = 10
      Width = 90
      Height = 25
      Caption = 'Plati karticom'
      OnClick = btnPayCardClick
    end
  end
  object lv: TListView
    Align = alClient
    ReadOnly = True
    RowSelect = True
  end
end
