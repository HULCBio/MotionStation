function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a FreqPeakRespView object.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:24 $

GridSize = this.AxesGrid.Size;
RespSize = size(this.Points);
% REVISIT: pad = handles([GridSize(1:2) prod(GridSize(3:end))-1]);
pad = zeros([RespSize(1:2) prod(GridSize(3:end))-1]);
pad(:) = NaN;
pad = handle(pad);

VLines = cat(3,this.VLines,pad);
HLines = cat(3,this.HLines,pad);
Points = cat(3,this.Points,pad);
h = cat(length(GridSize)+1, VLines, HLines, Points);