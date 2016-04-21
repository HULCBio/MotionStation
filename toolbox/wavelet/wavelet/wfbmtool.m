function varargout = wfbmtool(varargin)
%WFBMTOOL Fractional Brownian motion generation tool.
%   VARARGOUT = WFBMTOOL(VARARGIN)

% WFBMTOOL M-file for wfbmtool.fig
%      WFBMTOOL, by itself, creates a new WFBMTOOL or raises the existing
%      singleton*.
%
%      H = WFBMTOOL returns the handle to a new WFBMTOOL or the handle to
%      the existing singleton*.
%
%      WFBMTOOL('Property','Value',...) creates a new WFBMTOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wfbmtool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WFBMTOOL('CALLBACK') and WFBMTOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WFBMTOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 15-Dec-2003 15:21:36
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 13-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:42:46 $ 


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wfbmtool_OpeningFcn, ...
                   'gui_OutputFcn',  @wfbmtool_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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
% --- Executes just before wfbmtool is made visible.                      %
%*************************************************************************%

function wfbmtool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for wfbmtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wfbmtool wait for user response (see UIRESUME)
% uiwait(handles.wfbmtool_Win);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Intoduced manualy in the automatic generated code   %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);

%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%

function varargout = wfbmtool_OutputFcn(hObject, eventdata, handles)
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
%                BEGIN Create Functions                                   %
%                ----------------------                                   %
% --- Executes during object creation, after setting all properties.      %
%=========================================================================%

function EdiPop_CreateFcn(hObject,eventdata,handles)
% hObject    handle to Edi_Object or Pop_Object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
% Hint: popupmenu controls usually have a white background on Windows.
% See ISPC and COMPUTER.
if ispc
    % set(hObject,'BackgroundColor','white');
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%--------------------------------------------------------------------------

function Sli_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sli_Object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%--------------------------------------------------------------------------

%=========================================================================%
%                END Create Functions                                     %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%

% --- Executes on selection change in Pop_Wav_Fam.
function Pop_Wav_Fam_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_Wav_Fam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cbanapar('cba_fam',gcbf,[],guidata(gcbo));
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_Wav_Num.
function Pop_Wav_Num_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_Wav_Num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cbanapar('cba_num',gcbf,[],guidata(gcbo));
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_Refinement.
function Pop_Refinement_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_Refinement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------

% --- Executes on button press in Edi_Length.
function Edi_Length_Callback(hObject, eventdata, handles)
% hObject    handle to Edi_Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FieldDefault ='1000';
Val_Length = str2double(get(hObject,'String'));
if ~isequal(Val_Length,fix(Val_Length)) || ...
    Val_Length < 100 || isnan(Val_Length)
    set(hObject,'String',FieldDefault);
end
%--------------------------------------------------------------------------

% --- Executes on slider movement.
function Sli_Fractal_Index_Callback(hObject, eventdata, handles)
% hObject    handle to Sli_Fractal_Index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Val_Index = get(hObject,'Value');
set(handles.Edi_Fractal_Index,'string',Val_Index);
%--------------------------------------------------------------------------

% --- Executes on button press in Edi_Fractal_Index.
function Edi_Fractal_Index_Callback(hObject, eventdata, handles)
% hObject    handle to Edi_Fractal_Index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FieldDefault ='0.6';
Val_Index = str2double(get(hObject,'String'));
if Val_Index < 0 || Val_Index > 1 || isnan(Val_Index)
    set(hObject,'String',FieldDefault);
    set(handles.Sli_Fractal_Index,'Value',str2double(FieldDefault));
else
    set(handles.Sli_Fractal_Index,'Value',Val_Index);
end
%--------------------------------------------------------------------------

