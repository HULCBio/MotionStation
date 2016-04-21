function [a,x,y] = dspblkdiag(n,q)
% DSPBLKDIAG Signal Processing Blockset Diagonal Matrix block helper function.
%
% q is the diagonal
% n is the number of rows

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:16 $

qlen = length(q);

if qlen==0,
   q = 0;  % treat an empty as a zero
end

if qlen==1,  % scalar
   a=diag(q*ones(1,n));

else
   if n <= qlen,
      qlen=q(1:n);
   else
      qlen = [q(:); zeros(n-qlen,1)];
   end
   a = diag(qlen);
end

% For plotting
x = [0,NaN,100,NaN,[20 10 10 20],NaN,[84 96 96 84],NaN,[20 80]];
y = [0,NaN,100,NaN,[90 90 10 10],NaN,[90 90 10 10],NaN,[80 20]];

% [EOF] dspblkdiag.m
