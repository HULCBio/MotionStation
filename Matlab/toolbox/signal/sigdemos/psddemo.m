function varargout = psddemo(varargin)
%PSDDEMO Power Spectral Density Demo.
%   PSDDEMO displays the Power Spectral Density (PSD) of several 
%   signals. This demo contains these components:
%
%   Signals
%   -------
%   Apply different spectral estimators to three noisy signals. The first
%   signal contains both narrowband (sinusoids) and broadband
%   (autoregressive process) components. The SNR is defined as the ratio of
%   the output power of the AR filter to the input power. The second signal
%   contains only narrowband components. In this case, the SNR is the ratio
%   of the power of the sinusoids to the power of the noise. The third
%   signal is simply white gaussian noise.
%   
%   Monte Carlo simulation
%   ----------------------
%   Statistically compare the characteristics of each estimator using
%   Monte Carlo simulations. You can overlay the realizations or 
%   display only the average.
%
%   Spectral estimators
%   -------------------
%   Experiment with non-parametric as well as parametric and subspace 
%   methods and compare with the true PSD (black thick lines). For 
%   cases of short data records, the high resolution methods 
%   (parametric and subspace methods) tend to produce better results
%   than traditional Fourier transform-based methods. These high 
%   resolution methods uses a priori information of the spectral 
%   content of the signal to build a model of the signal. For further
%   information, look at the Signal Processing Toolbox User's Guide,
%   Chapter 3.
%
%   Spectral windows
%   ----------------
%   Choose different spectral windows. The choice of a windowing 
%   function is important in determining the quality of the PSD for
%   several estimators. The main role of the window is to damp out
%   the effects of the Gibbs phenomenon that results from truncation
%   of an infinite series. Click View to visualize the selected window
%   in the Window Visualization Tool.
%
% See also PERIODOGRAM, PWELCH, PMTM, PYULEAR, PBURG, PCOV, PMCOV, 
%          PMUSIC, PEIG, SPTOOL, WVTOOL.

%   Reference:
%     [1] Kay, S.M. Modern Spectral Estimation. Englewood Cliffs, 
%         NJ: Prentice Hall, 1988

%   Last Modified by GUIDE v2.0 04-Dec-2001 15:00:10
%   Author(s): S.Sand, V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/12 23:51:45 $

if nargin == 0  % LAUNCH GUI
    
%     fprintf('Initializing Power Spectral Density Demo ');
%     fprintf('.');

    % Center figure
    fig = openfig(mfilename,'reuse');
    movegui(fig, 'center');
    
    % Print option default : don't print uicontrols
    pt = printtemplate;
    pt.PrintUI = 0;
    set(fig, 'PrintTemplate', pt);
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);

    % Set colors
    set_colors(fig, handles);
    
    % Populate the window popup with all the aindow methods available in SPT
    [winclassnames, winnames] = findallwinclasses('nonuserdefined');
    set(handles.Window, 'String', winnames, 'Value', find(strcmpi('hamming',winclassnames)));
%     fprintf('.');

    % Render menus
    render_menus(fig);
    
    % Render toolbar
    set(fig, 'Toolbar', 'none');
    render_toolbar(fig);
%     fprintf('.');

    % Initialization
    initialize(fig,handles,winclassnames,winnames);
    
    % Define a CloseRequestFcn
    set(fig, 'CloseRequestFcn', @quit_Callback);

    if nargout > 0
        varargout{1} = fig;
    end
    
%     fprintf(' done.');

    set(fig, 'Visible', 'on')
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
    
end


% --------------------------------------------------------------------
%
%                INITIALIZATION FUNCTIONS
%
% --------------------------------------------------------------------
function set_colors(fig, handles)

% Use system color scheme for figure:
set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

% Use system color scheme for figure:
set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

% UIcontrol BackgroundColor
hvect = convert2vector(handles);
set(hvect, 'Units', 'Normalized');
index = find(strcmpi(get(hvect, 'Type'), 'uicontrol'));
hvect = hvect(index);
index = find(strcmpi(get(hvect, 'Style'), 'frame') | ...
    strcmpi(get(hvect, 'Style'), 'text') | ...
    strcmpi(get(hvect, 'Style'), 'checkbox'));
set(hvect(index), 'BackgroundColor', get(0,'defaultUicontrolBackgroundColor'));


% --------------------------------------------------------------------
function render_menus(fig)

% Render the "File" menu
hmenus.hfile = render_sptfilemenu(fig);

