function dummy = disp(mm)
%DISP Display.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:12:11 $

fprintf('\nSTRING Object stored in register(s):\n');
disp_rnumeric(mm);
disp_registerobj(mm);
disp_rstring(mm);
fprintf('\n');

%[EOF] disp.m