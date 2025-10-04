
object DM: TDM
  OldCreateOrder = False
  Height = 300
  Width = 400
  object FDConn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 64
    Top = 32
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 64
    Top = 88
  end
end
