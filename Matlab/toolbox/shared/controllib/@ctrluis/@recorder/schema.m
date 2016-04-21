function schema
% Defines properties for @recorder class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:32 $

pk = findpackage('ctrluis');

% Register class 
c = schema.class(pk,'recorder');

% Editor data
schema.prop(c, 'History', 'MATLAB array');   % Event history (text)
schema.prop(c, 'Redo', 'handle vector');     % Redo stack
schema.prop(c, 'Undo', 'handle vector');     % Undo stack

