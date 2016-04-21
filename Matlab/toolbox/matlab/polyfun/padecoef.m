function [a,b] = padecoef(T,n)
%PADECOEF  Pade approximation of time delays.
%
%   [NUM,DEN] = PADECOEF(T,N) returns the Nth-order Pade approximation 
%   of the continuous-time delay exp(-T*s) in transfer function form.
%   The row vectors NUM and DEN contain the polynomial coefficients  
%   in descending powers of s.
%
%   Class support for input T:
%      float: double, single
%
%   See also PADE

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/02 21:47:52 $

%  Reference:  Golub and Van Loan, Matrix Computations, Johns Hopkins
%              University Press, pp. 557ff.

ni = nargin;
no = nargout;
error(nargchk(1,2,ni))
if ni==1,
   n = 1; 
elseif n<0 | T<0,
   error('MATLAB:padecoef:NegativeTorN', 'T and N must be non negative.')
end
n = round(n);

% The coefficients of the Pade approximation are given by the 
% recursion   h[k+1] = (N-k)/(2*N-k)/(k+1) * h[k],  h[0] = 1
% and 
%     exp(-T*s) == Sum { h[k] (-T*s)^k } / Sum { h[k] (T*s)^k }
%
if T>0
   a = zeros(1,n+1,class(T));   a(1) = 1;
   b = zeros(1,n+1,class(T));   b(1) = 1;
   for k = 1:n,
      fact = T*(n-k+1)/(2*n-k+1)/k;
      a(k+1) = (-fact) * a(k);
      b(k+1) = fact * b(k);
   end
   a = fliplr(a/b(n+1));
   b = fliplr(b/b(n+1));
else
   a = ones(class(T));
   b = ones(class(T));
end

% end padecoef
