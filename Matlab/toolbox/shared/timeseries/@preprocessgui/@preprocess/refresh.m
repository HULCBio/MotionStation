function refresh(h)
%REFRESH
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:53 $

% Apply exclusion vector to GUI
if h.Position>0 && h.Position<=length(h.Datasets)
    manexl = h.ManExcludedpts{h.Position};
    h.update(manexl(:),false);
end