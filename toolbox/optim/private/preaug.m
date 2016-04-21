function[L,U,P,pcol] = preaug(H,pcf,A,varargin);
%PREAUG  example preconditioner of augmented matrix
%
% [L,U,P,pcol] = PREAUG(H,pcf,A) computes a sparse
% factorization of the LU-factorization of
%
%                   H     A'
%        M =          
%                   A     0  
%
%
% say,
%
%                   HH   AA'
%        MM =   
%                   AA    0
%
% where HH is SPD, usually banded, the nonzeros of AA
% are a subset of the nonzeros of A. If 0 < pcf(1,1) < n then
% the upper bandwidth of HH is pcf(1,1); if pcf(1,1) >= n then HH
% is a sparse Cholesky factorization of H. pcf(2,1) is the dropping
% tolerance for A --> AA.
%

%   Default preconditioner for PPCGR and SFMINLE.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/02/01 22:09:34 $
 
%
% Approximate H
if nargin ==0, 
   error('optim:preaug:NotInputs','No input parameters in function PREAUG.'); 
end
n = size(A,2);
if ~isnumeric(H) | ~isequal(size(H),[n,n]) 
    H = speye(n);    % default for H of wrong size
end
epsi = .001*ones(n,1);
info = 1;
HH = H;
if nargin <2, 
   pcf = [0;.05]; 
end
[mpcf,dumm] = size(pcf);
if mpcf < 2 
   pcf(2,1) = .05; 
end
tolA = abs(pcf(2,1));
ppcf = pcf(1,1);

if ppcf >= n % Try complet approx to H
   p = symamd(H);
   ddiag = diag(H);
   mind = min(ddiag);
   lambda = 0;
   if mind < 0, 
      lambda = -mind + .001; 
   end
   while info > 0
      H = H + lambda*speye(n);
      [R,info] = chol(H(p,p));
      lambda = lambda + 10;
   end
elseif (ppcf > 0) & ( ppcf < n) %Banded approximation to H
   % Cluster diagonal
   p = symrcm(H);
   HH = H(p,p);
   bndw = ppcf;
   HH = tril(triu(HH,-bndw),bndw);
   lambda = 0;
   ddiag = diag(HH);
   mind = min(ddiag);
   if mind < 0, 
      lambda = -mind + .001; 
   end
   while info > 0
      HH = HH + lambda*speye(n);
      [R,info] = chol(HH);
      lambda = 4*lambda;
      if lambda <= .001, 
         lambda = 1; 
      end
   end
   H(p,p) = HH;
else % diagonal approximation for H
   dnrms = sqrt(sum(H.*H))';
   d = max(dnrms,epsi);
   H = sparse(1:n,1:n,full(d));
end
if nargin < 3, 
   A = []; 
end
if isempty(A)
   L = R'; 
   U = R; 
   pcol = p; 
   P = sparse(n,n,pcol);
   return
end
[m,nn] = size(A);
if nn ~= n, 
   error('optim:preaug:SizeConflict', ...
         'Size of A conflicts with that of H in function PREAUG.'); 
end
if m > n, 
   error('optim:preaug:InvalidA', ...
         'Matrix A should have more columns than rows.'); 
end
%
% Approximate A
%
% Set up the augmented matrix
A = gangstr(A,tolA);
M = [H,A';A, sparse(m,m)];
pcol = colamd(M); 
pcol = pcol;
[L,U,P] = lu(M(:,pcol));


