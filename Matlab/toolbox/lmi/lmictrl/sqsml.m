% [sys,x0]=sqsml(t,x,u,flag,a,b,c,d,T)
%
% Called by SPLOT: square wave response of an LTI system

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [sys,x0]=sqsml(t,x,u,flag,a,b,c,d,T)


if flag==0,

  na=size(a,1);
  sys=[na 0 size(d,1) size(d,2) 0 1];
  x0=zeros(na,1);

else

  u=(rem(t,T)<T/2);

  if abs(flag)==1,
    % state-space ODE
    sys=a*x + b*u;
  elseif flag==3,
    sys=c*x + d*u;
  end

end
