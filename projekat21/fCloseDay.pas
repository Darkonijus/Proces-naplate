
unit fCloseDay;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls,
  FireDAC.Comp.Client, uDM;

type
  TfrmCloseDay = class(TForm)
    lv: TListView;
    btnClose: TButton;
  public
    procedure Init(AShiftId: Integer);
  end;

var
  frmCloseDay: TfrmCloseDay;

implementation

{$R *.dfm}

procedure TfrmCloseDay.Init(AShiftId: Integer);
var
  Q: TFDQuery;
  it: TListItem;
begin
  Caption := 'Zatvaranje dana';
  lv.ViewStyle := vsReport;
  lv.Columns.Add.Caption := 'Metod';
  lv.Columns.Add.Caption := 'Broj';
  lv.Columns.Add.Caption := 'Iznos';

  Q := DM.XZReport(AShiftId);
  try
    while not Q.Eof do
    begin
      it := lv.Items.Add;
      it.Caption := Q.FieldByName('method').AsString;
      it.SubItems.Add(Q.FieldByName('cnt').AsString);
      it.SubItems.Add(FormatFloat('0.00', Q.FieldByName('sum_amount').AsFloat));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
