function varargout = nwavtool(varargin)
%NWAVTOOL New wavelet for continuous analysis tool.
%   VARARGOUT = NWAVTOOL(VARARGIN)

% NWAVTOOL M-file for nwavtool.fig
%      NWAVTOOL, by itself, creates a new NWAVTOOL or raises the existing
%      singleton*.
%
%      H = NWAVTOOL returns the handle to a new NWAVTOOL or the handle to
%      the existing singleton*.
%
%      NWAVTOOL('Property','Value',...) creates a new NWAVTOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to nwavtool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      NWAVTOOL('CALLBACK') and NWAVTOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in NWAVTOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 15-Jun-2003 17:49:17
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 25-Feb-2004.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/15 22:41:28 $ 


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nwavtool_OpeningFcn, ...
                   'gui_OutputFcn',  @nwavtool_OutputFcn, ...
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
% --- Executes just before nwavtool is made visible.                      %
%*************************************************************************%

function nwavtool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for nwavtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nwavtool wait for user response (see UIRESUME)
% uiwait(handles.Fig_Pat2Cwt);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code  %
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

function varargout = nwavtool_OutputFcn(hObject, eventdata, handles)
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

%=========================================================================%
%                END Create Functions                                     %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%

% --- Executes on selection change in Pop_ApproxMeth.
function Pop_ApproxMeth_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_ApproxMeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hPolDefFra  = [handles.Fra_PolDegree handles.Pop_PolDegree handles.Txt_PolDegree];
ApproxMeth  = getApproxMeth(hObject);
switch ApproxMeth
    case 'Polynomial' 
        set(hPolDefFra,'Visible','on');
        BoundCondStr = {'None';'Continuous';'Differentiable'};
    case 'OrthConst'
        set(hPolDefFra,'Visible','off');
        BoundCondStr = {'None';'Continuous'};
end
set(handles.Pop_BoundCond,'String',BoundCondStr);
set(handles.Pop_BoundCond,'Value',2);
Pop_PolDegree = get(handles.Pop_PolDegree,'Value');
set(handles.Pop_PolDegree,'Value',max([3,Pop_PolDegree]));
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------

function Edi_LowBound_Callback(hObject, eventdata, handles)
% hObject    handle to Edi_LowBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
LowInter = tool_PARAMS.LowInter;
LowBound = str2double(get(hObject,'String'));
if LowBound > LowInter | isnan(LowBound)
    set(hObject,'String',sprintf('%0.4g',LowInter));
end
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------

function Edi_UppBound_Callback(hObject, eventdata, handles)
% hObject    handle to Edi_UppBound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
UppInter = tool_PARAMS.UppInter;
UppBound = str2double(get(hObject,'String'));
if UppBound < UppInter  | isnan(UppBound)
    set(hObject,'String',sprintf('%0.4g',UppInter));
end 
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_PolDegree.
function Pop_PolDegree_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_PolDegree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApproxMeth = getApproxMeth(handles.Pop_ApproxMeth);
switch ApproxMeth
    case 'Polynomial'
        Regularity = getRegularity(handles.Pop_BoundCond);
        PolDegree  = get(hObject,'Value');
        NBConstraint = 1 + 2*(Regularity + 1);
        freeDegree = PolDegree - NBConstraint;
        if freeDegree<0
            Regularity = floor((PolDegree-3)/2);
        end
        set(handles.Pop_BoundCond,'Value',Regularity+2);
        
    case 'OrthConst',
end
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_BoundCond.
function Pop_BoundCond_Callback(hObject, eventdata, handles)
% hObject    handle to Pop_BoundCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ApproxMeth = getApproxMeth(handles.Pop_ApproxMeth);
switch ApproxMeth
    case 'Polynomial'
        Regularity = getRegularity(hObject);
        PolDegree  = get(handles.Pop_PolDegree,'Value');
        NBConstraint = 1 + 2*(Regularity + 1);
        freeDegree = PolDegree - NBConstraint;
        if freeDegree<0
            Regularity = floor((PolDegree-3)/2);
        end
        set(handles.Pop_PolDegree,'Value',NBConstraint);
    case 'OrthConst',
end
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
hRunSig     = tool_PARAMS.hRunSig;
set(hRunSig,'Enable','Off');
%--------------------------------------------------------------------------

% --- Executes on button press in Rad_Trans.
function Rad_Trans_Callback(hObject, eventdata, handles)
% hObject    handle to Rad_Trans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',1);
set(handles.Rad_Super,'Value',0);
%--------------------------------------------------------------------------

