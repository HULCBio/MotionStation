function w = update_weights(alg, w, u, e);
%UPDATE_WEIGHTS  Variable step LMS weight update equation.
%  update weights for adaptalg.varlms

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/01/26 23:19:06 $

% alg: adaptalg.varlms object
% w:   weight vector
% u:   input vector
% e:   error

mu = alg.StepSize.';
gOld = alg.GradientVector.';

g = u*conj(e);

mu = mu + alg.IncStep * real(g.*gOld);
mu(mu<alg.MinStep)=alg.MinStep;
mu(mu>alg.MaxStep)=alg.MaxStep;

w = alg.LeakageFactor*w + 2*mu.*g;

alg.StepSize = mu.';
alg.GradientVector = g.';
