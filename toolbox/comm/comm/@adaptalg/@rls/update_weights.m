function w = update_weights(alg, w, u, e);
%UPDATE_WEIGHTS  RLS weight update equation.
%  Update weights for adaptalg.rls.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/09/01 09:11:31 $

% alg: RLS adaptive algorithm object
% w:   weight vector
% u:   input vector
% e:   error

Delta = alg.InvCorrMatrix;
lambda = alg.ForgetFactor;

G = Delta * u / (lambda + u'*Delta*u);
Delta = 1/lambda * (Delta - G*u'*Delta);
w = w + G*conj(e);

alg.InvCorrMatrix = Delta;