% --- Executes on button press in Rad_Super.
function Rad_Super_Callback(hObject, eventdata, handles)
% hObject    handle to Rad_Super (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Value',1);
set(handles.Rad_Trans,'Value',0);
%--------------------------------------------------------------------------

% --- Executes on button press in Chk_Noise.
function Chk_Noise_Callback(hObject, eventdata, handles)
% hObject    handle to Chk_Noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------

% --- Executes on button press in Chk_Triangle.
function Chk_Triangle_Callback(hObject, eventdata, handles)
% hObject    handle to Chk_Triangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Approximate.
function Pus_Approximate_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_Approximate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%-----------
wwaiting('msg',hFig,'Wait ... cleaning');
cleanTOOL([handles.Axe_PatWav handles.Axe_RunSig handles.Axe_Detect]);
ColorBarVisibility(handles.Axe_ColBar,'Off');

% Computing.
%-----------
wwaiting('msg',hFig,'Wait ... computing');

% Get parameter values.
%----------------------
tool_PARAMS     = wtbxappdata('get',hObject,'tool_PARAMS');
X               = tool_PARAMS.X;
Y               = tool_PARAMS.Y;
hRunSig         = tool_PARAMS.hRunSig;
ApproxMeth      = getApproxMeth(handles.Pop_ApproxMeth);
LowBound        = str2double(get(handles.Edi_LowBound,'String'));
UppBound        = str2double(get(handles.Edi_UppBound,'String'));
PolDegreeStr    = get(handles.Pop_PolDegree,'String');
PolDegreeVal    = get(handles.Pop_PolDegree,'Value');
PolDegree       = str2double(PolDegreeStr{PolDegreeVal});
BoundCondStr    = get(handles.Pop_BoundCond,'String');
BoundCondVal    = get(handles.Pop_BoundCond,'Value');
BoundCond       = BoundCondStr{BoundCondVal};
switch ApproxMeth
    case 'Polynomial'
        switch BoundCond
            case 'Continuous' ,   , Regularity =  0;
            case 'Differentiable' , Regularity =  1;
            otherwise ,             Regularity = -1;
        end
    case 'OrthConst'
        switch BoundCond
            case 'none'           , Regularity = -1; PolDegree = 0;
            case 'Continuous' ,   , Regularity =  0; PolDegree = 2;
            otherwise ,             Regularity = -1; PolDegree = 0;
        end
end

% Compute approximation.
%-----------------------
[PSI,X_PSI,NC_PSI] = pat2cwav(Y,ApproxMeth,PolDegree,Regularity);
PSI_pat = NC_PSI*PSI;     % Approximation of the original pattern.
deltaX   = 0.05;
XVAL_PSI = [LowBound-deltaX,LowBound,min(X_PSI)-eps, ...
            NaN,X_PSI,NaN,max(X_PSI)+eps,UppBound,UppBound+deltaX];
XVAL_FUN = [LowBound-deltaX,LowBound,NaN,X,NaN,UppBound,UppBound+deltaX];
YVAL_PSI = [0,0,0,NaN,PSI_pat,NaN,0,0,0];
YVAL_FUN = [NaN,NaN,NaN,Y,NaN,NaN,NaN];

% Store PSI.
%-----------
tool_PARAMS        = wtbxappdata('get',hObject,'tool_PARAMS');
tool_PARAMS.PSI    = PSI;
tool_PARAMS.NC_PSI = NC_PSI;
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

% Pattern and wavelet axes display.
%----------------------------------
lw = 1;
axes(handles.Axe_PatWav);
line(XVAL_FUN,YVAL_FUN,'color','r','linewidth',max(lw,2));
line(XVAL_PSI,YVAL_PSI,'color','g','linewidth',max(lw,2));
Xlim = [LowBound-deltaX UppBound+deltaX];
Ymin = min(min(PSI_pat),min(Y));
Ymax = max(max(PSI_pat),max(Y));
ext = abs(Ymax - Ymin) / 100;
Ylim = [Ymin-ext Ymax+ext];
set(handles.Axe_PatWav,'Xlim',Xlim,'Ylim',Ylim);

% Init DynVTool.
%---------------
axe_IND = [...
            handles.Axe_Pattern ,   ...
            handles.Axe_PatWav      ...
            ];
axe_CMD = [...
            handles.Axe_RunSig ,    ...
            handles.Axe_Detect      ...
            ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% Set the axes visible.
%----------------------
set(handles.Axe_PatWav,'Visible','on');

% Set visible and enabled uicontrols.
%------------------------------------
set(hRunSig,'Visible','on','Enable','On');

% get Menu Handles.
%------------------
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');

% Enable the Save Synthetisized signal Menu item.
%------------------------------------------------
set(hdl_Menus.m_save,'enable','on');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Run.
function Pus_Run_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%-----------
wwaiting('msg',hFig,'Wait ... cleaning');
cleanTOOL([handles.Axe_RunSig handles.Axe_Detect]);
% ColorBarVisibility(handles.Axe_ColBar,'On');

% Computing.
%-----------
wwaiting('msg',hFig,'Wait ... computing');

% Get parameter values.
%----------------------
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
X           = tool_PARAMS.X;
Y           = tool_PARAMS.Y;
PSI         = tool_PARAMS.PSI;
RadTrans    = get(handles.Rad_Trans,'Value');
RadSuper    = get(handles.Rad_Super,'Value');
ChkNoise    = get(handles.Chk_Noise,'Value');
ChkTriangle = get(handles.Chk_Triangle,'Value');

% Running signal construction.
%-----------------------------
titleSTR{1} = 'Running Signal';
if RadTrans
    nbFormeBASE = 8; scaleBASE = 8; rapport = 2; PONDERATIONS =  [1,1];
    signalBASE = getSignal('translate',Y,rapport,PONDERATIONS,nbFormeBASE);
    lenSIG  = length(signalBASE);
    scaleMIN = 1;
    scaleMAX = 2*scaleBASE;
    NoiseLevel = 1.25;
    titleSTR{2} = 'F((t-20)/8) + sqrt(2)\timesF((t-40)/4)';
else
    nbFormeBASE = 3; scaleBASE = 32; rapport = 4; PONDERATIONS =  [1,1];
    signalBASE = getSignal('superpose',Y,rapport,PONDERATIONS,nbFormeBASE);
    lenSIG  = length(signalBASE);
    scaleMIN = 1;
    scaleMAX = 2*scaleBASE;
    NoiseLevel = 0.75;
    titleSTR{2} = 'F((t-40)/32) + 2\timesF((t-40)/8)';
end
signal = signalBASE;

if ChkNoise
    NoiseLevel = NoiseLevel*std(signal);
    Noise = NoiseLevel*randn(1,lenSIG);
    signal = signal + Noise;
    titleSTR{2} = [titleSTR{2} ' + N'];
end
if ChkTriangle
    L = lenSIG/2;
    Triangle = [1:floor(L) , ceil(L):-1:1]/ceil(L);
    signal = signal + Triangle;
    titleSTR{2} = [titleSTR{2} ' + T'];
end
intervalleSIG = [0,nbFormeBASE*scaleBASE];
stepSIG = (intervalleSIG(2)-intervalleSIG(1))/(lenSIG-1);
xvalSIG = linspace(intervalleSIG(1),intervalleSIG(2),lenSIG);
stepScales = 1;
scales  = [scaleMIN:stepScales:scaleMAX];

% Running signal axes display.
%-----------------------------
lw = 1;
axes(handles.Axe_RunSig);
line(xvalSIG,signal,'color','b','linewidth',lw);
Xlim = intervalleSIG;
ext = abs(max(signal) - min(signal)) / 100;
Ylim = [min(signal)-ext max(signal)+ext];
set(handles.Axe_RunSig,'Xlim',Xlim,'Ylim',Ylim);
setAxesTitle(handles.Axe_RunSig,titleSTR);

% Set the axes visible.
%----------------------
set(handles.Axe_RunSig,'Visible','on');

% Compute the cwt.
%-----------------
C_psi = cwt({signal,stepSIG},scales,PSI);

% Find the coordinates of max coefs.
%-----------------------------------
[ROW_psi,COL_psi] = maxCoefs(C_psi);

% Plot contours and local grid lines.
%------------------------------------
plotCONTOUR(C_psi,scales,xvalSIG,handles.Axe_Detect,handles.Axe_ColBar);
LocalGrid(handles.Axe_Detect,RadTrans)

% Set the axes visible.
%----------------------
set(handles.Axe_Detect,'Visible','on');

% Set Colorbar visible.
%----------------------
ColorBarVisibility(handles.Axe_ColBar,'On');

% Init DynVTool.
%---------------
axe_IND = [...
        handles.Axe_Pattern , ...
        handles.Axe_PatWav ...
        ];
axe_CMD = [...
        handles.Axe_RunSig , ...
        handles.Axe_Detect ...
        ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Compare.
function Pus_Compare_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_Compare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% get Tool Parameters.
%---------------------
Nwavetool_PARAMS             = wtbxappdata('get',hFig,'tool_PARAMS');
Nwavetool_PARAMS.RadTrans    = get(handles.Rad_Trans,'Value');
Nwavetool_PARAMS.RadSuper    = get(handles.Rad_Super,'Value');
Nwavetool_PARAMS.ChkNoise    = get(handles.Chk_Noise,'Value');
Nwavetool_PARAMS.ChkTriangle = get(handles.Chk_Triangle,'Value');
Nwavetool_PARAMS.Pus_Compare = handles.Pus_Compare;

% Call the compwav figure and pass the tool_PARAMS structure.
%------------------------------------------------------------
% compwav('NwavtoolCall_Callback',gcbo,[],guidata(gcbo),Nwavetool_PARAMS)
compwav('NwavtoolCall_Callback',hFig,[],handles,Nwavetool_PARAMS);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_CloseWin.
function Pus_CloseWin_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_CloseWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
hFig = get(hObject,'Parent');
if isequal(lower(ena_Save),'on')
    status = wwaitans({hFig,'Save Adapted Wavelet'},...
        'Save the adapted wavelet ?',2,'Cancel');
    switch status
        case -1 , return;
        case  1
            Men_SaveWave_Callback(m_save, eventdata, handles)
        otherwise
    end
end
delete(handles.Axe_ColBar); % BUG AXES
close(hFig) 
%--------------------------------------------------------------------------

%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%

% --- Executes on menu item press in File ---> Load Pattern.
function Men_LoadPat_Callback(hObject, eventdata, handles, pathname, filename)
% hObject    handle to Men_LoadPat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
if nargin<4
    [sigInfos,sig_Anal,ok] = ...
        utguidiv('load_sig',hFig,'*.mat','Load Pattern');
    if ok
        pathname = sigInfos.pathname;         
        filename = sigInfos.filename;
    end
else
    ok = 1;
    try
        load(filename)
    catch
        ok = 0;
    end
end
if ~ok, return; end

% Cleaning.
%-----------
wwaiting('msg',hFig,'Wait ... cleaning');
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
set(hdl_Menus.m_save,'Enable','Off');
cleanTOOL([ handles.Axe_Pattern handles.Axe_PatWav ...
            handles.Axe_RunSig handles.Axe_Detect]);
ColorBarVisibility(handles.Axe_ColBar,'Off');

% Reinitialization of the GUI default values.
%--------------------------------------------
hPolDefFra  = [handles.Fra_PolDegree handles.Pop_PolDegree handles.Txt_PolDegree];
set(hPolDefFra,'Visible','on');
BoundCondStr = {'None';'Continuous';'Differentiable'};
set(handles.Pop_BoundCond,'String',BoundCondStr);
set(handles.Pop_BoundCond,'Value',2);
set(handles.Pop_ApproxMeth,'Value',1);
set(handles.Pop_PolDegree,'Value',3);
set(handles.Rad_Super,'Value',0);
set(handles.Rad_Trans,'Value',1);
set(handles.Chk_Noise,'Value',0);
set(handles.Chk_Triangle,'Value',0);

% Loading file.
%--------------
[name,ext] = strtok(filename,'.');
if isempty(ext) | isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end
try
    fullName = [pathname filename];
    % fileStruct = whos('-file',fullName);
    TMP = load(fullName);
    DUM = fieldnames(TMP);
    idxY = find(strcmp(DUM,'Y'));
    if ~isempty(idxY)
        Y = TMP.(DUM{idxY});
    else
        Y = TMP.(DUM{1});
    end
    clear TMP DUM idxY
catch          
    errargt(mfilename,'Load FAILED !','msg');
    wwaiting('off',hFig);
    return;
end

% Get variable values.
%---------------------
X = linspace(0,1,length(Y));
if size(X)~=size(Y) , Y = Y'; end
LowInter = X(1);
UppInter = X(end);
Interval = sprintf('[%0.4g , %0.4g]',LowInter,UppInter);

% Store variable values.
%-----------------------
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
tool_PARAMS.LowInter = LowInter;
tool_PARAMS.UppInter = UppInter;
tool_PARAMS.X = X;
tool_PARAMS.Y = Y;
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

% Update uicontrols on the command part.
%---------------------------------------
set(handles.Edi_Pattern,'String',name);
set(handles.Edi_Interval,'String',Interval);
set(handles.Edi_LowBound,'String',sprintf('%0.4g',LowInter));
set(handles.Edi_UppBound,'String',sprintf('%0.4g',UppInter));
set(handles.Pus_Approximate,'Enable','on');

% Axe_Pattern axes display.
%--------------------------
lw = 1;
axes(handles.Axe_Pattern);
line(X,Y,'color','r','linewidth',lw);
ext     = abs(max(Y) - min(Y)) / 100;
Ylim    = [min(Y)-ext max(Y)+ext];
Xlim    = [min(X) max(X)];
set(handles.Axe_Pattern,'Xlim',Xlim,'Ylim',Ylim);

% Set Title in the pattern axes.
%-------------------------------
IntegVAL = 0.5*sum((Y(1:end-1)+Y(2:end)).*diff(X));
titleSTR{1} = ['Pattern F'];
titleSTR{2} = ['(Integral = ' num2str(IntegVAL,4) ')'];
setAxesTitle(handles.Axe_Pattern,titleSTR);

% Set the axes visible.
%----------------------
set(handles.Axe_Pattern,'Visible','on');

% Set unvisible the running signal block of uicontrols.
%----------------------------------------------------
set(tool_PARAMS.hRunSig,'Enable','Off');

% Init DynVTool.
%---------------
axe_IND = [...
        handles.Axe_Pattern , ...
        handles.Axe_PatWav ...
        ];
axe_CMD = [...
        handles.Axe_RunSig , ...
        handles.Axe_Detect ...
        ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on menu item press in File ---> Save Adapted Wavelet.
function Men_SaveWave_Callback(hObject, eventdata, handles)
% hObject    handle to Men_SaveWave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get figure handle.
%-------------------
hFig = handles.output;

% Begin waiting.
%---------------
wwaiting('msg',hFig,'Wait ... saving');

% Get PSI values.
%----------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
Y = tool_PARAMS.PSI;
LowInter = tool_PARAMS.LowInter;
UppInter = tool_PARAMS.UppInter;
X = linspace(LowInter,UppInter,length(Y));

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',hFig, ...
    '*.mat','Save Adapted Wavelet');
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
    save([pathname filename],'X','Y','-mat');
catch          
    errargt(mfilename,'Save FAILED !','msg');
end

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------

function demo_FUN(hObject,eventdata,handles,numDEM)

% Default Demo Parameters.
%-------------------------
LowInter = 0; UppInter =  1;
TransVAL =  1; NoiseVAL =  0; TrianVAL = 0;
switch numDEM
    case 1 , 
        filename = 'ptpssin1';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = -1;
    case 2 , 
        filename = 'ptpssin1';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity =  0;
    case 3 ,
        filename = 'ptpssin1';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = -1;
        TransVAL = 0;
    case 4 ,
        filename = 'ptpssin1';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        TransVAL = 0;
    case 5 , 
        filename = 'ptpssin2';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = 0;
    case 6 , 
        filename = 'ptpssin2';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 7 , 
        filename = 'ptsine';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = 0;
        NoiseVAL =  1; TrianVAL = 1;        
    case 8 , 
        filename = 'ptsine';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        NoiseVAL =  1; TrianVAL = 1;
    case 9 , 
        filename = 'ptsumsin';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = 0;
    case 10 , 
        filename = 'ptsumsin';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 11 , 
        filename = 'ptsinpol';
        methode  = 'Polynomial'; PolDegree  = 6; Regularity = 0;
        NoiseVAL = 1;
    case 12 , 
        filename = 'ptsinpol';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        NoiseVAL = 1;
    case 13 , 
        filename = 'ptodtri';
        methode  = 'Polynomial'; PolDegree  = 5; Regularity = 0;
    case 14 , 
        filename = 'ptodtri';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 15 , 
        filename = 'pat8_256';
        methode  = 'Polynomial'; PolDegree  = 3; Regularity = 0;
    case 16 , 
        filename = 'pthaar';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 17 , 
        filename = 'pthaar';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = -1;
    case 18 , 
        filename = 'ptodlin';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 19 , 
        filename = 'ptodpoly';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        TransVAL = 0;
    case 20 , 
        filename = 'ptbumps';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
    case 21 , 
        filename = 'ptbumps';
        methode  = 'OrthConst';   PolDegree  = 3; Regularity = 0;
        TransVAL = 0;
end

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing and loading file.
%--------------------------
filename = [filename '.mat'];
pathname = utguidiv('WTB_DemoPath',filename);
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_load = hdl_Menus.m_load;
Men_LoadPat_Callback(m_load,eventdata,handles,pathname,filename);

% Setting Method, PolDegree, Regularity.
%---------------------------------------
popHDL = handles.Pop_ApproxMeth;
switch methode
    case 'Polynomial' , popVAL = 1;
    case 'OrthConst'  , popVAL = 2;
end
set(popHDL,'Value',popVAL);
Pop_ApproxMeth_Callback(popHDL, eventdata, handles);
popHDL = handles.Pop_PolDegree;
set(popHDL,'Value',PolDegree);
popHDL = handles.Pop_BoundCond;
popVAL = Regularity + 2;
set(popHDL,'Value',popVAL);
set(handles.Edi_LowBound,'String',sprintf('%0.4g',LowInter));
set(handles.Edi_UppBound,'String',sprintf('%0.4g',UppInter));

% Setting Run Parameters.
%------------------------
set(handles.Rad_Trans,'Value',TransVAL);
set(handles.Rad_Super,'Value',1-TransVAL);
set(handles.Chk_Noise,'Value',NoiseVAL);
set(handles.Chk_Triangle,'Value',TrianVAL);

% Approximation and Run.
%-----------------------
Pus_Approximate_Callback(handles.Pus_Approximate, eventdata, handles)
Pus_Run_Callback(handles.Pus_Run, eventdata, handles)
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

% Set Title in the pattern axes.
%-------------------------------
titleSTR = 'Original Pattern';
setAxesTitle(handles.Axe_Pattern,titleSTR);

% Set Title in the pattern and adapted wavelet axes.
%---------------------------------------------------
titleSTR = 'Pattern and Adapted Wavelet';
setAxesTitle(handles.Axe_PatWav,titleSTR);

% Set Title in the running signal axes.
%--------------------------------------
titleSTR = 'F((x-20) / 8 + (x-48) / 4) + T + N';
setAxesTitle(handles.Axe_RunSig,titleSTR);

% Set Title in the pattern detection axes.
%-----------------------------------------
titleSTR = 'Pattern Detection using Adapted Wavelet';
setAxesTitle(handles.Axe_Detect,titleSTR);

% Initialize colorbar.
%---------------------
cmap = get(hObject,'Colormap');
axes(handles.Axe_ColBar);
image([1:size(cmap,1)])
set(handles.Axe_ColBar,...
    'Xtick',[],'Xticklabel',[],'Ytick',[],'Yticklabel',[] ...    
    );
dynvzaxe('exclude',hObject,handles.Axe_ColBar)
ColorBarVisibility(handles.Axe_ColBar,'Off');

% Save Tool Parameters.
%----------------------
hRunSig  =   [                                                  ...
                handles.Fra_RunSignal, handles.Txt_RunSignal,   ...
                handles.Txt_TwoPatterns, handles.Txt_With,      ...
                handles.Rad_Trans, handles.Rad_Super,           ...
                handles.Chk_Noise, handles.Chk_Triangle,        ...
                handles.Pus_Run, handles.Pus_Compare            ...
            ];
tool_PARAMS.hRunSig = hRunSig;
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

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
hLINES  = findobj(handles,'type','line');
hPATCH  = findobj(handles,'type','patch');
hIMAGES  = findobj(handles,'type','image');
delete(hLINES,hPATCH,hIMAGES);
set(handles,'Visible','off');
%--------------------------------------------------------------------------

function ColorBarVisibility(Axe_ColBar,status)
hIMAGES = wfindobj(Axe_ColBar,'type','image');
set(Axe_ColBar,'Visible',status);
set(hIMAGES,'Visible',status);
%-------------------------------------------------------------------------

%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%

function ApproxMeth = getApproxMeth(Pop_ApproxMeth)

ApproxMethVal = get(Pop_ApproxMeth,'Value');
switch ApproxMethVal
    case 1 , ApproxMeth = 'Polynomial';
    case 2 , ApproxMeth = 'OrthConst';
end

%-------------------------------------------------------------------------

function Regularity = getRegularity(Pop_BoundCond)

Regularity = get(Pop_BoundCond,'Value')-2;

%-------------------------------------------------------------------------

function hdl_Menus = Install_MENUS(hFig)

% Add UIMENUS.
%-------------
m_files     = wfigmngr('getmenus',hFig,'file');
m_close = wfigmngr('getmenus',hFig,'close');
cb_close = [mfilename '(''close_FUN'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

str_numwin  = sprintf('%20.15f',hFig);

m_load  = uimenu(m_files,                   ...
    'Label','&Load Pattern',                 ...
    'Position',1,                           ...
    'Enable','On',                          ...
    'Callback',                             ...
    [mfilename '(''Men_LoadPat_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

m_save  = uimenu(m_files,                   ...
    'Label','&Save Adapted Wavelet',        ...
    'Position',2,                           ...
    'Enable','Off',                          ...
    'Callback',                             ...
    [mfilename '(''Men_SaveWave_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

m_demo  = uimenu(m_files,'Label','&Example ','Position',3,'Separator','On');
tab = setstr(9);
demoSET = {...
        ['Pattern 1' tab '- Not-Continuous Polynomial Approximation of d°3']; ...
        ['Pattern 1' tab '- Continuous Polynomial Approximation of d°3'];     ...
        ['Pattern 1' tab '- Not-Continuous OrthoPolynomial Approximation'];   ...
        ['Pattern 1' tab '- Continuous OrthoPolynomial Approximation'];       ...
        ['Pattern 2' tab '- Continuous Polynomial Approximation of d°3'];     ...
        ['Pattern 2' tab '- Continuous OrthoPolynomial Approximation'];       ...
        ['Pattern 3' tab '- Continuous Polynomial Approximation of d°3'];     ...
        ['Pattern 3' tab '- Continuous OrthoPolynomial Approximation'];       ...
        ['Pattern 4' tab '- Continuous Polynomial Approximation of d°3'];     ...
        ['Pattern 4' tab '- Continuous OrthoPolynomial Approximation'];       ...
        ['Pattern 5' tab '- Continuous Polynomial Approximation of d°6'];     ...
        ['Pattern 5' tab '- Continuous OrthoPolynomial Approximation'];       ...
        ['Pattern 6' tab '- Continuous Polynomial Approximation of d°5'];     ...
        ['Pattern 6' tab '- Continuous OrthoPolynomial Approximation'];       ...
        ['Pattern 7' tab '- Continuous Polynomial Approximation of d°5'];     ...
        ['Pattern 7' tab '- Continuous OrthoPolynomial Approximation'];       ...
        ['Pattern 8' tab '- Not-Continuous OrthoPolynomial Approximation'];   ...
        ['Pattern 9' tab '- Not-Continuous OrthoPolynomial Approximation'];   ...
        ['Pattern 10' tab '- Not-Continuous OrthoPolynomial Approximation'];  ...
        ['Pattern 11' tab '- Not-Continuous OrthoPolynomial Approximation'];  ...
        ['Pattern 12' tab '- Not-Continuous OrthoPolynomial Approximation'];  ...                
};
nbDEM = size(demoSET,1);
sepSET = [5,9,13];
for k = 1:nbDEM
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else , Sep = 'Off'; end
    uimenu(m_demo,'Label',[demoSET{k,1}],'Separator',Sep,'Callback',action);
end
hdl_Menus = struct('m_files',m_files,'m_close',m_close,'m_save',m_save);

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig,'&New Wavelet for CWT','NWAV_GUI');

% Add Help Item.
%----------------
% wfighelp('addHelpItem',hFig,'Continuous Transform','CW_TRANSFORM');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_load',m_load,'m_save',m_save);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function signalBASE = getSignal(typeSIG,FormeBASE,rapport,PONDERATIONS,nbFormeBASE)
Forme_1 = FormeBASE;
len_F1  = length(Forme_1);
x_new   = linspace(0,1,len_F1/rapport);
x_old   = linspace(0,1,len_F1);        
Forme_2 = (rapport^0.5)*interp1(x_old,Forme_1,x_new);
len_F2  = length(Forme_2);
Forme_1 = PONDERATIONS(1)*Forme_1;
Forme_2 = PONDERATIONS(2)*Forme_2;
signalBASE = zeros(1,nbFormeBASE*len_F1);
switch typeSIG
	case 'superpose'
        deb = floor(((nbFormeBASE-1)/2-1/4)*len_F1) + 1; fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = deb + floor((len_F1-len_F2)/2); fin = deb + len_F2-1;
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;

	case 'translate'
        deb = 2*len_F1; fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = floor(5*len_F1-len_F2/2); fin = deb + len_F2-1;        
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;
end
%-------------------------------------------------------------------------

function plotCONTOUR(C,scales,xvalSIG,Axe_Detect,Axe_ColBar)

% Compute and plot contours.
%---------------------------
axes(Axe_Detect);
maxi = max(max(abs(C))); 
D = abs(C)/maxi;
xval = [0.7:0.025:1]; 
contour(xvalSIG,scales,D,xval);

% Set Title in the pattern detection axes.
%-----------------------------------------
titleSTR = 'Pattern Detection using Adapted Wavelet';
setAxesTitle(Axe_Detect,titleSTR);
setAxesATTRB(scales,xvalSIG,Axe_Detect);

% Set Contour Values.
%--------------------
nbTICS = 7;
xlim = get(Axe_ColBar,'Xlim');
alfa = (xlim(2)-xlim(1))/(xval(end)-xval(1));
beta = xlim(1)-alfa*xval(1);
xCOL  = linspace(xval(1),xval(end),nbTICS);
xtics = alfa*xCOL + beta;
xlabs = num2str(xCOL(:),2);
set(Axe_ColBar, ...
        'XTick',xtics, ...
        'XTickLabel',xlabs ...
        );
%-------------------------------------------------------------------------

function setAxesATTRB(scales,xvalSIG,axe)
nb_SCALES = length(scales);
nb    = min(5,nb_SCALES);
level = '';
for k=1:nb , level = [level ' '  num2str(scales(k))]; end
if nb<nb_SCALES , level = [level ' ...']; end
nb    = ceil(nb_SCALES/20);
ytics = nb:nb:nb_SCALES;
tmp   = scales(nb:nb:nb*length(ytics));
ylabs = num2str(tmp(:));
set(axe, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Box','On' ...
        );
%-------------------------------------------------------------------------

function [ROW,COL] = maxCoefs(C)
[nb_ROW,nb_COL] = size(C);
D = abs(C(:));
[dummy,idx] = max(D);

col_INF = fix(idx/nb_ROW);
ROW = idx - nb_ROW*col_INF;
if ROW~=0
    COL = col_INF+1;
else
    COL = col_INF; ROW = nb_ROW;
end
%-------------------------------------------------------------------------

function LocalGrid(Axe_Detect,RadTrans)
axes(Axe_Detect)
if RadTrans
    line([20 20],[0 8],'color','k','LineStyle','--');
    line([0 20],[8 8],'color','k','LineStyle','--');
    line([40 40],[0 4],'color','k','LineStyle','--');
    line([0 40],[4 4],'color','k','LineStyle','--');
    line(20,8,'color','k','Marker','*');
    line(40,4,'color','k','Marker','*');
else
    line([40 40],[0 32],'color','k','LineStyle','--');
    line([0 40],[32 32],'color','k','LineStyle','--');
    line([40 40],[0 8],'color','k','LineStyle','--');
    line([0 40],[8 8],'color','k','LineStyle','--');
    line(40,32,'color','k','Marker','*');
    line(40,8,'color','k','Marker','*');
end
%-------------------------------------------------------------------------

%*************************************************************************

%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN General Utilities                                  %
%                -----------------------                                  %
%=========================================================================%
%--------------------------------------------------------------------------
function setAxesTitle(axe,label)
axes(axe); 
title(label,'Color','k','FontWeight','demi','Units','normalized','Fontsize',9);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function setAxesXlabel(axe,label)
axes(axe); 
xlabel(label,'Color','k','FontWeight','demi','Units','normalized','Fontsize',9);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function setAxesYlabel(axe,label)
axes(axe); 
ylabel(label,'Color','k','FontWeight','demi','Units','normalized','Fontsize',9);
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
typeDEM  = paramDEM{1,1};
hdl_WinCompWav = wtbxappdata('get',hFig,'hdl_WinCompWav');
switch typeDEM
    case 'run'
        numDEM = paramDEM{1,2};
        if ishandle(hdl_WinCompWav) , delete(hdl_WinCompWav); end
        demo_FUN(hFig,eventdata,handles,numDEM);

    case 'compare'
        if ishandle(hdl_WinCompWav) , delete(hdl_WinCompWav); end
        Pus_Compare = handles.Pus_Compare;
        OldFig = allchild(0);
        Pus_Compare_Callback(Pus_Compare,eventdata,handles);
        NewFig = allchild(0);
        hdl_WinCompWav = setdiff(NewFig,OldFig);
        wfigmngr('modify_FigChild',hFig,hdl_WinCompWav);
        wtbxappdata('set',hFig,'hdl_WinCompWav',hdl_WinCompWav);
        
    case 'compare_2'
        waveDEM = paramDEM{1,3};
        compwav('demoPROC',hdl_WinCompWav,[],[],waveDEM);
end
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
