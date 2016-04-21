function selectgain(Editor)
%SELECTGAIN  Selects gain value by clicking on the root locus plot.
%
%   See also SISOTOOL

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 04:57:31 $

% Enabled only in idle mode
if ~strcmp(Editor.EditMode,'idle')
    return
end
Axes = Editor.Axes;
PlotAxes = getaxes(Axes);
LoopData = Editor.LoopData;
EventMgr = Editor.EventManager;

% Get ZPK data for normalized open-loop model
[OLz,OLp,OLk] = zpkdata(getopenloop(LoopData),'v');

% Compute new loop gain value
CP = get(PlotAxes,'CurrentPoint');
P = CP(1,1) + 1i * CP(1,2);
NumP = OLk * prod(P-OLz);  % evaluate norm. ol numerator at P
DenP = prod(P-OLp);        % evaluate norm. ol denominator at P
NewGainMag = abs(DenP/NumP);

% Freeze axis limits in Root Locus Editor (axis rescaling gives the 
% illusion of missing the selected point)
Axes.LimitManager = 'off';  % disable any limit updating
XlimMode = Axes.XlimMode;
YlimMode = Axes.YlimMode;
Axes.XlimMode = 'manual';
Axes.YlimMode = 'manual';

% Start transaction 
T = ctrluis.transaction(LoopData,'Name','Edit Gain',...
    'OperationStore','on','InverseOperationStore','on');

% Set new compensator gain
Editor.EditedObject.setzpkgain(NewGainMag,'mag');

% Commit and stack transaction, and update plots
EventMgr.record(T);
LoopData.dataevent('gainC');

% Notify status bar and history listeners
Status = sprintf('Loop gain changed to %0.3g',Editor.EditedObject.getgain);
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);

% Restore initial axis limit modes
Axes.XlimMode = XlimMode;
Axes.YlimMode = YlimMode;
Axes.LimitManager = 'on';

