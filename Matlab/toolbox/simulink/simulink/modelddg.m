function dlgstruct = modelddg(h)

% Copyright 2003-2004 The MathWorks, Inc.

  %------------------------------------------------------------------------
  % Tab One contains:
  % - TextBrowser widget with model info
  %------------------------------------------------------------------------
  info.Type = 'textbrowser';
  info.Text = model_info_l(h);
  info.DialogRefresh = 1;
  
  %------------------------------------------------------------------------
  % Tab Two contains:
  % - Model callback functions widgets
  %------------------------------------------------------------------------
  preloadEdit.Name = 'Model pre-load function:';
  preloadEdit.RowSpan = [1 1];
  preloadEdit.ColSpan = [1 1];
  preloadEdit.Type = 'editarea';
  preloadEdit.MinimumSize = [0 50];
  preloadEdit.ObjectProperty = 'PreLoadFcn';
  
  initEdit.Name = 'Model initialization function:';
  initEdit.RowSpan = [2 2];
  initEdit.ColSpan = [1 1];
  initEdit.Type = 'editarea';
  initEdit.MinimumSize = [0 50];
  initEdit.ObjectProperty = 'InitFcn';
  
  startEdit.Name = 'Simulation start function:';
  startEdit.RowSpan = [3 3];
  startEdit.ColSpan = [1 1];
  startEdit.Type = 'editarea';
  startEdit.MinimumSize = [0 50];
  startEdit.ObjectProperty = 'StartFcn';
  
  stopEdit.Name = 'Simulation stop function:';
  stopEdit.RowSpan = [4 4];
  stopEdit.ColSpan = [1 1];
  stopEdit.Type = 'editarea';
  stopEdit.MinimumSize = [0 50];
  stopEdit.ObjectProperty = 'StopFcn';
  
  presaveEdit.Name = 'Model pre-save function:';
  presaveEdit.RowSpan = [5 5];
  presaveEdit.ColSpan = [1 1];
  presaveEdit.Type = 'editarea';
  presaveEdit.MinimumSize = [0 50];
  presaveEdit.ObjectProperty = 'PreSaveFcn';
  
  closeEdit.Name = 'Model close function:';
  closeEdit.RowSpan = [6 6];
  closeEdit.ColSpan = [1 1];
  closeEdit.Type = 'editarea';
  closeEdit.MinimumSize = [0 50];
  closeEdit.ObjectProperty = 'CloseFcn';
  
  %------------------------------------------------------------------------
  % Tab Three contains:
  % - Model information (version, created by etc) and model history widgets
  %------------------------------------------------------------------------  
  
  readOnly.Name = 'Read Only';
  readOnly.RowSpan = [3 3];
  readOnly.ColSpan = [1 1];
  readOnly.Type = 'checkbox';
  readOnly.DialogRefresh = 1;
  readOnly.Tag = 'readOnly_tag';
  readOnly.MatlabMethod = 'modelddg_readOnly_cb';
  readOnly.MatlabArgs = {h, '%dialog'};
  if (strcmp(h.EditVersionInfo,'ViewCurrentValues'))
    readOnly.Value = 1;
    editMode = 0;
  else
    readOnly.Value = 0;
    editMode = 1;
  end
  
  creatorEditLbl.Name = 'Created by:';
  creatorEditLbl.Type = 'text';
  creatorEditLbl.RowSpan = [1 1];
  creatorEditLbl.ColSpan = [1 1];
  
  creatorEdit.Name = '';
  creatorEdit.RowSpan = [1 1];
  creatorEdit.ColSpan = [2 2];
  creatorEdit.Type = 'edit';
  creatorEdit.Tag = 'createdBy';
  creatorEdit.ObjectProperty = 'Creator';
  if editMode == 1
      creatorEdit.Enabled = 1;
  else
      creatorEdit.Enabled = 0;
  end

  lastByValLbl.Name = 'Last saved by:';
  lastByValLbl.Type = 'text';
  lastByValLbl.RowSpan = [1 1];
  lastByValLbl.ColSpan = [3 3];
  
  lastByVal.Name = '';
  lastByVal.RowSpan = [1 1];
  lastByVal.ColSpan = [4 4];
  lastByVal.Type = 'edit';
  lastByVal.Tag = 'lastBy';
  if (editMode == 1)
    lastByVal.ObjectProperty = 'ModifiedByFormat';
  else
    lastByVal.Value = h.LastModifiedBy;
    lastByVal.Enabled = 0;
  end

  %Created By Edit area
  createdEditLbl.Name = 'Created on:';
  createdEditLbl.Type = 'text';
  createdEditLbl.RowSpan = [2 2];
  createdEditLbl.ColSpan = [1 1];
  
  createdEdit.Name = '';
  createdEdit.RowSpan = [2 2];
  createdEdit.ColSpan = [2 2];
  createdEdit.Type = 'edit';
  createdEdit.Tag = 'createdOn';
  createdEdit.ObjectProperty = 'Created';
  if editMode == 1
      createdEdit.Enabled = 1;
  else
      createdEdit.Enabled = 0;
  end
 
  lastOnVerValLbl.Name = 'Last saved on:'; 
  lastOnVerValLbl.Type = 'text';
  lastOnVerValLbl.RowSpan = [2 2];
  lastOnVerValLbl.ColSpan = [3 3];
  
  lastOnVerVal.Name = '';
  lastOnVerVal.RowSpan = [2 2];
  lastOnVerVal.ColSpan = [4 4];
  lastOnVerVal.Type = 'edit';
  lastOnVerVal.Tag = 'lastOn';
  lastOnVerVal.Value = h.LastModifiedDate;
  if (editMode == 1)
    lastOnVerVal.ObjectProperty = 'ModifiedDateFormat';
  else
    lastOnVerVal.Value = h.LastModifiedDate;
    lastOnVerVal.Enabled = 0;
  end
  
  modelVerValLbl.Name = 'Model version:';
  modelVerValLbl.Type = 'text';
  modelVerValLbl.RowSpan = [3 3];
  modelVerValLbl.ColSpan = [3 3];
  
  modelVerVal.Name = '';
  modelVerVal.RowSpan = [3 3];
  modelVerVal.ColSpan = [4 4];
  modelVerVal.Type = 'edit';
  modelVerVal.Tag = 'modelVer';
  if (editMode == 1)
    modelVerVal.ObjectProperty = 'ModelVersionFormat';
  else
    modelVerVal.Enabled = 0;
    modelVerVal.Value = h.ModelVersion;
  end
  
  version.Name = 'Model information';
  version.Type = 'group';
  version.LayoutGrid = [3 4];
  version.ColStretch = [0 1 0 1];
  version.RowSpan = [1 1];
  version.ColSpan = [1 1];
  version.Items = {creatorEditLbl, creatorEdit, ...
                   lastByValLbl, lastByVal, ...
                   createdEditLbl, createdEdit, ...
                   lastOnVerValLbl, lastOnVerVal, ...
                   readOnly, ...             
                   modelVerValLbl, modelVerVal};   
               
  % History widget
  history.Name = 'Model history:';
  history.Type = 'editarea';
  history.RowSpan = [1 1];
  history.ColSpan = [1 2];
  history.ObjectProperty = 'ModifiedHistory';
  
  promptHistoryVal.Name = 'Prompt to update model history:';
  promptHistoryVal.RowSpan = [2 2];
  promptHistoryVal.ColSpan = [2 2];
  promptHistoryVal.Type = 'combobox';
  promptHistoryVal.Entries = {'Never', 'When saving model'};
  if (strcmp(h.UpdateHistory, 'UpdateHistoryNever') == 1)
    promptHistoryVal.Value = 1;
  else
     promptHistoryVal.Value = 2;
  end
  promptHistoryVal.ObjectProperty = 'UpdateHistory';
  
  spacerPnl.Type = 'panel';
  spacerPnl.RowSpan = [2 2];
  spacerPnl.ColSpan = [1 1];
  
  modelHistoryPanel.Type = 'panel';
  modelHistoryPanel.LayoutGrid = [2 2];
  modelHistoryPanel.RowSpan = [2 2];
  modelHistoryPanel.ColSpan = [1 1];
  modelHistoryPanel.RowStretch = [1 0];
  modelHistoryPanel.ColStretch = [1 0];
  modelHistoryPanel.Items = {history, spacerPnl, promptHistoryVal};
  
  %------------------------------------------------------------------------
  % Tab Four contains:
  % - Description edit area
  %------------------------------------------------------------------------
  % Description Edit Area
  description.Name = 'Model description:';
  description.Type = 'editarea';
  description.ObjectProperty = 'Description';
   
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  

  tab1.Name = 'Main';
  tab1.LayoutGrid = [1 1];
  tab1.Items = {info};
  
  tab2.Name = 'Callbacks';
  tab2.LayoutGrid = [6 1];
  tab2.Items = {preloadEdit, initEdit, startEdit, stopEdit, presaveEdit, closeEdit};
                  
  tab3.Name = 'History';
  tab3.LayoutGrid = [2 1];
  tab3.RowStretch = [0 1];
  tab3.Items = {version, modelHistoryPanel};
    
  tab4.Name = 'Description';
  tab4.Items = {description};
  
  tabcont.Type = 'tab';
  tabcont.Tabs = {tab1 tab2 tab3 tab4};
  dlgstruct.Items = {tabcont};
 
  % Do the rest of assignments for this dialog
  dlgstruct.DialogTitle = 'Model Properties';
  dlgstruct.SmartApply  = 0;
  dlgstruct.HelpMethod  = 'helpview';
  dlgstruct.HelpArgs    = {[docroot '/mapfiles/simulink.map'], 'modelpropertiesdialog'};
  
