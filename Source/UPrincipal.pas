unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  Horse,
  Horse.Jhonson,
  System.JSON, Horse.HandleException,Winapi.Windows, FireDAC.Phys.PGDef,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.PG, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client,System.Json.writers,System.IniFiles,System.JSON.Types,
  IdBaseComponent, IdComponent, IdIPWatch;
type
  TfrmPrincipal = class(TForm)
    Rectangle1: TRectangle;
    btnFechar: TImage;
    lblWS: TLabel;
    Rectangle2: TRectangle;
    mlog: TMemo;
    FDConPG: TFDConnection;
    IdIPWatch1: TIdIPWatch;
    lblTipoBase: TLabel;
    PgDriverLink: TFDPhysPgDriverLink;
    procedure FormShow(Sender: TObject);
    private
    function GetVersaoArq: string;
  public
    vTipoBase:string;
    function ConectaPG: TJSONObject;
    function LerIni(Diretorio,Chave1, Chave2, ValorPadrao: String): String;

  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

uses UDM, UdmPost;

{ TfrmPrincipal }

function TfrmPrincipal.ConectaPG: TJSONObject;
var
 Arquivo,
 vVendorLib,
 dbUser,
 dbPassw,
 dbName,
 dbServer,
 dbPort: String;
 StrAux     : TStringWriter;
 txtJson    : TJsonTextWriter;
