function varargout = maskedit(varargin)

% Store the Block handles and their corresponding Dialogs


%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2004/04/15 00:46:28 $
persistent DIALOG_USERDATA

% Lock this file now to prevent user tampering
mlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error(nargchk(1, Inf, nargin));

% Determine what the action is
Action = varargin{1};
args   = varargin(2:end);

switch (Action)
 case 'Create'
  BlockHandle   = get_param(args{1}, 'Handle');
  dialog_exists = 0;
  
  % Check if dialog already created
  if ~isempty(DIALOG_USERDATA)
    idx = find([DIALOG_USERDATA.BlockHandle] == BlockHandle);
    if ~isempty(idx)
      PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
      frame = PanelHandle.getParent;
      frame.show;
      dialog_exists = 1;
    end
  end

  % Create mask editor and store it
  if (dialog_exists == 0)
    [BlockHandle PanelHandle] = CreateMaskEditor(args{:});
    DIALOG_USERDATA(end+1).BlockHandle = BlockHandle;
    DIALOG_USERDATA(end).PanelHandle   = PanelHandle;
  end
  
  % Now update dialog
  UpdateMaskEditor(BlockHandle, PanelHandle);
  
 case {'Delete', 'Cancel'}
  BlockHandle = args{1};

  % Check if dialog exists
  if ~isempty(DIALOG_USERDATA)
    idx = find([DIALOG_USERDATA.BlockHandle] == BlockHandle);
    if ~isempty(idx)
      PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
      frame = PanelHandle.getParent;
      frame.dispose;
      DIALOG_USERDATA(idx) = [];
    end
  end
 
 case 'DeleteAll'
  % Delete all existing dialogs
  if ~isempty(DIALOG_USERDATA)
    for i = 1:length(DIALOG_USERDATA)
      PanelHandle = DIALOG_USERDATA(i).PanelHandle;
      frame = PanelHandle.getParent;
      frame.dispose;
    end
    DIALOG_USERDATA = [];
  end
 
 case {'Apply', 'ApplyAndClose'}
  BlockHandle = args{1};
  idx = find([DIALOG_USERDATA.BlockHandle] == BlockHandle);
  PanelHandle = DIALOG_USERDATA(idx).PanelHandle;

  % Apply settings of dialog
  try
    ApplyMaskData(BlockHandle, PanelHandle, args{2});
    if strcmp(Action, 'ApplyAndClose')
        maskedit('Delete', BlockHandle);
    end
  catch
    errordlg(lasterr, 'Error', 'modal');
  end
  
 case 'Help'
   slprophelp('maskeditor')
        
 case 'Unmask'
   BlockHandle = args{1};
   set_param(BlockHandle, 'Mask', 'off');
   maskedit('Delete', BlockHandle);
   
 case 'GetMaskEditor'
  BlockHandle = args{1};
  idx = find([DIALOG_USERDATA.BlockHandle] == BlockHandle);
  if ~isempty(idx)
      PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
  else
      PanelHandle = [];
  end
  varargout{1} = PanelHandle;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H, panel] = CreateMaskEditor(varargin)

block = varargin{1};
name  = strrep(get_param(block, 'Name'),sprintf('\n'), ' ');
H     = get_param(block, 'Handle');
parent= get_param(block, 'Parent'); 

% Call constructor
panel = com.mathworks.toolbox.simulink.maskeditor.MaskEditor.CreateMaskEditor(name);
frame = panel.getParent;

% Set the right location
location       = get_param(H, 'Position');
parentLocation = get_param(parent, 'Location');
screenSize     = get(0,'ScreenSize');

dims   = frame.getBounds;
width  = dims.width; 
height = dims.height;

xLoc = min(parentLocation(1) + location(3) + width, screenSize(3)) - width;
yLoc = min(parentLocation(2) + location(2) + height, screenSize(4)) - height;
frame.setLocation(max(xLoc, 0), max(yLoc, 0));
  
% Store block handle
panel.setBlockHandle(H);
  
% Make it visible
frame.show;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateMaskEditor(H, MaskEditor)

props = {'MaskType', ...
	 'MaskSelfModifiable', ...
	 'MaskDisplay', ...
	 'MaskIconFrame', ...
	 'MaskIconOpaque', ...
	 'MaskIconRotate', ...
	 'MaskDescription', ...
	 'MaskHelp' ...
	};

