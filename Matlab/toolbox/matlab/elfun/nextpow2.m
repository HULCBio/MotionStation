function p = nextpow2(n)
%NEXTPOW2 Next higher power of 2.
%   NEXTPOW2(N) returns the first P such that 2^P >= abs(N).  It is
%   often useful for finding the nearest power of two sequence
%   length for FFT operations.
%   NEXTPOW2(X), if X is a vector, is the same as NEXTPOW2(LENGTH(X)).
%
%   See also LOG2, POW2.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11 $  $Date: 2002/04/15 03:38:34 $

if length(n) > 1
    n = length(n);
end

[f,p] = log2(abs(n));

% Check if n is an exact power of 2.
if ~isempty(f) & f == 0.5
    p = p-1;
end

% Check for infinities and NaNs
k = ~isfinite(f);
p(k) = f(k);
