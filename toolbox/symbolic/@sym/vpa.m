function r = vpa(s,d)
%VPA    Variable precision arithmetic.
%   R = VPA(S) numerically evaluates each element of S using variable
%   precision floating point arithmetic with D decimal digit accuracy,
%   where D is the current setting of DIGITS. R is a SYM.
%
%   VPA(S,D) uses D digits, instead of the current setting of DIGITS.
%   D is an integer or the SYM representation of a number.
%
%   Examples:
%      phi = sym('(1+sqrt(5))/2');      % phi is the "golden ratio".
%      vpa(phi,75) is a string containing 75 digits of phi.
%
%      vpa(sym(pi),1919)                  is a screen full of pi.
%      vpa(sym('exp(pi*sqrt(163))'),36)   shows an "almost integer".
%
%      vpa(sym(hilb(2)),5) returns
%      [    1., .50000]
%      [.50000, .33333]
%
%   See also DOUBLE, DIGITS.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:10:42 $


if nargin < 2
   s = sym(s);
   d = digits;
end;

r = maple('evalf',s,d);
