function varargout = filtview(varargin)
%FILTVIEW Render FVTool from SPTool
%   This function is used to render the Filter Visualization Tool
%   (FVTool) from SPTool.
%   
%   Type 'sptool' to start the Signal Processing GUI Tool and access
%   the Filter Visualization Tool (FVTool).
%
%   See also SPTOOL, FVTOOL, SIGBROWSE, FILTDES, SPECTVIEW.

%   Author: R. Malladi
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.23.4.2 $  $Date: 2004/04/13 00:32:23 $ 

if nargin == 0,
    if isempty(findobj(0,'tag','sptool'))
        disp('Type ''sptool'' to start the Signal GUI.')
    else
        disp('To use the Filter Viewer, click on a filter in the ''Filters''')
        disp('column in the ''SPTool'', and then click on the ''View'' button.')
    end
    return
end
action = varargin{1};

switch action
%--------------------------------------------------------------------------
% enable = filtview('selection',action,msg,SPTfig)
%  Respond to messages from SPTool.
% 
%  Possible actions are 'view'
%   
%  Button is enabled when there is a filter selected
% 
%  msg will be either:
%   1. 'new'      2. 'value'    3. 'Fs'
%   4. 'label'    5. 'dup'      6. 'clear'
% 
case 'selection'
    msg = varargin{3};
    SPToolFig = varargin{4};
    [hFVTs, f, varargout{1}] = lclSelection(SPToolFig);
    
    if isempty(hFVTs)
        return;
    end
    
    % Update the FVTools Launched from SPTool or Delete the existing ones 
    % if the selection is a null
    % Here the last input argument for the update_fvtool is 0, which
    % indicates that we need to look up for the filter index
    update_fvtool(hFVTs,f,msg,0);

%--------------------------------------------------------------------------
% filtview('action','view')
%  Open FVTool window and display the Filter Response
%  of currently selected filter(s).
% 
%  This callback is called by SPTool when the user clicks the
%  "View" button under "Filters" component in SPTool.
%
case 'action'
    FiltersSelected = sptool('Filters',0);
    % Launch a New FVTool & store its handle in SPTool userdata
    new_fvtool(FiltersSelected);
    
%--------------------------------------------------------------------------
% filtview('SPTclose')
%  Deletes all the FVTool client window(s) opened from SPTool.
%
%  SPTool will call filtview('SPTclose') when the user closes the SPTool window.
%
case 'SPTclose'
    SPToolFig = findobj(0,'type','figure','tag','sptool');
    ud = get(SPToolFig,'userdata');
    for k = 1 : length(ud.components(2).verbs),
        if strcmpi('filtview',ud.components(2).verbs(k).owningClient);
            break;
        end
    end
    
    % Close all the FVTools opened from SPTool
    for m = 1 : length(ud.components(2).verbs(k).hFVTs)
        delete(ud.components(2).verbs(k).hFVTs(m).FigureHandle);
    end
end


%--------------------------------------------------------------------------
% ------------------------ Local Functions --------------------------------
%--------------------------------------------------------------------------
function new_fvtool(filtStruc)
%NEW_FVTOOL Function for Launching a New FVTool from SPTool
% The handle of this FVTool is stored in the userdata of SPTool
% 
% Inputs:
%  filtStruc - Filter Structure(s) stored in SPTool
% 

% Create the dfiltwfs filter objects
for k = 1 : length(filtStruc),
    DFILT_DF1 = dfilt.df1(filtStruc(k).tf.num,filtStruc(k).tf.den);
    DFILTWFS(k) = dfilt.dfiltwfs(DFILT_DF1);
    DFILTWFS(k).Fs = filtStruc(k).Fs;
    DFILTWFS(k).Name = filtStruc(k).label;
end

% Set the initial frequency mode of FVTool.
opts.freqmode = 'off';
% Launch FVTool with the (multiple) filters selected.
hFig = fvtool(DFILTWFS,opts);
% Set the FVTool HostName to 'SPTool' to show its link to SPTool.
set(hFig, 'HostName', 'SPTool');
% Get the actual FVTool handle
hFVT = getcomponent(hFig,'fvtool');
% Set the FsEditable property to 'off' to disable the sampling frequency.
set(hFVT, 'FsEditable','off');

% Find SPTool to store FVTool handles in its userdata property
SPToolFig = findobj(0,'type','figure','tag','sptool');
ud = get(SPToolFig,'userdata');

for k = 1 : length(ud.components(2).verbs),
    if strcmpi('filtview',ud.components(2).verbs(k).owningClient);
        break;
    end
end

% Install listeners on the FVTool object
fvtoolListener = installlisteners(hFVT,SPToolFig,k);

