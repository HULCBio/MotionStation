function w = update_weights(alg, w, u, e);
%UPDATE_WEIGHTS  Normalized LMS weight update equation.
%  Update weights for adaptalg.normlms.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/09/01 09:11:30 $

% alg: adaptalg.normlms object
% w:   weight vector
% u:   input vector
% e:   error

G = alg.StepSize * u/(u'*u + alg.Bias);
w = alg.LeakageFactor*w + G*conj(e);
