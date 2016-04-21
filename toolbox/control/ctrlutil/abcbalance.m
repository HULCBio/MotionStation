function [a,b,c,e,t,sfio] = abcbalance(a,b,c,e,condt,varargin)
%ABCBALANCE  Balancing of state-space models.
%
%   [A,B,C,E,T] = ABCBALANCE(A,B,C,E,CONDT) uses BALANCE to
%   compute a diagonal similarity transformation T such that 
%   [T*A/T,T*B;C/T,0] has approximately equal row and column 
%   norms.  CONDT specifies an upper bound on the condition 
%   number of T.
%
%   [A,B,C,E,T,IOS] = ABCBALANCE(A,B,C,E,CONDT,Option1,Option2,...)
%   specifies additional options as strings:
%     'noperm'   Prevents state permutation during balancing
%     'perm'     Enables state permutation (default)
%     'scale'    Rescales B and C to make the balancing insensitive 
%                to I/O scale
%     'noscale'  No I/O rescaling (default)
%
%   With the 'scale' option, balancing is performed on the scaled
%   triplet (A,IOS*B,IOS*C).  This I/O rescaling is implicit and 
%   does not change the transfer function returned by ABCBALANCE.
%
%   LOW-LEVEL UTILITY, CALLED BY SSBAL.

%   Authors: P. Gahinet and C. Moler
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8.6.1 $  $Date: 2002/11/11 22:23:06 $

% RE: Expects A,B,C,E to be matrices or ND arrays

% Defaults and parameters
XPerm = true;     % state permutation enabled
ScaleIO = false;  % don't rescale I/O transfer function
for ct=1:length(varargin)
    switch lower(varargin{ct})
    case 'perm'
       XPerm = true;
    case 'noperm'
       XPerm = false;
    case 'scale'
       ScaleIO = true;
    case 'noscale'
       ScaleIO = false;
    end
end
   
% Get dimensions
asizes = size(a);
nx = asizes(1);
ne = size(e,1);
nu = size(b,2);
ny = size(c,1);
nsys = prod(asizes(3:end));

% Quick exit when no state
if nx==0 | nsys==0,
   t = eye(nx); 
   sfio = 1;
   return
end

% Form 2D matrix M = [|A|+|E| |B|;|C| 0] to be balanced
mae = max(abs(a(:,:,:)),[],3);
if ne,
   mae = mae + max(abs(e(:,:,:)),[],3);
end
mb = max([max(abs(b(:,:,:)),[],3) , zeros(nx,1)],[],2);
mc = max([max(abs(c(:,:,:)),[],3) ; zeros(1,nx)],[],1);

% Compute scalings SFX (states), SFBC (B vs. C), and SFIO (scaling H(s) -> sfio * H(s))
if ScaleIO && any(mb) && any(mc) && norm(mae,1)>0
    % Balancing with optimal I/O scaling
    [sfx,sfbc,sfio,p] = LocalScaleBalance(mae,mb,mc,XPerm);
else
    % No I/O scaling
    [sfx,sfbc,sfio,p] = LocalBalance(mae,mb,mc,XPerm,condt);
end

% If cond(T) exceeds CONDT, rescale diag(T) to match the bound on CONDT 
if isfinite(condt) & max(sfx)>10*condt*min(sfx),
   sfx = log2(sfx);
   scalf = log2(condt)/(max(sfx)-min(sfx));
   sfx = pow2(round(scalf*sfx));
end

% Compute balanced/scaled realization
isfx = 1./sfx;
for k=1:nsys,
   a(p,p,k) = lrscale(a(:,:,k),isfx,sfx);
   b(p,:,k) = lrscale(b(:,:,k),isfx,[]) * sfbc;
   c(:,p,k) = lrscale(c(:,:,k),[],sfx) / sfbc;
   if ne,
      e(p,p,k) = lrscale(e(:,:,k),isfx,sfx);
   end   
end

