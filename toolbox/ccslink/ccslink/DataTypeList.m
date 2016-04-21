function varargout = DataTypeList(varargin)
% DATATYPELIST M-file for DataTypeList.fig
%      DATATYPELIST, by itself, creates a new DATATYPELIST or raises the existing
%      singleton*.
%
%      H = DATATYPELIST returns the handle to a new DATATYPELIST or the handle to
%      the existing singleton*.
%
%      DATATYPELIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATATYPELIST.M with the given input arguments.
%
%      DATATYPELIST('Property','Value',...) creates a new DATATYPELIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataTypeList_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataTypeList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataTypeList

% Last Modified by GUIDE v2.5 13-Jan-2003 12:15:07
% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/30 23:13:06 $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataTypeList_OpeningFcn, ...
                   'gui_OutputFcn',  @DataTypeList_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DataTypeList is made visible.
function DataTypeList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataTypeList (see VARARGIN)

% Choose default command line output for DataTypeList
handles.output = hObject;
enableLoadBox(handles,'off');

handles.cc = varargin{1};
handles.proceed=1;
handles.parentGUIHandles = varargin{3};
if strcmp(varargin{2},'edit-typedef')
    handles.editTypedef = 1; % edit existing typedef entry
    setTextFields(handles,varargin{4});
    pos = get(handles.typedefName,'Position'); pos(2) = 18.076923076923077-0.265;
    set(handles.typedefName,'Position',pos);
    col = [0.8313725490196078,0.8156862745098039,0.7843137254901961];
    set(handles.typedefName,'BackgroundColor',col);
    set(handles.typedefName,'Enable','off');
elseif strcmp(varargin{2},'new-typedef')
    handles.editTypedef = 0; % new typedef entry
    set(handles.typedefName,'Enable','on');
end
proc = GetProcSubFamily(handles.cc.family,handles.cc.subfamily);

% Store old equivalent type
handles.prev_equivalentType = get(handles.equivalentType,'String');

% Get all types
[handles.TI_Types,handles.qTI_Types,handles.ML_Types] = feval([proc '_Datatypes'],handles.cc.type);
handles.UD_Types = UserDefinedTypes(handles.cc.type);

% Initialize Listbox
set(handles.KnownTypeList,'String',{handles.ML_Types{1:2:end}});

% If editing an exisiting typedef - set GUI to reflect current properties
if handles.editTypedef % edit existing typedef entry
    setGUIAttributes(handles,get(handles.equivalentType,'String'));
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataTypeList wait for user response (see UIRESUME)
% uiwait(handles.dataTypeList);


% --- Outputs from this function are returned to the command line.
function varargout = DataTypeList_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%% CreateFcn methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.

function equivalentType_CreateFcn(hObject, eventdata, handles)
CreateFcnDefault(hObject);
function KnownTypeList_CreateFcn(hObject, eventdata, handles)
CreateFcnDefault(hObject);

%%%%%%%%%%%%%%%%%%%%%% Callback methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function typedefName_Callback(hObject, eventdata, handles)
function equivalentType_Callback(hObject, eventdata, handles)

% --- Executes on button press in KnownTypeClass.
function KnownTypeClass_Callback(hObject, eventdata, handles)
val = GetSelection(hObject);
% disableHighlight(handles.KnownTypeList);
if strfind(val,'TI C')
    Settings4TIC(handles);
elseif strfind(val,'TI Fixed Point')
    set(handles.KnownTypeList,'Value',1);
    Settings4TIFxPt(handles);
elseif strfind(val,'MATLAB')
    set(handles.KnownTypeList,'Value',1);
    Settings4MATLAB(handles);
elseif strfind(val,'Struct')
    set(handles.KnownTypeList,'Value',1);
    Settings4UD(handles);
    if isempty(get(handles.KnownTypeList,'String'))
        warndlg('List is empty. You need to load a program to populate this list.','No CCS struct,union,enum types');
        return
    end
else
    Settings4Other(handles);
end

% --- Executes on button press in userDefinedType.
function userDefinedType_Callback(hObject, eventdata, handles)
set(hObject,'Value',1);
set(handles.specialTIType,'Value',0);
set(handles.matlabType,'Value',0);
set(handles.KnownTypeClass,'Value',0);
set(handles.otherType,'Value',0);

% --- Executes on selection change in userDefinedTypeList.
function userDefinedTypeList_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
% Check if there is no entry
if isempty(contents)
    warndlg('List is empty. You need to load a program to populate this list.','No CCS struct,union,enum types');
    return
end
% Remove highlights from othere types
% disableHighlight(hObject,handles,'userDefinedTypeList');
% Set the 'equivalent type' field to selected type
val = setEquivalentType(hObject,handles);
try
    % Get information on selected type
    warning off
    UDInfo = list(handles.cc.type,val);
    warning on
