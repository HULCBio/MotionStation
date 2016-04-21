function updatelims(this)
%  UPDATELIMS  Custom limit picker.
%
%  UPDATELIMS(H) implements a custom limit picker for Singular Value plots. 
%  This limit picker
%     1) Computes an adequate X range from the data or source
%     2) Computes common Y limits across rows for axes in auto mode.

%  Author(s): K. Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:22 $

AxesGrid = this.AxesGrid;

% Update X range by merging time Focus of all visible data objects.
ax = getaxes(AxesGrid);
if strcmp(AxesGrid.XLimMode, 'auto')
   XRange = getfocus(this);
   % RE: Do not use SETXLIM in order to preserve XlimMode='auto'
   set(ax, 'Xlim', XRange);
end

% Update Y limits
AxesGrid.updatelims('manual', [])
