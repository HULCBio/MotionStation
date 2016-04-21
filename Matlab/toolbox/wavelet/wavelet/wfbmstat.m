function varargout = wfbmstat(varargin)
%WFBMSTAT Fractional Brownian motion statistics tool.
%   VARARGOUT = WFBMSTAT(VARARGIN)

% WFBMSTAT M-file for wfbmstat.fig
%      WFBMSTAT, by itself, creates a new WFBMSTAT or raises the existing
%      singleton*.
%
%      H = WFBMSTAT returns the handle to a new WFBMSTAT or the handle to
%      the existing singleton*.
%
%      WFBMSTAT('Property','Value',...) creates a new WFBMSTAT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wfbmstat_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WFBMSTAT('CALLBACK') and WFBMSTAT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WFBMSTAT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 10-Sep-2003 15:54:48
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Mar-2003.
%   Last Revision: 10-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:42:45 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @wfbmstat_OpeningFcn, ...
    'gui_OutputFcn',  @wfbmstat_OutputFcn, ...
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
% --- Executes just before wfbmstat is made visible.                      %
%*************************************************************************%

function wfbmstat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for wfbmstat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wfbmstat wait for user response (see UIRESUME)
% uiwait(handles.wfbmStat_Win);

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

% --- Outputs from this function are returned to the command line.
function varargout = wfbmstat_OutputFcn(hObject, eventdata, handles)
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

% --- Executes on button press in Edi_NbBins.
function Edi_NbBins_Callback(hObject, eventdata, handles)
% hObject    handle to Edi_NbBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FieldDefault ='50';
NbBins = str2double(get(hObject,'String'));
if ~isequal(NbBins,fix(NbBins)) || NbBins <= 0 || isnan(NbBins)
    set(hObject,'String',FieldDefault);
end
%--------------------------------------------------------------------------

% --- Executes on button press in Chk_Hist.
function Chk_Hist_Callback(hObject, eventdata, handles)
% hObject    handle to Chk_Hist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------

% --- Executes on button press in Chk_Auto.
function Chk_Auto_Callback(hObject, eventdata, handles)
% hObject    handle to Chk_Auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------

% --- Executes on button press in Chk_Stats.
function Chk_Stats_Callback(hObject, eventdata, handles)
% hObject    handle to Chk_Stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Statistics.
function Pus_Statistics_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_Statistics (see GCBO)
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

% Parameters initialization.
%---------------------------
default_bins = 50;
curr_color   = wtbutils('colors','res');

% Get FBM_PARAMS parameters.
%---------------------------
FBM_PARAMS = get(hFig,'Userdata');

% Get uicontrol values.
%----------------------
DiffOrder_Str   = get(handles.Pop_DiffOrder,'String');  % Diff. order (string)
DiffOrder_Ind   = get(handles.Pop_DiffOrder,'Value');   % Diff. order (Index)
DiffOrder_Str   = DiffOrder_Str{DiffOrder_Ind,:};       % Diff. order (string)
DiffOrder_Num   = str2double(DiffOrder_Str);            % Diff. order (numeric)
NumBins_Str     = get(handles.Edi_NbBins,'String');     % Bins (string)
NumBins_Num     = str2double(NumBins_Str);              % Bins (numeric)

% Compute values to display.
%---------------------------
if DiffOrder_Num==0
    FBMxDif = FBM_PARAMS.FBM;
else
    FBMxDif = diff(FBM_PARAMS.FBM,DiffOrder_Num);
end
his             = wgethist(FBMxDif(:),NumBins_Num);
[xx,imod]       = max(his(2,:));
mode_val        = (his(1,imod)+his(1,imod+1))/2;

% Get check status.
%------------------
Chk_Hist    = get(handles.Chk_Hist,'value');
Chk_Auto    = get(handles.Chk_Auto,'value');
Chk_Stats   = get(handles.Chk_Stats,'value');

% Displaying axes depending on check status.
%-------------------------------------------
if Chk_Hist & Chk_Auto & Chk_Stats
    axe_xdif    = handles.Axe_xDif;
	axe_hist    = handles.Axe_Hist;
	axe_cumhist = handles.Axe_CumHist;
	axe_corr    = handles.Axe_AutoCorr;
	axe_spec    = handles.Axe_FFT;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
    DispStats(FBMxDif,handles,mode_val);
elseif ~Chk_Hist & ~Chk_Auto & ~Chk_Stats
    axe_xdif    = handles.Axe_xDif0;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
