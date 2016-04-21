function r = speig(a,b,c,d,e)
%SPEIG  Computes finite eigenvalues of symplectic pencil.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2002/11/11 22:22:09 $

% RE: Symplectic pencil for unit gain (gamma=1)

% Dimensions
nx = size(a,1);
[ny,nu] = size(d);

% Use form where Q matrix of pencil P-z*Q is block upper triangular
h11 = [a zeros(nx) ; zeros(nx) e'];
h12 = [zeros(nx,ny) b ; zeros(nx,ny+nu)];
h21 = [c zeros(ny,nx) ; zeros(nu,nx) b'];
h22 = [eye(ny) , d ; d' , eye(nu)];
j11 = [e zeros(nx) ; zeros(nx) a'];
j12 = [zeros(nx,ny+nu) ; c' zeros(nx,nu)];

% Balancing
[h,j] = aebalance([h11 h12;h21 h22],...
                  [j11 j12;zeros(ny+nu,2*nx+ny+nu)],'noperm');

% Compute finite eigenvalues
r = eig(h,j);
r = r(isfinite(r));
