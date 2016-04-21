function Z = immultiply(X,Y)
%IMMULTIPLY Multiply two images, or multiply image by constant.  Z =
%   IMMULTIPLY(X,Y) multiplies each element in the array X by the
%   corresponding element in the array Y and returns the product in the
%   corresponding element of the output array Z.
%   
%   If X and Y are real numeric arrays with the same size and class, then
%   Z has the same size and class as X.  If X is a numeric array and Y is
%   a scalar double, then Z has the same size and class as X.
%
%   If X is logical and Y is numeric, then Z has the same size and class
%   as Y.  If X is numeric and Y is logical, then Z has the same size and
%   class as X.
%
%   IMMULTIPLY computes each element of Z individually in
%   double-precision floating point.  If X is an integer array, then
%   elements of Z exceeding the range of the integer type are truncated,
%   and fractional values are rounded.
%
%   If X and Y are double arrays, you can use the expression X.*Y instead
%   of this function.
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
%   Multiply two uint8 images with the result stored in a uint16 image:
%
%       I = imread('moon.tif');
%       I16 = uint16(I);
%       J = immultiply(I16,I16);
%       imview(I), imview(J)
%
%   Scale an image by a constant factor:
%
%       I = imread('moon.tif');
%       J = immultiply(I,0.5);
%       imview(I), imview(J)
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT, IPPL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2003/08/23 05:52:36 $

checknargin(2,2,nargin,mfilename);

checkinput(X, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, 'X', 1);
checkinput(Y, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, 'Y', 1);

if (islogical(X) || islogical(Y)) && ~isequal(size(X), size(Y))
    eid = 'Images:immultiply:logicalInputSizeMismatch';
    msg = 'If either X or Y is logical, then X and Y must be the same size.';
    error(eid,'%s',msg);
end

if islogical(X) && islogical(Y)
    Z = X & Y;
    
elseif islogical(X) && isnumeric(Y)
    Z = Y;
    Z(~X) = 0;
    
elseif isnumeric(X) && islogical(Y)
    Z = X;
    Z(~Y) = 0;
    
else
    % X and Y must both be numeric.

    if (numel(Y) == 1) && strcmp(class(Y), 'double')
        Z = imlincomb(Y, X);
    else
        Z = immultmex(X, Y);
    end
end



