function p = getPositionInPixels(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:54 $

oldUnits = this.Figure.Units;
this.Figure.Units = 'pixels';
p = this.Figure.Position;
this.Figure.Units = oldUnits;