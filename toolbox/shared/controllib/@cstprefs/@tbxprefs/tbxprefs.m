function h_out = tbxprefs
%TBXPREFS  Toolbox preferences object contructor

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:55 $

mlock

persistent h; 
           
if isempty(h)
    %---Create class instance (w/default values)
    h = cstprefs.tbxprefs;
    h.reset;  %---This may not be neccessary as of beta5
	      %---Load default user preference file (if it exists)
    h.load;
end

h_out = h;

