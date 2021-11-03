object dm: Tdm
  OldCreateOrder = False
  Height = 610
  Width = 886
  object AreasTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM areas'
      'WHERE syncfaz=0')
    Left = 64
    Top = 116
  end
  object AuxatividadeabastecimentoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxatividadeabastecimento'
      'WHERE syncfaz=0')
    Left = 64
    Top = 169
  end
  object AuxcategoriaitemTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxcategoriaitem'
      'WHERE syncfaz=0')
    Left = 58
    Top = 447
  end
  object AuxcoberturaTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxcobertura'
      'WHERE syncfaz=0')
    Left = 223
    Top = 343
  end
  object AuxcultivaresTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxcultivares'
      'WHERE syncfaz=0')
    Left = 218
    Top = 398
  end
  object AuxculturasTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxculturas'
      'WHERE syncfaz=0')
    Left = 61
    Top = 392
  end
  object AuxgrupoprodutosTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxgrupoprodutos'
      'WHERE syncfaz=0')
    Left = 214
    Top = 444
  end
  object AuxmarcasTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxmarcas'
      'WHERE syncfaz=0')
    Left = 62
    Top = 336
  end
  object AuxpragasTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxpragas'
      'WHERE syncfaz=0')
    Left = 221
    Top = 231
  end
  object AuxpragastipoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxpragastipo'
      'WHERE syncfaz=0')
    Left = 220
    Top = 176
  end
  object AuxrevisaoitensTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxrevisaoitens'
      'WHERE syncfaz=0')
    Left = 224
    Top = 286
  end
  object AuxsegmentoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxsegmento'
      'WHERE syncfaz=0')
    Left = 221
    Top = 113
  end
  object AuxsubgrupoprodutosTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxsubgrupoprodutos'
      'WHERE syncfaz=0')
    Left = 224
    Top = 56
  end
  object AuxtipocultivarTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxtipocultivar'
      'WHERE syncfaz=0')
    Left = 220
    Top = 6
  end
  object AuxtipomaquinaveiculosTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxtipomaquinaveiculos'
      'WHERE syncfaz=0')
    Left = 66
    Top = 59
  end
  object AuxtipoocorrenciaTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxtipoocorrencia'
      'WHERE syncfaz=0')
    Left = 67
    Top = 227
  end
  object AuxtipooperacaosolidoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxtipooperacaosolido'
      'WHERE syncfaz=0')
    Left = 66
    Top = 6
  end
  object AuxtiposervicoTable: TFDQuery
    CachedUpdates = True
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM auxtiposervico'
      'WHERE syncfaz=0')
    Left = 66
    Top = 279
  end
  object CentrocustoTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM centrocusto'
      'WHERE syncfaz=0')
    Left = 344
    Top = 9
  end
  object DesembarqueTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM desembarque'
      'WHERE syncfaz=0')
    Left = 346
    Top = 61
  end
  object Forma_pagamento_fornecedorTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM forma_pagamento_fornecedor'
      'WHERE syncfaz=0')
    Left = 345
    Top = 132
  end
  object FornecedorTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM fornecedor'
      'WHERE syncfaz=0')
    Left = 340
    Top = 193
  end
  object LocalestoqueTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM localestoque'
      'WHERE syncfaz=0')
    Left = 326
    Top = 256
  end
  object MaquinaveiculoTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM maquinaveiculo'
      'WHERE syncfaz=0')
    Left = 331
    Top = 318
  end
  object OperacoesTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM operacoes'
      'WHERE syncfaz=0')
    Left = 329
    Top = 378
  end
  object OperadormaquinasTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM operadormaquinas'
      'WHERE syncfaz=0'
      '')
    Left = 337
    Top = 440
  end
  object OrcamentosTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM orcamentos'
      'WHERE syncfaz=0')
    Left = 496
    Top = 10
  end
  object OrcamentositensTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM orcamentositens'
      'WHERE syncfaz=0')
    Left = 494
    Top = 69
  end
  object PedidocompraTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pedidocompra'
      'WHERE syncfaz=0')
    Left = 495
    Top = 133
  end
  object PedidostatusTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pedidostatus'
      'WHERE syncfaz=0')
    Left = 494
    Top = 193
  end
  object PlanorevisaoTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM planorevisao'
      'WHERE syncfaz=0')
    Left = 488
    Top = 342
  end
  object PlanorevisaoitensTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM planorevisaoitens'
      'WHERE syncfaz=0')
    Left = 492
    Top = 400
  end
  object PlanorevisaomaquinasTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM planorevisaomaquinas'
      'WHERE syncfaz=0')
    Left = 489
    Top = 459
  end
  object PluviometroTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pluviometro'
      'WHERE syncfaz=0')
    Left = 487
    Top = 529
  end
  object PluviometrotalhoesTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pluviometrotalhoes'
      'WHERE syncfaz=0')
    Left = 488
    Top = 588
  end
  object ProdutosTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM produtos'
      'WHERE syncfaz=0')
    Left = 489
    Top = 551
  end
  object PropriedadeTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM propriedade'
      'WHERE syncfaz=0')
    Left = 616
    Top = 10
  end
  object SafraTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM safra'
      'WHERE syncfaz=0')
    Left = 612
    Top = 69
  end
  object ServicoTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM servico'
      'WHERE syncfaz=0')
    Left = 616
    Top = 127
  end
  object SetorTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM setor'
      'WHERE syncfaz=0')
    Left = 618
    Top = 187
  end
  object TalhoesTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM talhoes'
      'WHERE syncfaz=0')
    Left = 620
    Top = 250
  end
  object UsuarioTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM usuario'
      'WHERE syncfaz=0')
    Left = 619
    Top = 308
  end
  object PedidocompraitemsTable: TFDQuery
    Connection = frmPrincipal.FDConPG
    SQL.Strings = (
      'SELECT * FROM pedidocompraitems'
      'where syncfaz=0')
    Left = 491
    Top = 256
  end
end
