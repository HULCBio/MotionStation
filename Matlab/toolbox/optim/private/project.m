function [pvec,LZ,UZ,pcolZ,PZ,PT]  = project(A,vec,PT,LZ,UZ,pcolZ,PZ);
%PROJECT Non-orthogonal projector
%
% pvec = PROJECT(A,vec) is a non-orthogonal projection of vec
% onto null(A).
%
% pvec = PROJECT(A,vec,PT,LZ,UZ,pcolZ,PZ) is a non-orthogonal 
% projection of vec
% onto null(A). PT is a permutation matrix such that A*PT 
% has a leading nonsingular  m-by-m matrix, A_1,
% where m is the number of rows of A
% PZ*A_1(:,pcolZ) = LZ*UZ, the sparse LU-factorization on A_1.
%	
% [pvec,LZ,UZ,pcolZ,PZ,PT]  = project(A,vec) is a non-orthogonal 
% projection of
% vec onto null(A). PT is a permutation matrix such that A*PT
% has a leading nonsingular  m-by-m matrix, A_1,
% where m is the number of rows of A
% PZ*A_1(:,pcolZ) = LZ*UZ, the sparse LU-factorization on A_1.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/01 22:09:35 $

[m,n] = size(A); 
if m > n
   error('optim:project:InvalidA', ...
         'Function PROJECT expects A to have more columns than rows.'); 
end
if nargin < 3 | isempty(PT)
   PT = findp(A); 
end

A = A*PT'; 
vec = PT*vec;
if nargin < 6
   [pvec,LZ,UZ,pcolZ,PZ] = fzmult(A,vec,'transpose');
else
   pvec = fzmult(A,vec,'transpose',LZ,UZ,pcolZ,PZ);
end
pvec = PT'*fzmult(A,pvec,'',LZ,UZ,pcolZ,PZ);