% Render the "Edit" menu
hmenus.hedit = render_spteditmenu(fig);

% Render the "Insert" menu
hmenus.hinsert = render_sptinsertmenu(fig,3);

% Render the "Tools" menu
hmenus.htools = render_spttoolsmenu(fig,4);

% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(fig,5);

% Render a Signal Processing Toolbox "Help" menu
hmenus.hhelp = render_helpmenu(fig);


%-------------------------------------------------------------------
function hhelp = render_helpmenu(fig)

[hhelpmenu, hhelpmenuitems] = render_spthelpmenu(fig,6);

strs  = 'Estimation Demo Help';
cbs   = @help_Callback;
tags  = 'helpdemo'; 
sep   = 'off';
accel = '';
hwhatsthis = addmenu(fig,[6 1],strs,cbs,tags,sep,accel);

hhelp = [hhelpmenu, hhelpmenuitems(1), hwhatsthis, hhelpmenuitems(2:end)];


%-------------------------------------------------------------------
function render_toolbar(fig)

htoolbar.htoolbar = uitoolbar('Parent',fig);

% Render Print buttons (Print, Print Preview)
htoolbar.hprintbtns = render_sptprintbtns(htoolbar.htoolbar);

% Render the annotation buttons (Edit Plot, Insert Arrow, etc)
htoolbar.hscribebtns = render_sptscribebtns(htoolbar.htoolbar);

% Render the zoom buttons
htoolbar.hzoombtns = render_zoombtns(fig);


% --------------------------------------------------------------------
function initialize(fig,handles,winclassnames,winnames)

% Default userdata strcuture
ud=get(fig,'UserData');
ud.nsig = 1;
ud.N = 32;
ud.SNR = 10;
ud.NRep = 5;
ud.average = 1;
ud.method = 3;
ud.winnames = winnames;
ud.winclassnames = winclassnames;
ud.currentwin = find(strcmpi(winclassnames, 'hamming'));
ud.samplingflag = 'symmetric';
ud.winlength = 32;
ud.noverlap = 2;
ud.order = 10;
ud.wvtool = [];
set(fig,'UserData',ud);

% Sync GUI and figure's UserData
init = 'noupdate';
signal_Callback(handles.Signal, [], handles, init);
length_Callback(handles.Length, [], handles, init);
SNR_Callback(handles.SNR, [], handles, init);
method_Callback(handles.Method, [], handles, init);
window_Callback(handles.Window, [], handles, init);
noverlap_Callback(handles.noverlap, [], handles, init);
order_Callback(handles.order, [], handles, init);

% Update the axes
update_gui(fig,handles);


% --------------------------------------------------------------------
%
%                          CALLBACKS
%
% --------------------------------------------------------------------
function varargout = signal_Callback(h, eventdata, handles, varargin)
% Change Signal

hfig=handles.Estimation;
ud=get(hfig,'UserData');
nsig = get(h,'Value');
ud.nsig = nsig;

% Update order
if nsig==1,
    if any(ud.method==[10 11 12 13]),
        % Parametric methods
        set(handles.order, 'String', '10');
        ud.order = 10;
    elseif ud.method>16,
        % Subspace methods
        set(handles.order, 'String', '7');
        ud.order = 7;
    end
    set(handles.SNRstr, 'String', 'SNR in dB:');
    
elseif nsig==2,
    if any(ud.method==[10 11 12 13]),
        % Parametric methods
        set(handles.order, 'String', '8');
        ud.order = 8;
    elseif ud.method>16,
        % Subspace methods
        set(handles.order, 'String', '4');
        ud.order = 4;
    end
    set(handles.SNRstr, 'String', 'SNR in dB:');
    
elseif nsig==3,
    set(handles.SNRstr, 'String', 'Variance:');
end
order_Callback(handles.order, [], handles, 'noupdate');

% Save userdata
set(hfig,'UserData',ud);

if nargin>3, return; end
update_gui(hfig,handles);


% --------------------------------------------------------------------
function varargout = length_Callback(h, eventdata, handles, varargin)
% Change length

[val, errStr] = evaluatevars(get(h, 'String'));

