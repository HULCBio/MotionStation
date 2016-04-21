function position = getpixelposition(h)
% GETPIXELPOSITION Get position HG object in pixels.

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:33:40 $

old_u = get(h,'Units');
set(h,'Units','pixels');
wasError = false;
try
    position = get(h,'Position');
catch
    wasError = true;
end
set(h,'Units',old_u);
if wasError
    rethrow(lasterror);
end

end
