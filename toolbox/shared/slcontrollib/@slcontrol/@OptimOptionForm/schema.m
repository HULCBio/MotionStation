function schema
% Literal specification of optimization options for SRO Project.

% Author(s): P. Gahinet, Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:07:00 $

% Construct class
c = schema.class(findpackage('slcontrol'), 'OptimOptionForm');

% Add new enumeration type
if isempty( findtype('slcontrol_Display') )
  schema.EnumType('slcontrol_Display', {'off','iter','notify','final'});
end
if isempty( findtype('slcontrol_Gradient') )
  schema.EnumType('slcontrol_Gradient', {'basic','refined'});
end
if isempty( findtype('slcontrol_Search') )
  schema.EnumType('slcontrol_Search', ...
                  {'None','Positive Basis Np1','Positive Basis 2N',...
                   'Genetic Algorithm','Latin Hypercube','Nelder-Mead'});
end

% Display
p = schema.prop(c, 'Display', 'slcontrol_Display');
p.FactoryValue = 'iter';

% Gradient algorithm
p = schema.prop(c, 'GradientType', 'slcontrol_Gradient');
p.FactoryValue = 'basic';

% Problem size
p = schema.prop(c, 'LargeScale', 'on/off');
p.FactoryValue = 'off';

% Max iterations
p = schema.prop(c, 'MaxIter', 'string');
p.FactoryValue = '100';

% Constraint tolerance
p = schema.prop(c, 'TolCon', 'string');
p.FactoryValue = '0.001';

% Objective tolerance
p = schema.prop(c, 'TolFun', 'string');
p.FactoryValue = '0.001';

% Tolerance on search direction magnitude
p = schema.prop(c, 'TolX', 'string');
p.FactoryValue = '0.001';

% Search method (GADS only)
p = schema.prop(c, 'SearchMethod', 'slcontrol_Search');
p.FactoryValue = 'Latin Hypercube';

% Search limit (GADS only)
p = schema.prop(c, 'SearchLimit', 'string');
p.FactoryValue = '3';

% Version
p = schema.prop(c, 'Version', 'double');
p.FactoryValue = 1.0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
