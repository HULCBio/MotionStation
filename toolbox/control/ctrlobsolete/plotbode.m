function [MPaxes,SubAxes] = plotbode(mag,phase,w,p,m,PlotToSameAxes, ...
                             GainScale,FreqScale,FreqUnit,Gm,Pm,Wgm,Wpm)
%PLOTBODE Plots Bode responses given the plotting data.
%       [MPaxes,SubAxes] = PLOTBODE(MAG,PHASE,W,P,M,fig,Gm,Pm,Wgm,Wpm)
%       MPaxes  should be 2x1
%       SubAxes should be COLx2  where MAG and PHASE are NxCOL
%                                      w             is  Nx1
%                                      COL           is  P*M
%       Gm,Pm,Wgm,Wpm  should be vectors of length COL (or empty)
%       PlotToSameAxes is a boolean (1 or 0)

%       Author(s): A. Potvin, 11-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:32:47 $

ni = nargin;
error(nargchk(6,13,ni))

% Create/find MPaxes and SubAxes 
fig = get(0,'CurrentFigure');
DefAxesPos = get(fig,'DefaultAxesPosition');
MPaxes = subaxes(2,1,DefAxesPos+[0 0 0 .02],fig,.04);
delete(findobj(fig,'Type','axes','Position',DefAxesPos))

% Check for quick exit
if isempty(w),
   set(MPaxes(2),'XTickLabelMode','auto')
   xlabel('Frequency (rad/s)')
   ylabel('Phase (deg)')
   set(fig,'CurrentAxes',MPaxes(1))
   ylabel('Gain (dB)')
   SubAxes = MPaxes;
   return
end

if ni<13;
   Gm = [];
   Pm = [];
   Wgm = [];
   Wpm = [];
end

if ni<7,
   GainScale = 'dB';
end
if strcmp(GainScale,'dB'),
   mag = 20*log(mag)/log(10);
   Gm = 20*log(Gm)/log(10);
   UnitGain = 0;
   GainLabel = 'Gain (dB)';
   GainScale = 'linear';
elseif strcmp(GainScale,'log') | strcmp(GainScale,'linear'),
   UnitGain = 1;
   GainLabel = 'Gain';
else
   error(sprintf('Unknown GainScale: %s',GainScale));
end

if ni<8,
   FreqScale = 'log';
end
if ~strcmp(FreqScale,'log') & ~strcmp(FreqScale,'linear'),
   error('Unknown FreqScale.')
end

if ni<9,
   FreqUnit = 'rad/s';
end
if strcmp(FreqUnit,'Hz'),
   % Convert from rad/s to Hz
   CF = 1/(2*pi);
   w = CF*w
   Wgm = CF*Wgm;
   Wpm = CF*Wpm;
elseif ~strcmp(FreqUnit,'rad/s'),
   error(sprintf('Unknown FreqUnit: %s',FreqUnit));
end

% Will later return MPaxes(1) --- the Gain axes --- as the CurrentAx
IsHoldOn = strcmp(get(fig,'NextPlot'),'add') & strcmp(get(MPaxes(1),'NextPlot'),'add');
if IsHoldOn,
   set(MPaxes,'NextPlot','add')
else
   set(MPaxes,'NextPlot','replace')
end

col = size(mag,2);
Color = get(fig,'DefaultAxesXColor');
wrange = [w(1); w(length(w))];

PlotToSameAxes = PlotToSameAxes | (p*m==1);
if PlotToSameAxes,
   % Plot gain in dB in MPaxes(1)
   set(fig,'CurrentAxes',MPaxes(1))
   plot(w,mag)
   % Also plot a dotted line at zero dB
   line(wrange,[UnitGain; UnitGain],'Color',Color,'LineStyle',':')
   % Plot phase in MPaxes(2)
   set(fig,'CurrentAxes',MPaxes(2))
   plot(w,phase)
   SubAxes = MPaxes(:,ones(col,1))';
else
   SubAxes = zeros(col,2);
   % Set fig's DefaultAxesPosition and use miniplot to plot mag and zero dB lines
   set(fig,'DefaultAxesPosition',get(MPaxes(1),'Position'))
   [h,SubAxes(:,1),mp1] = miniplot(p,m,w,mag,wrange,[UnitGain; UnitGain]);
   % Make the lines at zero dB dotted and the right color
   set(h(:,2),'LineStyle',':','Color',Color)

   % Set fig's DefaultAxesPosition and use miniplot to plot phase
   % Note: Must also set fig's NextPlot back to add since last miniplot made it replace
   set(fig,'DefaultAxesPosition',get(MPaxes(2),'Position'),'NextPlot','add')
   [h,SubAxes(:,2),mp2] = miniplot(p,m,w,phase);

   % Return fig's DefAxesPos
   set(fig,'DefaultAxesPosition',DefAxesPos)
