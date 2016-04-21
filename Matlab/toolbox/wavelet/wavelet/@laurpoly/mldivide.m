function [Q,R] = mldivide(A,B)
%MLDIVIDE Laurent polynomial left division.
%   MLDIVIDE(A,B) overloads Laurent polynomial A \ B.
%   [Q,R] = mldivide(A,B) returns two Laurent polynomial Q and R
%   such that A = B*Q + R.
%   Among all possible euclidian divisions of A by B, MLDIVIDE returns
%   the one which has the remainder R with the highest degree.
%   
%   Example:
%     A = laurpoly([1 3 1],2);
%     B = laurpoly([1 1],1);
%     [Q,R] = mldivide(A,B);
%     ---------------------------------------------
%     A(z) = z^(+2) + 3*z^(+1) + 1
%     B(z) = z^(+1) + 1
%     [Q,R] = mldivide(A,B) returns 
%        Q(z) = 2*z^(+1) + 1  and  R(z) = - z^(+2)
%     ---------------------------------------------
%
%   See also EUCLIDEDIV, MRDIVIDE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:38:53 $

DEC = euclidediv(A,B);
[Q,R] = deal(DEC{end,:});
