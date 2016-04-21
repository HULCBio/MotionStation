function dlgstruct = dataddg_mxarray(h)
   
  %-----------------------------------------------------------------------
  % First Row contains:
  % - Values label widget
  % - Values edit widget
  %-----------------------------------------------------------------------  
  valueText.Name          = 'Value:';
  valueText.RowSpan       = [1 1];
  valueText.ColSpan       = [1 1];
  valueText.Type          = 'text';
  
  valueEdit.RowSpan       = [1 1];
  valueEdit.ColSpan       = [2 2];
  valueEdit.Type          = 'edit';
  valueEdit.Tag           = 'value_tag';
  valueEdit.Value         = h.getPropValue('Value');
  valueEdit.MatlabMethod  = 'setPropValue';
  valueEdit.MatlabArgs    = {h, 'Value', '%value'};
  valueEdit.DialogRefresh = true;
  
  %-----------------------------------------------------------------------
  % Second Row contains:
  % - dataType label widget
  % - dataType edit widget
  %-----------------------------------------------------------------------  
  dataTypeText.Name       = 'Data Type:';
  dataTypeText.Type       = 'text';
  dataTypeText.RowSpan    = [2 2];
  dataTypeText.ColSpan    = [1 1];
  
  dataType.RowSpan        = [2 2];
  dataType.ColSpan        = [2 2];
  dataType.Type           = 'edit';
  dataType.Tag            = 'dataType_tag';
  dataType.Enabled        = 0;
  dataType.Value          = h.getPropValue('DataType');

  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - spacer panel to absorb extra space
  %-----------------------------------------------------------------------  
  spacer.Type             = 'panel';
  spacer.RowSpan          = [3 3];
  spacer.ColSpan          = [1 2];
  
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.SmartApply       = 0;
  dlgstruct.DialogTag        = 'dataddg_mxarray';
  dlgstruct.DialogTitle      = ['Data properties: ', h.getDisplayLabel];
  dlgstruct.LayoutGrid       = [3 2];
  dlgstruct.ColStretch       = [0 1];
  dlgstruct.RowStretch       = [0 0 1];
  dlgstruct.HelpMethod       = 'doc';
  dlgstruct.Items            = {valueText, valueEdit,...
                                dataTypeText, dataType, spacer};
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'matlab_variable'};

%--------------------End of Main function --------------------------------
  
  
