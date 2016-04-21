function varargout = ccsinspect(varargin)
% CCSINSPECT  GUI Inspector of embedded functions and variables.
%   CCSINSPECT opens a window for exploring the variables and functions of
%   an embedded target loaded into Code Composer Studio(R).  All available
%   variables and functions are automatically listed.  The user can select
%   from this list and export a MATLAB object that represents the embedded
%   entity.  The resulting MATLAB object can be applied for direct
%   interaction between MATLAB and the embedded variable or function.
%
%   To run CCSINSPECT from MATLAB, type 'ccsinspect' at the command
%   prompt.
%
%   See also: CCSDSP, CREATEOBJ

% $Revision: 1.14.6.5 $ $Date: 2004/04/08 20:45:33 $
% Copyright 2002-2004 The MathWorks, Inc.
% Last Modified by GUIDE v2.5 16-Jan-2004 14:24:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ccsinspect_OpeningFcn, ...
                   'gui_OutputFcn',  @ccsinspect_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ccsinspect is made visible.
function ccsinspect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ccsinspect
handles.output = hObject;
handles.boardnum =0;
handles.procnum =0;
handles.cc = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ccsinspect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ccsinspect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%*******************************************
% --- Executes during object creation, after setting all properties.
function FunctionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FunctionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in FunctionList.
function FunctionList_Callback(hObject, eventdata, handles)
% hObject    handle to FunctionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns FunctionList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FunctionList

% This disables the Function list highlight

set(handles.VariableList,'Max',2);
set(handles.VariableList,'Value',[]);

%Change the Address to reflect the new value
faddr = get(handles.FunctionList,'UserData');
findex = get(handles.FunctionList,'Value');

if ~isempty(findex),
    %only select the first element if multiples are highlighted
    set(handles.Address,'String',faddr{findex(1)});
end
%********************************************



% --- Executes during object creation, after setting all properties.
function VariableList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VariableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in VariableList.
function VariableList_Callback(hObject, eventdata, handles)
% hObject    handle to VariableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns VariableList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VariableList

% This disables the Function list highlight
set(handles.FunctionList,'Max',2);
set(handles.FunctionList,'Value',[]);

%Change the Address to reflect the new value
vaddr = get(handles.VariableList,'UserData');
vindex = get(handles.VariableList,'Value');

% get selected variable
AllVars = get(handles.VariableList,'String');

if ~isempty(vindex),
    %only select the first element if multiples are highlighted
    set(handles.Address,'String',vaddr{vindex(1)});
%     selvar = AllVars(vindex);
%     set(handles.Variable,'string',selvar{:});
%     cc = handles.cc;
%     Varobj = cc.createobj(selvar{:});
%     VarobjValue = Varobj.read(1:Varobj.size);
%     if Varobj.size > 1
%         set(handles.VarValue,'string',['[' num2str(VarobjValue) ']']);
%     else
%         set(handles.VarValue,'string',num2str(VarobjValue));
%     end
end

% --- Executes on button press in makeLink.
function makeLink_Callback(hObject, eventdata, handles)
% hObject    handle to makeLink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% try
%     % save workspace for future reload
%     evalin('base',['save(''' tempdir 'origWS.mat'')']);
% catch
%     warning('This demo could clear out your workspace variables, please save it first!');
% end

boardnum = get(handles.BoardNumEdit,'Userdata');
procnum = get(handles.ProcNumEdit,'Userdata');
set(handles.BoardName,'String',' Standby - Loading Code Composer!');
try
    cc = ccsdsp('boardnum',boardnum,'procnum',procnum);
catch
    errordlg(lasterr,'Code Composer Studio (R) Link Failure','modal');
    return;
end

procname = getproc(cc);
if  ~any(strcmp(procname,{'c67x','c62x','c64x','c6x','c54x','c55x','r1x','r2x','c28x'})) % supported procs
    errormsg = ['Demo does not support ' procname '. Please select another processor.'];
    errordlg(errormsg,'Processor Not Supported','modal');
    clear cc;
    return;
end
   
handles.cc = cc;
guidata(hObject, handles);
set(handles.VariableList,'enable','on');
set(handles.FunctionList,'enable','on');
set(handles.InspectPropButton,'enable','on');
set(handles.obj2workspace,'enable','on');
set(handles.Slide,'enable','on');
set(handles.ccsVisible,'enable','on');
set(handles.LinkRefresh,'enable','on');
set(handles.TargetProgramTitle,'enable','on');
set(handles.BoardNameTitle,'enable','on');
set(handles.ProcNameTitle,'enable','on');
set(handles.LoadProgram,'enable','on');

set(handles.BoardNumEdit,'enable','off');
set(handles.ProcNumEdit,'enable','off');
set(handles.boardSelectButton,'enable','off');
set(hObject,'enable','off');


if isvisible(cc),
    set(handles.ccsVisible,'Value',1);   
else
    set(handles.ccsVisible,'Value',0);
