function dlgstruct = dataddg(h, name)

% Copyright 2002-2004 The MathWorks, Inc.

% See if this dialog is already open 
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

  % Data name
  nameEditLabel.Type = 'text';
  nameEditLabel.Name = 'Name:';
  nameEditLabel.RowSpan = [1 1];
  nameEditLabel.ColSpan = [1 1];
  
  nameEdit.Type = 'edit';
  nameEdit.RowSpan = [1 1];
  nameEdit.ColSpan = [2 4];
  nameEdit.Type = 'edit';
  nameEdit.ObjectProperty = 'name';
  nameEdit.Tag = 'sfDatadlg_Name';
  
  parentLbl.Type = 'text';
  parentLbl.Name = 'Parent:';
  parentLbl.RowSpan = [2 2];
  parentLbl.ColSpan = [1 1];
  
   %parent hyper
  parentHyper.Name = get_parent_name_l(h);
  parentHyper.RowSpan = [2 2];
  parentHyper.ColSpan = [2 4];
  parentHyper.Type = 'hyperlink';
  parentHyper.Tag = 'parentHyperTag';
  parentHyper.MatlabMethod = 'sf';
  parentHyper.MatlabArgs = {'Private', 'dlg_goto_parent', h.Id};
  
  scopePullDownLbl.Type = 'text';
  scopePullDownLbl.Name = 'Scope:';
  scopePullDownLbl.RowSpan = [3 3];
  scopePullDownLbl.ColSpan = [1 1];
   
  %scope pull down menu
  scopePullDown.RowSpan = [3 3];
  scopePullDown.ColSpan = [2 2];
  scopePullDown.Mode = 1;
  scopePullDown.DialogRefresh = 1;
  scopePullDown.Type = 'combobox';
  scopePullDown.Entries = h.getPropAllowedValues('Scope')';
  scopePullDown.Values = get_values_for_scope_enums_l(scopePullDown.Entries);
  scopePullDown.ObjectProperty = 'Scope';
  scopePullDown.Tag = 'sfDatadlg_Scope';
  
   
  portPullDownLbl.Type = 'text';
  portPullDownLbl.Name = 'Port:';
  portPullDownLbl.RowSpan = [3 3];
  portPullDownLbl.ColSpan = [3 3];
  
  %port pull down menu
  portPullDown.RowSpan = [3 3];
  portPullDown.ColSpan = [4 4];
  portPullDown.Type = 'combobox';

% Reinstate when visibility refresh for combo box is fixed
   if(h.isValidProperty('Port'))
%      portPullDownLbl.Visible = true;
%      portPullDown.Visible = true;
      portPullDown.ObjectProperty = 'Port';
   else
