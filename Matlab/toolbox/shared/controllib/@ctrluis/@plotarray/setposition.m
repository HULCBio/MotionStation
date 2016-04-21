function setposition(h,Position)
%SETPOSITION   Sets plot array position and refreshes plot.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:24 $

h.Position = Position;  % RE: no listener!
% Refresh plot
if h.Visible
   refresh(h)
end
