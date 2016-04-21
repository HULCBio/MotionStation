function shapenotch(Editor,event)
%SHAPENOTCH  Shape notch width.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.33 $  $Date: 2002/04/10 04:56:23 $

persistent ShapedGroup ShapedView TransAction 
persistent W0 Z1 Z2 Ts LeftRight RadSec2FreqUnits

LoopData = Editor.LoopData;
MagAxes = getaxes(Editor.Axes);  MagAxes = MagAxes(1);
FreqUnits = Editor.Axes.XUnits;
EventMgr = Editor.EventManager;

% Process request
switch event 
   
case 'init'
    % Initialization for notch width marker drag
    [ShapedGroup,ShapedView] = LocalGetSelection(gcbo);
    Ts = LoopData.Ts;
    RadSec2FreqUnits = unitconv(1,'rad/sec',FreqUnits);
    
    % Get notch frequency and initial depth (Zeta1/Zeta2) (both invariants)
    [W0,Z1] = damp(ShapedGroup.Zero(1),Ts);
    [W0,Z2] = damp(ShapedGroup.Pole(1),Ts);
    
    % Determine whether left or right marker is selected
    % RE: Don't rely on handles because markers can be on top of each other
    CP = get(MagAxes,'CurrentPoint');
    LeftRight = 1 + (CP(1,1)>RadSec2FreqUnits * W0);
    
    % Add vertical rulers
    Ylim = get(MagAxes,'Ylim');
    Wm = RadSec2FreqUnits * notchwidth(ShapedGroup,Ts);
    Zlevel = Editor.zlevel('compensator');
    LeftRuler = line(Wm([1 1]),Ylim,Zlevel(:,[1 1]),'Parent',MagAxes,...
        'Color',Editor.LabelColor,'LineStyle','--','EraseMode','xor');  % left
    RightRuler = line(Wm([2 2]),Ylim,Zlevel(:,[1 1]),'Parent',MagAxes,...
        'Color',Editor.LabelColor,'LineStyle','--','EraseMode','xor');  % right
    ShapedView.Ruler = [LeftRuler;RightRuler];
    
    % Track root location in status bar 
    EventMgr.poststatus(LocalTrackStatus(ShapedGroup,Ts,FreqUnits));
    
    % Broadcast MOVEPZ:init event
    LoopData.send('MovePZ',...
        ctrluis.dataevent(LoopData,'MovePZ',{Editor.EditedObject.Identifier,'init',ShapedGroup}));
    
    % Start transaction
    TransAction = ctrluis.transaction(LoopData,'Name','Shape Notch',...
        'OperationStore','on','InverseOperationStore','on','Compression','on');
    
case 'acquire'
    % Acquire new marker position 
    % RE: * Convert to working units (rad/sec)
    %     * Restrict X position to be in freq. range
    CP = get(MagAxes,'CurrentPoint');
    X = CP(1,1)/RadSec2FreqUnits;  
    X = max(Editor.Frequency(1),min(X,Editor.Frequency(end)));
    % Left/right marker constraints
    if LeftRight==1,  % left
        X = min(X,0.99*W0);
    else
        X = max(X,1.01*W0);
    end
    
    % Compute new values of notch zero/pole
    LocalUpdate(ShapedGroup,X,W0,Z1,Z2,Ts);
    
    % Clear open loop model (stale)
    LoopData.reset('all');
    
    % Broadcast PZDataChanged event (triggers plot updates)
    ShapedGroup.send('PZDataChanged');
    
    % Track root location in status bar 
    EventMgr.poststatus(LocalTrackStatus(ShapedGroup,Ts,FreqUnits));
    
case 'finish'
    % Button up event. Clear rulers
    delete(ShapedView.Ruler);
    ShapedView.Ruler = [];
    
    % Commit and stack transaction
    EventMgr.record(TransAction);

    % Broadcast MOVEPZ:finish event (exit RefreshMode=quick,...)  
    LoopData.send('MovePZ',...
        ctrluis.dataevent(LoopData,'MovePZ',{Editor.EditedObject.Identifier,'finish'}));
    
	% Update status and command history
	Str = ShapedGroup.movelog('',Ts);
    EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
    EventMgr.recordtxt('history',Str);
	
	% Clean up: release persistent UDD objects
	TransAction = [];   ShapedGroup = [];   ShapedView = [];
    
    % Trigger global update
    LoopData.dataevent('all');
    
end


%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%
% LocalGetSelection %
%%%%%%%%%%%%%%%%%%%%%
function [MovedGroup,hView] = LocalGetSelection(CurrentObj)
% Identifies selected PZGROUP object (pole/zero group)
% Moved PZVIEW object
hView = getappdata(CurrentObj,'PZVIEW');
% Moved PZGROUP
MovedGroup = hView.GroupData;


%%%%%%%%%%%%%%%
% LocalUpdate %
%%%%%%%%%%%%%%%
function LocalUpdate(Group,W,W0,Z1,Z2,Ts)
%  Derive value of notch pole/zero from position of width marker
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
if abs(Z1s-Z2s)<sqrt(eps)*Z2s
   % t->0.5*sqrt((x-1)^2/x/Z1s * DepthFraction/(1-DepthFraction)) as Z2s-Z1s->0
   t = sqrt((x-1)^2/x/Z1s*DepthFraction/(1-DepthFraction))/2;
else
   theta = (Z1s/Z2s)^DepthFraction;
   t = sqrt((theta-1)*(x-1)^2/x/(Z1s-theta*Z2s))/2;
end
t = min(t,1/abs(Z2));  % |t*Z2|<=1

% Root values
Z1 = t * Z1;  
Z2 = t * Z2;
Zero = W0 * (-Z1 + 1i * sqrt(1-Z1^2));
Pole = W0 * (-Z2 + 1i * sqrt(1-Z2^2));
if Ts,
    Zero = exp(Ts*Zero);   Pole = exp(Ts*Pole);
end

% Update group data
Group.Zero = [Zero ; conj(Zero)];
Group.Pole = [Pole ; conj(Pole)];


%%%%%%%%%%%%%%%%%%%%
% LocalTrackStatus %
%%%%%%%%%%%%%%%%%%%%
function Status = LocalTrackStatus(Group,Ts,FreqUnits)
% Display info about moved pole/zero

Spacing = blanks(5);
Text = 'Move the rulers left or right to adjust the notch width.';
[Wn,Zeta] = damp([Group.Zero(1);Group.Pole(1)],Ts);
Wn = unitconv(Wn,'rad/sec',FreqUnits);

Status = sprintf('%s\nNatural Frequency: %0.3g %s%sZero Damping: %0.3g%sPole Damping: %0.3g',...
    Text,Wn(1),FreqUnits,Spacing,Zeta(1),Spacing,Zeta(2));

