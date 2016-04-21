function resetaxes(hAx)
% Delete all the children of the axes and reset the axes.
%
%   Inputs:
%   hAx -   Handle to the axes

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:46:22 $

delete(allchild(hAx));
reset(hAx);

% [EOF]
