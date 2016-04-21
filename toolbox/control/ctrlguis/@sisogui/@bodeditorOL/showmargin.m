function showmargin(Editor,Margins)
%SHOWMARGIN  Updates stability margins display in Bode Editor.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.42 $  $Date: 2002/04/10 05:03:30 $

% RE: Interpolated margins are passed to SHOWMARGIN in drag mode
if strcmp(Editor.EditMode, 'off') | ...
      strcmp(Editor.Visible,'off') | strcmp(Editor.MarginVisible,'off')
   return
end   
PlotAxes = getaxes(Editor.Axes);

% Create HG objects for margin rendering if they don't already exist 
% or have been deleted
if isempty(Editor.HG.GainMargin) | ~ishandle(Editor.HG.GainMargin.Dot)
    LocalCreateObjects(Editor,'GainMargin',PlotAxes(1));
    LocalCreateObjects(Editor,'PhaseMargin',PlotAxes(2));
    % Listener to change in axes limits
    L = handle.listener(Editor.Axes,'PostLimitChanged',@LocalAdjustDisplay);
    L.CallbackTarget = Editor;
    set(Editor.HG.GainMargin.Dot,'UserData',L);
end

% Get margins from model database in normal mode
if strcmp(Editor.RefreshMode,'normal')
    Margins = getmargins(Editor.LoopData);
end

% Render gain and phase margins
LocalUpdateGainMargin(Editor,Margins.Gm,Margins.Wcg,Margins.Stable);
LocalUpdatePhaseMargin(Editor,Margins.Pm,Margins.Wcp);


%----------------- Local functions ---------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateGainMargin %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateGainMargin(Editor,Gm,Wcg,isStable)

HG = Editor.HG;
Handles = HG.GainMargin;
Frequency = get(HG.BodePlot(1),'Xdata');   % in current units
FreqUnits = Editor.Axes.XUnits;
MagUnits = Editor.Axes.YUnits{1};

% Unit conversions
Wcg = unitconv(Wcg,'rad/sec',FreqUnits);

% Margin data text
if isfinite(Gm),
   % Finite value
   MagUnitStr = MagUnits;
   if strcmpi(MagUnits,'abs')
      MagUnitStr = sprintf('(%s)',MagUnits);
   end  
   Display = sprintf('G.M.: %0.3g %s\nFreq: %0.3g %s',...
      unitconv(Gm,'abs',MagUnits),MagUnitStr,Wcg,FreqUnits);
else
   Display = sprintf('G.M.: Inf\nFreq: %0.3g',Wcg);
end
if ~isnan(isStable)
   if isStable,
      Display = sprintf('%s\n%s',Display,'Stable loop');
   else
      Display = sprintf('%s\n%s',Display,'Unstable loop');
   end
end

% Horizontal 0dB gain line 
if isfinite(Gm) & (Wcg>=Frequency(1) & Wcg<=Frequency(end))
   Yg = unitconv(1,'abs',MagUnits);
   Ydot = unitconv(1/Gm,'abs',MagUnits);
else
   Wcg = NaN;  % Wcg=0 gets mapped to -Inf in log scale
   Yg = NaN;   % trick to make it invisible
   Ydot = NaN;
end

% Set margin-related attributes
set(Handles.Dot,'Xdata',Wcg,'Ydata',Ydot)               % dot marker
set(Handles.vLine,'Xdata',[Wcg Wcg],'Ydata',[Ydot Yg])  % vertical line
set(Handles.hLine,'Ydata',[Yg Yg])                      % horizontal line
set(Handles.Text,'String',Display)                      % text


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePhaseMargin %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePhaseMargin(Editor,Pm,Wcp)

HG = Editor.HG;
Handles = HG.PhaseMargin;
Frequency = get(HG.BodePlot(2),'Xdata');
FreqUnits = Editor.Axes.XUnits;
PhaseUnits = Editor.Axes.YUnits{2};

% Unit conversions
Wcp = unitconv(Wcp,'rad/sec',FreqUnits);
PhaseConvert = unitconv(1,'deg',PhaseUnits);
Pm = Pm * PhaseConvert;

% Margin data text
if isfinite(Pm),
   % Finite value
   Display = sprintf('P.M.: %0.3g %s\nFreq: %0.3g %s',...
       Pm,PhaseUnits,Wcp,FreqUnits);
else
   Display = sprintf('P.M.: Inf\nFreq: %0.3g',Wcp);
end

% Determine the phase line associated with the phase margin (-180 modulo 360)
if isfinite(Pm) & (Wcp>=Frequency(1) & Wcp<=Frequency(end))
   Phase = get(HG.BodePlot(2),'Ydata');
   u180 = 180 * PhaseConvert;
   Yp = u180 * round((interp1(Frequency(:),Phase(:),Wcp)-Pm)/u180);
else
   Wcp = NaN;  % Wcp=0 gets mapped to -Inf in log scale
   Yp = NaN;
end
   