% Store the handle of FVTool object in the SPTool userdata structure
% Store the handle of FVTool listener in the SPTool userdata structure
% These handles will be used in keeping the FVTools in sync with SPTool
ud.components(2).verbs(k).hFVTs = [ud.components(2).verbs(k).hFVTs hFVT];
ud.components(2).verbs(k).listeners = ...
    [ud.components(2).verbs(k).listeners fvtoolListener];
set(SPToolFig,'userdata',ud);

% Update the userdata in SPTool
update_sptoolstruc(hFVT,SPToolFig);


% ------------------------------------------------------------------------
% Install Listeners on FVTool object (hFVT) properties and events
% ------------------------------------------------------------------------
function newPlotListener = installlisteners(hFVT,SPToolFig,k)
%INSTALLLISTENERS Install Listeners on the FVTool Object
% 
% Setup the listener for the FVTool Closing Event
closeList = handle.listener(hFVT, 'sigguiClosing',...
    {@closing_listener, SPToolFig, k});
sigsetappdata(hFVT.FigureHandle, 'sptool', 'closelistener', closeList);

% Setup a listener on FVTool NewPlot Event
newPlotListener = handle.listener(hFVT, ...
    'NewPlot', {@newplot_listener, SPToolFig});
set(newPlotListener, 'CallbackTarget', hFVT);
sigsetappdata(hFVT.FigureHandle, 'sptool',...
    'newplotlistener', newPlotListener);


% ------------------------------------------------------------------------
% Listener function on FVTool Close event
% ------------------------------------------------------------------------
function closing_listener(hFVT,eventData,SPToolFig,k)
%CLOSING_LISTENER Listener to the closing event of FVTool
%   
% Updates the hFVTs field of SPTool userdata structure
% 
SPToolFig = findobj(0,'type','figure','tag','sptool');
ud = get(SPToolFig,'userdata');

L = find(ud.components(2).verbs(k).hFVTs == hFVT);
if ~isempty(L)
    ud.components(2).verbs(k).hFVTs(L) = [];
    set(SPToolFig,'userdata',ud);
end


% ------------------------------------------------------------------------
% Listener function on FVTool 'NewPlot' event
% ------------------------------------------------------------------------
function newplot_listener(hFVT,eventData,SPToolFig)
%NEWPLOT_LISTENER Listener function on FVTool NewPlot event
%   
% Updates Filters structure in the userdata of SPTool
% 
update_sptoolstruc(hFVT,SPToolFig);


%--------------------------------------------------------------------------
% Local function for the selection case
%--------------------------------------------------------------------------
function [hFVTs, filtStructs, btnStatus] = lclSelection(SPToolFig)
%LCLSELECTION Local function for the selection case
% 
% Inputs:
%  SPToolFig - SPTool figure handle
% 
% Outputs:
%  hFVTs - FVTool object handles stored in SPTool userdata
%  filtStructs - Filters selected in SPTool (of type struct)
%  btnStatus - To set the VIEW button's Enable property ON/OFF
%  
ud = get(SPToolFig,'userdata');

% Obtain the FVTool object handles (stored in SPTool userdata)
for k = 1 : length(ud.components(2).verbs),
    if strcmpi('filtview',ud.components(2).verbs(k).owningClient);
        break;
    end
end

% Check if hFVTs is a field in the SPTool userdata structure
% hFVTs contains these FVTool object handles
if isfield(ud.components(2).verbs(k),'hFVTs')
    hFVTs = ud.components(2).verbs(k).hFVTs;
else
    % Create hFVTs, Listener fields in the userdata of SPTool at startup
    hFVTs = [];
    ud.components(2).verbs(k).hFVTs = hFVTs;
    ud.components(2).verbs(k).listeners = [];
    set(SPToolFig,'userdata',ud);
end

% Get the currently selected filter structure(s) from SPTool
[filtStructs, ind] = sptool('Filters',0);

if length(ind)>=1
    % only allow a view if a filter is selected
    btnStatus = 'on';
else
    btnStatus = 'off';
end


% ------------------------------------------------------------------------
% Function to update SPTool userdata (Filters structure)
% ------------------------------------------------------------------------
function update_sptoolstruc(hFVT,SPToolFig)
%UPDATE_SPTOOLSTRUC(hFVT,SPToolFig) Update SPTool Filters structure
% 
currentAnalysis = hFVT.Analysis;
if isempty(hFVT.Filters) || strcmpi(currentAnalysis, 'filtercoeffs')
    return;
end

% Get the analysis data from FVTool
[X, Y] = getdata(hFVT);

ud = get(SPToolFig,'userdata');
Filters = sptool('Filters');
selection = get(ud.list(2),'value');