begin
 StrAux  := TStringWriter.Create;
 txtJson := TJsonTextWriter.Create(StrAux);
 Arquivo := ExtractFilePath(ParamStr(0))+'Fort.ini';
 if not FileExists(Arquivo) then
 begin
   txtJson.WriteStartObject;
   txtJson.WritePropertyName('Erro');
   txtJson.WriteValue('Arquivo Fort.ini não localizado no seguinte diretorio:'+
   Arquivo);
   txtJson.WriteEndObject;
   Result := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(StrAux.ToString),0)as TJSONObject;
 end
 else
 begin
   vVendorLib := ExtractFilePath(ParamStr(0))+'libpq.dll';
   dbUser     := LerIni(Arquivo,'LOCAL','UserName','');
   dbPassw    := LerIni(Arquivo,'LOCAL','Password','');
   dbName     := LerIni(Arquivo,'LOCAL','Database','');
   dbServer   := LerIni(Arquivo,'LOCAL','Server','');
   dbPort     := LerIni(Arquivo,'LOCAL','Port','');
   with FDConPG do
   begin
    Params.Clear;
    Params.Values['DriverID']        := 'PG';
    Params.Values['User_name']       := dbUser;
    Params.Values['Database']        := dbName;
    Params.Values['Password']        := dbPassw;
    Params.Values['DriverName']      := 'PG';
    Params.Values['Server']          := dbServer;
    Params.Values['Port']            := dbPort;
    PgDriverLink.VendorLib           := vVendorLib;
   try
     Connected := true;
     vTipoBase := dm.RetornaTipoBase;
     lblTipoBase.Text := vTipoBase;
     txtJson.WriteStartObject;
     txtJson.WritePropertyName('Mensagem');
     txtJson.WriteValue('Conexao OK');
     txtJson.WriteEndObject;
     Result := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(StrAux.ToString),0)as TJSONObject;
    except
     on E: Exception do
     begin
      frmPrincipal.mlog.Lines.Add(E.Message);
      StrAux  := TStringWriter.Create;
      txtJson := TJsonTextWriter.Create(StrAux);
      txtJson.Formatting := TJsonFormatting.Indented;
      txtJson.WriteStartObject;
      txtJson.WritePropertyName('Erro');
      txtJson.WriteValue('Erro Ao Conectar DB LOCAL:'+E.Message);
      txtJson.WriteEndObject;
      Result := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(StrAux.ToString),0)as TJSONObject;
     end;
    end;
  end;
 end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  ConectaPG;
  THorse.Use(Jhonson);
  THorse.Use(HandleException);
  if vTipoBase='Agricultura' then
   THorse.Listen(8092, procedure(Horse: THorse)
   begin
     lblWS.Text := ('WS FortAgro: '+vTipoBase+' Porta: ' + Horse.Port.ToString+' Versão:'+GetVersaoArq);
     Application.ProcessMessages;
   end)
  else
   THorse.Listen(8001, procedure(Horse: THorse)
   begin
     lblWS.Text := ('WS FortAgro:'+vTipoBase+' Porta: ' + Horse.Port.ToString+' Versão:'+GetVersaoArq);
     Application.ProcessMessages;
   end);
   THorse.Get('/ping',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
    Res.Send('pong');
   end);
   THorse.Get('/Auxtipooperacaosolido',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxtipooperacaosolido');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxtipooperacaosolidoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxtipomaquinaveiculos',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxtipomaquinaveiculos');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxtipomaquinaveiculosTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Areas',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Areas');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AreasTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxatividadeabastecimento',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxatividadeabastecimento');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxatividadeabastecimentoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxtipoocorrencia',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxtipoocorrencia');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxtipoocorrenciaTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxtiposervico',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxtiposervico');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxtiposervicoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxtipocultivar',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxtipocultivar');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxtipocultivarTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxsubgrupoprodutos',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxsubgrupoprodutos');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxsubgrupoprodutosTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxsegmento',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxsegmento');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxsegmentoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxpragastipo',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get AuxativiAuxpragastipo');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxpragastipoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxpragas',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxpragas');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxpragasTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxrevisaoitens',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxrevisaoitens');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxrevisaoitensTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxcobertura',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxcobertura');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxcoberturaTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxcultivares',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxcultivares');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxcultivaresTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxmarcas',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxmarcas');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxmarcasTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxculturas',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxculturas');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxculturasTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxcategoriaitem',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxcategoriaitem');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxcategoriaitemTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Auxgrupoprodutos',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Auxgrupoprodutos');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.AuxgrupoprodutosTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
   THorse.Get('/Centrocusto',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Centrocusto');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.CentrocustoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Desembarque',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Desembarque');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.DesembarqueTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Forma_pagamento_fornecedor',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Forma_pagamento_fornecedor');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.Forma_pagamento_fornecedorTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Fornecedor',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Fornecedor');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.FornecedorTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Localestoque',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Localestoque');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.LocalestoqueTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Maquinaveiculo',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Maquinaveiculo');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.MaquinaveiculoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Operacoes',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Operacoes');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.OperacoesTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Operadormaquinas',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Operadormaquinas');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.OperadormaquinasTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Orcamentos',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Orcamentos');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.OrcamentosTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Orcamentositens',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Orcamentositens');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.OrcamentositensTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Pedidocompra',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Pedidocompra');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PedidocompraTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Pedidocompraitems',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Pedidocompraitems');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PedidocompraitemsTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Pedidostatus',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Pedidostatus');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PedidostatusTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Planorevisao',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Planorevisao');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PlanorevisaoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Planorevisaoitens',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Planorevisaoitens');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PlanorevisaoitensTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Planorevisaomaquinas',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Planorevisaomaquinas');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PlanorevisaomaquinasTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Pluviometro',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Pluviometro');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PluviometroTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Pluviometrotalhoes',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Pluviometrotalhoes');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PluviometrotalhoesTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Produtos',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Produtos');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.ProdutosTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Propriedade',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Propriedade');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.PropriedadeTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Safra',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Safra');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.SafraTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Servico',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Servico');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.ServicoTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Setor',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Setor');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.SetorTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Talhoes',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Talhoes');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.TalhoesTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);

   THorse.Get('/Usuario',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Get Usuario');
     try
      Res.Send<TJSONObject>(dm.GetGeneric(dm.UsuarioTable));
     except on ex:exception do
      begin
       mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' : Error '+ex.Message);
       Res.Send(tjsonobject.Create.AddPair('Erro',ex.Message)).Status(201);
      end;
     end;
   end);
//******************************post********************************************************
   THorse.Post('/FlagSync',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Alterando Flag Sync');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dm.PostMudaFlagSync(LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Abastecimento',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Abastecimento');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.AbastecimentoTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Abastecimentooutros',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Abastecimento Outros');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.AbastecimentooutrosTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Comprador',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Comprador');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.CompradorTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Contratos',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Contratos');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.ContratosTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Desembarque',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Desembarque');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DesembarqueTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Embarque',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Embarque');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.EmbarqueTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);
   THorse.Post('/Estoqueentrada',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Estoqueentrada');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.EstoqueentradaTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Notafiscalitems',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Notafiscalitems');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.NotafiscalitemsTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Estoquesaida',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Estoquesaida');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.EstoquesaidaTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Tranferencialocalestoque',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Tranferencialocalestoque');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.TranferencialocalestoqueTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);
   THorse.Post('/Devolucaoquimico',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Devolucaoquimico');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DevolucaoquimicoTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);
   THorse.Post('/Revisaomaquina',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Revisaomaquina');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.RevisaomaquinaTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Revisaomaquinaitens',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Revisaomaquinaitens');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.RevisaomaquinaitensTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Servicomanutencao',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Servicomanutencao');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.ServicomanutencaoTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Pluviometria',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Pluviometria');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.PluviometriaTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Standsementes',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Standsementes');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.StandsementesTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Monitoramentopragas',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Monitoramentopragas');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.MonitoramentopragasTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/MonitoramentopragaspontosTable',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Monitoramentopragaspontos');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.MonitoramentopragaspontosTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Monitoramentopragaspontosvalores',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Monitoramentopragaspontosvalores');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.MonitoramentopragaspontosvaloresTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Receiturario',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Receiturario');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.ReceiturarioTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Detreceiturario',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Detreceiturario');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DetreceiturarioTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Detreceiturariotalhao',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Detreceiturariotalhao');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DetreceiturariotalhaoTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Operacaosafratalhao',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Operacaosafratalhao');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.OperacaosafratalhaoTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Detoperacaosafratalhaomaquinasoperadores',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Detoperacaosafratalhaomaquinasoperadores');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DetoperacaosafratalhaomaquinasoperadoresTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Detoperacaosafratalhaoocorrencia',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Detoperacaosafratalhaoocorrencia');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DetoperacaosafratalhaoocorrenciaTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Detoperacaosafratalhaoprodutos',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Detoperacaosafratalhaoprodutos');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DetoperacaosafratalhaoprodutosTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);

   THorse.Post('/Detvazaooperacao',
   procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
   var
     LBody,LBodyRed: TJSONObject;
   begin
     mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Post Detvazaooperacao');
     LBody := Req.Body<TJSONObject>;
    try
     LBodyRed:=dmPost.PostGenerico(dmPost.DetvazaooperacaoTable,LBody);
     Res.Send(LBodyRed).Status(200)
     except on ex:exception do
     begin
      mLog.Lines.Add(FormatDateTime('dd-mm-yyyy-hh:mm:ss',now)+' Erro :'+ex.Message);
      Res.Send(tjsonobject.Create.AddPair('Mensagem', ex.Message)).Status(500);
     end;
    end;
   end);
end;

function TfrmPrincipal.GetVersaoArq: string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(
  ParamStr(0)), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(ParamStr(0)), 0,
  VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue),
  VerValueSize);
  with VerValue^ do
  begin
    Result := IntToStr(dwFileVersionMS shr 16);
    Result := Result + '.' + IntToStr(
    dwFileVersionMS and $FFFF);
    Result := Result + '.' + IntToStr(
    dwFileVersionLS shr 16);
    Result := Result + '.' + IntToStr(
    dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

function TfrmPrincipal.LerIni(Diretorio, Chave1, Chave2,
  ValorPadrao: String): String;
var
 FileIni: TIniFile;
begin
  result := ValorPadrao;
  try
    FileIni := TIniFile.Create(Diretorio);
    if FileExists(Diretorio) then
      result := FileIni.ReadString(Chave1, Chave2, ValorPadrao);
  finally
    FreeAndNil(FileIni)
  end;
end;


end.
