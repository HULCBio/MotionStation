function w = update_weights(alg, w, u, e);
%UPDATE_WEIGHTS  Sign LMS weight update equations.
%  Update weights for adaptalg.signlms.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/12 23:00:08 $

% alg: adaptalg.signlms object
% w:   weight vector
% u:   input vector
% e:   error

switch alg.AlgType
    case 'Sign LMS'
        v = u * sign(real(e));
    case 'Signed Regressor LMS'
        v = sign(real(u)) * real(e);
    case 'Sign Sign LMS'
        v = sign(real(u))*sign(real(e));
    case 'Complex Sign LMS'
        z = u*conj(e);
        v = complex(sign(real(z)), sign(imag(z)));
end
w = alg.LeakageFactor*w + alg.StepSize * v;
