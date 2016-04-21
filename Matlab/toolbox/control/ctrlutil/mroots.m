function r = mroots(p,varargin)
%MROOTS  Polynomial roots with multiplicity estimate
%
%   R = MROOTS(P) computes the roots R of the polynomial P and 
%   estimates the true value and multiplicity of multiple roots.
%
%   R = MROOTS(P,TOL) further specifies the admissible relative 
%   error TOL on the coefficient of P when approximating a cluster 
%   of roots by a multiple root (default = SQRT(EPS))
%
%   See also ROOTS.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $   $Date: 2002/04/10 06:38:41 $


% Parse input list and set defaults
ni = nargin;
nargchk(1,4,ni);
if ni==1 | ~isstr(varargin{1}),
   ComputeRoots = 1;   % 1 if roots need to be computed
else
   ComputeRoots = 0;   
   ni = ni-1;
   varargin(1) = [];
end

switch ni
case 1
   ptol = sqrt(eps);   % default max. relative error on p(i)
   roundoff = eps;     % round-off level on roots
case 2
   ptol = varargin{1};
   roundoff = eps;
case 3
   [ptol,roundoff] = deal(varargin{:});
end

% Compute roots
if ComputeRoots,
   r = roots(p);
   realflag = isreal(p);
else
   % Syntax MROOTS(R,'roots') where roots R already computed
   r = p(:);
   realflag = isequal(sort(r(imag(r)>0)),sort(conj(r(imag(r)<0))));
end

% Check for clustering around zero
tolabs = sqrt(roundoff);
absr = abs(r);
izero = (absr<tolabs);
rzero = zeros(sum(izero),1);
r = r(~izero,1);
absr = absr(~izero,1);

% Compute relative separation of roots (SEPMAT)
lr = length(r);
repr = r(:,ones(1,lr));
repabs = absr(:,ones(1,lr));
sepmat = eye(lr) + (abs(repr-repr.')./min(repabs,repabs'));

% Sort the roots such that r(k) is the closest roots
% (in the SEPMAT measure) to r(1),r(2),...,r(k-1)
ilist = 1:min(1,lr);
irem = min(1,lr)+1:lr;
gaps = zeros(1,lr);      % stores d(r(k),{r(1),r(2),...,r(k-1)})
for k=2:lr,
   [gaps(k),imin] = min(min(sepmat(ilist,irem),[],1));
   ilist = [ilist irem(imin)];
   irem(imin) = [];
end
r = r(ilist,1);

% Recursively check & split the cluster R
if length(r)>1,
   r = CheckCluster(r,gaps,ptol,roundoff);
end

% Put result together
r = [rzero ; r];
if realflag,
   r(imag(r)<0) = conj(r(imag(r)>0));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rc = CheckCluster(rc,gaps,ptol,roundoff)
%CLUSTER   Checks if a given root cluster RC can be identified with 
%          a multiple root.  If not, the cluster is split into 
%          subclusters and CHECKCLUSTER is invoked on each subcluster.
%
%   PTOL = max. rel. error on polynomial values
%   ROUNDOFF = round-off level on roots


% Ignore first entry of GAPS vector
gaps(1) = 0;  

% Get multiplicity and cluster center
m = length(rc); 
rmean = sum(rc)/m;
if isequal(sort(rc(imag(rc)>0)),sort(conj(rc(imag(rc)<0))))
   % Make sure RMEAN is real
   rmean = real(rmean);
end

% Tolerances
rtol = m * roundoff^(.7/m);   % max. distance to mean root
maxgap = min(0.1,2*rtol);     % max. gap between roots

% Test if cluster can be assimilated to root RMEAN of multiplicity M.  
% All roots should lie in disk of center RMEAN  and radius 
% RTOL * ABS(RMEAN), and the worst gap between values of POLY(RC) and 
% POLY(RMEAN*ONES(1,M)) should not exceed PTOL
if any(gaps>maxgap),
   % Some gaps exceed threshold: split cluster
   splitgap = maxgap;
elseif max(abs(rc-rmean)) > rtol*abs(rmean),
   % Some roots lie outside reference disk
   splitgap = max(gaps)/2;
else
   % Compare values of poly(rc) and (s-rmean)^m at the 
   % m points rmean+|rmean|*exp(j*2*pi*k/m)), k=0:m-1
   rad = max(1,abs(rmean));
   testpts = rmean+rad*exp((2*j*pi/m)*(0:m-1));
   values = prod((testpts(ones(m,1),:)-rc(:,ones(m,1)))/rad);
   if max(abs(values-1)) > ptol,
      % Split cluster
      splitgap = max(gaps)/2;
   else
      % Cluster can be assimilated to multiple root RMEAN
      rc = rmean * ones(m,1);
      return
   end
end

% Split cluster if fusion into multiple root RMEAN failed
igap = find(gaps>splitgap);
isub = [1 , igap ; igap-1 m];  % all subclusters
isub = isub(:,diff(isub)>0);   % discard subcluster with single roots
for ix=isub,
   rc(ix(1):ix(2)) = CheckCluster(rc(ix(1):ix(2)),gaps(ix(1):ix(2)),ptol,roundoff);
end


