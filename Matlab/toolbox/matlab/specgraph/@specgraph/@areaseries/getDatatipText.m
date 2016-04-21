function str = getDatatipText(this,dataCursor)

% Copyright 2003 The MathWorks, Inc.

if dataCursor.dataIndex > length(this.xdata)+1
  ind = 2*(1+length(this.xdata)) - dataCursor.dataIndex;
elseif dataCursor.dataIndex ~= 1
  ind = dataCursor.dataIndex-1;
else
  ind = 1;
end
str = {['X= ' num2str(this.xdata(ind))], ...
       ['Y= ' num2str(this.ydata(ind))]};
