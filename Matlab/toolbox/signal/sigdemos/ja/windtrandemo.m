function varargout = windtrandemo(varargin)
%WINDTRANDEMO ウィンドウ変換生成のデモ
%    WINDTRANDEM - 任意のベクトル間のなめらかな変換を生成するための
%　　ウィンドウ関数を使うデモを行います。
%
%   参考：WINDOW, PSD

%   Reference:
%     [1] Andrew Dowd and Michael Thanos, Vector Motion Processing Using
%         Spectral Windows, IEEE Control Systems Magazine, Vol. 20, 
%         No. 5, October 2000, Page 8.
%
%    FIG = WINDTRANDEMO launch windtrandemo GUI.
%    WINDTRANDEMO('callback_name', ...) invoke the named callback.

%   Author(s): A. Dowd, P. Costa

% Last Modified by GUIDE v2.0 28-Mar-2001 09:25:15

if nargin == 0  % LAUNCH GUI

    % Define some limits for the parameter values of various windows
    % This will be keep in 'handles' for future reference
    
    % Ok now for the graphics stuff
	fig = openfig(mfilename,'reuse');
 	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

   
	% Generate a structure of handles to pass to callbacks, and store it. 
    %line(0,0,'Parent',handles.posplot,'Color','b','Tag','transplot');
    wtypes = window;
    wtypes{4} = wtypes{3};   % Keep track of last selected value for each window
    
	handles = guihandles(fig); 
    handles.wtype = wtypes;
    handles.winposlin = line(1,1,'Parent',handles.posplot,'Color','b','LineWidth',1.5);   % line used for plotting Position (later)
    handles.winvellin = line(1,1,'Parent',handles.velplot,'Color','b','LineWidth',1.5);   % line used for plotting Velocity (later)
    handles.winacclin = line(1,1,'Parent',handles.accplot,'Color','b','LineWidth',1.5);   % line used for plotting Acceleration (later)
    handles.winacclinalt = line(1,1,'Parent',handles.accplot,'Color','r');
