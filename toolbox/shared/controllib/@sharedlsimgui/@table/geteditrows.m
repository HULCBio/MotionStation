function rowind = geteditrows(h)

% Copyright 2004 The MathWorks, Inc.

nrows = size(h.celldata,1);
if nrows>=1
	rowind = javaArray('java.lang.Boolean',nrows);
    for k=1:nrows
       if any(h.readonlyrows == k)
           rowind(k) = java.lang.Boolean(false);
       else
           rowind(k) = java.lang.Boolean(true);
       end
   end
else % return a scalar false bool
   rowind = javaArray('java.lang.Boolean',1); 
   rowind(1) = java.lang.Boolean(false);
end


