function tf = browsefilter(this,var)
% BROWSEFILTER 
% Checks if given variable should be included in the import browser

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/02/06 00:37:12 $

if strcmp(var.class,'opcond.OperatingPoint');
    tf = true;
elseif strcmp(var.class,'double') && ...
            ((min(var.size) == 1) && (max(var.size) == this.NxDesired))
    tf = true;
elseif strcmp(var.class,'struct')
    tf = true;
else
    tf = false;
end
