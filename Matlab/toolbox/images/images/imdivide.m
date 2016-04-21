function Z = imdivide(X,Y)
%IMDIVIDE Divide two images, or divide image by constant.
%   Z = IMDIVIDE(X,Y) divides each element in the array X by the
%   corresponding element in array Y and returns the result in the
%   corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays with the same size and class, or
%   Y can be a scalar double.  Z has the same size and class as X and Y
%   unless X is logical, in which case Z is double.
%
%   If X is an integer array, elements in the output that exceed the
%   range of integer type are truncated, and fractional values are
%   rounded.
%
%   If X and Y are both double arrays or if one of them is double and the 
%   other is logical, you can use the expression X ./ Y instead of this 
%   function.
%
%   Notes
%   -----
%   On Intel Architecture processors, IMDIVIDE can take advantage of 
%   the Intel Performance Primitives Library (IPPL), thus accelerating
%   its execution time. IPPL is activated only if arrays X and Y are
%   uint8, int16 or single and are of the same size and class.
%
%   Example
%   -------
%   Estimate and divide out the background of the rice image:
%
%       I = imread('rice.png');
%       background = imopen(I,strel('disk',15));
%       Ip = imdivide(I,background);
%       imview(Ip,[])
%
%   Divide an image by a constant factor:
%
%       I = imread('rice.png');
%       J = imdivide(I,2);
%       imview(I)
%       imview(J)
%
%   See also IMADD, IMCOMPLEMENT, IMLINCOMB, IMMULTIPLY, IMSUBTRACT, IPPL. 

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.6 $  $Date: 2003/08/23 05:52:27 $

checknargin(2,2,nargin,mfilename);

if (numel(Y) == 1) && strcmp(class(Y), 'double')
    Z = imlincomb(1/Y, X);
else
  checkinput(X, {'numeric','logical'}, 'real', mfilename, 'X', 1);
  checkinput(Y, {'numeric','logical'}, 'real', mfilename, 'Y', 2);
  Z = imdivmex(X, Y);
end


