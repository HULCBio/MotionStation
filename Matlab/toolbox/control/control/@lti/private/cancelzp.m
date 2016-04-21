function [z0,p0,z180,p180] = cancelzp(z,p,Ts,rtol)
%CANCELZP  Utility for ALLMARGIN and BANDWIDTH.

%   Author(s): P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/11 17:27:44 $

% RE: Keep both roots in complex pairs to ensure one-for-one
%     cancellations. OK if resulting z,p are not exactly complex 
%     conjugate.
tol2 = max(eps,rtol^2)^2;

% Pole/zero gap weighting (to ensure max_w |(jw-z)/(jw-p)-1| < rtol^2)
remin = sqrt(eps);  % critical to cancelling pairs on the imag. axis
if Ts
    weights = 1./(remin+abs(1-abs(z))).^2;
else
    weights = 1./(remin+abs(real(z))).^2;
end   

% Simplify cancellable (p,z) pairs
for m=length(z):-1:1,
    gaps = z(m)-p;
    [mingap,imin] = min(real(gaps).^2+imag(gaps).^2);
    if length(mingap) & weights(m)*mingap<tol2,
        % simplify
        p(imin,:) = [];
        z(m,:) = [];
        weights(m) = [];
    end
end
z180 = z;  
p180 = p;

% Further simplify allpass pairs for 0dB crossing detection (continuous time only)
if Ts==0
    for m=length(z):-1:1,
        [mingap,imin] = ...
            min((abs(real(z(m)))-abs(real(p))).^2 + imag(z(m)-p).^2);
        if length(mingap) & weights(m)*mingap<tol2,
            % simplify
            p(imin,:) = [];
            z(m,:) = [];
            weights(m) = [];
        end
    end
end
z0 = z;
p0 = p;


