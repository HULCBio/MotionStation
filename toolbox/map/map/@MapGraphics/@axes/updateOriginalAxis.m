function updateOriginalAxis(this)
%UPDATEORIGINALAXIS
%  changes the OrigPosition, OrigXLim and OrigYLim fields of the map axis.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:13:03 $

oldunits = this.Units;
this.Units = 'pixels';
this.OrigPosition = this.Position;
this.OrigXLim = this.XLim;
this.OrigYLim = this.YLim;

this.Units = oldunits;
