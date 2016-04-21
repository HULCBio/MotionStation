function mskeddlg(varargin)
% MSKEDDLG creates and manages the Mask Editor Dialog  
%
%   MSKEDDLG handles the callbacks for all controls in the mask editor dialog 
%   box.  Also creates pages two and three of the dialog box when the pages 
%   are changed for the first time

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.77.2.2 $
%   Sanjai Singh 05-01-96

button = varargin{1};
switch (button)
	
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Create - Creates the Mask Editor the first time %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'create',
    BlockHandle = varargin{2};
    
    % Call java mask editor
    if slfeature('JavaMaskEditor') && usejava('MWT')
      maskedit('Create', BlockHandle);
    else
      eval('CreateEditor(BlockHandle);','DisplayError(lasterr)');
    end
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% deleteEditor - Deletes the Mask Editor %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'deleteEditor'
    eval('DeleteEditor;','DisplayError(lasterr)');
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% CloseEditor - called from c-code %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'CloseEditor',
    BlockHandle = varargin{2};

    % Call java mask editor
    if slfeature('JavaMaskEditor') && usejava('MWT')
      maskedit('Delete', BlockHandle);
    else
      if ishandle(varargin{3})
        close(varargin{3})
        set_param(varargin{2}, 'MaskEditorHandle', -1);
      end
    end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Apply - The apply button has been pressed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Apply',
    eval('ApplyMaskData;','DisplayError(lasterr)');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Cancel - The cancel button has been pressed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Cancel',
    CancelMaskEditor;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Help - The help button has been pressed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Help',
    slprophelp('maskeditor')

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Close - The close button has been pressed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Close',
    errorValue = 1;
    MaskEditorHandle = gcbf;
    eval('errorValue = ApplyMaskData;','DisplayError(lasterr)');
    if ~errorValue
      set(MaskEditorHandle,'visible','off');
    end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Unmask - The unmask button has been pressed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Unmask',
    UnmaskBlock;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% tabcallbk - Change between pages on the main dialog %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'tabcallbk',
    NewPageName = varargin{2};
    ChangeMaskPage(NewPageName);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% listbox - Change list boxes %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Listbox',
    action = varargin{2}; 
    ChangeListBox(action);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Unknown button - error out %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  otherwise,
    error(['Unknown button action : ' button]);

