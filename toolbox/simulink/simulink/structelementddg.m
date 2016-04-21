function dlgstruct = structelementddg(h, name)

   nameLbl.Name = 'Name:';
   nameLbl.Type = 'text';
   nameLbl.RowSpan = [1 1];
   nameLbl.ColSpan = [1 1];
   
   nameVal.Name = '';
   nameVal.RowSpan = [1 1];
   nameVal.ColSpan = [2 2];
   nameVal.Type = 'edit';
   nameVal.Tag = 'name_tag';
   nameVal.ObjectProperty = 'Name';
   
   dimLbl.Name = 'Dimensions:';
   dimLbl.Type = 'text';
   dimLbl.RowSpan = [2 2];
   dimLbl.ColSpan = [1 1];
   
   dim.Name = '';
   dim.RowSpan = [2 2];
   dim.ColSpan = [2 2];
   dim.Type = 'edit';
   dim.Tag = 'dim_tag';
   dim.ObjectProperty = 'Dimensions';
   
   datatypeLbl.Name = 'Data type:';
   datatypeLbl.Type = 'text';
   datatypeLbl.RowSpan = [3 3];
   datatypeLbl.ColSpan = [1 1];
   
   datatype.Name = '';
   datatype.RowSpan = [3 3];
   datatype.ColSpan = [2 2];
   datatype.Type = 'edit';
   datatype.Tag = 'datatype_tag';
   datatype.ObjectProperty = 'DataType';
   
   complexLbl.Name = 'Complexity:';
   complexLbl.Type = 'text';
   complexLbl.RowSpan = [4 4];
   complexLbl.ColSpan = [1 1];
   
   complex.Name = '';
   complex.RowSpan = [4 4];
   complex.ColSpan = [2 2];
   complex.Type = 'combobox';
   complex.Tag = 'complex_tag';
   complex.Entries = set(h, 'Complexity')';
   complex.ObjectProperty = 'Complexity';
   complex.Mode = 1;
   complex.DialogRefresh = 1;
   
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = ['Simulink.StructElement: ', name];
  dlgstruct.Items = {nameLbl, nameVal, dimLbl, dim, datatypeLbl, datatype, complexLbl, complex};
  dlgstruct.LayoutGrid = [4 2];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'simulink_struct_element'};
  dlgstruct.ColStretch = [0 1];

