function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a TimePeakRespView object.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:31 $

h = cat(3, this.VLines, this.HLines, this.Points);

% REVISIT: Include line tips when handle(NaN) workaround removed
