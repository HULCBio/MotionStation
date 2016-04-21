function varargout = wavemenu(varargin)
% WAVEMENU Start the Wavelet Toolbox graphical user interface tools.
%    WAVEMENU launches a menu for accessing the various 
%    graphical tools provided in the Wavelet Toolbox.

% WAVEMENU M-file for wavemenu.fig
%      WAVEMENU, by itself, creates a new WAVEMENU or raises the existing
%      singleton*.
%
%      H = WAVEMENU returns the handle to a new WAVEMENU or the handle to
%      the existing singleton*.
%
%      WAVEMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAVEMENU.M with the given input arguments.
%
%      WAVEMENU('Property','Value',...) creates a new WAVEMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wavemenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wavemenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wavemenu

% Last Modified by GUIDE v2.5 12-Sep-2003 14:18:55
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Mar-2004.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.22.4.3 $ $Date: 2004/04/01 16:30:46 $

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wavemenu_OpeningFcn, ...
                   'gui_OutputFcn',  @wavemenu_OutputFcn, ...
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
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before wavemenu is made visible.                      %
%*************************************************************************%
function wavemenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wavemenu (see VARARGIN)

% Choose default command line output for wavemenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wavemenu wait for user response (see UIRESUME)
% uiwait(handles.WTBX_MainMenu);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Intoduced manualy in the automatic generated code   %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:});
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wavemenu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
% hObject    handle to PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%-------------------------------------------------------------------
% --- Executes on button press in PushButton Tool.
function Pus_TOOL_Callback(hObject,eventdata,handles,ToolName)
mousefrm(0,'watch');
switch ToolName
    case 'dw1dtool' , dw1dtool;
    case 'wp1dtool' , wp1dtool;
    case 'cw1dtool' , cw1dtool;
    case 'cwimtool' , cwimtool;
    case 'dw2dtool' , dw2dtool;
    case 'wp2dtool' , wp2dtool;
    case 'wvdtool'  , wvdtool;
    case 'wpdtool'  , wpdtool;
    case 'sw1dtool' , sw1dtool;
    case 'de1dtool' , de1dtool;
    case 're1dtool' , re1dtool;
    case 'cf1dtool' , cf1dtool;
    case 'sw2dtool' , sw2dtool;
    case 'cf2dtool' , cf2dtool;
    case 'sigxtool' , sigxtool;
    case 'imgxtool' , imgxtool;
    case 'wfbmtool' , wfbmtool;
    case 'wfustool' , wfustool;
    case 'nwavtool' , nwavtool;
    case 'wlifttool' , wlifttool;
end
mousefrm(0,'arrow');
%-------------------------------------------------------------------
% --- Executes on button press in Pus_Close_Win.
function Pus_Close_Win_Callback(hObject, eventdata, handles)

% Closing all opened main analysis windows.
%------------------------------------------
fig = gcbf;
wfigmngr('close',fig);

% Closing the wavemenu window.
%-----------------------------
try, delete(fig); end
mextglob('clear');
wtbxmngr('clear');
mousefrm(0,'arrow');
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles,varargin)

% Check for first call.
%----------------------
LstMenusInFig  = findall(get(hObject,'Children'),'flat','type','uimenu');
lstLabelsInFig = get(LstMenusInFig,'label');
idxMenuFile = strmatch('&File',lstLabelsInFig);
extendFLAG = isempty(idxMenuFile);

nbIN = length(varargin);
switch nbIN
    case 0 , 
    case 1
        winAttrb = varargin{1};
        if ~ischar(winAttrb) | isempty(winAttrb) 
        elseif strcmp(winAttrb(1),'m') ,  winAttrb = 'mono';
        elseif strcmp(winAttrb,'pref') ,  winAttrb = [];
        end
    otherwise
        error('Too many input arguments.')
end

if ~wtbxmngr('is_on') , wtbxmngr('ini'); end
if nbIN>0
    if ~(isempty(winAttrb) & mextglob('is_on'))
        mextglob('pref',winAttrb);
    end
else
    if ~mextglob('is_on') , mextglob('ini',[]); end
end

if extendFLAG
    wfigmngr('extfig',hObject,'ExtMainFig_WTBX');
    redimfig('On',hObject,[0.95 1.1],'left');
end

% Set CLOSE functions.
%---------------------
set(hObject,'CloseRequestFcn',@Pus_Close_Win_Callback)
LstMenusInFig  = findall(hObject,'type','uimenu');
lstLabelsInFig = get(LstMenusInFig,'label');
idxMenuClose = strmatch('&Close',lstLabelsInFig);
hMenu_Close = LstMenusInFig(idxMenuClose); 
set(hMenu_Close,'Callback',@Pus_Close_Win_Callback)

% Set the colors in the figure.
%------------------------------
Def_FraBkColor = mextglob('get','Def_FraBkColor');
set(hObject,'Color',Def_FraBkColor);
% % Or light gray
% %--------------
% LstFrameInFig  = findall(hObject,'style','frame');
% LstTextInFig  = findall(hObject,'style','text');
% Def_FigColor = mextglob('get','Def_FigColor');
% set(hObject,'Color',Def_FigColor);
% set([LstFrameInFig;LstTextInFig],'BackGroundColor',Def_FigColor);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%
