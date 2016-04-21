function addSimMenu(this)
%ADDSIMMENU  Install mpc @simplot-specific menus.

% Copyright 2004 The MathWorks, Inc.

AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu('show');  % search for specified menu (HOLD support)
if ~isempty(mRoot)
    return
end

% Show reference signal
% Enable only if an input signal has been defined
insize = getsize(this.input.Data);
if strcmp(this.Type,'outputs') && min(insize)>0
    mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
    'Label',xlate('Show Reference'),'Tag','show',...
    'Callback',{@localToggleInputVis this});
end
% Listeners
L = handle.listener(this,this.findprop('Input'),...
'PropertyPostSet',{@localTrackInputVis this mRoot});
set(mRoot,'UserData',{L []})
if ~isempty(this.Input)
    % Install listener to Input.Visible
    localTrackInputVis([],[],this,mRoot)
end
        
   

function localToggleInputVis(eventSrc,eventData,this)
% Toggles input visibility
Input = this.Input;
if isempty(Input)
    warndlg('There is no reference signal defined for this plot.','Show Reference Warning','modal')
else
    if strcmp(Input.Visible,'off')
        Input.Visible = 'on';
    else
        Input.Visible = 'off';
    end
end

function localTrackInputVis(eventSrc,eventData,this,mRoot)
% Install listener to track input visibility
L = get(mRoot,'UserData');
Input = this.Input;
if isempty(Input)
    L{2} = [];
    set(mRoot,'Checked','off')
else
    % Install listener to Input.Visible
    L{2} =  handle.listener(Input,Input.findprop('Visible'),...
    'PropertyPostSet',{@localSyncInputVis this mRoot});
    % Initialize check
    localSyncInputVis([],[],this,mRoot)
end
set(mRoot,'UserData',L)

function localSyncInputVis(eventSrc,eventData,this,mRoot)
% Update check status
set(mRoot,'Checked',this.Input.Visible)
