function [m,v]= fstat(v1,v2);
%FSTAT  Mean and variance for the F distribution.
%   [M,V] = FSTAT(V1,V2) returns the mean (M) and variance (V)
%   of the F distribution with V1 and V2 degrees of freedom.
%   Note that the mean of the F distribution is undefined if V1 
%   is less than 3. The variance is undefined for V2 less than 5.

%   References:
%      [1]  W. H. Beyer, "CRC Standard Probability and Statistics",
%      CRC Press, Boston, 1991, page 23.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.2 $  $Date: 2004/01/24 09:33:49 $

if nargin < 2, 
    error('stats:fstat:TooFewInputs','Requires two input arguments.'); 
end

[errorcode v1 v2] = distchck(2,v1,v2);

if errorcode > 0
    error('stats:fstat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

%   Initialize the M and V to zero.
m = zeros(size(v1));
v = zeros(size(v2));

k = find(v1 <= 0 | v2 <= 0);
if any(k(:))
    m(k) = NaN;
    v(k) = NaN;
end

k = find(v2 > 2 & v1 > 0);
if any(k)
    m(k) = v2(k) ./ (v2(k) - 2);
end

% The mean is undefined for V2 less than or equal to 2.
k1 = find(v2 <= 2);
if any(k1(:))
    m(k1) = NaN;
end

k = find(v2 > 4 & v1 > 0);
if any(k(:))
    v(k) = m(k) .^ 2 * 2 .* (v1(k) + v2(k) - 2) ./ (v1(k) .* (v2(k) - 4));
end

% The variance is undefined for V2 less than or equal to 4.
k2 = find(v2 <= 4);
if any(k2(:))
    v(k2) = NaN;
end