%-------------------------- End of main function ----------------------------

%----------------------------------------------------------------------------
function htm = model_info_l(h)

if isequal(h.Dirty, 'on'),  isModifiedStr = '<font color=''red''>yes</font>';
else,                       isModifiedStr = 'no';
end;

numContStates     = NaN;
numDiscStates     = NaN;
numOutputs        = NaN;
numInputs         = NaN;
directFeedthrough = NaN;
numSampleTimes    = NaN;

X = get_param(h.Name, 'tag');
X = str2num(X);

if length(X) == 6,
numContStates     = X(1);
numDiscStates     = X(2);
numOutputs        = X(3);
numInputs         = X(4);
directFeedthrough = X(5);
numSampleTimes    = X(6);
end;

 str = ['<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0 bgcolor="#ededed">',...
        '<tr><td>', ...
        '<b><font size=+3>Model Information for: <a href="matlab:%s">%s</a></b></font>', ...
        '<table>',...
        '<tr><td align="right"><b>Source file:</b></td><td><a href="matlab:edit(%s)">%s</a></td></tr>', ...   
        '<tr><td align="right"><b>Last Saved:</b></td><td>%s</td></tr>', ...
        '<tr><td align="right"><b>Created On:</b></td><td>%s</td></tr>', ...
        '<tr><td align="right"><b>Is Modified:</b></td><td>', isModifiedStr,'</td></tr>', ...
        '<tr><td align="right"><b>Model Version:</b></td><td>%s</td></tr>', ...     
       '</table>', ...
       '</td></tr>', ...
       '</table>',...
        ];
 
