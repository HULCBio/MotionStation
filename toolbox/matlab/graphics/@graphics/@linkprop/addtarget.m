function addtarget(hLink,h)
%ADDTARGET Add handle for linking

% Copyright 2003 The MathWorks, Inc.

if ~ishandle(h)
  error('MATLAB:graphics:linkprop','Invalid handle');
end

h = handle(h);

t = get(hLink,'Targets');

% only update if not already in list
if ~any(t==h)
  set(hLink,'Targets',[t,h]); 

  % Update listeners, call to pseudo-private method
  feval(get(hLink,'UpdateFcn'),hLink); 
end




