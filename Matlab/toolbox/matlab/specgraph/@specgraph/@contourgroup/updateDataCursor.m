function updateDataCursor(this,hDataCursor,target)
%UPDATEDATACURSOR Update contour data cursor
  
%   Copyright 1984-2004 The MathWorks, Inc.

x = get(this,'XData');
y = get(this,'YData');
if (size(y,1)==1), y=y'; end;
if (size(x,2)==1), x=x'; end;
x = x(1,:);
y = y(:,1);

xind = find(target(1,1)>=x);
yind = find(target(1,2)>=y);

if ~isempty(xind) & ~isempty(yind) 
  % Contour doesn't support interpolated datatips
  hDataCursor.Position = [x(xind(end)) y(yind(end))];
  hDataCursor.DataIndex = [xind(end) yind(end)];
end