%      portPullDownLbl.Visible = false;
%      portPullDown.Visible = false;
   end
      
  allowedValStr = h.getPropAllowedValues('Port');
  allowedValNum = NaN;
  for i=1:length(allowedValStr)
      allowedValNum(i) = str2num(allowedValStr{i});
  end
  portPullDown.Entries = allowedValStr';
  portPullDown.Values  = allowedValNum;
  
  typePullDownLbl.Type = 'text';
  typePullDownLbl.RowSpan = [4 4]; 
  typePullDownLbl.ColSpan = [1 1];
  typePullDownLbl.Name = 'Type:';
  
  %Type pull down menu
  typePullDown.RowSpan = [4 4];
  typePullDown.ColSpan = [2 2];
  typePullDown.Type = 'combobox';
  typePullDown.Editable = 1;
  typePullDown.Entries = h.getPropAllowedValues('DataType')';
  typePullDown.Values = get_values_for_type_enums_l(typePullDown.Entries);
  typePullDown.ObjectProperty = 'DataType';
  typePullDown.Mode = 1;
  typePullDown.DialogRefresh = 1;
  typePullDown.Tag = 'sfDatadlg_Type';
  
  unitsLbl.Type = 'text';
  unitsLbl.Name = 'Units:';
  unitsLbl.RowSpan = [4 4];
  unitsLbl.ColSpan = [3 3];
  
  %Units pull down menu
  units.RowSpan = [4 4];
  units.ColSpan = [4 4];
  units.Type = 'edit';
  units.ObjectProperty = 'Units';
  units.Tag = 'sfDatadlg_Units';
  
  %Complex checkbox
  isComplex.Name = 'Complex';
  isComplex.ObjectProperty = 'IsComplex';
  isComplex.RowSpan = [5 5];
  isComplex.ColSpan = [1 2];
  isComplex.Type = 'checkbox';
  isComplex.Enabled = 1;
  isComplex.Tag = 'isComplex_tag';
  isComplex.DialogRefresh = 1;
  
  %Testpoint checkbox
  isTestPoint.Name = 'Test Point';
  isTestPoint.Mode = 1;
  isTestPoint.ObjectProperty = 'IsTestPoint';
  isTestPoint.RowSpan = [5 5];
  isTestPoint.ColSpan = [3 4];
  isTestPoint.Type = 'checkbox';
  if h.isValidProperty('IsTestPoint')
  isTestPoint.Enabled = 1;
  else
      isTestPoint.Enabled = 0;
  end
  isTestPoint.Tag = 'isTestPoint_tag';
  isTestPoint.DialogRefresh = 1;
  
  panel1.Type = 'panel';
  panel1.LayoutGrid = [5 4];
  panel1.RowSpan = [1 1];
  panel1.ColSpan = [1 1];
  panel1.ColStretch = [0 1 0 1];
  
  panel1.Items = {nameEditLabel,    nameEdit ...
                  parentLbl,        parentHyper... 
                  scopePullDownLbl, scopePullDown};
  if(h.isValidProperty('Port'))
      panel1.Items = [panel1.Items, {portPullDownLbl , portPullDown}];
  end
  if(data_belongs_to_eml_block(h.Id))
      panel1.Items = [panel1.Items, {...
                      typePullDownLbl , typePullDown...
                      unitsLbl        , units,...
                      isComplex}];
  else
      panel1.Items = [panel1.Items, {...
                      typePullDownLbl , typePullDown...
                      unitsLbl        , units}];
  end
  
      % Figure out scaling information
      if isempty(thisDialog)
          [scaling_pop_val, scaling_edit_val] = get_scaling_info_from_sf(h.Id);
          fractionCombo.Value = scaling_pop_val-1;
          fractionEdit.Value = scaling_edit_val;
      end

      %Store Integer Pull Down
      store.Name = 'Store integer:';
      store.RowSpan = [1 1];
      store.ColSpan = [1 1];
      store.Type = 'combobox';
      store.Mode = 1;
      store.Entries = {'int32', 'int16', 'int8', 'uint32', 'uint16', 'uint8'};
      store.Values = [8 6 4 7 5 3];
      store.ObjectProperty = 'BaseType';
      if (strcmp(h.DataType,'fixpt') == 1)
          store.Enabled = 1;
      else
          store.Enabled = 0;
      end
      store.Tag = 'sfDatadlg_Store Integer';

      %Fraction Length Combo Box
      fractionCombo.Name = '';
      fractionCombo.RowSpan = [1 1];
      fractionCombo.ColSpan = [2 2];
      fractionCombo.Type = 'combobox';
      fractionCombo.Entries = {'Fraction length', 'Scaling'};
      if (strcmp(h.DataType, 'fixpt') == 1)
          fractionCombo.Enabled = 1;
      else
          fractionCombo.Enabled = 0;
      end
      fractionCombo.Tag = 'scaling_popup_tag';
      fractionCombo.DialogRefresh = 1;

      %Fraction Edit
      fractionEdit.Name = '';
      fractionEdit.Tag = 'scaling_edit_tag';
      fractionEdit.RowSpan = [1 1];
      fractionEdit.ColSpan = [3 3];
      fractionEdit.Type = 'edit';
      fractionEdit.DialogRefresh = 1;
      fractionEdit.ForegroundColor = [1 1 1];
      if (strcmp(h.DataType, 'fixpt') == 1)
          fractionEdit.Enabled = 1;
      else
          fractionEdit.Enabled = 0;
      end

      % If the dialog is already up, then we are in here after a dialog refresh
      % Check scaling popup and edit values to provide immediate feedback to the user
      % Note that this does not set values in the data dictionary. This is done
      % using the pre-apply callback.
      if ~isempty(thisDialog)
          currentSelection = thisDialog.getWidgetValue('scaling_popup_tag');
          scalingEdit = thisDialog.getWidgetValue('scaling_edit_tag');
          fractionCombo.Value = currentSelection;

          [slope,exponent,bias,err] = string_to_scaling(scalingEdit, currentSelection+1);
          if err
              fractionEdit.ForegroundColor = [255 1 1];
              fractionEdit.Value = scalingEdit;
          else
              fractionEdit.Value = scaling_to_string(slope,exponent,bias,currentSelection+1);
          end
      end

      % Finally, set the tooltip to show the appropriate thing based on the scaling
      % popup
      if (fractionCombo.Value == 0)
          fractionEdit.ToolTip = [ 'e.g. ''3'' means there are 3 bits right of the binary point.\n' ...
              'This is equivalent to scaling with slope 2^ -3 and bias 0.' ];
      else
          fractionEdit.ToolTip = 'Slope, e.g. 2^-9 or [Slope  Bias],e.g. [1.25  3]';
      end

      %Complex checkbox
      lock.Name = 'Lock output scaling against changes by the autoscaling tool';
      lock.ObjectProperty = 'Lock';
      lock.RowSpan = [2 2];
      lock.ColSpan = [1 3];
      lock.Type = 'checkbox';
      lock.Enabled = 1;
      lock.Tag = 'isLock_tag';
      lock.DialogRefresh = 1;

  %Assume that complex is not enabled unless 
  %you figure out otherwise from the object itself
  isComplex.Value = 0;
  if h.IsComplex
    isComplex.Value = 1;
  end
  %If the dialog itself is open turn the 
  %array check box on if the tag says so
  if ~isempty(thisDialog)
    currentSelection = thisDialog.getWidgetValue('isComplex_tag');
    if (currentSelection == 1)
       isComplex.Value  = 1;
    end
  end;
  
  
  %Sizes Edit Area
  sizesEdit.Name = 'Size:';
  sizesEdit.RowSpan = [1 1];
  sizesEdit.ColSpan = [1 1];
  sizesEdit.ObjectProperty = 'Size';
  sizesEdit.Type = 'edit';
  if strcmp(h.DataType, 'ml') == 1
    sizesEdit.Enabled = 0;
  else
    sizesEdit.Enabled = 1;
  end 
  sizesEdit.Tag = 'sfDatadlg_Array Size';
  
  %First Index Edit Area
  firstIndex.Name = 'First index:';
  firstIndex.RowSpan = [1 1];
  firstIndex.ColSpan = [2 2];
  firstIndex.Type = 'edit';
  firstIndex.ObjectProperty = 'FirstIndex';
  if (strcmp(h.DataType, 'ml') == 1 | ~isempty(regexp(h.Props.Array.Size, '^\s*([?)\s*(?(1)1|1?)\s*(?(1)])\s*$')))
    firstIndex.Enabled = 0;
  else
    firstIndex.Enabled = 1;
  end 
  firstIndex.Tag = 'sfDatadlg_First Index';
  
  %Cases that min/max field doesn't apply
  minMaxDoesntApply = strcmp(h.DataType, 'ml') == 1    || ...
                      strcmp(h.Scope, 'Constant') == 1 || ...
                      strcmp(h.Scope, 'Parameter') == 1;
                   
  %Min Edit Area
  minEdit.Name = 'Minimum:';
  minEdit.RowSpan = [1 1];
  minEdit.ColSpan = [1 1];
  minEdit.Type = 'edit';
  minEdit.ObjectProperty = 'Minimum';
  if minMaxDoesntApply
    minEdit.Enabled = 0;
  else
    minEdit.Enabled = 1;
  end 
  minEdit.Tag = 'sfDatadlg_Minimum';
  
  %Max Edit Area
  maxEdit.Name = 'Maximum:';
  maxEdit.RowSpan = [1 1];
  maxEdit.ColSpan = [2 2];
  maxEdit.Type = 'edit';
  maxEdit.ObjectProperty = 'Maximum';
  if minMaxDoesntApply
    maxEdit.Enabled = 0;
  else
    maxEdit.Enabled = 1;
  end 
  maxEdit.Tag = 'sfDatadlg_Maximum';
  
  %Data Dictionary Combo Box
  dataDictInit.Name = 'Initialize from:';
  dataDictInit.RowSpan = [1 1];
  dataDictInit.ColSpan = [1 1];
  dataDictInit.Type = 'combobox';
  dataDictInit.Mode = 1;
  dataDictInit.DialogRefresh = 1;
  dataDictInit.ObjectProperty = 'DdgInitFromWorkspace';
  %dataDictInit.Enabled = 1;
  switch h.Scope
      case 'Input'
          dataDictInit.Entries = {'Data dictionary', 'Workspace'};
          dataDictInit.Enabled = 0;
      case 'Output'
          dataDictInit.Entries = {'Data dictionary', 'Workspace'};
          if data_belongs_to_eml_block(h.Id)
              dataDictInit.Enabled = 0;
          else
              dataDictInit.Enabled = 1;
          end
      case 'Constant'
          dataDictInit.Entries = {'Data dictionary'};
          dataDictInit.Enabled = 1;
      case 'Parameter'
          dataDictInit.Entries = {'Workspace'};
          dataDictInit.Enabled = 1;
      otherwise
          dataDictInit.Entries = {'Data dictionary', 'Workspace'};
          dataDictInit.Enabled = 1;
  end
  dataDictInit.Tag = 'sfDatadlg_Initialize From';
       
  %Data Dictionary Edit Area
  dataDictEdit.Name = '';
  dataDictEdit.RowSpan = [1 1];
  dataDictEdit.ColSpan = [2 2];
  dataDictEdit.Type = 'edit';
  dataDictEdit.DialogRefresh = 1;
  dataDictEdit.Source = h.Props;
  dataDictEdit.ObjectProperty = 'InitialValue';
  if (dataDictInit.Enabled == 0 || h.InitFromWorkspace == 1)
    dataDictEdit.Enabled = 0;
  else
    dataDictEdit.Enabled = 1;
  end
  dataDictEdit.Tag = 'sfDataddg_dataDictEdit';
  
  %SavetoWorkspace
  saveWorkspace.Name = 'Save final value to base workspace';
  saveWorkspace.RowSpan = [2 2];
  saveWorkspace.ColSpan = [1 1];
  saveWorkspace.Type = 'checkbox';
  saveWorkspace.ObjectProperty = 'SaveToWorkspace';
  saveWorkspace.Tag = 'sfDatadlg_Save final value to base workspace';
  if strcmp(h.Scope, 'Constant') || strcmp(h.Scope, 'Parameter')
      saveWorkspace.Enabled = 0;
  else
      saveWorkspace.Enabled = 1;
  end
  
  %WatchInDebugger
  watchInDebugger.Name = 'Watch in Debugger';
  watchInDebugger.Source = h.Debug;
  watchInDebugger.RowSpan = [3 3];
  watchInDebugger.ColSpan = [1 1];
  watchInDebugger.Type = 'checkbox';
  watchInDebugger.ObjectProperty = 'Watch';
  watchInDebugger.Tag = 'sfDatadlg_Watch in Debugger';
 
  % description widget
  description.Name = 'Description:';
  description.Type = 'editarea';
  description.RowSpan = [1 1];
  description.ColSpan = [1 2];
  description.ObjectProperty = 'Description';
  description.Tag = 'sfDatadlg_Description';
   
  %Document hyperlink
  document.Name = 'Document Link:';
  document.RowSpan = [2 2];
  document.ColSpan = [1 1];
  document.Type = 'hyperlink';
  document.MatlabMethod = 'sf';
  document.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};
  
   %Document edit area
  document1.Name = '';
  document1.RowSpan = [2 2];
  document1.ColSpan = [2 2];
  document1.Type = 'edit';
  document1.ObjectProperty = 'Document';
  document1.Tag = 'sfDataddg_document1';
  
  fixptgroupbox.Name = 'Fixed-Point';
  fixptgroupbox.Type = 'group';
  fixptgroupbox.Source = h.FixptType;
  fixptgroupbox.LayoutGrid = [2 3];
  fixptgroupbox.ColStretch = [0 0 1];
  fixptgroupbox.RowSpan = [2 2];
  fixptgroupbox.ColSpan = [1 1];
  fixptgroupbox.Items = {store, fractionCombo, fractionEdit, lock};
  fixptgroupbox.Tag = 'sfDatadlg_Fixed-Point';

  arraypanel.Name = '';
  arraypanel.Type = 'panel';
  arraypanel.LayoutGrid = [1 2];
  arraypanel.Source = h.Props.Array;
  arraypanel.Items = {sizesEdit, firstIndex};
  arraypanel.Tag = 'sfDataddg_arraypanel'; 
  
  arraytogglepanel.Name = 'Data Size (Scalar)';
  arraySize = h.Props.Array.Size;
  if (~isempty(arraySize) & ~isempty(str2num(arraySize)))
    dim = str2num(arraySize);
    if length(dim) == 1 & dim > 1
        arraytogglepanel.Name = strcat('Data Size (1x', sprintf('%0.5g', dim), ' Array)');
    elseif (length(dim) > 1) 
        arraytogglepanel.Name = strcat('Data Size (', strrep(sprintf('%0.5g', dim),'  ','x'),...
                                       'Array)');
    end  
  end  
  %arraytogglepanel.Type = 'togglepanel';
  arraytogglepanel.Type = 'panel';
  arraytogglepanel.RowSpan = [3 3];
  arraytogglepanel.ColSpan = [1 1];
  arraytogglepanel.Items = {arraypanel};
  arraytogglepanel.Tag = 'sfDataddg_arraytogglepanel';
  
  limitgroupbox.Name = 'Limit range';
  limitgroupbox.Type = 'group';
  limitgroupbox.Source = h.Props.Range;
  limitgroupbox.LayoutGrid = [1 2];
  limitgroupbox.RowSpan = [2 2];
  limitgroupbox.ColSpan = [1 1];
  limitgroupbox.Items = {minEdit, maxEdit};
  limitgroupbox.Tag = 'sfDatadlg_Limit Range';
  
  spacera.Type = 'panel';
  spacera.RowSpan = [4 4];
  spacera.ColSpan = [1 2];

  tab1.Name = 'General';
  tab1.LayoutGrid = [4 1];
  tab1.RowStretch = [0 0 0 1];
      tab1.Items = {panel1, fixptgroupbox, arraytogglepanel, spacera };
  
  spacerb.Type = 'panel';
  spacerb.RowSpan = [4 4];
  spacerb.ColSpan = [1 1];
  
  panelA.Type = 'panel';
  panelA.RowSpan = [1 1];
  panelA.ColSpan = [1 1];
  panelA.LayoutGrid = [2 2];
  panelA.ColStretch = [0 1];
  panelA.RowStretch = [0 1];
  panelA.Items = {dataDictInit, dataDictEdit, saveWorkspace};

  tab2.Name = 'Value Attributes';
  tab2.LayoutGrid = [4 1];
  tab2.RowStretch = [0 0 0 1];
  tab2.Items = {panelA, limitgroupbox, watchInDebugger, spacerb};
  
  tab3.Name = 'Description';
  tab3.LayoutGrid = [2 2];
  tab3.ColStretch = [0 1];
  tab3.RowStretch = [1 0];
  tab3.Items = {description, document, document1};
  
  tabcont.Type = 'tab';
  tabcont.Tabs = {tab1, tab2, tab3};
  
  %%%%%%%%%%%%%%%%%%%%%%%
  % Main dialog
  %%%%%%%%%%%%%%%%%%%%%%%
 
  % if the developer feature is on append the id to the title
  if sf('Feature','Developer')
     id = sprintf('%0.5g', h.Id);
     dlgstruct.DialogTitle = strcat('Data#',id);
  else
     dlgstruct.DialogTitle = ['Data ', h.name];
  end
  dlgstruct.SmartApply = 0;
  dlgstruct.DialogTag = create_unique_dialog_tag_l(h);
  dlgstruct.CloseCallback = 'sf';
  dlgstruct.CloseArgs = {'Private', 'dataddg_preclose_callback', '%dialog'};
  dlgstruct.PreApplyCallback = 'sf';
  dlgstruct.PreApplyArgs     = {'Private', 'dataddg_preapply_callback', '%dialog'};
  dlgstruct.Items =  {tabcont};
  dlgstruct.HelpMethod = 'sfhelp';
  dlgstruct.HelpArgs = {'DATA_DIALOG'};
  dlgstruct.DisableDialog = ~is_object_editable(h);
  
  
