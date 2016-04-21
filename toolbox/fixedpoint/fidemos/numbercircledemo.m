%% Number Circle 
% Illustrates the definitions of unsigned and signed two's complement
% integer and fixed-point numbers

%% Fixed-point number definitions
%
% This demo illustrates the definitions of unsigned and signed-two's-complement
% integer and fixed-point numbers.

%% Unsigned integers.
%
% Unsigned integers are represented in the binary number system in the
% following way.  Let
%
%   b = [b(n) b(n-1) ... b(2) b(1)]
%
% be the binary digits of an n-bit unsigned integer, where each b(i) is
% either one or zero.  Then the value of b is
%
%   u = b(n)*2^(n-1) + b(n-1)*2^(n-2) + ... + b(2)*2^(1) + b(1)*2^(0)
%
% For example, let's define a 3-bit unsigned integer quantizer, and
% enumerate its range.
q = quantizer('ufixed',[3 0]);
[a,b] = range(q);
u = (a:eps(q):b)'

% Now, let's display those values in binary.
b = num2bin(q,u)

%% Unsigned integer number circle.
%
% Let's array them around a clock face with their corresponding binary and
% decimal values.
numbercircle(q);

%% Unsigned fixed-point.
%
% Unsigned fixed-point values are unsigned integers that are scaled by a
% power of two.  We call the negative exponent of the power of two the
% "fractionlength".
%
% If the unsigned integer u is defined as before, and the fractionlength is
% f, then the value of the unsigned fixed-point number is
%
%    uf = u*2^-f
%
% For example, let's define a 3-bit unsigned fixed-point quantizer with a
% fractionlength of 1, and enumerate its range.
q = quantizer('ufixed',[3 1]);
[a,b] = range(q);
uf = (a:eps(q):b)'

% Now, let's display those values in binary.
b = num2bin(q,uf)

%% Unsigned fixed-point number circle.
%
% Let's array them around a clock face with their corresponding binary and
% decimal values.
numbercircle(q);

%% Unsigned fractional fixed-point.
%
% Unsigned fractional fixed-point numbers are fixed-point numbers whos
% fractionlength f is equal to the wordlength n, which produces a scaling such
% that the range of numbers is between 0 and 1-2^-f, inclusive.  This is the
% most common form of fixed-point numbers because it has the nice property that
% all of the numbers are less than one, and the product of two numbers less than
% one is a number less than one, and so multiplication does not overflow.
%
% Thus, the definition of unsigned fractional fixed-point is the same as
% unsigned fixed-point, with the restriction that f=n, where n is the
% wordlength in bits.
%
%    uf = u*2^-f
%
% For example, let's define a 3-bit unsigned fractional fixed-point
% quantizer, which implies a fractionlength of 3.

q = quantizer('ufixed',[3 3]);
[a,b] = range(q);
uf = (a:eps(q):b)'

% Now, let's display those values in binary.
b = num2bin(q,uf)

%% Unsigned fractional fixed-point number circle.
%
% Let's array them around a clock face with their corresponding binary and
% decimal values.
numbercircle(q);

%% Signed two's-complement integers.
%
% Signed integers are represented in two's-complement in the binary number
% system in the following way.  Let
%
%   b = [b(n) b(n-1) ... b(2) b(1)]
%
% be the binary digits of an n-bit signed integer, where each b(i) is
% either one or zero.  Then the value of b is
%
%   s = -b(n)*2^(n-1) + b(n-1)*2^(n-2) + ... + b(2)*2^(1) + b(1)*2^(0)
%
% Note that the difference between this and the unsigned number is the
% negative weight on the most-significant-bit (MSB).
%
% For example, let's define a 3-bit signed integer quantizer, and
% enumerate its range.
q = quantizer('fixed',[3 0]);
[a,b] = range(q);
s = (a:eps(q):b)'

% Now, let's display those values in binary.
b = num2bin(q,s)

% Note that the most-significant-bit of negative numbers is 1, and positive
% numbers is 0.

%% Signed two's complement integer number circle.
%
% Let's array them around a clock face with their corresponding binary and
% decimal values.
%
% The reason for this ungainly looking definition of negative numbers is that
% addition of all numbers, both positive and negative, is carried out as if they
% were all positive, and then the n+1 carry bit is discarded.  The result
% will be correct if there is no overflow.  
numbercircle(q);

%% Signed fixed-point.
%
% Signed fixed-point values are signed integers that are scaled by a
% power of two.  We call the negative exponent of the power of two the
% "fractionlength".
%
% If the signed integer s is defined as before, and the fractionlength is
% f, then the value of the signed fixed-point number is
%
%    sf = s*2^-f
%
% For example, let's define a 3-bit signed fixed-point quantizer with a
% fractionlength of 1, and enumerate its range.
q = quantizer('fixed',[3 1]);
[a,b] = range(q);
sf = (a:eps(q):b)'

% Now, let's display those values in binary.
b = num2bin(q,sf)

%% Signed fixed-point number circle.
%
% Let's array them around a clock face with their corresponding binary and
% decimal values.
numbercircle(q);

%% Signed fractional fixed-point.
%
% Signed fractional fixed-point numbers are fixed-point numbers whos
% fractionlength f is one less than the wordlength n, which produces a
% scaling such that the range of numbers is between -1 and 1-2^-f, inclusive.
% This is the most common form of fixed-point numbers because it has the nice
% property that the product of two numbers less than one is a number less
% than one, and so multiplication does not overflow.  The only exception is
% the case when we are multiplying -1 by -1, because +1 is not an element of
% this number system.  Some processors have a special multiplication
% instruction for this situation, and some add an extra bit in the product to
% guard against this overflow.
%
% Thus, the definition of signed fractional fixed-point is the same as
% signed fixed-point, with the restriction that f=n-1, where n is the
% wordlength in bits.
%
%    sf = s*2^-f
%
% For example, let's define a 3-bit signed fractional fixed-point
% quantizer, which implies a fractionlength of 2.

q = quantizer('fixed',[3 2]);
[a,b] = range(q);
sf = (a:eps(q):b)'

% Now, let's display those values in binary.
b = num2bin(q,sf)

%% Signed fractional fixed-point number circle.
%
% Let's array them around a clock face with their corresponding binary and
% decimal values.
numbercircle(q);

%%
% Copyright 1999-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
