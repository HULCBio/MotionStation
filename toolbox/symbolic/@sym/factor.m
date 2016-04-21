function f = factor(x)
%FACTOR Symbolic factorization.
%   FACTOR(S), where S is a SYM matrix, factors each element of S.
%   If S contains all integer elements, the prime factorization is computed.
%   To factor integers greater than 2^52, use FACTOR(SYM('N')).
%
%   Examples:
%
%      factor(x^9-1) is 
%      (x-1)*(x^2+x+1)*(x^6+x^3+1)
%
%      factor(sym('12345678901234567890')) is
%      (2)*(3)^2*(5)*(101)*(3803)*(3607)*(27961)*(3541)
%
%   See also FACTOR, SIMPLIFY, EXPAND, SIMPLE, COLLECT.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:22:26 $

% Try the integer factorization first.
% If it fails, try the symbolic expression factorization.

siz = size(x);
[f, stat] = maple('map','ifactor',x(:));
if (stat == 2) & strcmp('Error, (in ifactor) invalid arguments',f)
   f = maple('map','factor',x(:));
elseif stat == 2
   error('symbolic:sym:factor:errmsg1',f);
end
f = reshape(f,siz);
