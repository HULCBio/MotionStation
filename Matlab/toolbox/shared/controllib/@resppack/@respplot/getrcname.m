function [RowNames,ColNames] = getrcname(this)
%GETRCNAME  Provides input and output names for display.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:35 $

% Default: read corresponding InputName/OutputName properties
RowNames = this.OutputName;
ColNames = this.InputName;
