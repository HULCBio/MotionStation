function y = flipud(x)
%FLIPUD Flip matrix in up/down direction.
%   FLIPUD(X) returns X with columns preserved and rows flipped
%   in the up/down direction.  For example,
%   
%   X = 1 4      becomes  3 6
%       2 5               2 5
%       3 6               1 4
%
%   See also FLIPLR, ROT90, FLIPDIM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2003/10/21 11:55:32 $

if ndims(x)~=2 
  error('MATLAB:flipud:SizeX', 'X must be a 2-D matrix.'); 
end
y = x(end:-1:1,:);
