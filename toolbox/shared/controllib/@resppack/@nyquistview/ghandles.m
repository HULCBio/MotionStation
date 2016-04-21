function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a nyquistview object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:55 $
h = cat(3,this.PosCurves,this.NegCurves,this.PosArrows,this.NegArrows);