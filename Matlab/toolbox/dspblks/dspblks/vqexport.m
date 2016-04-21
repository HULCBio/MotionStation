function varargout = vqexport(varargin)
% VQEXPORT M-file for vqexport.fig

% Copyright 1988-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:17:56 $ 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vqexport_OpeningFcn, ...
                   'gui_OutputFcn',  @vqexport_OutputFcn, ...
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

%-------------------------------------------------------------------------
function vqexport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vqexport (see VARARGIN)

% Choose default command line output for vqexport
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

%%%%Initialization
ud_E=get(hObject,'UserData');
ud_E.hMainFigParent = varargin{1};
ud = get(ud_E.hMainFigParent, 'UserData');
ud_E.outputVarName = ud.outputVarName;
%ud_E.exportOverwrite = ud.exportOverwrite;
ud_E.orginalParentName = get(ud_E.hMainFigParent,'Name');
set(hObject,'UserData',ud_E);

% pop up export window with previous setting
ud= get(ud_E.hMainFigParent,'UserData');
set(handles.popupExportTo,'Value',ud.exportTOpopup);
set(handles.editFinalCB,'String',ud.outputVarName{1});
set(handles.editError,  'String',ud.outputVarName{2});
set(handles.editEntropy,'String',ud.outputVarName{3});
set(handles.checkboxExportOverwrite,'Value',ud.exportOverwrite);
set(ud.hTextStatus,'ForeGroundColor','Black');  set(ud.hTextStatus,'String','Ready');

popupExportToVisEna(ud.exportTOpopup,handles);
%%%%End of Initialization

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap

% Make the GUI modal
set(handles.vqexport,'WindowStyle','modal')%'modal'

% UIWAIT makes vqexport wait for user response (see UIRESUME)
uiwait(handles.vqexport);

%-------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = vqexport_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.vqexport);

%-------------------------------------------------------------------------
function pushbutnApply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud_E=get(handles.vqexport,'UserData');
ud = get(ud_E.hMainFigParent,'UserData');
ud.outputVarName = ud_E.outputVarName;
ud.exportTOpopup = get(handles.popupExportTo,'Value');
ud.exportOverwrite = get(handles.checkboxExportOverwrite,'Value');
closing_status=vqaction(ud); 
if (closing_status)
    % if it does the right job, only then 
    %(1) make it disable, 
    %(2) save export window outlook in ud
    %(3) save dirty/clean name of main fig (for cancle button)
    setenableprop([handles.pushbutnApply], 'off');
    set(ud_E.hMainFigParent,'UserData',ud);
    % (for the cancel button) update the original fig title
    ud_E.orginalParentName = get(ud_E.hMainFigParent,'Name');
    set(handles.vqexport,'UserData',ud_E);
    %uiresume(handles.vqexport);     
end

%-------------------------------------------------------------------------
function pushbutnOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%spec: apply button: when export window is opened it is always Enable
%      you press apply, if variables exists and non-overwrite,
%                       you get status message, the export window outlook is NOT saved in ud
ud_E=get(handles.vqexport,'UserData');
ud = get(ud_E.hMainFigParent,'UserData');

if strcmpi(get(handles.pushbutnApply,'Enable'),'on')
	ud.outputVarName = ud_E.outputVarName;
	ud.exportTOpopup = get(handles.popupExportTo,'Value');
	ud.exportOverwrite = get(handles.checkboxExportOverwrite,'Value');
	
	closing_status=vqaction(ud); 
	
	% Use UIRESUME instead of delete because the OutputFcn needs
	% to get the updated handles structure.
	if (closing_status)
        set(ud_E.hMainFigParent,'UserData',ud);
        %pause(1);set(ud.hTextStatus,'String','Ready');
        uiresume(handles.vqexport);  % close export window  
	end
else
    % apply button has already been pressed, so there (in applybutn callback), 
    % export window outlook has been saved in ud), so no need to save ud here
    set(ud.hTextStatus,'ForeGroundColor','Black'); set(ud.hTextStatus,'String','Ready');
    uiresume(handles.vqexport); % close export window
end    

