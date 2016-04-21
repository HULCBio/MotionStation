function dummy = disp(mm)
%DISP Display.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:09:51 $

fprintf('\nNUMERIC Object stored in memory: \n')
disp_numeric(mm);
disp_memoryobj(mm);
fprintf('\n');

%[EOF] disp.m