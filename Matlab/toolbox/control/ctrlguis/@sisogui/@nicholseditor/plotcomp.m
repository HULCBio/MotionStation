function plotcomp(Editor)
%  PLOTCOMP  Renders compensator poles and zeros.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2002 The MathWorks, Inc. 
%  $Revision: 1.18 $ $Date: 2002/04/10 05:04:36 $

Ts = Editor.LoopData.Ts;
PlotAxes = getaxes(Editor.Axes);

% Get pole/zero groupinformation
PZGroups = Editor.EditedObject.PZGroup;
Nf = length(PZGroups);  % number of groups

% Initialize list of PZ group renderers (@PZVIEW objects)
Nc = length(Editor.EditedPZ);  % current number of PZVIEW objects

% Delete extra groups
if Nc > Nf,
  delete(Editor.EditedPZ(Nf+1:Nc));
  Editor.EditedPZ = Editor.EditedPZ(1:Nf,:);
end

% Add new groups
for ct = 1:Nf-Nc, 
  Editor.EditedPZ = [Editor.EditedPZ ; sisogui.pzview];
end

% Render each pole/zero group
HG = Editor.HG;  
HG.Compensator = zeros(0,1);
for ct = 1:Nf
  h = Editor.EditedPZ(ct);  % PZVIEW object for Nichols plot
  set(h, 'GroupData', PZGroups(ct));
  hPZ = LocalRender(h, PlotAxes, Editor, Ts);
  HG.Compensator = [HG.Compensator ; hPZ];
end

% Update database
Editor.HG = HG;


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalRender
% Renders pole/zero group
% ----------------------------------------------------------------------------%
function [hPZ] = LocalRender(hView, PlotAxes, Editor, Ts)
% HVIEW = @PZVIEW object rendering a given pole/zero group

% RE: Leave X and Y coordinate undefined (resolved by one-shot interpxy)
Style = Editor.LineStyle;
PZGroup = hView.GroupData;  % Rendered PZGROUP
Zlevel = Editor.zlevel('compensator');

% Render zeros
Zeros = PZGroup.Zero;   % zero values
if ~isempty(Zeros)
  if Ts
    FreqZ = min(damp(Zeros(1), Ts), pi/Ts);
  else
    FreqZ = damp(Zeros(1)); % in rad/sec
  end
  hZ = line(NaN, NaN, Zlevel, ...
	    'Parent', PlotAxes, ...
	    'Visible', Editor.Visible, ...
	    'UserData', FreqZ, ...
	    'LineStyle', 'none', ...
	    'Color', Style.Color.Compensator, ...
	    'HelpTopicKey', 'nicholscompensatorzero', ...
	    'Marker', 'o', 'MarkerSize', 6, ...
	    'ButtonDownFcn', {@LocalMovePZ Editor 'init'});
  setappdata(hZ, 'PZVIEW', hView);
  
  if any(strcmp(PZGroup.Type, {'Complex', 'Notch'}))
    set(hZ,'LineWidth', 2)
  end
else
  hZ = zeros(0,1);
  FreqZ = [];
end
hView.Zero = hZ(ones(1, length(Zeros)), 1);


% Render poles
Poles = PZGroup.Pole;   % zero values
if ~isempty(Poles)
  if Ts
    FreqP = min(damp(Poles(1), Ts), pi/Ts);
  else
    FreqP = damp(Poles(1)); % in rad/sec
  end
  hP = line(NaN, NaN, Zlevel, ...
	    'Parent', PlotAxes, ...
	    'Visible', Editor.Visible, ...
	    'UserData', FreqP, ...
	    'LineStyle', 'none', ...
	    'Color', Style.Color.Compensator, ...
	    'HelpTopicKey', 'nicholscompensatorpole', ...
	    'Marker', 'x', 'MarkerSize', 8, ...
	    'ButtonDownFcn', {@LocalMovePZ Editor 'init'}); 
  setappdata(hP, 'PZVIEW', hView);
  
  if any(strcmp(PZGroup.Type, {'Complex', 'Notch'}))
    set(hP, 'LineWidth', 2)
  end
