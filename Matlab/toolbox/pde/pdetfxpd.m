function f=pdetfxpd(p,t,u,time,f)
%PDETFXPD Evaluate a function on triangles.

%       A. Nordmark 12-21-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:21 $

if pdeisfunc(f)
  f=feval(f,p,t,u,time);
end