% Set margin-related attributes
set(Handles.Dot,'Xdata',Wcp,'Ydata',Yp+Pm)                % dot marker
set(Handles.vLine,'Xdata',[Wcp Wcp],'Ydata',[Yp Yp+Pm])   % vertical line
set(Handles.hLine,'Ydata',[Yp Yp])                        % horizontal line
set(Handles.Text,'String',Display)

% Limit tweaking
if isfinite(Wcp) & (Wcp>Editor.FreqFocus(1)/10 & Wcp<10*Editor.FreqFocus(2))
   % Make vertical phase line visible to limit picker
   set(Handles.vLine,'XLimInclude','on','YLimInclude','on')
else
   set(Handles.vLine,'XLimInclude','off','YLimInclude','off')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAdjustDisplay %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAdjustDisplay(Editor,event)
% Adjusts margin display when axis limits change
if strcmp(Editor.EditMode,'off') | strcmp(Editor.MarginVisible,'off')
   return
end
% Adjust visibility and extents (in normal mode only)
HG = Editor.HG;
PlotAxes = getaxes(Editor.Axes);
NormalRefresh = strcmp(Editor.RefreshMode,'normal');
if strcmp(Editor.MagVisible,'on')
   LocalRefresh(HG.GainMargin,PlotAxes(1),HG.BodePlot(1),NormalRefresh)
end
if strcmp(Editor.PhaseVisible,'on')
   LocalRefresh(HG.PhaseMargin,PlotAxes(2),HG.BodePlot(2),NormalRefresh)
end


%%%%%%%%%%%%%%%%%%%%
%%% LocalRefresh %%%
%%%%%%%%%%%%%%%%%%%%
function LocalRefresh(MarginObjects,BodeAxes,BodeCurve,NormalRefresh)
% Adjust position and visibility of margin objects when axis limits change
% BODEAXES: mag or phase axes
% BODECURVE: mag or phase curve

% Get axis limits 
Xlims = get(BodeAxes,'Xlim');
Ylims = get(BodeAxes,'Ylim');

% Visibility of horizontal line
set(MarginObjects.hLine,'Xdata',Xlims)
Wc = get(MarginObjects.Dot,'Xdata');
if ~isfinite(Wc) | Wc<Xlims(1) | Wc>Xlims(2)
   set(MarginObjects.hLine,'YData',[NaN NaN])  % hide horizontal line
end

% Position text (based on Y coordinate of left-most visible point)
if NormalRefresh
   Zlevel = get(MarginObjects.Text, 'Position');
   Zlevel = Zlevel(3);
   Xdata = get(BodeCurve,'Xdata');
   Ydata = get(BodeCurve,'Ydata');
   isLinearY = strcmp(get(BodeAxes,'YScale'),'linear');
   idx = find(Xdata >= Xlims(1));
   if ~isempty(idx) % protect against error when zooming in an empty area
      if ((isLinearY & Ydata(idx(1)) >= (Ylims(1)+Ylims(2))/2) | ...
            (~isLinearY & Ydata(idx(1)) >= sqrt(Ylims(1)*Ylims(2))))
         % Place it at the bottom left corner
         set(MarginObjects.Text,'Position',[.02 .04 Zlevel], ...
            'VerticalAlignment','bottom')
      else
         set(MarginObjects.Text,'Position',[.02 .97 Zlevel], ...
            'VerticalAlignment','top')
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateObjects %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateObjects(Editor,MarginType,Axes)

% Prefs
Style = Editor.LineStyle;
MarginColor = Style.Color.Margin;  

% Create objects
MarginObjects = ...
   struct('Dot',[],'hLine',[],'vLine',[],'Text',[]);

% Graphics
Zlevel = Editor.zlevel('margin');
MarginObjects.Dot = line(1,1,Zlevel,'Parent',Axes,...
   'XLimInclude','off',...
   'YLimInclude','off',......
   'HitTest','off',...
   'MarkerEdgeColor',MarginColor ,...
   'MarkerFaceColor',MarginColor , ...
   'Marker','o','MarkerSize',6,...
   'HelpTopicKey','gainphasemargin');

MarginObjects.hLine = line([.1 10],[NaN NaN],Zlevel(:,[1 1]),...
   'Parent',Axes,'HitTest','off','XLimInclude','off','YLimInclude','off',...
   'Color',MarginColor,'LineStyle','-.');

MarginObjects.vLine = line([1 1],[NaN NaN],Zlevel(:,[1 1]),'parent',Axes, ...
   'HitTest','off','Color',MarginColor,'LineStyle','-');

AxesColor = get(Axes,'Color');
if strcmp(AxesColor,'none'),
   AxesColor = get(get(Axes,'Parent'),'Color');
end

% Text
Zlevel = Editor.zlevel('margintext');
MarginObjects.Text = text(1,0,Zlevel,'','parent',Axes, ...
   'HitTest','off',...
   'XLimInclude','off',...
   'YLimInclude','off',......
   'Interpreter','none',...
   'Units','normalized',...
   'Color',(AxesColor==0),...
   'EdgeColor', AxesColor, ...
   'BackGroundColor', AxesColor, ...
   'HelpTopicKey','gainphasemargin');
TempHG = Editor.HG;
TempHG.(MarginType) = MarginObjects;
Editor.HG = TempHG;