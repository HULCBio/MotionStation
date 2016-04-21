function colind = geteditcols(h)

% Copyright 2004 The MathWorks, Inc.

if length(h.colnames)>=1
	colind = javaArray('java.lang.Boolean',length(h.colnames));
    for k=1:length(h.colnames)
       if any(h.readonlycols == k)
           colind(k) = java.lang.Boolean(false);
       else
           colind(k) = java.lang.Boolean(true);
       end
   end
else
   colind = javaArray('java.lang.Boolean',1); 
   colind(1) = java.lang.Boolean(false);
end


