function reset(alg)
%RESET  Reset varlms adaptive algorithm object.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/26 23:19:03 $

% Initialize step size and gradient vector.
alg.StepSize = alg.InitStep*ones(1, alg.nWeightsPrivate);
alg.GradientVector = zeros(1, alg.nWeightsPrivate);
