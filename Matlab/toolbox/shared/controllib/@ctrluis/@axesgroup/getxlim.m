function Xlims = getxlim(h,col_index)
%GETXLIM  Gets X limits of axes group.
%
%   XLIMS = GETXLIM(AXGROUP) returns the limits of all axes
%   in the axes group AXGROUP.  XLIMS is 
%     * a vector if XlimSharing = 'all'
%     * a Nc-by-1 cell array if XlimSharing = 'column' (Nc=#columns)
%     * a Np-by-1 cell array if XlimSharing = 'peer' (Np=#columns in subgrid)
%     * a Nr-by-Nc cell array if XlimSharing = 'none'
%
%   XLIMS = GETXLIM(AXGROUP,J) returns the limits of the axes in column J
%   (vector except for XlimSharing = 'none').
%
%   XLIMS = GETXLIM(AXGROUP,[J1 J2]) returns the limits of the axes in the 
%   column specified by the integers J1 and J2, where J1 is relative to the  
%   major grid (size=AXGROUP.Size(1:2)), and J2 is relative to the minor grid 
%   (size=AXGROUP.Size(3:4)).

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:12 $

PlotAxes = h.Axes2d;

if nargin==1
   switch h.XlimSharing
   case 'all'
      Xlims = get(PlotAxes(1),'Xlim');
   case 'column'
      Xlims = get(PlotAxes(1,:),{'Xlim'});
   case 'peer'
      Xlims = get(PlotAxes(1,1:h.Size(4)),{'Xlim'});
   case 'none'
      Xlims = get(PlotAxes(:),{'Xlim'});
      Xlims = reshape(Xlims,size(PlotAxes));
   end
else
   % Limits for given column
   % Convert 2x1 index into absolute index
   if length(col_index)==2
      col_index = (col_index(1)-1) * h.Size(4) + col_index(2);
   end
   if strcmp(h.XlimSharing,'none')
      Xlims = get(PlotAxes(:,col_index),{'Xlim'});
   else
      Xlims = get(PlotAxes(1,col_index),'Xlim');
   end
end
