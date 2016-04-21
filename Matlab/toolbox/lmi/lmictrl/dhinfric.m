% [gopt,K,X1,X2,Y1,Y2] = dhinfric(P,r,gmin,gmax,tol,options)
%
% For a discrete-time plant P(z), computes the best
% H_infinity performance GOPT in the interval [GMIN,GMAX]
% as well as an H_infinity central controller  K(s)  that
%    * internally stabilizes the plant, and
%    * yields a closed-loop gain no larger than GOPT.
% DHINFRIC implements the Riccati-based approach.
%
% To compute just GOPT, call DHINFRIC with only one output argument.
% The input arguments  GMIN, GMAX, TOL, and OPTIONS  may be jointly
% omitted
%
% Assumptions on P(z):  stabilizable/detectable, D12 and D21 full rank
%
% Input:
%  P          plant SYSTEM matrix  (see LTISS)
%  R          1x2 vector specifying the dimensions of D22. That is,
%                      R(1) = nbr of measurements
%                      R(2) = nbr of controls
%  GMIN,GMAX  a-priori bounds on GOPT.   If no such bounds are
%             available, set  GMIN = GMAX = 0.  To test if some value
%             GAMA is feasible, set  GMIN = GMAX = GAMA.
%  TOL        relative accuracy required on GOPT (default = 1e-2).
%  OPTIONS    optional 3-entry vector of control parameters for
%             numerical computations.
%             OPTIONS(1): not used
%             OPTIONS(2): valued in [0,1], default=0. The larger its
%                   value is, the better the closed-loop damping is
%                   in the face of unit-circle zeros.
%             OPTIONS(3): default=1e-3. Reduced-order synthesis is
%                   performed whenever
%                      rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% Output:
%  GOPT       best H_infinity performance in [GMIN,GMAX]
%  K          central H_infinity controller for gamma = GOPT
%  X1,X2,..   X = X2/X1  and  Y = Y2/Y1  are the solutions of the two
%             H_infinity Riccati equations for  gamma = GOPT.
%
%
% See also  DHINFLMI.

% Authors: P. Gahinet and A.J. Laub 10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [gopt,Kcen,x1,x2,y1,y2] = dhinfric(P,r,gmin,gmax,tol,options)


ubo=1; lbo=1;   % default = specified bounds

if nargin <2,
  error('usage:  [gopt,K,x1,x2,y1,y2] = dhinfric(P,r,gmin,gmax,tol,options)');
elseif length(r)~=2,
  error('R must be a two-entry vector');
elseif min(r)<=0,
  error('The entries of R must be positive integers');
else
  if nargin < 6, options=[0 0 0]; end
  if nargin < 5, tol=1e-2; end
  if nargin < 4, gmax=0;  end
  if nargin < 3, gmin=0;  end
end

if isempty(tol) | tol <= 0, tol=1e-2; end
macheps=mach_eps;
knobjw=options(2);
tolred=options(3);
if tolred==0, tolred=1e-3; end

gopt=[]; Kcen=[]; x1=[]; x2=[]; y1=[]; y2=[];


% balance the plant realization
%------------------------------

P=sbalanc(P);



% compute the optimal performance in the interval [gmin,gmax]
%------------------------------------------------------------

[gopt,x1,x2,y1,y2,sing12,sing21]=dgoptric(P,r,gmin,gmax,tol,knobjw);


if sing12 & sing21,
  disp('** D12 and D21 are rank-deficient'); return,
elseif sing12,
  disp('** D12 is rank-deficient'); return,
elseif sing21,
  disp('** D21 is rank-deficient'); return,
elseif nargout <=1 | isempty(gopt), return,
end



% compute the central controller
%-------------------------------

[Kcen,gopt]=dkcen(P,r,gopt,x1,x2,y1,y2,tolred);



% post-analysis
%--------------

[ak,bk,ck,dk]=ltiss(Kcen);
[a,b1,b2,c1,c2]=hinfpar(P,r);


if max(abs(eig([a+b2*dk*c2,b2*ck;bk*c2,ak]))) >= 1,
   disp('Failure: closed-loop unstability due to numerical difficulties!')
   disp('   Increase OPTIONS(1) or GAMMA for more reliable computations')
   disp('  ');
   return
elseif norm(ak,1) > 1e6,
   disp('Warning in DHINFRIC:  the controller parameters have high norms!')
   disp('   For more reliable computations, increase OPTIONS(1) or GAMMA')
   disp('  ');
end




% update K(z) if D22 is nonzero
%------------------------------

[rp,cp]=size(P); p2=r(1); m2=r(2);
d22=P(rp-p2:rp-1,cp-m2:cp-1);

if norm(d22,1) > 0,
  if norm(dk,1) > 0,
     M2k=eye(p2)+d22*dk; Mk2=eye(m2)+dk*d22;
     s=svd(M2k);
     if min(s) < sqrt(macheps)*max(s),
       Kcen=[];
       error('Algebraic loop due to nonzero D22!  Perturb D22 and recompute K(s)');
     else
       tmp=Mk2\ck;
       Kcen=ltisys(ak-bk*d22*tmp,bk/M2k,tmp,Mk2\dk);
     end
  else
     Kcen=ltisys(ak-bk*d22*ck,bk,ck,dk);
  end
end
