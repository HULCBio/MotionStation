function varargout = demoguimwin(varargin)
% DEMOGUIMWIN M-file for demoguimwin.fig
%      DEMOGUIMWIN, by itself, creates a new DEMOGUIMWIN or raises the existing
%      singleton*.
%
%      H = DEMOGUIMWIN returns the handle to a new DEMOGUIMWIN or the handle to
%      the existing singleton*.
%
%      DEMOGUIMWIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMOGUIMWIN.M with the given input arguments.
%
%      DEMOGUIMWIN('Property','Value',...) creates a new DEMOGUIMWIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before demoguimwin_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to demoguimwin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help demoguimwin

% Last Modified by GUIDE v2.5 04-Sep-2003 16:09:40
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 09-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/15 22:37:02 $

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demoguimwin_OpeningFcn, ...
                   'gui_OutputFcn',  @demoguimwin_OutputFcn, ...
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
% --- Executes just before demoguim is made visible.                      %
%*************************************************************************%
function demoguimwin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to demoguimwin (see VARARGIN)

% Choose default command line output for demoguimwin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes demoguimwin wait for user response (see UIRESUME)
% uiwait(handles.Guim_Tool);

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
function varargout = demoguimwin_OutputFcn(hObject, eventdata, handles)
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
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles,varargin)

wfigmngr('extfig',hObject,'Empty');
nbIN = length(varargin);
init = 0;
switch nbIN
    case 0 , 
        option = 'create';
    case 1
        option = varargin{1};
        if ~ischar(option)
            winAttrb = option; init = 1; option = 'create';
        elseif isempty(option)
            winAttrb = [];     init = 1; option = 'create';
        elseif strcmp(option(1),'m')
            winAttrb = 'mono'; init = 1; option = 'create';
        elseif strcmp(option,'pref')
            winAttrb = [];     init = 1; option = 'create';
        end
    otherwise
        option = varargin{1};
        winAttrb = varargin{2};
        if ~strcmp(option,'close') , init = 1; option = 'create'; end
end

switch option
    case 'create'
        if ~wtbxmngr('is_on') , wtbxmngr('ini'); end
        if init
            if ~(isempty(winAttrb) & mextglob('is_on'))
                mextglob('pref',winAttrb);
            end
        else
            if ~mextglob('is_on') , mextglob('ini',[]); end
        end
end
if isequal(init,0)
    redimfig('On',hObject,[0.95 1.1],'left');
end
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%