if isempty(errStr),
    
    % Check if input is valid
    if val<1 | round(val)~=val,
        errordlg('The number of samples must be an integer greater than zero.');
        return
    end
    
    hfig=handles.Estimation;
    ud=get(hfig,'UserData');
    ud.N = val;
    
    % Update window length
    if any(ud.method == [3,4]) % Periodogram and Modified Periodogram
        ud.winlength = val;
    elseif ud.method == 5, % Welch
        ud.winlength = round(val/8);
    end
    
    % Save userdata
    set(hfig,'UserData',ud);
    
    % Update window length uicontrol
    set(handles.winlength, 'String', num2str(ud.winlength));
    winlength_Callback(handles.winlength, eventdata, handles,'noupdate');
    
    if nargin>3, return; end
    update_gui(hfig,handles);
    
else
    errordlg(errStr);
end


% --------------------------------------------------------------------
function varargout = SNR_Callback(h, eventdata, handles, varargin)
% Change SNR

[val, errStr] = evaluatevars(get(h, 'String'));

if isempty(errStr),
    
    % Valid input
    if val<0,
        errordlg('The SNR must be positive.');
        return
    end

    % Update userdata
    hfig=handles.Estimation;
    ud=get(hfig,'UserData');
    ud.SNR = val;
    set(hfig,'UserData',ud);
    
    if nargin>3, return; end
    update_gui(hfig,handles);
    
else
    errordlg(errStr);
end


% --------------------------------------------------------------------
function varargout = NRep_Callback(h, eventdata, handles, varargin)
% Change the number of trials

[val, errStr] = evaluatevars(get(h, 'String'));
if isempty(errStr),
    
    % Check if input is valid
    if val<1 | round(val)~=val,
        errordlg('The number of trials must be an integer greater than zero.');
        return
    end
    
    % Update userdata
    hfig=handles.Estimation;
    ud=get(hfig,'UserData');
    ud.NRep = val;
    set(hfig,'UserData',ud);
    
    if nargin>3, return; end
    update_gui(hfig,handles);
    
else
    errordlg(errStr);
end


% --------------------------------------------------------------------
function varargout = average_Callback(h, eventdata, handles, varargin)
% Average of overlay the realizations of Monte Carlo simulation

% Update userdata
hfig=handles.Estimation;
ud=get(hfig,'UserData');
ud.average = get(h,'Value');
set(hfig,'UserData',ud);

if nargin>3, return; end
update_gui(hfig,handles);


% --------------------------------------------------------------------
function varargout = method_Callback(h, eventdata, handles, varargin)
% Change estimation method

% Skip invalid popup values
val = get(h,'Value');
if val<=3,
    val = 3;
elseif  val==7,
    val = 6;
elseif val==8 | val==9,
    val = 10;
elseif  val==14,
    val = 13;
elseif val==15 | val==16,
    val = 17;
end

% Update userdata
hfig=handles.Estimation;
ud=get(hfig,'UserData');
ud.method = val;
set(h, 'Value', val);
set(hfig,'UserData',ud);

switch ud.method,
case 3,
    % Periodogram settings
    ud = periodogram_settings(ud, handles);
    
case 4,
    % Modified periodogram settings
    ud = modified_periodogram_settings(ud, handles);
    
case 5,
    % Welch
    ud = welch_settings(ud, handles);
        
case 6,
    % Thomson Multitaper
    ud = thomson_settings(ud, handles);
    
case {10,11,12,13},
    % Parametric methods
    ud = parametric_settings(ud, handles);
    
case {17,18},
    % Subspace methods
    ud = subspace_settings(ud, handles);
    
end

set(hfig,'UserData',ud);

if nargin>3, return; end
update_gui(hfig,handles);


% --------------------------------------------------------------------
function varargout = order_Callback(h, eventdata, handles, varargin)
% Change order

[val, errStr] = evaluatevars(get(h, 'String'));

if isempty(errStr),
    
    % Check if input is valid
    if val<1 | round(val)~=val,
        orderstr = get(handles.orderstr, 'String');
        % Remove :
        orderstr(end) = [];
        errordlg(['The ',lower(orderstr),' must be an integer greater than zero.']);
        return
    end
    
    hfig=handles.Estimation;
    ud=get(hfig,'UserData');
    ud.order = val;
    
    % Default window length for subspace methods
    if ud.method>16,
        set(handles.winlength, 'String', num2str(2*val));
        ud.winlength = 2*val;
        winlength_Callback(handles.winlength, eventdata, handles,'noupdate');
    end
    
    % Update userdata
    set(hfig,'UserData',ud);
    
    if nargin>3, return; end
    update_gui(hfig,handles);
    
else
    errordlg(errStr);
end


% --------------------------------------------------------------------
function varargout = noverlap_Callback(h, eventdata, handles, varargin)
% Change noverlap

