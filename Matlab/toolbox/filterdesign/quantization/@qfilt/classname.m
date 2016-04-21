function fstruct = classname(h)
%CLASSNAME Returns the classname of the object
%   CLASSNAME(H) Returns the class name of the object (the abbreviated 
%   filter structure)

% Author(s): J. Schickler
% Copyright 1999-2002 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2002/04/14 15:32:17 $

fstruct = get(h, 'FilterStructure');

% [EOF]
