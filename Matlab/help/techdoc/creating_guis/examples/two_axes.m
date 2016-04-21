function varargout = two_axes(varargin)
% TWO_AXES Application M-file for two_axes.fig
%   TWO_AXES, by itself, creates a new TWO_AXES or raises the existing
%   singleton*.
%
%   H = TWO_AXES returns the handle to a new TWO_AXES or the handle to
%   the existing singleton*.
%
%   TWO_AXES('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in TWO_AXES.M with the given input arguments.
%
%   TWO_AXES('Property','Value',...) creates a new TWO_AXES or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before two_axes_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to two_axes_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help two_axes

% Last Modified by GUIDE v2.5 25-Mar-2002 12:19:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @two_axes_OpeningFcn, ...
                   'gui_OutputFcn',     @two_axes_OutputFcn, ...
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

% --- Executes just before two_axes is made visible.
function two_axes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to two_axes (see VARARGIN)

% Choose default command line output for two_axes
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes two_axes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = two_axes_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function varargout = plot_button_Callback(h, eventdata, handles, varargin)
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get user input from GUI
f1 = str2double(get(handles.f1_input,'String'));
f2 = str2double(get(handles.f2_input,'String'));
t = eval(get(handles.t_input,'String'));

% Calculate data
x = sin(2*pi*f1*t) + sin(2*pi*f2*t);
y = fft(x,512);
m = y.*conj(y)/512;
f = 1000*(0:256)/512;;

% Create frequency plot
axes(handles.frequency_axes)
plot(f,m(1:257))
set(handles.frequency_axes,'XMinorTick','on')
grid on

% Create time plot
axes(handles.time_axes)
plot(t,x)
set(handles.time_axes,'XMinorTick','on')
grid on


