function varargout = DataTypeInfoGui(varargin)
% DATATYPEINFOGUI M-file for DataTypeInfoGui.fig
%      DATATYPEINFOGUI, by itself, creates a new DATATYPEINFOGUI or raises the existing
%      singleton*.
%
%      H = DATATYPEINFOGUI returns the handle to a new DATATYPEINFOGUI or the handle to
%      the existing singleton*.
%
%      DATATYPEINFOGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATATYPEINFOGUI.M with the given input arguments.
%
%      DATATYPEINFOGUI('Property','Value',...) creates a new DATATYPEINFOGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataTypeInfoGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataTypeInfoGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataTypeInfoGui

% Last Modified by GUIDE v2.5 20-Dec-2002 10:42:40
% Copyright 2003 The MathWorks, Inc.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataTypeInfoGui_OpeningFcn, ...
                   'gui_OutputFcn',  @DataTypeInfoGui_OutputFcn, ...
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


% --- Executes just before DataTypeInfoGui is made visible.
function DataTypeInfoGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataTypeInfoGui (see VARARGIN)

% Choose default command line output for DataTypeInfoGui
handles.output = hObject;

UDInfo = varargin{1};
set(handles.UDdatatype,'String',UDInfo.type);
% set(handles.UDdatatype,'enable','off');
infoString = [];

switch UDInfo.uclass
case {'structure','union'}
	if strcmpi(UDInfo.uclass,'union')
        set(handles.UDname,'String','UNION TYPE:');
    else
        set(handles.UDname,'String','STRUCT TYPE:');
	end
    set(handles.UD_Fields,'String','Member (type):');
	structName = fieldnames(UDInfo.members);
	for i=1:length(structName)
        infoString{i} = [UDInfo.members.(structName{i}).name ' (' UDInfo.members.(structName{i}).type ')'];
	end

case 'enum'
    set(handles.UDname,'String','ENUM TYPE:');
    set(handles.UD_Fields,'String','Label (value):');
	for i=1:length(UDInfo.value)
        infoString{i} = [UDInfo.label{i} ' = ' num2str(UDInfo.value(i))];
	end
end
set(handles.UDInfoList,'String',infoString);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataTypeInfoGui wait for user response (see UIRESUME)
% uiwait(handles.UD_GUI);

% --- Outputs from this function are returned to the command line.
function varargout = DataTypeInfoGui_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function UDInfoList_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Callbacks
function UDInfoList_Callback(hObject, eventdata, handles)

% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
delete(handles.UD_GUI);