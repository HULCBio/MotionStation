function schema
%
% $Revision: 1.1.6.2 $ $Date: 2004/01/24 09:35:02 $

% Copyright 2003-2004 The MathWorks, Inc.

pk = findpackage('stats');

% Create a new class

c = schema.class(pk, 'outlierdb');

schema.prop(c, 'current', 'string');
p=schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
