function setcharprefs(this,property,value)
% SETCHARPREFS is a method that updates the characteristics preferences of the plot. 

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:24:10 $

Preferences = this.Preferences;
if strcmpi('SettlingTimeThreshold',property)
    Preferences.SettlingTimeThreshold = value;
elseif strcmpi('RiseTimeLimits',property)
    Preferences.RiseTimeLimits = value;
end
this.Preferences = Preferences;    