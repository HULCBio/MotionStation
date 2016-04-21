function [Q,R] = quorem(A,B,x)
%QUOREM Symbolic matrix element-wise quotient and remainder.
%   [Q,R] = QUOREM(A,B) for symbolic matrices A and B with integer or
%   polynomial elements does element-wise division of A by B and returns 
%   quotient Q and remainder R so that A = Q.*B+R.
%   For polynomials, QUOREM(A,B,x) uses variable x instead of findsym(A,1)
%   or findsym(B,1).
%
%   Example:
%      syms x
%      p = x^3-2*x+5
%      [q,r] = quorem(x^5,p)
%         q = x^2+2
%         r = -5*x^2-10+4*x
%      [q,r] = quorem(10^5,subs(p,'10'))
%         q = 101
%         r = 515
%
%   See also MOD, RDIVIDE, LDIVIDE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:23:03 $

A = sym(A);
B = sym(B);
if nargin < 3
   x = findsym(A,1);
   if isempty(x)
      x = findsym(B,1);
   end
end
if isempty(x)
   if all(size(B) == 1)
      B = B(ones(size(A)));
   elseif all(size(A) == 1)
      A = A(ones(size(B)));
   end
   if ~isequal(size(A),size(B));
      error('symbolic:sym:quorem:errmsg1','Array dimensions must agree.')
   end
   Q = A;
   R = A;
   for k = 1:prod(size(A))
      Q(k) = maple('iquo',A(k),B(k),'''_ans''');
      R(k) = maple('_ans');
   end
   maple('_ans := ''_ans''');
else
   if all(size(B) == 1)
      B = B(ones(size(A)));
   elseif all(size(A) == 1)
      A = A(ones(size(B)));
   end
   if ~isequal(size(A),size(B));
      error('symbolic:sym:quorem:errmsg1','Array dimensions must agree.')
   end
   Q = A;
   R = A;
   for k = 1:prod(size(A))
      Q(k) = maple('quo',A(k),B(k),x,'''_ans''');
      R(k) = maple('_ans');
   end
   maple('_ans := ''_ans''');
end
