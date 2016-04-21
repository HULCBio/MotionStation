function [sys,g,T,Ti] = balreal(sys,condt)
%BALREAL  Gramian-based balancing of state-space realizations.
%
%   [SYSB,G] = BALREAL(SYS) computes a balanced state-space 
%   realization for the stable portion of the linear system SYS.
%   For stable systems, SYSB is an equivalent realization 
%   for which the controllability and observability Gramians
%   are equal and diagonal, their diagonal entries forming
%   the vector G of Hankel singular values.  Small entries in G  
%   indicate states that can be removed to simplify the model  
%   (use MODRED to reduce the model order).
% 
%   If SYS has unstable poles, its stable part is isolated, 
%   balanced, and added back to its unstable part to form SYSB.
%   The entries of G corresponding to unstable modes are set 
%   to Inf.  Use BALREAL(SYS,CONDMAX) to control the condition 
%   number of the stable/unstable decomposition (see STABSEP
%   for details).  
%
%   [SYSB,G,T,Ti] = BALREAL(SYS,...) also returns the balancing 
%   state transformation x_b = T*x used to transform SYS into SYSB,
%   as well as the inverse transformation x = Ti*x_b.
%
%   See also MODRED, GRAM, SSBAL, SS.

%	Author(s): J.N. Little 3-6-86
%	           Alan J. Laub 10-30-94
%             P. Gahinet  09-2002
%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.14.4.4 $  $Date: 2004/04/10 23:13:23 $

%  Reference:
%   [1] Laub, A.J., M.T. Heath, C.C. Paige, and R.C. Ward,
%       ``Computation of System Balancing Transformations and Other
%       Applications of Simultaneous Diagonalization Algorithms,''
%       IEEE Trans. Automatic Control, AC-32(1987), 115--122.

ni = nargin;
if ni==1
   condt = 1e8;
end
sizes = size(sys.d);
if ~all(sizes),
   % System w/o state, input or output
   g = zeros(0,1);  T = [];  Ti = [];  return
elseif length(sizes)>2,
   error('Cannot be applied to multiple models at once.')
end

% Stable/unstable partition
% RE: 1) SYS.A scaled with BALANCE and reduced to Schur form 
%        (exploited by Lyapunov solvers)
%     2) Note that Hankel SVs are invariant under state transformation
[Gs,Gns,T,Ti] = stabsep(sys,condt,1,1e3*eps);

% Compute Cholesky factors of reachability and observability Gramians
% RE: Uses Hammarling's algorithm that solves directly for the
%     Cholesky factor of the Lyapunov equation solution (see LYAPCHOL)
Rr = gram(Gs,'cf');
Ro = gram(Gs,'of');

% Compute SVD of the ``product of the Cholesky factors''
% NOTE: Numerically, the product SVD algorithm of Heath et al. (reference [12]
% of [1]) is superior to forming the product ro*rr' directly and then
% computing the SVD.  In other words, the following code should be used:
%      [u,g,v] = prodsvd(ro,rr')
[u,s,v] = svd(Ro*Rr');
g = diag(s);
ns = length(g);

% Form transformation Ts for the stable part
ZeroHSV = (g<=eps*max(g));  % zero or nearly zero HSV
if all(ZeroHSV)
   % g = 0
   Ts = eye(ns);
   Tsi = Ts;
elseif ~any(ZeroHSV)
   % all nonzero
   sgi = 1./sqrt(g);
   Ts = repmat(sgi,[1 ns]) .* (u'*Ro);     % efficient diag(sgi)*u'*Ro
   Tsi = (Rr'*v) .* repmat(sgi.',[ns 1]);  % efficient Rr'*v*diag(sgi)
else
   % Some HSV are nearly zero (non minimal realization)
   nz = sum(ZeroHSV);
   nnz = ns-nz;
   sgi = 1./sqrt(g(1:nnz));
   Zo = orth(Ro');
   Zr = orth(Rr');
   Phi1 = (Zo*Zo'*Ro'*u(:,1:nnz)) .* repmat(sgi.',[ns 1]);
   Psi1 = (Zr*Zr'*Rr'*v(:,1:nnz)) .* repmat(sgi.',[ns 1]);
   Phi2 = null(Phi1');
   Psi2 = null(Psi1');
   [u,s,v] = svd(Phi2'*Psi2);
   sgi = 1./sqrt(diag(s(1:nz,1:nz)));
   Ts =  [Phi1 , (Psi2*v(:,1:nz)) .* repmat(sgi.',[ns 1])]';
   Tsi = [Psi1 , (Phi2*u(:,1:nz)) .* repmat(sgi.',[ns 1])];
end

% Form balanced realization
% REVISIT: should support descriptor case
[aNs,bNs,cNs] = ssdata(Gns);
[as,bs,cs] = ssdata(Gs);
sys.a = {blkdiag(aNs , Ts*as*Tsi)};
sys.b = {[bNs ; Ts*bs]};
sys.c = {[cNs , cs*Tsi]};
sys.e = {[]};
sys.StateName(:) = {''};  % clear names

% Combine state transformations
nns = size(aNs,1);
g = [repmat(Inf,[nns 1]) ; g];
T = blkdiag(eye(nns),Ts) * T;
Ti = Ti * blkdiag(eye(nns),Tsi);


