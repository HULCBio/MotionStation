function L = leslie(a,b)
%LESLIE  Leslie matrix.
%   GALLERY('LESLIE',A,B) is the N-by-N matrix from the Leslie
%   population model with average birth numbers A(1:N) and 
%   survival rates B(1:N-1).  It is zero, apart from on the first row 
%   (which contains the A(I)) and the first subdiagonal (which contains
%   the B(I)).  For a valid model, the A(I) are nonnegative and the
%   B(I) are positive and bounded by 1.
%
%   GALLERY('LESLIE',N) generates the Leslie matrix with A = ONES(N,1),
%   B = ONES(N-1,1).

%   References:
%   [1] M. R. Cullen, Linear Models in Biology, Ellis Horwood,
%       Chichester, UK, 1985.
%   [2] H. Anton and C. Rorres, Elementary Linear Algebra: Applications
%       Version, eighth edition, Wiley, New York, 2000, Sec. 11.18.
%
%   Nicholas J. Higham
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/05/19 11:16:09 $

if nargin == 1
   n = a;
   a = ones(n,1);
   b = ones(n-1,1);
end

if length(a) ~= length(b) + 1 
  error('MATLAB:leslie:ArgSize', 'Arguments have invalid dimensions.') 
end

L = diag(b,-1);
L(1,:) = a(:)';
