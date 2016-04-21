function varargout = HilBlkGui(varargin)
% HilBlkGui M-file for HilBlkGui.fig
% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 20:44:25 $

% Last Modified by GUIDE v2.5 03-Jul-2003 12:56:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HilBlkGui_OpeningFcn, ...
                   'gui_OutputFcn',  @HilBlkGui_OutputFcn, ...
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


%--------------------------------------------------------------
function HilBlkGui_OpeningFcn(hObject, eventdata, handles, varargin)
% Executes just before HilBlkGui is made visible.
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HilBlkGui (see VARARGIN)

% Choose default command line output for HilBlkGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Set up mapping from GUI to block
blk = gcb;
blkh = gcbh;
set(hObject,'UserData',blk);

% Display name of block at the top of the gui.
nm = get_param(blkh,'name');
nm2 = strrep(nm,sprintf('\n'),' ');
set(hObject,'name',['Block parameters: ' nm2]);
set(handles.argChooserListboxTag,'string','');

% Remove "Code generation" tab if Emb Target for TI C6000 DSP not installed
if ~exist('ti_c6000.tlc','file'),
    set(handles.codeGenerationTabButtonTag,'visible','off');
end

% Gray out entire gui if viewed from library
if strcmp(get_param(gcs,'blockdiagramtype'), 'library')
    setEnablesOnEntireGui(handles,'off');
    setVisForTargetSelectionTab(handles,  'off');
    setVisForFunctionInterfaceTab(handles,'on');
    set(handles.globVarNameEditBoxTag,'visible','off');
    set(handles.globVarNameTextTag,'visible','off');
    setVisForCodeGenerationTab(handles,   'off');
    return;  % No need to update the rest of the gui
end

% Make sure this block does not already have an open GUI
UDATA = get_param(blk,'UserData');
if ~isempty(UDATA.guiHandle) && ishandle(UDATA.guiHandle), 
    g = get(UDATA.guiHandle);
    if isfield(g,'Tag') && strcmp(g.Tag,'HilBlkFigureTag'),
        %  XXX     Gui already open; need to close new one
        %close(hObject);  % won't work because remainder of gui opening
        %                   is still to come...
        % set(prevHandle,'visible','on');
        %% So let's just close the old one and continue opening the new one.
        close(UDATA.guiHandle); 
    end
end

% Set up mapping from block to GUI
UDATA.guiHandle = hObject;
set_param(blk,'UserData',UDATA); % This does not make the model dirty

% Popuplate GUI with block param values
set(handles.funcNameEditBoxTag,'string',UDATA.funcName);
if isfield(UDATA,'includePaths') && ~isempty(UDATA.includePaths),
    set(handles.includePathsListboxTag,'string',UDATA.includePaths);
else
    set(handles.includePathsListboxTag,'string','[none]');
end
if ~isempty(UDATA.sourceFiles),
    set(handles.projFilesListboxTag,'string',UDATA.sourceFiles);
else
    set(handles.projFilesListboxTag,'string','[none]');
end
set(handles.specifyPrototypeCheckboxTag,'value',~UDATA.declAutoDetermined);
updateGuiForFunctionInfo(handles,blk);

if isfield(UDATA,'funcTimeout'),
    set(handles.timeoutEditBoxTag,'string',num2str(UDATA.funcTimeout));
else
    set(handles.timeoutEditBoxTag,'string','30');
end    
    
PDATA = HilBlkPersistentData(blk,'get');
if PDATA.ccsObjStale || PDATA.tgtFcnObjStale, 
    % Disable the params that depend on Query
    setEnablesOnAllQueryDependentParams(handles, 'off');
    % Don't gray out funcDecl edit box unless it was auto-determined
    if UDATA.declAutoDetermined,
        set(handles.funcDeclEditBoxTag,'enable','off');
        set(handles.funcDeclTextTag,'enable','off');
    else
        set(handles.funcDeclEditBoxTag,'enable','on');
        set(handles.funcDeclTextTag,'enable','on');
    end
end

% Tabs
setVisForTargetSelectionTab(handles,  'off');
setVisForFunctionInterfaceTab(handles,'off');
setVisForCodeGenerationTab(handles,   'off');
if ~isfield(UDATA,'lastSelectedTab'),
    UDATA.lastSelectedTab = 1;
    set_param(blk,'UserData',UDATA);
    set(handles.statusTextTag,'string', ...
        'Choose target board and click "Function Interface" tab to continue.');
end
switch UDATA.lastSelectedTab
    case 1,
        setVisForTargetSelectionTab(handles,  'on');
    case 2,
        setVisForFunctionInterfaceTab(handles,'on');
    case 3,
        setVisForCodeGenerationTab(handles,   'on');
end
set(handles.argChooserTextTag,'Enable','on'); % (usability request)

% BOARD/PROC
try 
    c = ccsboardinfo;
catch
    uiwait(errordlg('Error connecting to Code Composer Studio(R).', ...
        'Error in HIL Function Call Block','modal'));
    PDATA.ccsObjStale = true;
    PDATA.tgtFcnObjStale = true;
    HilBlkPersistentData(blk,'set',PDATA);
    return;
end
boardList = '';   % List of options for Board name popup
for k = 1:length(c),
    if k>1  
        boardList = [boardList '|'];  % Append | between choices
    end
    boardList = [boardList c(k).name];
