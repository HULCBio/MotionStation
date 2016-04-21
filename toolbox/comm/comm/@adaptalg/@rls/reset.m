function reset(alg)
%RESET  Reset RLS adaptive algorithm object.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/26 23:18:56 $

% Reset inverse correlation matrix.
alg.InvCorrMatrix = alg.InvCorrInit*eye(alg.nWeightsPrivate);
