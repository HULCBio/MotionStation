function [BigAx,Axes] = plotnyq(re,im,p,m,PlotToSameAxes)
%PLOTNYQ Plots Nyquist responses given the plotting data.
%       [BigAx,Axes] = PLOTNYQ(RE,IM,P,M,PlotToSameAxes)

%       Author(s): A. Potvin, 11-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:41 $

ni = nargin;
error(nargchk(5,5,ni))
% Check for quick exit
if isempty(re),
   return
end
fig = get(0,'CurrentFigure');
PlotToSameAxes = PlotToSameAxes | (p*m==1);

% Faster to do this inside loop, but more robust to do all setup in miniplot
% First plot the actual Nyquist curve
[lenW,PM] = size(re);
NaNmat = NaN;
NaNmat = NaNmat(ones(1,PM));
if PlotToSameAxes,
   h = plot([re; NaNmat; re],[im; NaNmat; -im]);
   Axes = get(h(1),'Parent');
   BigAx = Axes;
   Axes = Axes(ones(PM,1),1);
else
   [h,Axes,BigAx] = miniplot(p,m,[re; NaNmat; re],[im; NaNmat; -im]);
end

% Calculate arrow information
% Horizontal arrow indicies are ArrowInd
[yrange,ArrowInd] = max(abs(im));
yrange = 2*yrange;
xrange = max(re)-min(re);

% Loop over I/O
Color = get(fig,'DefaultAxesXColor');
for i=1:PM,
   ax = Axes(i);
   set(fig,'CurrentAxes',ax)

   % Make any arrows
   if lenW>1,
      % Horizontal arrows
      ind = ArrowInd(1,i);
      % Positive Dir means top arrow to right
      if ind==lenW,
         Dir = re(lenW-1,i) -re(lenW,i);
      else
         Dir = re(ind+1,i) -re(ind,i);
      end
      Dir = sign(Dir);
      if Dir~=0,
         yarrow = [yrange(i) 0 -yrange(i)]/48;
         xarrow = -[xrange(i) 0 xrange(i)]/36;
         Ar = re(ind,i);
         Ai = im(ind,i);
         arrow = line(Ar+[Dir*xarrow NaN -Dir*xarrow],[Ai+yarrow NaN -Ai+yarrow]);
         if PlotToSameAxes,
            % Make arrow color same as h(i) color
            set(arrow,'Color',get(h(i),'Color'))
         end
      end
   end

   % If PlotToSameAxes, only set limits, plot cross, and plot axis once ... the last time
   if (~PlotToSameAxes) | (i==PM),
      % Get the axes limits and fix them
      % Get the limits forst otherwise setting the LimMode gets the wrong ones
      xlim = get(ax,'XLim');
      ylim = get(ax,'YLim');
      set(ax,'XLimMode','manual','YLimMode','manual')
   
      % Make cross at s = -1 + j0, i.e the -1 point
      line(-1,0,'LineStyle','+','Color',Color,'MarkerSize',12)
   
      % Axis
      line([xlim; 0 0]',[0 0; ylim]','Color',Color,'LineStyle',':');
   end
end

% Make labels on BigAx and make as CurrentAxes
set(fig,'CurrentAx',BigAx)
if PlotToSameAxes,
   title('Nyquist plot','Visible','on')
else
   set(BigAx,'Box','on')
   title('Nyquist plots for outputs (rows) vs inputs (columns)','Visible','on')
end
xlabel('Real Axis','Visible','on')
ylabel('Imag Axis','Visible','on')

% end plotnyq