elseif Chk_Hist & ~Chk_Auto & Chk_Stats
    axe_xdif    = handles.Axe_xDif1;
	axe_hist    = handles.Axe_Hist1;
	axe_cumhist = handles.Axe_CumHist1;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
    DispStats(FBMxDif,handles,mode_val);
elseif ~Chk_Hist & Chk_Auto & Chk_Stats
    axe_xdif    = handles.Axe_xDif1;
	axe_corr    = handles.Axe_AutoCorr1;
	axe_spec    = handles.Axe_FFT1;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
    DispStats(FBMxDif,handles,mode_val);
elseif Chk_Hist & ~Chk_Auto & ~Chk_Stats
    axe_xdif    = handles.Axe_xDif2;
	axe_hist    = handles.Axe_Hist2;
	axe_cumhist = handles.Axe_CumHist2;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
elseif ~Chk_Hist & Chk_Auto & ~Chk_Stats
    axe_xdif    = handles.Axe_xDif2;
	axe_corr    = handles.Axe_AutoCorr2;
	axe_spec    = handles.Axe_FFT2;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
elseif ~Chk_Hist & ~Chk_Auto & Chk_Stats
    axe_xdif    = handles.Axe_xDif3;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispStats(FBMxDif,handles,mode_val);
elseif Chk_Hist & Chk_Auto & ~Chk_Stats
    axe_xdif    = handles.Axe_xDif4;
	axe_hist    = handles.Axe_Hist4;
	axe_cumhist = handles.Axe_CumHist4;
	axe_corr    = handles.Axe_AutoCorr4;
	axe_spec    = handles.Axe_FFT4;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
end

% Init DynVTool.
%---------------
axe_IND = [...
            handles.Axe_xDif,       ...
            handles.Axe_xDif0,      ...
            handles.Axe_xDif1,      ...
            handles.Axe_xDif2,      ...
            handles.Axe_xDif3,      ...
            handles.Axe_xDif4,      ...
            handles.Axe_AutoCorr,   ...
            handles.Axe_AutoCorr1,  ...
            handles.Axe_AutoCorr2,  ...
            handles.Axe_AutoCorr4,  ...
            handles.Axe_FFT,        ...
            handles.Axe_FFT1,       ...
            handles.Axe_FFT2,       ...
            handles.Axe_FFT4        ...
            ];
axe_CMD = axe_IND;
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_CloseWin.
function Pus_CloseWin_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_CloseWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcbf)
%--------------------------------------------------------------------------

%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Special Callback Functions                         %
%                --------------------------------                         %
%=========================================================================%

% --- Executes on button press in Statistics from wfbmtool figure.
function WfbmtoolCall_Callback(hObject, eventdata, handles,FBM_PARAMS)
% hObject    handle to Pus_Statistics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save wfbmtool handles in 'Userdata' field of wfbmstat figure.
%--------------------------------------------------------------
if isfield(FBM_PARAMS,'demoMODE')
    F1 = allchild(0);
end

wfbmstat('userdata',FBM_PARAMS);

if isfield(FBM_PARAMS,'demoMODE')
    F2 = allchild(0);
    hFig = setdiff(F2,F1);
    set(hFig,'HandleVisibility','On')
end

%=========================================================================%
%                END Special Callback Functions                           %
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

% Set Title in the 1Dif axes (first time).
%-----------------------------------------
title = 'Fractional Brownian Motion Increments of order 1';
setAxesTitle(handles.Axe_xDif,title);

% Resize Figure.
%---------------------
redimfig('On',hObject);

% Save Tool Parameters.
%----------------------
hSTATS  =   [                                                           ...
    handles.Txt_Mean,handles.Txt_Max,handles.Txt_Min,handles.Txt_Range, ...
    handles.Txt_StdDev,handles.Txt_Median,handles.Txt_MedAbsDev,        ...
    handles.Txt_MeanAbsDev,handles.Txt_Mode,                            ...
    handles.Edi_Mean,handles.Edi_Max,handles.Edi_Min,handles.Edi_Range, ...
    handles.Edi_StdDev,handles.Edi_Median,handles.Edi_MedAbsDev,        ...
    handles.Edi_MeanAbsDev,handles.Edi_Mode,                            ...
    handles.Fra_Stats                                                   ...
            ];
tool_PARAMS = struct('hSTATS',hSTATS);
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

% First statistics display.
%--------------------------
wfbmstat('Pus_Statistics_Callback',hObject, eventdata, handles);

% End Of initialization.
%-----------------------
set(hObject,'HandleVisibility','Callback');