%----------------------------------------------------------------------------------------
function [popup_val, edit_val] = get_scaling_info_from_sf(dataId)
  
% set strings from data dictionary
  [baseType, slope, exponent, bias] = sf('get',dataId...
                                         ,'data.fixptType.baseType'...
                                         ,'data.fixptType.slope'...
                                         ,'data.fixptType.exponent'...
                                         ,'data.fixptType.bias'...
                                         );
  if slope ~= 1.0 | bias ~= 0.0
    % scaling requires slope/bias display
    scalingMode = 2;
  else
    % scaling does not require slope/bias display, so get mode from dd
    scalingMode = sf('get',dataId,'data.dlgFixptMode');
    % protect against 0 (default dd value); be robust to out-of-range values
    if(scalingMode ~= 1 & scalingMode ~= 2)
        scalingMode = 1;
    end
  end
  
  % scaling popup and edit
  popup_val = scalingMode;
  edit_val = scaling_to_string(slope,exponent,bias,scalingMode);

  
%------------------------------------------------------------------------------------
function isEml = parent_is_eml(h)

isEml = is_eml_chart(h.Id);
   
%------------------------------------------------------------------------------------
  function parentName = get_parent_name_l(h)

  parent = sf('get',h.Id,'.linkNode.parent');
    [MACHINE,CHART,STATE] = sf('get','default','machine.isa','chart.isa','state.isa');
  switch sf('get',parent,'.isa')
   case MACHINE
    parentName = '(machine) ';
   case CHART
    if is_eml_chart(parent) 
      parentName = '';
    else
      parentName = '(chart) ';
    end
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
  
