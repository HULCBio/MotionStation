function Ylims = getylim(h,row_index)
%GETYLIM  Gets X limits of axes group.
%
%   YLIMS = GETYLIM(AXGROUP) returns the limits of all axes in the 
%   axes group AXGROUP.  YLIMS is 
%     * a vector if YlimSharing = 'all'
%     * a Nr-by-1 cell array if YlimSharing = 'column' (Nr=#rows)
%     * a Np-by-1 cell array if YlimSharing = 'peer' (Np=#rows in subgrid)
%     * a Nr-by-Nc cell array if YlimSharing = 'none'
%
%   YLIMS = GETYLIM(AXGROUP,I) returns the limits of the axes in row I
%   (vector except for YlimSharing = 'none').
%
%   YLIMS = GETYLIM(AXGROUP,[I1 I2]) returns the limits of the axes in the 
%   row specified by the integers I1 and I2, where I1 is relative to the  
%   major grid (size=AXGROUP.Size(1:2)), and I2 is relative to the minor grid 
%   (size=AXGROUP.Size(3:4)).

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:13 $

PlotAxes = h.Axes2d;

if nargin==1
   switch h.YlimSharing
   case 'all'
      Ylims = get(PlotAxes(1),'Ylim');
   case 'row'
      Ylims = get(PlotAxes(:,1),{'Ylim'});
   case 'peer'
      Ylims = get(PlotAxes(1:h.Size(3),1),{'Ylim'});
   case 'none'
      Ylims = get(PlotAxes(:),{'Ylim'});
      Ylims = reshape(Ylims,size(PlotAxes));
   end
else
   % Limits for given column
   % Convert 2x1 index into absolute index
   if length(row_index)==2
      row_index = (row_index(1)-1) * h.Size(3) + row_index(2);
   end
   if strcmp(h.YlimSharing,'none')
      Ylims = get(PlotAxes(row_index,:),{'Ylim'});
   else
      Ylims = get(PlotAxes(row_index,1),'Ylim');
   end
end
