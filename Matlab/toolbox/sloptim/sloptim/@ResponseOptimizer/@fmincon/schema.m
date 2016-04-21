function schema
% Optimizer class for FMINCON.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:39 $
pk = findpackage('ResponseOptimizer');
c = schema.class(pk, 'fmincon', findclass(pk,'Optimizer'));
