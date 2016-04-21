function cleargrid(h,varargin)
%CLEARGRID  Clears grid lines.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:05 $

% Save current zoom mode
zoommode = zoom(double(h.Parent),'getmode');

delete(h.GridLines(ishandle(h.GridLines)))
h.GridLines = [];

% Restore zoommode if necessary
if strcmpi('in',zoommode),
    zoom(double(h.Parent),'on');
elseif strcmpi('out',zoommode),
    zoom(double(h.Parent),'outmode');
end