hfig=handles.Estimation;
ud=get(hfig,'UserData');
[val, errStr] = evaluatevars(get(h, 'String'));

if isempty(errStr),
    
    % Check if input is valid
    if val>=ud.winlength,
        errordlg('The number of samples to overlap must be less than the length of the window.');
    elseif val<1 or round(val)~=val,
        errordlg('The number of samples to overlap must be an integer greater than zero.');
    else
        % Update userdata
        ud.noverlap = val;
        set(hfig,'UserData',ud);
        
        if nargin>3, return; end
        update_gui(hfig,handles);
    end
else
    errordlg(errStr);
end


% --------------------------------------------------------------------
function varargout = window_Callback(h, eventdata, handles, varargin)
% Change window

% Update userdata
hfig=handles.Estimation;
ud=get(hfig,'UserData');
ud.currentwin = get(h,'Value');
set(hfig,'UserData',ud);

% Update Sampling uicontrols
winclassnames = ud.winclassnames{ud.currentwin};
winobj = feval(str2func(['sigwin.' winclassnames]));
if isa(winobj, 'sigwin.samplingflagwin'),
    % Sampling flag
    setenableprop([handles.sampling handles.samplingstr], 'on');
    sampling_Callback(handles.sampling, eventdata, handles, 'noupdate');
else
    setenableprop([handles.sampling handles.samplingstr], 'off');
end
    
% Update the Parameter uicontrols
paramnames = getparamnames(winobj);
if isempty(paramnames),
    setenableprop([handles.parameter handles.parameterstr], 'off');
    set(handles.parameterstr, 'String', 'Parameter:');
else
    setenableprop([handles.parameter handles.parameterstr], 'on');
    set(handles.parameterstr, 'String', [paramnames,':']);
    set(handles.parameter, 'String', num2str(winobj.(paramnames)));
    ud.winparam = winobj.(paramnames);
    set(hfig,'UserData',ud);
    parameter_Callback(handles.parameter, eventdata, handles, 'noupdate');
end

% Update WVTool if necessary
window_listener(h, []);

if nargin>3, return; end
update_gui(hfig,handles);


% --------------------------------------------------------------------
function varargout = winlength_Callback(h, eventdata, handles, varargin)
% Change window length

hfig=handles.Estimation;
ud=get(hfig,'UserData');
[val, errStr] = evaluatevars(get(h, 'String'));
if isempty(errStr),
    
    % Check if input is valid
    if val>ud.N,
        errordlg('Window length must be less than the length of the signal.');
    elseif val<1 | round(val)~=val,
        errordlg('Window length must be an integer greater than zero.');
    else,
        
        % Update overlap
        if ud.method>15,
            % Subspace methods
            if val<=ud.order,
                errordlg('Window length must be greater than the number of complex sinusoids.');
                return
            end
            ud.noverlap = val-1;
        elseif ud.method==5,
            % Welch
            if rem(val,2),
                ud.noverlap = (val-1)/2;
            else
                ud.noverlap = val/2;
            end
        end
        set(handles.noverlap, 'String', num2str(ud.noverlap));
        
        % Update userdata
        ud.winlength = val;
        set(hfig,'UserData',ud);
        
        % Update WVTool if needed
        window_listener(handles.Window, []);
        
        if nargin>3, return; end
        update_gui(hfig,handles);
        
    end
else
    errordlg(errStr);
end


% --------------------------------------------------------------------
function varargout = view_Callback(h, eventdata, handles, varargin)
% Launch WVTool to visualize the window

hfig=handles.Estimation;
ud=get(hfig,'UserData');

if isempty(ud.wvtool),
    
    % Instantiate the window object
    winclassnames = ud.winclassnames{ud.currentwin};
    winobj = feval(str2func(['sigwin.' winclassnames]));
    winobj.length = ud.winlength;
    paramname = getparamnames(winobj);
    if ~isempty(paramname),
        set(winobj, paramname, ud.winparam);
    end
    if isa(winobj, 'sigwin.samplingflagwin'),
        set(winobj, 'SamplingFlag', ud.samplingflag);
    end
        
    % Launch WVTool
    [hwv, ud.wvtool] = wvtool(winobj);
    
    % Save the handle to WVTool
    set(hfig,'UserData',ud);
    
    % Install a listener on 'WVToolClosing' event
    listener = handle.listener(ud.wvtool, 'WVToolClosing', @wvtool_listener);
    listener.CallbackTarget = handle(gcbf);
    setappdata(gcbf, 'Listeners', [getappdata(gcbf, 'Listeners');listener]);
    