% Form scaling transform T and return inv(T) to be consistent with SS2SS
t = zeros(nx);
t(p,:) = sfbc * diag(isfx);


%--------------- Local Functions --------------------------------------

%%%%%%%%%%%%%%%%
% LocalBalance %
%%%%%%%%%%%%%%%%
function [sfx,sfbc,sfio,perm] = LocalBalance(a,b,c,XPerm,condt)
% Regular balancing
nx = size(a,1);

% To activate balancing when M=[A B;C 0] is triangular, set
% zero entries of B and C to
%   * C(j)=TINY*|C| if C~=0, |B| otherwise 
%   * B(j)=TINY*|B| if B~=0, |C| otherwise
% RE: This perturbation will be visible only when C.ej=0 and 
%     A.ej=s.ej, i.e., x(j) is unobservable or uncontrollable
bmax = max(b); 
cmax = max(c);
tiny = max(1e-100,(1/condt)^2);
b(b==0) = tiny * bmax + (bmax==0) * cmax;
c(c==0) = tiny * cmax + (cmax==0) * bmax;

% Perform the balancing with BALANCE
[sf,junk,junk] = balance([a b;c 0],'noperm');
sfx = sf(1:nx);     % balances the states
sfbc = sf(nx+1);    % equalizes |B| and |C|
sfio = 1;

% BALANCE may permute the rows/cols of A to enforce triangularity (desirable 
% for balancing prior to Hessenberg reduction). Acquire this permutation PERM
if XPerm
   [junk,perm,junk] = balance(a);
else
   perm = 1:nx;  % No permutation
end


%%%%%%%%%%%%%%%%%%%%%
% LocalScaleBalance %
%%%%%%%%%%%%%%%%%%%%%
function [sfx,sfbc,sfio,perm] = LocalScaleBalance(a,b,c,XPerm)
% Balancing with optimal I/O scaling. Seeks scaling t=SFIO such that 
% after balancing of (A,tB,tC,0), the norms of A, B, C are roughly 
% equalized and nearly equal to the norm of BALANCE(A). This particular 
% scaling enhances computations that ought to be invariant under I/O scaling 
% (e.g., computing transfer function zeros)

% RE: Do not remove A's diagonal (geck 130048)
%     a = [-3e4 1;0 -6e9]; b = [1e9;0];  c = [0,1e9]; d = 1;
%     zero(ss(a,b,c,d))
nx = size(a,1);

% Balance A and acquire PERM if requested
if XPerm
   [sa,perm,a0] = balance(a);
else
   [sa,perm,a0] = balance(a,'noperm');
end
anorm0 = norm(a0,1);

% Lower bound on optimal scaling t* using balancing at t=0
b0 = lrscale(b,1./sa,[]);
c0 = lrscale(c,[],sa);
tlb = 0.5*anorm0/sqrt(max(b0)*max(c0));

% Estimate t* where ||A(t)|| starts increasing
% Algorithm first increases t until an upper bound TUB is found, and
% then refines the estimate [TLB,TUB] of t*
% RE: Since TLB is scale invariant, this ensures appx scale invariance
%     of the balancing algorithm
tub = Inf;
sflb = [];
iter = 0;
while iter<6 && tub>100*tlb
   % Next test point
   if isinf(tub)
      t = tlb * 10^(2+iter);
   else
      t = sqrt(tlb*tub);
   end
   % Balance
   [sfx,junk,m] = balance([a t*b;t*c 0],'noperm');
   if norm(m(1:nx,1:nx),1)>=2*anorm0
      tub = t;
   else
      tlb = t;  sflb = sfx;
   end
   iter = iter+1;
end

% Use scaling for t=tlb (makes difference for margex2 in ltigallery)
sfio = tlb;
if isempty(sflb)
   [sflb,junk,junk] = balance([a tlb*b;tlb*c 0],'noperm');
end
sfbc = sflb(nx+1);  % equalizes |B| and |C|
sfx = sflb(1:nx);   % balances the states
