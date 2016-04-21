function wprime = nndadapt(t,w)
%NNDADAPT Calculates the derivative for adaptive weights of the Grossberg network
%
%  NNDADAPT(t,w2)
%    t - Current time
%    w - Weights (w(1)=w1,1, w(2)=w12, w(3)=w21, w(4)=w22)
%   Returns dw.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

global n1_1;
global n1_2;
global lr;

if (rem(fix(t/0.2),2)==0),
  n1 = n1_1;
  n2 = [1; 0];
else
  n1 = n1_2;
  n2 = [0; 1];
end

w = reshape(w,2,2);

if lr == 1
  wprime = (4*n2*ones(1,2)).*(ones(2,1)*n1'-w);
else
  wprime = 4*n2*n1' - 2*w;
end

wprime = reshape(wprime,4,1);
