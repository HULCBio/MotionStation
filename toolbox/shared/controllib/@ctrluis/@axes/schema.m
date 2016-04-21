function schema
% Defines properties for @axes class (single axes)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:33 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'axes',findclass(pk,'axesgroup'));

% Properties
p = schema.prop(c,'LimitStack','MATLAB array');    % Limit stack
p.FactoryValue = struct('Limits',zeros(0,4),'Index',0);