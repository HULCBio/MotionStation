function r = hpeig(a,b,c,d,e)
%HPEIG  Computes finite eigenvalues of hamiltonian pencil.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2002/11/11 22:21:34 $

% RE: Hamiltonian pencil for unit gain (gamma=1)

% Dimensions
nx = size(a,1);
[ny,nu] = size(d);

% Time scale compression (helpful for ZPK->SS models with low and high freq.)
[a,b,e] = LocalNormalize(a,b,e);

% Form pencil
h11 = [a zeros(nx) ; zeros(nx) -a'];
h12 = [zeros(nx,ny) b ; c' zeros(nx,nu)];
h21 = [c zeros(ny,nx) ; zeros(nu,nx) -b'];
h22 = [eye(ny) , d ; d' , eye(nu)];
j11 = [e zeros(nx) ; zeros(nx) e'];

% Balancing
[h,j] = aebalance([h11 h12;h21 h22],blkdiag(j11,zeros(ny+nu)),'noperm');

% Compute finite eigenvalues
r = eig(h,j);
r = r(isfinite(r));

%------------ Local functions ----------------

function [a,b,e] = LocalNormalize(a,b,e)
% Detects when (A,E) is quasi upper-triangular and applies
% a diagonal scaling that normalizes the (r,s) pairs of 
% diagonal elements to |r|+|s|=1 (the gen. eigs of (A,E) are r/s).
% This scaling improve numerics for models converted from ZPK 
% that have widely spread time scales (see, e.g., test problems in 
% TBANDWIDTH) by enhancing the accuracy of LF roots at the expense 
% of HF roots.
[nx,nu] = size(b);
mag = max(abs(a),abs(e));
maglt = tril(mag,-2);
magld = diag(mag,-1);
if ~any(maglt(:)) & ~any(magld(1:nx-2,:) & magld(2:nx-1,:))
    % (A,E) is in quasi upper-triangular form
    [aa,ee] = qz(a,e,'complex');
    s = log2(max(1,abs(diag(aa))+abs(diag(ee))));
    s = pow2(-round(s));
    a = s(:,ones(1,nx)) .* a;
    e = s(:,ones(1,nx)) .* e;
    b = s(:,ones(1,nu)) .* b;
end
