function UnitBox = editUnits(this,BoxLabel,BoxPool,Data)
%EDITUNITS  Builds group box for Units

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:54 $

% Build standard Unit box
UnitBox = this.AxesGrid.editUnits(BoxLabel,BoxPool,'simUnits',[]);
UnitBox.Tag = 'simUnits';
