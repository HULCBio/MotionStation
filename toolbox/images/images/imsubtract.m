function Z = imsubtract(X,Y)
%IMSUBTRACT Subtract two images, or subtract constant from image.
%   Z = IMSUBTRACT(X,Y) subtracts each element in array Y from the
%   corresponding element in array X and returns the difference in the
%   corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays of the same size and class, or Y
%   is a double scalar.  The output array, Z, has the same size and class
%   as X unless X is logical, in which case Z is double. 
%
%   If X is an integer array, then elements of the output that exceed the
%   range of the integer type are truncated, and fractional values are
%   rounded.
%
%   If X and Y are double or logical arrays, then you can use the
%   expression X - Y instead of this function.
%
%   Notes
%   -----
%   On Intel Architecture processors, IMSUBTRACT can take advantage of 
%   the Intel Performance Primitives Library (IPPL), thus accelerating
%   its execution time. IPPL is activated only if array X is uint8, 
%   int16, or single.
%
%   Example
%   -------
%   Estimate and subtract the background of the rice image:
%       I = imread('rice.png');
%       background = imopen(I,strel('disk',15));
%       Ip = imsubtract(I,background);
%       imview(I), imview(Ip,[])
%
%   Subtract a constant value from the rice image:
%       I = imread('rice.png');
%       Iq = imsubtract(I,50);
%       imview(I), imview(Iq)
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMMULTIPLY, IPPL.

%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.9.4.6 $  $Date: 2003/08/23 05:52:45 $

error(nargchk(2,2,nargin,'struct'))

if (numel(Y) == 1) && strcmp(class(Y),'double')
    Z = imlincomb(1.0, X, -Y);
else
    Z = imlincomb(1.0, X, -1.0, Y);
end