%----------------------------------------------------------------------------------------
function unique_tag = create_unique_dialog_tag_l(h)
  
  unique_tag = sprintf('%s%0.5g','_DDG_Data_Dialog_Tag_', h.Id);
  
%----------------------------------------------------------------------------------------
function [result,scope] = is_io_data(dataId)
%
% Data trigger and port is only needed in the context of input/output datas
%
scope = sf('get',dataId,'data.scope');
if isempty(scope)
  warning('Bad dataId');
  result = 0;
elseif any(scope == [1,2,8,9])
  result = 1;
else
  result = 0;
end

%----------------------------------------------------------------------------------------
function ios = io_data_of(chart,scope)
switch scope
  case {1,2,8,9}
    ios = sf('find',sf('DataOf',chart),'data.scope',scope);
  otherwise
    error('Bad scope');
end

%----------------------------------------------------------------------------------------
function [slope,exponent,bias,err] = string_to_scaling(string,mode)

% mode == 1   interpret as fraction length
% mode == 2   interpret as slope or [slope bias]
% otherwise error

%set up default values
slope = 1.0;
exponent = 0;
bias = 0.0;

err = 0;
try
    scaling = evalin('base',[ '[' string ']' ]);
catch
    err = 1;
    return;
end

if isempty(scaling)
    % blank string => use default values
    return;
