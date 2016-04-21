function updatelims(this)
%UPDATELIMS  Custom limit picker.
%
%  UPDATELIMS(H) implements a custom limit picker for Nichols plots. 
%  This limit picker
%     1) Computes common X limits across columns for axes in auto mode.
%     2) Computes common Y limits across rows for axes in auto mode.
%     3) Adjusts the phase ticks (for phase in degrees)
%     4) Adjusts the limits to show full 180 protions of the Nichols grid

%  Author(s): P. Gahinet, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:27 $

AxGrid = this.AxesGrid;

% Let HG compute the limits
updatelims(AxGrid)

% Adjust limits to accomodate Nichols chart (SISO only)
NicChartOn = (prod(AxGrid.Size)==1 & strcmp(AxGrid.Grid,'on'));
if NicChartOn
   PlotAxes = getaxes(AxGrid);
   Xlim = get(PlotAxes,'Xlim');
   Ylim = get(PlotAxes,'Ylim');
   if strcmp(AxGrid.XlimMode,'auto')
      set(PlotAxes,'Xlim',niclims('phase', Xlim, AxGrid.XUnits))
   end
   if strcmp(AxGrid.YlimMode,'auto')
      set(PlotAxes,'Ylim',niclims('mag', Ylim, AxGrid.YUnits))
   end
end

% Adjust phase ticks
LocalAdjustPhaseTicks(this,NicChartOn)

% --------------------------------------------------------------------------- %
% Local Functions
% --------------------------------------------------------------------------- %
function LocalAdjustPhaseTicks(this,NicChartOn)
% Adjust phase tick labels for degrees (THIS = @respplot handle)
% Data visibility
AxGrid = this.AxesGrid;
DataVis = datavis(this);
if ~any(DataVis(:))
   return
end

% Phase axes and their Y limit mode
PlotAxes = getaxes(this);
XLimMode = AxGrid.XLimMode;
if ischar(XLimMode)
   AutoX = repmat(strcmp(XLimMode, 'auto'), [size(PlotAxes,2) 1]);
else
   AutoX = strcmp(XLimMode, 'auto');  % phase rows in auto mode
end

% Compute phase extent
Xextent = LocalGetPhaseExtent(this, DataVis);
if any(strcmp(this.IOGrouping, {'all', 'inputs'}))
   % Row grouping
   PlotAxes = PlotAxes(:,1);
   AutoX = any(AutoX);
   Xextent = cat(1,Xextent{:});
   Xextent = {[min(Xextent(:,1)) , max(Xextent(:,2))]};
end

% Adjust phase extent when Nichols chart is on
if NicChartOn & AutoX
   Xextent{1} = niclims('phase', Xextent{1}, AxGrid.XUnits);
end
   
% Bottom visible row
visrow = find(any(DataVis'));
visrow = visrow(end);  
set(PlotAxes(visrow,:), 'XtickMode', 'auto') % release x ticks 

% Adjust ticks
if all(strcmp(AxGrid.XUnits,'deg'))
   for ct = 1:size(PlotAxes,2)
      XlimP  = get(PlotAxes(visrow, ct), 'Xlim');
      Xticks = get(PlotAxes(visrow, ct), 'XTick');
      if isempty(Xextent{ct})
         % No data
         NewTicks = Xticks;
      elseif AutoX(ct)
         % Auto mode
         [NewTicks, XlimP] = phaseticks(Xticks,XlimP,Xextent{ct});
      else
         % Fixed limit mode
         NewTicks = phaseticks(Xticks, XlimP);
      end
      set(PlotAxes(:,ct), 'XTick', NewTicks)
      set(PlotAxes(:,ct), 'Xlim',  XlimP);
   end
end


% --------------------------------------------------------------------------- %
function Xextent = LocalGetPhaseExtent(this, DataVis)
% Computes spread of phase values
hx = zeros(0, size(DataVis,2));
for r = this.Responses(strcmp(get(this.Responses, 'Visible'), 'on'))'
   % For each visible response plots
   hx = cat(1, hx , r.xextent(DataVis));
end
Xextent = LocalGetExtent(hx(:,:,1));


% --------------------------------------------------------------------------- %
function Xextent = LocalGetExtent(Xhandles)
% Computes X extent spanned by handles XHANDLES for current X limits.
% REVISIT: This should be an HG primitive!!
nc = size(Xhandles,2);
Xextent = cell(1,nc);
for ctc = 1:nc
   Xh = Xhandles(:,ctc);
   Xh = Xh(ishandle(Xh));
   Xx = zeros(0,2);
   for ctr = 1:length(Xh)
      Xdata = get(Xh(ctr),'Xdata');
      Ydata = get(Xh(ctr),'Ydata');
      YRange = get(get(Xh(ctr),'Parent'), 'Ylim');
      Xdata = Xdata(Ydata>=YRange(1) & Ydata<=YRange(2));
      Xx = [Xx ; [min(Xdata) , max(Xdata)]];
      Xx = [min(Xx(:,1)) , max(Xx(:,2))];
   end
   Xextent{ctc} = Xx;
end
