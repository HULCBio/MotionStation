function aObj = editsize(aObj, varargin)
%AXISTEXT/EDITSIZE Edit font size for axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:11:58 $

t = aObj;
try
   size = str2double(varargin{1});
   aObj = set(aObj,'FontSize',size);
catch
   error('Unable to set font size');
end

