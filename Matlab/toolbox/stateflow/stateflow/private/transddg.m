function dlgstruct = transddg(h, name)

% Copyright 2002-2003 The MathWorks, Inc.

  % We ignore the name in this dialog schema

  % sourcelabel widget
  sourceLabel.Name = 'Source:';
  sourceLabel.RowSpan = [1 1];
  sourceLabel.ColSpan = [1 1];
  sourceLabel.Type = 'text';
  sourceLabel.Tag = strcat('sfTransdlg_', sourceLabel.Name);
  %source widget 
  
  source.Name = get_source_string_l(h);
  source.RowSpan = [1 1];
  source.ColSpan = [2 2];
  source.Type = 'hyperlink';
  source.MatlabMethod = 'sf';
  source.Tag = 'sourceTag';
  source.MatlabArgs = {'Private', 'dlg_goto_source', h.Id};
  
  % destlabel widget
  destLabel.Name = 'Destination:';
  destLabel.RowSpan = [2 2];
  destLabel.ColSpan = [1 1];
  destLabel.Type = 'text';
  destLabel.Tag = strcat('sfTransdlg_', destLabel.Name);
  
  %dest widget 
  dest.Name = get_dest_string_l(h);
  dest.RowSpan = [2 2];
  dest.ColSpan = [2 2];
  dest.Type = 'hyperlink';
  dest.Tag = 'destTag';
  dest.MatlabMethod = 'sf';
  dest.MatlabArgs = {'Private', 'dlg_goto_dest', h.Id};
  
  % Parentlabel widget
  parentLabel.Name = 'Parent:';
  parentLabel.RowSpan = [3 3];
  parentLabel.ColSpan = [1 1];
  parentLabel.Type = 'text';
  parentLabel.Tag = strcat('sfTransdlg_', parentLabel.Name);
  
  %Parent widget 
  parent.Name = get_parent_string_l(h);
  parent.RowSpan = [3 3];
  parent.ColSpan = [2 2];
  parent.Type = 'hyperlink';
  parent.Tag = 'parentTag';
  parent.MatlabMethod = 'sf';
  parent.MatlabArgs = {'Private', 'dlg_goto_parent', h.Id};
  
  %Debugger breakpoints
  debuggerLabel.Name = 'Debugger breakpoints:';
  debuggerLabel.RowSpan = [1 1];
  debuggerLabel.ColSpan = [1 1];
  debuggerLabel.Type = 'text';
  debuggerLabel.Tag = strcat('sfTransdlg_', debuggerLabel.Name);
  
  %when tested check box
  whenTested.Name = 'When Tested';
  whenTested.RowSpan = [1 1];
  whenTested.ColSpan = [2 2];
  whenTested.Type = 'checkbox';
  whenTested.ObjectProperty = 'WhenTested';
  whenTested.Tag = strcat('sfTransdlg_', whenTested.Name);
  
   %when valid check box
  whenValid.Name = 'When Valid';
  whenValid.RowSpan = [1 1];
  whenValid.ColSpan = [3 3];
  whenValid.Type = 'checkbox';
  whenValid.ObjectProperty = 'WhenValid';
  whenValid.Tag            = strcat('sfTransdlg_', whenValid.Name);
  
   % pnlEntryExit panel
  pnlEntryExit.Type       = 'panel';
  pnlEntryExit.Source    = h.Debug.Breakpoints;
  pnlEntryExit.RowSpan = [4 4];
  pnlEntryExit.ColSpan = [1 2];
  pnlEntryExit.LayoutGrid = [1 3];
  pnlEntryExit.ColStretch = [0 0 1];
  pnlEntryExit.Items      = {debuggerLabel, whenTested, whenValid};
  pnlEntryExit.Tag        = 'sfTransdlg_pnlEntryExit';
  
   % Label widget
  label.Name = 'Label:';
  label.Type = 'editarea';
  label.RowSpan = [5 5];
  label.ColSpan = [1 2];
  label.ObjectProperty = 'LabelString';
  label.Tag = strcat('sfTransdlg_', label.Name);
  
  % description widget
  description.Name = 'Description:';
  description.Type = 'editarea';
  description.RowSpan = [6 6];
  description.ColSpan = [1 2];
  description.ObjectProperty = 'Description';
  description.Tag = strcat('sfTransdlg_', description.Name);
  
  %Document hyperlink
  document.Name = 'Document Link';
  document.RowSpan = [7 7];
  document.ColSpan = [1 1];
  document.Type = 'hyperlink';
  document.Tag = 'documentTag';
  document.MatlabMethod = 'sf';
  document.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};
  
   %Document edit area
  document1.Name = '';
  document1.RowSpan = [7 7];
  document1.ColSpan = [2 2];
  document1.Type = 'edit';
  document1.ObjectProperty = 'Document';
  document1.Tag = 'sfTransdlg_document1';
  
  %%%%%%%%%%%%%%%%%%%%%%%
  % Main dialog
  %%%%%%%%%%%%%%%%%%%%%%%
  title = get_trans_title_l(h);
  % if the developer feature is on append the id to the title
  if sf('Feature','Developer')
    id = strcat('#', sf_scalar2str(h.Id));
    dlgstruct.DialogTitle = strcat(title, id);
  else
    dlgstruct.DialogTitle = title;
  end
  dlgstruct.LayoutGrid = [7 2];
  dlgstruct.RowStretch = [0 0 0 0 1 2 0];
  dlgstruct.ColStretch = [0 1];
  dlgstruct.CloseCallback = 'sf';
  dlgstruct.CloseArgs     = {'SetDynamicDialog', h.Id, []};
  dlgstruct.Items         = {sourceLabel, source, destLabel, dest, parentLabel, parent,...,
                     pnlEntryExit, label, description, document, document1 };
  
  dlgstruct.DialogTag     = strcat('sfTransdlg_', dlgstruct.DialogTitle);
  dlgstruct.HelpMethod = 'sfhelp';
  dlgstruct.HelpArgs = {'TRANSITION_DIALOG'};
  dlgstruct.DisableDialog = ~is_object_editable(h);

  