end

% otherwise must be a finite real matrix of length 1 or 2
if ~isreal(scaling) | any(isnan(scaling)) | any(isinf(scaling))
    err = 1;
    return;
end

switch mode
    case 1
        % fraction length must be a single integer
        if length(scaling) > 1 | fix(scaling) ~= scaling
            err = 1;
            return;
        end
        exponent = -scaling;
    case 2
        % slope   or   [slope  bias]
        if length(scaling) > 2
            err = 1;
            return;
        end
        % slope must be positive
        if scaling(1) <= 0.0
            err = 1;
            return;
        end
        [slope, exponent] = log2(scaling(1));
        % log2 is almost right - produces 0.5 <= slope < 1
        % we need 1.0 <= slope < 2
        slope = slope * 2;
        exponent = exponent - 1;
        if length(scaling) > 1
            bias = scaling(2);
        end
    otherwise
        error('bogus case');
end

%----------------------------------------------------------------------------------------
function string = scaling_to_string(slope,exponent,bias,scalingMode)

% construct scaling string from fixpt parameters
  switch scalingMode
   case 1
    if slope ~= 1.0 | bias ~= 0.0 | fix(exponent) ~= exponent
      error('bogus mode');
    end
    string = sprintf('%d', -exponent);
   case 2
       string = safe_num2str(slope * (2^exponent));
       if bias
           string =  sprintf('[ %s  %s ]', string, safe_num2str(bias));
       end
   otherwise
    error('bogus mode');
  end  

