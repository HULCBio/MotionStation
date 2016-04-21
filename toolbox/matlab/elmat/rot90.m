function B = rot90(A,k)
%ROT90  Rotate matrix 90 degrees.
%   ROT90(A) is the 90 degree counterclockwise rotation of matrix A.
%   ROT90(A,K) is the K*90 degree rotation of A, K = +-1,+-2,...
%
%   Example,
%       A = [1 2 3      B = rot90(A) = [ 3 6
%            4 5 6 ]                     2 5
%                                        1 4 ]
%
%   See also FLIPUD, FLIPLR, FLIPDIM.

%   From John de Pillis 19 June 1985
%   Modified 12-19-91, LS.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.11.4.1 $  $Date: 2003/05/01 20:41:57 $

if ndims(A)~=2 
  error('MATLAB:rot90:SizeA', 'A must be a 2-D matrix.'); 
end
[m,n] = size(A);
if nargin == 1
    k = 1;
else
    if length(k)~=1 
      error('MATLAB:rot90:kNonScalar', 'k must be a scalar.'); 
    end
    k = rem(k,4);
    if k < 0
        k = k + 4;
    end
end
if k == 1
    A = A.';
    B = A(n:-1:1,:);
elseif k == 2
    B = A(m:-1:1,n:-1:1);
elseif k == 3
    B = A(m:-1:1,:);
    B = B.';
else
    B = A;
end
