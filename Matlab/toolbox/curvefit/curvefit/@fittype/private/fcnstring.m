function line = fcnstring(variable,arglist,numargs,expr)

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:42:50 $

line =sprintf('  %s(', variable);
for k = 1:(numargs-1)
    line = sprintf('%s%s,', line, deblank(arglist(k,:)));
end
line = sprintf('%s%s)', line, deblank(arglist(numargs,:)));
line = sprintf('%s = %s', line, expr);
