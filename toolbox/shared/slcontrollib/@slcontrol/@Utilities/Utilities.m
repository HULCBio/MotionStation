function hout = Utilities
% UTILITIES Static class for control related utility methods.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:00 $

% Singleton object
persistent this

if isempty(this)
  % Create singleton class instance
  this = slcontrol.Utilities;
end

% Language workaround.
hout = this;
