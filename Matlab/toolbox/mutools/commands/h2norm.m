% function out = h2norm(sys)
%
%   Calculates the 2-norm of a stable, strictly
%   proper SYSTEM matrix. H2NORM solves a Lyapunov equation
%   with SYLV to get the controllability grammian.
%
%   See also: H2SYN, HINFSYN, HINFFI, and HINFNORM.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = h2norm(sys)
 if nargin ~= 1
   disp('usage: out = h2norm(sys)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 if mtype == 'syst'
   if mnum == 0
     disp('system has no states')
     return
   else
     [a,b,c,d] = unpck(sys);
     if norm(d,'fro') ~= 0
       disp(['nonzero D term gives INFINITE 2 norm'])
       out = [];
       return
     elseif max(real(eig(a))) >= 0
       disp(['system has poles in closed right-half plane'])
       out = [];
       return
     else
%      p = sylv(a,a',-b*b');
       p = axxbc(a,a',-b*b');
       tnorm = sqrt(sum(diag(c*p*c')));
     end
     if nargout == 1
       out = tnorm;
     else
       fprintf(' %.3e \n',tnorm)
     end
   end
 else
   error('input matrix is not a SYSTEM matrix')
   return
 end