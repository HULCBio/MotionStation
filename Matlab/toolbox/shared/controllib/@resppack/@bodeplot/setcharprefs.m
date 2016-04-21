function setcharprefs(this,property,value)
% SETCHARPREFS is a method that updates the characteristics preferences of the plot. 

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:26 $

Preferences = this.Preferences;
if strcmp(property,'UnwrapPhase')
   Preferences.UnwrapPhase = value;
end
this.Preferences = Preferences;
