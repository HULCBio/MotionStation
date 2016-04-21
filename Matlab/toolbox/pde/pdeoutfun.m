function status=pdeoutfun(t,y,flag)
%PDEOUTFUN Produce feedback to during time stepping.

%       A. Nordmark 2-6-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:18 $

if nargin==2
  for i=1:length(t)
    fprintf('Time: %g\n',t(i))
  end
end

status=0;

