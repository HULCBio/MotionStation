
% Copyright 2004 The MathWorks, Inc.

me = daexplr;
mi = DAStudio.imMenuItem;
mi.setMenuItem(me, '');
mi.ItemID = 'VIEW_ROOTCONFIGSET';
if ~mi.On
  mi.execute;
  pause(1);
end
cs = getActiveConfigSet(0);
me.view(cs);