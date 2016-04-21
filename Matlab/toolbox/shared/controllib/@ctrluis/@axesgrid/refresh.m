function refresh(h,varargin)
%REFRESH  Adjusts visibility of HG axes in axes grid.
%
%   Invoked when modifying properties controlling axes visibility,
%   REFRESH updates the visibility of HG axes as well as the  
%   position and visibility of tick and text labels.  
%
%   This method interfaces with the @plotarray class by first updating
%   the visibility properties of the @plotarray objects, and then 
%   invoking @plotarray/refresh.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:50 $

SubGridSize = prod(h.Size([3 4]));

% Row visibility
RowVis = reshape(strcmp(h.RowVisible,'on'),h.Size([3 1]));
if any(strcmp(h.AxesGrouping,{'row','all'}))
   h.Axes.RowVisible = [any(RowVis(:)) ; logical(zeros(h.Size(1)-1,1))];
   if SubGridSize>1
      set(h.Axes.Axes(1,:),'RowVisible',any(RowVis,2))
   end
else
   h.Axes.RowVisible = any(RowVis,1)';
   if SubGridSize>1
      for ct=1:h.Size(1)
         set(h.Axes.Axes(ct,:),'RowVisible',RowVis(:,ct))
      end
   end
end

% Column visibility
ColVis = reshape(strcmp(h.ColumnVisible,'on'),h.Size([4 2]));
if any(strcmp(h.AxesGrouping,{'column','all'}))
   h.Axes.ColumnVisible = [any(ColVis(:)) ; logical(zeros(h.Size(2)-1,1))];
   if SubGridSize>1
      set(h.Axes.Axes(:,1),'ColumnVisible',any(ColVis,2))
   end
else
   h.Axes.ColumnVisible = any(ColVis,1)';
   if SubGridSize>1
      for ct=1:h.Size(2)
         set(h.Axes.Axes(:,ct),'ColumnVisible',ColVis(:,ct))
      end
   end
end

% Global visibility
h.Axes.Visible = strcmp(h.Visible,'on');

% Update visibility of low-level HG axes
refresh(h.Axes);

% Set label and tick visibility
setlabels(h)