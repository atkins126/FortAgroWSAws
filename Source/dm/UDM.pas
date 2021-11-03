unit UDM;

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
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  Tdm = class(TDataModule)
    AreasTable: TFDQuery;
    AuxatividadeabastecimentoTable: TFDQuery;
    AuxcategoriaitemTable: TFDQuery;
    AuxcoberturaTable: TFDQuery;
    AuxcultivaresTable: TFDQuery;
    AuxculturasTable: TFDQuery;
    AuxgrupoprodutosTable: TFDQuery;
    AuxmarcasTable: TFDQuery;
    AuxpragasTable: TFDQuery;
    AuxpragastipoTable: TFDQuery;
    AuxrevisaoitensTable: TFDQuery;
    AuxsegmentoTable: TFDQuery;
    AuxsubgrupoprodutosTable: TFDQuery;
    AuxtipocultivarTable: TFDQuery;
    AuxtipomaquinaveiculosTable: TFDQuery;
    AuxtipoocorrenciaTable: TFDQuery;
    AuxtipooperacaosolidoTable: TFDQuery;
    AuxtiposervicoTable: TFDQuery;
    CentrocustoTable: TFDQuery;
    DesembarqueTable: TFDQuery;
    Forma_pagamento_fornecedorTable: TFDQuery;
    FornecedorTable: TFDQuery;
    LocalestoqueTable: TFDQuery;
    MaquinaveiculoTable: TFDQuery;
    OperacoesTable: TFDQuery;
    OperadormaquinasTable: TFDQuery;
    OrcamentosTable: TFDQuery;
    OrcamentositensTable: TFDQuery;
    PedidocompraTable: TFDQuery;
    PedidostatusTable: TFDQuery;
    PlanorevisaoTable: TFDQuery;
    PlanorevisaoitensTable: TFDQuery;
    PlanorevisaomaquinasTable: TFDQuery;
    PluviometroTable: TFDQuery;
    PluviometrotalhoesTable: TFDQuery;
    ProdutosTable: TFDQuery;
    PropriedadeTable: TFDQuery;
    SafraTable: TFDQuery;
    ServicoTable: TFDQuery;
    SetorTable: TFDQuery;
    TalhoesTable: TFDQuery;
    UsuarioTable: TFDQuery;
    PedidocompraitemsTable: TFDQuery;
  private
    function GetDataSetAsJSON(DataSet: TDataSet): TJSONObject;
  public
    function RetornaTipoBase:string;
    function PostMudaFlagSync(obj: TJSONObject): TJSONObject;
    function GetGeneric(DataSet: TDataSet):TJSONObject;
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses UPrincipal;

{$R *.dfm}

function Tdm.GetDataSetAsJSON(DataSet: TDataSet): TJSONObject;
var
  f: TField;
  o: TJSOnObject;
  a: TJSONArray;
begin
  a := TJSONArray.Create;
  DataSet.Active := True;
  DataSet.First;
  while not DataSet.EOF do begin
    o := TJSOnObject.Create;
    for f in DataSet.Fields do
      o.AddPair(f.FieldName, VarToStr(f.Value));
    a.AddElement(o);
    DataSet.Next;
  end;
  DataSet.Active := False;
  Result := TJSONObject.Create;
  Result.AddPair(DataSet.Name, a);
end;

function Tdm.GetGeneric(DataSet: TDataSet): TJSONObject;
begin
 DataSet.Close;
 DataSet.Open;
 Result := GetDataSetAsJSON(DataSet);
end;

function Tdm.PostMudaFlagSync(obj: TJSONObject): TJSONObject;
var
 vJsonString,vSql :string;
 vJoInsert,vJoItemO,vJoItemO1 : TJSONObject;
 vJoItem,vJoItem1   : TJSONArray;
 vQry:TFDQuery;
 o: TJSOnObject;
begin
 vQry:=TFDQuery.Create(nil);
 vQry.Connection := frmPrincipal.FDConPG;
 vJsonString := obj.ToString;
 vJoInsert   := TJSONObject.ParseJSONValue(vJsonString) as TJSONObject;
 vJoItem     := vJoInsert.GetValue('Flag') as TJSONArray;
 vJoItemO    := vJoItem.Items[0] as TJSONObject;
 vSql        := vJoItemO.GetValue('SQL').value;
 with vQry, vQry.SQL do
 begin
   Clear;
   Add(vSql);
   try
    ExecSQL;
    o := TJSOnObject.Create;
    o.AddPair('OK','Flag OK');
    Result := O;
   except
    on E: Exception do
    begin
     o := TJSOnObject.Create;
     o.AddPair('ERRO',E.Message);
     Result := O;
    end;
   end;
 end;
 vQry.Free;
end;

function Tdm.RetornaTipoBase: string;
var
 vQry:TFDQuery;
begin
 vQry:=TFDQuery.Create(nil);
 vQry.Connection:=frmPrincipal.FDConPG;
 with vQry,vQry.SQL do
 begin
   Clear;
   Add('select * from systemconfig');
   Open;
   if vQry.FieldByName('agricultura').AsInteger=1 then
    Result := 'Agricultura'
   else
    Result := 'Pecuaria'
 end;
 vQry.Free;
end;

end.
