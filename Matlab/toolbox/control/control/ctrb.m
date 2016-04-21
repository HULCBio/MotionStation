function co = ctrb(a,b)
%CTRB  Compute the controllability matrix.
%
%   CO = CTRB(A,B) returns the controllability matrix [B AB A^2B ...].
%
%   CO = CTRB(SYS) returns the controllability matrix of the 
%   state-space model SYS with realization (A,B,C,D).  This is
%   equivalent to CTRB(sys.a,sys.b).
%
%   For ND arrays of state-space models SYS, CO is an array with N+2
%   dimensions where CO(:,:,j1,...,jN) contains the controllability 
%   matrix of the state-space model SYS(:,:,j1,...,jN).  
%
%   See also CTRBF, SS.

%   Thanks to Joseph C. Slater (Wright State University) and
%             Jesse A. Leitner (AFRL/VSSS, USAF)
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:23:03 $

error(nargchk(2,2,nargin))

% Dimension checking
n = size(a,1);
nu = size(b,2);
if ~isequal(n,size(a,2),size(b,1)),
   error('A must be square and have the same number of rows as B.')
end

% Allocate CO and compute each A^k B term
co = zeros(n,n*nu);
co(:,1:nu) = b;
for k=1:n-1
  co(:,k*nu+1:(k+1)*nu) = a * co(:,(k-1)*nu+1:k*nu);
end
