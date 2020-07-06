unit DBGrid_custom_connectionFD;

interface

uses
  Data.DB, FireDAC.Comp.Client, System.SysUtils, Vcl.ActnList, Vcl.Dialogs, System.Classes,
  Vcl.Forms, Vcl.DBGrids, Vcl.StdCtrls, FireDAC.Stan.Param, System.UITypes,
  System.Generics.Collections, DBGrid_custom_table;


  type
    TDatabase = (MYSQL, FIREBIRD);

    TDBGrid_custom_connectionFD = class(TComponent)

   private
       FConn : TFDConnection;
       FPathLog: string;
       FDBGrid: TDBGrid;
       FId_user_login : integer;
       FDBGrid_custom_table : TDBGrid_custom_table;
       FDatabase : TDatabase;

       function setConfig: String;

    public
       constructor Create; virtual;
       destructor Destroy; override;

       public procedure loadTable;
       public procedure loadConfig(pForm: TForm);
       public procedure save(pForm: TForm);
       public procedure reset(pForm: TForm);
       public procedure setDBGRID(pDBGrid: TDBGrid);
       public function  getDBGRID:TDBGrid;

    published
       property Conn : TFDConnection read FConn write FConn;
       property DBGrid_custom_table : TDBGrid_custom_table read FDBGrid_custom_table write FDBGrid_custom_table;
       property ID_USER_LOGIN : Integer read FId_user_login write FId_user_login;
       property Database : TDatabase read FDatabase write FDatabase;

    private
       property DBGrid : TDBGrid read FDBGrid write FDBGrid;

    end;

implementation

constructor TDBGrid_custom_connectionFD.Create;
begin

end;

destructor TDBGrid_custom_connectionFD.Destroy;
begin

  inherited;
end;

function TDBGrid_custom_connectionFD.getDBGRID: TDBGrid;
begin
 result := DBGrid;
end;

function TDBGrid_custom_connectionFD.setConfig: String;
var
  Str: TStringStream;
begin
  Str:= TStringStream.Create;

  try
     try
        DBGrid.Columns.SaveToStream(Str);
        Result := Str.DataString;

     except
       on e: Exception do
       begin
         MessageDlg('Erro: ' + e.Message ,  mtError,[mbok],0);
       end;
     end;

  finally
    FreeAndNil(Str);
  end;
end;

procedure TDBGrid_custom_connectionFD.setDBGRID(pDBGrid: TDBGrid);
begin
  DBGrid := pDBGrid;
end;

procedure TDBGrid_custom_connectionFD.loadConfig(pForm: TForm);
 var
  qy : TFDQuery;
  Str: TStringStream;
  pathSave: string;
begin
   qy := TFDQuery.Create(nil);
   qy.Connection := FConn;

  try
     try
         begin
             qy.SQL.Clear;
             qy.SQL.Add(
                 ' SELECT '+ DBGrid_custom_table.FieldConfig +' FROM           '+DBGrid_custom_table.Table+'  ' +#13+
                 ' WHERE                                             ' +#13+
                 ' '+DBGrid_custom_table.FieldForm+'          =  :FORM                  ' +#13+
                 ' AND                                               ' +#13+
                 ' '+DBGrid_custom_table.FieldIdUser+'       =  :USER                  ' +#13+
                 ' AND                                               ' +#13+
                 ' '+DBGrid_custom_table.FieldGrid+'   =  :GRID_NAME                    '
             );
             qy.ParamByName('FORM').AsString       :=   pForm.Name;
             qy.ParamByName('USER').AsInteger      :=   FId_user_login;
             qy.ParamByName('GRID_NAME').AsString  :=   DBGrid.Name;
             qy.Open;

             if not qy.IsEmpty then
             begin
                try
                    Str:= TStringStream.Create( qy.FieldByName(DBGrid_custom_table.FieldConfig).AsString );
                    DBGrid.Columns.LoadFromStream(Str);
                finally
                  FreeAndNil(Str);
                end;
             end;
         end;

     finally
     end;

  finally
    FreeAndNil(qy);
  end;
end;

procedure TDBGrid_custom_connectionFD.loadTable;
var
  TempList: TStringList;
begin
  try
    try
       TempList:= TStringList.Create;
       FConn.GetTableNames('',DBGrid_custom_table.Table,'',TempList);

       if Pos(DBGrid_custom_table.Table,TempList.Text) = 0 then
       begin

         case Database of

            MYSQL:
            begin
              FConn.ExecSQL
               (
                ' CREATE TABLE '+DBGrid_custom_table.Table+' (                    ' + #13 +
                '  '+DBGrid_custom_table.FieldIdUser+  ' INT(11) NOT NULL,        ' + #13 +
                '  '+DBGrid_custom_table.FieldForm+    ' VARCHAR(255) NOT NULL,   ' + #13 +
                '  '+DBGrid_custom_table.FieldGrid+    ' VARCHAR(255) NOT NULL,   ' + #13 +
                '  '+DBGrid_custom_table.FieldConfig+  ' LONGBLOB NOT NULL,       ' + #13 +
                '    DATAHORA TIMESTAMP NOT NULL);                                '
                );
            end;


            FIREBIRD:
            begin
              FConn.ExecSQL(
                ' CREATE TABLE '+DBGrid_custom_table.Table+' (                                  ' + #13 +
                '    '+DBGrid_custom_table.FieldIdUser+  ' INTEGER NOT NULL,                    ' + #13 +
                '    '+DBGrid_custom_table.FieldForm+    ' VARCHAR(255) NOT NULL,               ' + #13 +
                '    '+DBGrid_custom_table.FieldGrid+    ' VARCHAR(255) NOT NULL,               ' + #13 +
                '    '+DBGrid_custom_table.FieldConfig+  ' BLOB SUB_TYPE 0 SEGMENT SIZE 10000,  ' + #13 +
                '    DATAHORA TIMESTAMP NOT NULL);                                              '
                );
            end;

         end;

       end;

    finally
      FreeAndNil(TempList);
    end;

  except
     on e: Exception do
     begin
       Exit;
     end;
  end;
