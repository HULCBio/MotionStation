function y=diric(x,N)
%DIRIC	Dirichlet, or periodic sinc function
%   Y = DIRIC(X,N) returns a matrix the same size as X whose elements
%   are the Dirichlet function of the elements of X.  Positive integer
%   N is the number of equally spaced extrema of the function in the 
%   interval 0 to 2*pi. 
%
%   The Dirichlet function is defined as
%       d(x) = sin(N*x/2)./(N*sin(x/2))   for x not a multiple of 2*pi
%              +1 or -1 for x a multiple of 2*pi. (depending on limit)

%   Author(s): T. Krauss, 1-14-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:10:52 $

error(nargchk(2,2,nargin));
if round(N)~=N | N<1 | prod(size(N))~=1,
    error('Requires N to be a positive integer.');
end

y=sin(.5*x);
i=find(abs(y)>1e-12);   % set where x is not divisible by 2 pi
j=1:length(x(:));
j(i)=[];                         % complement set
y(i)=sin((N/2)*x(i))./(N*y(i));
y(j)=sign(cos(x(j)*((N+1)/2)));