%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%

function cleanTOOL(handles)

% Get figure handle.
%-------------------
hFig = handles.output;

% Clean figure.
%--------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
hAXES   = findobj(hFig,'type','axes');
hLINES  = findobj(hAXES,'type','line');
hPATCH  = findobj(hAXES,'type','patch');
set(hAXES,'Visible','off');
set(tool_PARAMS.hSTATS,'Visible','off');
delete(hLINES,hPATCH);
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
m_files     = wfigmngr('getmenus',hFig,'file');
str_numwin  = sprintf('%20.15f',hFig);

% Add Help for Tool.
%------------------
% wfighelp('addHelpTool',hFig,'&Continuous Analysis','CW1D_GUI');

% Add Help Item.
%----------------
% wfighelp('addHelpItem',hFig,'Continuous Transform','CW_TRANSFORM');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files);
%-------------------------------------------------------------------------

function DispxDif(FBMxDif,axe_xdif,DiffOrder,curr_color,FBM_PARAMS)
% x order increments axes display.
%---------------------------------
axes(axe_xdif);
line(0:length(FBMxDif)-1,FBMxDif,'Color',curr_color);
Xlim    = [0 length(FBMxDif)];
ext = abs(max(FBMxDif) - min(FBMxDif)) / 100;
Ylim = [min(FBMxDif)-ext max(FBMxDif)+ext];
set(axe_xdif,'Xlim',Xlim,'Ylim',Ylim);

% Get parameter settings.
%------------------------
Wav = FBM_PARAMS.Wav;                   % Wavelet used                           
Val_Length_Num = FBM_PARAMS.Length;     % Signal length (numeric)                           
Val_Index = FBM_PARAMS.H;               % Fractal index (numeric)                                        

if isequal(deblankl(DiffOrder),'0')
    label = [ ...
        'Synthesized Fractional Brownian Motion of length ',    ...
        num2str(Val_Length_Num),' using ',Wav,                  ...
        ' and H = ',num2str(Val_Index)                          ...
            ];
else
    label = ['Fractional Brownian Motion Increments of Order ', ...
              deblankl(DiffOrder)];
end
setAxesTitle(axe_xdif,label)
set(axe_xdif,'Visible','on');
%--------------------------------------------------------------------------

function DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color)
% Displaying histogram.
%----------------------
his(2,:)  = his(2,:)/length(FBMxDif(:));
axes(axe_hist);
wplothis(axe_hist,his,curr_color);
label = 'Histogram';
setAxesTitle(axe_hist,label)
set(axe_hist,'Visible','on');

% Displaying cumulated histogram.
%--------------------------------
for i=6:4:length(his(2,:));
    his(2,i)   = his(2,i)+his(2,i-4);
    his(2,i+1) = his(2,i);
end
axes(axe_cumhist);
wplothis(axe_cumhist,[his(1,:);his(2,:)],curr_color);
label = 'Cumulative Histogram';
setAxesTitle(axe_cumhist,label)
set(axe_cumhist,'Visible','on');
%--------------------------------------------------------------------------

function DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color)
% Displaying Autocorrelations.
%-----------------------------       
[corr,lags] = wautocor(FBMxDif);
lenLagsPos  = (length(lags)-1)/2;
lenKeep     = min(200,lenLagsPos);
first       = lenLagsPos+1-lenKeep;
last        = lenLagsPos+1+lenKeep;
Xval        = lags(first:last);
Yval        = corr(first:last);
axes(axe_corr);
hdl_RES = line('Xdata',Xval,'Ydata',Yval,'Color',curr_color);
set(axe_corr,'Xlim',[Xval(1) Xval(end)],...
             'Ylim',[min(0,1.1*min(Yval)) 1]);
label = 'Autocorrelations';
setAxesTitle(axe_corr,label)
set(axe_corr,'Visible','on');

% Displaying Spectrum.
%---------------------
[sp,f]  = wspecfft(FBMxDif);
axes(axe_spec);
hdl_RES = line('Xdata',f,'Ydata',sp,'Color',curr_color);
Xlim    = [min(f) max(f)];
ext     = abs(max(sp) - min(sp)) / 100;
Ylim    = [min(sp)-ext max(sp)+ext];
set(axe_spec,'Xlim',Xlim,'Ylim',Ylim);
label = 'FFT - Energy Spectrum';
setAxesTitle(axe_spec,label)
set(axe_spec,'Visible','on');
%--------------------------------------------------------------------------

