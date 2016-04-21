function layout(h,eventdata)
%LAYOUT   Positions axes in axis grid.

%   Author(s): Adam DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:20 $

% Get visible portion of the grid
ax = h.Axes(h.RowVisible,h.ColumnVisible);
[nr,nc] = size(ax);
if ~h.Visible | nr*nc==0
    return
end

scale = h.Geometry.PrintScale;

% Get requested position in pixels
[FigW,FigH] = figsize(h,'pixel');
LM = h.Geometry.LeftMargin * (scale/FigW);  % scaled + normalized
TM = h.Geometry.TopMargin * (scale/FigH);
HGap = h.Geometry.HorizontalGap * (scale/FigW);
VGap = h.Geometry.VerticalGap * (scale/FigH);
HRatio = h.Geometry.HeightRatio;

% Adjust position to account for row and column labels
Position = h.Position + [LM 0 -LM -TM];  % normalized units

% Width and height of individual sub-axes in grid (in normalized units)
W = max(2*scale/FigW,(Position(3)-(nc-1)*HGap)/nc);
H = zeros(nr,1);
if length(HRatio)==nr
   H = max(2*scale/FigH,((Position(4)-(nr-1)*VGap)/sum(HRatio)) * HRatio);
else   
   H(:) = max(2*scale/FigH,(Position(4)-(nr-1)*VGap)/nr);
end

% Position each sub-axes
x0 = Position(1);
NormUnits = reshape(strcmp(get(ax,'Units'),'normalized'),[nr nc]);
for jct=1:nc
   y0 = Position(2);
   for ict=nr:-1:1
      % Switch to normalized units
      % RE: LEGEND may change units to points and trigger LAYOUT through
      %     listener to figure position
      if ~NormUnits(ict,jct)
         Units = ax(ict,jct).Units;
         ax(ict,jct).Units = 'normalized';
      end
      ax(ict,jct).Position = [x0 y0 W H(ict)]; % no listener...
      if ~NormUnits(ict,jct)
         ax(ict,jct).Units = Units;
      end
      y0 = y0 + H(ict) + VGap;
   end
   x0 = x0 + W + HGap;
end
        
        