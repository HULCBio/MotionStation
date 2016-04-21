function varargout = confirm_close(varargin)
% CONFIRM_CLOSE Application M-file for confirm_close.fig
%   CONFIRM_CLOSE, by itself, creates a new CONFIRM_CLOSE or raises the existing
%   singleton*.
%
%   H = CONFIRM_CLOSE returns the handle to a new CONFIRM_CLOSE or the handle to
%   the existing singleton*.
%
%   CONFIRM_CLOSE('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in CONFIRM_CLOSE.M with the given input arguments.
%
%   CONFIRM_CLOSE('Property','Value',...) creates a new CONFIRM_CLOSE or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before confirm_close_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to confirm_close_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GCBO, OPENFIG, GUIDATA, GUIHANDLES, FEVAL

% Edit the above text to modify the response to help confirm_close

% Last Modified by GUIDE v2.5 10-Mar-2002 11:20:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @confirm_close_OpeningFcn, ...
                   'gui_OutputFcn',     @confirm_close_OutputFcn, ...
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


% --- Executes just before confirm_close is made visible.
function confirm_close_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to confirm_close (see VARARGIN)

% Choose default command line output for confirm_close
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes confirm_close wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = confirm_close_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

user_response = modaldlg('Title','Confirm Close');
switch lower(user_response)
case 'no'
	% take no action
case 'yes'
	% Prepare to close GUI application window
	%                  .
	%                  .
	%                  .
	delete(handles.figure1)
end

