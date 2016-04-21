function nmhinf = normhinf(varargin)
%NORMHINF Continuous H-Infinity norm.
%
% [NMHINF] = NORMHINF(A,B,C,D,tol) or
% [NMHINF] = NORMHINF(SS_,tol) computes the HINF norm of the given
%    state-space realization. Implemented here is a binary search
%    algorithm of imaginary axis eigenvalue(s) of the Hamiltonian
%
%                        -1           -1
%       H(gam) = | A + BR  D'C     -BR  B'        |
%                |       -1                -1     |
%                |C'(I+DR  D')C    -(A + BR  D'C)'|
%
%    where R = gam^2 I - D'D > 0. HINF norm equals to "gam" when H
%    has imaginary axis eigenvalue(s).
%
%    Initial guesses of the HINF norm upper/lower bounds are
%
%       Upper Bound: max_sigma(D) + 2*sum(Hankel SV(G))
%       Lower Bound: max{max_sigma(D), max_Hankel SV(G)}.
%
%    The search algorithm stops when two adjacent "gam's" have relative
%    error less than "tol". If no "tol" provided, tol = 0.001.

% R. Y. Chiang & M. G. Safonov 8/91
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.11.4.3 $
% All Rights Reserved.

nag1 = nargin;

if nag1 == 5 | nag1 == 2
   [emsg,nag1,xsflag,Ts,a,b,c,d,tol]=mkargs5x('ss',varargin); error(emsg);
elseif nag1 == 4 | nag1 == 1
   [emsg,nag1,xsflag,Ts,a,b,c,d]=mkargs5x('ss',varargin); error(emsg);
   tol = 0.001;
end

% Handle discrete-time systems via z to s Tustin transform:
if Ts,[a,b,c,d]=bilin(a,b,c,d,-1,'Tustin',2*abs(Ts)); end

conda = cond(a);
if conda > 1.e8
   disp('WARNING: THE SYSTEM A MATRIX IS ILL-DONDITIONED ...');
   disp('         RESULT MAY BE INACCURATE ! ');
   disp('         (TRY BALANCING THE PROBLEM USING OBALREAL.M,');
   disp('          IF THE SYSTEM IS MINIMAL.)');
end

[rd,cd] = size(d);
dtd = d'*d;
hsv = hksv(a,b,c);

gam = max(svd(d));
n_l = max([gam,max(hsv)]);
n_h = gam + 2*sum(hsv);

while (n_h-n_l) > 2*tol*n_l
    gam = (n_l+n_h)/2;
    r = gam*gam*eye(cd) - dtd;
    ir = inv(r);
    Ham = [a+b*ir*d'*c  -b*ir*b';
           c'*(eye(rd)+d*ir*d')*c -(a+b*ir*d'*c)'];
    lam = abs(real(eig(Ham)));
    if any(lam < sqrt(eps)) % exists imag. lam
       n_l = gam;
    else                    % no imag. lam
       n_h = gam;
    end
end

nmhinf = gam;

%
% ----- End of NORMHINF.M  % RYC/MGS %
