function str = getDatatipText(this,dataCursor)

% Copyright 2003 The MathWorks, Inc.

is3D = ~isempty(this.zdata);

ind = dataCursor.dataIndex;

xx = num2str(this.xdata(ind(1)));
yy = num2str(this.ydata(ind(1)));

if is3D
   zz = num2str(this.zdata(ind(1)));
   str = {['X= ',xx], ['Y= ',yy], ['Z= ',zz]};
else
   str = {['X= ',xx], ['Y= ',yy]};
end
