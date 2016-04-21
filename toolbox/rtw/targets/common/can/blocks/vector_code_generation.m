function generateCode = vector_code_generation(sys)
%
%  VECTOR_CODE_GENERATION Returns whether code generation for the Vector 
%  CAN blocks should be run.
%
%  VECTOR_CODE_GENERATION(SYS) returns true if the target associated with model
%  SYS is GRT or ERT.   Otherwise, false is returned.
%

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
% $Date: 2003/07/31 18:04:06 $
   sys_target_file = get_param(sys, 'RTWSystemTargetFile');
   tlcindex = findstr('.tlc', sys_target_file);
   target = sys_target_file(1:tlcindex-1);
   switch (target)
      case { 'grt', 'ert' }
         generateCode = true;
      otherwise
         generateCode = false;
   end;
return;