end

% Set the Scale's
if strcmp(FreqScale,'log'),
   set([SubAxes(:); MPaxes(:)],'XScale','log')
end
if strcmp(GainScale,'log'),
   set(SubAxes(:,1),'YScale','log')
end

% Delete children of MPaxes if ~PlotToSameAxes
if ~PlotToSameAxes,
   delete(get(MPaxes(1),'Children'))
   delete(get(MPaxes(2),'Children'))
end

% Loop over I/O
for i=1:col,
   % Augment gain plot with margin data if supplied
   if ~isempty(Gm),
      Wgmi = Wgm(i);
      Wpmi = Wpm(i);
      % Make Gain axes current
      ax = SubAxes(i,1);
      set(fig,'CurrentAxes',ax)
      ylim  = get(ax, 'YLim');
      if (Wgmi~=0) & finite(Wgmi)
         % Plot gain margin lines
         line([Wgmi; Wgmi],[-Gm(i); UnitGain],'Color',Color,'LineStyle','-')
         line([Wgmi; Wgmi],ylim,'Color',Color,'LineStyle',':')
      end
      if finite(Wpmi),
         % Put phase margin on gain plot as a dotted line
         line([Wpmi; Wpmi],[UnitGain; ylim(1)],'Color',Color,'LineStyle',':')
      end
   end

   % Will be working on Phase axes
   ax = SubAxes(i,2);

   % Augment phase plot with margin data if supplied
   if ~isempty(Pm),
      % Make Phase axes current if going to plot
      set(fig,'CurrentAxes',ax)
      if finite(Wpmi)
         % Plot phase margins lines
         line([Wpmi; Wpmi],[Pm(i)-180; -180],'Color',Color,'LineStyle','-')
         line([Wpmi; Wpmi],[0 -360],'Color',Color,'LineStyle',':')
      end
      if (Wgmi~=0) & finite(Wgmi)
         % Put gain margin on gain plot as a dotted verical line from 0 to -180 degrees
         line([Wgmi; Wgmi],[0; -180],'Color',Color,'LineStyle',':')
      end
      % Always plot a line at 180 degrees
      line(wrange,[-180,-180],'Color',Color,'LineStyle',':')
   end

   % If PlotToSameAxes, only set ticks once ... the last time
   if (~PlotToSameAxes) | (i==col),
      % Set tick marks up to be in multiples of 30, 90, 180, 360 ... degrees.
      ytick = get(ax, 'ytick');
      ylim  = get(ax, 'ylim');
      yrange = ylim(2) - ylim(1);
      no_of_pts = log(yrange/(length(ytick)*90))/log(2);
      n = round(no_of_pts);
      if n >= -1,
         % 45, 90, 180, 360, ...  degree increments  
         ytick = [ylim(1):(90*2^n):-90*2^n, 0:(90*2^n):ylim(2)];
         ytick = ytick(find(ytick >= ylim(1) & ytick <= ylim(2))); 
      elseif n >= -2 
         % Special case for 30 degree increments rather than 22.5
         ytick = [ylim(1):30:-30, 0:30:ylim(2)];
         ytick = ytick(find(ytick >= ylim(1) & ytick <= ylim(2)));
      end
      set(ax,'YTick',ytick);
   end
end

% Make labels in MPaxes and leave with gain axes as CurrentAxes
set(SubAxes,'XTickLabels','','YTickLabels','')
if m<2,
   set(SubAxes(p:p:p*m,2),'XTickLabelMode','auto')
end
set(MPaxes(1),'XTickLabels','','YTickLabelMode','auto')
set(MPaxes(2),'XTickLabelMode','auto','YTickLabelMode','auto')
set(MPaxes,'Visible','off')
set(SubAxes,'Visible','on')
set(fig,'CurrentAxes',MPaxes(2))
xlabel(sprintf('Frequency %s',FreqUnit),'Visible','on')
ylabel('Phase (deg)','Visible','on')
set(fig,'CurrentAxes',MPaxes(1))
ylabel(GainLabel,'Visible','on')
if PlotToSameAxes,
   title('Bode response','Visible','on')
else
   title('Bode responses for outputs (rows) vs inputs (columns)','Visible','on')
end

if ~IsHoldOn,
   set(fig,'NextPlot','replace')
end

% end plotbode
