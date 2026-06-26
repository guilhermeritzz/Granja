object DataModuleGranja: TDataModuleGranja
  Height = 246
  Width = 368
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=GRANJA'
      'User_Name=granja'
      'Password=granja123'
      'DriverID=ora')
    LoginPrompt = False
    Left = 48
    Top = 24
  end
  object FDPhysOracleDriverLink1: TFDPhysOracleDriverLink
    Left = 48
    Top = 88
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 48
    Top = 152
  end
  object qryLotes: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      
        'SELECT ID_LOTE, DESCRICAO, DATA_ENTRADA, QUANTIDADE_INICIAL, PES' +
        'O_MEDIO_GERAL'
      'FROM TAB_LOTE_AVES'
      'ORDER BY ID_LOTE')
    Left = 168
    Top = 24
    object qryLotesID_LOTE: TFMTBCDField
      FieldName = 'ID_LOTE'
      Origin = 'ID_LOTE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Precision = 38
      Size = 38
    end
    object qryLotesDESCRICAO: TStringField
      FieldName = 'DESCRICAO'
      Origin = 'DESCRICAO'
      Required = True
      Size = 100
    end
    object qryLotesDATA_ENTRADA: TDateTimeField
      FieldName = 'DATA_ENTRADA'
      Origin = 'DATA_ENTRADA'
      Required = True
      EditMask = 'DD/MM/YYYY'
    end
    object qryLotesQUANTIDADE_INICIAL: TFMTBCDField
      FieldName = 'QUANTIDADE_INICIAL'
      Origin = 'QUANTIDADE_INICIAL'
      Required = True
      Precision = 38
      Size = 38
    end
    object qryLotesPESO_MEDIO_GERAL: TBCDField
      FieldName = 'PESO_MEDIO_GERAL'
      Origin = 'PESO_MEDIO_GERAL'
      DisplayFormat = '0.00'
      EditFormat = '0.00'
      Precision = 10
      Size = 2
    end
  end
  object dsLotes: TDataSource
    DataSet = qryLotes
    Left = 288
    Top = 24
  end
  object qryPesagens: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT ID_PESAGEM, DATA_PESAGEM, PESO_MEDIO, QUANTIDADE_PESADA'
      'FROM TAB_PESAGEM'
      'WHERE ID_LOTE_FK = :id'
      'ORDER BY DATA_PESAGEM, ID_PESAGEM')
    Left = 168
    Top = 104
    ParamData = <
      item
        Name = 'id'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object qryPesagensID_PESAGEM: TFMTBCDField
      FieldName = 'ID_PESAGEM'
      Origin = 'ID_PESAGEM'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Precision = 38
      Size = 38
    end
    object qryPesagensDATA_PESAGEM: TDateTimeField
      FieldName = 'DATA_PESAGEM'
      Origin = 'DATA_PESAGEM'
      Required = True
    end
    object qryPesagensPESO_MEDIO: TBCDField
      FieldName = 'PESO_MEDIO'
      Origin = 'PESO_MEDIO'
      Required = True
      DisplayFormat = '0.00'
      EditFormat = '0.00'
      Precision = 10
      Size = 2
    end
    object qryPesagensQUANTIDADE_PESADA: TFMTBCDField
      FieldName = 'QUANTIDADE_PESADA'
      Origin = 'QUANTIDADE_PESADA'
      Required = True
      Precision = 38
      Size = 38
    end
  end
  object dsPesagens: TDataSource
    DataSet = qryPesagens
    Left = 288
    Top = 96
  end
  object qryMortalidades: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      
        'SELECT ID_MORTALIDADE, DATA_MORTALIDADE, QUANTIDADE_MORTA, OBSER' +
        'VACAO'
      'FROM TAB_MORTALIDADE'
      'WHERE ID_LOTE_FK = :id'
      'ORDER BY DATA_MORTALIDADE, ID_MORTALIDADE')
    Left = 168
    Top = 168
    ParamData = <
      item
        Name = 'id'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    object qryMortalidadesID_MORTALIDADE: TFMTBCDField
      FieldName = 'ID_MORTALIDADE'
      Origin = 'ID_MORTALIDADE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Precision = 38
      Size = 38
    end
    object qryMortalidadesDATA_MORTALIDADE: TDateTimeField
      FieldName = 'DATA_MORTALIDADE'
      Origin = 'DATA_MORTALIDADE'
      Required = True
    end
    object qryMortalidadesQUANTIDADE_MORTA: TFMTBCDField
      FieldName = 'QUANTIDADE_MORTA'
      Origin = 'QUANTIDADE_MORTA'
      Required = True
      Precision = 38
      Size = 38
    end
    object qryMortalidadesOBSERVACAO: TStringField
      FieldName = 'OBSERVACAO'
      Origin = 'OBSERVACAO'
      Size = 255
    end
  end
  object dsMortalidades: TDataSource
    DataSet = qryMortalidades
    Left = 288
    Top = 168
  end
end
