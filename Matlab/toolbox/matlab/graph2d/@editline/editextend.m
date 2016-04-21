function aObj = editextend(aObj, varargin)
%EDITLINE/EDITEXTEND End edit for editline object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:12:17 $

t = aObj;
tH = get(aObj,'MyHandle');
initVal = get(tH,'LineWidth');
virtualslider('init', tH, .5, initVal, 30, .5, 'set', 'LineWidth');
