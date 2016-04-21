function w = update_weights(alg, w, u, e);
%UPDATE_WEIGHTS  CMA weight update equation.
%  Update weights for adaptalg.cma.
%  Identical to lms algorithm.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/09/01 09:11:25 $

% alg: adaptalg.cma object
% w:   weight vector
% u:   input vector
% e:   error

G = alg.StepSize * u;
w = alg.LeakageFactor*w + G*conj(e);
