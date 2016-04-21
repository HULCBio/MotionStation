function dlgstruct = numerictypeddg(h, name)
  
  %-----------------------------------------------------------------------
  % First Row contains:
  % - category label widget
  % - category combobox widget
  %----------------------------------------------------------------------- 
  categoryLbl.Name = 'Category:';
  categoryLbl.Type = 'text';
  categoryLbl.RowSpan = [1 1];
  categoryLbl.ColSpan = [1 1];
  
  category.Name = '';
  category.RowSpan = [1 1];
  category.ColSpan = [2 2];
  category.Tag = 'Category';
  category.Type = 'combobox';
  category.Entries = set(h, 'Category')';
  category.ObjectProperty = 'Category';
  category.Mode = 1;
  category.DialogRefresh = 1;
  catVal = h.Category;
  
  %-----------------------------------------------------------------------
  % Second Row contains:
  % - signed checkbox widget
  %----------------------------------------------------------------------- 
  signed.Name = 'Signed';
  signed.RowSpan = [2 2];
  signed.ColSpan = [1 1];
  signed.Type = 'checkbox';
  signed.Tag = 'Signed';
  signed.ObjectProperty = 'Signed';
  if (strcmp(catVal, 'Double') || strcmp(catVal, 'Single') ||... 
      strcmp(catVal, 'Boolean'))
    signed.Visible = 0;
  else
    signed.Visible = 1;
  end;
  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - Total bits label widget
  % - Total bits edit field widget
  %----------------------------------------------------------------------- 
  totalBitsLbl.Name = 'Word Length:';
  totalBitsLbl.Type = 'text';
  totalBitsLbl.RowSpan = [3 3];
  totalBitsLbl.ColSpan = [1 1];
  
  totalBits.Name = '';
  totalBits.RowSpan = [3 3];
  totalBits.ColSpan = [2 2];
  totalBits.Tag = 'TotalBits';
  totalBits.Type = 'edit';
  totalBits.ObjectProperty = 'WordLengthString'; 
  totalBits.Mode = 1;
   if (strcmp(catVal, 'Double') || strcmp(catVal, 'Single') ||... 
      strcmp(catVal, 'Boolean'))
    totalBitsLbl.Visible = 0;
    totalBits.Visible    = 0;
  else
    totalBitsLbl.Visible = 1;
    totalBits.Visible    = 1;
  end;

  %-----------------------------------------------------------------------
  % Fourth Row contains:
  % - Fraction length label widget
  % - Fraction length edit field widget
  % (only visible for Fixed-point: Binary point scaling mode)
  %----------------------------------------------------------------------- 
  fracLenLbl.Name = 'Fraction Length:';
  fracLenLbl.Type = 'text';
  fracLenLbl.RowSpan = [4 4];
  fracLenLbl.ColSpan = [1 1];
  
  fracLen.Name = '';
  fracLen.RowSpan = [4 4];
  fracLen.ColSpan = [2 2];
  fracLen.Tag = 'FractionLength';
  fracLen.Type = 'edit';
  fracLen.ObjectProperty = 'FractionLengthString';
  fracLen.Mode = 1;
  fracLen.DialogRefresh = 1;
  if strcmp(catVal, 'Fixed-point: binary point scaling')
    fracLenLbl.Visible = 1;
    fracLen.Visible    = 1;
  else
    fracLenLbl.Visible = 0;
    fracLen.Visible    = 0;
  end
  
  %-----------------------------------------------------------------------
  % Fifth Row contains:
  % - Slope label widget
  % - Slope edit field widget
  %----------------------------------------------------------------------- 
  slopeLbl.Name = 'Slope:';
  slopeLbl.Type = 'text';
  slopeLbl.RowSpan = [5 5];
  slopeLbl.ColSpan = [1 1];
  
  slope.Name = '';
  slope.RowSpan = [5 5];
  slope.ColSpan = [2 2];
  slope.Type = 'edit';
  slope.Tag = 'Slope';
  slope.ObjectProperty = 'SlopeString'; 
  slope.Mode = 1;
  slope.DialogRefresh = 1;
  if (strcmp(catVal, 'Fixed-point: slope and bias scaling'))
    slopeLbl.Visible = 1;
    slope.Visible    = 1;
  else
    slopeLbl.Visible = 0;
    slope.Visible    = 0;
  end;
  
  %-----------------------------------------------------------------------
  % Sixth Row contains:
  % - Bias label widget
  % - Bias edit field widget
  %----------------------------------------------------------------------- 
  biasLbl.Name = 'Bias:';
  biasLbl.Type = 'text';
  biasLbl.RowSpan = [6 6];
  biasLbl.ColSpan = [1 1];
  
  bias.Name = '';
  bias.RowSpan = [6 6];
  bias.ColSpan = [2 2];
  bias.Type = 'edit';
  bias.Tag = 'Bias';
  bias.ObjectProperty = 'BiasString';
  bias.Mode = 1;
  if (strcmp(catVal, 'Fixed-point: slope and bias scaling'))
    biasLbl.Visible = 1;
    bias.Visible    = 1;
  else
    biasLbl.Visible = 0;
    bias.Visible    = 0;
  end;
  
  %-----------------------------------------------------------------------
  % Seventh Row contains:
  % - IsAlias checkbox widget
  %----------------------------------------------------------------------- 
  isAlias.Name = 'Is alias';
  isAlias.RowSpan = [7 7];
  isAlias.ColSpan = [1 1];
  isAlias.Type = 'checkbox';
  isAlias.Tag = 'IsAlias';
  isAlias.ObjectProperty = 'IsAlias';
  
  %-----------------------------------------------------------------------
  % Eigth Row contains:
  % - HeaderFile label widget
  % - HeaderFile edit field widget
  %----------------------------------------------------------------------- 
  headerFileLbl.Name = 'Header file:';
  headerFileLbl.Type = 'text';
  headerFileLbl.RowSpan = [8 8];
  headerFileLbl.ColSpan = [1 1];
  
  headerFile.Name = '';
  headerFile.RowSpan = [8 8];
  headerFile.ColSpan = [2 2];
  headerFile.Type = 'edit';
  headerFile.Tag = 'HeaderFile';
  headerFile.ObjectProperty = 'HeaderFile';
  
  %-----------------------------------------------------------------------
  % Nineth Row contains:
  % - Description editarea widget
  %----------------------------------------------------------------------- 
  description.Name = 'Description:';
  description.Type = 'editarea';
  description.Tag = 'Description';
  description.RowSpan = [9 9];
  description.ColSpan = [1 2];
  description.ObjectProperty = 'Description';  
  
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = ['Simulink.NumericType: ' name];
  dlgstruct.Items = {categoryLbl, category, ... 
                     signed, ...
                     totalBitsLbl, totalBits, ...
                     fracLenLbl, fracLen, ...
                     slopeLbl, slope, ...
                     biasLbl, bias, ...
                     isAlias, ...
                     headerFileLbl, headerFile, ...
                     description};
  dlgstruct.LayoutGrid = [9 2];
  dlgstruct.RowStretch = [0 0 0 0 0 0 0 0 1];
  dlgstruct.ColStretch = [0 1];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'simulink_numeric_type'};
  
