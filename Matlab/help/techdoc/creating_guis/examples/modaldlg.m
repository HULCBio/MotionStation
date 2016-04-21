function varargout = modaldlg(varargin)
% MODALDLG Application M-file for untitled.fig
%   MODALDLG, by itself, creates a new MODALDLG or raises the existing
%   singleton*.
%
%   H = MODALDLG returns the handle to a new MODALDLG or the handle to
%   the existing singleton*.
%
%   MODALDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in MODALDLG.M with the given input arguments.
%
%   MODALDLG('Property','Value',...) creates a new MODALDLG or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before modaldlg_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to modaldlg_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 08-Apr-2002 16:30:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @modaldlg_OpeningFcn, ...
                   'gui_OutputFcn',     @modaldlg_OutputFcn, ...
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


% --- Executes just before modaldlg is made visible.
function modaldlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to modaldlg (see VARARGIN)

% Choose default command line output for modaldlg
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
if(nargin > 3)
    for index = 1:2:(nargin-3),
        switch lower(varargin{index})
        case 'title'
            set(hObject, 'Name', varargin{index+1});
        case 'string'
            set(handles.string, 'String', varargin{index+1});
        otherwise
            error('Invalid input arguments');
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
FigWidth=215;FigHeight=88;
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','points');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','points');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'position', FigPos);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

IconData=questIconData;
questIconMap(256,:)=get(handles.figure1,'color');
IconCMap=questIconMap;

axes(handles.axes1);
Img=image(IconData);
set(handles.figure1, 'Colormap', IconCMap);

set(gca, ...
    'Visible', 'off', ...
    'YDir'   ,'reverse'       , ...
    'XLim'   ,get(Img,'XData'), ...
    'YLim'   ,get(Img,'YData')  ...
    );
    
% UIWAIT makes modaldlg wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = modaldlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in yes_button.
function yes_button_Callback(hObject, eventdata, handles)
% hObject    handle to yes_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in no_button.
function no_button_Callback(hObject, eventdata, handles)
% hObject    handle to no_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" - do uiresume if we get it
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    
