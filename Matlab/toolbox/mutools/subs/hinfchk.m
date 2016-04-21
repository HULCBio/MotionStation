% function out = hinfchk(sys,nnorm,zeroeps)
%
%   forms Hamiltonian matrix for H_infinity
%   norm calculation for SYSTEM matrices.
%   subroutine for HINFNORM.
%
%   See also: H2, H2NORM, HINF, HINFFI, and HINFNORM.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = hinfchk(sys,nnorm,zeroeps)
 if nargin == 0
   disp('usage: out = hinfchk(sys,nnorm,zeroeps)')
   return
 end
 if nargin == 1
   nnorm = 1;
   zeroeps = 1e-9;
 elseif nargin == 2
   zeroeps = 1e-9;
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 [a,b,c,d] = unpck(sys);
 b = (1.0/sqrt(nnorm)) * b;
 c = (1.0/sqrt(nnorm)) * c;
 d = (1.0/nnorm) * d;
 imdd = eye(mcols) - d'*d;
 sol = imdd \ [b' d'*c];
 ham = [-a' -c'*c ; 0*a a] - [c'*d;-b]*sol;

 [out,epkgdif,realmin] = jwhamtst(ham,zeroeps);

%
%