function aObj = editextend(aObj, varargin)
%AXISTEXT/EDITEXTEND End text edit
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:11:55 $


t = aObj;
tH = get(aObj,'MyHandle');
initVal = get(t,'FontSize');
virtualslider('init', tH, 6, initVal, 48, .5, 'set', 'FontSize');