%-------------------------------------------------------------------------------
% Construct the title of the dialog
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function title = get_trans_title_l(h)
  label = sf('get', h.Id,'.labelString');
  title = ['Transition ' label];
  
%-------------------------------------------------------------------------------
% Construct the source string
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function source = get_source_string_l(h)
  src = sf('get',h.Id,'transition.src.id');
  source = get_srcdst_string_l(src);
  
%-------------------------------------------------------------------------------
% Construct the destination string
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function dest = get_dest_string_l(h)
  dst = sf('get',h.Id,'transition.dst.id');
  dest = get_srcdst_string_l(dst);
  
%-------------------------------------------------------------------------------
% Returns the name of the source or dest object of the transition
% Parameters:
%   h - Handle to the src/dst udi
%-------------------------------------------------------------------------------
function objName = get_srcdst_string_l(id)
 
  if id > 0
    [STATE,JUNCTION] = sf('get','default','state.isa','junction.isa');
    
    switch sf('get',id,'.isa')
     case STATE
      objName = ['(state) ' sf('FullNameOf',id,'.')];
     case JUNCTION
      switch sf('get',id,'.type')
       case 0 % CONNECTIVE
        objName = '(connective junction)';
       case 1 % HISTORY	
        objName = '(history junction)';
       otherwise
        objName = '(junction)';
        warning('Bad junction type.');
      end
     otherwise
      objName = sprintf('(#%d) ',id);
      warning('Bad object type.');
    end
  else
    objName = '~';
  end

%-------------------------------------------------------------------------------
% Construct the parent string
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function parentName = get_parent_string_l(h)
  parent = sf('get',h.Id,'transition.linkNode.parent');
  
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