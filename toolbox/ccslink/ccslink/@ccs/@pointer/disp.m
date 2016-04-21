function dummy = disp(mm)
%DISP Display.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/11/30 23:10:23 $

fprintf('\nPOINTER Object stored in memory: \n')
disp_numeric(mm);
disp_memoryobj(mm);
disp_pointer(mm);
fprintf('\n');
%[EOF] disp.m