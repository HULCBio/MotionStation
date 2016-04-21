function varargout = TempDTypesGui(varargin)
% TEMPDTYPESGUI M-file for TempDTypesGui.fig
%      TEMPDTYPESGUI, by itself, creates a new TEMPDTYPESGUI or raises the existing
%      singleton*.
%
%      H = TEMPDTYPESGUI returns the handle to a new TEMPDTYPESGUI or the handle to
%      the existing singleton*.
%
%      TEMPDTYPESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMPDTYPESGUI.M with the given input arguments.
%
%      TEMPDTYPESGUI('Property','Value',...) creates a new TEMPDTYPESGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TempDTypesGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TempDTypesGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:36 $

% Edit the above text to modify the response to help TempDTypesGui

% Last Modified by GUIDE v2.5 21-Jan-2003 16:11:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TempDTypesGui_OpeningFcn, ...
                   'gui_OutputFcn',  @TempDTypesGui_OutputFcn, ...
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


% --- Executes just before TempDTypesGui is made visible.
function TempDTypesGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TempDTypesGui (see VARARGIN)

% Choose default command line output for TempDTypesGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TempDTypesGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TempDTypesGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function editBoxTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBoxTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editBoxTag_Callback(hObject, eventdata, handles)
% hObject    handle to editBoxTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBoxTag as text
%        str2double(get(hObject,'String')) returns contents of editBoxTag as a double


% --- Executes on button press in okButtonTag.
function okButtonTag_Callback(hObject, eventdata, handles)
% hObject    handle to okButtonTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


% --- Executes during object creation, after setting all properties.
function type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function type_Callback(hObject, eventdata, handles)
% hObject    handle to type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of type as text
%        str2double(get(hObject,'String')) returns contents of type as a double


