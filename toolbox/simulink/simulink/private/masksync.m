function Data = masksync(action, H, BlockHandle, position)
%MASKSYNC syncs data for the three different pages of the Mask Editor.
%   MASKSYNC synchronizes the data for the three pages (Icon, Parameter,
%   Documentation) of the Mask Editor.  MASKSYNC also parses the Initialization
%   commands and Parameter types.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.16 $
%   Sanjai Singh  09-17-96


switch (action)

  case 'UIGeom'
    Data = UIGeom(position);
    
  case 'SyncDocPage'
    Data = SyncDocPage(H, BlockHandle);

  case 'SyncIconPage'
    Data = SyncIconPage(H, BlockHandle);

  case 'SyncParamPage'
    Data = SyncParamPage(H, BlockHandle);

  otherwise
    error(['Unknown action for the Mask Sync : ' action]);

end  % ... switch (action)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of main function : masksync %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  UIGeom : Data for the Geometry of UIControls for the Mask Editor    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UIData = UIGeom(position)

  isPC  = strncmp(computer,'PC',2);
  isMAC = strncmp(computer,'MA',2);
  
  UIData.Width     = position(3) + position(1);
  UIData.Height    = position(4) + position(2);;

  UIData.ListboxFontname = 'Courier';
  UIData.ListboxFontsize = 9;
  UIData.PopupColor      = get(0,'defaultuicontrolbackgroundcolor');
  if isPC
    UIData.PopupColor      = [1 1 1];
    UIData.ListboxFontname = 'Courier New';
  end
  if isMAC
    UIData.ListboxFontsize = 10;
  end

  lang = lower(get(0,'language'));
  if strncmp(lang, 'ja', 2)
    UIData.ListboxFontname = 'FixedWidth';
    UIData.ListboxFontsize = get(0,'factoryuicontrolfontsize');
  end

  UIData.EditSize   = 20;
  UIData.PopupSize  = 25 - isPC * 5;

  %
  % Data for use of the Parmater Page only
  %
  UIData.TypePopupOffset   = UIData.Height - 187;
  UIData.EvalPopupOffset   = UIData.Height - 212;
  if isPC
    UIData.TypePopupOffset = UIData.Height - 182;
    UIData.EvalPopupOffset = UIData.Height - 208;
  end

  %
  % Data for the Icon Page only
  %
  UIData.RadioHeight  = 20;
  UIData.FrameOffset  = UIData.Height - 233 + isPC * 5;
  UIData.OpaqueOffset = UIData.Height - 263 + isPC * 5;
  UIData.RotateOffset = UIData.Height - 293 + isPC * 5;
  UIData.CoordsOffset = UIData.Height - 323 + isPC * 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : UIGeom %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SyncDocPage : Syncs the Doc Page of the Mask Editor          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SyncData = SyncDocPage(H, BlockHandle)

  SyncData.DescriptionString = get_param(BlockHandle, 'MaskDescription');
  SyncData.HelpString        = get_param(BlockHandle, 'MaskHelp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : SyncDocPage %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SyncIconPage : Syncs the Icon Page of the Mask Editor          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SyncData = SyncIconPage(H, BlockHandle)

  FrameV = 1;
  if strcmp(get_param(BlockHandle, 'MaskIconFrame'), 'on')
    FrameV = 2;
  end

  OpaqueV = 1;
  if strcmp(get_param(BlockHandle, 'MaskIconOpaque'), 'on')
    OpaqueV = 2; 
  end

  RotateV = 1;
  if strcmp(get_param(BlockHandle, 'MaskIconRotate'), 'port')
    RotateV = 2;
  end

  NormalV = 2;    % default to autoscale
  if strcmp(get_param(BlockHandle, 'MaskIconUnits'), 'pixels')
    NormalV = 1;
  elseif strcmp(get_param(BlockHandle, 'MaskIconUnits'), 'normalized')
    NormalV = 3;
  end
  
  SyncData.TypeString    = get_param(BlockHandle, 'MaskType');
  SyncData.DisplayString = get_param(BlockHandle, 'MaskDisplay');
  SyncData.RotateValue   = RotateV;
  SyncData.OpaqueValue   = OpaqueV;
  SyncData.FrameValue    = FrameV;
  SyncData.NormalValue   = NormalV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : SyncIconPage %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SyncParamPage : Syncs the Param Page of the Mask Editor          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SyncData = SyncParamPage(H, BlockHandle)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Initialize the ListBox Parameter Data and Strings %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  PromptData        = get_param(BlockHandle, 'MaskPrompts'); 
  ValueData         = get_param(BlockHandle, 'MaskValues'); 
  NameData          = get_param(BlockHandle, 'MaskNames'); 
  TunableData       = get_param(BlockHandle, 'MaskTunableValues'); 
  EnableData        = get_param(BlockHandle, 'MaskEnables'); 
  VisibleData       = get_param(BlockHandle, 'MaskVisibilities');
  CallbackData      = get_param(BlockHandle, 'MaskCallbacks');
  nParams           = length(PromptData);
  Data              = get(H, 'UserData');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Store the Extra Mask Values %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ExtraValueData = {};
  if length(ValueData) > nParams
    ExtraValueData = ValueData((nParams+1):length(ValueData));
  end
  Data.ParamPage.ExtraValueData = ExtraValueData;
  set(H, 'UserData', Data)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  %% If there are Parameters, we got work to do %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (nParams > 0)
    ParseParam = 'MaskVariables';
    if isempty(get_param(BlockHandle, 'MaskVariables'))
      ParseParam = 'MaskInitialization';
    end
    [VarNames, VarEvals, allElse] = parseInitCommands(BlockHandle, ParseParam);
    if isempty(get_param(BlockHandle, 'MaskVariables'))
      initString = allElse;
    else
      initString = get_param(BlockHandle, 'MaskInitialization');
    end
      
    [StyleTypes, PopupStrings] = parseParamTypes(BlockHandle);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Setup the Parameter Data %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:nParams
      paramData(i).prompt   = PromptData{i};
      paramData(i).variable = VarNames{i};
      paramData(i).type     = StyleTypes{i};
      paramData(i).popupStr = PopupStrings{i};
      paramData(i).evalType = VarEvals{i};
      paramData(i).value    = ValueData{i};
      paramData(i).name     = NameData{i};
      paramData(i).tunable  = TunableData{i};
      paramData(i).enable   = EnableData{i};
      paramData(i).visible  = VisibleData{i};
      paramData(i).callback = CallbackData{i};
    end  %% for end

  end  % if end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Set the Parameter terminating string for the ListBox %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  paramData(nParams+1).prompt    = '<<end of parameter list>>';
  paramData(nParams+1).variable  = '';
  paramData(nParams+1).type      = '  ';
  paramData(nParams+1).popupStr  = '';
  paramData(nParams+1).evalType  = 0;
  paramData(nParams+1).value     = '';
  paramData(nParams+1).name      = '';
  paramData(nParams+1).tunable   = 'foo';
  paramData(nParams+1).enable    = 'foo';
  paramData(nParams+1).visible   = 'foo';
  paramData(nParams+1).callback  = 'disp sanjai';

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Place the Data into the ListBox %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (nParams > 0)        
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get all the Strings %%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    typeString     = setstr(32*ones(nParams,9)); 
    paramString    = setstr(32*ones(nParams,26));
    variableString = setstr(32*ones(nParams,12));
    padding        = setstr(32*ones(nParams,2));
      
    tempParam      = '';
    tempType       = strvcat(paramData(1:nParams).type);
    tempVar        = '';
    evalString     = '';

    for i = 1:nParams
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Check for Empty Prompt Name %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if isempty(paramData(i).prompt)
        tempParam = strvcat(tempParam, ' ');
      else        
        tempParam = strvcat(tempParam, paramData(i).prompt);
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Check for Empty Variable Name %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if isempty(paramData(i).variable)
        tempVar = strvcat(tempVar, ' ');
      else        
        tempVar = strvcat(tempVar, paramData(i).variable);
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Create evalString Variable  %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      marker = ' ';
      if (paramData(i).evalType == 1)
        marker = '*';
      end
      evalString = strvcat(evalString, marker);        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Trim the Strings if needed %% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tempParam                     = tempParam(:,1:min(26,end));
    tempVar                       = tempVar(:,1:min(12,end));
    paramString(find(tempParam))  = tempParam(find(tempParam));
    typeString(find(tempType))    = tempType(find(tempType));
    variableString(find(tempVar)) = tempVar(find(tempVar));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create Final String to enter in the ListBox %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    paramString = [paramString padding evalString typeString variableString];
    paramString = strvcat(paramString, paramData(nParams+1).prompt);
    promptStr   = paramData(1).prompt; 
  else 
    paramString    =  paramData(1).prompt;
    variableString = '';
    StyleTypes     = {};
    PopupStrings   = {};
    evalString     = '';
    promptStr      = '';
    initString     = get_param(BlockHandle, 'MaskInitialization');
  end  %% End of if (nParam>0)
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% The Initial Enable States of the UIControls %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  SyncData.EnableDeleteButton = 'on';
  SyncData.EnableUpButton     = 'off';
  SyncData.EnableDownButton   = 'on';

  if nParams==0
    SyncData.EnableDeleteButton = 'off';
    SyncData.EnableDownButton   = 'off';
  end

  if nParams==1
    SyncData.EnableDownButton = 'off';
  end

  SyncData.EnablePromptText   = 'on';
  SyncData.EnablePromptEdit   = 'on';

  SyncData.EnableVariableText = 'on';
  SyncData.EnableVariableEdit = 'on';

  SyncData.EnableControlText     = 'on';
  SyncData.EnableControlPopup    = 'on';

  SyncData.EnableAssgnText    = 'on';
  SyncData.EnableAssgnPopup   = 'on';

  IValue = 1;
  if (length(StyleTypes) > 0)
    if (strcmp(StyleTypes{1}(1:4),'chec'))
      IValue = 2;
    elseif (strcmp(StyleTypes{1}(1:4),'popu'))
      IValue = 3;
    end
  end
  SyncData.Value = IValue;
  
  SyncData.EnablePopupString = 'off'; 
  if nParams & strcmp(StyleTypes{1},'popup')
    SyncData.EnablePopupString = 'on';
  end 

  % Store the other relevant Information %
  SyncData.ParamData       = paramData;
  SyncData.PromptString    = promptStr;
  SyncData.ParamString     = paramString;
  SyncData.EvalString      = evalString;
  SyncData.VariableString  = variableString;
  SyncData.Styles          = StyleTypes;
  SyncData.PopupStrings    = PopupStrings;
  SyncData.InitString      = initString;
  SyncData.FirstVariable    = paramData(1).variable;
  SyncData.FirstEvalType    = paramData(1).evalType + 1;
  SyncData.FirstPopupString = paramData(1).popupStr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : SyncParamPage %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parseInitCommands : Parses the Initialization commands and returns %%
%%                     two strings, one with the variable assignments %%
%%                     and one with everythign else.                  %%
%%                                                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [VarNames, VarEvals, allElse]  = parseInitCommands(BlockHandle, ParseParam)
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
      type(i) = (initstr(locations(i)) == '&');
      
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


