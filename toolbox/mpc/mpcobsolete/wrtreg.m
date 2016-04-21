function [xreg,yreg] = wrtreg(x,y,n);
%WRTREG	Write regression input and output
%	[xreg,yreg] = wrtreg(x,y,n)
% WRTREG writes regression input and output to be used by regression
% routines in determining the impulse response coefficients. yreg is
% produced by deleting the first n rows of y, while x is shifted
% diagonally to produce xreg.
%
% Inputs:
%  x,y: input matrix and output vector.
%    n: number of impulse response coefficients for all inputs.
%
% Outputs:
%   xreg&yreg:  input matrix and output vector to be used by routines such
%               as pls and mlr.
%
% See also MLR, PLSR.
%
% Note: Standard single sampling delay is assumed for all inputs.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage: [xreg,yreg] = wrtreg(x,y,n)')
   return
end
[nrx,ncx] = size(x);
[nry,ncy] = size(y);
if nrx ~= nry
   error('Number of rows for input and output must be same!');
   return;
end
if n >= nrx
   error('Number of rows in input must be larger than n!');
   return;
end
if ncy > 1
   error('Only one output is allowed')
end
xreg = zeros(nrx-n,ncx*n);
for i = 1:ncx
   for j = 1:n
      xreg(:,(i-1)*n+j) = x(n-j+1:nrx-j,i);
   end
end
yreg = y(n+1:nrx,:);

%  End of function wrtreg.
