function varargout = ccshildemo(varargin)
% CCSHILDEMO HIL demo.
%  CCSHILDEMO shows how you can use MATLAB to run a function that you have
%  implemented on a DSP target and verify if its results match that of your 
%  MATLAB simulation results. 
% 
%  The GUI shows three tab windows, each containing code for a) running the
%  MATLAB simulation, b) running the DSP function, and c) comparing the 
%  results obtained from the previous two steps. 
% 
%  There are test samples provided, each showing either a different
%  application or a different way of invoking the DSP Function Call part.
%
%  See also hiltutorial.

% Last Modified by GUIDE v2.5 24-Oct-2003 18:15:45
%   Copyright 2004 The MathWorks, Inc.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ccshildemo_OpeningFcn, ...
                   'gui_OutputFcn',  @ccshildemo_OutputFcn, ...
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

% --- Executes just before ccshildemo is made visible.
function ccshildemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for ccshildemo
handles.output = hObject;

% handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
handles.cc = [];
handles.runstep = 1;
handles.examples = {'Sine example 1','Sine wave example 1','Sine wave example 2',...
        'Filter example 1','Filter example 2',...
    };
handles.numdefaultexamples = length(handles.examples);
handles.numnewexamples = 0;
% Set-up pulldown menu for examples
set(handles.exampletag,'String',handles.examples);
set(handles.exampletag,'Value',1);
handles.lastval = 1;

if isempty(handles.cc)
    handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
end

% Default program/project files
handles = GetDefaultFiles(handles);
if isempty(handles.programfile)
    return
end
% set(handles.ccsprogramtag,'Enable','off');
% set(handles.ccsprojecttag,'Enable','off');
set(handles.loadprogramtag,'Enable','off');
set(handles.loadprojecttag,'Enable','off');

% Save default M code
[handles.examplecode,handles.funcname] = GetDefaultCode(handles);

% Display M code for first example
UpdateCode(handles,1);
set(handles.statustag,'String',handles.examples{1});
set(handles.dspfunctionname,'String',handles.funcname{1});

set(handles.runFirst,'Enable','on'); % disable/enable appropriate run buttons
set(handles.runSecond,'Enable','off');
set(handles.runThird,'Enable','off');
SetVisible(handles,'sim',1);
SetTabBold(handles,'sim');



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ccshildemo wait for user response (see UIRESUME)
% uiwait(handles.mainGUI);


% --- Outputs from this function are returned to the command line.
function varargout = ccshildemo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in exampletag.
function exampletag_Callback(hObject, eventdata, handles)
% Get example selected
val = get(hObject,'Value');
if val==handles.lastval
    return
end
% Ensures that listbox does not disappear when previous listbox value is
% larger than currently selected listbox height
set(handles.MATLABcodetag,'Value',1);
set(handles.DSPcodetag,'Value',1);
set(handles.Vercodetag,'Value',1);
%
if val<=handles.numdefaultexamples
    [handles,errstate] = GetDefaultFiles(handles);
    if errstate
        return
    end
    % comment out - bec. changing ccsprogramtag & ccsprojecttag to text
    % set(handles.ccsprogramtag,'Enable','off');
    % set(handles.ccsprojecttag,'Enable','off');
    set(handles.loadprogramtag,'Enable','off');
    set(handles.loadprojecttag,'Enable','off');
    set(handles.dspfunctionname,'String',handles.funcname{val});
else
    set(handles.ccsprogramtag,'Enable','on');
    set(handles.ccsprojecttag,'Enable','on');
    set(handles.loadprogramtag,'Enable','on');
    set(handles.loadprojecttag,'Enable','on');
end
% Change text if necessary
UpdateCode(handles,val);
set(handles.statustag,'String',handles.examples{val});
% Set this new val as the last activated val
handles.lastval = val;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in addexampletag.
function addexampletag_Callback(hObject, eventdata, handles)
% hObject    handle to addexampletag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ccsprogramtag,'Enable','on');
set(handles.ccsprojecttag,'Enable','on');
set(handles.loadprogramtag,'Enable','on');
set(handles.loadprojecttag,'Enable','on');
    
new_example = { get(handles.newexampletag,'String') };
if isempty(new_example{1})
    errordlg('You must supply a title to a new session.','modal');
    return
