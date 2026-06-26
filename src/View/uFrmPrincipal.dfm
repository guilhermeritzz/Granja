object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Granja'
  ClientHeight = 680
  ClientWidth = 1000
  Color = clBtnFace
  Constraints.MinHeight = 600
  Constraints.MinWidth = 836
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1000
    Height = 680
    ActivePage = tabPesagem
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    OnChanging = PageControl1Changing
    ExplicitLeft = 8
    ExplicitTop = -8
    object tabLista: TTabSheet
      Caption = 'Lista'
      object gridLotes: TDBGrid
        Left = 0
        Top = 41
        Width = 992
        Height = 481
        Align = alClient
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnDblClick = gridLotesDblClick
        Columns = <
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ID_LOTE'
            Title.Alignment = taRightJustify
            Title.Caption = 'N'#186
            Width = 50
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'DESCRICAO'
            Title.Caption = 'Descri'#231#227'o'
            Width = 320
            Visible = True
          end
          item
            Alignment = taCenter
            Expanded = False
            FieldName = 'DATA_ENTRADA'
            Title.Alignment = taCenter
            Title.Caption = 'Entrada'
            Width = 100
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'QUANTIDADE_INICIAL'
            Title.Alignment = taRightJustify
            Title.Caption = 'Qtde Inicial'
            Width = 100
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'PESO_MEDIO_GERAL'
            Title.Alignment = taRightJustify
            Title.Caption = 'Peso M'#233'dio'
            Width = 100
            Visible = True
          end>
      end
      object pnlBarraLista: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 41
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 1
        object btnLoteIncluir: TButton
          Left = 8
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Incluir'
          TabOrder = 0
          OnClick = btnLoteIncluirClick
        end
        object btnLoteExcluir: TButton
          Left = 99
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Excluir'
          TabOrder = 1
          OnClick = btnLoteExcluirClick
        end
        object btnLoteGravar: TButton
          Left = 190
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Gravar'
          TabOrder = 2
          OnClick = btnLoteGravarClick
        end
        object btnLoteCancelar: TButton
          Left = 281
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Cancelar'
          TabOrder = 3
          OnClick = btnLoteCancelarClick
        end
      end
      object pnlLoteDados: TPanel
        Left = 0
        Top = 522
        Width = 992
        Height = 130
        Align = alBottom
        BevelOuter = bvLowered
        TabOrder = 2
        object lblLoteId: TLabel
          Left = 8
          Top = 10
          Width = 36
          Height = 13
          Caption = 'N'#186' Lote'
        end
        object lblLoteDescricao: TLabel
          Left = 88
          Top = 10
          Width = 46
          Height = 13
          Caption = 'Descri'#231#227'o'
        end
        object lblLoteEntrada: TLabel
          Left = 8
          Top = 62
          Width = 64
          Height = 13
          Caption = 'Data Entrada'
        end
        object lblLoteQtd: TLabel
          Left = 128
          Top = 62
          Width = 54
          Height = 13
          Caption = 'Qtde Inicial'
        end
        object lblLotePeso: TLabel
          Left = 240
          Top = 62
          Width = 82
          Height = 13
          Caption = 'Peso M'#233'dio Geral'
        end
        object edtLoteId: TEdit
          Left = 8
          Top = 26
          Width = 70
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object edtLoteDescricao: TEdit
          Left = 88
          Top = 26
          Width = 260
          Height = 21
          TabOrder = 1
        end
        object dtpLoteEntrada: TDateTimePicker
          Left = 8
          Top = 78
          Width = 110
          Height = 21
          Date = 45838.000000000000000000
          Time = 45838.000000000000000000
          TabOrder = 2
        end
        object edtLoteQtdInicial: TEdit
          Left = 128
          Top = 78
          Width = 100
          Height = 21
          TabOrder = 3
        end
        object edtLotePesoMedio: TEdit
          Left = 240
          Top = 78
          Width = 100
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 4
        end
      end
    end
    object tabPesagem: TTabSheet
      Caption = 'Pesagem'
      ImageIndex = 1
      object gridPesagens: TDBGrid
        Left = 0
        Top = 113
        Width = 992
        Height = 429
        Align = alClient
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnDblClick = gridPesagensDblClick
        Columns = <
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ID_PESAGEM'
            Title.Alignment = taRightJustify
            Title.Caption = 'N'#186
            Width = 50
            Visible = True
          end
          item
            Alignment = taCenter
            Expanded = False
            FieldName = 'DATA_PESAGEM'
            Title.Alignment = taCenter
            Title.Caption = 'Data'
            Width = 110
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'PESO_MEDIO'
            Title.Alignment = taRightJustify
            Title.Caption = 'Peso M'#233'dio (Kg)'
            Width = 130
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'QUANTIDADE_PESADA'
            Title.Alignment = taRightJustify
            Title.Caption = 'Qtde Pesada'
            Width = 120
            Visible = True
          end>
      end
      object pnlCabPesagem: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 72
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 1
        object lblPesLoteId: TLabel
          Left = 8
          Top = 8
          Width = 36
          Height = 13
          Caption = 'N'#186' Lote'
        end
        object lblPesLoteDesc: TLabel
          Left = 88
          Top = 8
          Width = 46
          Height = 13
          Caption = 'Descri'#231#227'o'
        end
        object lblPesLoteEntrada: TLabel
          Left = 376
          Top = 8
          Width = 64
          Height = 13
          Caption = 'Data Entrada'
        end
        object lblPesLoteQtd: TLabel
          Left = 484
          Top = 8
          Width = 54
          Height = 13
          Caption = 'Qtde Inicial'
        end
        object edtPesLoteId: TEdit
          Left = 8
          Top = 24
          Width = 70
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object edtPesLoteDesc: TEdit
          Left = 88
          Top = 24
          Width = 280
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object edtPesLoteEntrada: TEdit
          Left = 376
          Top = 24
          Width = 100
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 2
        end
        object edtPesLoteQtd: TEdit
          Left = 484
          Top = 24
          Width = 90
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
        end
      end
      object pnlBarraPesagem: TPanel
        Left = 0
        Top = 72
        Width = 992
        Height = 41
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 2
        object btnPesIncluir: TButton
          Left = 8
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Incluir'
          TabOrder = 0
          OnClick = btnPesIncluirClick
        end
        object btnPesExcluir: TButton
          Left = 99
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Excluir'
          TabOrder = 1
          OnClick = btnPesExcluirClick
        end
        object btnPesGravar: TButton
          Left = 190
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Gravar'
          TabOrder = 2
          OnClick = btnPesGravarClick
        end
        object btnPesCancelar: TButton
          Left = 281
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Cancelar'
          TabOrder = 3
          OnClick = btnPesCancelarClick
        end
        object btnPesAtualizar: TButton
          Left = 388
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Atualizar'
          TabOrder = 4
          OnClick = btnPesAtualizarClick
        end
      end
      object pnlPesEdit: TPanel
        Left = 0
        Top = 542
        Width = 992
        Height = 110
        Align = alBottom
        BevelOuter = bvLowered
        TabOrder = 3
        object lblPesData: TLabel
          Left = 8
          Top = 12
          Width = 69
          Height = 13
          Caption = 'Data Pesagem'
        end
        object lblPesPeso: TLabel
          Left = 128
          Top = 12
          Width = 77
          Height = 13
          Caption = 'Peso M'#233'dio (Kg)'
        end
        object lblPesQtd: TLabel
          Left = 240
          Top = 12
          Width = 62
          Height = 13
          Caption = 'Qtde Pesada'
        end
        object dtpPesData: TDateTimePicker
          Left = 8
          Top = 28
          Width = 110
          Height = 21
          Date = 45838.000000000000000000
          Time = 45838.000000000000000000
          Enabled = False
          TabOrder = 0
        end
        object edtPesPeso: TEdit
          Left = 128
          Top = 28
          Width = 100
          Height = 21
          Enabled = False
          TabOrder = 1
        end
        object edtPesQtd: TEdit
          Left = 240
          Top = 28
          Width = 100
          Height = 21
          Enabled = False
          TabOrder = 2
        end
      end
    end
    object tabMortalidade: TTabSheet
      Caption = 'Mortalidade'
      ImageIndex = 2
      object gridMortalidades: TDBGrid
        Left = 0
        Top = 113
        Width = 992
        Height = 429
        Align = alClient
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        OnDblClick = gridMortalidadesDblClick
        Columns = <
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ID_MORTALIDADE'
            Title.Alignment = taRightJustify
            Title.Caption = 'N'#186
            Width = 50
            Visible = True
          end
          item
            Alignment = taCenter
            Expanded = False
            FieldName = 'DATA_MORTALIDADE'
            Title.Alignment = taCenter
            Title.Caption = 'Data'
            Width = 110
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'QUANTIDADE_MORTA'
            Title.Alignment = taRightJustify
            Title.Caption = 'Qtde Morta'
            Width = 110
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'OBSERVACAO'
            Title.Caption = 'Observa'#231#227'o'
            Width = 420
            Visible = True
          end>
      end
      object pnlCabMort: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 72
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 1
        object lblMortLoteId: TLabel
          Left = 8
          Top = 8
          Width = 36
          Height = 13
          Caption = 'N'#186' Lote'
        end
        object lblMortLoteDesc: TLabel
          Left = 88
          Top = 8
          Width = 46
          Height = 13
          Caption = 'Descri'#231#227'o'
        end
        object lblMortLoteEntrada: TLabel
          Left = 376
          Top = 8
          Width = 64
          Height = 13
          Caption = 'Data Entrada'
        end
        object lblMortLoteQtd: TLabel
          Left = 484
          Top = 8
          Width = 54
          Height = 13
          Caption = 'Qtde Inicial'
        end
        object edtMortLoteId: TEdit
          Left = 8
          Top = 24
          Width = 70
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object edtMortLoteDesc: TEdit
          Left = 88
          Top = 24
          Width = 280
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object edtMortLoteEntrada: TEdit
          Left = 376
          Top = 24
          Width = 100
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 2
        end
        object edtMortLoteQtd: TEdit
          Left = 484
          Top = 24
          Width = 90
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
        end
      end
      object pnlBarraMort: TPanel
        Left = 0
        Top = 72
        Width = 992
        Height = 41
        Align = alTop
        BevelOuter = bvLowered
        TabOrder = 2
        object btnMortIncluir: TButton
          Left = 8
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Incluir'
          TabOrder = 0
          OnClick = btnMortIncluirClick
        end
        object btnMortExcluir: TButton
          Left = 99
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Excluir'
          TabOrder = 1
          OnClick = btnMortExcluirClick
        end
        object btnMortGravar: TButton
          Left = 190
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Gravar'
          TabOrder = 2
          OnClick = btnMortGravarClick
        end
        object btnMortCancelar: TButton
          Left = 281
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Cancelar'
          TabOrder = 3
          OnClick = btnMortCancelarClick
        end
        object btnMortAtualizar: TButton
          Left = 388
          Top = 7
          Width = 85
          Height = 27
          Caption = 'Atualizar'
          TabOrder = 4
          OnClick = btnMortAtualizarClick
        end
      end
      object pnlMortEdit: TPanel
        Left = 0
        Top = 542
        Width = 992
        Height = 110
        Align = alBottom
        BevelOuter = bvLowered
        TabOrder = 3
        object lblMortData: TLabel
          Left = 8
          Top = 12
          Width = 23
          Height = 13
          Caption = 'Data'
        end
        object lblMortQtd: TLabel
          Left = 128
          Top = 12
          Width = 55
          Height = 13
          Caption = 'Qtde Morta'
        end
        object lblMortObs: TLabel
          Left = 240
          Top = 12
          Width = 58
          Height = 13
          Caption = 'Observa'#231#227'o'
        end
        object dtpMortData: TDateTimePicker
          Left = 8
          Top = 28
          Width = 110
          Height = 21
          Date = 45838.000000000000000000
          Time = 45838.000000000000000000
          Enabled = False
          TabOrder = 0
        end
        object edtMortQtd: TEdit
          Left = 128
          Top = 28
          Width = 100
          Height = 21
          Enabled = False
          TabOrder = 1
        end
        object edtMortObs: TEdit
          Left = 240
          Top = 28
          Width = 400
          Height = 21
          Enabled = False
          MaxLength = 255
          TabOrder = 2
        end
      end
    end
  end
end
