function y = bin2float(bin)
% private.
% Converts a binary input(in bits) to IEEE single precision representation.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:13:10 $

wordlength     = 32;
exponentlength = 8;
fractionlength = 23;
exponentbias   = 127;
exponentmin    = -126;
exponentmax    = 127;

if isempty(bin)
  y = 0;
  return
end

% Zero pad to the right.
w = wordlength;
[mbin,nbin] = size(bin);
if nbin<w
  % Zero-pad to the right.
  o = '0';
  % bin = [bin,o(ones(mbin,1),ones(w-nbin,1))];
  bin = [o(ones(mbin,1),ones(w-nbin,1)), bin]; % my change - Zero-pad to the left.
end

% Peel off [sign, exponent, fraction]
% Then, each piece is small enough to be a positive integer

% Sign
s = (-1).^bin2dec(bin(:,1));

% Unbiased exponent
e = bin2dec(bin(:,2:exponentlength+1));

% Biased exponent
b = e - exponentbias;

% Fraction
f = pow2(bin2dec(bin(:,exponentlength+2:end)),-fractionlength);

% Initialize the output.  Zero is the default, so 
y = zeros(size(s));

% Denormal
n = e==0 & f~=0;
y(n) = s(n).*pow2(f(n),exponentmin);

% Normal
n = e~=0 & b<=exponentmax;
y(n) = s(n).*pow2(1+f(n),b(n));

% NaN
n = b==exponentmax+1 & f~=0;
y(n) = nan;

% +-inf
n = b==exponentmax+1 & f==0;
y(n) = s(n).*inf;

