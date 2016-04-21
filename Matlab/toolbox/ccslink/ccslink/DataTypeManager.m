function varargout = DataTypeManager(varargin)
% DATATYPEMANAGER UI manager of data types in CCSDSP object
% DATATYPEMANAGER(CC) accepts a CCSDSP object and opens an window for
%   exploring and accessing the data types stored in the CCSDSP object's
%   TYPE property (cc.type).
% CC2 = DATATYPEMANAGER(CC) same as above except it returns the CCSDSP
%   object that has been modified. Note: CC and CC2 are equivalent.
% Functions that can be done through GUI include viewing existing data type
%   entries, adding/removing data type entries, and saving/loading GUI
%   sessions. Note: Viewing/adding/removing data type entries can be done
%   through the MATLAB command line by using the following CC.TYPE methods:
%   gettypeinfo, add, clear.
%
% See also GETTYPEINFO, ADD, CLEAR.

% Last Modified by GUIDE v2.5 20-Dec-2002 13:36:47
% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/08 20:47:19 $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataTypeManager_OpeningFcn, ...
                   'gui_OutputFcn',  @DataTypeManager_OutputFcn, ...
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

% -----------------------------------------------
% --- Executes just before DataTypeManager is made visible.
function DataTypeManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataTypeManager (see VARARGIN)

% Additional 'handles' members
handles.willSave=0;
len_args = length(varargin);
if len_args==0
    error('The DataTypeManager requires a CCSDSP object input.');
else
    if ~(any(ishandle(varargin{1})) && isa(varargin{1},'ccs.ccsdsp'))
        error('The DataTypeManager requires a CCSDSP object input.');
    end
end
[handles.cc,handles.passCCObj,handles.text] = CC_ErrorCheck(varargin,len_args);
handles.typelist = handles.cc.type.typelist;

% Choose default command line output for DataTypeManager
handles.output = handles.cc;

% Do a refresh before starting
refreshList(hObject, handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataTypeManager wait for user response (see UIRESUME)
% uiwait(handles.DataTypeInspectorGUI);

% -----------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = DataTypeManager_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

% -----------------------------------------------
% --- Executes on button press in saveSession.
function [willSave,saveFile] = saveSession_Callback(hObject, eventdata, handles)
orig_path = pwd;
cd(handles.cc.cd); % cd to where project resides
% Ask user for an m-file
[filename, pathname] =  uiputfile('*.m','Save as'); %,['Load Program Files - ' targetName]);
cd(orig_path);
% Check if nothing was selected
if isnumeric(filename) && filename==0
    willSave = 0;
    saveFile = '';
    return
end
% Always default to .m
[pathstr,name,ext] = fileparts(filename);
if isempty(ext)
    filename = [filename '.m'];
