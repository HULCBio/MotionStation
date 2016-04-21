function aObj = editsize(aObj, varargin)
%EDITLINE/EDITSIZE Edit editline linewidth
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:12:20 $


t = aObj;
try
   size = str2double(varargin{1});
   aObj = set(aObj,'LineWidth',size);
catch
   error('Unable to set line size');
end
