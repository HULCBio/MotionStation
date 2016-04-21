% [gopt,K] = hinflmi(P,r)
% [gopt,K,X1,X2,Y1,Y2] = hinflmi(P,r,g,tol,options)
%
% Given the continuous-time plant P(s), computes the best
% H-infinity performance GOPT as well as an H-infinity
% controller  K(s)  that
%    * internally stabilizes the plant, and
%    * yields a closed-loop gain no larger than GOPT.
% HINFLMI implements the LMI-based approach.
%
% To compute only GOPT, call HINFLMI with only one output argument.
% The input arguments  G, TOL, and OPTIONS  are optional.
%
% Input:
%  P          plant SYSTEM matrix  (see LTISYS)
%  R          1x2 vector specifying the dimensions of D22. That is,
%                      R(1) = nbr of measurements
%                      R(2) = nbr of controls
%  G          user-specified target for the closed-loop performance.
%             Set G=0 to compute GOPT, and set  G=GAMMA  to test
%             whether the performance GAMMA is achievable.
%  TOL        relative accuracy  required on GOPT   (default=1e-2)
%  OPTIONS    optional 3-entry vector of control parameters for
%             the numerical computations.
%             OPTIONS(1): valued in [0,1] (default=0). Reduces the
%                         norm of R when increased  -> slower
%                         controller dynamics
%             OPTIONS(2): same for S
%             OPTIONS(3): default = 1e-3. Reduced-order synthesis is
%                         performed whenever
%                          rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% Output:
%  GOPT       best H-infinity performance
%  K          central H-infinity controller for gamma = GOPT
%  X1,X2,..   X = X2/X1  and  Y = Y2/Y1  are solutions of the
%             two H-infinity Riccati inequalities for gamma = GOPT.
%             Equivalently,  R = X1  and  S = Y1  are solutions
%             of the characteristic LMIs since X2=Y2=GOPT*eye .
%
%
% See also  HINFRIC, HINFMIX, HINFGS.

% Author: P. Gahinet  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

% Reference:
%  Gahinet and Apkarian , "A Linear Matrix Inequality Approach
%  to H-infinity Control," Int. J. Robust and Nonlinear Contr.,
%  4 (1994), pp. 421-448.


function [gopt,Kcen,x1,x2,y1,y2] = hinflmi(P,r,gmin,tol,options)

if nargin <2,
  error('usage:  [gopt,K] = hinflmi(P,r,g,tol,options)');
elseif length(r)~=2,
  error('R must be a two-entry vector');
elseif min(r)<=0,
  error('The entries of R must be positive integers');
else
  if nargin < 5, options=[0 0 0]; end
  if nargin < 4, tol=1e-2;  end
  if nargin < 3, gmin=0;  end
end
tolred=options(3);
if tolred==0, tolred=1e-3; end

macheps=mach_eps;
gopt=[]; Kcen=[]; x1=[]; x2=[]; y1=[]; y2=[];



% compute the optimal performance in the interval [gmin,gmax]
%------------------------------------------------------------

disp(sprintf('\n Minimization of gamma:'));


[gopt,x1,x2,y1,y2]=goptlmi(P,r,gmin,tol,options);

if isempty(gopt),
  disp('HINFLMI:  The LMI optimization failed!');
  return
else
  disp(sprintf(' Optimal Hinf performance:  %6.3e \n',gopt));
end
if nargout <=1, return, end



% compute the central controller
%-------------------------------


[Kcen,gopt,flag]=klmi(P,r,gopt,x1,x2,y1,y2,tolred);



% post-analysis
%--------------

[ak,bk,ck,dk]=ltiss(Kcen);
[a,b1,b2,c1,c2]=hinfpar(P,r);

if flag(1) & flag(2),
   str='OPTIONS(1:2) or ';
elseif flag(1)
   str='OPTIONS(1) or ';
elseif flag(2)
   str='OPTIONS(2) or ';
else str='';
end

if max(real(eig([a+b2*dk*c2,b2*ck;bk*c2,ak]))) >= 0,
   disp('Failure: closed-loop unstability due to numerical difficulties!')
   disp(['   Increase ' str 'GAMMA to improve reliability']);
   disp('  ');
   return
elseif abs(sum(diag(ak))) > 1e6,
   disp('Warning:  the controller has fast modes (modulus > 1e6)')
   disp(['   Increase ' str 'GAMMA to eliminate fast dynamics']);
   disp('  ');
end



% update K(s) if D22 is nonzero
%------------------------------
[rp,cp]=size(P); p2=r(1); m2=r(2);
d22=P(rp-p2:rp-1,cp-m2:cp-1);

if norm(d22,1) > 0,
  if norm(dk,1) > 0,
     M2k=eye(p2)+d22*dk; Mk2=eye(m2)+dk*d22;
     s=svd(M2k);
     if min(s) < sqrt(macheps),
       error('Algebraic loop due to nonzero D22!  Perturb D22 and recompute K(s)');
       Kcen=[];
     else
       tmp=Mk2\ck;
       Kcen=ltisys(ak-bk*d22*tmp,bk/M2k,tmp,Mk2\dk);
     end
  else
     Kcen=ltisys(ak-bk*d22*ck,bk,ck,dk);
  end
end
