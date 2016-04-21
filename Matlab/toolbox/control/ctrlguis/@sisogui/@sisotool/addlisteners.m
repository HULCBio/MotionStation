function addlisteners(sisodb)
%ADDLISTENERS  Add GUI-wide listeners.

%   Author: P. Gahinet  
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.17 $  $Date: 2002/06/11 17:29:50 $

HG = sisodb.HG;
LoopData = sisodb.LoopData;
PlotEditors = sisodb.PlotEditors;

% Listeners to @sisotool properties
Listeners = handle.listener(sisodb,sisodb.findprop('GlobalMode'),...
    'PropertyPostSet',@GlobalModeChanged);

% Listeners to @loopdata properties
%   1) FirstImport: side effects of first import
%   2) SystemName: update figure name
Listeners = [Listeners ; ...
        handle.listener(LoopData,'FirstImport',@activate) ; ...
        handle.listener(LoopData,'SingularInnerLoop',@LocalAlgLoopWarning) ; ...
        handle.listener(LoopData,findprop(LoopData,'SystemName'),...
        'PropertyPostSet',@SystemNameCB)];

% Listeners to editor properties and events
Listeners = [Listeners ; ...
        handle.listener(PlotEditors,PlotEditors(1).findprop('Visible'),...
        'PropertyPostSet',{@LocalCheckView HG.Menus.View.Editors});...
        handle.listener(PlotEditors,PlotEditors(1).findprop('EditMode'),...
        'PropertyPostSet',@LocalModeChanged)];

% Event listeners
Listeners = [Listeners ; handle.listener(sisodb,'ShowData',@ShowDataCB)];

% Target listener callbacks
set(Listeners,'CallbackTarget',sisodb)

% Make listeners persistent
sisodb.Listeners = Listeners;


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCheckView %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckView(sisodb,event,hMenu)
% Side-effects of editor visibility change
% RE: Layout update is triggered by Editor because of sequencing problems
% Update UI menu state 
set(hMenu(:),{'Checked'},get(sisodb.PlotEditors,{'Visible'}))


%%%%%%%%%%%%%%%%%%%%
%%% SystemNameCB %%%
%%%%%%%%%%%%%%%%%%%%
function SystemNameCB(sisodb,event)
% Side-effects of first import
% Update figure title
set(sisodb.Figure,'Name',sprintf('SISO Design for System %s',event.NewValue));


%%%%%%%%%%%%%%%%%%
%%% ShowDataCB %%%
%%%%%%%%%%%%%%%%%%
function ShowDataCB(sisodb,event)
% Side-effects of first import
% REVISIT: remove 3rd arg when hSRc contains source handle
addview(sisodb,'SystemView');


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalModeChanged(sisodb,event)
% Called when EditMode changes in some Editor
if strcmp(event.NewValue,'idle')
    % Abort any global mode when some editor returns to idle (local mode change)
    sisodb.GlobalMode = 'off';
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GlobalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function GlobalModeChanged(sisodb,event)
% Called when GlobalMode is changed
if strcmp(event.NewValue,'off') && ~isoff(sisodb)
    % Revert to idle mode locally
    set(sisodb.PlotEditors,'EditMode','idle');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAlgLoopWarning %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAlgLoopWarning(sisodb,event)
% Called when inner loop is singular
if ~isoff(sisodb) && all(strcmp(get(sisodb.PlotEditors,'RefreshMode'),'normal'))
   % Issue warning
   warndlg('Algebraic loop in inner loop G-H-F.','SISO Tool Warning','modal')
end