else
    figure(ud.wvtool.FigureHandle);
end


% --------------------------------------------------------------------
function varargout = parameter_Callback(h, eventdata, handles, varargin)
% Change window parameter

[val, errStr] = evaluatevars(get(h, 'String'));
if isempty(errStr),
    
    hfig=handles.Estimation;
    ud=get(hfig,'UserData');
    
    % Check if input is valid
    if val<0,
        winclassnames = ud.winclassnames{ud.currentwin};
        winobj = feval(str2func(['sigwin.' winclassnames]));
        paramname = getparamnames(winobj);
        errordlg([paramname,' must be specified as a positive number.']);
        return
    end
    
    % Update userdata
    ud.winparam = val;
    set(hfig,'UserData',ud);
    
    % Update WVTool if needed
    window_listener(handles.Window, []);
    
    if nargin>3, return; end
    update_gui(hfig,handles);
    
else
    errordlg(errStr);
end


% --------------------------------------------------------------------
function varargout = sampling_Callback(h, eventdata, handles, varargin)
% Change window sampling flag

% Update userdata
hfig=handles.Estimation;
ud=get(hfig,'UserData');
str = get(h,'String');
ud.samplingflag = str{get(h,'Value')};
set(hfig,'UserData',ud);

% Update WVTool if needed
window_listener(handles.Window, []);

if nargin>3, return; end
update_gui(hfig,handles);


% --------------------------------------------------------------------
function varargout = help_Callback(h, eventdata, handles, varargin)
% Launch help for the demo

helpwin(mfilename);


% --------------------------------------------------------------------
function varargout = quit_Callback(h, eventdata, handles, varargin)
% Close the demo

if strcmpi(get(h,'Type'),'figure'),
    fig = h;
else
    fig = get(h,'Parent');
end

% Close WVTool if needed
ud=get(fig,'UserData');
if ~isempty(ud.wvtool),
    close(ud.wvtool);
end

delete(fig);


% --------------------------------------------------------------------
%
%                       UTILITY FUNCTIONS
%
% --------------------------------------------------------------------
function ud = periodogram_settings(ud, handles)

% Disable order
setenableprop([handles.order handles.orderstr], 'off');
set(handles.orderstr, 'String', 'Order:');

% Disable window

set(handles.winframe, 'Enable', 'off');
setenableprop([handles.Window handles.Windowstr], 'off');
setenableprop([handles.winlength handles.winlengthstr], 'off');
setenableprop([handles.parameter handles.parameterstr], 'off');
setenableprop([handles.sampling handles.samplingstr], 'off');
set(handles.view, 'Enable', 'off');

% Default window = rectangular
ud.currentwin = find(strcmpi(ud.winclassnames, 'rectwin'));

% Sync the Parameter and Sampling uicontrols
set(handles.Window, 'Value', ud.currentwin);
window_Callback(handles.Window, [], handles,'noupdate')   

% Close WVTool if necessary
if ~isempty(ud.wvtool),
    close(ud.wvtool);
end
ud.wvtool = [];

% No overlap
setenableprop([handles.noverlap handles.noverlapstr], 'off');


% --------------------------------------------------------------------
function ud = modified_periodogram_settings(ud, handles)

% Disable order
setenableprop([handles.order handles.orderstr], 'off');
set(handles.orderstr, 'String', 'Order:');

% Enable window
set(handles.winframe, 'Enable', 'on');
setenableprop([handles.Window handles.Windowstr], 'on');
setenableprop([handles.winlength handles.winlengthstr], 'on');
set(handles.view, 'Enable', 'on');

% Default window = hamming
ud.currentwin = find(strcmpi(ud.winclassnames, 'hamming'));
% Sync the Parameter and Sampling uicontrols
set(handles.Window, 'Value', ud.currentwin);
window_Callback(handles.Window, [], handles,'noupdate')

% Disable window length
setenableprop([handles.winlength handles.winlengthstr], 'off');
set(handles.winlength, 'String', num2str(ud.N));
ud.winlength = ud.N;

% Disable overlap
setenableprop([handles.noverlap handles.noverlapstr], 'off');


% --------------------------------------------------------------------
function ud = welch_settings(ud, handles)

% Disable order
setenableprop([handles.order handles.orderstr], 'off');
set(handles.orderstr, 'String', 'Order:');