% --- Executes on button press in Rad_Random.
function Rad_Random_Callback(hObject, eventdata, handles)
% hObject    handle to Rad_Random (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',1);
set(handles.Rad_Value,'Value',0);
set(handles.Edi_Value,'enable','off');
%--------------------------------------------------------------------------

% --- Executes on button press in Rad_Value.
function Rad_Value_Callback(hObject, eventdata, handles)
% hObject    handle to Rad_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',1);
set(handles.Rad_Random,'Value',0);
set(handles.Edi_Value,'enable','on');
%--------------------------------------------------------------------------

% --- Executes on button press in Edi_Value.
function Edi_Value_Callback(hObject, eventdata, handles)
% hObject    handle to Edi_Value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FieldDefault ='1';
Val_Value = str2double(get(hObject,'String'));
if ~isequal(Val_Value,fix(Val_Value)) || Val_Value < 0 || isnan(Val_Value)
    set(hObject,'String',FieldDefault);
end
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Generate.
function Pus_Generate_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_Generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%----------
wwaiting('msg',hFig,'Wait ... cleaning');
cleanTOOL(handles);

% Computing.
%-----------
wwaiting('msg',hFig,'Wait ... computing');

% Get all the parameter settings.
%--------------------------------
% Wavelet used
Wav = cbanapar('get',hFig,'wav');                           
% Signal length (string)
Val_Length_Str = get(handles.Edi_Length,'String');                     
% Signal length (numeric)
Val_Length_Num = str2double(Val_Length_Str);                           
% Fractal index (string)
H = get(handles.Edi_Fractal_Index,'String');              
% Fractal index (numeric)
Val_Index = str2double(H);                                        
% Matrix of Refinement values
Val_Refinement = str2double(get(handles.Pop_Refinement,'String'));     
% Current Refinement value
Val_Refinement = Val_Refinement(get(handles.Pop_Refinement,'Value'));  
% Check if a value is used for seed
if get(handles.Rad_Value,'Value')                                       
    % Set seed generator with this value
    randn('state',str2double(get(handles.Edi_Value,'String')));         
end

% Compute Fractional Brownian Motion signal.
%-------------------------------------------
FBM_PARAMS.SEED = randn('state');
FBM = wfbm(Val_Index,Val_Length_Num,Val_Refinement,Wav);

% Synthesized Fractional Brownian Motion axes display.
%-----------------------------------------------------
axes(handles.Axe_FBM);
TFBM = 0:length(FBM)-1;
ext  = abs(max(FBM) - min(FBM)) / 100;
Ylim = [min(FBM)-ext max(FBM)+ext];
Xlim = [TFBM(1) TFBM(end)];
line(TFBM,FBM,'color','r');
set(handles.Axe_FBM,'Xlim',Xlim,'Ylim',Ylim);
FBM_title = ['Synthesized Fractional Brownian Motion ', ...
             'of parameter H = ',H,' using ',Wav];
setAxesTitle(handles.Axe_FBM,FBM_title);

% First order increments axes display.
%-------------------------------------
FBM1Dif = diff(FBM);
axes(handles.Axe_1Dif);
line(0:length(FBM1Dif)-1,FBM1Dif,'color','g');
ext = abs(max(FBM1Dif) - min(FBM1Dif)) / 100;
Ylim = [min(FBM1Dif)-ext max(FBM1Dif)+ext];
set(handles.Axe_1Dif,'Xlim',Xlim,'Ylim',Ylim);

% Set the axes visible.
%----------------------
set(handles.Axe_FBM,'Visible','on');
set(handles.Axe_1Dif,'Visible','on');

% Enable the Statistics Push_Button.
%-----------------------------------
set(handles.Pus_Statistics,'enable','on');

% get Menu Handles.
%------------------
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');

% Enable the Save Synthetisized signal Menu item.
%------------------------------------------------
set(hdl_Menus.m_save,'enable','on');

% Update Generated FBM Parameters.
%---------------------------------
FBM_PARAMS.FBM          = FBM;
FBM_PARAMS.Wav          = Wav;
FBM_PARAMS.Length       = Val_Length_Num;
FBM_PARAMS.H            = Val_Index;
FBM_PARAMS.Refinement   = Val_Refinement;
wtbxappdata('set',hFig,'FBM_PARAMS',FBM_PARAMS);

% Init DynVTool.
%---------------
axe_IND = [];
axe_CMD = [...
        handles.Axe_FBM , ...
        handles.Axe_1Dif ...
    ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Statistics.
function Pus_Statistics_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_Statistics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% get Tool Parameters.
%---------------------
FBM_PARAMS = wtbxappdata('get',hFig,'FBM_PARAMS');

% Call the wfbmstat figure and pass the FBM_PARAMS structure.
%------------------------------------------------------------
wfbmstat('WfbmtoolCall_Callback',hFig,[],handles,FBM_PARAMS);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_CloseWin.
function Pus_CloseWin_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_CloseWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    hFig = get(hObject,'Parent');
    status = wwaitans({hFig,'Fractional Brownian Motion'},...
        'Save the synthesized signal ?',2,'Cancel');
    switch status
        case -1 , return;
        case  1
            Men_SavSynthSig_Callback(m_save, eventdata, handles)
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------

%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%

% --- Executes on menu item press in File ---> Save Synthesized Signal.
function Men_SavSynthSig_Callback(hObject, eventdata, handles)
% hObject    handle to Men_SavSynthSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% Begin waiting.
%---------------
wwaiting('msg',hFig,'Wait ... saving');

% Update Tool Parameters.
%------------------------
FBM_PARAMS = wtbxappdata('get',hFig,'FBM_PARAMS');

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',hFig, ...
    '*.mat','Save Synthesized Signal');
if ~ok,
    wwaiting('off',hFig);   % End waiting.
    return; 
end

% Saving file.
%-------------
[name,ext] = strtok(filename,'.');
if isempty(ext) | isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end

try
    eval([name ' = FBM_PARAMS.FBM;']);
    FBM_PARAMS = rmfield(FBM_PARAMS,'FBM');
    save([pathname filename],name,'FBM_PARAMS','-mat');
catch          
    errargt(mfilename,'Save FAILED !','msg');
end

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------

function close_FUN(hObject,eventdata,handles)

Pus_CloseWin = handles.Pus_CloseWin;
Pus_CloseWin_Callback(Pus_CloseWin,eventdata,handles);
%--------------------------------------------------------------------------

%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%

function Init_Tool(hObject, eventdata, handles)

% WTBX -- Install DynVTool.
%--------------------------
dynvtool('Install_V3',hObject,handles);

% WTBX -- Install MENUS.
%-----------------------
wfigmngr('extfig',hObject,'ExtFig_GUIDE');
wfigmngr('attach_close',hObject);
set(hObject,'HandleVisibility','On');
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);

