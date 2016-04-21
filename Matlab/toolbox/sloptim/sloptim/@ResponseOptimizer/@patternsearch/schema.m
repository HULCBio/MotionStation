function schema
% Optimizer class for PATTERNSEARCH algorithm.

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:47 $
pk = findpackage('ResponseOptimizer');
c = schema.class(pk, 'patternsearch', findclass(pk,'Optimizer'));