% Enable window
set(handles.winframe, 'Enable', 'on');
setenableprop([handles.Window handles.Windowstr], 'on');

% Default window = hamming
ud.currentwin = find(strcmpi(ud.winclassnames, 'hamming'));
% Sync the Parameter and Sampling uicontrols
set(handles.Window, 'Value', ud.currentwin);
window_Callback(handles.Window, [], handles,'noupdate')
    
% Default window length
setenableprop([handles.winlength handles.winlengthstr], 'on');
ud.winlength = round(ud.N/2);
set(handles.winlength, 'String', num2str(ud.winlength));

% Default overlap
setenableprop([handles.noverlap handles.noverlapstr], 'on');
ud.noverlap = round(ud.winlength/2);
set(handles.noverlap, 'String', num2str(ud.noverlap));
    
% Enable View button
set(handles.view, 'Enable', 'on');
    

% --------------------------------------------------------------------
function ud = thomson_settings(ud, handles)

% Enable Time X Bandwidth parameter
setenableprop([handles.order handles.orderstr], 'on');
set(handles.orderstr, 'String', 'Time X Bandwidth:');

% Default Time X Bandwidth = 2
set(handles.order, 'String', '2');
ud.order = 2;
        
% Disable window
set(handles.winframe, 'Enable', 'off');
setenableprop([handles.Window handles.Windowstr], 'off');
setenableprop([handles.winlength handles.winlengthstr], 'off');
setenableprop([handles.parameter handles.parameterstr], 'off');
setenableprop([handles.sampling handles.samplingstr], 'off');
set(handles.view, 'Enable', 'off');

% Disable overlap
setenableprop([handles.noverlap handles.noverlapstr], 'off');

% Close WVTool if necessary
if ~isempty(ud.wvtool),
    close(ud.wvtool);
end
ud.wvtool = [];
    
    
% --------------------------------------------------------------------
function ud = parametric_settings(ud, handles)

% Enable order
setenableprop([handles.order handles.orderstr], 'on');
set(handles.orderstr, 'String', 'Order:');

% Default order
if ud.nsig==1,
    set(handles.order, 'String', '10');
    ud.order = 10;
elseif ud.nsig==2,
    set(handles.order, 'String', '8');
    ud.order = 8;
end
order_Callback(handles.order, [], handles, 'noupdate');

% Disable window
set(handles.winframe, 'Enable', 'off');
setenableprop([handles.Window handles.Windowstr], 'off');
setenableprop([handles.winlength handles.winlengthstr], 'off');
setenableprop([handles.parameter handles.parameterstr], 'off');
setenableprop([handles.sampling handles.samplingstr], 'off');
set(handles.view, 'Enable', 'off');

% Disable overlap
setenableprop([handles.noverlap handles.noverlapstr], 'off');

% Close WVTool if necessary
if ~isempty(ud.wvtool),
    close(ud.wvtool);
end
ud.wvtool = [];


% --------------------------------------------------------------------
function ud = subspace_settings(ud, handles)

% Enable order
setenableprop([handles.order handles.orderstr], 'on');
set(handles.orderstr, 'String', 'Complex sinusoids:');

% Default number of complex sinusoids
if ud.nsig==1,
    set(handles.order, 'String', '7');
    ud.order = 7;
elseif ud.nsig==2,
    set(handles.order, 'String', '4');
    ud.order = 4;
end

% Enable window
set(handles.winframe, 'Enable', 'on');
setenableprop([handles.Window handles.Windowstr], 'on');

% Default window = rectangular
ud.currentwin = find(strcmpi(ud.winclassnames, 'rectwin'));
% Sync the Parameter and Sampling uicontrols
set(handles.Window, 'Value', ud.currentwin);
window_Callback(handles.Window, [], handles,'noupdate')
    
% Default window length
setenableprop([handles.winlength handles.winlengthstr], 'on');
ud.winlength = 2*ud.order;
set(handles.winlength, 'String', num2str(ud.winlength));

% Default overlap
setenableprop([handles.noverlap handles.noverlapstr], 'on');
ud.noverlap = ud.winlength-1;
set(handles.noverlap, 'String', num2str(ud.noverlap));
    
% Enable View button
set(handles.view, 'Enable', 'on');


% --------------------------------------------------------------------
function x = signal(ud)
% Generate the different signals

sig_num = ud.nsig;
N = ud.N;
SNR = ud.SNR;
NRep = ud.NRep;