% Add this back in when we have the internal APIs setup. 
% ALSO, add Model block's references and libraries referenced as well. See g172677 for more details.
%
%       '   <br><br>',...
%       '<table width="200%%"  BORDER=0 CELLSPACING=0 CELLPADDING=0>',...
%       '<tr><td>',...
%       '<b><font size=+2>Last Update Diagram Summary</font></b> ( <a href="matlab:%s">Execute Update Diagram</a> )', ...
%       '<table>',...
%       '<tr><td align="right"><b>Number of continuous states:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of discrete states:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of outputs:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of inputs:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Direct Feedthrough:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Number of sample times:</b></td><td>%d</td></tr>', ...
%       '<tr><td align="right"><b>Library dependencies:</b></td><td>TBD</td></tr>', ...
%       '</table>', ... 
%       '</td></tr>', ...
%       '</table>' ...
%        ];
        
 editStr =  ['''',h.Name,'.mdl'''];
 execStr = ['try,[t_,rs_] = sldiagnostics(''', h.Name, ''',''Sizes''); c_ = struct2cell(rs_); d_ = [c_{:}]; set_param(''',h.Name,''',''tag'', num2str(d_));  clear(''t_''); clear(''rs_''); clear(''c_''); clear (''d_'');end;']; 
 
%fix this later
%fn = h.FileName;
%if length(fn)>2 & isequal(fn(2), ':'),
%  fn = fn(3:end);
%end;
%editStr =  ['''',fn,'''']

 htm = sprintf(str, h.Name, h.Name, editStr, h.FileName,  h.LastModifiedDate, ...
               h.Created, h.ModelVersion);
 
% execStr, numContStates, numDiscStates, ...
%               numOutputs, numInputs, directFeedthrough, numSampleTimes ...
%               );

%---------------------------------------------------------------------------------
function htm = ws_info_1

htm = ...
    ['<p>The model workspace is similar to the base MATLAB workspace except:<br>', ...
     '<ul>', ...
     '<li>Variables in this workspace are only visible within the scope of this model.', ...
     '<li>When the model is loaded, the workspace is initialized from a data repository.', ...
     '<li>Changes to the workspace are saved to the data repository when the ', ...
     'model is saved (for MAT-File / MDL-File repositories).', ...
     '<li>The current data repository can also be manually reloaded or saved.', ...
     '<li>In general, parameters in this workspace are not tunable.  However, when ', ...
     'referencing this model from another model, parameters can be made tunable by ', ...
     'identifying them as parameter arguments.', ...
     '</ul></p>', ...
     '<p>To work with this workspace at the MATLAB command line, type: <br>',...
     '<div style="font-family: courier">',...
     '>> <a href="matlab:eval(''ws = get_param(bdroot, ''''BlockDiagramWorkspace'''')'')">',...
     'ws = get_param(bdroot, ''BlockDiagramWorkspace'') ',...
     '</div></p>'];
