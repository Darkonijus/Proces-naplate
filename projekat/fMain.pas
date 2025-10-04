unit fMain;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    btnCloseDay: TButton;
    lblShift: TLabel;
    lv: TListView;
    pnlBtns: TPanel;
    btnEspresso: TButton;
    btnCap: TButton;
    btnVoda: TButton;
    btnRemove: TButton;
    btnPayCash: TButton;
    btnPayCard: TButton;
    lblTotal: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnEspressoClick(Sender: TObject);
    procedure btnCapClick(Sender: TObject);
    procedure btnVodaClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnPayCashClick(Sender: TObject);
    procedure btnPayCardClick(Sender: TObject);
    procedure btnCloseDayClick(Sender: TObject);
  private
    FTotal: Currency;
    FDayCash, FDayCard: Currency;
    FNextReceipt: Integer;
    procedure AddItem(const AName: string; APrice: Currency);
    procedure RecalcTotal;
    procedure DoPay(const Method: string);
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption := 'Capi Bar - Mini POS';
  FNextReceipt := 1;
  lblShift.Caption := 'Smena: 1';
  lv.ViewStyle := vsReport;
  lv.Columns.Add.Caption := 'Artikal';
  lv.Columns.Add.Caption := 'Količina';
  lv.Columns.Add.Caption := 'Ukupno';
  lv.ReadOnly := True;
  RecalcTotal;
end;

procedure TfrmMain.AddItem(const AName: string; APrice: Currency);
var i,q: Integer; it: TListItem;
begin
  // Ako vec postoji artikal, uvecaj kolicinu
  for i := 0 to lv.Items.Count-1 do
    if SameText(lv.Items[i].Caption, AName) then
    begin
      q := StrToIntDef(lv.Items[i].SubItems[0],1);
      Inc(q);
      lv.Items[i].SubItems[0] := IntToStr(q);
      lv.Items[i].SubItems[1] := FormatFloat('0.00', q*APrice);
      RecalcTotal;
      Exit;
    end;
  // novi red
  it := lv.Items.Add;
  it.Caption := AName;
  it.SubItems.Add('1');
  it.SubItems.Add(FormatFloat('0.00', APrice));
  RecalcTotal;
end;

procedure TfrmMain.RecalcTotal;
var i: Integer;
begin
  FTotal := 0;
  for i := 0 to lv.Items.Count-1 do
    FTotal := FTotal + StrToFloatDef(lv.Items[i].SubItems[1], 0);
  lblTotal.Caption := 'Ukupno: ' + FormatFloat('0.00', FTotal);
end;

procedure TfrmMain.btnEspressoClick(Sender: TObject);
begin
  AddItem('Espresso', 150);
end;

procedure TfrmMain.btnCapClick(Sender: TObject);
begin
  AddItem('Cappuccino', 200);
end;

procedure TfrmMain.btnVodaClick(Sender: TObject);
begin
  AddItem('Voda', 120);
end;

procedure TfrmMain.btnRemoveClick(Sender: TObject);
begin
  if Assigned(lv.Selected) then
    lv.Selected.Delete;
  RecalcTotal;
end;

procedure TfrmMain.DoPay(const Method: string);
var rec: string;
begin
  if FTotal <= 0 then
  begin
    ShowMessage('Korpa je prazna.');
    Exit;
  end;
  rec := Format('R%6.6d',[FNextReceipt]);
  Inc(FNextReceipt);
  if SameText(Method,'CASH') then
    FDayCash := FDayCash + FTotal
  else
    FDayCard := FDayCard + FTotal;
  ShowMessage(Format('Plaćanje uspešno (%s). Račun: %s',[Method, rec]));
  lv.Items.Clear;
  RecalcTotal;
end;

procedure TfrmMain.btnPayCashClick(Sender: TObject);
begin
  DoPay('CASH');
end;

procedure TfrmMain.btnPayCardClick(Sender: TObject);
begin
  DoPay('CARD');
end;

procedure TfrmMain.btnCloseDayClick(Sender: TObject);
begin
  ShowMessage(Format('Zbir za smenu:%sGotovina: %s%sKartice: %s', [sLineBreak,
    FormatFloat('0.00', FDayCash), sLineBreak, FormatFloat('0.00', FDayCard)]));
end;

end.