% WTBX -- Install ANAPAR FRAME.
%------------------------------
wnameDEF  = 'db10';  
utanapar('Install_V3_CB',hObject,'wtype','owt');
set(hObject,'Visible','On'); pause(0.01) %%% MiMi : BUG MATLAB %%%
cbanapar('set',hObject,'wav',wnameDEF);

% Set Title in the FBM axes (first time).
%----------------------------------------
title = 'Synthesized Fractional Brownian Motion';
setAxesTitle(handles.Axe_FBM,title);

% Set Title in the 1Dif axes (first time).
%-----------------------------------------
title = 'First order increments';
setAxesTitle(handles.Axe_1Dif,title);

% End Of initialization.
%-----------------------
redimfig('On',hObject);
set(hObject,'HandleVisibility','Callback');

%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%

function cleanTOOL(handles)
hAXES = [handles.Axe_FBM, handles.Axe_1Dif];
hLINES = findobj(hAXES,'type','line');
set(hAXES,'Visible','off');
delete(hLINES);
set(handles.Pus_Statistics,'enable','off');
%--------------------------------------------------------------------------

%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%

function hdl_Menus = Install_MENUS(hFig)

% Add UIMENUS.
%-------------
m_files  = wfigmngr('getmenus',hFig,'file');
m_close  = wfigmngr('getmenus',hFig,'close');
% cb_close = [mfilename '(''close_FUN'',gcbo,[],guidata(gcbo));'];
cb_close = [mfilename '(''Pus_CloseWin_Callback'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);
m_save   = uimenu(m_files,                  ...
    'Label','&Save Synthesized Signal',     ...
    'Position',1,                           ...
    'Enable','Off',                         ...
    'Callback',                             ...
    [mfilename '(''Men_SavSynthSig_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig,'&Fractional Brownian Motion Synthesis','WFBM_GUI');

% Add Help Item.
%----------------
% wfighelp('addHelpItem',hFig,'Continuous Transform','CW_TRANSFORM');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_save',m_save,'m_close',m_close);
%-------------------------------------------------------------------------

%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN General Utilities                                  %
%                -----------------------                                  %
%=========================================================================%

function setAxesTitle(axe,label)
axes(axe); 
title(label,'Color','k','FontWeight','demi','Units','normalized','Fontsize',9);
%--------------------------------------------------------------------------

function setAxesXlabel(axe,label)
axes(axe); 
xlabel(label,'Color','k','FontWeight','demi','normalized','Fontsize',9);
%--------------------------------------------------------------------------

function setAxesYlabel(axe,label)
axes(axe); 
ylabel(label,'Color','k','FontWeight','demi','normalized','Fontsize',9);
%--------------------------------------------------------------------------

%=========================================================================%
%                END Tool General Utilities                               %
%=========================================================================%


%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles,varargin)
close(hFig);
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin)

% Initialization for next plot
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tool_PARAMS.demoMODE = 'on';
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS );
set(hFig,'HandleVisibility','On')

handles  = guidata(hFig);
paramDEM = varargin{1};
hFbmVal = paramDEM{1,1};
typeDEM = paramDEM{1,2};
hdl_WinFbmStat = wtbxappdata('get',hFig,'hdl_WinFbmStat');
if ishandle(hdl_WinFbmStat) , delete(hdl_WinFbmStat); end
switch typeDEM
    case 'generate'
        Pus_Generate = handles.Pus_Generate;
        Edi_Fractal_Index = handles.Edi_Fractal_Index;
        Sli_Fractal_Index = handles.Sli_Fractal_Index;
        set(Sli_Fractal_Index,'Value',hFbmVal);
        set(Edi_Fractal_Index,'String',num2str(hFbmVal));
        Pus_Generate_Callback(Pus_Generate,eventdata,handles);

    case 'statistics'
        Pus_Statistics = handles.Pus_Statistics;
        OldFig = allchild(0);
        Pus_Statistics_Callback(Pus_Statistics,eventdata,handles);
        NewFig = allchild(0);
        hdl_WinFbmStat = setdiff(NewFig,OldFig);
        wfigmngr('modify_FigChild',hFig,hdl_WinFbmStat);
        wtbxappdata('set',hFig,'hdl_WinFbmStat',hdl_WinFbmStat);
end
set(hFig,'HandleVisibility','Callback')
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
