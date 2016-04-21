function schema
%
% $Revision: 1.8.2.1 $
% Copyright 2001-2004 The MathWorks, Inc.


pk = findpackage('cftool');

% Create a new class

%   $Revision: 1.8.2.1 $  $Date: 2004/02/01 21:38:45 $
c = schema.class(pk, 'fitdb');

schema.prop(c, 'current', 'string');

p=schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

p=schema.prop(c, 'newOptions', 'handle');
p.AccessFlags.Serialize = 'off';

p=schema.prop(c, 'newModel', 'string');
p.AccessFlags.Serialize = 'off';

p=schema.prop(c, 'newCoeff', 'string vector');
p.AccessFlags.Serialize = 'off';

p=schema.prop(c, 'newProps', 'string vector');
p.AccessFlags.Serialize = 'off';
