% [gopt,K] = hinfric(P,r)
% [gopt,K,X1,X2,Y1,Y2,Preg] = hinfric(P,r,gmin,gmax,tol,options)
%
% For a continuous-time plant  P(s), computes the best
% H-infinity performance GOPT in the interval [GMIN,GMAX]
% as well as an H-infinity central controller  K(s)  that
%    * internally stabilizes the plant, and
%    * yields a closed-loop gain no larger than GOPT.
% HINFRIC implements the Riccati-based approach. The plant is
% regularized when necessary.
%
% To compute just GOPT, call HINFRIC with only one output argument.
% The input arguments  GMIN, GMAX, TOL, and OPTIONS  may be jointly
% omitted
%
% Input:
%  P          plant SYSTEM matrix  (see LTISYS)
%  R          1x2 vector specifying the dimensions of D22. That is,
%                   R(1) = nbr of measurements (inputs of K)
%                   R(2) = nbr of controls (outputs of K)
%  GMIN,GMAX  a-priori bounds on GOPT.   If no such bounds are
%             available, set  GMIN = GMAX = 0.  To test if some value
%             GAMA is feasible, set  GMIN = GMAX = GAMA.
%  TOL        relative accuracy required on GOPT (default = 1e-2).
%  OPTIONS    optional 3-entry vector of control parameters for
%             numerical computations.
%             OPTIONS(1): valued in [0,1], default=0. The larger its
%                   value is, the smaller the norms of the controller
%                   state-space matrices are.
%             OPTIONS(2): valued in [0,1], default=0. The larger its
%                   value is, the better the closed-loop damping is
%                   in the face of jw-axis zeros.
%             OPTIONS(3): default=1e-3. Reduced-order synthesis is
%                   performed whenever
%                      rho(X*Y) >=  ( 1 - OPTIONS(3) ) * GOPT^2
% Output:
%  GOPT       best H-infinity performance in [GMIN,GMAX]
%  K          central H-infinity controller for gamma = GOPT
%  X1,X2,..   X = X2/X1  and  Y = Y2/Y1  are the solutions of the two
%             H-infinity Riccati equations for  gamma = GOPT.
%  PREG       regularized plant if P(s) was singular
%
%
%  See also  HINFLMI, DHINFRIC.

% Authors: P. Gahinet and A.J. Laub  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

% Reference:
%  * for regular plants, Doyle et al., IEEE Trans. Aut. Contr.,
%    pp. 831-847, 1989
%  * for singular plants with D12 or D21 rank-deficient,
%    Gahinet and Laub , Proc. CDC, 1994

function [gopt,Kcen,x1,x2,y1,y2,Preg] = hinfric(P,r,gmin,gmax,tol,options)

if nargin <2,
  error('usage:  [gopt,K,X1,X2,Y1,Y2] = hinfric(P,r,gmin,gmax,tol,options)');
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
knobrk=min(1,max(0,options(1)));
knobjw=min(1,max(0,options(2)));
tolred=options(3);
if tolred==0, tolred=1e-3; end


gopt=[]; Kcen=[]; x1=[]; x2=[]; y1=[]; y2=[];


% balance the plant realization
%------------------------------

P=sbalanc(P);



% compute the optimal performance in the interval [gmin,gmax]
%------------------------------------------------------------

[gopt,x1,x2,y1,y2,sing12,sing21]=goptric(P,r,gmin,gmax,tol,knobjw);

if nargout <=1 | isempty(gopt), return, end

g0=gopt;


% plant regularization and reliability enhancement
%-------------------------------------------------

[Preg,gopt,x1,x2,y1,y2]=...
   plantreg(P,r,gopt,x1,x2,y1,y2,sing12,sing21,knobrk,knobjw,macheps);



% compute the central controller
%-------------------------------

[Kcen,gfin]=kric(Preg,r,gopt,x1,x2,y1,y2,tolred,knobrk);



if gfin > 1.01*g0,
  disp(sprintf('GAMMA_OPT  reset to  %6.3e  during regularization',gfin));
end



gopt=gfin;




% post-analysis
%--------------

[ak,bk,ck,dk]=ltiss(Kcen);
[a,b1,b2,c1,c2]=hinfpar(P,r);


if max(real(eig([a+b2*dk*c2,b2*ck;bk*c2,ak]))) >= 0,
   disp('Failure: closed-loop unstability due to numerical difficulties!')
   disp('   Increase OPTIONS(1) or GAMMA for more reliable computations')
   disp('  ');
   return
elseif abs(sum(diag(ak))) > 1e6,
   disp('Warning:  the controller parameters have high norms!')
   disp('   For more reliable computations, increase OPTIONS(1) or GAMMA')
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
     if min(s) < sqrt(macheps)*max(s),
       Kcen=[];
       error('Algebraic loop due to nonzero D22!  Perturb D22 and recompute K');
     else
       tmp=Mk2\ck;
       Kcen=ltisys(ak-bk*d22*tmp,bk/M2k,tmp,Mk2\dk);
     end
  else
     Kcen=ltisys(ak-bk*d22*ck,bk,ck,dk);
  end
end