end
% Set board,proc name 
set(handles.BoardName,'String',cc.info.boardname);
set(handles.ProcName,'String',cc.info.procname);
LinkRefresh_Callback(handles.LinkRefresh,0,handles);


% --- Executes on button press in LinkRefresh.
function LinkRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to LinkRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Enable everyone!!
cc = handles.cc;
if cc.info.subfamily >= 96,  % 6x family
    numNibbles = 8;
else     % 5x family
    numNibbles = 4;
end
% retrieve ALL variables
v = cc.list('variable-short');
vname = fieldnames(v);
vnamecell = [];
vaddr = [];
for i=1:length(vname),
   vnamecell{i} = v.(vname{i}).name;
   if ~strcmp( vnamecell{i}, vname{i} ),
       vnamecell{i} = [ vnamecell{i} ' (' vname{i} ')' ];
   end
   if ischar(v.(vname{i}).location(1)),
      vaddr{i} = 'Register';
   else
      vaddr{i} = dec2hex(v.(vname{i}).location(1),numNibbles);
   end
end
%  Configure list of names in listbox for variables (and preserve addresses
%  in UserData)
set(handles.VariableList,'String',vnamecell,'UserData',vaddr);
if isempty(vnamecell),
    set(handles.VariableList,'Value',[]);    
else
    set(handles.VariableList,'Value',1);
end    
if ~isempty(vaddr)
    set(handles.Address,'String',vaddr{1});
end


%****************************************************
% retrieve ALL functions
f = cc.list('function-short');
fname = fieldnames(f);
fnamecell = [];
faddr = [];
for i=1:length(fname),
   fnamecell{i} = f.(fname{i}).name;
   if ~strcmp( fnamecell{i}, fname{i} ),
       fnamecell{i} = [ fnamecell{i} ' (' fname{i} ')' ];
   end
   if ischar(f.(fname{i}).location(1)),
      faddr{i} = f.(fname{i}).location;
   else
      faddr{i} = dec2hex(f.(fname{i}).location(1),numNibbles);
   end   
end
%  Configure list of names in listbox for variables 
%  Also disable highlighted section
set(handles.FunctionList,'String',fnamecell,'UserData',faddr);
set(handles.FunctionList,'Max',2);
set(handles.FunctionList,'Value',[]);
%**************************************************************


% retrieve name of last file loaded
% dspboards = get(actxserver('CodeComposer.Application'),'DspBoards');
% pgFile = invoke(invoke(invoke(get(invoke(dspboards,'Item',cc.boardnum),'DspTasks'),'Item',cc.procnum),'CreateDspUser'),'GetFileLoaded');
% clear dspboards;
pgFile = p_getProgLoaded(cc);

if isempty(pgFile),
    set(handles.fileNametext,'String','--- No file loaded ---');
else
    [pd,pf,pe] = fileparts(pgFile);
    set(handles.fileNametext,'String',[pf pe]);
end

