function h = getfdasessionhandle(hFig)
%GETFDASESSIONHANDLE  Return the handle to an FDATool session.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 23:54:31 $ 

if isempty(hFig) | ~ishandle(hFig),
    h = [];
else
    h = siggetappdata(hFig, 'fdatool', 'handle');
end

% [EOF]