else
  hP = zeros(0,1);
  FreqP = [];
end
hView.Pole = hP(ones(1,length(Poles)), 1);

% Overall handles (no repetition)
hPZ = [hZ(:,1) ; hP(:,1)];

% Add notch width markers
if strcmp(PZGroup.Type, 'Notch')
  FreqM = notchwidth(PZGroup, Ts);  % Marker frequencies
  nwm(1,1) = line(NaN, NaN, Zlevel, 'Parent', PlotAxes, 'UserData', FreqM(1));
  nwm(2,1) = line(NaN, NaN, Zlevel, 'Parent', PlotAxes, 'UserData', FreqM(2));
  
  set(nwm, 'Visible', Editor.Visible, ...
	   'LineStyle', 'none', ...
	   'Marker', 'diamond', ...
	   'MarkerFaceColor', [0 0 0], ...
	   'MarkerSize', 6, 'Color', [0 0 0], ...
	   'Tag', 'NotchWidthMarker', ...
	   'HelpTopicKey', 'sisonotchwidthmarker', ...
	   'ButtonDownFcn', {@LocalShapeNotch Editor 'init'}); 
  setappdata(nwm(1), 'PZVIEW', hView);
  setappdata(nwm(2), 'PZVIEW', hView);
  
  hView.Extra = nwm;
  hPZ = [hPZ ; nwm];
else
  hView.Extra = zeros(0,1);
end

hView.Ruler = zeros(0,1);


% ----------------------------------------------------------------------------%
% LocalMovePZ
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain,trackpz when directed callback are available
% ----------------------------------------------------------------------------%
function LocalMovePZ(hSrc, junk, Editor, action)
persistent SISOfig WBMU

switch action
 case 'init'
  % Initialize move
  SISOfig = gcbf;
  if ~strcmp(Editor.EditMode,'idle')
    % Redirect to editor axes
    Editor.mouseevent('bd',get(hSrc,'parent'));
    
  elseif strcmp(get(SISOfig,'SelectionType'),'normal')
    % Change pointer
    setptr(SISOfig, 'closedhand')
    
    % Take over window mouse events
    WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
    set(SISOfig, 'WindowButtonMotionFcn', {@LocalMovePZ Editor 'acquire'}, ...
		 'WindowButtonUpFcn', {@LocalMovePZ Editor 'finish'});
    % Initialize tracking algorithm and notify peers
    Editor.trackpz('init');
  end
  
 case 'acquire'
  % Track mouse location (move)
  Editor.trackpz('acquire');
  
 case 'finish'
  % Restore initial conditions
  set(SISOfig, {'WindowButtonMotionFcn','WindowButtonUpFcn'}, WBMU, ...
	       'Pointer', 'arrow')
  % Clean up and update
  Editor.trackpz('finish');
end


% ----------------------------------------------------------------------------%
% LocalShapeNotch
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain when directed callback are available
% ----------------------------------------------------------------------------%
function LocalShapeNotch(hSrc, junk, Editor, action)
persistent SISOfig WBMU

switch action
 case 'init'
  % Initialize move
  SISOfig = gcbf;
  if ~strcmp(Editor.EditMode,'idle')
    % Redirect to editor axes
    Editor.mouseevent('bd',get(hSrc,'parent'));
    
  elseif strcmp(get(SISOfig,'SelectionType'),'normal')
    % Change pointer
    setptr(SISOfig,'closedhand')
    
    % Take over window mouse events
    WBMU = get(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'});
    set(SISOfig,'WindowButtonMotionFcn',{@LocalShapeNotch Editor 'acquire'},...
		'WindowButtonUpFcn', {@LocalShapeNotch Editor 'finish'});
    % Initialize tracking algorithm and notify peers
    Editor.shapenotch('init');
  end
  
 case 'acquire'
  % Track mouse location (move)
  Editor.shapenotch('acquire');
  
 case 'finish'
  % Restore initial conditions
  set(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'}, WBMU, ...
	       'Pointer', 'arrow')
  % Clean up and update
  Editor.shapenotch('finish');
end
