function b = isfixptinstalled
%ISFIXPTINSTALLED   Returns true if fixedpoint is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/06 21:53:50 $

b = license('test', 'Fixed_Point_Toolbox') && ~isempty(ver('fixedpoint'));

% [EOF]
