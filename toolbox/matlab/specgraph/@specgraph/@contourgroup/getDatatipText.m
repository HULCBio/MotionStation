function str = getDatatipText(this,dataCursor)
%GETDATATIPTEXT Get contour datatip text
  
%   Copyright 1984-2003 The MathWorks, Inc. 

x = get(this,'XData');
y = get(this,'YData');
z = get(this,'ZData');
if (size(y,1)==1), y=y'; end;
if (size(x,2)==1), x=x'; end;
x = x(1,:);
y = y(:,1);

% DataIndex was computed in updateDataCursor
ind = dataCursor.DataIndex;
str = {['X= ' num2str(x(ind(1)))], ...
       ['Y= ' num2str(y(ind(2)))], ...
       ['Level= ' num2str(z(ind(2),ind(1)))]};

if ~isempty(this.DisplayName)
  str = {this.DisplayName,str{:}};
end