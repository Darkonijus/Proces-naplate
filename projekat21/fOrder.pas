
unit fOrder;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Data.DB, FireDAC.Comp.Client, uDM, fPayment;

type
  TfrmOrder = class(TForm)
    pnlTop: TPanel;
    btnAdd: TButton;
    btnRemove: TButton;
    btnPay: TButton;
    lvItems: TListView;
    lblTable: TLabel;
    lblTotal: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnPayClick(Sender: TObject);
  private
    FOrderId: Integer;
    FTable: Integer;
    FShiftId: Integer;
    procedure EnsureSeedItems;
    procedure RefreshList;
    procedure UpdateTotal;
  public
    procedure InitForTable(ATable, AShiftId: Integer);
  end;

var
  frmOrder: TfrmOrder;

implementation

{$R *.dfm}

procedure TfrmOrder.FormCreate(Sender: TObject);
begin
  lvItems.ViewStyle := vsReport;
  lvItems.Columns.Add.Caption := 'Artikal';
  lvItems.Columns.Add.Caption := 'Količina';
  lvItems.Columns.Add.Caption := 'Ukupno';
  lvItems.ReadOnly := True;
end;

procedure TfrmOrder.InitForTable(ATable, AShiftId: Integer);
begin
  FTable := ATable;
  FShiftId := AShiftId;
  Caption := Format('Porudžbina - sto %d', [ATable]);
  lblTable.Caption := Caption;
  // kreiraj porudžbinu
  FOrderId := DM.BeginOrder(DM.CurrentWorkerId, ATable, AShiftId);
  EnsureSeedItems;
  RefreshList;
  UpdateTotal;
end;

procedure TfrmOrder.EnsureSeedItems;
begin
  // ubaci par artikala ako tabela item nema ništa
  if DM.FDConn.ExecSQLScalar('SELECT COUNT(*) FROM item') = 0 then
  begin
    DM.FDConn.ExecSQL('INSERT INTO item(name,price) VALUES (''Espresso'',150)');
    DM.FDConn.ExecSQL('INSERT INTO item(name,price) VALUES (''Cappuccino'',200)');
    DM.FDConn.ExecSQL('INSERT INTO item(name,price) VALUES (''Voda'',120)');
  end;
end;

procedure TfrmOrder.RefreshList;
var
  Q: TFDQuery;
  it: TListItem;
begin
  lvItems.Items.Clear;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.FDConn;
    Q.Open('SELECT order_item_id, item_name_snapshot, quantity, total_price FROM order_item WHERE order_id=?', [FOrderId]);
    while not Q.Eof do
    begin
      it := lvItems.Items.Add;
      it.Caption := Q.FieldByName('item_name_snapshot').AsString;
      it.SubItems.Add(Q.FieldByName('quantity').AsString);
      it.SubItems.Add(FormatFloat('0.00', Q.FieldByName('total_price').AsFloat));
      it.Data := Pointer(Q.FieldByName('order_item_id').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmOrder.UpdateTotal;
var
  T: Currency;
begin
  T := DM.CalcTotal(FOrderId);
  lblTotal.Caption := 'Ukupno: ' + FormatFloat('0.00', T);
end;

procedure TfrmOrder.btnAddClick(Sender: TObject);
var
  Q: TFDQuery;
  list: TStringList;
  choice: string;
  id: Integer;
begin
  // prikaži jednostavan izbor artikla
  list := TStringList.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.FDConn;
    Q.Open('SELECT item_id, name FROM item ORDER BY name');
    while not Q.Eof do
    begin
      list.AddObject(Q.FieldByName('name').AsString, TObject(Q.FieldByName('item_id').AsInteger));
      Q.Next;
    end;
    if list.Count = 0 then Exit;
    choice := list[0]; // za sada uzmi prvi (najjednostavnije)
    id := Integer(list.Objects[0]);
    DM.AddItem(FOrderId, id, 1);
    RefreshList;
    UpdateTotal;
  finally
    list.Free;
    Q.Free;
  end;
end;

procedure TfrmOrder.btnRemoveClick(Sender: TObject);
var
  id: Integer;
begin
  if Assigned(lvItems.Selected) then
  begin
    id := Integer(lvItems.Selected.Data);
    DM.RemoveItem(id);
    RefreshList;
    UpdateTotal;
  end;
end;

procedure TfrmOrder.btnPayClick(Sender: TObject);
begin
  with TfrmPayment.Create(Self) do
  try
    Init(FOrderId);
    ShowModal;
  finally
    Free;
  end;
  RefreshList;
  UpdateTotal;
end;

end.
