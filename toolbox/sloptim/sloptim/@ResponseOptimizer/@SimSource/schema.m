function schema
% Simulink data source.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
pk = findpackage('ResponseOptimizer');
c = schema.class(pk,'SimSource',findclass(pk,'Source'));
c.Description = 'Simulink data source';

%%%%%%%%%%%%%%%%%%%%%%
%-- Public Properties
%%%%%%%%%%%%%%%%%%%%%%
% DataLoggingName for data logging port
p = schema.prop(c,'LogID','string'); 
p.Description = 'Data logging port name';
