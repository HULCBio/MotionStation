function updateDataCursor(this,hDataCursor,target)
%UPDATEDATACURSOR Update quiver data cursor
  
%   Copyright 1984-2003 The MathWorks, Inc. 

x = get(this,'XData');
y = get(this,'YData');

distbase = (target(1,1)-x).^2 + (target(1,2)-y).^2;
ch = get(this,'Children');
linex = get(ch(1),'XData');
liney = get(ch(1),'YData');
tipx = linex(2:3:end);
tipy = liney(2:3:end);
disttip = (target(1,1)-tipx).^2 + (target(1,2)-tipy).^2;

[basemin,baseind] = min(distbase(:));
[tipmin,tipind] = min(disttip(:));

if tipmin < basemin
  hDataCursor.Position = [x(tipind(1)) y(tipind(1))];
  hDataCursor.DataIndex = tipind(1);
else
  hDataCursor.Position = [x(baseind(1)) y(baseind(1))];
  hDataCursor.DataIndex = baseind(1);
end
