function showmargin(Editor, Margins)
%SHOWMARGIN    Updates stability margins display in Nichols Editor.

%  Author(s): P. Gahinet, Bora Eryilmaz
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.33.4.2 $ $Date: 2004/04/10 23:14:12 $

% Return if Editor is inactive 
if strcmp(Editor.EditMode, 'off') | ...
      strcmp(Editor.Visible,'off') | strcmp(Editor.MarginVisible,'off')
   return
end   
PlotAxes = getaxes(Editor.Axes);

% Create HG objects for margin rendering if they don't already exist 
% or have been deleted
HG = Editor.HG;
if isempty(HG.Margins) | ~ishandle(HG.Margins.MagDot)
   LocalCreateObjects(Editor, 'Margins', PlotAxes);
   % Listener to change in axes limits
   L = [handle.listener(Editor.Axes,'PostLimitChanged',@LocalAdjustDisplay);...
         handle.listener(Editor, Editor.findprop('FrequencyUnits'),...
         'PropertyPostSet',@showmargin)];
   set(L,'CallbackTarget',Editor)
   set(Editor.HG.Margins.MagDot,'UserData',L);
end

% Get margins from model database in normal mode
% RE: Interpolated margins are passed to SHOWMARGIN in drag mode
if strcmp(Editor.RefreshMode,'normal')
   Margins = Editor.LoopData.getmargins;
end

% Render gain and phase margins
LocalUpdateMargins(Editor, Margins.Gm, Margins.Pm, ...
   Margins.Wcg, Margins.Wcp, Margins.Stable);


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Update gain and phase margin objects
% ----------------------------------------------------------------------------%
function LocalUpdateMargins(Editor, Gm, Pm, Wcg, Wcp, isStable)
% Get handle
HG = Editor.HG;
Handles = HG.Margins;
FreqUnits  = Editor.FrequencyUnits;
MagUnits   = 'dB';
PhaseUnits = Editor.Axes.XUnits;
Phase      = get(HG.NicholsPlot, 'Xdata');
Frequency  = unitconv(Editor.Frequency, 'rad/sec', FreqUnits);

% Gain and Phase Margins (convert to current units)
Gm  = unitconv(Gm,  'abs', MagUnits);
Pm  = unitconv(Pm,  'deg', PhaseUnits);
Wcg = unitconv(Wcg, 'rad/sec', FreqUnits);
Wcp = unitconv(Wcp, 'rad/sec', FreqUnits);

% 180 degrees in current units;
PhaseConvert = unitconv(1, 'deg', PhaseUnits);
u180 = 180 * PhaseConvert;

% Unit dependent entities
Yo = unitconv(1, 'abs', MagUnits);
if strcmpi(MagUnits, 'abs')
   MagUnitStr = '(abs)';
   Ydot = 1/Gm;
else
   MagUnitStr = 'dB';
   Ydot = -Gm;
end

% Determine the gain line associated with the gain margin
if isfinite(Gm) && isfinite(Wcg)
   Xg = u180 * round(interp1(Frequency(:), Phase(:), Wcg) / u180);
   % Gain margin data text
   Display = sprintf('G.M.: %0.3g %s @ %0.3g %s', ...
      Gm, MagUnitStr, Wcg, FreqUnits);
else
   Xg = NaN; % trick to make it invisible
   Display = sprintf('G.M.: Inf @ %0.3g', Wcg);
end

% Determine the phase line associated with the phase margin (-180 modulo 360)
if isfinite(Pm)
   Xp = u180 * round((interp1(Frequency(:), Phase(:), Wcp) - Pm) / u180);
   % Phase margin data text
   Display = sprintf('%s\nP.M.: %0.3g %s @ %0.3g %s', Display, ...
      Pm, PhaseUnits, Wcp, FreqUnits);
else
   Xp = NaN; % trick to make it invisible
   Display = sprintf('%s\nP.M.: Inf @ %0.3g', Display, Wcp);
end

if ~isnan(isStable)
   if isStable
      Display = sprintf('%s\n%s', Display, 'Stable loop');
   else
      Display = sprintf('%s\n%s', Display, 'Unstable loop');
   end
end

% Set margin-related attributes
Px = [Xp+Pm Xp];  Gy = [Ydot Yo];
set(Handles.MagDot,  'Xdata',  Xg,      'Ydata',  Gy(1))   % mag dot marker
set(Handles.MagLine, 'Xdata', [Xg Xg],  'Ydata',  Gy)      % vertical line
set(Handles.PhaDot,  'Xdata',  Px(1),   'Ydata',  Yo)      % pha dot marker
set(Handles.PhaLine, 'Xdata',  Px,      'Ydata', [Yo Yo])  % horizontal line
set(Handles.Text,    'String', Display)                    % text