end;

procedure TDBGrid_custom_connectionFD.reset(pForm: TForm);
var
 qy : TFDQuery;
begin
     qy := TFDQuery.Create(nil);
     qy.Connection := FConn;

   try
      try
         begin
             qy.SQL.Clear;
             qy.SQL.Add(
                 ' DELETE   FROM '+DBGrid_custom_table.Table+'         ' +#13+
                 ' WHERE                           ' +#13+
                 ' '+DBGrid_custom_table.FieldForm+' =  :FORM         ' +#13+
                 ' AND                             ' +#13+
                 ' '+DBGrid_custom_table.FieldIdUser+'  =  :USER     ' +#13+
                 ' AND                             ' +#13+
                 ' '+DBGrid_custom_table.FieldGrid+' =  :GRID_NAME    '
             );
             qy.ParamByName('FORM').AsString       :=   pForm.Name;
             qy.ParamByName('USER').AsInteger      :=   FId_user_login;
             qy.ParamByName('GRID_NAME').AsString  :=   DBGrid.Name;
             qy.ExecSQL;

             if qy.RowsAffected > 0 then
             begin
               MessageDlg('Grid resetado, feche a tela e abra novamente.',mtInformation,[mbOK],0);
             end;
         end;

      except
        on e: Exception do
        begin
          MessageDlg('Ops! Houve um erro ao resetar grid' +#13+ E.Message,mtError,[mbok],0);
        end;
      end;

   finally
     qy.Free;
   end;
end;

procedure TDBGrid_custom_connectionFD.save(pForm: TForm);
var
 qy : TFDQuery;
 sql:string;
begin
     qy := TFDQuery.Create(nil);
     qy.Connection := FConn;

   try
      try
         begin
             qy.SQL.Clear;
             qy.SQL.Add(
                 ' SELECT * FROM '+DBGrid_custom_table.Table+'        ' +#13+
                 ' WHERE                          ' +#13+
                 ' '+DBGrid_custom_table.FieldForm+' =  :FORM        ' +#13+
                 ' AND                            ' +#13+
                 ' '+DBGrid_custom_table.FieldIdUser+'  =  :USER    ' +#13+
                 ' AND                            ' +#13+
                 ' '+DBGrid_custom_table.FieldGrid+' =  :GRID_NAME   '
             );
             qy.ParamByName('FORM').AsString       :=   pForm.Name;
             qy.ParamByName('USER').AsInteger      :=   FId_user_login;
             qy.ParamByName('GRID_NAME').AsString  :=   DBGrid.Name;
             qy.Open;

             if qy.IsEmpty then
             begin
                qy.SQL.Clear;
                qy.SQL.Add(
                  'INSERT INTO '+DBGrid_custom_table.Table+'  ' +#13+
                  '('+
                   DBGrid_custom_table.FieldForm+','+
                   DBGrid_custom_table.FieldIdUser+','+
                   DBGrid_custom_table.FieldGrid+','+
                   DBGrid_custom_table.FieldConfig+','+
                   'datahora'+
                  ')' + #13 +
                  'VALUES' + #13 +
                  '('+#13+
                  ':FORM,'+
                  ':USER,'+
                  ':GRID_NAME,'+
                  ':GRID_CONFIG,' +
                  'CURRENT_TIMESTAMP'+
                  ')'
                  );
                qy.ParamByName('FORM').AsString         :=   pForm.Name;
                qy.ParamByName('USER').AsInteger        :=   FId_user_login;
                qy.ParamByName('GRID_NAME').AsString    :=   DBGrid.Name;
                qy.ParamByName('GRID_CONFIG').Value     :=   self.setConfig;
                qy.ExecSQL;

             end
             else
             begin
                qy.SQL.Clear;
                qy.SQL.Add(
                  'UPDATE '+DBGrid_custom_table.Table+'                            ' +#13+
                  'SET                                         ' +#13+
                  ' '+DBGrid_custom_table.FieldConfig+'        =  :GRID_CONFIG,   ' +#13+
                  ' DATAHORA = CURRENT_TIMESTAMP             ' +#13+
                  ' WHERE                                      ' +#13+
                  ' '+DBGrid_custom_table.FieldForm+'          =  :FORM           ' +#13+
                  ' AND                                        ' +#13+
                  ' '+DBGrid_custom_table.FieldIdUser+'       =  :USER           ' +#13+
                  ' AND                                        ' +#13+
                  ' '+DBGrid_custom_table.FieldGrid+'   =  :GRID_NAME '
                );
                qy.ParamByName('FORM').AsString         :=   pForm.Name;
                qy.ParamByName('USER').AsInteger        :=   FId_user_login;
                qy.ParamByName('GRID_NAME').AsString    :=   DBGrid.Name;
                qy.ParamByName('GRID_CONFIG').AsString  :=   self.setConfig;
                qy.ExecSQL;
             end;
         end;

      except
        on e: Exception do
        begin
          MessageDlg('Ops! Houve um erro ao gravar grid' +#13+ E.Message,mtError,[mbok],0);
        end;
      end;

   finally
     qy.Free;
   end;
end;

end.
