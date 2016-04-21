function err = fitfun(lambda,t,y,handle)
%FITFUN Used by FITDEMO.
%   FITFUN(lambda,t,y,handle) returns the error between the data and the values
%   computed by the current function of lambda.
%
%   FITFUN assumes a function of the form
%
%     y =  c(1)*exp(-lambda(1)*t) + ... + c(n)*exp(-lambda(n)*t)
%
%   with n linear parameters and n nonlinear parameters.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 03:36:42 $

A = zeros(length(t),length(lambda));
for j = 1:length(lambda)
   A(:,j) = exp(-lambda(j)*t);
end
c = A\y;
z = A*c;
err = norm(z-y);

set(gcf,'DoubleBuffer','on');
set(handle,'ydata',z)
drawnow
pause(.04)
