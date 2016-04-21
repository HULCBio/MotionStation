function value = rtw_host_implementation_props(model)
% RTW_HOST_IMPLEMENTATION_PROPS - returns C specific implementation
% properties for the host computer inside a MATLAB structure.
%
% See also RTW_IMPLEMENTATION_PROPS, EXAMPLE_RTW_INFO_HOOK.
  
% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.3.4.5 $
  
  comp = computer;
  
  switch comp
   case {'PCWIN', 'ALPHA'}
    value.ShiftRightIntArith   = true;
    value.Endianess            = 'Little';
   case {'SOL2', 'GLNX86', 'GLNXI64', 'HPUX', 'MAC'}
    value.ShiftRightIntArith   = true;
    value.Endianess            = 'LittleEndian';
  end
  

  
  
