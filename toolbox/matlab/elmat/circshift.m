function b = circshift(a,p)
%CIRCSHIFT Shift array circularly.
%   B = CIRCSHIFT(A,SHIFTSIZE) circularly shifts the values in the array A
%   by SHIFTSIZE elements. SHIFTSIZE is a vector of integer scalars where
%   the N-th element specifies the shift amount for the N-th dimension of
%   array A. If an element in SHIFTSIZE is positive, the values of A are
%   shifted down (or to the right). If it is negative, the values of A
%   are shifted up (or to the left). 
%
%   Examples:
%      A = [ 1 2 3;4 5 6; 7 8 9];
%      B = circshift(A,1) % circularly shifts first dimension values down by 1.
%      B =     7     8     9
%              1     2     3
%              4     5     6
%      B = circshift(A,[1 -1]) % circularly shifts first dimension values
%                              % down by 1 and second dimension left by 1.
%      B =     8     9     7
%              2     3     1
%              5     6     4
%
%   See also FFTSHIFT, SHIFTDIM.

%   Copyright 1984-2003 The MathWorks, Inc.  
%   $Revision: 1.11.4.1 $  $Date: 2003/05/01 20:41:28 $

% Error out if there are not exactly two input arguments
if nargin < 2
    error('MATLAB:circshift:NoInputs',['No input arguments specified. ' ...
            'There should be exactly two input arguments.'])
end

% Parse the inputs to reveal the variables necessary for the calculations
[p, sizeA, numDimsA, msg] = ParseInputs(a,p);

% Error out if ParseInputs discovers an improper SHIFTSIZE input
if (~isempty(msg))
    error('MATLAB:circshift:InvalidShiftType','%s',msg);
end

% Calculate the indices that will convert the input matrix to the desired output
% Initialize the cell array of indices
idx = cell(1, numDimsA);

% Loop through each dimension of the input matrix to calculate shifted indices
for k = 1:numDimsA
    m      = sizeA(k);
    idx{k} = mod((0:m-1)-p(k), m)+1;
end

% Perform the actual conversion by indexing into the input matrix
b = a(idx{:});


%%%
%%% Parse inputs
%%%
function [p, sizeA, numDimsA, msg] = ParseInputs(a,p)

% default values
sizeA    = size(a);
numDimsA = ndims(a);
msg      = '';

% Make sure that SHIFTSIZE input is a finite, real integer vector
sh        = p(:);
isFinite  = all(isfinite(sh));
nonSparse = all(~issparse(sh));
isInteger = all(isa(sh,'double') & (imag(sh)==0) & (sh==round(sh)));
isVector  = ((ndims(p) == 2) && ((size(p,1) == 1) || (size(p,2) == 1)));

if ~(isFinite && isInteger && isVector && nonSparse)
    msg = ['Invalid shift type: ' ...
          'must be a finite, nonsparse, real integer vector.'];
    return;
end

% Make sure the shift vector has the same length as numDimsA. 
% The missing shift values are assumed to be 0. The extra 
% shift values are ignored when the shift vector is longer 
% than numDimsA.
if (numel(p) < numDimsA)
   p(numDimsA) = 0;
end