%    handles.impposlin = line(1,1,'Parent',handles.posplot,'Color','r','Marker','x');
    handles.impposlin = line(1,1,'Parent',handles.posplot,'Color','r');
    handles.impvellin = line(1,1,'Parent',handles.velplot,'Color','r');

    legend(handles.posplot,'Windowed','Direct Path');
	guidata(fig, handles); 

     % Fill windows options with values from 'window'

    set(handles.wintypepop,'String',wtypes{2});
    % Set options for computing the first order window
    set(handles.firstorderconv,'UserData',{'sin','fderive','mirror'});

    % Set options for SAMPLEs
    sampS= struct('T',1.0,'X',[1 -1],'V',[1 1],'Name','Raster X');
    sampS(end+1) = struct('T',1.0,'X',[0  1],'V',[0 0],'Name','Raster Y');
    sampS(end+1) = struct('T',1.0,'X',[1  1],'V',[-1 1],'Name','Corner');
    sampS(end+1) = struct('T',1.0,'X',[0 0],'V',[0 100],'Name','Launch');
    sampS(end+1) = struct('T',1.0,'X',[rand randn],'V',[randn rand],'Name','Random');
    set(handles.samples,'UserData',sampS);


	if nargout > 0
		varargout{1} = fig;
	end
    
    set(handles.posplot,'XGrid','on');
    set(handles.posplot,'YGrid','on');
    computeplot(handles);
    
    % Add Context sensitive help to gui
    contextmenu(fig, handles.wintypepop,'windtrandemo_winselect');
    contextmenu(fig, handles.text_wscale,'windtrandemo_winscale');
    contextmenu(fig, handles.text_wparam,'windtrandemo_winparam'); 
    contextmenu(fig, handles.winparam,'windtrandemo_winparam');   
    contextmenu(fig, handles.text_firstorder,'windtrandemo_firstordermethod');
    contextmenu(fig, handles.firstorderconv,'windtrandemo_firstordermethod');
    contextmenu(fig, handles.text_W0,'windtrandemo_winscale_W0');
    contextmenu(fig, handles.text_W1,'windtrandemo_winscale_W1');
    
    contextmenu(fig, handles.text_sampvector,'windtrandemo_vector_samp');
    contextmenu(fig, handles.samples,'windtrandemo_vector_samp');
    
    contextmenu(fig, handles.text_vector_init,'windtrandemo_vector_init');
    contextmenu(fig, handles.text_X1,'windtrandemo_vector_X1');
    contextmenu(fig, handles.x1edit,'windtrandemo_vector_X1');
    contextmenu(fig, handles.text_V1,'windtrandemo_vector_V1');
    contextmenu(fig, handles.v1edit,'windtrandemo_vector_V1');   
    
    contextmenu(fig, handles.text_vector_target,'windtrandemo_vector_target');
    contextmenu(fig, handles.text_X2,'windtrandemo_vector_X2');
    contextmenu(fig, handles.x2edit,'windtrandemo_vector_X2');
    contextmenu(fig, handles.text_V2,'windtrandemo_vector_V2');
    contextmenu(fig, handles.v2edit,'windtrandemo_vector_V2');
    
    contextmenu(fig, handles.text_tran_scale,'windtrandemo_vector_scale');    
    contextmenu(fig, handles.text_K0,'windtrandemo_vector_K0');
    contextmenu(fig, handles.text_K1,'windtrandemo_vector_K1');
    
    contextmenu(fig, handles.text_2der,'windtrandemo_2der_select');
    contextmenu(fig, handles.plotaccel,'windtrandemo_2der_acc');
    contextmenu(fig, handles.plotspectra,'windtrandemo_2der_spec');
    
    contextmenu(fig, handles.posplot,'windtrandemo_posplot');
    contextmenu(fig, handles.velplot,'windtrandemo_velplot');
    contextmenu(fig, handles.accplot,'windtrandemo_accplot');
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end

function computeplot(h);
% Plot the position, velocity and acceleration given a windows and vector 
% definition.  For this excerise, we pick 256 points for the period of the window.
npts = 257;  % one more than the period to encompass the values t=0 and 1
windex =  get(h.wintypepop,'Value');
winFH = h.wtype{1}(windex);
winPR = h.wtype{3}(windex);
if winPR,
    winPR = get(h.winparam,'Value');
else
    winPR = [];
end
optionsFO = get(h.firstorderconv,'UserData');
indexF0 = get(h.firstorderconv,'Value');
optionFO = optionsFO{indexF0};

[A0,V0,P0,S0] = scalewinzo(winFH{1},winPR,npts);
[A1,V1,P1,S1] = scalewinfo(winFH{1},winPR,npts,optionFO);

set(h.winscaleZO,'String',num2str(S0));
set(h.winscaleFO,'String',num2str(S1));
x(1) = get(h.x1edit,'Value');
x(2) = get(h.x2edit,'Value');
v(1) = get(h.v1edit,'Value');
v(2) = get(h.v2edit,'Value');
wintypelst = get(h.wintypepop,'String');
winidx = get(h.wintypepop,'Value');
wintype = wintypelst{winidx};
winparam = get(h.winparam,'Value');
% Tp = get(h.Tperiod,'Value');
Tp = 1;

xgap = x(2) - x(1);

ts1 = linspace(-1*Tp,0,npts);    % This choice is not arbitrary 
tstf = linspace(0,Tp,npts);
ts2 = linspace(Tp,2*Tp,npts);
% trim off the extras
tst = tstf(1:npts);
k = scalingfactor(x,v,Tp);        % See equation 10 and 11
set(h.K0val,'String',num2str(k(1)));
set(h.K1val,'String',num2str(k(2)));
% compute profiles (vectorized)
ys1 = x(1) + v(1)*(ts1);
ys2 = x(2) + v(2)*(ts2 - Tp);          

