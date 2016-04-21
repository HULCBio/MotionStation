function Z = imadd(X,Y,output_class)
%IMADD Add two images, or add constant to image.
%   Z = IMADD(X,Y) adds each element in array X to the corresponding      
%   element in array Y and returns the sum in the corresponding element
%   of the output array Z.  X and Y are real, nonsparse, numeric arrays
%   or logical arrays with the same size and class, or Y is a scalar
%   double.  Z has the same size and class as X unless X is logical, in
%   which case Z is double.
%
%   Z = IMADD(X,Y,OUTPUT_CLASS) specifies the desired output class of Z.
%   OUTPUT_CLASS must be one of the following strings: 'uint8', 'uint16',
%   'uint32', 'int8', 'int16', and 'int32', 'single, 'double'.
%
%   If Z is an integer array, then elements in the output that exceed the
%   range of the integer type are truncated, and fractional values are
%   rounded.
%
%   If X and Y are double or logical arrays, you can use the expression
%   X+Y instead of this function.
%
%   Notes
%   -----
%   On Intel Architecture processors, IMADD can take advantage of 
%   the Intel Performance Primitives Library (IPPL), thus accelerating
%   its execution time. IPPL is activated in two cases:
%     - arrays X, Y and Z are uint8, int16, or single and are 
%       of the same class
%     - Y is a double scalar and arrays X and Z are uint8, int16
%       or single and are of the same class.
%
%   Example 1
%   ---------
%   Add two images together:
%
%       I = imread('rice.png');
%       J = imread('cameraman.tif');
%       K = imadd(I,J);
%       imview(K)
%
%   Example 2
%   ---------
%   Add two images together and specify an output class:
%
%       I = imread('rice.png');
%       J = imread('cameraman.tif');
%       K = imadd(I,J,'uint16');
%       imview(K,[])
%
%   Example 3
%   ---------
%   Add a constant to an image:
%
%       I = imread('rice.png');
%       Iplus50 = imadd(I,50);
%       imview(I), imview(Iplus50)
%
%   See also IMABSDIFF, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMMULTIPLY, 
%            IMSUBTRACT, IPPL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2003/05/03 17:50:40 $

checknargin(2, 3, nargin, mfilename);

if (nargin < 3)
    if islogical(X)
        output_class = 'double';
    else
        output_class = class(X);
    end
else
    valid_strings = {'uint8' 'uint16' 'uint32' 'int8' 'int16' 'int32' ...
                     'single' 'double'};
    output_class = checkstrs(output_class, valid_strings, mfilename, ...
                             'OUTPUT_CLASS', 3);
end

if (prod(size(Y)) == 1) & isa(Y, 'double')
    Z = imlincomb(1.0, X, Y, output_class);
else
    Z = imlincomb(1.0, X, 1.0, Y, output_class);
end
