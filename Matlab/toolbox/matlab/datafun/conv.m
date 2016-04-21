function c = conv(a, b)
%CONV Convolution and polynomial multiplication.
%   C = CONV(A, B) convolves vectors A and B.  The resulting
%   vector is length LENGTH(A)+LENGTH(B)-1.
%   If A and B are vectors of polynomial coefficients, convolving
%   them is equivalent to multiplying the two polynomials.
%
%   Class support for inputs A,B: 
%      float: double, single
%
%   See also DECONV, CONV2, CONVN, FILTER and, in the Signal
%   Processing Toolbox, XCORR, CONVMTX.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.16.4.2 $  $Date: 2004/03/09 16:16:08 $

na = length(a);
nb = length(b);

if na ~= numel(a) || nb ~= numel(b)
  error('MATLAB:conv:AorBNotVector', 'A and B must be vectors.');
end

% Convolution, polynomial multiplication, and FIR digital
% filtering are all the same operations.  Since FILTER
% is a fast built-in primitive, we'll use it for CONV.

% CONV(A,B) is the same as CONV(B,A), but we can make it go
% substantially faster if we swap arguments to make the first
% argument to filter the shorter of the two.
if na > nb
    if nb > 1
        a(na+nb-1) = 0;
    end
    c = filter(b, 1, a);
else
    if na > 1
        b(na+nb-1) = 0;
    end
    c = filter(a, 1, b);
end