yst =  (k(1)*Tp)*P0 + (k(2))*P1 + x(1) + v(1)*tst;   % See equation 3
vst =  k(1)*V0 + k(2)*V1 + v(1);
ast =  (k(1)*A0 + k(2)*A1); 
ys = [ys1 yst ys2];
ts = [ts1 tst ts2];
as = [zeros(size(ys1)) ast zeros(size(ys2))];
vs = [v(1)*ones(size(ys1)) vst v(2)*ones(size(ys2))];

set(h.winposlin,'XData',ts,'YData',ys);
set(h.winvellin,'XData',ts,'YData',vs);

% plot impulse versions (in red)
impT = [-1*Tp 0 Tp 2*Tp];
iposV =[ys1(1) x(1) x(2) ys2(end)];
set(h.impposlin,'XData',impT,'YData',iposV);  % This creates the Impulse version, with markers at X1 and X2
impT = [-1*Tp 0 0 Tp Tp 2*Tp];
ivel = (x(2)-x(1))/Tp;
ivelV = [v(1) v(1) ivel ivel v(2) v(2)];
set(h.impvellin,'XData',impT,'YData',ivelV);

pk(1) = (k(1)/2)+k(2);
pk(2) = (k(1)/2)-k(2);

if get(h.plotspectra,'Value'),
    psdas = fft([zeros(1,1024) as zeros(1,1024)]);  % zero pad to see the lobes
    wstate=warning;
    warning off;
    psdasdB = 20*log10(abs(psdas)/(npts-1));
    warning(wstate);
    fD = linspace(0,2*pi,length(psdas)+1);       % in units of 1/T
    fsD = fD(1:111).*((npts-1)/(2*pi));

    winYdB = psdasdB(1:111);
    winmaxdB = max(winYdB);
    
    % compute impulse version using full fourier transform 
    psdF = linspace(0,10,256);
    psdim = pk(1)^2 + pk(2)^2 + 2*pk(1)*pk(2)*cos(2*pi*psdF);
    wstate=warning;
    psdimdB = 10*log10(psdim);
    warning off;
    
    ymaxdb = max([max(psdimdB) winmaxdB]);
    set(h.winacclinalt,'XData',psdF,'YData', max(psdimdB,ymaxdb-120) );
    set(h.winacclin,'XData',fsD,'YData',max(winYdB,ymaxdb-120));
    set(h.xaxis2nd,'String','Freq. (1/T)');

else
    % Need to create an arrow to indicate impulse
    Scale = 0.03;
    impT = [-1*Tp 0 0 -1*Tp*Scale Tp*Scale 0 0  Tp Tp  Tp*(1-Scale) Tp*(1+Scale) Tp Tp 2*Tp]; 
    
    pkt(1) = pk(1)-sign(pk(1))*0.3*max(abs(pk));
    pkt(2) = pk(2)-sign(pk(2))*0.3*max(abs(pk));
    iaccV = [ 0 0 pk(1) pkt(1) pkt(1) pk(1) 0 0 pk(2) pkt(2) pkt(2) pk(2) 0 0];
    set(h.winacclinalt,'XData',impT,'YData', iaccV );
    set(h.winacclin,'XData',ts,'YData',as);
    set(h.xaxis2nd,'String','Time');
