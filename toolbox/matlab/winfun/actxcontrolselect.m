function varargout = actxcontrolselect(varargin)
%ACTXCONTROLSELECT A GUI for selecting and creating an ActiveX control.
%  [H, INFO] = ACTXCONTROLSELECT
%  creates an ActiveX control through a GUI. 
%
%  H is the handle of the control's default interface.
%
%  INFO is a three column cell array with the Name, ProgID, and Filename of
%  the created control.
% 
%  Example: h=actxcontrolselect
%   
%  See also: ACTXCONTROL, ACTXCONTROLLIST

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.0

% Last Modified by GUIDE v2.5 25-Feb-2004 15:25:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @actxcontrolselect_OpeningFcn, ...
                   'gui_OutputFcn',  @actxcontrolselect_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before actxcontrolselect is made visible.
function actxcontrolselect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

%get a list of all ActiveX controls in the system
persistent activexList;

% keep user parameters sending to actxcontrol command
set(handles.OKButton,'String',  'Create');

if isempty(activexList)
    activexList = actxcontrollist;
end
set(handles.ActiveXList, 'String',  {activexList{:,1}});

% set up GUIDE's way of using this dialog
handles.User = 'Normal';
if (~isempty(varargin) && length(varargin)>=2 && strcmpi(varargin{1},'User'))
    handles.User = varargin{2};
end    
if isempty(get(handles.figure1,'javaframe')) 
    set(handles.HelpButton,'Enable','off');
else
    set(handles.HelpButton,'Enable','on');
    if isequal(handles.User,'GUIDE')
        set(handles.PropertiesButton,'Visible','off');
        handles.helpmapfile = fullfile(docroot, '/mapfiles/creating_guis.map');
        handles.helpkey = 'activex_controls';
    else
        set(handles.PropertiesButton,'Visible','on');
        handles.helpmapfile = fullfile(docroot, '/techdoc/matlab_external/matlab_external.map');
        handles.helpkey = 'creating_activex_controls';
    end
end

% Choose default command line output for actxcontrolselect
handles.controls = activexList;
handles.selection = {};
handles.output = {hObject, handles.selection};
handles.Parent = [];
handles.Position = get(0,'DefaultUicontrolPosition');
handles.EventCallback = {};
handles.TestFigure = figure('visible','off', 'handlevisibility', 'off');
prompt1 = ['Please select an ActiveX control from the list of all controls in', ...
           ' your system. You can see a preview of the selected control if it ',...
           'can be created successfully in MATLAB and has a screen image.'];
prompt2= ['You can also see a list of parameters used in creating an ActiveX ',...
           'control. Press the Properties button to see their default values ',...
           ' and choose different ones.'];       
handles.prompt = sprintf('%s\n\n%s',prompt1, prompt2);
set(handles.PromptEdit, 'String', handles.prompt);
    
% Update handles structure
guidata(hObject, handles);

%Make the GUI modal
set(handles.figure1,'HandleVisibility','off')
set(handles.figure1,'WindowStyle','modal')

Local_CreatePreview(handles);

% UIWAIT makes actxcontrolselect wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = actxcontrolselect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
output =  handles.output;
delete(handles.TestFigure);
delete(handles.figure1);

if ~isempty(output)
    progid = output{1,2};
    callback = {};
    count=0;
    h=[];
    if ~isequal(handles.User, 'GUIDE')
        for i=1:length(handles.EventCallback)
            handler = deblank(fliplr(deblank(handles.EventCallback{i,2})));
            if ~isempty(handler)
                count =count +1;
                callback{count,1} = handles.EventCallback{i,1};
                callback{count,2} = handles.EventCallback{i,2};
            end
        end
        if ishandle(handles.Parent)
            h = actxcontrol(progid, handles.Position, handles.Parent, callback);    
        else
            h = actxcontrol(progid, handles.Position, gcf, callback);    
        end
    end
    output ={};
    output{1} = h;
    output{2} = handles.output;
else
    output{1} = [];
    output{2} = [];
end
varargout = output;

% --- Executes during object creation, after setting all properties.
function ActiveXList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ActiveXList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ActiveXList.
function ActiveXList_Callback(hObject, eventdata, handles)
% hObject    handle to ActiveXList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ActiveXList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ActiveXList

Local_CreatePreview(handles);

% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.ActiveXList, 'Value');
name = char(handles.controls{index, 1});
progid = char(handles.controls{index, 2});
location = char(handles.controls{index, 3});

handles.output = {name, progid, location};
guidata(handles.figure1, handles);
uiresume(handles.figure1);

function Local_CreatePreview(handles)
if isfield(handles, 'Preview') & ishandle(handles.Preview)
    delete(handles.Preview);
    handles = rmfield(handles, 'Preview');
    guidata(handles.figure1, handles);
end

index = get(handles.ActiveXList, 'Value');

name = char(handles.controls{index, 1});
progid = char(handles.controls{index, 2});
location = char(handles.controls{index, 3});
pos = get(handles.PromptEdit, 'Position');
set(handles.ProgIDLabel,'String', progid);
set(handles.LocationLabel,'String', location);

% disable buttons while the preview is created
set(handles.PropertiesButton, 'enable','off');
set(handles.OKButton, 'enable','off');
set(handles.PromptEdit, 'String', '');
set(handles.PromptEdit, 'Visible', 'on');

control =[];
try
    control = actxcontrol(progid, pos, handles.TestFigure);
    delete(control);
    control = actxcontrol(progid, pos, handles.figure1);
    set(handles.PromptEdit, 'Visible', 'off');
    % enable buttons after the preview is created successfully
    set(handles.PropertiesButton, 'enable','on');
    set(handles.OKButton, 'enable','on');
catch
    set(handles.PromptEdit, 'String', lasterr);
end
handles.Preview = control;
handles.EventCallback = {};
guidata(handles.figure1, handles);

% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = [];
guidata(handles.figure1, handles);
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = [];
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in PropertiesButton.
function PropertiesButton_Callback(hObject, eventdata, handles)
% hObject    handle to PropertiesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

actxcontrolcreateproperty(handles.figure1);


% --- Executes on button press in HelpButton.
function HelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

helpview(handles.helpmapfile, handles.helpkey, 'CSHelpWindow', handles.figure1);
