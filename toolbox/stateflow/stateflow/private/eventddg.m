function dlgstruct = eventddg(h, name)
  % See if this dialog is already open 

% Copyright 2002-2003 The MathWorks, Inc.

    t = DAStudio.ToolRoot;
    openD = t.getOpenDialogs;
    thisDialog = [];
    thisDialogTag = create_unique_dialog_tag_l(h);
     
    for i=1:size(openD)
      tag = openD(i).dialogTag;
      if strcmp(tag, thisDialogTag)
        % We have a match
        thisDialog = openD(i);
        break;
      end
    end

  % Name field
  txtName.Name           = 'Name:';
  txtName.Type           = 'edit';
  txtName.RowSpan        = [1 1];
  txtName.ColSpan        = [1 3];
  txtName.ObjectProperty = 'Name'; 
  txtName.Tag            = strcat('sfEventdlg_', txtName.Name);
  
  % Parent label
  lblParent.Name    = 'Parent:';   
  lblParent.Type    = 'text';  
  lblParent.RowSpan = [2 2];
  lblParent.ColSpan = [1 1];
  lblParent.Tag     = strcat('sfEventdlg_', lblParent.Name);
  
  % Parent hyperlink
  hypParent.Name    = ddg_get_parent_name(h.getParent);
  hypParent.Type    = 'hyperlink';
  hypParent.Tag     = 'hypParentTag';
  hypParent.RowSpan = [2 2];
  hypParent.ColSpan = [2 2];
  hypParent.MatlabMethod = 'sf';
  hypParent.MatlabArgs = {'Private', 'dlg_goto_parent', h.Id};
  
  % Scope combobox
  cmbScope.Name           = 'Scope:';
  cmbScope.Type           = 'combobox';
  cmbScope.RowSpan        = [3 3];
  cmbScope.ColSpan        = [1 1];
  cmbScope.ObjectProperty = 'Scope';
  cmbScope.Mode           = 1;       %0 = batch, 1 = immediate refresh
  cmbScope.DialogRefresh  = 1;       %0 = no refresh, 1 = refresh
  
  % Show appropriate entries depending on the event's parent
  scp = scope_of(h.Id);
  cmbScope.Entries = scp.string;
  cmbScope.Values = scp.values;
  cmbScope.Tag    = strcat('sfEventdlg_', cmbScope.Name);
  
  %------------------------------------------------------------------  
  % Port combobox
  %------------------------------------------------------------------  
  cmbPort.Name           = 'Port:';
  cmbPort.Type           = 'combobox';
  cmbPort.RowSpan        = [3 3];
  cmbPort.ColSpan        = [2 2];
  
  cmbPort.ObjectProperty = 'Port';
  allowedValStr = h.getPropAllowedValues('Port');
  allowedValNum = NaN;
  for i=1:length(allowedValStr)
      allowedValNum(i) = str2num(allowedValStr{i});
  end
  cmbPort.Entries = allowedValStr';
  cmbPort.Values  = allowedValNum;
              
  %------------------------------------------------------------------  
  % Trigger combobox
  %------------------------------------------------------------------  
  cmbTrigger.Name           = 'Trigger:';
  cmbTrigger.Type           = 'combobox';
  cmbTrigger.RowSpan        = [3 3];
  cmbTrigger.ColSpan        = [3 3];
  cmbTrigger.ObjectProperty = 'Trigger';
  cmbTrigger.Tag            = strcat('sfEventdlg_', cmbTrigger.Name);
 
  %-------------------------------------
  % Refresh logic for the combobox
  %-------------------------------------
  switch h.Scope
    case 'Local'
      cmbTrigger.Enabled = 0;     
      cmbTrigger.Entries = {'Either', 'Rising', 'Falling', 'Function call'};       
    case 'Input'    
      cmbTrigger.Enabled = 1;     
      cmbTrigger.Entries = {'Either', 'Rising', 'Falling', 'Function call'};       
    case 'Output'
      cmbTrigger.Enabled = 1;     
      cmbTrigger.Entries = {'Either Edge', 'Function call'}; 
      cmbTrigger.Values  = [0, 3];  
    otherwise                                                   
	  cmbTrigger.Enabled = 0;     
	  cmbTrigger.Entries = {'Either', 'Rising', 'Falling', 'Function call'};         
  end

  
  %------------------------------------------------------------------  
  % Breakpoints
  %------------------------------------------------------------------  
  lblDBP.Name    = 'Debugger breakpoints:';
  lblDBP.Type    = 'text';
  lblDBP.RowSpan = [1 1];
  lblDBP.ColSpan = [1 1];
  lblDBP.Tag     = strcat('sfEventdlg_', lblDBP.Name);
  
  chkSBC.Name    = 'Start of Broadcast';
  chkSBC.Type    = 'checkbox';
  chkSBC.RowSpan = [1 1];
  chkSBC.ColSpan = [2 2];
  chkSBC.ObjectProperty = 'StartBroadcast';
  chkSBC.Tag            =  strcat('sfEventdlg_', chkSBC.Name);
  
  chkEBC.Name           = 'End of Broadcast';
  chkEBC.Type           = 'checkbox';
  chkEBC.RowSpan        = [1 1];
  chkEBC.ColSpan        = [3 3];
  chkEBC.ObjectProperty = 'EndBroadcast';
  chkEBC.Tag            = strcat('sfEventdlg_', chkEBC.Name);
  
  pnlBreak.Type         = 'panel';
  pnlBreak.LayoutGrid   = [1 3];
  pnlBreak.ColStretch   = [0 0 1];
  pnlBreak.RowSpan      = [4 4];
  pnlBreak.ColSpan      = [1 3];
  pnlBreak.Source       = h.Debug.Breakpoints;
  pnlBreak.Items        = {lblDBP, chkSBC, chkEBC};
  pnlBreak.Tag          = 'sfEventdlg_pnlBreak';
  
  %------------------------------------------------------------------  
  % Description editarea
  %------------------------------------------------------------------  
  desc.Name           = 'Description';
  desc.Type           = 'editarea';
  desc.RowSpan        = [5 5];
  desc.ColSpan        = [1 3];
  desc.ObjectProperty = 'Description';
  desc.Tag            = strcat('sfEventdlg_', desc.Name);
  
  %------------------------------------------------------------------  
  %Document hyperlink
  %------------------------------------------------------------------  
  doclinkName.Name = 'Document Link:';
  doclinkName.Tag = 'doclinkNameTag';
  doclinkName.RowSpan = [1 1];
  doclinkName.ColSpan = [1 1];
  doclinkName.Type = 'hyperlink';
  doclinkName.MatlabMethod = 'sf';
  doclinkName.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};
  
  %------------------------------------------------------------------    
  %Document link edit area
  %------------------------------------------------------------------  
  doclinkEdit.Name = '';
  doclinkEdit.RowSpan = [1 1];
  doclinkEdit.ColSpan = [2 2];
  doclinkEdit.Type = 'edit';
  doclinkEdit.ObjectProperty = 'Document';
  doclinkEdit.Tag = 'sfEventdlg_doclinkEdit';
  
  pnlDoc.Type = 'panel';
  pnlDoc.LayoutGrid = [1 2];
  pnlDoc.RowSpan = [6 6];
  pnlDoc.ColSpan = [1 3];
  pnlDoc.ColStretch = [0 1];
  pnlDoc.Items = {doclinkName, doclinkEdit};
  %------------------------------------------------------------------  
  % main panel
  %------------------------------------------------------------------  
  pnlMain.Type       = 'panel';
  pnlMain.LayoutGrid = [6 3];
  pnlMain.RowStretch = [0 0 0 0 1 0];
  pnlMain.ColStretch = [0 0 1];
  pnlMain.Items      = {txtName, ...
                        lblParent, hypParent, ...
                        cmbScope};
  if (h.isValidProperty('Port'))
      pnlMain.Items = [pnlMain.Items, {cmbPort}];
  end
  pnlMain.Items = [pnlMain.Items, {...
                                   cmbTrigger,...
                                   pnlBreak, ...                         %lblDBP, chkSBC, chkEBC, ...
                                   desc, ...
                        pnlDoc}];
  pnlMain.Tag        = 'sfEventdlg_pnlMain';
   
  %------------------------------------------------------------------
  % Main dialog
  %------------------------------------------------------------------
   % if the developer feature is on append the id to the title
  if sf('Feature','Developer')
    id = strcat('#', sf_scalar2str(h.Id));
    dlgstruct.DialogTitle = ['Event ' h.Name];
    dlgstruct.DialogTitle = strcat(dlgstruct.DialogTitle, id);
  else
    dlgstruct.DialogTitle = ['Event ' h.Name];
  end
  dlgstruct.SmartApply = 0;
  dlgstruct.Items = {pnlMain};
  dlgstruct.DialogTag = create_unique_dialog_tag_l(h);
  dlgstruct.CloseCallback = 'sf';
  dlgstruct.CloseArgs = {'Private', 'eventddg_preclose_callback', '%dialog'};
  dlgstruct.PreApplyCallback = 'sf';
  dlgstruct.PreApplyArgs     = {'Private', 'eventddg_preapply_callback', '%dialog'};
  dlgstruct.HelpMethod = 'sfhelp';
  dlgstruct.HelpArgs = {'EVENT_DIALOG'};
  dlgstruct.DisableDialog = ~is_object_editable(h);

  %------------------------------------------------------------------
  % find the io event
  %------------------------------------------------------------------
  function [ios, index] = io_events_of(eventId)
  
  chart = sf('get',eventId,'.linkNode.parent');
  scope = sf('get',eventId,'event.scope');
  
  switch scope
  case 1 % INPUT
    ios = sf('find',sf('EventsOf',chart),'event.scope',scope);
    index = [1:size(ios,2)];
  case 2 % OUTPUT
    dios = sf('find',sf('DataOf',chart),'data.scope',scope);
    ios = sf('find',sf('EventsOf',chart),'event.scope',scope);
    index = size(dios,2) + [1:size(ios,2)];
  otherwise
    error('Bad scope');