function DispStats(FBMxDif,handles,mode_val)
% Computing values for statistics.
%---------------------------------
errtol     = 1.0E-12;
mean_val   = mean(FBMxDif);
max_val    = max(FBMxDif);
min_val    = min(FBMxDif);
range_val  = max_val-min_val;
std_val    = std(FBMxDif);
med_val    = median(FBMxDif);
medDev_val = median(abs(FBMxDif(:)-med_val)); 
if abs(medDev_val)<errtol , medDev_val = 0; end
meanDev_val = mean(abs(FBMxDif(:)-mean_val));      
if abs(meanDev_val)<errtol , meanDev_val = 0; end

% Get figure handle.
%-------------------
hFig = handles.output;

% Displaying Statistics.
%-----------------------
set(handles.Edi_Mean,'string',sprintf('%1.4g',mean_val));
set(handles.Edi_Max,'string',sprintf('%1.4g',max_val));
set(handles.Edi_Min,'string',sprintf('%1.4g',min_val));
set(handles.Edi_Range,'string',sprintf('%1.4g',range_val));
set(handles.Edi_StdDev,'string',sprintf('%1.4g',std_val));
set(handles.Edi_Median,'string',sprintf('%1.4g',med_val));
set(handles.Edi_MedAbsDev,'string',sprintf('%1.4g',medDev_val));
set(handles.Edi_MeanAbsDev,'string',sprintf('%1.4g',meanDev_val));
set(handles.Edi_Mode,'string',sprintf('%1.4g',mode_val));
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
set(tool_PARAMS.hSTATS,'Visible','on');
%--------------------------------------------------------------------------

function [sp,f] = wspecfft(signal)
%WSPECFFT FFT spectrum of a signal.
%
% f is the frequency 
% sp is the energy, the square of the FFT transform

% The input signal is empty.
%---------------------------
if isempty(signal)
    sp = [];f =[];return
end

% Compute the spectrum.
%----------------------
n   = length(signal);
XTF = fft(fftshift(signal));
m   = ceil(n/2) + 1;

% Compute the output values.
%---------------------------
f   = linspace(0,0.5,m);
sp  = (abs(XTF(1:m))).^2;
%--------------------------------------------------------------------------

function [c,lags] = wautocor(a,maxlag)
%WAUTOCOR Auto-correlation function estimates.
%   [C,LAGS] = WAUTOCOR(A,MAXLAG) computes the 
%   autocorrelation function c of a one dimensional
%   signal a, for lags = [-maxlag:maxlag]. 
%   The autocorrelation c(maxlag+1) = 1.
%   If nargin==1, by default, maxlag = length(a)-1.

if nargin == 1, maxlag = size(a,2)-1;end
lags = -maxlag:maxlag;
if isempty(a) , c = []; return; end
epsi = sqrt(eps);
a    = a(:);
a    = a - mean(a);
nr   = length(a); 
if std(a)>epsi
    % Test of the variance.
    %----------------------
    mr     = 2 * maxlag + 1;
    nfft   = 2^nextpow2(mr);
    nsects = ceil(2*nr/nfft);
    if nsects>4 & nfft<64
        nfft = min(4096,max(64,2^nextpow2(nr/4)));
    end
    c      = zeros(nfft,1);
    minus1 = (-1).^(0:nfft-1)';
    af_old = zeros(nfft,1);
    n1     = 1;
    nfft2  = nfft/2;
    while (n1<nr)
       n2 = min( n1+nfft2-1, nr );
       af = fft(a(n1:n2,:), nfft);
       c  = c + af.* conj( af + af_old);
       n1 = n1 + nfft2;
       af_old = minus1.*af;
    end
    if n1==nr
        af = ones(nfft,1)*a(nr,:);
   	c  = c + af.* conj( af + af_old );
    end
    mxlp1 = maxlag+1;
    c = real(ifft(c));
    c = [ c(mxlp1:-1:2,:); c(1:mxlp1,1) ];

    % Compute the autocorrelation function.
    %-------------------------------------- 
    cdiv = c(mxlp1,1);
    c = c / cdiv;
else
    % If  the variance is too small.
    %-------------------------------
    c = ones(size(lags));
end
%--------------------------------------------------------------------------

%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN General Utilities                                  %
%                -----------------------                                  %
%=========================================================================%

function setAxesTitle(axe,label)
axes(axe); 
t = title(label,'Color','k','FontWeight','demi','Units',...
    'normalized','Fontsize',9);
set(t,'Position',[0.5,1.02]);
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
