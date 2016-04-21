function [q,g,h,r]=pdeefxpd(p,e,u,time,bl)
%PDEEFXPD Evaluate a function on edges.

%       A. Nordmark 12-20-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:15 $


if pdeisfunc(bl)
  [q,g,h,r]=feval(bl,p,e,u,time);
  return
end

% Return nonsense
q=[];
g=[];
h=[];
r=[];

