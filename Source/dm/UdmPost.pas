unit UdmPost;

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
  IdBaseComponent, IdComponent, IdIPWatch, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Stan.StorageJSON;

type
  TdmPost = class(TDataModule)
    AbastecimentoTable: TFDQuery;
    AbastecimentooutrosTable: TFDQuery;
    CompradorTable: TFDQuery;
    ContratosTable: TFDQuery;
    DesembarqueTable: TFDQuery;
    DetoperacaosafratalhaomaquinasoperadoresTable: TFDQuery;
    DetoperacaosafratalhaoocorrenciaTable: TFDQuery;
    DetoperacaosafratalhaoprodutosTable: TFDQuery;
    DetreceiturarioTable: TFDQuery;
    DetreceiturariotalhaoTable: TFDQuery;
    DetvazaooperacaoTable: TFDQuery;
    DevolucaoquimicoTable: TFDQuery;
    EmbarqueTable: TFDQuery;
    EstoqueentradaTable: TFDQuery;
    EstoquesaidaTable: TFDQuery;
    MonitoramentopragasTable: TFDQuery;
    MonitoramentopragaspontosTable: TFDQuery;
    MonitoramentopragaspontosvaloresTable: TFDQuery;
    NotafiscalitemsTable: TFDQuery;
    OperacaosafratalhaoTable: TFDQuery;
    PedidocompraTable: TFDQuery;
    PedidocompraitemsTable: TFDQuery;
    PluviometriaTable: TFDQuery;
    ReceiturarioTable: TFDQuery;
    RevisaomaquinaTable: TFDQuery;
    RevisaomaquinaitensTable: TFDQuery;
    ServicomanutencaoTable: TFDQuery;
    StandsementesTable: TFDQuery;
    TranferencialocalestoqueTable: TFDQuery;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
  private
    { Private declarations }
  public
    function PostGenerico(DataSet: TFDQuery;obj: TJSONObject): TJSONObject;
  end;

var
  dmPost: TdmPost;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses UPrincipal, UDM;

{$R *.dfm}

{ TdmPost }

function TdmPost.PostGenerico(DataSet: TFDQuery;obj:TJSONObject): TJSONObject;
var
  I,X,vErro: Integer;
  JsonToSend :TStringStream;
  vField,vFieldJS:string;
  LJSon      : TJSONArray;
  StrAux     : TStringWriter;
  txtJson    : TJsonTextWriter;
  vQry       : TFDQuery;
  vIdResult,vErroStr  :string;
  f: TField;
begin
  vQry       := TFDQuery.Create(nil);
  vQry.Connection    := frmPrincipal.FDConPG;
  DataSet.Open();
  JsonToSend := TStringStream.Create(obj.ToJSON);
  vQry.LoadFromStream(JsonToSend,sfJSON);
  vIdResult:='';
  DataSet.Close;
  DataSet.Open;
  while not vQry.eof do
  begin
    vErro :=0;
    try
     DataSet.Filtered := false;
     DataSet.Filter   := 'id='+vQry.FieldByName('id').AsString;
     DataSet.Filtered := true;
     if DataSet.IsEmpty then
     begin
      DataSet.Insert;
      frmPrincipal.mlog.Lines.Add('Inserindo '+
       StringReplace(DataSet.Name,'Table','',[rfReplaceAll])+
       ' ID: '+vQry.FieldByName('id').AsString);
     end
     else
     begin
      DataSet.Edit;
      frmPrincipal.mlog.Lines.Add('Editando '+
       StringReplace(DataSet.Name,'Table','',[rfReplaceAll])+
       ' ID: '+vQry.FieldByName('id').AsString);
     end;
     for f in DataSet.Fields do
     begin
      vField:=f.FieldName;
      DataSet.FieldByName(vField).AsString     := vQry.FieldByName(vField).AsString;
     end;
      DataSet.ApplyUpdates(-1);
      if DataSet.Name='PedidocompraTable' then
       dm.InsereStatusInicialPedido(vQry.FieldByName('id').AsString);

      frmPrincipal.mlog.Lines.add('Atualizado com Sucesso '+
       StringReplace(DataSet.Name,'Table','',[rfReplaceAll])+
       ' ID: '+vQry.FieldByName('id').AsString);
      if vIdResult.Length>0 then
       vIdResult:=vIdResult+','+vQry.FieldByName('id').AsString
      else
       vIdResult:=vQry.FieldByName('id').AsString;
      vQry.Next;
     except
       on E: Exception do
       begin
         vErro      :=1;
         vErroStr   := e.Message;
         Break;
       end;
    end;
  end;
  if vErro=0 then
  begin
    StrAux  := TStringWriter.Create;
    txtJson := TJsonTextWriter.Create(StrAux);
    txtJson.Formatting := TJsonFormatting.Indented;
    txtJson.WriteStartObject;
    txtJson.WritePropertyName('OK');
    txtJson.WriteValue(vIdResult);
    txtJson.WriteEndObject;
    Result := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(StrAux.ToString),0)as TJSONObject;
  end
  else
  begin
    StrAux  := TStringWriter.Create;
    txtJson := TJsonTextWriter.Create(StrAux);
    txtJson.Formatting := TJsonFormatting.Indented;
    txtJson.WriteStartObject;
    txtJson.WritePropertyName('Erro');
    txtJson.WriteValue('Erro Ao Sincronizar:'+DataSet.Name+vErroStr);
    txtJson.WriteEndObject;
    Result := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(StrAux.ToString),0)as TJSONObject;
  end;

end;

end.