% Set above properties
for i = 1:length(props)
  eval(['MaskEditor.set' props{i} '(get_param(H,''' props{i} '''))'])
end

% MaskIconUnits are special because they are an enumeration, so need
% to translate the setting
MaskEditor.setMaskIconUnits(xlate(get_param(H, 'MaskIconUnits')));

% These are all the Mask parameters
[variables evaluates initString] = Variables2Cell(H);

prompts      = get_param(H, 'MaskPrompts');
[types,popups]= parseParamTypes(H);
popups = strrep(popups, '|', sprintf('\n'));
tunables     = get_param(H, 'MaskTunableValues');
names        = get_param(H, 'MaskNames');
values       = get_param(H, 'MaskValues');
callbacks    = get_param(H, 'MaskCallbacks');
enables      = get_param(H, 'MaskEnables');
visibilities = get_param(H, 'MaskVisibilities');
aliases      = get_param(H, 'MaskVarAliases');
tabNames     = get_param(H, 'MaskTabNames');

MaskEditor.setMaskInitialization(initString);
MaskEditor.setMaskParameters(prompts, ...
			     variables, ...
			     types, ...
			     popups, ...
			     evaluates, ...
			     tunables, ...
			     names, ...
			     values, ...
			     callbacks, ...
			     enables, ...
			     visibilities, ...
                             aliases, ...
                             tabNames);

% Enable MaskSelfModifiable only for library blocks.
enable = strcmpi(get_param(bdroot(H), 'BlockDiagramType'), 'library');
MaskEditor.getMaskSelfModifiable.setEnabled(enable);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vars, evals, initString] = Variables2Cell(H)

vars       = {};
evals      = {};
initString = get_param(H, 'MaskInitialization');

if (~isempty(get_param(H, 'MaskPrompts')))
  ParseParam = 'MaskVariables';
  if isempty(get_param(H, 'MaskVariables'))
    ParseParam = 'MaskInitialization';
  end
  [vars, evals, allElse] = parseInitCommands(H, ParseParam);
  if isempty(get_param(H, 'MaskVariables'))
    initString = allElse;
  else
    initString = get_param(H, 'MaskInitialization');
  end
end

for i = 1:length(evals)
  if evals{i}
    evals{i} = 'on';
  else
    evals{i} = 'off';
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parseInitCommands : Parses the Initialization commands and returns %%
%%                     two strings, one with the variable assignments %%
%%                     and one with everythign else.                  %%
%%                                                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [VarNames, VarEvals, allElse]  = parseInitCommands(BlockHandle, ...
						  ParseParam)
% parseInitCommands : This function returns
%                     - Variable Names
%                     - Variable Evaluation Types
%                     - The rest of the Initialization String
%                     in cell arrays of length = number of parameters

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Get the Mask Initialization String %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  initstr = deblank(get_param(BlockHandle, ParseParam));
  NParams = length(get_param(BlockHandle, 'MaskPrompts'));
  
  % Initialize the output variables
  VarNames     = {};
  VarEvals     = {};
  if NParams > 0
    VarNames(1:NParams) = {''};
    VarEvals(1:NParams) = {0};
  end
  index        = [];
  
  allElse      = initstr;
  deleteVector = [];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% If String is not Empty, then Proceed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~isempty(initstr)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Find all the @/& Positions (Assignments) %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    locations = sort([find(initstr == '@') find(initstr == '&')]);
    for i = 1:length(locations)
      breakOut = 0;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      %% Two conditions for an Assignment                    %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      %% 1) Preceding the @/& is an equals sign              %% 
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      posB = locations(i) - 1;
      while (~breakOut & (initstr(posB) ~= '=')) 
        if (initstr(posB) ~= ' ')
          breakOut = 1;
        end
        posB = posB - 1;            
      end 
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      %% 2) After @/& is a ; or , with exceptions of numbers %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      posF = locations(i) + 1;
      while (~breakOut & (posF<=length(initstr))& isempty(findstr(';,',initstr(posF))))
        if isempty(findstr(' 0123456789',initstr(posF)))
          breakOut = 1;
        end 
        posF = posF + 1;            
      end 
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Get the Assignment type (@/&) of this one %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      type(i) = (initstr(locations(i)) == '@');
      
      if ~breakOut
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% It is a Valid Assignment %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      newIndex = str2num(initstr((locations(i)+1) : (posF-1))); 
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      %% Only Record First occurrence of an Index %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      if (isempty(index)|(~isempty(index) & (sum(newIndex == index) == 0)))
        index = [index, newIndex];
        VarEvals{newIndex} = type(i);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Find nameStart and nameEnd indices for the assignment %% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nameEnd   = posB - 1;
        nameStart = posB - 1;
        CR        = sprintf('\n');
        while (nameStart >= 1) & isempty(findstr([';,' CR],initstr(nameStart)))
          nameStart = nameStart - 1;
        end
        nameStart   = nameStart + 1;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Set the Variable Name and the AllElse String %% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        VarNames{newIndex} = deblank(initstr(nameStart:nameEnd));
        
        allElse(nameStart:posF) = ' ';
        deleteVector = [deleteVector nameStart:posF];
        
      end
    end
  end  % end of for i... loop
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Remove Extra Spaces from AllElse String %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  allElse(deleteVector) = '';
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Fill the rest if needed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  N = max(index);
  if N > NParams
    warning('The numbers used for assignments exceeds number of parameters')
    VarNames = VarNames(1:NParams);
    VarEvals = VarEvals(1:NParams);
  end
end %% if ~isempty(initstr)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : parseInitCommands %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parseParamTypes : Function which makes a cell array of the       %%
%%                   parameter types, and another with the popup    %%
%%                   strings.                                       %%
%%                                                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [StyleTypes,  PopupStrings]  = parseParamTypes(BlockHandle)

  StyleData    = get_param(BlockHandle, 'MaskStyles');
  Num          = length(StyleData);
  StyleTypes   = {};
  PopupStrings = {};
  
  for i = 1:Num
    style = StyleData{i};
    if strncmp(style, 'popu', 4)
      StyleTypes{i}   = 'popup';
      PopupStrings{i} = style(7:length(style)-1);
    else
      StyleTypes{i}   = style;
      PopupStrings{i} = '';
    end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : parseParamTypes %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ApplyMaskData : Function to save all the entered data into the block
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ApplyMaskData(H, panel, data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get the Initialization Commands String %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maskInitString = char(panel.getMaskInitialization.getText);
if ~isempty(maskInitString) & ~isempty(find(maskInitString == '@'))
  warndlg(['Assignments should be made using the variable name '...
           'associated with the parameter instead of using @N.'], 'warning', 'modal');
end
maskSelfFlag = panel.getMaskSelfModifiable.getState;
maskSelfModifiable = 'off';
if maskSelfFlag
  maskSelfModifiable = 'on';
end

variableString = '';
typeString     = '';
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate proper Assignments for Prompts, Variables, TypeString %% 
%% and Initialization Strings . Also Names and Values             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Columns are : Prompt, Variable, Type,     Popup,  Eval,   Tunable, 
%               Name,   Value,    Callback, Enable, Visible
numParams     = data.getHeight;
  
PromptArray   = cell(numParams,1);
VarArray      = cell(numParams,1);
TypeArray     = cell(numParams,1);
PopupArray    = cell(numParams,1);
EvalArray     = cell(numParams,1);
TunableArray  = cell(numParams,1);
NameArray     = cell(numParams,1);
ValueArray    = cell(numParams,1);
CallbackArray = cell(numParams,1);
EnableArray   = cell(numParams,1);
VisibleArray  = cell(numParams,1);
AliasArray    = cell(numParams,1);
TabNameArray  = cell(numParams,1);

for i = 1:numParams
   PromptArray{i}   = data.getData(i-1, 0);
   VarArray{i}      = data.getData(i-1, 1);
   TypeArray{i}     = data.getData(i-1, 2);
   PopupArray{i}    = data.getData(i-1, 3);
   EvalArray{i}     = data.getData(i-1, 4);
   TunableArray{i}  = data.getData(i-1, 5);
   if TunableArray{i}
     TunableArray{i} = 'on';
   else
     TunableArray{i} = 'off';
   end
   NameArray{i}     = data.getData(i-1, 6);
   ValueArray{i}    = data.getData(i-1, 7);
   CallbackArray{i} = data.getData(i-1, 8);
   EnableArray{i}   = data.getData(i-1, 9);
   if EnableArray{i}
     EnableArray{i} = 'on';
   else
     EnableArray{i} = 'off';
   end
   VisibleArray{i}  = data.getData(i-1, 10);
   if VisibleArray{i}
     VisibleArray{i} = 'on';
   else
     VisibleArray{i} = 'off';
   end
   AliasArray{i} = data.getData(i-1, 11);
   TabNameArray{i} = data.getData(i-1, 12);
end
  
%%%%%%%%%%%%%%%%%%%%%%%%
%% Massage popup data %%
%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:numParams
  val = PopupArray{i};
  if ~isempty(val)
    val = strrep(val, sprintf('\n'), '|');
    val = strrep(val, char(13), '');
    val = strrep(val, '||', '|');
    if strcmp(val(end), '|')
      val(end) = [];
    end
    PopupArray{i} = val;
  end
end        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check to make sure every variable is unique %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UniqueVariableList = '';
for i = 1:numParams
  CV              = deblank(VarArray{i});
  CurrentVariable = fliplr(deblank(fliplr(CV)));
  VarArray{i}     = CurrentVariable;
  if ~isempty(CurrentVariable)
    UniqueVariableList = strvcat(UniqueVariableList, CurrentVariable); 
  end
  
  % Check for alias duplication as well
  CA              = deblank(AliasArray{i});
  CurrentAlias    = fliplr(deblank(fliplr(CA)));
  AliasArray{i}   = CurrentAlias;
  if ~isempty(CurrentAlias)
    UniqueVariableList = strvcat(UniqueVariableList, CurrentAlias); 
  end
end
if size(unique(UniqueVariableList,'rows'),1)~=size(UniqueVariableList,1)
  % Display an error for usage of duplicate names
  beep;errordlg('Duplicate variable or alias names being used','Error','modal');
  errorValue = 1;
  return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop through for all parameters %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:numParams
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Assign the variables (evaluated or literal) %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isempty(VarArray{i})
    warndlg(['Variable field is empty for prompt ''' ...
             PromptArray{i} ''' (parameter ' num2str(i) ')'], 'warning', 'modal');
  else
    if (EvalArray{i} == 1)	% evaluated param
      variableString = [variableString, ...
                        VarArray{i}, '=@', num2str(i), ';'];
    else  % literal param
      variableString = [variableString, VarArray{i},...
                        '=&',num2str(i),';'];
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Generate the Type string %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  typ = char(TypeArray{i}.getCurrentString);
  typeString = [typeString, typ];
  if strcmp(typ, 'popup')
    % Check to make sure that no commas are entered in popup string
    if ~isempty(find(PopupArray{i} == ','))
      beep; errordlg(['Commas are not allowed in the specification of' ...
                      ' popup strings. Use ''|'' to separate choices.'],'Error','modal');
      errorValue = 1;
      return;
    end
    typeString = [typeString,'(',PopupArray{i},')'];
  end
  if (i < numParams)
    typeString = [typeString,','];
  end
end % ... end of the for loop

%%%%%%%%%%%%%%%%%%
%% Set the data %%
%%%%%%%%%%%%%%%%%%
MaskType        = char(panel.getMaskType.getText);
MaskDescription = char(panel.getMaskDescription.getText);
MaskHelp        = char(panel.getMaskHelp.getText);

MaskDisplay    = char(panel.getMaskDisplay.getText);
MaskIconRotate = panel.getMaskIconRotate.getSelectedItem;
if strcmpi(MaskIconRotate, xlate('fixed'))
  MaskIconRotate = 'none';
else
  MaskIconRotate = 'port';
end
MaskIconFrame  = panel.getMaskIconFrame.getSelectedItem;
if strcmpi(MaskIconFrame, xlate('visible'))
  MaskIconFrame = 'on';
else
  MaskIconFrame = 'off';
end
MaskIconOpaque = panel.getMaskIconOpaque.getSelectedItem;
if strcmpi(MaskIconOpaque, xlate('opaque'))
  MaskIconOpaque = 'on';
else
  MaskIconOpaque = 'off';
end
MaskIconUnits  = char (panel.getMaskIconUnits.getSelectedItem);

if strcmpi(MaskIconUnits, xlate('autoscale'))
     MaskIconUnits = 'autoscale';
elseif strcmpi(MaskIconUnits, xlate('pixels'))
     MaskIconUnits = 'pixels';
else 
     MaskIconUnits = 'normalized';
end

set_param(H, ...
          'Mask'              , 'on',...
          'MaskType'          , MaskType,...
          'MaskDisplay'       , MaskDisplay,...
          'MaskIconRotate'    , MaskIconRotate,...
          'MaskIconFrame'     , MaskIconFrame,...
          'MaskIconOpaque'    , MaskIconOpaque,...
          'MaskIconUnits'     , MaskIconUnits,...  
          'MaskDescription'   , MaskDescription,...
          'MaskHelp'          , MaskHelp,...
          'MaskSelfModifiable', maskSelfModifiable,...
          'MaskVariables'     , variableString,...
          'MaskInitialization', maskInitString,...
          'MaskStyleString'   , typeString,...
          'MaskPrompts'       , PromptArray,...
          'MaskValues'        , ValueArray,...
          'MaskTunableValues' , TunableArray,...
          'MaskEnables'       , EnableArray,...
          'MaskVisibilities'  , VisibleArray,...
          'MaskCallbacks'     , CallbackArray,...
          'MaskVarAliases'    , AliasArray,...
          'MaskTabNames'      , TabNameArray);

SetMaskState(H);  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : ApplyMaskData %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SetMaskState : sets the mask property to 'off' if none of the    %%
%%                mask string properties are set.                   %%
%%                                                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetMaskState(handle)

maskParams = get_param(handle, 'ObjectParameters');
nameOfFields = fieldnames( maskParams ) ;
numFields = length( nameOfFields ) ;

for i = 1:numFields                                
  currentField = nameOfFields{i};
  if (length(currentField) >= 4) & ...
     strcmp(currentField(1:4), 'Mask') & ... 
     strcmp(getfield( maskParams, currentField, 'Type' ), 'string')
    str = get_param(handle, currentField);
    if ~isempty(str)
      return;
    end
  end
end
set_param(handle, 'Mask', 'off');