%-------------------------------------------------------------------------    
function pushbutnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud_E=get(handles.vqexport,'UserData');
ud = get(ud_E.hMainFigParent,'UserData');
% set(handles.editFinalCB,'String',ud.outputVarName{1});
% set(handles.editError,'String',ud.outputVarName{2});
% set(handles.editEntropy,'String',ud.outputVarName{3});
% set the original figure state to its original one
set(ud_E.hMainFigParent,'Name',ud_E.orginalParentName);
set(ud.hTextStatus,'ForeGroundColor','Black'); set(ud.hTextStatus,'String','Ready');
% handles.output = get(hObject,'String');

% Update handles structure
% guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.vqexport);

%-------------------------------------------------------------------------  
function vqexport_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to vqexport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.vqexport, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    pushbutnCancel_Callback(handles.pushbutnCancel, eventdata, handles);
else
    % The GUI is no longer waiting, just close it
    delete(handles.vqexport);
end

%-------------------------------------------------------------------------
function vqexport_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to vqexport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    pushbutnCancel_Callback(handles.pushbutnCancel, eventdata, handles);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    pushbutnOK_Callback(handles.pushbutnOK, eventdata, handles);
end    

%-------------------------------------------------------------------------
function popupExportTo_Callback(hObject, eventdata, handles)
% hObject    handle to popupExportTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ud_E=get(handles.vqexport,'UserData');
vqmake_fig_dirty(ud_E.hMainFigParent); 
setenableprop([handles.pushbutnApply], 'on');

val = get(hObject,'Value');
popupExportToVisEna(val,handles);

%-------------------------------------------------------------------------
function popupExportToVisEna(val,handles)
	if (val==1)%% workspace
		setenableprop([handles.textFinalCB   handles.editFinalCB],    'on');
        setenableprop([handles.textError     handles.editError],      'on');
        setenableprop([handles.textEntropy   handles.editEntropy],    'on');
        setenableprop([handles.checkboxExportOverwrite],      'on');
	elseif (val==2)%% text-file
		setenableprop([handles.textFinalCB   handles.editFinalCB],    'off');
        setenableprop([handles.textError     handles.editError],      'off');  
        setenableprop([handles.textEntropy   handles.editEntropy],    'off');
        setenableprop([handles.checkboxExportOverwrite],      'off'); 
	elseif (val==3)%% mat-file
		setenableprop([handles.textFinalCB   handles.editFinalCB],    'on');
        setenableprop([handles.textError     handles.editError],      'on'); 
        setenableprop([handles.textEntropy   handles.editEntropy],    'on');
        setenableprop([handles.checkboxExportOverwrite],      'off');    
	end    

%-------------------------------------------------------------------------
function editFinalCB_Callback(hObject, eventdata, handles)
% hObject    handle to editFinalCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vqVerifyVariableName(hObject, 1, handles.vqexport, handles.pushbutnApply);

%-------------------------------------------------------------------------
function editError_Callback(hObject, eventdata, handles)
% hObject    handle to editError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vqVerifyVariableName(hObject, 2, handles.vqexport,handles.pushbutnApply);

%-------------------------------------------------------------------------
function editEntropy_Callback(hObject, eventdata, handles)
% hObject    handle to editEntropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vqVerifyVariableName(hObject, 3, handles.vqexport,handles.pushbutnApply);

%-------------------------------------------------------------------------
function vqVerifyVariableName(hEditBox, indx, hFig, hApplyButn)
ud_E=get(hFig,'UserData');
newName     = get(hEditBox, 'String');

% Make sure that the new variable name is valid
if isvarname(newName) & ~isreserved(newName, 'm'),
    ud_E.outputVarName{indx} = newName;
    %save user data
    set(hFig,'UserData',ud_E); 
    %make the parent fig dirty
    vqmake_fig_dirty(ud_E.hMainFigParent); 
    setenableprop(hApplyButn, 'on');
else
    
    % If the new variable name is not valid set it (previous valid one) back and error
    set(hEditBox, 'String', ud_E.outputVarName{indx});
    
    if isreserved(newName, 'm'),
        endstr = ' is a reserved word in MATLAB.';
    else
        endstr = ' is not a valid variable name.';
    end
    errorString = strcat(newName , endstr);
    errordlg(errorString);
end

%-------------------------------------------------------------------------
function checkboxExportOverwrite_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxExportOverwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ud_E=get(handles.vqexport,'UserData');

% make parent fig dirty
vqmake_fig_dirty(ud_E.hMainFigParent); 
setenableprop([handles.pushbutnApply], 'on');

% [EOF]




