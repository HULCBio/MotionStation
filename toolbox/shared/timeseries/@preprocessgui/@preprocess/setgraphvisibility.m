function setgraphvisibility(h,stat)
%SETGRAPHVISIBILITY
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:58 $

if ~isempty(h.Window) && ishandle(h.Window)
   set(h.Window,'Visible',stat);
end