% This disables the Function list (we'll start in the variable list)


% --- Push selected object to Matlab workspace
function obj2workspace_Callback(hObject, eventdata, handles)
% hObject    handle to obj2workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fsel =  get(handles.FunctionList,'Value');
vsel =  get(handles.VariableList,'Value');
if ~isempty(vsel),
    vnamecell = get(handles.VariableList,'String');
    name = vnamecell{vsel(1)}; %only select the first element if multiples are highlighted
elseif ~isempty(fsel),    
    fnamecell = get(handles.FunctionList,'String');
    name = fnamecell{fsel(1)};%only select the first element if multiples are highlighted
else
    warning('Nothing selected for export to workspace!');
    return;
end
bracketindex = strfind( name,'(');
if ~isempty(bracketindex),  % Extract valid ML name for variable
     mlname = name(bracketindex+1:end-1);
     ccname = name(1:bracketindex-1);
else
     mlname = name;
     ccname = name;
end

procname = getproc(handles.cc);
if any(strcmp(procname,{'c55x','r1x','r2x'})) && ~isempty(fsel)
        errormsg = ['Function objects are not yet supported on the ' upper(procname) '.'];
    errordlg(errormsg,'Processor Not Supported','modal');
    return;
end

obj = handles.cc.createobj(ccname)
assignin('base',mlname,obj);

% --- Executes on button press in InspectPropButton.
function InspectPropButton_Callback(hObject, eventdata, handles)
% hObject    handle to InspectPropButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupInspector(hObject,handles);

% --- Popup inspector
function popupInspector(hObject,handles);
fsel =  get(handles.FunctionList,'Value');
vsel =  get(handles.VariableList,'Value');
if ~isempty(vsel),
    vnamecell = get(handles.VariableList,'String');
    %only select the first element if multiples are highlighted
    name = vnamecell{vsel(1)};
elseif ~isempty(fsel),
    fnamecell = get(handles.FunctionList,'String');
    %only select the first element if multiples are highlighted
    name = fnamecell{fsel(1)};
else
    warning('Nothing selected for inspection!');
    return;
end
bracketindex = strfind( name,'(');
if ~isempty(bracketindex),  % Extract valid ML name for variable
     mlname = name(bracketindex+1:end-1);
     ccname = name(1:bracketindex-1);
else
     mlname = name;
     ccname = name;
end     

procname = getproc(handles.cc);
if any(strcmp(procname,{'c55x','r1x','r2x'})) && ~isempty(fsel)
        errormsg = ['Function objects are not yet supported on the ' upper(procname) '.'];
    errordlg(errormsg,'Processor Not Supported','modal');
    return;
end

obj = handles.cc.createobj(ccname);
handles.obj = obj;
guidata(hObject, handles);
% uiwait
% assignin('base',mlname,obj);
inspect(handles.obj);
drawnow;
% uiresume

% --- Executes on button press in CloseButton.
function CloseButton_Callback(hObject, eventdata, handles)
cc = handles.cc;
if ~isempty(cc)
    boardnum = get(handles.BoardNumEdit,'Userdata');
    procnum = get(handles.ProcNumEdit,'Userdata');
    assignin('base','cc',cc);
    evalin('base',['cc = ccsdsp(''boardnum'',' num2str(boardnum) ',''procnum'',' num2str(procnum) ')']);
    close(handles.mainWindow);
else
    close(handles.mainWindow);
end
% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% try
%      cc = handles.cc;
%      cc.visible(0)
%      assignin('base','cc',cc);
%      evalin('base','clear all');
%      pause(1);
%      evalin('base',['load(''' tempdir 'origWS.mat'')']);
%      close(handles.mainWindow); 
% catch
%     close(handles.mainWindow); 
% end

% --- Executes during object creation, after setting all properties.
function BoardNumEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoardNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function BoardNumEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BoardNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BoardNumEdit as text
%        str2double(get(hObject,'String')) returns contents of BoardNumEdit as a double
%set(handles.FunctionList,'enable','off');
set(handles.VariableList,'enable','off');
oldbd = handles.boardnum;
newbdstr = get(hObject,'String');
newbdnum = eval(newbdstr,oldbd);
if newbdnum < 0, newbdnum = oldbd; end
newbdnum = round(newbdnum);
set(hObject,'Userdata',newbdnum,'String',num2str(newbdnum));


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function ProcNumEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProcNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function ProcNumEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ProcNumEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ProcNumEdit as text
%        str2double(get(hObject,'String')) returns contents of ProcNumEdit as a double
%set(handles.FunctionList,'enable','off');
set(handles.VariableList,'enable','off');
oldpr = handles.boardnum;
newprstr = get(hObject,'String');
newprnum = eval(newprstr,oldpr);
if newprnum < 0, newprnum = oldpr; end
newprnum = round(newprnum);
set(hObject,'Userdata',newprnum,'String',num2str(newprnum));


% --- Executes on button press in Slide.
function OpenProject_Callback(hObject, eventdata, handles)
% hObject    handle to Slide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetName = get(handles.BoardName,'String');
[filename, pathname] =  uigetfile('*.pjt',['Open Project Files - ' targetName]);
if ischar(filename) & ischar(pathname),
    try
        cc = handles.cc;
        cc.cd(pathname);
        handles.cc.open(fullfile(pathname, filename),'Project',30);
    catch
        errordlg('Failed during open, please select a valid project file','Project Open Failure');
        return;
    end
end

% --- Executes on button press in Load Program.
function LoadProgram_Callback(hObject, eventdata, handles)
% hObject    handle to Loadprogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    targetName = get(handles.BoardName,'String');
    orig_path = pwd;
    cd(handles.cc.cd); %where project resides
    [filename, pathname] =  uigetfile('*.out',['Load Program Files - ' targetName]);
    cd(orig_path);
    if ischar(filename) & ischar(pathname),
        try
            handles.cc.open(fullfile(pathname, filename),'Program',30);
        catch
            errordlg('Failed during load, please select a valid progarm file','Program Load Failure');
            return;
        end
        LinkRefresh_Callback(handles.LinkRefresh,0,handles);
    end    

% --- Executes on button press in boardSelectButton.
function boardSelectButton_Callback(hObject, eventdata, handles)
% hObject    handle to boardSelectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    [bdnum,prnum] = boardprocsel;
catch
    warndlg(...
    { 'Unable to run Board Selection Utility',...
      '[bdnum,prnum] = boardprocsel;',...
      'Board and Processor must be entered manually',...
      lasterr},'GUI Error');
end
if ~isempty(bdnum),
    set(handles.BoardNumEdit,'String',int2str(bdnum));
    set(handles.BoardNumEdit,'UserData',bdnum);
end
if ~isempty(prnum),
    set(handles.ProcNumEdit,'String',int2str(prnum));
    set(handles.ProcNumEdit,'UserData',prnum);
end

% --- Executes on button press in ccsVisible.
function ccsVisible_Callback(hObject, eventdata, handles)
cc = handles.cc;
nowState = isvisible(cc);
newState = get(hObject,'Value');
if nowState ~= newState,
  cc.visible(newState);
end

% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
msgbox(help('ccsinspect'),'Help');