switch(sig_num)
case 1
    % Broad+Narrowband components
    % see [1] p.12
    randn('state',0); 
    n = 0:N-1;
    f1 = 0.1;
    f2 = 0.8;
    f3 = 0.84;
    a = -.850848;
    noisevar = (1-a^2)/10^(SNR/10);
    for i=1:NRep,
        noise = sqrt(noisevar)*randn(N,1);
        x(:,i) = 2*cos(pi*f1*n)' + 2*cos(pi*f2*n)' + 2*cos(pi*f3*n)' + ...
            sqrt(2)*filter(1,[1.0000 a], noise);
    end
case 2
    % 2 Real Sinusoid in WGN
    randn('state',0);
    n = 0:N-1;
    noisevar = 1/SNR;
    for i=1:NRep,
        x(:,i) = cos(0.257*pi*n)' + sin(0.2*pi*n)' + sqrt(noisevar)*randn(size(n))';
    end
case 3
    % WGN
    randn('state',0);
    noisevar = SNR;
    for i=1:NRep,
        x(:,i) = sqrt(noisevar)*randn(N,1);
    end
end


% --------------------------------------------------------------------
function Pxx = compPxx(ud)
% Computes Power spectral density (or pseudo spectrum for subspace methods)

method = ud.method;
x = ud.signal;
Nfft = ud.Nfft;
NRep = ud.NRep;
order = ud.order;
noverlap = ud.noverlap;

% Generate window if needed
if any(method==[4 5 17 18]),
    winclassnames = ud.winclassnames{ud.currentwin};
    winobj = feval(str2func(['sigwin.' winclassnames]));
    winobj.length = ud.winlength;
    paramname = getparamnames(winobj);
    if ~isempty(paramname),
        set(winobj, paramname, ud.winparam);
    end
    if isa(winobj, 'sigwin.samplingflagwin'),
        set(winobj, 'SamplingFlag', ud.samplingflag);
    end
    winvect = generate(winobj);
end

warning off MATLAB:divideByZero

% Avoid no op popup values
generatePxxcmd = {'', ...
        '', ...
        'periodogram(x(:,i),[],Nfft,''twosided'')', ...
        'periodogram(x(:,i),winvect,Nfft,''twosided'')', ...
        'pwelch(x(:,i),winvect,noverlap,Nfft,''twosided'')', ...
        'pmtm(x(:,i),order,Nfft,1,.5,''twosided'')', ...
        '', ...
        '', ...
        '', ...
        'pyulear(x(:,i),order,Nfft,''twosided'')', ...
        'pburg(x(:,i),order,Nfft,''twosided'')', ...
        'pcov(x(:,i),order,Nfft,''twosided'')',...
        'pmcov(x(:,i),order,Nfft,''twosided'')', ...
        '', ...
        '', ...
        '', ...
        'pmusic(x(:,i),order,Nfft,1,winvect,noverlap,''twosided'')', ...
        'peig(x(:,i),order,Nfft,1,winvect,noverlap,''twosided'')'};

for i=1:NRep,
    [Pxx(:,i),f] = eval(generatePxxcmd{method});
    Pxx(:,i) = fftshift(Pxx(:,i));
end

warning on MATLAB:divideByZero


% --------------------------------------------------------------------
function update_gui(hfig,handles)

% Get figure's userData
hfig=handles.Estimation;
ud=get(hfig,'UserData');

% Compute signal
ud.signal = signal(ud);

% Compute Pxx
ud.Nfft = 512;
try,
    ud.Pxx = compPxx(ud);
catch
    errordlg(lasterr);
    return;
end

% Update UserData
set(hfig,'UserData',ud);

% Plot
set(0,'ShowHiddenHandles','on');
plot_signal(hfig,handles);
plot_Pxx(hfig,handles);
set(0,'ShowHiddenHandles','off');

% Restore zoom state
zoommode = getappdata(hfig,'ZoomState');
if strcmpi(zoommode, 'zoomin'),
    zoom(hfig,'inmode');
elseif strcmpi(zoommode, 'zoomout'),
    zoom(hfig,'outmode');
end

% --------------------------------------------------------------------
function plot_signal(hfig,handles)
% Plot the signals in time domain

ud = get(hfig, 'UserData');
axes(handles.timedomain);

x = ud.signal;
if ud.average,
    % Average the realizations if needed
    x = mean(x, 2);
end

plot(x)

% XLim
[xmax, NRep] = size(ud.signal);
set(handles.timedomain, 'XLim', [1 xmax]);
grid on;

