function varargout = simple_gui(varargin)
% SIMPLE_GUI Application M-file for simple_gui.fig
%   SIMPLE_GUI, by itself, creates a new SIMPLE_GUI or raises the existing
%   singleton*.
%
%   H = SIMPLE_GUI returns the handle to a new SIMPLE_GUI or the handle to
%   the existing singleton*.
%
%   SIMPLE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in SIMPLE_GUI.M with the given input arguments.
%
%   SIMPLE_GUI('Property','Value',...) creates a new SIMPLE_GUI or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before simple_gui_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to simple_gui_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help simple_gui

% Last Modified by GUIDE v2.5 08-Apr-2002 16:26:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @simple_gui_OpeningFcn, ...
                   'gui_OutputFcn',     @simple_gui_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before simple_gui is made visible.
function simple_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to simple_gui (see VARARGIN)

%Create the data to plot
handles.peaks = peaks(35);
handles.membrane = membrane;
[x,y] = meshgrid(-8:.5:8);
r = sqrt(x.^2+y.^2) + eps;
z = sin(r)./r;
handles.sinc = z;
handles.current_data = handles.peaks;
surf(handles.current_data)

% Choose default command line output for simple_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
% Call the popup menu callback to set the handles.current_data 
% field to the current value of the popup
plot_popup_Callback(handles.plot_popup,[],handles)
% --------------------------------------------------------------------
    
% UIWAIT makes simple_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = simple_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function varargout = surf_pushbutton_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to surf_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

z = handles.current_data;
surf(z);

% --------------------------------------------------------------------
function varargout = mesh_pushbutton_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to mesh_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

z = handles.current_data;
mesh(z)

% --------------------------------------------------------------------
function varargout = contour_pushbutton_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to contour_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

z = handles.current_data;
contour(z)

% --------------------------------------------------------------------
function varargout = plot_popup_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to plot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

val = get(hObject,'Value');
str = get(hObject, 'String');
switch str{val};
case 'peaks'
	handles.current_data = handles.peaks;
case 'membrane'
	handles.current_data = handles.membrane;
case 'sinc'
    handles.current_data = handles.sinc;
	
end
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function plot_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


