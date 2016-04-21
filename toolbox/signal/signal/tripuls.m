function y = tripuls(t,Tw,skew)
%TRIPULS Sampled aperiodic triangle generator.
%   TRIPULS(T) generates samples of a continuous, aperiodic,
%   unity-height triangle at the points specified in array T, centered
%   about T=0.  By default, the triangle is symmetric and has width 1.
%
%   TRIPULS(T,W) generates a triangle of width W.
%
%   TRIPULS(T,W,S) allows the triangle skew S to be adjusted.  The
%   skew parameter must be in the range -1 < S < +1, where 0 generates
%   a symmetric triangle.
%
%   See also SQUARE, SIN, COS, CHIRP, DIRIC, GAUSPULS, PULSTRAN and
%   RECTPULS.

%   Author(s): D. Orofino, 4/96
%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.7 $

error(nargchk(1,3,nargin));
if nargin<2, Tw=1;   end
if nargin<3, skew=0; end
if (skew<-1) | (skew>1),
  error('Skew value must be in the range -1<=k<=1.');
end

% Compute triangle function output:
Ta=Tw/2*skew;
y=zeros(size(t));
i = find( (t>(-Tw/2)) & (t<Ta) );
y(i) = (2*t(i)+Tw)./(Tw*(1+skew));
i = find( (t>Ta) & (t<Tw/2) );
y(i) = 1 - (2*t(i)-skew*Tw)./(Tw*(1-skew));
y(find(t==Ta)) = 1.0;

% end of tripuls.m