title('Time Series', 'Fontsize', 8);
xlabel('Samples', 'Fontsize', 8);
ylabel('Amplitude', 'Fontsize', 8);


% --------------------------------------------------------------------
function plot_Pxx(hfig,handles)
% Plot the PSD

ud = get(hfig, 'UserData');
axes(handles.freqdomain);

if ud.average,
    % Average the realizations if needed
    ud.Pxx = mean(ud.Pxx, 2);
end

f = linspace(-1,1-1/ud.Nfft,ud.Nfft);
plot(f, 10*log10(ud.Pxx))

% XLim
set(handles.freqdomain, 'XLim', [f(1) f(end)]);
grid on;

title('PSD Estimation', 'Fontsize', 8);
xlabel('Normalized Frequency  (\times\pi rad/sample)', 'Fontsize', 8);
if ud.method>16,
    % Subspace methods
    ylabel('Pseudo Spectrum (dB)', 'Fontsize', 8);
else
    ylabel('Power Spectral Density (dB/rad/sample)', 'Fontsize', 8);
end

% Overlay the theoretical PSD
if ud.nsig ==1,
    % Test case 1 : Broadband + Narrowband components
    hold on;
    
    % Broadband component = AR process order 1
    % Use the impulse response of the all pole filter for the theoretical AR PSD
    a = -.850848;
    noisevar = (1-a^2)/10^(ud.SNR/10);
    Par = periodogram(impz(1, [1 a], ud.N), [], 'twosided', ud.Nfft);
    noisepsd = noisevar*abs(freqz(1, [1 a], ud.Nfft, 'whole')).^2;
    plot(f, 10*log10(fftshift(Par+noisepsd)), 'k', 'LineWidth', 2)
    
    % Narrowband components = 3 sinusoids
    yf = get(handles.freqdomain, 'YLim');
    f1 = 0.1;
    f2 = 0.8;
    f3 = 0.84;
    plot([f1 f1], yf, 'k', 'LineWidth', 2);
    plot([-f1 -f1], yf, 'k', 'LineWidth', 2);
    plot([f2 f2], yf, 'k', 'LineWidth', 2);
    plot([-f2 -f2], yf, 'k', 'LineWidth', 2);
    plot([f3 f3], yf, 'k', 'LineWidth', 2);
    plot([-f3 -f3], yf, 'k', 'LineWidth', 2);
    
    hold off;
    
elseif ud.nsig == 2,
    % Test case 2 : Narrowband components

    hold on;
    
    % Narrowband components = 2 sinusoids
    f1 = 0.2;
    f2 = 0.257;
    yf = get(handles.freqdomain, 'YLim');
    plot([f1 f1], yf, 'k', 'LineWidth', 2);
    plot([-f1 -f1], yf, 'k', 'LineWidth', 2);
    plot([f2 f2], yf, 'k', 'LineWidth', 2);
    plot([-f2 -f2], yf, 'k', 'LineWidth', 2);
    
    hold off;
    
elseif ud.nsig == 3,
    % Test case 3 : White Gaussian Noise
    
    hold on;
    
    xf = get(handles.freqdomain, 'XLim');
    noisevar = ud.SNR;
    pxx = 10*log10(noisevar/(2*pi));
    plot(xf, [pxx pxx], 'k', 'LineWidth', 2);
    
    hold off;
    
end


% --------------------------------------------------------------------
function window_listener(h, eventData)
% Update WVTool each time a new window is selected

fig = get(h, 'Parent');
ud=get(fig,'UserData');

% If WVTool is open
if ~isempty(ud.wvtool),
    
    % Instantiate the window object
    winclassnames = ud.winclassnames{get(h,'Value')};
    winobj = feval(str2func(['sigwin.' winclassnames]));
    winobj.length = ud.winlength;
    paramname = getparamnames(winobj);
    if ~isempty(paramname),
        set(winobj, paramname, ud.winparam);
    end
    if isa(winobj, 'sigwin.samplingflagwin'),
        set(winobj, 'sampling', ud.samplingflag);
    end
    
    % Set the window in WVTool
    addwin(ud.wvtool, winobj, [], 'Replace');
end


% --------------------------------------------------------------------
function wvtool_listener(h, eventData)
% Callback executed when WVTool is closing

% Remove the handle of WVTool when it's closed
ud=get(h,'UserData');
ud.wvtool = [];
set(h,'UserData',ud);


% [EOF]
