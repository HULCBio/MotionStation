function update(Editor,varargin)
%UPDATE  Updates Nichols Editor and Regenerates Plot.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.32 $ $Date: 2002/06/11 17:29:35 $

% Return if Editor if inactive.
if strcmp(Editor.EditMode, 'off') | strcmp(Editor.Visible, 'off')
  return
end

% Model data
LoopData = Editor.LoopData;
Ts = LoopData.Ts;  % sample time

% ----------------------------------------------------------------------------%
% Update Frequency Response Data
% ----------------------------------------------------------------------------%
% Get normalized open-loop (ZPK gain replaced by its sign)
NormOpenLoop = getopenloop(Editor.LoopData);
Editor.SingularLoop = (~isfinite(NormOpenLoop));
if Editor.SingularLoop
  % Open loop is not defined, e.g. when minor loop cannot be closed in config 4
   Editor.clear;  return
end
GainMag = getzpkgain(Editor.EditedObject,'mag'); 

% Compute Nichols plot data (units = rad/sec,abs,degrees)
lwarn = lastwarn; warn = warning('off');
[Editor.Magnitude,Editor.Phase,Editor.Frequency,FreqFocus] = ...
   nichols(Editor,{NormOpenLoop});
warning(warn); lastwarn(lwarn);

% Conversion factors
MagData = mag2dB(GainMag * Editor.Magnitude);
PhaseData = unitconv(Editor.Phase, 'deg', Editor.Axes.XUnits);
if Ts
  NyqFreq = pi / Ts;
end

% Resolve unidentified focus (quasi-integrator) by looking
if isempty(FreqFocus)
   % for 0dB gain crossings to anchor focus
   idxc = find(MagData(1:end-1).*MagData(2:end)<=0);
   if ~isempty(idxc)
      FreqFocus = [Editor.Frequency(idxc(1))/10 , 10*Editor.Frequency(idxc(1)+1)];
   elseif Ts
      FreqFocus = NyqFreq * [0.05,1];
   else
      FreqFocus = [0.1,1];
   end
end

% Set preferred frequency range
Editor.FreqFocus = FreqFocus;


% ----------------------------------------------------------------------------%
% Render Data
% ----------------------------------------------------------------------------%
HG = Editor.HG;
PlotAxes = getaxes(Editor.Axes); 
Style = Editor.LineStyle;
UIC = get(PlotAxes, 'uicontextmenu');  % axis context menu

% Clear HG objects managed by Nichols editor
Editor.clear;

% Check if the system poles/zeros are to be shown
if strcmp(Editor.ShowSystemPZ, 'on')
  PZVis = Editor.Visible;
else
  PZVis = 'off';
end

% Find the fixed poles and zeros
[FixedZeros, FixedPoles] = fixedpz(LoopData);

% System zeros (discard conjugates of imaginary zeros)
FixedZeros = [FixedZeros(~imag(FixedZeros), :) ; ...
	      FixedZeros(imag(FixedZeros) > 0, :)];
FreqZ = damp(FixedZeros, Ts); % in rad/sec
MagPhaZ = [];

% Discard roots whose CT frequency exceeds pi/Ts
if Ts,
  idx = find(FreqZ <= NyqFreq);
  FixedZeros = FixedZeros(idx);
  FreqZ = FreqZ(idx);
end

% Line structure for zeros
Zlevel = Editor.zlevel('system');
for ct = length(FixedZeros):-1:1
   MagPhaZ(ct,1) = line(NaN, NaN, Zlevel, ...
      'Parent', PlotAxes, ...
      'XlimInclude','off',...
      'YlimInclude','off',...      
      'UserData', FreqZ(ct), ...
      'Visible', PZVis,...
      'LineStyle', 'none', ...
      'Marker', 'o', ...
      'MarkerSize', 5, ...
      'Color', Style.Color.System, ...
      'UIContextMenu', UIC, ...
      'HelpTopicKey', 'nicholssystemzero', ...
      'ButtonDownFcn', {@LocalShowData Editor});
end

% Highlite imaginary zeros
imfz = find(imag(FixedZeros) > 0);
set(MagPhaZ(imfz, :), 'LineWidth', 2)

