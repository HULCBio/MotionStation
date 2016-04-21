% [sys,x0]=sinsml(t,x,u,flag,a,b,c,d,w)
%
% Called by SPLOT: sine wave response of an LTI system

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [sys,x0]=sinsml(t,x,u,flag,a,b,c,d,w)


if flag==0,

  na=size(a,1);
  sys=[na 0 size(d,1) size(d,2) 0 1];
  x0=zeros(na,1);

else

  if abs(flag)==1,
    % state-space ODE
    sys=a*x + b*sin(w*t);
  elseif flag==3,
    sys=c*x + d*sin(w*t);
  end

end
