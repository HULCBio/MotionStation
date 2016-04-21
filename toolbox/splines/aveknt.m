function tstar = aveknt(t,k)
%AVEKNT Knot averages.
%
%   AVEKNT(T,K)  returns the averages of successive  K-1  knots, i.e., 
%   the points 
%
%       TSTAR(i) = ( T_{i+1} + ... + T_{i+K-1} ) / (K-1)
%
%   recommended as good interpolation point choices when interpolating
%   from  S_{K,T} .
%
%   For example, with  k  and the increasing sequence  breaks  given,
%   the statements
%
%      t = augknt(breaks,k); x = aveknt(t);
%      sp = spapi( t , x, sin(x) );
%
%   provide a spline interpolant to the sine function on the interval
%   [breaks(1) .. breaks(end)] .
%
%   See also SPAPIDEM, OPTKNT, APTKNT, CHBPNT.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.18 $

t = t(:); n = length(t)-k;
if k<2, error('SPLINES:AVEKNT:wrongk','The second argument must be at least 2 .')
elseif n<0, error('SPLINES:AVEKNT:toofewknots','There must be at least K knots.')
elseif k==2, tstar = reshape(t(1+[1:n]),1,n);
else
   temp = repmat(t,1,k-1);
   temp = sum(reshape([temp(:);zeros(k-1,1)],n+k+1,k-1).')/(k-1);
   tstar = temp(1+[1:n]);
end