function str = safe_num2str(num)
    % Doubles have 16.5 bits of precision.  
    % 16 is right most of the time and crufty none of the time.
    % 17 is right all of the time, and crufty some of the time.
    % It is easy to determine if you have the wrong answer.
    % It is difficult to determine if you have a crufty answer.
    % This _inefficient_ routine, starts with a potentially wrong ansewer, then checks
    % its accuracy.  If 16 produces the wrong answer, then 17 will not produce cruft, as
    % the reason 16 is wrong is that 17 is needed.  That's the theory, at least. -=>J
    str = sprintf('%.16g', num);
    num2 = eval(str);
    if num2 ~= num
        str = sprintf('%.17g', num);
    end


function vals = get_values_for_scope_enums_l(enumVals)  
  vals = zeros(1, length(enumVals));
  for i=1:length(enumVals)
    thisEnum = enumVals{i};
    switch thisEnum
     case 'Local'
      vals(i) = 0;
     case 'Input'
      vals(i) = 1;
     case 'Output'
      vals(i) = 2;
     case 'WORKSPACE_DATA'
      vals(i) = 3;
     case 'Imported'
      vals(i) = 4;
     case 'Exported'
      vals(i) = 5;
     case 'Temporary'
      vals(i) = 6;
     case 'Constant'
      vals(i) = 7;
     case 'Function input'
      vals(i) = 8;
     case 'Function output'
      vals(i) = 9;
     case 'Parameter'
      vals(i) = 10;
    end
  end


function vals = get_values_for_type_enums_l(enumVals)  
  vals = zeros(1, length(enumVals));
  for i=1:length(enumVals)
    thisEnum = enumVals{i};
    switch thisEnum
     case 'boolean'
      vals(i) = 1;
     case 'state'
      vals(i) = 2;
     case 'uint8'
      vals(i) = 3;
     case 'int8'
      vals(i) = 4;
     case 'uint16'
      vals(i) = 5;
     case 'int16'
      vals(i) = 6;
     case 'uint32'
      vals(i) = 7;
     case 'int32'
      vals(i) = 8;
     case 'single'
      vals(i) = 9;
     case 'double'
      vals(i) = 10;
     case 'fixpt'
      vals(i) = 11;
     case 'ml'
      vals(i) = 12;
    end
  end

function belongsToEml = data_belongs_to_eml_block(dataId)
    parent = sf('get',dataId,'data.linkNode.parent');
    if(~isempty(sf('get',parent,'chart.id')) &&...
            is_eml_chart(parent))
        belongsToEml = true;
    else
        belongsToEml = false;
    end
