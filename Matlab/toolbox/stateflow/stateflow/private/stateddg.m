function dlgstruct = stateddg(h, name)

% Copyright 2002-2004 The MathWorks, Inc.
  
% The name argument is ignored
  
% Setup some common data
  [isFunc, isNoteBox, disableIfGroup, disableIfFuncOrGroup, disableUnlessFunc] = setup_common_data_l(h);
  
  if ~isNoteBox
    % name Label
    nameLabel.Name = 'Name:';
    nameLabel.RowSpan = [1 1];
    nameLabel.ColSpan = [1 1];
    nameLabel.Type = 'text';
    nameLabel.Tag = strcat('sfStatedlg_', nameLabel.Name);
    
    %State Name
    stateName.Name = h.name;
    stateName.RowSpan = [1 1];
    stateName.ColSpan = [2 4];
    stateName.Type = 'hyperlink';
    stateName.MatlabMethod = 'sf';
    stateName.Tag = 'stateNameTag';
    stateName.MatlabArgs = {'Private', 'dlg_goto_object', h.Id};
  end
  
  % Parentlabel widget
  parentLabel.Name = 'Parent:';
  parentLabel.RowSpan = [2 2];
  parentLabel.ColSpan = [1 1];
  parentLabel.Type = 'text';
  parentLabel.Tag = strcat('sfStatedlg_', parentLabel.Name);
  
  %Parent widget 
  parent.Name = get_parent_string_l(h);
  parent.RowSpan = [2 2];
  parent.ColSpan = [2 4];
  parent.Type = 'hyperlink';
  parent.MatlabMethod = 'sf';
  parent.Tag = 'parentTag';
  parent.MatlabArgs = {'Private', 'dlg_goto_parent', h.Id};
  
  if ~isNoteBox
    %Debugger breakpoints
    debuggerLabel.Name = 'Breakpoints:';
    debuggerLabel.RowSpan = [1 1];
    debuggerLabel.ColSpan = [1 1];
    debuggerLabel.Type = 'text';
    debuggerLabel.Tag = strcat('sfStatedlg_', debuggerLabel.Name);
    
    %State During check box
    if(isFunc)
      stateDuring.Name = 'Function Call';
    else
      stateDuring.Name = 'State During';
    end
    
    stateDuring.RowSpan = [1 1];
    stateDuring.ColSpan = [2 2];
    stateDuring.Type = 'checkbox';
    if (has_state_field_l(h, 'Debug'))
      stateDuring.ObjectProperty = 'onDuring';
      stateDuring.Visible = disableIfGroup;
    else 
      stateDuring.Visible = false;
    end
    stateDuring.Tag = strcat('sfStatedlg_', stateDuring.Name);
    
    %State Entry check box
    stateEntry.Name = 'State Entry';
    stateEntry.RowSpan = [1 1];
    stateEntry.ColSpan = [3 3];
    stateEntry.Type = 'checkbox';
    stateEntry.Visible = disableIfFuncOrGroup;
    if (has_state_field_l(h, 'Debug'))
      stateEntry.ObjectProperty = 'onEntry';
    end
    stateEntry.Tag = strcat('sfStatedlg_', stateEntry.Name);
    
    %State Exit check box
    stateExit.Name = 'State Exit';
    stateExit.RowSpan = [1 1];
    stateExit.ColSpan = [4 4];
    stateExit.Type = 'checkbox';
    stateExit.Visible = disableIfFuncOrGroup;
    if (has_state_field_l(h, 'Debug'))
      stateExit.ObjectProperty = 'onExit';
    end;
    stateExit.Tag = strcat('sfStatedlg_', stateExit.Name);

    if (stateExit.Visible || stateEntry.Visible || stateDuring.Visible)
      debuggerLabel.Visible = disableIfGroup;
    else
      debuggerLabel.Visible = false;
    end
    
    
    % pnlEntryExit panel
    pnlEntryExit.Type       = 'panel';
    if (has_state_field_l(h, 'Debug'))
      pnlEntryExit.Source    = h.Debug.Breakpoints;
    end
    pnlEntryExit.RowSpan = [3 3];
    pnlEntryExit.ColSpan = [1 4];
    pnlEntryExit.LayoutGrid = [1 4];
    pnlEntryExit.ColStretch = [2 3 3 3];
    pnlEntryExit.Items      = {debuggerLabel, stateDuring, stateEntry, ...
                        stateExit};
    pnlEntryExit.Tag = 'sfStatedlg_pnlEntryExit';
    
    % Function Inline options
    inlineOption.Name = 'Function Inline Option:';
    inlineOption.Type = 'combobox';
    inlineOption.RowSpan = [4 4];
    inlineOption.ColSpan = [1 4];
    inlineOption.ObjectProperty = 'InlineOption';
    inlineOption.Entries = {'Auto','Inline','Function'};
    inlineOption.Visible = disableUnlessFunc;
    inlineOption.Tag = strcat('sfStatedlg_', inlineOption.Name);
        
    %Output State Activity widget   
    outputState.Name = 'Output State Activity';
    outputState.RowSpan = [5 5];
    outputState.ColSpan = [2 2];
    outputState.Type = 'checkbox';
    if (has_state_field_l(h, 'HasOutputData'))
      outputState.ObjectProperty = 'HasOutputData';
    end
    outputState.Visible = disableIfFuncOrGroup;
    outputState.Tag = strcat('sfStatedlg_', outputState.Name);
  end
  
  % Label widget
  label.Name = 'Label:';
  label.Type = 'editarea';
  label.RowSpan = [6 6];
  label.ColSpan = [1 4];
  if isNoteBox
    label.ObjectProperty = 'Text';
  else
    label.ObjectProperty = 'LabelString';
  end	
  label.Tag = strcat('sfStatedlg_', label.Name);
  
  % description widget
  description.Name = 'Description:';
  description.Type = 'editarea';
  description.RowSpan = [7 7];
  description.ColSpan = [1 4];
  description.ObjectProperty = 'Description';
  description.Tag = strcat('sfStatedlg_', description.Name);
  
  %Document hyperlink
  document.Name = 'Document Link:';
  document.RowSpan = [8 8];
  document.ColSpan = [1 1];
  document.Type = 'hyperlink';
  document.Tag = 'documentTag';
  document.MatlabMethod = 'sf';
  document.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};
  
  %Document edit area
  document1.Name = '';
  document1.RowSpan = [8 8];
  document1.ColSpan = [2 4];
  document1.Type = 'edit';
  document1.ObjectProperty = 'Document';
  document1.Tag = 'sfStatedlg_document1';
  
  title =  get_dialog_title_l(h);
  % if the developer feature is on append the id to the title
  if sf('Feature','Developer')
    id = strcat('#', sf_scalar2str(h.Id));
    dlgstruct.DialogTitle = strcat(title, id);
  else
    dlgstruct.DialogTitle = title;
  end
  dlgstruct.LayoutGrid = [8 4];
  dlgstruct.RowStretch = [0 0 0 0 0 1 1 0];
  dlgstruct.ColStretch = [2 3 3 3];
  dlgstruct.CloseCallback = 'sf';
  dlgstruct.CloseArgs = {'SetDynamicDialog', h.Id, []};
  if ~isNoteBox
    dlgstruct.Items = {nameLabel, stateName, outputState, parentLabel, parent, pnlEntryExit, ...
                       inlineOption, label, description, document, document1 };
  else
    dlgstruct.Items = {parentLabel, parent, label, description, document, document1 };
    
  end
  dlgstruct.DialogTag = strcat('sfStatedlg_', dlgstruct.DialogTitle);
  dlgstruct.HelpMethod = 'sfhelp';
  dlgstruct.HelpArgs = get_help_mapping(h);  
  dlgstruct.DisableDialog = ~is_object_editable(h);