end
% Before adding to list, check is already in list
if any(strcmp(new_example,get(handles.exampletag,'String')))
    errordlg(['Example ''' new_example{1} ''' already exists in the selection. Supply a different example name.'],...
        'Duplicate name','modal');
    return
end

% Add to list
examplelist = vertcat(get(handles.exampletag,'String'),new_example);
set(handles.exampletag,'String',examplelist);
handles.examples = examplelist;
% Clear edit box for next entry
set(handles.newexampletag,'String','');
% Display empty code windows
set(handles.MATLABcodetag,'String',{[]});
set(handles.DSPcodetag,'String',{[]});
set(handles.Vercodetag,'String',{[]});
% Save code
handles.lastval = length(examplelist);
set(handles.exampletag,'Value',handles.lastval);
handles = MATLABcodetag_Callback(handles.MATLABcodetag, eventdata, handles);
handles = DSPcodetag_Callback(handles.DSPcodetag, eventdata, handles);
handles = Vercodetag_Callback(handles.Vercodetag, eventdata, handles);
% Increment added examples
handles.numnewexamples = handles.numnewexamples+1;
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in MATLABcodetag.
function handles = MATLABcodetag_Callback(hObject, eventdata, handles)
% Save updates/changes made on code
handles.examplecode(handles.lastval).matlab = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in DSPcodetag.
function handles = DSPcodetag_Callback(hObject, eventdata, handles)
% Save updates/changes made on code
handles.examplecode(handles.lastval).dsp = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in Vercodetag.
function handles = Vercodetag_Callback(hObject, eventdata, handles)
% Save updates/changes made on code
handles.examplecode(handles.lastval).ver = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in runtag.
function handles = runtag_Callback(hObject, eventdata, handles)

if handles.runstep~=1
    warndlg(sprintf(['You are currently running the demo incrementally. \n'...
            'You have to complete all the steps before clicking ''Run demo''.'])...
            ,'Demo is not yet finished running','modal');
    return
end

if isempty(handles.cc)
    handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
end

exnum = get(handles.exampletag,'Value');
if exnum<=handles.numdefaultexamples
    issupported = LoadDefaultCCSProgram(handles.cc,handles);
    if ~issupported
        return;
    end
end
run(handles.cc,'main');

pointsave=get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');
if ~runSim(handles,exnum)
    return
end
if ~runDSP(handles,exnum)
    return
end
if ~runVer(handles,exnum)
    return
end

set(gcbf,'Pointer',pointsave);
guidata(hObject,handles);

%-----------------------------
function resp = runSim(handles,exnum)
try
    code = handles.examplecode(exnum).matlab;
    section = 'MATLAB Simulation';
    set(handles.statustag,'String','Running MATLAB simulation...');
    % EvaluateCode([handles.cc.boardnum,handles.cc.procnum],code,'sim');
    EvaluateCode(handles,code,'sim');
    resp = 1;
catch
    set(handles.statustag,'String',[handles.examples{exnum} ': Halted']);
    errordlg(sprintf('Error in ''%s'' section:\n%s',section,lasterr),'modal');
    resp = 0;
    % reset
    set(handles.runsteptag,'String','Run MATLAB Simulation');
    set(gcbf,'Pointer','arrow');
    return
end
%-----------------------------
function EvaluateCode(MW_CCSLINK_handles,MW_CCSLINK_code,MW_CCSLINK_section)
warning off MATLAB:intConvertNonIntVal;
warning off MATLAB:FUNCTION:FuncDeclRequired;
warning off backtrace;

% Load variables from previous step
if ~strcmp(MW_CCSLINK_section,'sim')
    MW_CCSLINK_origpath = pwd;
    cd(tempdir);
    load ccshildemo.mat
    cd(MW_CCSLINK_origpath);
end
% Evaluate code
if strcmp(MW_CCSLINK_section,'dsp')
    cc = MW_CCSLINK_handles.cc;
end
for MW_CCSLINK_i=1:length(MW_CCSLINK_code)
    eval(MW_CCSLINK_code{MW_CCSLINK_i})
end
% Save variables for next step - 
% Note: due to constraint in saving/loading CCS-related variables per step,
% the verification step cannot access any CC-related variables.
if ~strcmp(MW_CCSLINK_section,'ver')
    existingvars_orig = whos;
    existingvars = {existingvars_orig.name};
    
    % Exclude all CCS-related variables
    idxexcludelist = [];
    if strcmp(MW_CCSLINK_section,'dsp')
        excludelist = {'rtdx','stack','type','ccsdsp','ccs.'};
        for MW_CCSLINK_i=1:length(excludelist)
            idxexcludelist = [idxexcludelist,strmatch(excludelist{MW_CCSLINK_i},{existingvars_orig.class})'];
        end
        existingvars = setdiff(existingvars,{existingvars{idxexcludelist}});
    end
    % Exclude all MW_CCSLINK_ variables
    existingvars = setdiff(existingvars,{'MW_CCSLINK_code','MW_CCSLINK_i','MW_CCSLINK_section','MW_CCSLINK_handles','MW_CCSLINK_origpath'});
    
    str = 'save ccshildemo.mat ';
    for MW_CCSLINK_i=1:length(existingvars)
        str = [str existingvars{MW_CCSLINK_i} ' '];
    end
    MW_CCSLINK_origpath = pwd;
    cd(tempdir);
    eval(str);
    cd(MW_CCSLINK_origpath);
end

warning on MATLAB:intConvertNonIntVal;
warning on MATLAB:FUNCTION:FuncDeclRequired;
warning on backtrace;

%-----------------------------
function resp = runDSP(handles,exnum)
try
    code = handles.examplecode(exnum).dsp;
    section = 'DSP Implementation';
    set(handles.statustag,'String','Running DSP implementation...');
    EvaluateCode(handles,code,'dsp');
    resp = 1;
catch
    set(handles.statustag,'String',[handles.examples{exnum} ': Halted']);
    errordlg(sprintf('Error in ''%s'' section:\n%s',section,lasterr),'modal');
    resp = 0;
    % reset
    set(handles.runsteptag,'String','Run MATLAB Simulation');
    set(gcbf,'Pointer','arrow');
    return
end
%-----------------------------
function resp = runVer(handles,exnum)
try
    code = handles.examplecode(exnum).ver;
    section = 'Verification';
    set(handles.statustag,'String','Running verification code...');
    % EvaluateCode([0 0],code,'ver');
    EvaluateCode(handles,code,'ver');
    set(handles.statustag,'String',[handles.examples{exnum} ': Done']);
    resp = 1;
catch
    set(handles.statustag,'String',[handles.examples{exnum} ': Halted']);
    errordlg(sprintf('Error in ''%s'' section:\n%s',section,lasterr),'modal');
    resp = 0;
    % reset
    set(handles.runsteptag,'String','Run MATLAB Simulation');
    set(gcbf,'Pointer','arrow');
    return
end

% --- Executes on button press in ccsdsptag.
function handles = ccsdsptag_Callback(hObject, eventdata, handles)
if ~isempty(handles.cc)
    changecode = 1; % change the cc-dependent default code (e.g. add(..,'int32',...))
else
    changecode = 0;
end
try
    [b,p] = boardprocsel; drawnow;
    pointsave = get(gcbf,'Pointer');
    set(gcbf,'Pointer','Watch');
    handles.cc = ccsdsp('boardnum',b,'procnum',p);
catch
    set(gcbf,'Pointer',pointsave);    
    errordlg(lasterr);
    return
end
% Update CCSDSP Link display
set(handles.boardnumtxt,'String',['Board number: ' num2str(b)]);
set(handles.procnumtxt,'String',['Processor number: ' num2str(p)]);
boardinfo = info(handles.cc);
set(handles.boardtypetxt,'String',['Board name:   ' boardinfo.boardname]);
% Update registernames
if boardinfo.family==320
    handles.subfamily = ['C' dec2hex(boardinfo.subfamily) 'x'];
elseif boardinfo.family==470
    handles.subfamily = ['R' dec2hex(boardinfo.subfamily) 'x'];
else
    errordlg(['Family TMS ' boardinfo.family ' is not supported.']);
    return
end
if changecode
    % Default program/project files
    handles = GetDefaultFiles(handles);
    if isempty(handles.programfile)
        handles.examplecode = struct('matlab',[],'dsp',[],'ver',[]);
        handles.funcname = [];
        UpdateCode(handles,1);
        guidata(hObject, handles);
        return
    end
    % Save default M code
    [handles.examplecode,handles.funcname] = GetDefaultCode(handles);

    % set(handles.ccsprogramtag,'Enable','off');
    % set(handles.ccsprojecttag,'Enable','off');
    set(handles.loadprogramtag,'Enable','off');
    set(handles.loadprojecttag,'Enable','off');

    % Save default M code
    [handles.examplecode,handles.funcname] = GetDefaultCode(handles);

    % Display M code for first example
    UpdateCode(handles,1);
    set(handles.statustag,'String',handles.examples{1});
    set(handles.dspfunctionname,'String',handles.funcname{1});

    set(handles.runFirst,'Enable','on'); % disable/enable appropriate run buttons
    set(handles.runSecond,'Enable','off');
    set(handles.runThird,'Enable','off');
    SetVisible(handles,'sim',1);
    SetTabBold(handles,'sim');
end

set(gcbf,'Pointer',pointsave);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in closetag.
function closetag_Callback(hObject, eventdata, handles)
if handles.numnewexamples~=0
    SaveExample(handles);
end
delete(handles.mainGUI);

% --- Executes on button press in helptag.
function helptag_Callback(hObject, eventdata, handles)
msgbox(sprintf([...
        'This demo shows you how to use the "Link for Code Composer Studio"\n', ...
        'to verify and debug your DSP application in a Hardware-in-the-loop fashion.\n\n', ...
        'Three text boxes are provided to show the three most commonly practised\n', ...
        'stages of DSP application development:\n',...
        '   1) Simulation\n',...
        '   2) DSP implementation,\n',...
        '   3) Verification.\n',...
        '\n',...
        'Each text box contains the MATLAB code needed to implement a particular \n', ...
        'stage. Five examples are provided to show how you can use CCS-specific \n', ...
        'MATLAB functions to check a DSP function''s behavior.  \n', ...
        '\n',...
        'You can run an example by clicking buttons in the following order:\n',...
        '  1.) ''Run MATLAB Simulation\n',...
        '  2.) ''Run DSP Implementation\n',...
        '  3.) ''Compaer Results\n',...
        '\n',...
        'The complete M-code for running a particular example can be generated by\n', ...
        'clicking the ''Export script to file...'' button.\n\n', ...
        '\n', ...
        '\n', ...
        '\n', ...
        '\n' ...
    ]),'Help');

function newexampletag_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of newexampletag as text
%        str2double(get(hObject,'String')) returns contents of newexampletag as a double



% --- Executes during object creation, after setting all properties.
function ccsprogramtag_CreateFcn(hObject, eventdata, handles)
% comment out - bec. changing ccsprogramtag & ccsprojecttag to text
% SetupBackground(hObject,'white');
function ccsprojecttag_CreateFcn(hObject, eventdata, handles)
% comment out - bec. changing ccsprogramtag & ccsprojecttag to text
% SetupBackground(hObject,'white');
function exampletag_CreateFcn(hObject, eventdata, handles)
SetupBackground(hObject,'white');
function MATLABcodetag_CreateFcn(hObject, eventdata, handles)
SetupBackground(hObject,'white');
function DSPcodetag_CreateFcn(hObject, eventdata, handles)
SetupBackground(hObject,'white');
function Vercodetag_CreateFcn(hObject, eventdata, handles)
SetupBackground(hObject,'white');
function newexampletag_CreateFcn(hObject, eventdata, handles)
SetupBackground(hObject,'white');
function dspfunctionname_CreateFcn(hObject, eventdata, handles)
SetupBackground(hObject,'white');
%-----------------------------------------
function SetupBackground(hObject,bgcolor)
if ispc
    set(hObject,'BackgroundColor',bgcolor);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%----------------------------------
function UpdateCode(handles,exnum)
set(handles.MATLABcodetag,'String',handles.examplecode(exnum).matlab);
set(handles.DSPcodetag,'String',handles.examplecode(exnum).dsp);
set(handles.Vercodetag,'String',handles.examplecode(exnum).ver);
set(handles.Vercodetag,'Value',1);

%--------------------------------
function [examplecode,funcname] = GetDefaultCode(handles)
len = length(handles.examples);
funcname = cell(len);
examplecode(len) = struct('matlab',[],'dsp',[],'ver',[]);
for i=1:len
    [examplecode(i),funcname{i}] = getDefaultExampleCode(i,handles.cc); % passing CC is hack for fir_filter part - must be removed later on
end

%--------------------------------
function resp = LoadDefaultCCSProgram(cc,handles)
resp = 1;
board = GetDemoProp(cc,'hiltutorial');
if ~isSupportedProc(board)
    errordlg('The demo does not support the processor you selected.','Processor not supported','modal');
    resp = 0;
    return
end
projfile = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','hiltutorial',board.hiltut.projname);
% projfile = fullfile('d:','work','CCSLinkDemonstration','hil','hiltutorial',board.hiltut.projname);
projpath = fileparts(projfile);

% Open CCS project
warnstate = warning('off');
open(cc,projfile);
warning(warnstate);
% Change working directory of Code Composer(only)
cd(cc,projpath); 
visible(cc,1);

if strcmpi(board.name,'c54x')
    open(cc,'hiltut_54x.c','text');
    activate(cc,'hiltut_54x.c','text');
else
    open(cc,'hiltut.c','text');
    activate(cc,'hiltut.c','text');
end  

try
    load(cc,board.hiltut.loadfile);    % Load the target execution file
    % Show only filename (no path)
    % set(handles.ccsprogramtag,'String',fullfile(projpath,board.hiltut.loadfile));
    set(handles.ccsprogramtag,'String',board.hiltut.loadfile);
catch % if error occurs while loading
    disp(lasterr);
	% Setting the right build options:
	setbuildopt(cc,'Compiler',board.hiltut.Cbuildopt);
	% Directing output program file to a temporary directory on your system
	setbuildopt(cc,'Linker',['-c -o"' tempdir board.hiltut.loadfile '" -x']);
	build(cc,'all',1500); % PLEASE WAIT FOR THIS 'BUILD' OPERATION TO COMPLETE
    try 
        % Attempt to load the program file from the temporary directory
        load(cc,[tempdir board.hiltut.loadfile]);
    catch
        contFlag = 'dummy';
        while ~isempty(contFlag) && ~strcmpi(contFlag,'exit')
            contFlag = input('Hit return to proceed with the demo, type ''exit'' to exit the demo: ','s');
        end
        if ~isempty(contFlag),
            % Clear all variables created by the tutorial
            hiltutorialVars1 = whos;
            hiltutorialVars1 = setdiff({hiltutorialVars1.name},existingVars);
            len1 = length(hiltutorialVars1);
            for varid1=1:len1
                clear (hiltutorialVars1{varid1});
            end
            clear hiltutorialVars1 len1 varid1
            disp(sprintf('\nExiting demo...'))
            return
        end
    end
end

% --- Executes on button press in saveSessiontag.
function saveSessiontag_Callback(hObject, eventdata, handles)
if isempty(handles.cc)
    handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
end
orig_path = pwd;
cd(handles.cc.cd); % cd to where project resides
% Ask user for an m-file
[filename, pathname] =  uiputfile('*.m','Save as','Untitled.m'); %,['Load Program Files - ' targetName]);
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
fprintf(handles.saveFile.fid,'%% Setup CCSDSP link -----\n');
fprintf(handles.saveFile.fid,'cc = ccsdsp(''boardnum'',%d,''procnum'',%d);\n',handles.cc.boardnum,handles.cc.procnum);
if ~isempty(handles.projectfile)
    fprintf(handles.saveFile.fid,'open(cc,''%s'',''project'');\n',handles.projectfile);
end
if ~isempty(handles.programfile)
    fprintf(handles.saveFile.fid,'load(cc,''%s'');\n\n',handles.programfile);
else
    lastfileloaded = p_getProgLoaded(handles.cc);
    fprintf(handles.saveFile.fid,'load(cc,''%s'');\n\n',lastfileloaded);
end
fprintf(handles.saveFile.fid,'%% MATLAB simulation -----\n');
val = get(handles.exampletag,'Value');
for i=1:length(handles.examplecode(val).matlab)
    fprintf(handles.saveFile.fid,'%s\n',handles.examplecode(val).matlab{i});
end
fprintf(handles.saveFile.fid,'\n%% DSP implementation -----\n');
for i=1:length(handles.examplecode(val).dsp)
    fprintf(handles.saveFile.fid,'%s\n',handles.examplecode(val).dsp{i});
end
fprintf(handles.saveFile.fid,'\n%% Verify and compare results -----\n');
for i=1:length(handles.examplecode(val).ver)
    fprintf(handles.saveFile.fid,'%s\n',handles.examplecode(val).ver{i});
end
fclose(handles.saveFile.fid);
%
guidata(hObject,handles);
% Return info (hack) - 'willSave' & 'saveFile' values are not stored even after 
% call to saveSession_Callback (when called by 'close')
willSave = handles.willSave;
saveFile= handles.saveFile;

% Open and preview file
open([handles.saveFile.path '\' handles.saveFile.filename]);

% --- Executes on button press in runsteptag.
function runsteptag_Callback(hObject, eventdata, handles)
pointsave = get(gcbf,'Pointer');
exnum = get(handles.exampletag,'Value');
if handles.runstep==1
    if isempty(handles.cc)
        handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
    end
    issupported = LoadDefaultCCSProgram(handles.cc,handles);
    if ~issupported
       return;
    end
    set(gcbf,'Pointer','watch');
    run(handles.cc,'main');
    if ~runSim(handles,exnum)
        return
    end
    set(handles.statustag,'String','Running MATLAB simulation...done');
    set(gcbf,'Pointer',pointsave);
    handles.runstep=2;
    set(hObject,'String','Run DSP Implementation');
    
elseif handles.runstep==2
    set(gcbf,'Pointer','watch');
    if ~runDSP(handles,exnum);
        return
    end
    set(handles.statustag,'String','Running DSP implementation...done');
    set(gcbf,'Pointer',pointsave);
    handles.runstep=3;
    set(hObject,'String','Run Verification');
elseif handles.runstep==3
    set(gcbf,'Pointer','watch');
    if ~runVer(handles,exnum);
        return
    end
    set(handles.statustag,'String','Running verification code...done');
    set(gcbf,'Pointer',pointsave);
    handles.runstep=1;
    set(hObject,'String','Run MATLAB Simulation');
end
DeleteMatFile;
% Update handles structure
guidata(hObject, handles);

%-----------------------------
function resp = SaveExample(handles)
savefile = questdlg('You added new example(s) in the list. Would you like to save this so you can reload it later?',...
    'Save example','Yes','No','Yes');
if strcmp(savefile,'No')
    return;
end
[filename,pathname] = uigetfile('*.mat','Enter a MAT-file','Untitled.mat');
if ischar(filename) && ischar(pathname),
    examplelist = {handles.examples{handles.numdefaultexamples+1:end}};
    examplecode = (handles.examplecode(handles.numdefaultexamples+1:end));
    save(fullfile(pathname,filename),'examplelist','examplecode');
else
    return;
end

% --- Executes on button press in loadnewexample.
function loadnewexample_Callback(hObject, eventdata, handles)
[filename,pathname] = uigetfile('*.mat','Enter a MAT-file');
if ischar(filename) && ischar(pathname),
    if isempty(findstr(filename,'.mat'))
        errordlg('You have to choose a MAT-file.','Invalid file','modal');
        return;
    end
    load(fullfile(pathname,filename),'examplelist','examplecode');
    if ~isempty(findstr(lastwarn,'not found'))
        errordlg('You have to choose a valid MAT-file.','Invalid file','modal');
        return
    end
    if length(examplelist)~=length(examplecode)
        errordlg('The MAT-file you seleccted contains invalid data.','Invalid file','modal');
        return
    end
    handles.examples = horzcat(handles.examples,examplelist);
    handles.examplecode = horzcat(handles.examplecode,examplecode);
    handles.examplecode(end+1) = examplecode;
    set(handles.exampletag,'String',handles.examples);
    handles.numnewexamples = length(examplelist);
else
    return;
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in loadprogramtag.
function loadprogramtag_Callback(hObject, eventdata, handles)
if isempty(handles.cc)
    handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
end
orig_path = pwd;
[prjpath1,prjfile1] = fileparts(handles.projectfile);
[prjpath2,prjfile2] = fileparts(handles.programfile);
if ~isempty(prjpath1)
    cd(prjpath1);
elseif ~isempty(prjpath2)
    cd(prjpath2);
else
    cd(handles.cc.cd); % cd to where project resides
end
[filename, pathname] =  uigetfile('*.out');
cd(orig_path);
if ischar(filename) && ischar(pathname),
    if isempty(findstr(filename,'.out'))
        return
    end
    finalfile = fullfile(pathname,filename);
    % set(handles.ccsprogramtag,'String',finalfile);
    set(handles.ccsprogramtag,'String',file);
    if LoadCCSFile(handles,finalfile,'program')
        handles.programfile = finalfile;
    end
    guidata(hObject,handles);
end   

% --- Executes on button press in loadprojecttag.
function loadprojecttag_Callback(hObject, eventdata, handles)
if isempty(handles.cc)
    handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
end
orig_path = pwd;
[prjpath1,prjfile1] = fileparts(handles.projectfile);
[prjpath2,prjfile2] = fileparts(handles.programfile);
if ~isempty(prjpath1)
    cd(prjpath1);
elseif ~isempty(prjpath2)
    cd(prjpath2);
else
    cd(handles.cc.cd); % cd to where project resides
end
[filename, pathname] =  uigetfile('*.pjt');
cd(orig_path);
if ischar(filename) && ischar(pathname),
    if isempty(findstr(filename,'.pjt'))
        return
    end
   
    % Show only filename (no path)
    finalfile = fullfile(pathname,filename);
    % set(handles.ccsprojecttag,'String',finalfile);
    set(handles.ccsprojecttag,'String',file);
    
    if LoadCCSFile(handles,finalfile,'project')
        handles.programfile = finalfile;
    end
    guidata(hObject,handles);
end 

%-----------------------------------------
function ccsprogramtag_Callback(hObject, eventdata, handles)
completefilename = get(hObject,'String');
[pathname,filename,ext] = fileparts(completefilename);
if isempty(ext) || strcmpi(ext,'.out')
    filename = [filename '.out'];
    completefilename = fullfile(pathname,filename);
    set(hObject,'String',completefilename);
else
    errordlg('This is not a valid COFF file. Enter a new file.','Invalid COFF file','modal');
    set(hObject,'String','');
    return
end
if LoadCCSFile(handles,completefilename,'program')
    handles.programfile = completefilename;
end
% Update handles structure
guidata(hObject, handles);

%-----------------------------------
function resp = LoadCCSFile(handles,completefilename,opt)
try
    set(handles.statustag,'String',['Loading ' completefilename '...']);
    handles.cc.open(completefilename,opt,30);
    resp = 1;
catch
    set(handles.statustag,'String',[completefilename ': Loading FAILED']);
    switch opt
        case 'program'
            errordlg('Failed during load, please select a valid program file','Program Load Failure','modal');
        case 'project'
            errordlg('Failed during load, please select a valid project file','Project Load Failure','modal');
    end
    resp = 0;
    return;
end 
set(handles.statustag,'String',['Loading ' completefilename '... DONE']);

%------------------------------------------------
function [handles,errstate] = GetDefaultFiles(handles)
errstate = 0;
board = GetDemoProp(handles.cc,'hiltutorial');
if ~isSupportedProc(board)
    errordlg('The demo does not support the processor you selected.','Processor not supported','modal');
    handles.programfile = [];
    handles.projectfile = [];
    errstate = 1;
else
    handles.programfile = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','hiltutorial',board.hiltut.loadfile);
    handles.projectfile = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','hiltutorial',board.hiltut.projname);
end

% set(handles.ccsprojecttag,'String',handles.projectfile);
% set(handles.ccsprogramtag,'String',handles.programfile);

% Show only filename (no path)
[path,filename,ext] = fileparts(handles.projectfile);
set(handles.ccsprojecttag,'String',[filename ext]);
[path,filename,ext] = fileparts(handles.programfile);
set(handles.ccsprogramtag,'String',[filename ext]);

% Update handles structure
guidata(handles.ccsprojecttag, handles);

% --- Executes on button press in viewdspcode.
function viewdspcode_Callback(hObject, eventdata, handles)
dspfcnname = p_deblank(get(handles.dspfunctionname,'String'));
try
    visible(handles.cc,1);
    lastwarn('');
    goto(handles.cc,dspfcnname);
    if ~isempty(lastwarn)
        warndlg(lastwarn,'Can''t locate DSP code','modal');
    end
catch
    if findstr(lasterr,'SetCursor')
        errmsg = ['Cannot locate DSP function ''' dspfcnname ''', the ''',...
                handles.cc.info.boardname ''' CCS window must be open.'];
    else
        errmsg = lasterr;
    end
    errordlg(errmsg,'Cannot locate DSP code','modal');
end

%-----------------------------------------------------
function dspfunctionname_Callback(hObject, eventdata, handles)
dspfcnname = p_deblank(get(hObject,'String'));
set(hObject,'String',dspfcnname);

%-----------------------------------------------------
function resp = isSupportedProc(board)
resp = 0;
if ~isempty(board) 
    if ~isempty(strmatch(board.name,{'c6x','c62x','c64x','c67x','c54x','c28x'},'exact'))
        resp = 1;
    end
end
%----------------------------------
function [code,funcname] = getDefaultExampleCode(exnum,cc)
switch exnum
    case 1, 
        code.matlab = {...
                '% ''userval'' must be [-pi,pi]',...
                'userval = 1.2;',...
                'output_sim = sin(userval);',...
                'disp(sprintf(''\nRESULT:''))',...
                'disp(sprintf('' MATLAB Sine function: sin(%g) = %g'',userval,output_sim))',...
            };
        funcname = 'sin_taylor';
        code.dsp = { ...
                '% ''userval'' must be [-pi,pi]',...
                'userval = 1.2;',...
                '% create function object',...
                'ff = createobj(cc,''sin_taylor'');',...
                '% run function',...
                'output_dsp = run(ff,''x'',int16(userval*2^13));',...
                '% format function output',...
                'output_dsp = output_dsp/2^14;',...
                'disp(sprintf('' Embedded DSP Sine function: sin_taylor(%g) = %g'',userval,output_dsp))'...
            };
        code.ver = {...
                'disp(sprintf('' Difference: %g'',output_sim-output_dsp))'...
            };
    case {2,3}, 
        code.matlab = {...
                '% input data',...
                'inputdata = [-pi:0.1:pi];',...
                'output_sim = sin(inputdata);',...
                '',...
                '% Plot the MATLAB output',...
                'h = figure; set(h,''pos'',[9 339 397 420])',...
                'subplot(2,1,1); plot(inputdata,output_sim,''blue'');',...
                'title(''MATLAB simulation'')',...
                'a = gca;',...
                'set(get(a,''title''),''fontsize'',10);',...
                'set(a,''fontsize'',8);',...
                'set(a,''fontweight'',''light'');',...
                'axis tight; grid on;',...
            };
        funcname = 'sin_taylor_vect';
        if exnum==2,
            code.dsp = { ...
                    '% input data',...
                    'inputdata = [-pi:0.1:pi];',...
                    '',...
                    '% create function object',...
                    'ff = createobj(cc,''sin_taylor_vect'');',...
                    '',...
                    '% use global variables ''ibuf'' & ''obuf'' as buffers for input parameters ''x'' & ''y'',respectively',...
                    'ibufobj = createobj(cc,''ibuf''); % create an object for the input buffer',...
                    'obufobj = createobj(cc,''obuf''); % create an object for the output buffer',...
                    '% initialize buffers',...
                    'write(ibufobj,int16(inputdata*2^13)); % write data to input buffer // scaling for binary point',...
                    'write(obufobj,int16(zeros(1,63))); % initialize output buffer to zeros',...
                    '',...
                    '% Run sin_taylor_vect and pass values to input parameters',...
                    'run(ff,''x'',ibufobj.address(1),''y'',obufobj.address(1),''npts'',63);',...
                    '% Extract the output data',...
                    'outputdataAddress = deref(ff.outputvar); % dereference the output data',...
                    'outputdataAddress.size = 63; % read the next 63 addresses (obuf)',...
                    'output_dsp = read(outputdataAddress)/2^14;'...
                };
        else
            code.dsp = { ...
                    '% Input data',...
                    'inputdata = [-pi:0.1:pi];',...
                    '',...
                    '% Create function object and',...
                    '% locally allocate space as buffers for input parameters ''x'' & ''y''',...
                    'ff = createobj(cc,''sin_taylor_vect'',''function'',''allocate'',{''x'',63,''y'',63});',...
                    '',...
                    '% initialize buffers',...
                    'write(ff,''*x'',int16(inputdata*2^13)); % write data to input buffer // scaling for binary point',...
                    'write(ff,''*y'',int16(zeros(1,63))); % initialize output buffer to zeros',...
                    '',...
                    '% Run sin_taylor_vect and pass values to input parameters',...
                    'run(ff,''npts'',63);',...
                    '% Extract the output data',...
                    'output_dsp = read(getinput(ff,''*y''))/2^14;'...
                };
        end
        code.dsp = horzcat( code.dsp, {...
                '',...
                '% Plot the DSP output',...
                'figure(h);',...
                'subplot(2,1,2); plot(inputdata,output_dsp,''red'');',...
                'title(''DSP Implementation'')',...
                'a = gca;',...
                'set(get(a,''title''),''fontsize'',10);',...
                'set(a,''fontsize'',8);',...
                'set(a,''fontweight'',''light'');',...
                'axis tight; grid on;',...
            });
        code.ver = {...
                '% Plot both outputs and compare',...
                'h = figure; set(h,''pos'',[414 339 442 420])',...
                'subplot(2,1,1);',...
                'plot(inputdata,output_sim,''blue''); hold on;',...
                'plot(inputdata,output_dsp,''red''); hold off;',...
                'title(''MATLAB simulation (blue) vs. DSP Implementation (red)'');',...
                'a = gca;',...
                'set(get(a,''title''),''fontsize'',10);',...
                'set(a,''fontsize'',8);',...
                'set(a,''fontweight'',''light'');',...
                'axis tight; grid on;',...
                'dif = output_sim-output_dsp;'...
                'subplot(2,1,2); plot(inputdata,dif);',...
                'title(''Difference between MATLAB simulation vs. DSP Implementation results'');',...
                'a = gca;',...
                'set(get(a,''title''),''fontsize'',10);',...
                'set(a,''fontsize'',8);',...
                'set(a,''fontweight'',''light'');',...
                'axis([inputdata(1) inputdata(end) min(output_dsp) max(output_dsp)]); grid on;',...
            };
    case {4,5},
        code.matlab = {...
                '% Default',...
                'nfrm = 128; cscaling = 2^15; sineFreq = 100; fs = 8000;',...
                '% Generate random noise',...
                'noiseVect = 0.12 * rand(nfrm,1);',...
                '% Form input signal',...
                't = (0:nfrm-1)''/fs;',...
                'sineSignal = sin( sineFreq * t * 2 * pi );',...
                'inputSignal = noiseVect + 0.2*sineSignal;',...
                '',...
                '% Filter output generated from MATLAB',...
                'n = 10; wb1 = 0.3;',...
                'bcoeff = fir1(n,wb1);',...
                'filterOutput = filter(bcoeff, 1, inputSignal);',...
                '',...
                '% Plot the MATLAB output',...
                'h = figure(''units'',''normalized'',''pos'',[0.0381,0.5078,0.4170,0.3984]);',...
                'subplot(2,1,1); plot(filterOutput);',...
                'title(''MATLAB simulation'')',...
                'axis tight; grid on;',...
                'drawnow;',...
            };
        funcname = 'fir_filter';
        subfamily = cc.info.subfamily;
        if subfamily>=96 && subfamily<112,
            int32equivalent = 'add(cc.type,''INT32'',''int''); % add INT32 to the cc typedef list';
        else
            int32equivalent = 'add(cc.type,''INT32'',''long''); % add INT32 to the cc typedef list';
        end
        if exnum==4,
            code.dsp = { ...
                    '% Create an object for the ''fir_filter'' library function in CCS',...
                    'ff = createobj(cc,''fir_filter''); % warning thrown because function declaration cannot be located',...
                    '% Supply function declaration through ''declare'' but first add typedef information to Type class',...
                    'add(cc.type,''INT16'',''short''); % add INT16 to the cc typedef list'};
            code.dsp = horzcat( code.dsp, { int32equivalent, ...
                    'declare(ff,''decl'',''void fir_filter(INT16 *din, INT16 *coeff, INT16 *dout, INT32 ncoeff, INT32 nbuf )'');',...
                    '',...
                    '% Use global variables as buffers for the input parameters',...
                    'coeff = createobj(cc,''coeff'');',...
                    'din = createobj(cc,''din'');',...
                    'dout = createobj(cc,''dout'');',...
                    '',...
                    'inputSignal_tgt = int16(cscaling*inputSignal);',...
                    'input_tgt = [zeros(n,1); inputSignal_tgt(1:end-n)];',...
                    'write(coeff,int16(cscaling.*bcoeff));',...
                    'write(din,input_tgt);',...
                    '',...
                    '% Write data into function''s input parameters',...
                    'write(ff,''din'',din.address(1));',...
                    'write(ff,''coeff'',coeff.address(1));',...
                    'write(ff,''dout'',dout.address(1));',...
                    'write(ff,''ncoeff'',n);',...
                    'write(ff,''nbuf'',nfrm);',...
                    '',...
                    '% run the function',...
                    'run(ff);',...
                    '',...
                    '% read function''s output data',...
                    'filterOutput_tgt = read(dout);',...
                    'filterOutput_tgt = double(filterOutput_tgt)/cscaling; % scale',...
            });
        else
            code.dsp = { ...
                    '% Create an object for the ''fir_filter'' library function in CCS',...
                    'ff = createobj(cc,''fir_filter'',''function'',''allocate'',{''din'',nfrm+10,''coeff'',11,''dout'',nfrm});',...
                    '',...
                    '% Supply function declaration through ''declare'' but first add typedef information to Type class',...
                    'add(cc.type,''INT16'',''short''); % add INT16 to the cc typedef list'};
            code.dsp = horzcat( code.dsp, { int32equivalent, ...
                    'declare(ff,''decl'',''void fir_filter(INT16 *din, INT16 *coeff, INT16 *dout, INT32 ncoeff, INT32 nbuf )'');',...
                    '',...
                    '% Scale input data, coeff, and load these values to the target',...
                    'inputSignal_tgt = int16(cscaling*inputSignal);',...
                    'write(getinput(ff,''*coeff''),int16(cscaling*bcoeff));',...
                    'write(getinput(ff,''*din''),[zeros(n,1);inputSignal_tgt]);',...
                    'write(ff,''ncoeff'',n);',...
                    'write(ff,''nbuf'',nfrm);',...
                    '',...
                    '% ''goto'' + ''execute'' ==> same as ''run''',...
                    'goto(ff);',...
                    'execute(ff);',...
                    '',...
                    '% read function''s output data',...
                    'filterOutput_tgt = read(getinput(ff,''*dout''));',...
                    'filterOutput_tgt = double(filterOutput_tgt)/cscaling; % scale',...
                });
        end
        code.dsp = horzcat( code.dsp, {...
                '',...
                '% Plot the DSP output',...
                'figure(h);',...
                'subplot(2,1,2); plot(filterOutput_tgt,''r'');',...
                'title(''DSP implementation'')',...
                'axis tight; grid on; ',...
                'drawnow;',... 
            });
                
        code.ver = {...
                '% Plot the outputs and compare',...
                'h = figure(''units'',''normalized'',''pos'',[0.0371,0.1979,0.4180,0.2148]);',...
                '% Plot input signal',...
                'plot(inputSignal,''k''); hold on; ',...
                '% Plot MATLAB function''s output data in blue',...
                'plot(filterOutput,''o''); hold on; ',...
                '% Plot DSP function''s output data in red',...
                'plot(filterOutput_tgt,''rx''); hold off',...
                'axis tight; grid on;',...
                'title(''Input Signal (black), MATLAB (blue), Target DSP (red)'');',...
                'drawnow;',...
            };
    otherwise
end

% --- Executes on button press in runFirst.
function runFirst_Callback(hObject, eventdata, handles)
pointsave = get(gcbf,'Pointer');
exnum = get(handles.exampletag,'Value');
% Check is handle is already created and is supported
if isempty(handles.cc)
    handles = ccsdsptag_Callback(handles.ccsdsptag, eventdata, handles);
end
issupported = LoadDefaultCCSProgram(handles.cc,handles);
if ~issupported
   return;
end

% Disable users from changing example while in the middle of one example
set(handles.exampletag,'Enable','off');

set(handles.runSecond,'Enable','off');
set(handles.runThird,'Enable','off');

% Start to run
set(gcbf,'Pointer','watch');
run(handles.cc,'main');
if ~runSim(handles,exnum)
    return
end
set(handles.statustag,'String','Running MATLAB simulation...done');
set(gcbf,'Pointer',pointsave);

% Prepare parameters for next step
handles.runstep=2; % next run step
set(hObject,'Enable','off'); % disable/enable appropriate run buttons
set(handles.runSecond,'Enable','on');
set(handles.runThird,'Enable','off');
SetVisible(handles,'dsp',1);
SetTabBold(handles,'dsp');

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in runSecond.
function runSecond_Callback(hObject, eventdata, handles)
if handles.runstep~=2
    errordlg('You need to follow the correct run order. Click ''Run MATLAB Simulation'' first.',...
        'Incorrect run order','modal');
    return
end
pointsave = get(gcbf,'Pointer');
exnum = get(handles.exampletag,'Value');

% Start to run
set(gcbf,'Pointer','watch');
if ~runDSP(handles,exnum);
    return
end
set(handles.statustag,'String','Running DSP implementation...done');
set(gcbf,'Pointer',pointsave);

% Prepare parameters for next step
handles.runstep=3; % next run step
set(handles.runFirst,'Enable','off'); % disable/enable appropriate run buttons
set(hObject,'Enable','off');
set(handles.runThird,'Enable','on');
SetVisible(handles,'ver',1);
SetTabBold(handles,'ver');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in runThird.
function runThird_Callback(hObject, eventdata, handles)
if handles.runstep~=3
    errordlg('You need to follow the correct run order. Click ''Run DSP Implementation'' first.',...
        'Incorrect run order','modal');
    return
end

pointsave = get(gcbf,'Pointer');
exnum = get(handles.exampletag,'Value');

% Start to run
set(gcbf,'Pointer','watch');
if ~runVer(handles,exnum);
    return
end
DeleteMatFile;
set(handles.statustag,'String','Running verification code...done');
set(gcbf,'Pointer',pointsave);

% Prepare parameters for next step
handles.runstep=1; % next run step
set(handles.runFirst,'Enable','on'); % disable/enable appropriate run buttons
set(handles.runSecond,'Enable','off');
set(hObject,'Enable','off');
SetVisible(handles,'sim',1);
SetTabBold(handles,'sim');

% Allow users to select example to run
set(handles.exampletag,'Enable','on');

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in simtab.
function simtab_Callback(hObject, eventdata, handles)
SetVisible(handles,'sim',1);

% --- Executes on button press in dsptab.
function dsptab_Callback(hObject, eventdata, handles)
SetVisible(handles,'dsp',1);

% --- Executes on button press in vertab.
function vertab_Callback(hObject, eventdata, handles)
SetVisible(handles,'ver',1);

%-------------------------------------------------
function SetVisible(handles,stage,state)
if state==1,    state = 'on';       otherstate = 'off';
else            state = 'off';      otherstate = 'on';
end
switch stage
    case 'sim'
        set(handles.MLSimtext,      'Visible',state);
        set(handles.MATLABcodetag,  'Visible',state);
        set(handles.DSPImptext,     'Visible',otherstate);
        set(handles.DSPcodetag,     'Visible',otherstate);
        set(handles.Vertext,        'Visible',otherstate);
        set(handles.Vercodetag,     'Visible',otherstate);
        set(handles.viewdspcode,    'Visible',otherstate);
        set(handles.dspfunctionname,'Visible',otherstate);
    case 'dsp'
        set(handles.MLSimtext,      'Visible',otherstate);
        set(handles.MATLABcodetag,  'Visible',otherstate);
        set(handles.DSPImptext,     'Visible',state);
        set(handles.DSPcodetag,     'Visible',state);
        set(handles.Vertext,        'Visible',otherstate);
        set(handles.Vercodetag,     'Visible',otherstate);
        set(handles.viewdspcode,    'Visible',state);
        set(handles.dspfunctionname,'Visible',state);
    case 'ver'
        set(handles.MLSimtext,      'Visible',otherstate);
        set(handles.MATLABcodetag,  'Visible',otherstate);
        set(handles.DSPImptext,     'Visible',otherstate);
        set(handles.DSPcodetag,     'Visible',otherstate);
        set(handles.Vertext,        'Visible',state);
        set(handles.Vercodetag,     'Visible',state);
        set(handles.viewdspcode,    'Visible',otherstate);
        set(handles.dspfunctionname,'Visible',otherstate);
end

%-------------------------------------------------
function SetTabBold(handles,stage)
switch stage
    case 'sim'
        set(handles.simtab,'FontWeight','demi');
        set(handles.dsptab,'FontWeight','normal');
        set(handles.vertab,'FontWeight','normal');
    case 'dsp'
        set(handles.simtab,'FontWeight','normal');
        set(handles.dsptab,'FontWeight','demi');
        set(handles.vertab,'FontWeight','normal');
    case 'ver'
        set(handles.simtab,'FontWeight','normal');
        set(handles.dsptab,'FontWeight','normal');
        set(handles.vertab,'FontWeight','demi');
end

%-------------------------------------------------
function DeleteMatFile
%- Delete MAT file
% origwd = cd(tempdir);
% matfilelist = ls('ccshildemo.mat')
warning('off','MATLAB:DELETE:FileNotFound')
try
    delete([tempdir 'ccshildemo.mat']);
catch
    % do nothing
end
warning('on','MATLAB:DELETE:FileNotFound')
% cd(origwd);

% [EOF] ccshildemo.m
