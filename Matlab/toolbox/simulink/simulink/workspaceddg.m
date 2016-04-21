function dlgstruct = workspaceddg(hObj)
% WORKSSPACEDDG Creates the workspace dialog in the Model Explorer.
%   This function manages and displays the workspace dialog in the 
%   in the Model Explorer.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

if isa(hObj, 'DAStudio.WorkspaceNode')
    hObj = hObj.getParent;
end

if (isa(hObj, 'Simulink.Root'))
    BaseWrkSpaceDesc.Type = 'textbrowser';
    BaseWrkSpaceDesc.Text = l_BaseWSInfo;

    dlgstruct.DialogTitle = 'Base Workspace';
    dlgstruct.Items = {BaseWrkSpaceDesc};
    dlgstruct.HelpMethod  = 'helpview';
    dlgstruct.HelpArgs    = {[docroot '/mapfiles/simulink.map'], 'base_workspace'};

else
    hWS = hObj.getWorkspace;
    modelName = hObj.getFullName;
    
    %Source Combo Box
    source.Name = 'Data source:';
    source.RowSpan = [1 1];
    source.ColSpan = [1 4];
    source.Type = 'combobox';
    source.DialogRefresh = 1;
    source.Tag = 'dataSource';
    source.Entries = {'MDL-File (read/write)', 'MAT-File (read-only)', 'M-Code (read-only)'};
    source.Values  = [workspaceddg_cb([], 'mapDataSourceToValue', hWS, 'MDL-File'), ...
                      workspaceddg_cb([], 'mapDataSourceToValue', hWS, 'MAT-File'), ...
                      workspaceddg_cb([], 'mapDataSourceToValue', hWS, 'M-Code')];
    source.Value = workspaceddg_cb([], 'mapDataSourceToValue', hWS, hWS.DataSource);
    source.MatlabMethod = 'workspaceddg_cb';
    source.MatlabArgs   = {'%dialog', '%tag', hWS, '%value'};
    
    showFileName = false;
    showMCode    = false;
    isWritable   = false;

    switch hWS.DataSource
     case 'MDL-File'
      isWritable = true;
     case 'MAT-File'
      showFileName   = true;
     case 'M-Code'
      showMCode     = 1;
     otherwise
      error(['Unhandled data source: ', hWS.DataSource]);
    end

    %File Name
    fileEdit.Name = 'File name:';
    fileEdit.RowSpan = [2 2];
    fileEdit.ColSpan = [1 4];
    fileEdit.Type = 'edit';
    fileEdit.Tag = 'WorkspaceFileName';
    if (showFileName)
      fileEdit.Source = hWS;
      fileEdit.ObjectProperty = 'FileName';
    end
    fileEdit.Visible = showFileName;

    % User M-code Edit Area
    userMcode.Name = 'M-Code:';
    userMcode.Type = 'editarea';
    userMcode.RowSpan = [3 3];
    userMcode.ColSpan = [1 4];
    userMcode.Visible = showMCode;
    userMcode.Tag = 'MCode';
    if(showMCode)
      userMcode.Source = hWS;
      userMcode.ObjectProperty = 'MCode';
    end
    
    % Import/Reload Button
    if isWritable
      loadButton.Name    = 'Import From MAT-File';
      loadButton.Tag     = 'import';
    else
      loadButton.Name    = 'Re-initialize Workspace';
      loadButton.Tag     = 'reload';
    end
    loadButton.RowSpan = [4 4];
    loadButton.ColSpan = [1 1];
    loadButton.Type    = 'pushbutton';
    loadButton.MatlabMethod = 'workspaceddg_cb';
    loadButton.MatlabArgs   = {'%dialog', '%tag', hWS};
    loadButton.DialogRefresh = 1;
    
    % Export Button (position 1)
    exportButton.Name    = 'Export To MAT-File';
    exportButton.RowSpan = [4 4];
    exportButton.ColSpan = [2 2];
    exportButton.Tag     = 'export';
    exportButton.Type    = 'pushbutton';
    exportButton.Visible = true;
    exportButton.MatlabMethod = 'workspaceddg_cb';
    exportButton.MatlabArgs   = {'%dialog', '%tag', hWS};
    exportButton.Enabled = ~isempty(hWS.whos);

    % Clear Button
    clearButton.Name = 'Clear Workspace';
    clearButton.RowSpan = [4 4];
    clearButton.ColSpan = [4 4];
    clearButton.Tag     = 'clear';
    clearButton.Type    = 'pushbutton';
    clearButton.Visible = isWritable;
    clearButton.MatlabMethod = 'workspaceddg_cb';
    clearButton.MatlabArgs   = {'%dialog', '%tag', hWS};
    clearButton.DialogRefresh = 1;
    
    pnlModelWrkSpace.Name       = 'Workspace data';
    pnlModelWrkSpace.Type       = 'group';
    pnlModelWrkSpace.RowSpan    = [1 1];
    pnlModelWrkSpace.ColSpan    = [1 1];
    pnlModelWrkSpace.LayoutGrid = [4 4];
    pnlModelWrkSpace.ColStretch = [0 0 1 0];
    pnlModelWrkSpace.Items = {source, fileEdit, userMcode, loadButton, exportButton, clearButton};

    %Parameter Argument Names
    modelArgNames.Name = ['Model arguments (for referencing this model):'];
    modelArgNames.NameLocation = 2;
    modelArgNames.RowSpan = [2 2];
    modelArgNames.ColSpan = [1 1];
    modelArgNames.Type = 'edit';
    modelArgNames.Tag = 'ModelParamArgNames';
    modelArgNames.Source = hObj.Handle;
    modelArgNames.ObjectProperty = 'ParameterArgumentNames';
    modelArgNames.ToolTip = ['This is an ordered, comma-separated list of parameters ', ...
                        'that will become the arguments to this model \n', ...
                        'when it is called from within another model (they will ', ...
                        'appear as dialog parameters on the Model block).  \n', ...
                        'To specify the characteristics of these parameters, ', ...
                        'create variables with the same names in this \n', ...
                        'model''s workspace.'];
    modelArgNames.ToolTip = sprintf(modelArgNames.ToolTip);
  
    spacer.Name    = '';
    spacer.Type    = 'text';
    spacer.RowSpan = [3 3];
    spacer.ColSpan = [1 1];

    %%%%%%%%%%%%%%%%%%%%%%%
    % Assemble the dialog
    %%%%%%%%%%%%%%%%%%%%%%%
    dlgstruct.DialogTitle = 'Model Workspace';
    dlgstruct.LayoutGrid = [3 1];
    dlgstruct.RowStretch = [0 0 1];
    dlgstruct.Items = {pnlModelWrkSpace, modelArgNames, spacer};
    
    % Do the rest of assignments for this dialog
    dlgstruct.SmartApply = 0;
    %dlgstruct.PreApplyCallback = 'dataddg_preapply_callback';
    %dlgstruct.PreApplyArgs     = {h, '%dialog'};
    dlgstruct.HelpMethod  = 'helpview';
    dlgstruct.HelpArgs    = {[docroot '/mapfiles/simulink.map'], 'model_workspace'};
    
end

%-----------------------------------------------------------------------------
function htm = l_BaseWSInfo;

htm = ...
    ['<p>The base (MATLAB) workspace contains variables that are visible to ', ...
    'all Simulink models.  These variables can be used to parameterize ', ...
    'certain model, block and signal parameters.<\p>'];