% System poles (discard conjugates of imaginary poles)
FixedPoles = [FixedPoles(~imag(FixedPoles), :) ; ...
	      FixedPoles(imag(FixedPoles) > 0, :)];
FreqP = damp(FixedPoles, Ts);  % in rad/sec
MagPhaP = [];

% Discard roots whose CT frequency exceeds pi/Ts
if Ts,
  idx = find(FreqP <= NyqFreq);
  FixedPoles = FixedPoles(idx);
  FreqP = FreqP(idx);
end

% Line structure for poles
for ct = length(FixedPoles):-1:1
   MagPhaP(ct,1) = line(NaN, NaN, Zlevel, ...
      'Parent', PlotAxes, ...
      'XlimInclude','off',...
      'YlimInclude','off',...      
      'UserData', FreqP(ct), ...
      'Visible', PZVis,...
      'LineStyle', 'none', ...
      'Marker', 'x', ...
      'MarkerSize', 6, ...
      'Color', Style.Color.System, ...
      'UIContextMenu', UIC, ...
      'HelpTopicKey', 'nicholssystempole', ...
      'ButtonDownFcn', {@LocalShowData Editor});
end

% Highlite imaginary poles
imfp = find(imag(FixedPoles) > 0);
set(MagPhaP(imfp, :), 'LineWidth', 2);

% Handle summary
HG.System = [MagPhaZ ; MagPhaP];

% Plot the Nichols plot
Zdata = Editor.zlevel('curve', [length(PhaseData) 1]);
HG.NicholsPlot = line(PhaseData, MagData, Zdata, ...
   'Parent', PlotAxes, ...
   'XlimInclude','off',...
   'YlimInclude','off',...      
   'Color', Style.Color.Response, ...
   'UIContextMenu', UIC, ...
   'Tag', xlate('Open-loop Nichols plot.'), ...
   'HelpTopicKey', 'sisonicholsplot', ...
   'ButtonDownFcn', {@LocalMoveGain Editor 'init'});  

% Update portion of Nichols plot to be included in limit picking
% REVISIT: Simply set NicholsPlot's X/YlimIncludeData properties when available
InFocus = find(Editor.Frequency >= FreqFocus(1) & Editor.Frequency <= FreqFocus(2));
set(HG.NicholsShadow,...
   'XData',PhaseData(InFocus),'YData',MagData(InFocus),'ZData',zeros(size(InFocus)))

% Update HG database
Editor.HG = HG;

% Set X/Y coordinates of poles/zeros of compensator/system on the Nichols plot.
plotcomp(Editor)
Editor.interpxy(MagData, PhaseData);

% Stability margins
showmargin(Editor)

% Update axis limits
% RE: Includes line handle restacking for proper layering, margin display,...
updateview(Editor)


% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalShowData
% Show system data
% ----------------------------------------------------------------------------%
function LocalShowData(hSrc, event, Editor)
if ~strcmp(Editor.EditMode,'idle')
   % Redirect to editor axes
   Editor.mouseevent('bd',get(hSrc,'parent'));
elseif strcmp(get(gcbf, 'SelectionType'), 'open')
   % Notify parent of open request
   Editor.root.send('ShowData');
end


% ----------------------------------------------------------------------------%
% Function: LocalMoveGain
% Callback for button down on closed-loop poles
% ----------------------------------------------------------------------------%
function LocalMoveGain(hSrc, event, Editor, action)
% REVISIT: merge with trackgain when directed callback are available
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
      WBMU = get(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'});
      set(SISOfig,'WindowButtonMotionFcn',{@LocalMoveGain Editor 'acquire'}, ...
         'WindowButtonUpFcn', {@LocalMoveGain Editor 'finish'});
      
      % Initialize tracking algorithm and notify peers
      Editor.trackgain('init');
   end
   
case 'acquire'
   % Track mouse location (move)
   Editor.trackgain('acquire');
   
case 'finish'
   % Restore initial conditions
   set(SISOfig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn'}, WBMU, ...
      'Pointer', 'arrow')
   % Clean up and update
   Editor.trackgain('finish');
end
