function schema
%
% $Revision: 1.3.2.1 $
% Copyright 1999-2004 The MathWorks, Inc.

pk = findpackage('cftool');

% Create a new class

%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:38:53 $
c = schema.class(pk, 'outlierdb');

schema.prop(c, 'current', 'string');
p=schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