end
% --------------------------------------------------------------------
function varargout = decv1_Callback(h, eventdata, handles, varargin)
% Decrease Velocity 1
v1 = get(handles.v1edit,'Value');
v1 = v1/1.5;
set(handles.v1edit,'Value',v1);
set(handles.v1edit,'String',num2str(v1));
computeplot(handles);
% --------------------------------------------------------------------
function varargout = decv2_Callback(h, eventdata, handles, varargin)
% Decrease Velocity 2
v2 = get(handles.v2edit,'Value');
v2 = v2/1.5;
set(handles.v2edit,'Value',v2);
set(handles.v2edit,'String',num2str(v2));
computeplot(handles);
% --------------------------------------------------------------------
function varargout = incv1_Callback(h, eventdata, handles, varargin)
% Increase Velocity 1
v1 = get(handles.v1edit,'Value');
v1 = v1*1.5;
set(handles.v1edit,'Value',v1);
set(handles.v1edit,'String',num2str(v1));
computeplot(handles);
% --------------------------------------------------------------------
function varargout = incv2_Callback(h, eventdata, handles, varargin)
% Decrease Velocity 2
v2 = get(handles.v2edit,'Value');
v2 = v2*1.5;
set(handles.v2edit,'Value',v2);
set(handles.v2edit,'String',num2str(v2));
computeplot(handles);
% --------------------------------------------------------------------
function varargout = x1edit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.x1edit.
try
    x1 = eval(get(h,'String'));
catch
    warndlg('Warning - X1 undefined (set to zero)','Velocity Error');
    x1 = 0;
end
set(h,'String',num2str(x1));
set(h,'Value',x1);
computeplot(handles);

% --------------------------------------------------------------------
function varargout = v1edit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.v1edit.
try
    v1 = eval(get(h,'String'));
catch
    warndlg('Warning - V1 undefined (set to zero)','Velocity Error');
    v1 = 0;
end
set(h,'String',num2str(v1));
set(h,'Value',v1);
computeplot(handles);


% --------------------------------------------------------------------
function varargout = x2edit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.x2edit.
try
    x2 = eval(get(h,'String'));
catch
    warndlg('Warning - X2 undefined (set to zero)','Velocity Error');
    x2 = 0;
end
set(h,'String',num2str(x2));
set(h,'Value',x2);
computeplot(handles);


% --------------------------------------------------------------------
function varargout = v2edit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.v2edit.
try
    v2 = eval(get(h,'String'));
catch
    warndlg('Warning - V2 undefined (set to zero)','Velocity Error');
    v2 = 0;
end
set(h,'String',num2str(v2));
set(h,'Value',v2);
computeplot(handles);
% --------------------------------------------------------------------
function varargout = general_Callback(h, eventdata, handles, varargin)
% used by any callback that ONLY changes plots
%
computeplot(handles);

% --------------------------------------------------------------------
function varargout = wintypepop_Callback(h, eventdata, handles, varargin)
% Check status of type - may need to activate the parameter window
%
wparam = handles.wtype{3};
windex =  get(h,'Value');

if wparam(windex),
    % Valid parameter entry
    set(handles.winparam,'BackgroundColor',[1 1 1]);
    set(handles.winparam,'Enable','on'); 
    woldvalue = handles.wtype{4}(windex);
    set(handles.winparam,'String',num2str(woldvalue)); 
    set(handles.winparam,'Value',woldvalue);
    set(handles.text_wparam,'Enable','on');
