function dlgstruct = chartddg(h, name)

% Copyright 2002-2004 The MathWorks, Inc.

  % We ignore name here
  isEml = isa(h, 'Stateflow.EMChart');
  editable = is_object_editable(h);
  
  %Chart Name
  nameLabel.Name = 'Name:';
  nameLabel.RowSpan = [1 1];
  nameLabel.ColSpan = [1 1];
  nameLabel.Type = 'text';
  nameLabel.Tag = strcat('sfChartdlg_', nameLabel.Name);
  
  chartName.Name = get_chart_name_l(h);
  chartName.RowSpan = [1 1];
  chartName.ColSpan = [2 2];
  chartName.Type = 'hyperlink';
  chartName.MatlabMethod = 'sf';
  chartName.Tag = 'chartHyperNameTag';
  chartName.MatlabArgs = {'Private', 'dlg_goto_object', h.Id};
  
  % Simulnk Subsystem widget
  simulinkSubsys.Name = 'Parent:';
  simulinkSubsys.RowSpan = [2 2];
  simulinkSubsys.ColSpan = [1 1];
  simulinkSubsys.Type = 'text';
  simulinkSubsys.Tag = strcat('sfChartdlg_', simulinkSubsys.Name);
  
  simulinkSubsysHyper.Name = get_subsystem_name_l(h);
  simulinkSubsysHyper.RowSpan = [2 2];
  simulinkSubsysHyper.ColSpan = [2 2];
  simulinkSubsysHyper.Type = 'hyperlink';
  simulinkSubsysHyper.Tag = 'simulinkSubsysHyperTag';
  simulinkSubsysHyper.MatlabMethod = 'open_system';
  simulinkSubsysHyper.MatlabArgs = {get_subsystem_handle_l(h)};
  
  % parent widget
  parent.Name = 'Machine:';
  parent.RowSpan = [3 3];
  parent.ColSpan = [1 1];
  parent.Type = 'text';
  parent.Tag = strcat('sfChartdlg_', parent.Name);
  
  %parent hyper
  parentHyper.Name = get_parent_name_l(h);
  parentHyper.RowSpan = [3 3];
  parentHyper.ColSpan = [2 2];
  parentHyper.Type = 'hyperlink';
  parentHyper.MatlabMethod = 'sf';
  parentHyper.Tag = 'parentHyperTag';
  parentHyper.MatlabArgs = {'Private', 'dlg_goto_parent', h.Id};
    
  hyperPanel.Type = 'panel';
  hyperPanel.RowSpan = [1 1];
  hyperPanel.ColStretch = [1 3];
  hyperPanel.LayoutGrid = [3 2];
  hyperPanel.ColStretch = [0 1];
  hyperPanel.Items = {nameLabel, chartName, simulinkSubsys, simulinkSubsysHyper,...
                        parent, parentHyper}; 
  
  %update checkbox widget
  update_popup.Name = 'Update method:';
  update_popup.Type = 'combobox';
  update_popup.RowSpan = [2 2];
  update_popup.ColSpan = [1 1];
  update_popup.ObjectProperty = 'ChartUpdate';
  update_popup.Mode = 1;
  update_popup.DialogRefresh = 1;
  update_popup.Entries = {'Inherited', 'Discrete', 'Continuous'};
  update_popup.Tag = strcat('sfChartdlg_', update_popup.Name);
  update_popup.Enabled = editable;
  
  if (~isEml)
    % Sample time
    updateMethod = sf('get',h.Id,'.updateMethod');	
    sample.Name = 'Sample Time:';
    sample.Type = 'edit';
    sample.RowSpan = [2 2];
    sample.ColSpan = [2 3];
    sample.ObjectProperty = 'SampleTime';
    if updateMethod == 0
      sample.Enabled = 0;
      sample.InitialValue = '-1';
    elseif updateMethod == 2
      sample.Enabled = 0;
      sample.InitialValue = '';
    else
      sample.Enabled = editable;
    end
    sample.Tag = strcat('sfChartdlg_', sample.Name);
    
    
    %Enable check box
    enable.Name = 'Enable C-bit operations';
    enable.Type = 'checkbox';
    enable.ObjectProperty = 'EnableBitOps';
    enable.Mode = 1;
    enable.RowSpan = [1 1];
    enable.ColSpan = [1 1];
    enable.Tag = strcat('sfChartdlg_', enable.Name) ;
    enable.Enabled = editable;

    %Apply to chart checkbox
    apply.Name = 'Apply to all charts in machine now';
    apply.Type = 'pushbutton';
    apply.MatlabMethod = 'sf';
    apply.MatlabArgs = {'Private', 'dlg_apply_bitops_to_all_charts', h.Id};
    apply.Tag = strcat('sfChartdlg_', apply.Name);
    apply.RowSpan = [1 1];
    apply.ColSpan = [2 2];
    apply.Enabled = editable;

    actLang = sf('get',h.Id,'chart.actionLanguage');
    if actLang < 0
      enable.Enabled = 0;
      apply.Enabled = 0;
    end

    % Group to hold enable and apply widgets
    mygroupbox.Name = '';
    mygroupbox.Type = 'group';
    mygroupbox.RowSpan = [3 3];
    mygroupbox.ColSpan = [1 3];
    mygroupbox.LayoutGrid = [1 2];
    mygroupbox.ColStretch = [0 1];
    mygroupbox.Items = {enable, apply};
    mygroupbox.Tag = 'sfChartdlg_group';

    %noCode check box
    noCode.Name = 'No Code Generation for Custom Target';
    noCode.RowSpan = [4 4];
    noCode.ColSpan = [1 1];
    noCode.Type = 'checkbox';
    noCode.ObjectProperty = 'NoCodegenForCustomTargets';
    noCode.Tag = strcat('sfChartdlg_', noCode.Name) ;
    noCode.Enabled = editable;

    %exportChart check box
    exportChart.Name = 'Export Chart Level Graphical Functions (Make Global)';
    exportChart.RowSpan = [5 5];
    exportChart.ColSpan = [1 1];
    exportChart.Type = 'checkbox';
    exportChart.ObjectProperty = 'ExportChartFunctions';
    exportChart.Tag = strcat('sfChartdlg_', exportChart.Name);
    exportChart.Enabled = editable;

    %Strong Data check box
    strong.Name = 'Use Strong Data Typing with Simulink I/O';
    strong.RowSpan = [6 6];
    strong.ColSpan = [1 1];
    strong.Type = 'checkbox';
    strong.ObjectProperty = 'StrongDataTypingWithSimulink';
    strong.Tag = strcat('sfChartdlg_', strong.Name);
    strong.Enabled = editable;

    %execute check box
    execute.Name = 'Execute (enter) Chart At Initialization';
    execute.RowSpan = [7 7];
    execute.ColSpan = [1 1];
    execute.Type = 'checkbox';
    execute.ObjectProperty = 'ExecuteAtInitialization';
    execute.Tag = strcat('sfChartdlg_', execute.Name);
    execute.Enabled = editable;

    % Debugger widget
    debuggerLabel.Name = 'Debugger breakpoint:';
    debuggerLabel.Type = 'text';
    debuggerLabel.RowSpan = [1 1];
    debuggerLabel.ColSpan = [1 1];
    debuggerLabel.Tag = strcat('sfChartdlg_', debuggerLabel.Name);

    % Debugger Checkbox
    debuggerCheck.Name = 'On chart entry';
    debuggerCheck.Type = 'checkbox';
    debuggerCheck.RowSpan = [1 1];
    debuggerCheck.ColSpan = [2 2];
    debuggerCheck.ObjectProperty = 'OnEntry';
    debuggerCheck.Tag = strcat('sfChartdlg_', debuggerCheck.Name);
    debuggerCheck.Enabled = editable;

    % pnlEntry panel
    pnlEntry.Type       = 'panel';
    pnlEntry.Source    = h.Debug.breakpoints;
    pnlEntry.RowSpan = [8 8];
    pnlEntry.ColSpan = [1 2];
    pnlEntry.LayoutGrid = [1 2];
    pnlEntry.ColStretch = [0 1];
    pnlEntry.Items      = {debuggerLabel, debuggerCheck};
    pnlEntry.Tag = 'sfChartdlg_panel';

  end
    % Editor checkbox
  editorLabel.Name = 'Editor:';
  editorLabel.Type = 'text';
  editorLabel.RowSpan = [1 1]; 
  editorLabel.ColSpan = [1 1];
  editorLabel.Tag = strcat('sfChartdlg_', editorLabel.Name);
  
  % Editor checkbox
  editorCheck.Name = 'Locked';
  editorCheck.Type = 'checkbox';
  editorCheck.RowSpan = [1 1];
  editorCheck.ColSpan = [2 2]; 
  editorCheck.ObjectProperty = 'Locked';
  editorCheck.Tag = strcat('sfChartdlg_', editorCheck.Name);
  
  pnlDebuggerAndEdit.Type = 'panel';
  pnlDebuggerAndEdit.LayoutGrid = [1 2];
  pnlDebuggerAndEdit.Items = {editorLabel, editorCheck};
  pnlDebuggerAndEdit.ColStretch = [0 1];
  pnlDebuggerAndEdit.RowSpan = [8 8];
  if (~isEml) 
      pnlDebuggerAndEdit.ColSpan = [3 3];
  else
      pnlDebuggerAndEdit.ColSpan = [1 2];
  end
  
  % description widget
  description.Name = 'Description:';
  description.Type = 'editarea';
  description.RowSpan = [9 9];
  description.ColSpan = [1 3];
  description.ObjectProperty = 'Description';
  description.Tag = strcat('sfChartdlg_', description.Name);
  description.Enabled = editable;
  
  %Document hyperlink
  document.Name = 'Document Link:';
  document.RowSpan = [1 1];
  document.ColSpan = [1 1];
  document.Type = 'hyperlink';
  document.MatlabMethod = 'sf';
  document.Tag = 'documentHyperTag';
  document.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};
  
   %Document edit area
  document1.Name = '';
  document1.RowSpan = [1 1];
  document1.ColSpan = [2 2];
  document1.Type = 'edit';
  document1.ObjectProperty = 'Document';
  document1.Tag = 'sfChartdlg_document';
  document1.Enabled = editable;
  
  pnlDoc.Type = 'panel';
  pnlDoc.LayoutGrid = [1 2];
  pnlDoc.RowSpan = [10 10];
  pnlDoc.ColSpan = [1 3];
  pnlDoc.ColStretch = [0 1];
  pnlDoc.Items = {document, document1};
  
  %%%%%%%%%%%%%%%%%%%%%%%
  % Main dialog
  %%%%%%%%%%%%%%%%%%%%%%%
  title = get_chart_title_l(h);
  % if the developer feature is on append the id to the title
  if sf('Feature','Developer')
    id_str = strcat('#',sf_scalar2str(h.Id));
    dlgstruct.DialogTitle = strcat(title,id_str);
  else
    dlgstruct.DialogTitle = title;
  end
  dlgstruct.LayoutGrid = [10 3];
  dlgstruct.ColStretch = [0 0 1];
  dlgstruct.RowStretch = [0 0 0 0 0 0 0 0 1 0];
  
  dlgstruct.CloseCallback = 'sf';
  dlgstruct.CloseArgs = {'SetDynamicDialog', h.Id, []};
  dlgstruct.DialogTag = strcat('sfChartdlg_', get_chart_title_l(h));
  if (~isEml)
    dlgstruct.Items = {hyperPanel, update_popup, sample, mygroupbox, ...
                       noCode, exportChart, strong, execute, pnlEntry, ...
                       pnlDebuggerAndEdit, description, pnlDoc};
  else
    dlgstruct.Items = {hyperPanel, update_popup,...
                       pnlDebuggerAndEdit, ...
                       description, pnlDoc};
  end
  dlgstruct.HelpMethod = 'sfhelp';
  dlgstruct.HelpArgs = {'CHART_DIALOG'};
  
