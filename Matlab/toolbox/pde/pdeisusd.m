function y=pdeisusd(name)
%PDEISUSED Checks if NAME is already used.
%
%       PDEISUSD(NAME) checks the string NAME against all object names
%       in PDETOOL and returns 1 if NAME is used, 0 if not.
%
%       Note: NAME is case sensitive, e.g., 'E1'~='e1'.

%       Magnus Ringh 11-15-94. MR 8-17-95
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:20 $

if ~ischar(name),
  error('PDE:pdeisusd:InputNotString', 'Input must be a string.');
end

y=0;
pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
objnames=getappdata(pde_fig,'objnames');

[n,m]=size(objnames);
ln=length(name);
if ln>n,
  return;
end
nm=(ones(m,1)*[name zeros(1,n-ln)])';
tst=(nm==objnames);
if any(sum(tst)==size(tst,1)),
  y=1;
end