indx = 1;
while indx <= length(selection),
    % Based on the current analysis, update the fields in SPTool userdata
    switch currentAnalysis
        case {'magresp', 'magnphaseresp'}
            Filters(selection(indx)).f = X{indx};
            Filters(selection(indx)).H = Y{indx};
        case 'groupdelay'
            Filters(selection(indx)).f = X{indx};
            Filters(selection(indx)).G = Y{indx};
        case 'impresp'
            Filters(selection(indx)).t = X{indx};
            Filters(selection(indx)).imp = Y{indx};
        case 'stepresp'
            Filters(selection(indx)).t = X{indx};
            Filters(selection(indx)).step = Y{indx};
        case 'pzplot'
            [z,p,k] = zpk(hFVT.Filters(indx).Filter);
            Filters(selection(indx)).zpk.z = z;
            Filters(selection(indx)).zpk.p = p;
            Filters(selection(indx)).zpk.k = k;
    end
    indx = indx + 1;
end

ud.session{2} = Filters;
ud.unchangedFlag = 0;
set(SPToolFig,'userdata',ud);


%--------------------------------------------------------------------------
% Utility function to modify the analysis data before storing it in SPTool
%--------------------------------------------------------------------------
function [X,Y] = getdata(hFVT)
%GETDATA Get the FVTool analysis data for storing it in SPTool
% This function takes care of the incompatibilities if any.
% 
% Get the analysis data from FVTool
[X, Y] = getanalysisdata(hFVT);

currentAnalysis = hFVT.Analysis;
RANGE = getparameter(hFVT,'unitcircle');
unitCircle = RANGE.Value;

switch currentAnalysis
    case {'magresp', 'phaseresp', 'magnphaseresp', 'groupdelay'}
        if ~strcmpi(unitCircle, 'Specify freq. vector')
            if strcmpi(get(getparameter(hFVT, 'freqmode'), 'Value'), 'Normalized')
                % Convert the frequency scale from Normalized to Hz before storing it
                % in the SPTool userdata structure.
                X = normalized2hz(hFVT,X,unitCircle);
            end
            % Remove replicas that would have been created by FVTool
            [X, Y] = removereplicas(hFVT,X,Y,unitCircle);
        end
    case {'impresp', 'stepresp'}
        if (get(getparameter(hFVT, 'timemode'), 'Value') == 'Samples')
            % Convert the time scale from Samples to Seconds before storing it
            % in the SPTool userdata structure.
            X = samples2secs(hFVT,X);
        end
end


%--------------------------------------------------------------------------
% Utility function to convert the frequency scale from Normalized to Hz
%--------------------------------------------------------------------------
function X = normalized2hz(hFVT,X,unitCircle)
%NORMALIZED2HZ Convert the frequency scale from Normalized to Hz
% 
maxFs = getmaxfs(hFVT.Filters);
for k = 1 : length(hFVT.Filters)
    if strcmpi(unitCircle, '[0, pi)') || ...
            strcmpi(unitCircle, '[-pi, pi)')
        X{k} = X{k}*maxFs/2;
    elseif strcmpi(unitCircle, '[0, 2pi)')
        X{k} = X{k}*maxFs;
    end
end


%--------------------------------------------------------------------------
% Utility function to convert the time scale from Samples to Seconds
%--------------------------------------------------------------------------
function X = samples2secs(hFVT,X)
%SAMPLES2SECS Convert the time scale from Samples to Seconds
% 
for k = 1 : length(hFVT.Filters)
    X{k} = X{k}/hFVT.Filters(k).Fs;
end


%--------------------------------------------------------------------------
% Utility function to remove the replicas in FVTool frequency response
%--------------------------------------------------------------------------
function [X,Y] = removereplicas(hFVT,X,Y,unitCircle)
%REMOVEREPLICAS Remove the replicas in FVTool frequency response
% 
% Check for any frequency response replicas in the analysis data
maxFs = getmaxfs(hFVT.Filters);

NFFT = getparameter(hFVT,'nfft');
nfftValue = NFFT.Value;

for k = 1 : length(hFVT.Filters)
    Fs = hFVT.Filters(k).Fs;
    if (Fs ~= maxFs)
        if strcmpi(unitCircle, '[-Fs/2, Fs/2)') || ...
                strcmpi(unitCircle, '[-pi, pi)')
            lowerIndx = find(X{k} == -Fs/2);
            upperIndx = find(X{k} == Fs/2);
            X{k} = X{k}(lowerIndx : upperIndx-1);
            Y{k} = Y{k}(lowerIndx : upperIndx-1);
        else
            X{k} = X{k}(1:nfftValue);
            Y{k} = Y{k}(1:nfftValue);
        end
    end
end

