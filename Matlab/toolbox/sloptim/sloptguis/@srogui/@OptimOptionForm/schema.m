function schema
% Literal specification of optimization options for SRO Project.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:44:05 $

% Construct class
sp = findclass(findpackage('slcontrol'),'OptimOptionForm');
c = schema.class(findpackage('srogui'), 'OptimOptionForm', sp);

% Add new enumeration type
if isempty( findtype('sloptim_Algorithm') )
   schema.EnumType( 'sloptim_Algorithm', {'fmincon','patternsearch','fminsearch'});
end

% Properties
p = schema.prop(c,'Algorithm', 'sloptim_Algorithm');
p.FactoryValue = 'fmincon';

% Restarts
p = schema.prop(c,'Restarts', 'string');
p.FactoryValue = '0';
