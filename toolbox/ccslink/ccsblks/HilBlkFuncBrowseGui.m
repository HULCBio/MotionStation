function varargout = HilBlkFuncBrowseGui(varargin)
% HILBLKFUNCBROWSEGUI M-file for HilBlkFuncBrowseGui.fig

% Copyright 2003-2004 The MathWorks, Inc.

% Last Modified by GUIDE v2.5 17-Jan-2003 16:51:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HilBlkFuncBrowseGui_OpeningFcn, ...
                   'gui_OutputFcn',  @HilBlkFuncBrowseGui_OutputFcn, ...
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

% ---------------------------------------------
function HilBlkFuncBrowseGui_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Executes just before HilBlkFuncBrowseGui is made visible.

% Update handles structure
guidata(hObject, handles);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% Default output 
% Output will be empty unless user clicks "OK"
handles.output = '';

% Update handles structure
guidata(hObject, handles);

set(hObject,'Name','List of functions on target CPU');

% Set up listbox
s = get(hObject,'UserData');
blk = s.blk;
PDATA = HilBlkPersistentData(blk,'get');
errFlag = false;
if PDATA.ccsObjStale,
    try
        HilBlkGetCcsHandle(blk);
    catch
        errFlag = true;
        uiwait(errordlg(lasterr, ...
            'Error in HIL Function Call Block','modal'));
    end
    PDATA = HilBlkPersistentData(blk,'get');
end
if ~errFlag,
    s.funcList = PDATA.ccsObj.list('function');
    s.funcListCell = fieldnames(s.funcList);
    set(handles.funcBrowseListboxTag,'string',s.funcListCell);
    
    % Store "s" structure in gui
    set(hObject,'UserData',s);
end
    
% UIWAIT makes HilBlkFuncBrowseGui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% ---------------------------------------------
function varargout = HilBlkFuncBrowseGui_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.

% Get output from handles structure
if isfield(handles,'output'),
    varargout{1} = handles.output;
else
    varargout{1} = '';
end

% The figure can be deleted now
delete(handles.figure1);


% ---------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% --- Executes when user attempts to close figure1.
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


% ---------------------------------------------
function figure1_KeyPressFcn(hObject, eventdata, handles)
% --- Executes on key press over figure1 with no controls selected.

% ---------------------------------------------
function funcBrowseListboxTag_Callback(hObject, eventdata, handles)
% --- Executes on selection change in funcBrowseListboxTag.

% ---------------------------------------------
function okButtonTag_Callback(hObject, eventdata, handles)
% --- Executes on button press in okButtonTag.

% Get output string
s = get(handles.figure1,'UserData');
v = get(handles.funcBrowseListboxTag,'value');
if isfield(s,'funcListCell') && ~isempty(s.funcListCell),
    handles.output = s.funcListCell{v};
else
    handles.output = '';
end

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% ---------------------------------------------
function funcBrowseListboxTag_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
set(hObject,'BackgroundColor','white');

