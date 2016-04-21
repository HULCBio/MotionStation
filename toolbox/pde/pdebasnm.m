function mn=pdebasnm(mn)
%PDEBASNM strips path from filename.

%       Magnus G. Ringh 6-01-94, MR 9-29-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:13 $

cmptr=computer;
if ~isempty(findstr('PCWIN',cmptr))
  ch='\';
elseif ~isempty(findstr('MAC2',cmptr))
  ch=':';
else
  ch='/';
end
n=length(mn);
i=findstr(mn,ch);
ni=length(i);
if ni>0,
  mn=mn(i(ni)+1:n);
end