end  %%%% end of switch (button) %%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : mskeddlg.m %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DeleteEditor : Function to delete the Mask Editor
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DeleteEditor

  Data   = get(gcbf,'UserData');
  exists = 1;

  eval(['exists = ~isempty(find_system('...
        'get_param(Data.BlockHandle,''parent''),' ...
        '''LookUnderMasks'',''all'',''Handle'', Data.BlockHandle));'], ...
        'exists = 0;')

  if exists
    set_param(Data.BlockHandle, 'maskeditorhandle', -1);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : DeleteEditor %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UnmaskBlock : Function called when its time to Unmask the Block
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UnmaskBlock

  Data = get(gcbf,'UserData');
  set_param(Data.BlockHandle, 'mask', 'off');
  set(gcbf, 'visible', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : UnmaskBlock %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ApplyMaskData : Function to save all the entered data into the block
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorValue = ApplyMaskData

  MaskEditorHandle = gcbf;
  Data = get(MaskEditorHandle,'UserData');
  errorValue = 0;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Reset the Block Name in case it changed %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  BlockName = [get_param(Data.BlockHandle,'parent') '/' ...
               get_param(Data.BlockHandle,'name')];   
  set(MaskEditorHandle,'name',['Mask Editor: ' BlockName])

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Do the First Page (Icon Page) %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  value  = get(Data.IconPage.MaskDrawingCoordsHandle, 'value');
  Coords = get(Data.IconPage.MaskDrawingCoordsHandle, 'string');

  IconRotateValue = RotateVal(get(Data.IconPage.MaskRotateIconHandle,'value'));
  IconOpaqueValue = onoff(get(Data.IconPage.MaskOpaqueIconHandle,'value')-1);
  IconFrameValue  = onoff(get(Data.IconPage.MaskFrameIconHandle,'value')-1);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Create the Display String carefully %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  DispString      = get(Data.IconPage.MaskDisplayHandle,'string');
  FinalDispString = '';
  for DispIdx = 1:length(DispString)
    FinalDispString = [FinalDispString DispString{DispIdx} sprintf('\n')];
  end
  if ~isempty(FinalDispString)
    FinalDispString(end) = [];
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% If User hasn't left the first page, don't look for %%
  %% other Handles as they have not been created.       %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ~Data.AllPages
    set_param(Data.BlockHandle, ...
	'Mask'          , 'on',...
	'MaskType'      , get(Data.IconPage.MaskTypeHandle, 'string'),...
	'MaskDisplay'   , FinalDispString,...
	'MaskIconRotate', IconRotateValue,...
	'MaskIconFrame' , IconFrameValue,...
	'MaskIconOpaque', IconOpaqueValue,...
	'MaskIconUnits' , Coords(value,:) );   

  else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %% Do the Parameter Page (Initialization) %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Get the UserData from the ListBox %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      paramData         = get(Data.ParamPage.ParamListBox, 'UserData');
      [nParams, unused] = size(get(Data.ParamPage.ParamListBox, 'string')); 
      nParams           = nParams - 1; % exclude <<end of parameter string>>

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Get the Initialization Commands String %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      maskInitString = get(Data.ParamPage.MaskInitCommandsHandle, 'string');

      if ~isempty(maskInitString) && ~isempty(find(maskInitString == '@'))
	defwarn = warning('backtrace', 'off');
	  warning(['Assignments should be made using the Variable name '...
		'associated with the parameter Prompts instead of using @N.']);
	  warning(defwarn)
	end
      variableString = '';
      typeString     = '';
 
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Generate proper Assignments for Prompts, Variables, TypeString %% 
      %% and Initialization Strings . Also Names and Values             %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if nParams==0
        promptArray   = {};
        ValueArray    = {};
        NameArray     = {};
	TunableArray  = {};
	EnableArray   = {};
	VisibleArray  = {};
	CallbackArray = {};
      else
	%% TRANSPOSE them to have columns
        promptArray = {paramData(1:nParams).prompt}';
        ValueArray  = {paramData(1:nParams).value}';
        NameArray   = {paramData(1:nParams).name}';
	TunableArray= {paramData(1:nParams).tunable}';
	EnableArray   = {paramData(1:nParams).enable}';
	VisibleArray  = {paramData(1:nParams).visible}';
	CallbackArray = {paramData(1:nParams).callback}';
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Check to make sure every variable is unique %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      UniqueVariableList = '';
      for i = 1:nParams
	CV              = deblank(paramData(i).variable);
	CurrentVariable = fliplr(deblank(fliplr(CV)));
        paramData(i).variable = CurrentVariable;
	if ~isempty(CurrentVariable)
	  UniqueVariableList = strvcat(UniqueVariableList, CurrentVariable); 
	end
      end
      if size(unique(UniqueVariableList,'rows'),1)~=size(UniqueVariableList,1)
	% Display an error for usage of duplicate names
	MaskDialogEditor = get(0,'CurrentFigure');
	errorString = 'Duplicate variable names being used';
	beep;errordlg(errorString,'Error','modal');
	set(0,'CurrentFigure', MaskDialogEditor);
	errorValue = 1;
	return;
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Loop through for all parameters %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for i = 1:nParams
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Assign the variables (evaluated or literal) %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isempty(deblank(paramData(i).variable))
	  defwarn = warning('backtrace', 'off');
	    warning(['Variable field in Mask Editor is empty for Prompt ''' ...
		  paramData(i).prompt ''' (parameter ' num2str(i) ')']);
	    warning(defwarn)
        else
          evalType = paramData(i).evalType;
          if (evalType == 0)	% evaluated param
            variableString = [variableString, ...
                       deblank(paramData(i).variable), '=@',num2str(i),';'];
          else  % literal param
            variableString = [variableString, paramData(i).variable,...
                            '=&',num2str(i),';'];
          end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Generate the Type string %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        typ = paramData(i).type;
        typeString = [typeString, typ];
        if strcmp(typ, 'popup')
	  % Check to make sure that no commas are entered in popup string
	  if ~isempty(find(paramData(i).popupStr == ','))
	    beep; errordlg(['Commas are not allowed in the specification of' ...
			    ' popup strings. Use ''|'' to separate choices.'],'Error','modal');
	    errorValue = 1;
	    return;
	  end
          typeString = [typeString,'(',paramData(i).popupStr,')'];
        end
        if (i < nParams)
          typeString = [typeString,','];
        end

    end % ... end of the for loop

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create the Initialization String carefully %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [InitM InitN]   = size(maskInitString);
    FinalInitString = '';
    for idx = 1:InitM
      FinalInitString = [FinalInitString ...
                         deblank(maskInitString(idx,:)) sprintf('\n')];
    end
    if ~isempty(FinalInitString)
      FinalInitString(end) = [];
    end
		 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create the Description String carefully %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DescString      = get(Data.DocPage.MaskDescriptionHandle,'string');
    FinalDescString = '';
    for DescIdx = 1:length(DescString)
      FinalDescString = [FinalDescString DescString{DescIdx} sprintf('\n')];
    end
    if ~isempty(FinalDescString)
      FinalDescString(end) = [];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create the Help String carefully %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    HelpString      = get(Data.DocPage.MaskHelpHandle,'string');
    FinalHelpString = '';
    for HelpIdx = 1:length(HelpString)
      FinalHelpString = [FinalHelpString HelpString{HelpIdx} sprintf('\n')];
    end
    if ~isempty(FinalHelpString)
      FinalHelpString(end) = [];
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Set the Initialization Data and Documentation Page %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ExtraValueData = Data.ParamPage.ExtraValueData;
    if isempty(ExtraValueData)
      MaskValueArray = ValueArray;
    else
      MaskValueArray = [ValueArray; ExtraValueData];
    end
    set_param(Data.BlockHandle, ...
	'Mask'              , 'on',...
	'MaskType'          , get(Data.IconPage.MaskTypeHandle, 'string'),...
	'MaskDisplay'       , FinalDispString,...
	'MaskIconRotate'    , IconRotateValue,...
	'MaskIconFrame'     , IconFrameValue,...
	'MaskIconOpaque'    , IconOpaqueValue,...
	'MaskIconUnits'     , Coords(value,:),...
	'MaskDescription'   , FinalDescString,...
	'MaskHelp'          , FinalHelpString,...
	'MaskVariables'     , variableString,...
	'MaskInitialization', FinalInitString,...
	'MaskStyleString'   , typeString,...
	'MaskPrompts'       , promptArray,...
	'MaskValues'        , MaskValueArray,...
	'MaskTunableValues' , TunableArray,...
	'MaskEnables'       , EnableArray,...
	'MaskVisibilities'  , VisibleArray,...
	'MaskCallbacks'     , CallbackArray);

  end % ... if Data.AllPages

  SetMaskState(Data.BlockHandle);
  set(0,'CurrentFigure', MaskEditorHandle)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : ApplyMaskData %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CancelMaskEditor: Close mask editor without recording any changes
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CancelMaskEditor

  close(gcbf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : CancelMaskEditor %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GetPageNum : Function which gets the corresponding Page number.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function num = GetPageNum(PageName)

  switch (PageName)
    case xlate('     Icon      '),
      num =  1;
    case xlate(' Initialization '),
      num =  2;
    case xlate(' Documentation '),
      num = 3;
    otherwise,
      num = 1;
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : GetPageNum %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ChangeMaskPage : Function to change pages of the Mask Editor.        %% 
%                                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeMaskPage(newPage)
% ChangeMaskPage : Changes the Page of the Mask Editor from the current 
%                  page to the Specified Page. It is called by pressing 
%                  one of the radio buttons on the top of the Mask Editor.
%
  MaskEditorHandle = gcbf;
  Data           = get(MaskEditorHandle, 'UserData');
  currentPageNum = Data.currentPage;
  newPageNum     = GetPageNum(newPage);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Change the page only if we need to %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (currentPageNum ~= newPageNum)
    [oldpagetag, error] = sprintf('page%d', currentPageNum);
    [newpagetag, error] = sprintf('page%d', newPageNum);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Make the Current Page Invisible %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(findobj(MaskEditorHandle, 'Tag', oldpagetag), 'visible', 'off');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% If the other pages have not been created, Create them. %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~Data.AllPages
      position    = [5  70 390 315]; 
      BlockHandle = Data.BlockHandle;

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Create Param Page (Page 2 of the Mask Editor) %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      mskedpg('ParamPage', MaskEditorHandle, BlockHandle, position);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Create Documentation Page (Page 3 of the Mask Editor) %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      mskedpg('DocPage', MaskEditorHandle, BlockHandle, position);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% IMPORTANT : Since UserData has changed, Get the New UserData %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      Data          = get(MaskEditorHandle,'UserData');
      Data.AllPages = 1;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Make New Page Visible and Save Mask Editor's UserData %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(findobj(MaskEditorHandle, 'Tag', newpagetag), 'visible', 'on');
    Data.currentPage = newPageNum;
    set(MaskEditorHandle, 'UserData', Data);

  end  % ... if newpage ~= currentpage

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : ChangeMaskPage %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ChangeListBox : Manages the ListBox which lists all the Parameters %%
%                                                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ChangeListBox(button, Handle)
%                                                                
%	ChangeListBox(button) is a function to change the 
%       contents of the parameter and variable listbox
%
  if nargin == 2
    MaskEditorHandle = Handle;
  else  
    MaskEditorHandle = gcbf;
  end
  Data            = get(MaskEditorHandle, 'UserData');
  listbox         = Data.ParamPage.ParamListBox;
  nameEditHandle  = Data.ParamPage.MaskPromptsHandle;
  varEditHandle   = Data.ParamPage.MaskVariablesHandle;
  varEvalHandle   = Data.ParamPage.MaskEvalHandle;
  typeHandle      = Data.ParamPage.MaskParamTypeHandle;
  popupEditHandle = Data.ParamPage.MaskPopupStrings;
  popupTextHandle = Data.ParamPage.MaskPopupText;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Get Data of the ListBox %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  paramData         = get(listbox, 'userdata');
  selected          = get(listbox, 'value');
  [nParams, unused] = size(get(listbox,'string')); 
  ExtraValueData    = Data.ParamPage.ExtraValueData;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Define a New Data Item %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  NewDataItem.prompt    = '';
  NewDataItem.variable  = '';
  NewDataItem.type      = 'edit';
  NewDataItem.popupStr  = '';
  NewDataItem.evalType  = 0;
  NewDataItem.value     = '';
  NewDataItem.name      = '';
  NewDataItem.tunable   = 'on';
  NewDataItem.enable    = 'on';
  NewDataItem.visible   = 'on';
  NewDataItem.callback  = '';
  
  Action = 1;

  switch (button)

    case 'Up',
      %%%%%%%%%%%%%%%%%%%%%%%%%
      %% The Up Arrow Button %%
      %%%%%%%%%%%%%%%%%%%%%%%%%
      if ((selected == 1) || (selected == nParams))
        Action = 0;
      else
        % Interchange selection with the one over it
        paramData([selected selected-1]) = paramData([selected-1 selected]); 
        set(listbox, 'value', selected-1, 'userdata', paramData);
        selected = selected - 1;
        ChangeListBox('UpdateEdit', MaskEditorHandle);
      end

    case 'Down',
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% The Down Arrow Button %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      if (selected >= (nParams-1))
        Action = 0;
      else
        % Interchange selection with the one below it 
        paramData([selected selected+1]) = paramData([selected+1 selected]); 
        set(listbox, 'value', selected+1, 'userdata', paramData);
        selected = selected + 1;
        ChangeListBox('UpdateEdit', MaskEditorHandle);
      end

    case 'New',
      %%%%%%%%%%%%%%%%%%%% 
      %% The New Button %%
      %%%%%%%%%%%%%%%%%%%% 
      nParams               = nParams + 1;
      vector                = nParams:-1:(selected + 1);
      paramData(vector)  = paramData(vector-1);  
      paramData(selected) = NewDataItem;
      %
      % Check if we already have a MaskValue for this new item
      %
      if ~isempty(ExtraValueData)
	paramData(selected).value = ExtraValueData{1};
	ExtraValueData(1) = [];
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Reset all UIControls on the Parameter Page %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      set(nameEditHandle  , 'enable', 'on', 'string', '')
      set(varEditHandle   , 'enable', 'on', 'string', '')
      set(typeHandle      , 'enable', 'on', 'value' , 1)
      set(varEvalHandle   , 'enable', 'on', 'value' , 1)
      set(popupEditHandle , 'enable', 'off','String', '')
      set(popupTextHandle , 'enable', 'off')
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Enable the 8 uicontrols %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      set(Data.ParamPage.MaskPStringHandle,     'enable', 'on');
      set(Data.ParamPage.MaskPromptsHandle,     'enable', 'on');
      set(Data.ParamPage.MaskVStringHandle,     'enable', 'on');
      set(Data.ParamPage.MaskVariablesHandle,   'enable', 'on');
      set(Data.ParamPage.MaskParamStringHandle, 'enable', 'on');
      set(Data.ParamPage.MaskParamTypeHandle,   'enable', 'on');
      set(Data.ParamPage.MaskEvalStringHandle,  'enable', 'on');
      set(Data.ParamPage.MaskEvalHandle,        'enable', 'on');
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Enable other buttons %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%
      set(Data.ParamPage.DeleteButtonHandle, 'enable', 'on');
      if (selected == 1)  
	set(Data.ParamPage.UpButtonHandle,   'enable', 'off');
      else
	set(Data.ParamPage.UpButtonHandle,   'enable', 'on');
      end
      if (selected == (nParams-1))
	set(Data.ParamPage.DownButtonHandle, 'enable', 'off');
      else
	set(Data.ParamPage.DownButtonHandle, 'enable', 'on');
      end 

    case 'Delete',
      %%%%%%%%%%%%%%%%%%%%%%%
      %% the delete button %%	
      %%%%%%%%%%%%%%%%%%%%%%%
      if (selected == nParams)
        Action = 0;
      else 
        paramData(selected)   = [];
        newString             = get(listbox,'string');
        newString(selected,:) = [];
        nParams               = nParams - 1;
        set(listbox,'UserData', paramData, 'string', newString); 
        ChangeListBox('UpdateEdit', MaskEditorHandle);
      end     

    case 'Edit',
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% The Edit mode for each Parameter %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if (nParams==1)
        %% There are no Parameters and the User has entered a string %%
        %% So create a Parameter %%
        nParams = 2;
        paramData(nParams)  = paramData(selected);
        paramData(selected) = NewDataItem;
	%
	% Check if we already have a MaskValue for this new item
	%
	if ~isempty(ExtraValueData)
	  paramData(selected).value = ExtraValueData{1};
	  ExtraValueData(1) = [];
	end
        set(Data.ParamPage.DeleteButtonHandle, 'enable', 'on');
      end

      if (selected==nParams)
        Action = 0;
      else
        val                            = get(typeHandle,     'Value');
        paramData(selected).prompt   = get(nameEditHandle, 'String');
        paramData(selected).variable = get(varEditHandle,  'String');
        paramData(selected).type     = StringToValue(val);
        paramData(selected).popupStr = get(popupEditHandle,'String');
        paramData(selected).evalType = get(varEvalHandle,  'Value') - 1;
        if (val == 3)
          set(popupEditHandle, 'enable', 'on');
          set(popupTextHandle, 'enable', 'on');
        else
          set(popupEditHandle, 'enable', 'off');
          set(popupTextHandle, 'enable', 'off');
        end
      end

    case 'UpdateEdit',
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Updates the strings in the edit controls when the selection %% 
      %% is changed in the listbox.                                  %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if (selected==nParams)
        Action = 0;
        set(nameEditHandle  , 'enable', 'off', 'string', '')
        set(varEditHandle   , 'enable', 'off', 'string', '')
        set(typeHandle      , 'enable', 'off')
        set(varEvalHandle   , 'enable', 'off')
        set(Data.ParamPage.MaskPStringHandle,     'enable', 'off');
        set(Data.ParamPage.MaskPromptsHandle,     'enable', 'off');
        set(Data.ParamPage.MaskVStringHandle,     'enable', 'off');
        set(Data.ParamPage.MaskVariablesHandle,   'enable', 'off');
        set(Data.ParamPage.MaskParamStringHandle, 'enable', 'off');
        set(Data.ParamPage.MaskParamTypeHandle,   'enable', 'off');
        set(Data.ParamPage.MaskEvalStringHandle,  'enable', 'off');
        set(Data.ParamPage.MaskEvalHandle,        'enable', 'off');
        set(Data.ParamPage.DeleteButtonHandle, 'enable', 'off');
        set(Data.ParamPage.UpButtonHandle,     'enable', 'off');
        set(Data.ParamPage.DownButtonHandle,   'enable', 'off');
	set(popupEditHandle,'enable','off', 'string', '');
	set(popupTextHandle,'enable','off');

      else
        set(nameEditHandle  , 'enable', 'on')
        set(varEditHandle   , 'enable', 'on')
        set(typeHandle      , 'enable', 'on')
        set(varEvalHandle   , 'enable', 'on')
        set(Data.ParamPage.MaskPStringHandle,     'enable', 'on');
        set(Data.ParamPage.MaskPromptsHandle,     'enable', 'on');
        set(Data.ParamPage.MaskVStringHandle,     'enable', 'on');
        set(Data.ParamPage.MaskVariablesHandle,   'enable', 'on');
        set(Data.ParamPage.MaskParamStringHandle, 'enable', 'on');
        set(Data.ParamPage.MaskParamTypeHandle,   'enable', 'on');
        set(Data.ParamPage.MaskEvalStringHandle,  'enable', 'on');
        set(Data.ParamPage.MaskEvalHandle,        'enable', 'on');
        set(Data.ParamPage.DeleteButtonHandle, 'enable', 'on');
        set(Data.ParamPage.UpButtonHandle,     'enable', 'on');
        set(Data.ParamPage.DownButtonHandle,   'enable', 'on');
        set(nameEditHandle, 'String',paramData(selected).prompt);
        set(varEditHandle,  'String',paramData(selected).variable);
        set(varEvalHandle,  'value', paramData(selected).evalType + 1);
        val = ValueToString(paramData(selected).type);
            
        set(typeHandle,'value',val);
        set(popupEditHandle,'String', paramData(selected).popupStr);
        if (val == 3)
          set(popupEditHandle,'enable','on');
          set(popupTextHandle,'enable','on');
        else
          set(popupEditHandle,'enable','off', 'string', '');
          set(popupTextHandle,'enable','off');
        end
      end

      if (selected == 1)
        set(Data.ParamPage.UpButtonHandle,     'enable', 'off');
      end
      if (selected == (nParams-1))
        set(Data.ParamPage.DownButtonHandle,   'enable', 'off');
      end

  end  %% End of switch(button) %%

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% If ListBox needs to be Updated then the Action flag has been set %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if Action
    if (nParams > 1)
      %%%%%%%%%%%%%%%%%%%%%%%%%
      %% Get all the Strings %%
      %%%%%%%%%%%%%%%%%%%%%%%%%
      typeString     = char(32*ones(nParams-1,9)); 
      paramString    = char(32*ones(nParams-1,26));
      variableString = char(32*ones(nParams-1,12));
      padding        = char(32*ones(nParams-1,2));
      
      tempParam      = '';
      tempType       = strvcat(paramData(1:nParams-1).type);
      tempVar        = '';
      evalString     = '';

      for i = 1 : nParams-1
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
      paramString = strvcat(paramString, paramData(nParams).prompt);
    else 
      paramString    =  paramData(1).prompt;
      variableString = '';
      typeStr        = '';
      popupStrs      = '';
      evalString     = '';
    end %% end for  if (nParams > 1) %%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Set the New Strings and Data into Respective places %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(listbox, 'String'   , paramString,...
                 'UserData' , paramData );

    set(Data.ParamPage.MaskVStringHandle,'UserData',[evalString, variableString]);


end % if Action
Data.ParamPage.ExtraValueData = ExtraValueData;
set(MaskEditorHandle, 'UserData', Data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : ChangeListBox %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CreateEditor : Function to create the Mask Editor for the first time
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateEditor(BlockHandle)
%
% CREATEEDITOR : Creates the Mask Editor for a masked Block.
%                Calls tabdlg to create the Tabs :
%                - Icon
%                - Initialization
%                - Documentation
%
%                Creates following Push Buttons
%                - OK : Cancel : Unmask : Help : Apply
%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Determine if the Block has the Mask Editor Open %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  BlockName = [get_param(BlockHandle,'parent') '/' ...
               get_param(BlockHandle,'name')];   
  dialogName   = ['Mask Editor: ', BlockName];
  Handle       = get_param(BlockHandle,'maskeditorhandle');

  if ishandle(Handle)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% The Figure Exists. Update BlockName and Data %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Data = get(Handle,'UserData');

    %%%%%%%%%%%%%%%%%%%%%%%%
    %% Set the Block Name %% 
    %%%%%%%%%%%%%%%%%%%%%%%%
    BlockName = [get_param(Data.BlockHandle,'parent') '/' ...
                 get_param(Data.BlockHandle,'name')];   
    set(Handle,'name',['Mask Editor: ' BlockName])

    %%%%%%%%%%%%%%%%%%%%%%%%
    %% Sync the Icon Page %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    SyncIcon = masksync('SyncIconPage', Handle, BlockHandle);
    set(Data.IconPage.MaskTypeHandle,   'String', SyncIcon.TypeString);
    set(Data.IconPage.MaskDisplayHandle,'String', {SyncIcon.DisplayString});
    set(Data.IconPage.MaskRotateIconHandle, 'value', SyncIcon.RotateValue);
    set(Data.IconPage.MaskFrameIconHandle, 'value', SyncIcon.FrameValue);
    set(Data.IconPage.MaskOpaqueIconHandle, 'value', SyncIcon.OpaqueValue);
    set(Data.IconPage.MaskDrawingCoordsHandle, 'value', SyncIcon.NormalValue);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Don't Sync the other pages if they have never been opened %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Data.AllPages
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Sync the Documentation Page %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      SyncDoc   = masksync('SyncDocPage', Handle, BlockHandle);
      set(Data.DocPage.MaskDescriptionHandle, ...
	  'String', {SyncDoc.DescriptionString});
      set(Data.DocPage.MaskHelpHandle, 'String', {SyncDoc.HelpString});
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Sync the Parameter Page and Set Value of Listbox to 1 %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      SyncParam = masksync('SyncParamPage', Handle, BlockHandle);
      listbox   = Data.ParamPage.ParamListBox;
      set(listbox, 'value', 1);
      set(Data.ParamPage.MaskInitCommandsHandle,...
	  'String', SyncParam.InitString);       
      set(listbox, 'String'  , SyncParam.ParamString, ...
	  'UserData', SyncParam.ParamData);
      ChangeListBox('UpdateEdit', Handle)
    
    end  % ... end of if Data.AllPages
    set(Handle, 'Visible','on');
    figure(Handle)

  else 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create a Figure for the Mask Editor %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pushHsize    = 70;
    pushVsize    = 25;
    Border       = 5;
    FigureWidth  = 410;
    FigureHeight = 400;
    tab          = [10 90 170 250 330];
    Grey         = get(0,'defaultuicontrolbackgroundcolor');
    ctab         = [  0         0         0;
                      1.0000    1.0000    1.0000;
                      0.7020    0.7020    0.7020;
                      0.6000    0.6000    0.6000;
                      0.5000    0.5000    0.5000;
                      0.4000    0.4000    0.4000 ];
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Place the Mask Editor in the Middle of the Screen %% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    screen     = get(0,'ScreenSize');
    FigureXpos = (screen(3)-FigureWidth)/2;
    FigureYpos = (screen(4)-FigureHeight)/2;
    if (FigureXpos < 0) FigureXpos = FigureXpos*2; end
    if (FigureYpos < 0) FigureYpos = FigureYpos*2; end
 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Add the Tabs along the top of the Mask Editor %%         
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strings    = cell(3,1);
    strings(1) = {xlate('     Icon      ')};
    strings(2) = {xlate(' Initialization ')};
    strings(3) = {xlate(' Documentation ')};
  
    if strcmp(computer, 'PCWIN'),
      font.name = 'MS Sans Serif';
      font.size = 10;
    else
      font.name = get(0,'DefaultUIControlFontName');
      font.size = get(0,'DefaultUIControlFontSize');
    end

    tabDims   = {[60; 90; 100], 21};
    sheetDims = [FigureWidth (FigureHeight-(5*Border+pushVsize))];
    offsets   = [5 5 5 (5*Border+pushVsize)];

    [dlgHandle, sheetPos] = tabdlg('create', ...
                   strings,    ...
                   tabDims,    ... 
                   'mskeddlg', ...
                   sheetDims,  ... 
                   offsets,    ...
                   1 );

    position = get(dlgHandle, 'position');
    set(dlgHandle, ...
               'Tag',             'maskEditDialog',...
               'Visible',         'off',...
               'ColorMap',        ctab,...
               'Position',[FigureXpos FigureYpos position(3) position(4)],...
               'Name',            dialogName,...
               'NumberTitle',     'off',...
               'IntegerHandle',   'off',...
               'MenuBar',         menubar,...
               'DeleteFcn',       'mskeddlg deleteEditor',...
               'Color',           Grey);

    %%%%%%%%%%%%%%%%%%
    %% Get UserData %%
    %%%%%%%%%%%%%%%%%%
    Data = get(dlgHandle, 'UserData');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %% Add the Block Handle to the UserData %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    Data.currentPage = 1;
    Data.BlockHandle = BlockHandle;
    Data.AllPages    = 0;
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create The Push Buttons along the bottom of the Mask Editor % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Data.Buttons.OKHandle = uicontrol( ...
                'Style',                  'pushbutton',...
                'Position',        [tab(1) 2*Border pushHsize pushVsize],...
                'Callback',               'mskeddlg Close',...
                'enable',                 'on',...
                'String',                 'OK' );
    Data.Buttons.CancelHandle = uicontrol( ...
                'Style',                  'pushbutton',...
                'Position',        [tab(2) 2*Border pushHsize pushVsize],...
                'Callback',               'mskeddlg Cancel',...
                'Enable',                 'on',...
                'String',                 'Cancel');
    Data.Buttons.UnmaskHandle = uicontrol( ...
                'Style',                  'pushbutton',...
                'Position',         [tab(3) 2*Border pushHsize pushVsize],...
                'Callback',               'mskeddlg Unmask',...
                'Enable',                 'on',...
                'String',                 'Unmask' );
    Data.Buttons.HelpHandle = uicontrol( ...
                'Style',                  'pushbutton',...
                'Position',        [tab(4) 2*Border pushHsize pushVsize],...
                'Callback',               'mskeddlg Help',...
                'Enable',                 'on',...
                'String',                 'Help' );
    Data.Buttons.ApplyHandle = uicontrol( ...
                'Style',                  'pushbutton',...
                'Callback',               'mskeddlg Apply',...
                'Position',        [tab(5) 2*Border pushHsize pushVsize],...
                'UserData',               0,...
                'Enable',                 'on',...
                'String',                 'Apply' );
	   
    set(dlgHandle,'UserData',Data);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create the first page only as it is what will be seen first %%
    %% although there are 3 screens. The other 2 are created later %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    position = [5  70 390 315]; 
    mskedpg('IconPage',dlgHandle, BlockHandle, position); 

    set(dlgHandle,'HandleVisibility','callback',...
                   'Visible','on',...
                   'resize','off');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  			
    %% Set the Mask Editor handle in the Block %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  			
    set_param(BlockHandle,'maskEditorHandle',dlgHandle);              

  end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : CreateEditor %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ValueToString : Function returns enumerated value for type string.
%%                 Returns the following:
%%                 edit     = 1
%%                 checkbox = 2
%%                 popup    = 3
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = ValueToString(str)

  %% Default to the Edit control %%
  val = 1;
  if strncmp(str, 'chec', 4)
    val = 2;
  elseif strncmp(str, 'popu', 4)
    val = 3;
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : ValueToString %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% StringToValue : Function returns string associated with enumerated value 
%%                 Returns the following:
%%                 1 = edit    
%%                 2 = checkbox
%%                 3 = popup   
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = StringToValue(num)

  str = 'edit';
  if (num == 2)
    str = 'checkbox';
  elseif (num == 3)
    str = 'popup';
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : StringToValue %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DisplayError : Display the error encountered in an Error    %%
%%                dialog with the lasterr                      %% 
%%                                                             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DisplayError(ErrMsg)

  CF = get(0,'CurrentFigure');
  errordlg(ErrMsg, 'Error','modal')
  set(0,'CurrentFigure', CF)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : DisplayError %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RotateVal : returns the rotate string depending upon popup value %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RotateStr = RotateVal(idx)

values = {'none','port','pure'};
RotateStr = values{idx};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End of function : RotateVal %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
  if (length(currentField) >= 4) && ...
     strcmp(currentField(1:4), 'Mask') && ... 
     strcmp(getfield( maskParams, currentField, 'Type' ), 'string')
    str = get_param(handle, currentField);
    if ~isempty(str)
      return;
    end
  end
end
set_param(handle, 'Mask', 'off');


