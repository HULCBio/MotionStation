function mRoot = addSimMenu(this,menuType)
%ADDSIMMENU  Install @simplot-specific menus.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:48 $

AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
    return
end

switch menuType
    
    case 'show'
        % Show inoput signal
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
        'Label',xlate('Show Input'),'Tag','show',...
        'Callback',{@localToggleInputVis this});
        % Listeners
        L = handle.listener(this,this.findprop('Input'),...
        'PropertyPostSet',{@localTrackInputVis this mRoot});
        set(mRoot,'UserData',{L []})
        if ~isempty(this.Input)
            % Install listener to Input.Visible
            localTrackInputVis([],[],this,mRoot)
        end
        % Add right click menu for lsim GUI
    case 'lsimdata'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
        'Label',xlate('Input data...'),'Tag','lsimdata',...
        'Callback',{@localgui this 'lsimdata'},'separator','on');
        % Add right click menu for "initial" for of lsim GUI
    case 'lsiminit'
        mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
        'Label',xlate('Initial condition...'),'Tag','lsiminit',...
        'Callback',{@localgui this 'lsiminit'});
end


%-------------------- Local Functions ---------------------------

function localgui(eventSrc, eventGUI, this, mode)

% open the lsim GUI
this.lsimgui(mode);

function localToggleInputVis(eventSrc,eventData,this)
% Toggles input visibility
Input = this.Input;
if isempty(Input)
    warndlg('There is no input signal defined for this plot.','Show Input Warning','modal')
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
