unit DBGrid_custom_table;

interface

uses
  System.Classes;

  Type
    TDBGrid_custom_table = class(TComponent)

    private
       FTable : string;
       FId_User : string;
       FForm : string;
       Fgrid_Name : string;
       Fgrid_Config : string;

     published
       property Table : string read FTable write FTable;
       property FieldIdUser : string read FId_User write FId_User;
       property FieldForm : string read FForm write FForm;
       property FieldGrid : string read Fgrid_Name write Fgrid_Name;
       property FieldConfig : string read Fgrid_Config write Fgrid_Config;

    end;

implementation

{ TDBGrid_custom_table }

end.
