function schema
% Optimization options for SRO Project.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:25 $

% Construct class
c = schema.class(findpackage('ResponseOptimizer'), 'OptimOptions');

% Add new enumeration type
if (isempty(findtype('SRO_Algorithm')))
   schema.EnumType('SRO_Algorithm',{'fmincon','patternsearch','fminsearch'});
end
if (isempty(findtype('SRO_Display')))
   schema.EnumType('SRO_Display',{'off','iter','notify','final'});
end
if (isempty(findtype('SRO_Gradient')))
   schema.EnumType('SRO_Gradient',{'basic','refined'});
end

% Algorithm
p = schema.prop(c,'Algorithm', 'SRO_Algorithm');
p.FactoryValue = 'fmincon';

% Display
p = schema.prop(c, 'Display', 'SRO_Display');
p.FactoryValue = 'iter';

% Gradient algorithm
p = schema.prop(c, 'GradientType', 'SRO_Gradient');
p.FactoryValue = 'basic';

% Max iterations
p = schema.prop(c, 'MaxIter', 'double');
p.SetFunction = @localSetMaxIter;
p.FactoryValue = 100;

% Constraint tolerance
p = schema.prop(c, 'TolCon', 'double');
p.FactoryValue = 0.001;
p.SetFunction = @localSetTol;

% Objective tolerance
p = schema.prop(c, 'TolFun', 'double');
p.FactoryValue = 0.01;
p.SetFunction = @localSetTol;

% Optimal X tolerance
p = schema.prop(c, 'TolX', 'double');
p.FactoryValue = 0.01;
p.SetFunction = @localSetTol;

% Restarts
p = schema.prop(c,'Restarts', 'double');
p.FactoryValue = 0;
p.SetFunction = @localSetRestart;

% Search Method (GADS only)
p = schema.prop(c,'SearchMethod', 'MATLAB array');

% Version
p = schema.prop(c, 'Version', 'double');
p.FactoryValue = 1;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

%---------------- Local Functions ---------------------

function a = localSetMaxIter(this,a)
if ~isreal(a) || a<1 || a~=round(a)
   error('MaxIter must be set to a positive integer.')
end
   
function a = localSetRestart(this,a)
if ~isreal(a) || a<1 || a~=round(a)
   error('Restarts must be set to a positive integer.')
end

function a = localSetTol(this,a)
if ~isreal(a) || a<0 || a>1
   error('Tolerances must be set to a real number between 0 and 1.')
end
