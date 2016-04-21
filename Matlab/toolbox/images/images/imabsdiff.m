function Z = imabsdiff(varargin)
%IMABSDIFF Compute absolute difference of two images.
%   Z = IMABSDIFF(X,Y) subtracts each element in array Y from the
%   corresponding element in array X and returns the absolute difference in
%   the corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays with the same class and size.  Z
%   has the same class and size as X and Y.  If X and Y are integer
%   arrays, elements in the output that exceed the range of the integer
%   type are truncated.
%
%   If X and Y are double arrays, you can use the expression ABS(X-Y)
%   instead of this function.  If X and Y are logical arrays, you can use
%   the expression XOR(A,B) instead of this function.
%
%   Notes
%   -----
%   On Intel Architecture processors, IMABSDIFF can take advantage of 
%   the Intel Performance Primitives Library (IPPL), thus accelerating
%   its execution time. IPPL is activated only if arrays X, Y and Z are
%   logical, uint8 or single and are of the same class.
%
%   Example
%   -------
%   Display the absolute difference between a filtered image and the
%   original.
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imabsdiff(I,J);
%       imview(K,[])
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT, IPPL.  

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2003/05/03 17:50:39 $

Z = imabsdiffmex(varargin{:});