%-------------------------------------------------------------------------------
% Constructs the parent hyperlink string
% Parameters:
%   h - handle to the state udi
%-------------------------------------------------------------------------------
function parentName = get_parent_string_l(h)
  
  parent = sf('get',h.Id,'state.treeNode.parent');
  [MACHINE,CHART,STATE] = sf('get','default','machine.isa','chart.isa','state.isa');
  switch sf('get',parent,'.isa')
   case MACHINE
    parentName = '(machine) ';
   case CHART
    parentName = '(chart) ';
   case STATE
    type = sf('get',parent,'.type');
    if type==3 %GROUP_STATE
      parentName = '(box) ';
    elseif(type==2)
      parentName = '(function) ';
    else
      parentName = '(state) ';
    end
   case EVENT
    parentName = '(event) ';
   otherwise
    parentName = sprintf('(#%d) ',parent);
    warning('Bad parent type.');
  end
  parentName = [parentName sf('FullNameOf',parent,'.')];
  
%-------------------------------------------------------------------------------
% Sets up some booleans that are used to control visibility of some widgets
% Parameters:
%   h = handle to the state udi
%-------------------------------------------------------------------------------
function [isFunc, isNoteBox, disableIfGroup, disableIfFuncOrGroup, disableUnlessFunc] = setup_common_data_l(h)

  FUNC_STATE = 2;
  GROUP_STATE = 3;
  [type,isNoteBox,isTruthtable,isEML] = sf('get', h.Id, '.type','.isNoteBox', ...
                                           '.truthTable.isTruthTable','.eml.isEML');
  isGroup = (type==GROUP_STATE);
  isFunc = (type==FUNC_STATE);
  
  if isGroup
    disableIfGroup = 0;
  else
    disableIfGroup = 1;
  end
  if(isFunc | isGroup)
    disableIfFuncOrGroup = 0;
  else
    disableIfFuncOrGroup = 1;
  end
  if(isFunc)
    disableUnlessFunc = 1;
  else
    disableUnlessFunc = 0;
  end

 %-----------------------------------------------------------------------------
 % Assign the proper help based on the type of object 
function helpArgs = get_help_mapping(h)

  if (isa(h, 'Stateflow.TruthTable') | isa(h, 'Stateflow.EMFunction') | isa(h, 'Stateflow.Function'))
    helpArgs = {'function_dialog'};
  else 
    helpArgs = {'STATE_DIALOG'};
  end  

%-------------------------------------------------------------------------------
% Construct the title of the dialog
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function title = get_dialog_title_l(h)
  
  FUNC_STATE = 2;
  GROUP_STATE = 3;
  [type,isNoteBox,isTruthtable,isEML] = sf('get', h.Id, '.type','.isNoteBox', ...
                                           '.truthTable.isTruthTable','.eml.isEML');
  isGroup = (type==GROUP_STATE);
  isFunc = (type==FUNC_STATE);
  
  stateName = sf('get',h.Id,'.name');
  if isNoteBox
    title = ['Note ',stateName,' ... '];
  elseif isGroup
    title = ['Box ',stateName];
  elseif isTruthtable
    title = ['Truthtable ',stateName];
  elseif isEML
    title = 'Embedded MATLAB Function';
  elseif isFunc
    title = ['Function ',stateName];
  else
    title = ['State ',stateName];
  end
    
%-------------------------------------------------------------------------------
% Determine if the state udi has the specified field defined
% Parameters:
%   h - Handle to the state udi
%   field - Name the field to check
%-------------------------------------------------------------------------------
function result = has_state_field_l(h, field),
  
  result = logical(1);
  try
    get(h, field);
  catch
    result = logical(0);
  end
    