end
% Open m-file
handles.willSave=1;
handles.saveFile = struct('path',pathname,'filename',filename,'fid',[]);
handles.saveFile.fid = fopen([handles.saveFile.path '\' handles.saveFile.filename],'w+');
% Save script to m-file
if handles.passCCObj
    fprintf(handles.saveFile.fid,'%s\n\n',['function ' strrep(handles.saveFile.filename,'.m','') '(cc)']);
else
    fprintf(handles.saveFile.fid,'%s\n\n',['function cc = ' strrep(handles.saveFile.filename,'.m','')]);
end
guidata(hObject,handles);
% Return info (hack) - 'willSave' & 'saveFile' values are not stored even after 
% call to saveSession_Callback (when called by 'close')
willSave = handles.willSave;
saveFile= handles.saveFile;

% -----------------------------------------------
% --- Executes on button press in loadSession.
function loadSession_Callback(hObject, eventdata, handles)
orig_path = pwd;
cd(handles.cc.cd); % cd to where project resides
% Ask user for m-file (contains session)
[filename, pathname] =  uigetfile('*.m'); %,['Load Program Files - ' targetName]);
cd(orig_path);
% Check if nothing was selected
if isnumeric(filename) && filename==0
    return
end
% Always default to .m
[pathstr,name,ext] = fileparts(filename);
if ~isempty(ext)
    filename = strrep(filename,'.m','');
end
% Open and run m-file
try 
    cd(pathname)
    % handles.cc = ccsdsp('boardnum',handles.cc.boardnum,'procnum',handles.cc.procnum);
    try 
        % 2 versions of the sessions
        % try
            % cc is passed
            feval(filename,handles.cc);
            % Text for session
            handles.text = horzcat(handles.text, ...
                {[''                                        ]},...
                {['% Load typedef session - ' filename '.m' ]},...
                {['origPath = cd(''' pathname ''');'        ]},...
                {[filename '(cc);'                          ]},...
                {[''                                        ]});
        % Commenting second version of session-loading
		% catch
		%     % cc is created - this overwrites what you have previously
		%     % added/removed
		%     proceedload = questdlg(['Loading ''' filename ''' will overwrite any changes you peviously ',...
		%             'applied to the CCSDSP object. Do you want to proceed?']);
		%     if strcmp(proceedload,'Yes')
		%         handles.cc = feval(filename);
		%         % Text for session
		%         handles.text = horzcat(handles.text, ...
		%             {[''                                                           ]},...
		%             {['% Load typedef session - ' filename '.m'                    ]},...
		%             {['% Warning: This will overwrite previous changes to cc.type' ]},...                    
		%             {['origPath = cd(''' pathname ''');'                           ]},...
		%             {['cc = ' filename ';'                                         ]},...
		%             {[''                                                           ]});
		%     else
		%         return;
		%     end
        % end
        cd(orig_path);
        refreshList(hObject,handles);
        guidata(hObject,handles);
        
    catch
        errordlg(sprintf(['A problem occurred while loading ''' filename ''':\n\n',...
                lasterr]),'Load session error','modal');
    end
catch
    errordlg(lasterr,'File not loaded','modal');
end

% -----------------------------------------------
% --- Executes on button press in refreshList.
function refreshList_Callback(hObject, eventdata, handles)
handles.text = horzcat(handles.text, {['% List is refreshed - any changes made on CC' ...
            'in the MATLAB workspace will get reflected on the gui (not on this file)']});
refreshList(hObject, handles);

% -----------------------------------------------
% --- Executes on button press in addTypedef.
function addTypedef_Callback(hObject, eventdata, handles)
dataTypeList(handles.cc,'new-typedef',handles); % must return cc or cc.type

% -----------------------------------------------
% --- Executes on button press in removeTypedef.
function removeTypedef_Callback(hObject, eventdata, handles)
% contents = get(handles.TypeEqvPairList,'String');
val = get(handles.TypeEqvPairList,'Value');
if IsEqvPairListEmpty(handles.TypeEqvPairList,val)
    return; % nothing to remove
else
    typedefName = handles.cc.type.typename{val};
    clear(handles.cc.type,typedefName);
    handles.text = horzcat(handles.text, {['clear(cc.type,''',typedefName,''');']});
    guidata(hObject,handles);
    refreshList(hObject, handles);
end

% -----------------------------------------------
% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% Check if user wants to save session
if handles.willSave==0
    willSave = questdlg('Do you want to save the entire session before closing?','Save session');
    if strcmpi(willSave,'Yes')
        % Ask for file to save changes to
        [handles.willSave,handles.saveFile] = ...
        saveSession_Callback(handles.saveSession, 0, handles);
    elseif strcmpi(willSave,'Cancel')
        % Do not close gui
        return;
    else 
        % No - proceed and close gui
    end
end
% Save session and close file
if handles.willSave==1
	for i=1:length(handles.text)
        fprintf(handles.saveFile.fid,'%s\n',handles.text{i});
	end
	fprintf(handles.saveFile.fid,'\n%s',['% [EOF] ' handles.saveFile.filename]);
	fclose(handles.saveFile.fid);
end
% Close gui
delete(handles.DataTypeInspectorGUI)

% -----------------------------------------------
% --- Executes during object creation, after setting all properties.
function TypeEqvPairList_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% -----------------------------------------------
% --- Executes on selection change in TypeEqvPairList.
function TypeEqvPairList_Callback(hObject, eventdata, handles)
selectionType = get(handles.DataTypeInspectorGUI,'selectionType');
if strcmp(selectionType,'open') % double-click
    TypeEqvPairList = get(hObject,'String');
	val = get(hObject,'Value');
    if IsEqvPairListEmpty(hObject,val)
        return;
    end
	dataTypeList(handles.cc,'edit-typedef',handles,TypeEqvPairList{val}); % must return cc or cc.type
	refreshList(handles.refreshList, handles);
end

% -----------------------------------------------
% --- a) Checks passed input parameter CCObj.
% --- b) Creates a CCSDSP object if not passed.
function [cc,passCCObj,text] = CC_ErrorCheck(args,len)
if len==1
	if ~ishandle(args{1})
        error(generateccsmsgid('InvalidHandle'),'First parameter must be a valid CCSDSP handle.');
	elseif length(args{1})>1
        error(generateccsmsgid('InvalidInput'),'First parameter must be a single-element CCSDSP handle.');
	else
        cc = args{1};
        passCCObj = 1;
        text = [];
	end
elseif len==0
    [bn,pn] = boardprocsel;
    if isempty(bn) || isempty(bn)
        error(generateccsmsgid('NoBoardProcSpecified'),'No boardnum or procnum is specified.');
    end
    try
        cc = ccsdsp('boardnum',bn,'procnum',pn);
        passCCObj = 0;
        text{1} = ['% Create CCSDSP object'];
        text{2} = ['cc = ccsdsp(''boardnum'',' num2str(bn) ',''procnum'',' num2str(pn) ');'];
    catch
        error(generateccsmsgid('CannotCreateHandle'),'Cannot create a CCSDSP handle.');
    end
else
    error(generateccsmsgid('CannotOpenGUI'),'Cannot open Data Type Manager - incorrect number input parameters.');
end

% ------------------------------------------
function resp = IsEqvPairListEmpty(hObject,val)
resp = 0;
TypeEqvPairList = get(hObject,'String');
if nargin==1
    val = get(hObject,'Value');
end
if isempty(val) || (val<=1 && isempty(TypeEqvPairList{1})),
    resp = 1;
end

% [EOF] DataTypeManager.m