%-------------------------------------------------------------------------------
% Construct the title of the dialog
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function title = get_chart_title_l(h)
  if is_eml_chart(h.Id)
    title = 'Embedded MATLAB Function';
  else
    chartName = sf('get',h.Id,'.name'); 
    title = ['Chart ' chartName];
  end
  
%-------------------------------------------------------------------------------
% Construct the hyperlink string for the chart name
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function name = get_chart_name_l(h)
  
  chartName = sf('get',h.Id,'.name');
  if is_eml_chart(h.Id)
    name = chartName;
  else 
    name = ['Chart ' chartName];
  end
  name(regexp(name,'\s'))=' ';
  
%-------------------------------------------------------------------------------
% Construct the hyperlink string for the chart's parent name
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function parentName = get_parent_name_l(h)

  parent = sf('get',h.Id,'.machine');
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
% Construct the hyperlink string for the subsystem name
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function ssName = get_subsystem_name_l(h)
  
  if isempty(sf('get',h.Id,'chart.isa'))
    ssName = sprintf('(#%d) ', h.Id);
    warning('Bad chart type.');
  end
  
  [machine,instances] = sf('get',h.Id,'.machine','.instances');
  if isempty(instances)
    warning('No instances of this char.');
    return;
  end
  
  instanceId = instances(1);
  ssName = [sf('get',machine,'.name')];
  ssName(regexp(ssName,'\s'))=' ';
  
%-------------------------------------------------------------------------------
% Return the handle to the simulink subsystem
% Parameters:
%   h - Handle to the state udi
%-------------------------------------------------------------------------------
function ssHandle = get_subsystem_handle_l(h)
  
  instances = sf('get',h.Id,'.instances');
  if isempty(instances)
    warning('No instances of this char.');
    return;
  end
  
  instanceId = instances(1);
  [blockH,machineId] = sf('get',instanceId,'.simulinkBlock','.machine');
  ssHandle = get_param(blockH,'Parent');
  
  