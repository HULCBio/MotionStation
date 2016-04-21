function str = getDatatipText(this,dataCursor)

% Copyright 2003 The MathWorks, Inc.

ind = floor((dataCursor.dataIndex-1)/5)+1;
str = {['X= ' num2str(this.xdata(ind))], ...
       ['Y= ' num2str(this.ydata(ind))]};
