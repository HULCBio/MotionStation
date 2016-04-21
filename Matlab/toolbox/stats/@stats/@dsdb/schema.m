function schema
%
% $Revision: 1.1.6.2 $
% Copyright 2003-2004 The MathWorks, Inc.

pk = findpackage('stats');

% Create a new class
c = schema.class(pk, 'dsdb');
schema.prop(c, 'current', 'string');
p=schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
