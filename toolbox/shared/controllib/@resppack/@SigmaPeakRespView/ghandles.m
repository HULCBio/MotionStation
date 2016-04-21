function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a SigmaPeakRespView object.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:29 $

GridSize = this.AxesGrid.Size;

VLines = cat(3,this.VLines);
HLines = cat(3,this.HLines);
Points = cat(3,this.Points);
h = cat(length(GridSize), VLines, HLines, Points);