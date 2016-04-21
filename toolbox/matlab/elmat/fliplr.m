function y = fliplr(x)
%FLIPLR Flip matrix in left/right direction.
%   FLIPLR(X) returns X with row preserved and columns flipped
%   in the left/right direction.
%   
%   X = 1 2 3     becomes  3 2 1
%       4 5 6              6 5 4
%
%   See also FLIPUD, ROT90, FLIPDIM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2003/10/21 11:55:31 $

if ndims(x)~=2 
  error('MATLAB:fliplr:SizeX', 'X must be a 2-D matrix.'); 
end
y = x(:,end:-1:1);
