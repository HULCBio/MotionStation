function [num,den] = ss2tfm(a,b,c,d,iu)
%
% Purpose:  To obtain the transfer function of a particular
%           state space representation (one input at a time)
%
% Usage  :  [Num,Den] = ss2tfm(A,B,C,D,iu)
%           Num is a matrix containing as many rows as there are outputs
%           Den is the denominator polynomial
%           The state space system is given by:
%              x(k+1) = A*x(k) + B*u(k)
%              y(k)   = C*x(k) + D*u(k)
%           iu is the input to be used.  The transfer function can
%           only be computed between the outputs and one input at a
%           time due to MATLAB limitations
%
% For reference on the formula used see Kailath's "Linear Systems"
% page 651.
%

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

error(abcdchkm(a,b,c,d));

[ny,n]=size(c);
[ny,nu]=size(d);
if iu <= 0 | iu > nu
   error('IU is <= 0 or greater than number of inputs in system');
end

if n == 0
   num=d(:,iu);
   den=1;
   return
end

den = poly(a);

for i = 1:ny
  num(i,:) = poly(a-b(:,iu)*c(i,:)) - den + d(i,iu)*den;
end