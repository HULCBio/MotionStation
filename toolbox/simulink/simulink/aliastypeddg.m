function dlgstruct = aliastypeddg(h, name)
  
  %-----------------------------------------------------------------------
  % First Row contains:
  % - baseType label widget
  % - baseType combobox widget
  %-----------------------------------------------------------------------  
  baseTypeLbl.Name = 'Base type:';
  baseTypeLbl.Type = 'text';
  baseTypeLbl.RowSpan = [1 1];
  baseTypeLbl.ColSpan = [1 1];
  
  baseType.Name = '';
  baseType.RowSpan = [1 1];
  baseType.ColSpan = [2 2];
  baseType.Type = 'combobox';
  baseType.Editable = 1;
  baseType.Tag = 'baseType_tag';
  baseType.Entries = {'double', 'single' 'int32','int16','int8',...
                      'uint32','uint16','uint8','boolean'};
  baseType.ObjectProperty = 'BaseType';
  
  %-----------------------------------------------------------------------
  % Second Row contains:
  % - headerFile label widget
  % - headerFile edit field widget
  %-----------------------------------------------------------------------  
  headerFileLbl.Name = 'Header file:';
  headerFileLbl.Type = 'text';
  headerFileLbl.RowSpan = [2 2];
  headerFileLbl.ColSpan = [1 1];
  
  headerFile.Name = '';
  headerFile.RowSpan = [2 2];
  headerFile.ColSpan = [2 2];
  headerFile.Type = 'edit';
  headerFile.Tag = 'headerFile_tag';
  headerFile.ObjectProperty = 'HeaderFile';
  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - Description editarea widget
  %----------------------------------------------------------------------- 
  description.Name = 'Description:';
  description.Type = 'editarea';
  description.Tag = 'description_tag';
  description.RowSpan = [3 3];
  description.ColSpan = [1 2];
  description.ObjectProperty = 'Description';  
  
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = ['Simulink.AliasType: ', name];
  dlgstruct.Items = {baseTypeLbl, baseType, headerFileLbl, headerFile, description};
  dlgstruct.LayoutGrid = [3 2];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot '/mapfiles/simulink.map'], 'simulink_alias_type'};
  dlgstruct.RowStretch = [0 0 1];
  dlgstruct.ColStretch = [0 1];
  
