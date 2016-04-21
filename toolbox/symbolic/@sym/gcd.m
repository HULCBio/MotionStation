function [g,c,d] = gcd(a,b,x)
%GCD    Greatest common divisor.
%   G = GCD(A,B) is the symbolic greatest common divisor of A and B.
%   G = GCD(A,B,X) uses variable X instead of FINDSYM(A,1).
%   [G,C,D] = GCD(A,B,...) also returns C and D so that G = A*C + B*D.
%
%   Example:
%      syms x
%      gcd(x^3-3*x^2+3*x-1,x^2-5*x+4) 
%      returns x-1
%
%   See also LCM.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/16 22:22:32 $
 
a = sym(a);
b = sym(b);
if nargin < 3
   x = findsym(a,1);
   if ~isequal(x,findsym(b,1))
      error('symbolic:sym:gcd:errmsg1','Cannot identify default symbolic variable.')
   end
end
if isempty(x)
   g = maple('gcd',a,b,'''c''','''d''');
else
   g = maple('gcdex',a,b,x,'''c''','''d''');
end
c = sym(maple('c'));
d = sym(maple('d'));
maple('c := ''c''');
maple('d := ''d''');
