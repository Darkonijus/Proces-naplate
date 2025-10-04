
unit uDM;

interface

uses
  System.SysUtils, System.Classes, Vcl.Dialogs, System.DateUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Intf,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Param;

type
  TDM = class(TDataModule)
    FDConn: TFDConnection;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
  private
    function ColumnExists(const ATable, ACol: string): Boolean;
    procedure EnsureColumns;
  public
    CurrentWorkerId: Integer;
    CurrentWorkerName: string;
    procedure InitDB(const ADbPath: string);
    procedure EnsureSchema;
    function Authenticate(const AUser, APass: string): Boolean;
    function BeginOrder(AWorkerId, ATable, AShiftId: Integer): Integer;
    procedure AddItem(AOrderId, AItemId, AQty: Integer);
    procedure RemoveItem(AOrderItemId: Integer);
    function CalcTotal(AOrderId: Integer): Currency;
    procedure AddPayment(AOrderId: Integer; const AMethod: string; AAmount: Currency);
    function IssueReceipt(AOrderId: Integer): string;
    function ShiftOpenId: Integer;
    function XZReport(AShiftId: Integer): TFDQuery; // caller owns
  end;

var
  DM: TDM;

implementation

{$R *.dfm}

procedure TDM.InitDB(const ADbPath: string);
begin
  FDConn.Params.Clear;
  FDConn.Params.DriverID := 'SQLite';
  FDConn.Params.Database := ADbPath;
  FDConn.LoginPrompt := False;
  FDConn.Connected := True;
  EnsureSchema;
  EnsureColumns;
end;