% ----------------------------------------------------------------------------%
% LocalAdjustDisplay: Adjusts margin text  when axis limits change 
%                     (in normal mode only)
% ----------------------------------------------------------------------------%
function LocalAdjustDisplay(Editor,event)
% Quick exit
if strcmp(Editor.EditMode,'off') | strcmp(Editor.MarginVisible,'off') | ...
      strcmp(Editor.RefreshMode,'quick')
   return
end
Axes = getaxes(Editor.Axes);
MarginObjects = Editor.HG.Margins;
Plot = Editor.HG.NicholsPlot;

% Get axis limits 
Xlims  = get(Axes, 'Xlim');
Ylims  = get(Axes, 'Ylim');
Scales = get(Axes, {'Xscale', 'Yscale'});

% Position text (based on Y coordinate of left-most visible point)
Xdata = get(Plot, 'Xdata');
Ydata = get(Plot, 'Ydata');
idx   = find(Xdata >= Xlims(1) & Xdata <= Xlims(2) & ...
   Ydata >= Ylims(1) & Ydata <= Ylims(2));
if ~isempty(idx) % protect against error when zooming in an empty area
   [miny,minI] = min(Ydata(idx));
   minI = minI + idx(1) - 1;  % index of minumum visible Ydata point
end
Zlevel = get(MarginObjects.Text, 'Position');
Zlevel = Zlevel(3);
if isempty(idx) | Xdata(minI)<(Xlims(1)+Xlims(2))/2
   % Place it at the bottom right corner
   set(MarginObjects.Text, 'Position', [0.98 0.02 Zlevel], ...
      'VerticalAlignment', 'bottom', ...
      'HorizontalAlignment', 'right');
else
   % Place it at the bottom left corner
   set(MarginObjects.Text, 'Position', [0.02 0.02 Zlevel], ...
      'VerticalAlignment', 'bottom', ...
      'HorizontalAlignment', 'left');
end


% ----------------------------------------------------------------------------%
% LocalCreateObjects
% ----------------------------------------------------------------------------%
function LocalCreateObjects(Editor, MarginType, Axes)
% Preferences
Style = Editor.LineStyle;
MarginColor = Style.Color.Margin;  
Visible = get(Axes, 'Visible');

% Create objects
MarginObjects = struct('PhaDot',  [], ...
   'MagDot',  [], ...
   'PhaLine', [], ...
   'MagLine', [], ...
   'Text',    []);

% Graphics
Zlevel = Editor.zlevel('margin');
MarginObjects.MagDot = line(0, 1, Zlevel, ...
   'Parent',  Axes, ...
   'XLimInclude','off',...
   'YLimInclude','off',......
   'HitTest', 'off', ...
   'MarkerEdgeColor', MarginColor , ...
   'MarkerFaceColor', MarginColor , ...
   'Marker',       'o', ...
   'MarkerSize',   6, ...
   'HelpTopicKey', 'nicholsgainphasestems');

MarginObjects.PhaDot = line(1, 0, Zlevel, ...
   'Parent',  Axes, ...
   'XLimInclude','off',...
   'YLimInclude','off',......
   'HitTest', 'off', ...
   'MarkerEdgeColor', MarginColor , ...
   'MarkerFaceColor', MarginColor , ...
   'Marker',       'o', ...
   'MarkerSize',   6, ...
   'HelpTopicKey', 'nicholsgainphasestems');

MarginObjects.MagLine = line([1 1], [NaN NaN], Zlevel(:,[1 1]), ...
   'Parent',  Axes, ...
   'XLimInclude','off',...
   'YLimInclude','off',......
   'HitTest', 'off', ...
   'Color', MarginColor, ...
   'LineStyle', '-');

% Horizontal line visible to X limit picker to always show 
% what 180 crossing the P.M. is relative to
MarginObjects.PhaLine = line([NaN NaN], [1 1], Zlevel(:,[1 1]), ...
   'Parent',  Axes, ...
   'YLimInclude','off',......
   'HitTest', 'off', ...
   'Color', MarginColor, ...
   'LineStyle', '-');

AxesColor = get(Axes, 'Color');
if strcmp(AxesColor, 'none'),
   AxesColor = get(get(Axes, 'Parent'), 'Color');
end

% Text
Zlevel = Editor.zlevel('margintext');
MarginObjects.Text = text(0, 0, Zlevel, '', ...
   'Parent',  Axes, ...
   'HitTest', 'off', ...
   'XLimInclude','off',...
   'YLimInclude','off',......
   'Interpreter', 'none', ...
   'Units',   'normalized', ...
   'Color',   (AxesColor == 0), ...
   'EdgeColor', AxesColor, ...
   'BackGroundColor', AxesColor, ...
   'HelpTopicKey', 'nicholsgainphasetext');
TempHG = Editor.HG;
TempHG.(MarginType) = MarginObjects;
Editor.HG = TempHG;
