object dmPost: TdmPost
  OldCreateOrder = False
  Height = 564
  Width = 857
  object AbastecimentoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      
        'select id,status,datareg,idusuario,dataalteracao,idusuarioaltera' +
        'cao,'
      
        'idlocalestoque,idmaquina,idoperador,volumelt,combustivel,dataaba' +
        'stecimento,hora,'
      'syncaws,syncfaz,horimetro,idatividade,obs,valorlitro,externo '
      'from abastecimento a')
    Left = 148
    Top = 76
  end
  object AbastecimentooutrosTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM abastecimentooutros')
    Left = 150
    Top = 137
  end
  object CompradorTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM comprador')
    Left = 151
    Top = 197
  end
  object ContratosTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM contratos')
    Left = 156
    Top = 247
  end
  object DesembarqueTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM desembarque')
    Left = 151
    Top = 298
  end
  object DetoperacaosafratalhaomaquinasoperadoresTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM detoperacaosafratalhaomaquinasoperadores')
    Left = 313
    Top = 31
  end
  object DetoperacaosafratalhaoocorrenciaTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM detoperacaosafratalhaoocorrencia')
    Left = 310
    Top = 94
  end
  object DetoperacaosafratalhaoprodutosTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM detoperacaosafratalhaoprodutos')
    Left = 303
    Top = 158
  end
  object DetreceiturarioTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM detreceiturario')
    Left = 302
    Top = 217
  end
  object DetreceiturariotalhaoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM detreceiturariotalhao')
    Left = 297
    Top = 277
  end
  object DetvazaooperacaoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM detvazaooperacao')
    Left = 298
    Top = 343
  end
  object DevolucaoquimicoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM devolucaoquimico')
    Left = 516
    Top = 25
  end
  object EmbarqueTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM embarque')
    Left = 513
    Top = 79
  end
  object EstoqueentradaTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM estoqueentrada')
    Left = 509
    Top = 150
  end
  object EstoquesaidaTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM estoquesaida')
    Left = 513
    Top = 215
  end
  object MonitoramentopragasTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM monitoramentopragas')
    Left = 504
    Top = 281
  end
  object MonitoramentopragaspontosTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM monitoramentopragaspontos')
    Left = 503
    Top = 333
  end
  object MonitoramentopragaspontosvaloresTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM monitoramentopragaspontosvalores')
    Left = 500
    Top = 396
  end
  object NotafiscalitemsTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM notafiscalitems')
    Left = 507
    Top = 474
  end
  object OperacaosafratalhaoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM operacaosafratalhao')
    Left = 653
    Top = 26
  end
  object PedidocompraTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pedidocompra')
    Left = 660
    Top = 80
  end
  object PedidocompraitemsTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pedidocompraitems')
    Left = 662
    Top = 135
  end
  object PluviometriaTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pluviometria')
    Left = 667
    Top = 191
  end
  object ReceiturarioTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM receiturario')
    Left = 671
    Top = 254
  end
  object RevisaomaquinaTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM revisaomaquina')
    Left = 671
    Top = 317
  end
  object RevisaomaquinaitensTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM revisaomaquinaitens')
    Left = 666
    Top = 377
  end
  object ServicomanutencaoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM servicomanutencao')
    Left = 675
    Top = 456
  end
  object StandsementesTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM standsementes')
    Left = 785
    Top = 28
  end
  object TranferencialocalestoqueTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM tranferencialocalestoque')
    Left = 794
    Top = 82
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 64
    Top = 8
  end
end