catch
    % If no info is available
	if strfind(lasterr,['Type ''' val ''' is not recognized.'])
        errordlg(['No information is available on ''' val '''. Examine your source code to get ',...
            'more information on this type. '],...
            'No data type info','modal');
        return
	else
    % If an error occurred
        errordlg(lasterr,'modal');
	end
end
% Call GUI
selectionType = get(handles.dataTypeList,'selectionType');
if strcmp(selectionType,'open') % double-click
    DataTypeInfoGui(UDInfo);
end

% --- Executes on selection change in otherTypeList.
function otherTypeList_Callback(hObject, eventdata, handles)
set(handles.equivalentType,'String',get(hObject,'String'));

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
if ~applyTypeChanges(hObject, eventdata, handles)
    return
end
delete(handles.dataTypeList)

% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
delete(handles.dataTypeList);

% --- Executes on button press in loadCCSProgram.
function loadCCSProgram_Callback(hObject, eventdata, handles)
% targetName = get(handles.BoardName,'String');
orig_path = pwd;
cd(handles.cc.cd); % cd to where project resides
[filename, pathname] =  uigetfile('*.out'); %,['Load Program Files - ' targetName]);
cd(orig_path);
if ischar(filename) && ischar(pathname),
    try
        set(handles.programName,'String',['Loading ' filename ' ...']);
        handles.cc.open(fullfile(pathname, filename),'Program',30);
        handles.parentGUIHandles.text = horzcat( handles.parentGUIHandles.text, ...
                                {['open(cc,''',fullfile(pathname, filename),''',''program'',30);']} );
        guidata(handles.parentGUIHandles.saveSession,handles.parentGUIHandles);
    catch
        set(handles.programName,'String',['Loading FAILED.']);
        errordlg('Failed during load, please select a valid progarm file','Program Load Failure','modal');
        return;
    end 
    handles.UD_Types = refreshAfterLoad(hObject,handles,filename);
    % Refresh display
    val = GetSelection(handles.KnownTypeClass);
    if strfind(val,'Struct')
        set(handles.KnownTypeList,'String',handles.UD_Types);
    end
    guidata(hObject,handles);
end    

%%%%%%%%%%%%%%%%%%% PRIVATE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ----------------------------------------
% --- UI default settings
function CreateFcnDefault(hObject)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% ----------------------------------------
function val = setEquivalentType(hObject,handles)
contents = get(hObject,'String');
if ~isempty(contents)
	val = contents{get(hObject,'Value')};
	set(handles.equivalentType,'String',val);
end
% ----------------------------------------
function disableHighlight(hObject)
set(handles.KnownTypeList,'Max',2);
set(handles.KnownTypeList,'Value',[]);

% ----------------------------------------
function stat = addTypeToCC(hObject,handles)
stat = 1;
typedefName = get(handles.typedefName,'String');
equivalentType = get(handles.equivalentType,'String');
if isempty(typedefName) 
    warndlg('You have not specified a typedef name.','Incomplete info');
    stat = 0;    return;
elseif isempty(equivalentType)
    warndlg('You have not specified an equivalent type.','Incomplete info');
    stat = 0;    return;
elseif strcmp(handles.prev_equivalentType,equivalentType)
    stat = -1;   return; % no changes made
else
end
try
    add(handles.cc.type,typedefName,equivalentType);
catch
    stat = 0;
    errordlg(lasterr,'Parsing problem','modal')
end
handles.parentGUIHandles.text = horzcat( handles.parentGUIHandles.text, ...
                                {['add(cc.type,''',typedefName,''',''',equivalentType,''');']} );
guidata(handles.parentGUIHandles.saveSession,handles.parentGUIHandles);
guidata(hObject,handles);

% ----------------------------------------
function UD_Types = refreshAfterLoad(hObject,handles,filename)
handles.UD_Types = UserDefinedTypes(handles.cc.type);
% set(handles.userDefinedTypeList,'String',handles.UD_Types);
% set(handles.programNameText,'String','Target program file:');
set(handles.programName,'String',filename);
guidata(hObject,handles);
UD_Types = handles.UD_Types; % return UD_Types - bug in GUIDE
                             % handles.UD_Types is not saved

% ----------------------------------------
function setTextFields(handles,typedefInfoString)
openpar = findstr('(',typedefInfoString);
typedefName = typedefInfoString(1:openpar(1)-2);
typedefEqv  = typedefInfoString(openpar(1)+1:end-1);
set(handles.typedefName,'String',typedefName);
set(handles.equivalentType,'String',typedefEqv);

% ----------------------------------------
function setGUIAttributes(handles,typedefEqv)

% TI C types
TIidx  = strmatch(typedefEqv,{handles.TI_Types{1:2:end}},'exact');
if ~isempty(TIidx)
    set(handles.KnownTypeClass,'Value',2);
    Settings4TIC(handles);
    set(handles.KnownTypeList,'Value',TIidx);
    return   
end
% Matlab
MLidx  = strmatch(typedefEqv,{handles.ML_Types{1:2:end}},'exact');
if ~isempty(MLidx)
    set(handles.KnownTypeClass,'Value',1);
    Settings4MATLAB(handles);
    set(handles.KnownTypeList,'Value',MLidx);
    return   
end
qTIidx = strmatch(typedefEqv,{handles.qTI_Types{1:2:end}},'exact');
if ~isempty(qTIidx)
    set(handles.KnownTypeClass,'Value',3);
    Settings4TIFxPt(handles);
    set(handles.KnownTypeList,'Value',qTIidx);
    return   
end
% User-defined (struct,union,enum)
UDidx  = strmatch(typedefEqv,handles.UD_Types,'exact');
if ~isempty(UDidx)
    set(handles.KnownTypeClass,'Value',4);
    Settings4UD(handles);
    set(handles.KnownTypeList,'Value',UDidx);
    return   
end
% Others
set(handles.KnownTypeClass,'Value',5);
Settings4Other(handles);
set(handles.otherTypeList,'String',get(handles.equivalentType,'String'));
otherTypeList_Callback(handles.otherTypeList,0,handles);

% ----------------------------------------------------------
function stat = applyTypeChanges(hObject, eventdata, handles)
% Add type or save changes to cc.type list
stat = addTypeToCC(hObject,handles);
% Stat - closes DataTypeList GUI
if stat==0, % no type added bec of invalid input(s)
    return; 
elseif stat==-1, % no type added bec of no new change(s)
    stat=1; return; % set stat=1 to trick & close GUI
end 
% Call refresh callback for parent GUI
refreshList(handles.parentGUIHandles.refreshList,handles.parentGUIHandles);

% --- Executes on selection change in KnownTypeList.
function KnownTypeList_Callback(hObject, eventdata, handles)
setEquivalentType(hObject,handles);
val = GetSelection(handles.KnownTypeClass);
if strfind(val,'Struct')
    userDefinedTypeList_Callback(handles.KnownTypeList, eventdata, handles)
end

% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)

% --------------------------------------------
% Disable/Enable Load Box
function enableLoadBox(handles,state)
set(handles.loadCCSProgram,'Enable',state);
set(handles.programNameText,'Enable',state);
set(handles.programName,'Enable',state);

% --------------------------------------------
% Get selected string
function val = GetSelection(hObject)
contents = get(hObject,'String');
val = contents{get(hObject,'Value')};

% --------------------------------------------
function ToggleListboxVisibility(handles,state)
% flip state
if strcmp(state,'on')
    state2 = 'off';
else
    state2 = 'on';
end
% Known Type
set(handles.KnownTypeList,'Visible',state);
% Other Type
set(handles.otherTypeList,'Visible',state2);

% ------------------------------------------
function Settings4TIC(handles)
set(handles.KnownTypeList,'String',{handles.TI_Types{1:2:end}});
enableLoadBox(handles,'off');
ToggleListboxVisibility(handles,'on');
% ------------------------------------------
function Settings4MATLAB(handles)
set(handles.KnownTypeList,'String',{handles.ML_Types{1:2:end}});
enableLoadBox(handles,'off');
ToggleListboxVisibility(handles,'on');
% ------------------------------------------
function Settings4TIFxPt(handles)
set(handles.KnownTypeList,'String',{handles.qTI_Types{1:2:end}});
enableLoadBox(handles,'off');
ToggleListboxVisibility(handles,'on');
% ------------------------------------------
function Settings4UD(handles)
set(handles.KnownTypeList,'String',handles.UD_Types);
enableLoadBox(handles,'on');
ToggleListboxVisibility(handles,'on');
% ------------------------------------------
function Settings4Other(handles)
enableLoadBox(handles,'off');
ToggleListboxVisibility(handles,'off');
% ------------------------------------------
function proc = GetProcSubFamily(family,subfamily)
proc = [];
if family==320
    if subfamily>=96 && subfamily<112
        proc = 'C6x';
    elseif subfamily==84
        proc = 'C54x';
    elseif subfamily==85
        proc = 'C55x';
    elseif subfamily==40
        proc = 'C28x';
    elseif subfamily==39
        proc = 'C27x';
    elseif subfamily==36
        proc = 'C24x';
    else
        errordlg(['DataTypeManger has no support for TMS' num2str(family) 'C' dec2hex(subfamily) 'x types.'],'Processor not supported','modal');
    end
elseif family==470
    if subfamily==1
        proc = 'Rxx';
    elseif subfamily==2
        proc = 'Rxx';
    else
        errordlg(['DataTypeManger has no support for TMS' num2str(family) 'R' dec2hex(subfamily) 'x types.'],'Processor not supported','modal');
    end
else
    errordlg(['DataTypeManger has no support for TMS' num2str(family) num2str(hex2dec(subfamily))' types.'],'Processor not supported','modal');
end

% [EOF]