procedure TDM.EnsureSchema;
begin
  FDConn.ExecSQL('PRAGMA foreign_keys=ON');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS worker (' +
                 '  worker_id INTEGER PRIMARY KEY,' +
                 '  username  TEXT NOT NULL UNIQUE,' +
                 '  password  TEXT NOT NULL' +
                 ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS shift (' +
                 '  shift_id INTEGER PRIMARY KEY,' +
                 '  shift_start DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
                 '  shift_end   DATETIME' +
                 ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS item (' +
                 '  item_id INTEGER PRIMARY KEY,' +
                 '  name    TEXT NOT NULL,' +
                 '  price   REAL NOT NULL' +
                 ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS "order" (' +
                 '  order_id     INTEGER PRIMARY KEY,' +
                 '  worker_id    INTEGER NOT NULL REFERENCES worker(worker_id),' +
                 '  shift_id     INTEGER NOT NULL REFERENCES shift(shift_id),' +
                 '  order_time   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
                 '  table_number INTEGER,' +
                 '  status       TEXT NOT NULL DEFAULT ''DRAFT'',' +
                 '  receipt_no   TEXT UNIQUE,' +
                 '  total_cash   REAL NOT NULL DEFAULT 0,' +
                 '  total_card   REAL NOT NULL DEFAULT 0,' +
                 '  total        REAL NOT NULL DEFAULT 0,' +
                 '  is_paid      INTEGER NOT NULL DEFAULT 0' +
                 ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS order_item (' +
                 '  order_item_id INTEGER PRIMARY KEY,' +
                 '  order_id      INTEGER NOT NULL REFERENCES "order"(order_id) ON DELETE CASCADE,' +
                 '  item_id       INTEGER NOT NULL REFERENCES item(item_id),' +
                 '  item_name_snapshot TEXT NOT NULL,' +
                 '  quantity      INTEGER NOT NULL CHECK (quantity>0),' +
                 '  price_each    REAL NOT NULL,' +
                 '  discount_pct  REAL,' +
                 '  total_price   REAL NOT NULL' +
                 ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS payment_method (' +
                 '  method_id INTEGER PRIMARY KEY,' +
                 '  name TEXT NOT NULL UNIQUE' +
                 ')');

  FDConn.ExecSQL('CREATE TABLE IF NOT EXISTS payment (' +
                 '  payment_id INTEGER PRIMARY KEY,' +
                 '  order_id   INTEGER NOT NULL REFERENCES "order"(order_id) ON DELETE CASCADE,' +
                 '  method_id  INTEGER NOT NULL REFERENCES payment_method(method_id),' +
                 '  amount     REAL NOT NULL,' +
                 '  time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,' +
                 '  status     TEXT NOT NULL DEFAULT ''APPROVED'',' +
                 '  auth_ref   TEXT' +
                 ')');

  FDConn.ExecSQL('INSERT OR IGNORE INTO payment_method(method_id,name) VALUES (1,''CASH''),(2,''CARD'')');
    // ensure default users exist (portable for older SQLite)
  FDConn.ExecSQL('INSERT OR IGNORE INTO worker(username,password) VALUES (''radnik'',''1234'')');
  FDConn.ExecSQL('UPDATE worker SET password=''1234'' WHERE username=''radnik''');
  FDConn.ExecSQL('INSERT OR IGNORE INTO worker(username,password) VALUES (''menadzer'',''9999'')');
  FDConn.ExecSQL('UPDATE worker SET password=''9999'' WHERE username=''menadzer''');
  FDConn.ExecSQL('INSERT OR IGNORE INTO shift(shift_id,shift_start) VALUES (1,CURRENT_TIMESTAMP)');
end;

function TDM.ColumnExists(const ATable, ACol: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FDConn;
    Q.Open(Format('PRAGMA table_info("%s")', [ATable]));
    Result := False;
    while not Q.Eof do
    begin
      if SameText(Q.FieldByName('name').AsString, ACol) then
        Exit(True);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TDM.EnsureColumns;

  procedure AddCol(const Tbl, Col, DDL: string);
  begin
    if not ColumnExists(Tbl, Col) then
      FDConn.ExecSQL(Format('ALTER TABLE "%s" ADD COLUMN %s %s', [Tbl, Col, DDL]));
  end;

begin
  AddCol('order','receipt_no','TEXT');
  FDConn.ExecSQL('CREATE UNIQUE INDEX IF NOT EXISTS idx_order_receipt ON "order"(receipt_no)');
  AddCol('order','status','TEXT NOT NULL DEFAULT ''DRAFT''');
  AddCol('order','total_cash','REAL NOT NULL DEFAULT 0');
  AddCol('order','total_card','REAL NOT NULL DEFAULT 0');
  AddCol('order','is_paid','INTEGER NOT NULL DEFAULT 0');

  AddCol('order_item','item_name_snapshot','TEXT');
  AddCol('order_item','discount_pct','REAL');

  if FDConn.ExecSQLScalar('SELECT COUNT(*) FROM payment_method') = 0 then
    FDConn.ExecSQL('INSERT INTO payment_method(name) VALUES (''CASH''),(''CARD'')');
end;

function TDM.Authenticate(const AUser, APass: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FDConn;
    Q.Open('SELECT worker_id, username FROM worker WHERE username=? AND password=?', [AUser, APass]);
    Result := not Q.IsEmpty;
    if Result then ShowMessage('DBG: Authenticate OK worker_id=' + Q.FieldByName('worker_id').AsString) else ShowMessage('DBG: Authenticate FAIL');
    if Result then
    begin
      CurrentWorkerId := Q.FieldByName('worker_id').AsInteger;
      CurrentWorkerName := Q.FieldByName('username').AsString;
    end;
  finally
    Q.Free;
  end;
end;

function TDM.BeginOrder(AWorkerId, ATable, AShiftId: Integer): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FDConn;
    Q.SQL.Text := 'INSERT INTO "order"(worker_id,shift_id,order_time,table_number,status,total,total_cash,total_card,is_paid) ' +
                  'VALUES(:w,:s,CURRENT_TIMESTAMP,:t,''DRAFT'',0,0,0,0)';
    Q.ParamByName('w').AsInteger := AWorkerId;
    Q.ParamByName('s').AsInteger := AShiftId;
    Q.ParamByName('t').AsInteger := ATable;
    Q.ExecSQL;
    Result := FDConn.ExecSQLScalar('SELECT last_insert_rowid()');
  finally
    Q.Free;
  end;
end;

procedure TDM.AddItem(AOrderId, AItemId, AQty: Integer);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FDConn;
    Q.SQL.Text := 'INSERT INTO order_item(order_id,item_id,item_name_snapshot,quantity,price_each,total_price) ' +
                  'SELECT :o, i.item_id, i.name, :q, i.price, i.price * :q FROM item i WHERE i.item_id=:i';
    Q.ParamByName('o').AsInteger := AOrderId;
    Q.ParamByName('q').AsInteger := AQty;
    Q.ParamByName('i').AsInteger := AItemId;
    Q.ExecSQL;
    CalcTotal(AOrderId);
  finally
    Q.Free;
  end;
end;

procedure TDM.RemoveItem(AOrderItemId: Integer);
begin
  FDConn.ExecSQL('DELETE FROM order_item WHERE order_item_id=:id', [AOrderItemId]);
end;

function TDM.CalcTotal(AOrderId: Integer): Currency;
begin
  FDConn.ExecSQL('UPDATE "order" SET total = (SELECT IFNULL(SUM(total_price),0) FROM order_item WHERE order_id=:o) WHERE order_id=:o',
                 [AOrderId, AOrderId]);
  Result := FDConn.ExecSQLScalar('SELECT total FROM "order" WHERE order_id=?', [AOrderId]);
end;

procedure TDM.AddPayment(AOrderId: Integer; const AMethod: string; AAmount: Currency);
var
  methodId: Integer;
begin
  methodId := FDConn.ExecSQLScalar('SELECT method_id FROM payment_method WHERE name=?', [AMethod]);
  if methodId = 0 then
    raise Exception.Create('Nepoznat metod placanja: ' + AMethod);

  FDConn.ExecSQL('INSERT INTO payment(order_id, method_id, amount, status) VALUES(:o,:m,:a,''APPROVED'')',
                 [AOrderId, methodId, AAmount]);

  if SameText(AMethod, 'CASH') then
    FDConn.ExecSQL('UPDATE "order" SET total_cash = total_cash + :a WHERE order_id=:o', [AAmount, AOrderId])
  else
    FDConn.ExecSQL('UPDATE "order" SET total_card = total_card + :a WHERE order_id=:o', [AAmount, AOrderId]);
end;

function TDM.IssueReceipt(AOrderId: Integer): string;
begin
  Result := FormatDateTime('yyyymmdd', Now) + '-' + IntToStr(AOrderId);
  FDConn.ExecSQL('UPDATE "order" SET status=''ISSUED'', is_paid=1, receipt_no=:r WHERE order_id=:o',
                 [Result, AOrderId]);
end;

function TDM.ShiftOpenId: Integer;
begin
  Result := FDConn.ExecSQLScalar('SELECT shift_id FROM shift ORDER BY shift_id DESC LIMIT 1');
  if Result = 0 then
  begin
    FDConn.ExecSQL('INSERT INTO shift(shift_start) VALUES (CURRENT_TIMESTAMP)');
    Result := FDConn.ExecSQLScalar('SELECT last_insert_rowid()');
  end;
end;

function TDM.XZReport(AShiftId: Integer): TFDQuery;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  Q.Connection := FDConn;
  Q.SQL.Text :=
    'SELECT pm.name as method, COUNT(p.payment_id) as cnt, SUM(p.amount) as sum_amount ' +
    'FROM payment p JOIN payment_method pm ON pm.method_id=p.method_id ' +
    'JOIN "order" o ON o.order_id = p.order_id ' +
    'WHERE o.shift_id=:s AND p.status=''APPROVED'' ' +
    'GROUP BY pm.name';
  Q.ParamByName('s').AsInteger := AShiftId;
  Q.Open;
  Result := Q;
end;

end.
