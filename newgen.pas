unit NewGen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection, sqldb, FileUtil, LResources, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Buttons;

type

  { TfmNewGen }

  TfmNewGen = class(TForm)
    bbCreateGen: TBitBtn;
    BitBtn1: TBitBtn;
    cbTables: TComboBox;
    cbFields: TComboBox;
    cxTrigger: TCheckBox;
    edGenName: TEdit;
    gbTrigger: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure bbCreateGenClick(Sender: TObject);
    procedure cbTablesChange(Sender: TObject);
    procedure cxTriggerChange(Sender: TObject);
  private
    { private declarations }
    fdbIndex: Integer;
    ibConnection: TIBConnection;
    SQLTrans: TSQLTransaction;
  public
    procedure Init(dbIndex: Integer);
    { public declarations }
  end; 

var
  fmNewGen: TfmNewGen;

implementation

{ TfmNewGen }

uses main, SysTables;

procedure TfmNewGen.bbCreateGenClick(Sender: TObject);
var
  List: TStringList;
  Valid: Boolean;
begin
  if Trim(edGenName.Text) <> '' then
  begin
    Valid:= True;
    List:= TStringList.Create;
    List.Add('create generator ' + edGenName.Text + ';');
    if cxTrigger.Checked then
    begin
      Valid:= False;
      if (cbTables.ItemIndex = -1) or (cbFields.ItemIndex = -1) then
        MessageDlg('You should select a table and a field', mtError, [mbOk], 0)
      else
      if Trim(edGenName.Text) = '' then
        MessageDlg('You should enter generator name', mtError, [mbOK], 0)
      else
      begin
        List.Add('CREATE TRIGGER ' + Trim(edGenName.Text) + ' FOR ' + cbTables.Text);
        List.Add('ACTIVE BEFORE INSERT POSITION 0 ');
        List.Add('AS BEGIN ');
        List.Add('IF (NEW.' + cbFields.Text + ' IS NULL OR NEW.' + cbFields.Text + ' = 0) THEN ');
        List.Add('  NEW.' + cbFields.Text + ' = GEN_ID(' + edGenName.Text + ', 1);');
        List.Add('END;');
        Valid:= True;
      end;

    end;
    fmMain.ShowCompleteQueryWindow(fdbIndex, 'Create Generator: ' + edGenName.Text, List.Text);
    Close;
    List.Free;
  end
  else
    MessageDlg('You should write Generator name', mtError, [mbOK], 0);
end;

procedure TfmNewGen.cbTablesChange(Sender: TObject);
var
  FType: string;
begin
  if cbTables.ItemIndex <> -1 then
  begin
    fmMain.GetFields(fdbIndex, cbTables.Text, nil);
    cbFields.Clear;
    while not fmMain.SQLQuery1.EOF do
    begin
      FType:= Trim(fmMain.SQLQuery1.FieldByName('Field_Type_Str').AsString);
      if (FType = 'INTEGER') or (FType = 'INT64') or (FType = 'SMALLINT') then
        cbFields.Items.Add(Trim(fmMain.SQLQuery1.FieldByName('Field_Name').AsString));
      fmMain.SQLQuery1.Next;
    end;
    fmMain.SQLQuery1.Close;

  end;
end;

procedure TfmNewGen.cxTriggerChange(Sender: TObject);
begin
  gbTrigger.Enabled:= cxTrigger.Checked;
end;

procedure TfmNewGen.Init(dbIndex: Integer);
var
  TableNames: string;
  Count: Integer;
begin
  fdbIndex:= dbIndex;
  TableNames:= dmSysTables.GetDBObjectNames(dbIndex, 1, Count);

  fmNewGen.cbTables.Items.CommaText:= TableNames;

  cxTrigger.Checked:= False;
end;

initialization
  {$I newgen.lrs}

end.

