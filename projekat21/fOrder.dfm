
object frmOrder: TfrmOrder
  Caption = 'Narudzbina'
  ClientHeight = 480
  ClientWidth = 640
  OnShow = FormShow
  object pnlTop: TPanel
    Align = alTop
    Height = 48
    object btnAdd: TButton
      Left = 8
      Top = 10
      Width = 80
      Height = 28
      Caption = 'Dodaj'
      OnClick = btnAddClick
    end
    object btnRemove: TButton
      Left = 96
      Top = 10
      Width = 80
      Height = 28
      Caption = 'Ukloni'
      OnClick = btnRemoveClick
    end
    object btnPay: TButton
      Left = 520
      Top = 10
      Width = 100
      Height = 28
      Caption = 'Plati'
      OnClick = btnPayClick
    end
    object lblTotal: TLabel
      Left = 200
      Top = 16
      Caption = 'Ukupno: 0.00'
    end
  end
  object lvItems: TListView
    Align = alClient
    ViewStyle = vsReport
    Columns = <
      item
        Caption = 'Artikal'
        Width = 300
      end
      item
        Caption = 'Kolicina'
        Width = 80
      end
      item
        Caption = 'Iznos'
        Width = 100
      end>
  end
end
