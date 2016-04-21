function shapenotch(Editor, event)
%SHAPENOTCH  Shape notch width.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet, Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:04:44 $

persistent ShapedGroup
persistent W0 Z1 Z2 isLeft TransAction

LoopData = Editor.LoopData;
PlotAxes = getaxes(Editor.Axes);
EventMgr = Editor.EventManager;
Ts = LoopData.Ts;

% Process request
switch event 
case 'init'
    % Initialization for notch width marker drag
    CObj = gcbo;
    [ShapedGroup, ShapedView] = LocalGetSelection(CObj);
    
    % Get notch frequency and initial depth (Zeta1/Zeta2) (both invariants)
    [W0, Z1] = damp(ShapedGroup.Zero(1), Ts);
    [W0, Z2] = damp(ShapedGroup.Pole(1), Ts);
    
    % Determine whether left or right marker is selected
    % RE: Don't rely on handles because markers can be on top of each other
    Wm = get(CObj, 'UserData');
    isLeft = (Wm < W0);
    
    % Track root location in status bar 
    EventMgr.poststatus(LocalTrackStatus(ShapedGroup, Ts, ...
        Editor.FrequencyUnits));
    
    % Broadcast MOVEPZ:init event
    LoopData.send('MovePZ', ctrluis.dataevent(LoopData, 'MovePZ', ...
        {Editor.EditedObject.Identifier, 'init', ShapedGroup}));
    
    % Start transaction
    TransAction = ctrluis.transaction(LoopData,'Name','Shape Notch',...
        'OperationStore','on','InverseOperationStore','on','Compression','on');
    
case 'acquire'
    % Get Nichols plot data in current units
    [Gain, Magnitude, Phase, Frequency] = nicholsdata(Editor);
    
    % Acquire new marker position 
    % REMARK: * Convert to working units (rad/sec)
    %         * Restrict X position to be in Phase range
    %         * Restrict Y position to be in Mag range
    CP = get(PlotAxes, 'CurrentPoint');
    X = max(min(Phase), min(CP(1,1), max(Phase)));
    Y = max(min(Magnitude), min(CP(1,2), max(Magnitude)));
    
    % Acquire new marker angle (use lower/upper frequency range)
    if isLeft
        I = find(Editor.Frequency < W0);
    else
        I = find(Editor.Frequency > W0);
    end
    
    % Left/right marker frequency constraints
    W = Editor.project(X, Y, Phase(I), Magnitude(I), Editor.Frequency(I));
    if isLeft
        W = min(W, 0.99 * W0);
    else
        W = max(W, 1.01 * W0);
    end
    
    % Compute new values of notch zero/pole
    LocalUpdate(ShapedGroup, W, W0, Z1, Z2, Ts);
    
    % Clear open loop model (stale)
    LoopData.reset('all');
    
    % Broadcast PZDataChanged event (triggers plot updates)
    ShapedGroup.send('PZDataChanged');
    
    % Track root location in status bar 
    EventMgr.poststatus(LocalTrackStatus(ShapedGroup, Ts, ...
        Editor.FrequencyUnits));
    
case 'finish'
    % Button up event.  Commit and stack transaction
    EventMgr.record(TransAction);
    
    % Broadcast MOVEPZ:finish event (exit RefreshMode=quick,...)  
    LoopData.send('MovePZ', ctrluis.dataevent(LoopData, 'MovePZ', ...
        {Editor.EditedObject.Identifier, 'finish'}));
    
    % Update status and command history
    Str = ShapedGroup.movelog('', Ts);
    EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
    EventMgr.recordtxt('history',Str);
    
    % Clean up: release persistent UDD objects
    TransAction = []; ShapedGroup = [];
    
    % Trigger global update
    dataevent(LoopData, 'all');
end


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalGetSelection
% Identifies selected PZGROUP object (pole/zero group)
% ----------------------------------------------------------------------------%
function [MovedGroup, hView] = LocalGetSelection(CurrentObj)
% Moved PZVIEW object
hView = getappdata(CurrentObj, 'PZVIEW');

% Moved PZGROUP
MovedGroup = hView.GroupData;


% ----------------------------------------------------------------------------%
% Function: LocalUpdate
% Derive value of notch pole/zero from position of width marker
% ----------------------------------------------------------------------------%
function LocalUpdate(Group, W, W0, Z1, Z2, Ts)
%  The natural frequency Wn and the depth factor Z1/Z2 are 
%  invariant during the move operation.

% Markers are located at DepthFraction of the total notch depth in dB
% (for an isolated notch)
DepthFraction = 0.25;

% Moving the width marker amounts to transforming (Z1,Z2)->(t*Z1,t*Z2)
% The various quantities are related by
%     (x-1)^2 + 4 t^2 Zeta1^2 x
%     ------------------------- = (Zeta1/Zeta2)^(2*DepthFraction)
%     (x-1)^2 + 4 t^2 Zeta2^2 x
% with x = (W/W0)^2 .  Solve for t and enforce |t*Z2|<=1
Z1s = Z1^2;  
Z2s = Z2^2;
x = (W/W0)^2;

if abs(Z1s-Z2s) < sqrt(eps)*Z2s
    % t->0.5*sqrt((x-1)^2/x/Z1s * DepthFraction/(1-DepthFraction)) as Z2s-Z1s->0
    t = sqrt((x-1)^2 / x / Z1s * DepthFraction / (1-DepthFraction)) / 2;
else
    theta = (Z1s / Z2s)^DepthFraction;
    t = sqrt((theta-1) * (x-1)^2 / x / (Z1s-theta*Z2s)) / 2;
end
t = min(t, 1/abs(Z2));  % |t*Z2|<=1

% Root values
Z1 = t * Z1;  
Z2 = t * Z2;
Zero = W0 * (-Z1 + 1i * sqrt(1 - Z1^2));
Pole = W0 * (-Z2 + 1i * sqrt(1 - Z2^2));
if Ts,
    Zero = exp(Ts*Zero);
    Pole = exp(Ts*Pole);
end

% Update group data
Group.Zero = [Zero ; conj(Zero)];
Group.Pole = [Pole ; conj(Pole)];


% ----------------------------------------------------------------------------%
% Function: LocalTrackStatus
% Display info about moved pole/zero
% ----------------------------------------------------------------------------%
function Status = LocalTrackStatus(Group, Ts, FreqUnits)
Spacing = blanks(5);
Text = 'Move the rulers along the curve to adjust the notch width.';
[Wn, Zeta] = damp([Group.Zero(1); Group.Pole(1)], Ts);
Wn = unitconv(Wn, 'rad/sec', FreqUnits);

Status = sprintf('%s\nNatural Frequency: %0.3g %s%sZero Damping: %0.3g%sPole Damping: %0.3g',...
    Text, Wn(1), FreqUnits, Spacing, Zeta(1), Spacing, Zeta(2));
