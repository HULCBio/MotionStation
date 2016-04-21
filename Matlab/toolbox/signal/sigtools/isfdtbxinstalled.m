function b = isfdtbxinstalled
%ISFDTBXINSTALLED   Returns true if filter design toolbox is installed.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:30:56 $

b = license('test', 'Filter_Design_Toolbox') && ~isempty(ver('filterdesign'));

% [EOF]
