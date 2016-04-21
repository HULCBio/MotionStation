function Z = imlincomb(varargin)
%IMLINCOMB Compute linear combination of images.
%   Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An) computes K1*A1 + K2*A2 + ... +
%   Kn*An.  A1, A2, ..., An are real, nonsparse, numeric arrays with the
%   same class and size, and K1, K2, ..., Kn are real double scalars.  Z
%   has the same size and class as A1 unless A1 is logical, in which case
%   Z is double.
%
%   Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An,K) computes K1*A1 + K2*A2 +
%   ... + Kn*An + K.
%
%   Z = IMLINCOMB(..., OUTPUT_CLASS) lets you specify the class of Z.
%   OUTPUT_CLASS is a string containing the name of a numeric class.
%
%   Use IMLINCOMB to perform a series of arithmetic operations on a pair
%   of images, rather than nesting calls to individual arithmetic
%   functions, such as IMADD and IMMULTIPLY.  When you nest calls to the
%   arithmetic functions, and the input arrays have integer class,then
%   each function truncates and rounds the result before passing it to
%   the next function, thus losing accuracy in the final result.
%   IMLINCOMB performs all the arithmetic operations at once before
%   truncating and rounding the final result.
%
%   Each element of the output, Z, is computed individually in
%   double-precision floating point.  When Z is an integer array, elements
%   of Z that exceed the range of the integer type are truncated, and
%   fractional values are rounded.
%
%   Notes
%   -----
%   On Intel Architecture processors, IMLINCOMB can take advantage of 
%   the Intel Performance Primitives Library (IPPL), thus accelerating
%   its execution time. IPPL is activated in the following cases:
%     - Z = IMLINCOMB( 1.0, A1, 1.0, A2)
%     - Z = IMLINCOMB( 1.0, A1,-1.0, A2)
%     - Z = IMLINCOMB(-1.0, A1, 1.0, A2)
%     - Z = IMLINCOMB( 1.0 ,A1, K)
%   where A1, A2 and Z are uint8, int16 or single and are of the 
%   same class.
%
%   Example 1
%   ---------
%   Scale an image by a factor of two.
%
%       I = imread('cameraman.tif');
%       J = imlincomb(2,I);
%       imview(J)
%
%   Example 2
%   ---------
%   Form a difference image with the zero value shifted to 128.
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imlincomb(1,I,-1,J,128); % K(r,c) = I(r,c) - J(r,c) + 128
%       imview(K)
%
%   Example 3
%   ---------
%   Add two images with a specified output class.
%
%       I = imread('rice.png');
%       J = imread('cameraman.tif');
%       K = imlincomb(1,I,1,J,'uint16');
%       imview(K,[])
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMMULTIPLY, IMSUBTRACT, IPPL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.5 $  $Date: 2003/08/23 05:52:34 $

% I/O spec
% ========
% A1, ...       Real, numeric, full arrays
%               Logical arrays also allowed, and are converted to uint8.
%
% K1, ...       Real, double scalars
%
% OUTPUT_CLASS  Case-insensitive nonambiguous abbreviation of one of
%               these strings: uint8, uint16, uint32, int8, int16, int32,
%               single, double

[images, scalars, output_class] = ParseInputs(varargin{:});

Z = imlincombc(images, scalars, output_class);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [images, scalars, output_class] = ParseInputs(varargin)
  
checknargin(2, Inf, nargin, mfilename);

if ischar(varargin{end})
  valid_strings = {'uint8' 'uint16' 'uint32' 'int8' 'int16' 'int32' ...
                   'single' 'double'};
  output_class = checkstrs(varargin{end}, valid_strings, mfilename, ...
                           'OUTPUT_CLASS', 3);
  varargin(end) = [];
else
  if islogical(varargin{2})
    output_class = 'double';
  else
    output_class = class(varargin{2});
  end
end

%check images
images = varargin(2:2:end);
if ~iscell(images) || isempty(images)
  displayInternalError('images');
end


% assign and check scalars
for p = 1:2:length(varargin)
  checkinput(varargin{p}, 'double', 'real nonsparse scalar', ...
             mfilename, sprintf('K%d', (p+1)/2), p);
end
scalars = [varargin{1:2:end}];

%make sure it is a vector
if ( ndims(scalars)~=2 || (all(size(scalars)~=1) && any(size(scalars)~=0)) )
  displayInternalError('scalars');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayInternalError(string)

eid = sprintf('Images:%s:internalError',mfilename);
msg = sprintf('Internal error: %s is not valid.',upper(string));
error(eid,'%s',msg);
