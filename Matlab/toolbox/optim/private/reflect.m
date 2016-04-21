function[x,sigma] = reflect(y,u,l)
%REFLECT Reflection transformation
%
%  [x,sigma] = reflect(y,u,l) reflection transformation as
%  described in Coleman and Li ??: x is reflected point, sigma is sign vector
%  corresponding to x. y is current point, u is vector of
%  upper bounds, l is vector of lower bounds.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/02/07 19:13:41 $

% INITIALIZATION
n = length(y);
w = zeros(n,1); 
x = zeros(n,1); 
sigma = zeros(n,1);
%
% Map y to x and compute the sign vector
% sigma according to the Coleman/Li paper ??. 
%
arg1 = (l == 0) & (u == 1); 
arg2 = (l == 0 ) & (u == inf);
arg3 = (l == -inf) & (u == 1);
arg4 = (l == -inf) & (u == inf);

sarg1 = size(arg1(arg1>0)); 
sarg2 = size(arg2(arg2>0));  
sarg3 = size(arg3(arg3>0)); 
sarg4 = size(arg4(arg4>0));

w(arg1)=rem(abs(y(arg1)),2*ones(sarg1)); 
x(arg1)=min(w(arg1),2*ones(sarg1)-w(arg1));
sigma(arg1 & (w <= 2-w))=sign(y(arg1 & (w <= 2-w)));
sigma(arg1 & (w > 2-w))=-sign(y(arg1 & (w > 2-w)));

x(arg2) = abs(y(arg2)); 
sigma(arg2) = sign(y(arg2));

x(arg3 & (y <=1)) = y(arg3 & (y <=1));
arg5 = arg3 & (y <=1);
sigma(arg5)= ones(size(arg5(arg5 > 0)));
arg6 = arg3 & (y > 1);
x(arg6) = 2*ones(size(arg6(arg6>0)))- y(arg6);
sigma(arg6) = -ones(size(arg6(arg6>0)));
x(arg4) = y(arg4); 
sigma(arg4) = ones(sarg4);
sigma = sigma + (ones(n,1) - abs(sigma));


