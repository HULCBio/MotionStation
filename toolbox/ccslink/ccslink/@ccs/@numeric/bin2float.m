function y = bin2float(nn,str,bin)
%BIN2FLOAT  Binary string to floating-point.
%
%   Y = BIN2FLOAT(STR,B) converts a single- or double-precision floating-point
%   number in binary string B to the numerical equivalent in numeric array Y.
%   The string STR should be either 'single' or 'double'.
%
%   It is assumed that B is a string array of equal length rows in binary
%   format in a single "vector" of numbers with no leading or trailing
%   blanks.  No error checking is done.
%
%   If there are fewer digits than necessary to represent the number, then
%   the string is zero-padded on the left.
%
%   Example:
%     x = '01000000010010010000111111011010';
%     y = bin2float('single',x)


%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.2 $ $Date: 2003/11/30 23:09:34 $



switch str
	case 'double',
        if any(strcmp(nn.procsubfamily,{'C6x','R1x','R2x'})) 
    		wordlength     = 64;
    		exponentlength = 11;
    		fractionlength = 52;
    		exponentbias   = 1023;
    		exponentmin    = -1022;
    		exponentmax    = 1023;
        elseif any(strcmp(nn.procsubfamily,{'C54x','C55x','C28x'})),
			wordlength     = 32;
			exponentlength = 8;
			fractionlength = 23;
			exponentbias   = 127;
			exponentmin    = -126;
			exponentmax    = 127;
        end
	case 'single',
		wordlength     = 32;
		exponentlength = 8;
		fractionlength = 23;
		exponentbias   = 127;
		exponentmin    = -126;
		exponentmax    = 127;
	otherwise
		error('Unrecongnized option.');
end

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
  bin = [bin,o(ones(mbin,1),ones(w-nbin,1))];
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

% [EOF] bin2float.m