else
    % No parameter!
    set(handles.winparam,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    set(handles.winparam,'Enable','off');
    set(handles.text_wparam,'Enable','off');
end
computeplot(handles);


% --------------------------------------------------------------------
function varargout = winparam_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.edit5.
wvalue =  eval(get(h,'String'));
set(h,'Value',wvalue);
% Preseve value for next time I select this window
windex = get(handles.wintypepop,'Value');
handles.wtype{4}(windex) = wvalue;  % preserve value for posterity
guidata(gcbo, handles);              % Store Change
computeplot(handles);

% --------------------------------------------------------------------
function varargout = quit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton1.
close(handles.guiaccwin);

% % --------------------------------------------------------------------
% 
% function varargout = posplot_ButtondownFcn(h, eventdata, handles, varargin)
% %
% x = get(h,'CurrentPoint')

% --------------------------------------------------------------------
function varargout = samples_Callback(h, eventdata, handles, varargin)
% Install a sample waveform
sampSA =     get(h,'UserData');
sampI =     get(h,'Value');
sampS = sampSA(sampI);
if strcmpi( sampS.Name,'Random'),
    sampS = struct('T',1.0,'X',[rand randn],'V',[randn rand]);
end
%set(handles.Tperiod,'String',num2str(sampS.T));
%set(handles.Tperiod,'Value',sampS.T);
set(handles.x1edit,'String',num2str(sampS.X(1)));
set(handles.x1edit,'Value',sampS.X(1));
set(handles.x2edit,'String',num2str(sampS.X(2)));
set(handles.x2edit,'Value',sampS.X(2));
set(handles.v1edit,'String',num2str(sampS.V(1)));
set(handles.v1edit,'Value',sampS.V(1));
set(handles.v2edit,'String',num2str(sampS.V(2)));
set(handles.v2edit,'Value',sampS.V(2));
computeplot(handles);

% --------------------------------------------------------------------
function varargout = information_Callback(h, eventdata, handles, varargin)
% Link to Documentation
% disp('Information Callback not implemented.')
hFig = gcbf;
bring_up_help_window(hFig,'windtrandemo_start');

% --------------------------------------------------------------------
function varargout = plotspectra_Callback(h, eventdata, handles, varargin)
% uicontrol 'Plot Spectra' - Toggles between the acceleration and 
% spectra of acceleration. 
SpectButt = get(h,'Value');
if SpectButt,
    set(handles.plotaccel,'Value',0);
else
    set(handles.plotaccel,'Value',1);
end
computeplot(handles);

% --------------------------------------------------------------------
function varargout = plotaccel_Callback(h, eventdata, handles, varargin)
% 'Plot Acceleration' radio button
AccelButt = get(h,'Value');
if AccelButt,
    set(handles.plotspectra,'Value',0);
else
    set(handles.plotspectra,'Value',1);
end
computeplot(handles);


% --------------------------------------------------------------
function hcmenu = contextmenu(hfig,hItem,tagStr)

hcmenu = uicontextmenu('Parent',hfig);

% Define context menu item
uimenu('Parent',hcmenu,...
    'Label','What''s This?',...
    'Callback',{@HelpGeneral,tagStr});

% Associate the context menu with hItem
set(hItem,'uicontextmenu',hcmenu);

%--------------------------------------------------------------
function HelpGeneral(hco,eventStruct,tag)
% HelpGeneral Bring up the help page corresponding to the tag string.
hFig = gcbf;
bring_up_help_window(hFig,tag);

%-----------------------------------------------------------
function bring_up_help_window(hFig,tag);

try,
    [tag toolbox] = strtok(tag,filesep);
    if isempty(toolbox), toolbox = [filesep 'signal']; end
    helpview([docroot filesep 'mapfiles' toolbox '.map'], tag);
    
catch,
    % Help failed
    % Do some basic debugging of the help system:
    msg = {'';
        'Failed to find on-line help entry:';
        ['   "' tag '"'];
        ''};
    
    if isempty(docroot),
        msg = [msg; {'The "docroot" command is used to identify the on-line documentation';
                'path, and it has returned an empty string.  This usually indicates';
                'that you have not installed on-line help, or you have not properly';
                'set up the MATLAB Preferences.';
                ''}];
    else
        msg = [msg; {'The "docroot" command is used to identify the on-line documentation';
                'path, and it has returned a non-empty string.  This generally indicates';
                'that you have installed on-line help, but the specified directory path';
                'may be incorrect.';
                ''}];
    end
    
    msg = [msg;
        {'To modify your preference settings for the documentation path, go';
            'to the File menu in the Command Window, and choose "Preferences".';
            'Select "Help Browser", then check the "Documentation Location"';
            'directory path to ensure it points the location of your on-line';
            'help.'}];
    
    % Produce the error message:
    helpError(hFig,msg);
end

%--------------------------------------------------------------
function helpError(hFig,msg)
% Generate a modal dialog box to display errors while trying to obtain help

hmsg = errordlg(msg,'Help Error','modal');



%   Copyright 1988-2002 The MathWorks, Inc.
