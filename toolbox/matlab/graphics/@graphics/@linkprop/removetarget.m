function removetarget(hLink,h)
%REMOVETARGET Remove handle for linking

% Copyright 2003 The MathWorks, Inc.

if ~ishandle(h)
   return;
end

h = handle(h);

t = get(hLink,'Targets');

% only update if in list
ind = find(t==h);

% remove element
if length(ind)>0
  t(ind) = [];
  set(hLink,'Targets',t); 

  % Update listeners, call to pseudo-private method
  feval(get(hLink,'UpdateFcn'),hLink); 
end




