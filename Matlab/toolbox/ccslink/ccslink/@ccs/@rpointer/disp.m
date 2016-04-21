function dummy = disp(mm)
%DISP Display.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/11/30 23:11:59 $

fprintf('\nPOINTER Object stored in register(s):\n');
disp_rnumeric(mm);
disp_registerobj(mm);
disp_rpointer(mm);
fprintf('\n');

%[EOF] disp.m