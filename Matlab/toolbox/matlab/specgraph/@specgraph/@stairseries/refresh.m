function refresh(this)
%REFRESH Refresh stair plot
  
%   Copyright 1984-2003 The MathWorks, Inc.

if ~strcmp(this.dirty,'clean')
  if length(this.xdata) ~= length(this.ydata)
    this.dirty = 'inconsistent';
  else
    [x,y] = deal(this.xdata,this.ydata);
    x = x(:);
    y = y(:);

    [n,nc] = size(y); 
    ndx = [1:n;1:n];
    y2 = y(ndx(1:2*n-1),:);
    if size(x,2)==1,
      x2 = x(ndx(2:2*n),ones(1,nc));
    else
      x2 = x(ndx(2:2*n),:);
    end

    ch = get(this,'children');
    set(ch,'visible',this.visible);
    set(ch,'xdata',x2,'ydata',y2);
    
    this.dirty = 'clean';
    update(this);
  end
end