end

  %------------------------------------------------------------------
  % generate unique tag for the dialog
  %------------------------------------------------------------------
  function unique_tag = create_unique_dialog_tag_l(h)
    unique_tag = ['_DDG_Event_Dialog_Tag_', sf_scalar2str(h.Id)];
	
  %------------------------------------------------------------------
  % Event trigger and port is only needed in the context of input/output
  % event
  %------------------------------------------------------------------
  function result = is_io_event(eventId)
 
  scope = sf('get',eventId,'event.scope');
  if isempty(scope)
    warning('Bad eventId');
    result = 0;
  elseif any(scope == [1,2])
    result = 1;
  else
    result = 0;
  end


  %------------------------------------------------------------------
  % Determine the Entries and Values array of the scope combobox
  %------------------------------------------------------------------
function scope = scope_of( eventId )
%
% Obtains the scope of an event
%
parent = sf('get',eventId,'.linkNode.parent');

if ~sf('ishandle',parent)
  scope.string = '';
  scope.values = [];
  warning('Event has an invalid parent.');
  return;
end

[MACHINE, CHART, STATE] = sf('get','default','machine.isa', 'chart.isa', 'state.isa');
switch sf('get',parent,'.isa')
  case MACHINE
    scope.string = {'Local','Exported','Imported'};
    scope.values = [0,4,3];
  case CHART
    scope.string = {'Local','Input from Simulink','Output to Simulink'};
    scope.values = [0,1,2];
  case STATE
    scope.string = {'Local'};
    scope.values = [0];
  otherwise
    scope.string = '';
    scope.values = [];
    scope.value = 0;
    warning('Parent of event has an invalid class.');
    return;
end
