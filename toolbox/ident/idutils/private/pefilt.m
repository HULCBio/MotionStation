function y=pefilt(b,a,u,t)
%PEFILT Auxiliary routine to PE
%
%   y = pefilt(b,a,u,t)
%
%   y is obtained as the filtered output to the system b/a with
%   input u. The initial conditions are chosen so that the first
%   values of y equal the entries in the vector t.

%   L. Ljung 87-08-08, 94-08-26
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:47 $

 y=filter(b,a,u);return % Uncomment this line if you do not wish the initial
                         % values be chosen so as to make the first prediction
                         % errors zero.
if nargin<4, t=[];end
na=length(a)-1;nb=length(b)-1;
n=max([na nb length(t)]);
t=[t(:);zeros(n,1)];
f1=filter(a,1,t(1:n));

f2=filter(b,1,u(1:n));
x=f1(:)-f2(:);
y=filter([b zeros(1,n-nb)],[a zeros(1,n-na)],u,x);