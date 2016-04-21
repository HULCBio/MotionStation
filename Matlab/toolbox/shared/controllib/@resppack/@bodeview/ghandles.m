function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a bodeview object.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:34 $
h = cat(4,...
   cat(3, this.MagCurves, this.PhaseCurves),...
   cat(3, this.MagNyquistLines, this.PhaseNyquistLines));