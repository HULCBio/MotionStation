function w = update_weights(alg, w, u, e);
%UPDATE_WEIGHTS  LMS weight update equation.
%  Update weights for adaptalg.lms.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/09/01 09:11:28 $

% alg: adaptalg.lms object
% w:   weight vector
% u:   input vector
% e:   error

G = alg.StepSize * u;
w = alg.LeakageFactor*w + G*conj(e);