end
set(handles.boardNamePopupTag,'string',boardList);
% If there is a previous board choice, make sure it is in the list.
if ~isempty(UDATA.boardName),
    boardIndex = HilBlkFindBoardOrProc(c,UDATA.boardName);
    if boardIndex==-1,
        msg = ['Could not find previously-chosen board; ' ...
                'the first board in the list will be selected.'];
        warning(msg)
        set(handles.statusTextTag,'string',msg);
        boardIndex = 1;
        PDATA = HilBlkPersistentData(blk,'get');
        PDATA.ccsObjStale = true;
        PDATA.tgtFcnObjStale = true;
        HilBlkPersistentData(blk,'set',PDATA);
    end
else
    boardIndex = 1;
end
if ~isequal(UDATA.boardName,c(boardIndex).name),
    UDATA.boardName = c(boardIndex).name;
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
end
set(handles.boardNamePopupTag,'value',boardIndex);

procList = '';
for k = 1:length(c(boardIndex).proc),
    if k>1  
        procList = [procList '|'];  % Append | between choices
    end
    procList = [procList c(boardIndex).proc(k).name];
end

set(handles.procNamePopupTag,'string',procList);

% If there is a previous proc choice, make sure it is in the list.
if ~isempty(UDATA.procName),
    procIndex = HilBlkFindBoardOrProc(c(boardIndex).proc,UDATA.procName);
    if procIndex==-1,
        msg = ['Could not find previously-chosen processor; ' ...
                'the first processor in the list will be selected.'];
        warning(msg)
        set(handles.statusTextTag,'string',msg);
        procIndex = 1;
        PDATA = HilBlkPersistentData(blk,'get');
        PDATA.ccsObjStale = true;
        PDATA.tgtFcnObjStale = true;
        HilBlkPersistentData(blk,'set',PDATA);
    end
else
    procIndex = 1;
end
if ~isequal(UDATA.procName, c(boardIndex).proc(procIndex).name),
    UDATA.procName = c(boardIndex).proc(procIndex).name;
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
end
set(handles.procNamePopupTag,'value',procIndex);



%--------------------------------------------------------------
function varargout = HilBlkGui_OutputFcn(hObject, eventdata, handles)
% Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   C A L L B A C K S  are located in separate files in private directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------
function okButtonTag_Callback(hObject, eventdata, handles)
okButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function helpButtonTag_Callback(hObject, eventdata, handles)
helpButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function targetSelectionTabButtonTag_Callback(hObject, eventdata, handles)
targetSelectionTabButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function functionInterfaceTabButtonTag_Callback(hObject, eventdata, handles)
functionInterfaceTabButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function codeGenerationTabButtonTag_Callback(hObject, eventdata, handles)
codeGenerationTabButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function queryButtonTag_Callback(hObject, eventdata, handles)
queryButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function manageDTypesButtonTag_Callback(hObject, eventdata, handles)
manageDTypesButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function functionBrowseButtonTag_Callback(hObject, eventdata, handles)
functionBrowseButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function funcNameEditBoxTag_Callback(hObject, eventdata, handles)
funcNameEditBoxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function specifyPrototypeCheckboxTag_Callback(hObject, eventdata, handles)
specifyPrototypeCheckboxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function funcDeclEditBoxTag_Callback(hObject, eventdata, handles);
funcDeclEditBoxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function argChooserListboxTag_Callback(hObject, eventdata, handles)
argChooserListboxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function portAssignPopupTag_Callback(hObject, eventdata, handles)
portAssignPopupCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function sizeEditBoxTag_Callback(hObject, eventdata, handles)
sizeEditBoxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function storageOptionPopupTag_Callback(hObject, eventdata, handles)
storageOptionPopupCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function addressEditBoxTag_Callback(hObject, eventdata, handles)
addressEditBoxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function globVarNameEditBoxTag_Callback(hObject, eventdata, handles)
globVarNameEditBoxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function boardNamePopupTag_Callback(hObject, eventdata, handles)
boardNamePopupCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function procNamePopupTag_Callback(hObject, eventdata, handles)
procNamePopupCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function projFilesListboxTag_Callback(hObject, eventdata, handles)
projFilesListboxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function addFileButtonTag_Callback(hObject, eventdata, handles)
addFileButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function removeFileButtonTag_Callback(hObject, eventdata, handles)
removeFileButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function includePathsListboxTag_Callback(hObject, eventdata, handles)
includePathsListboxCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function addIncludeButtonTag_Callback(hObject, eventdata, handles)
addIncludeButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function removeIncludeButtonTag_Callback(hObject, eventdata, handles)
removeIncludeButtonCallback(hObject, eventdata, handles);

%--------------------------------------------------------------
function timeoutEditBoxTag_Callback(hObject, eventdata, handles)
timeoutEditBoxCallback(hObject, eventdata, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%     C R E A T E - U I C O N T R O L    F U N C T I O N S 
% --- Executes during object creation, after setting all properties.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------
function funcNameEditBoxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function funcDeclEditBoxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function argChooserListboxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function sizeEditBoxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function portAssignPopupTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function storageOptionPopupTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function addressEditBoxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function boardNamePopupTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function procNamePopupTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function globVarNameEditBoxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function includePathsListboxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function projFilesListboxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');

%--------------------------------------------------------------
function timeoutEditBoxTag_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');




% EOF HilBlkGui.m
