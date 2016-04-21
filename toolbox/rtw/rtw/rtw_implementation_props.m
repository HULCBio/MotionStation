function value = rtw_implementation_props(model)
% RTW_IMPLEMENTATION_PROPERTIES - returns C specific implementation
% properties for a given target inside a MATLAB structure.  For
% example:
%
% value.ShiftRightIntArith   = true;
%
% Example
%   rtw_implementation_props('model_name')
%
% See also EXAMPLE_RTW_INFO_HOOK.
  
% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.2.2.8 $

  hf = rtwprivate('get_rtw_info_hook_file_name',model);
  
  if hf.FileExists;
    
    % hook file is available
    
    hookfile = hf.HookFileName;
    
    try,
      value = feval(hookfile,'cImplementation',model);
    catch
      error(['Error encountered while executing custom supplied ', ...
             'RTW hook file ', hookfile, '.m: ', lasterr]);
    end
    
  else
    
    % hookfile is not available (use defaults)
    
    value = rtw_host_implementation_props(model);
    
  end
  
  cs = getActiveConfigSet(model);
  hardware = cs.getComponent('Hardware Implementation');
  if strcmp(hardware.TargetUnknown, 'off')
    value.ShiftRightIntArith = strcmp(get_param(cs, 'TargetShiftRightIntArith'), 'on');
    value.TypeEmulationWarnSuppressLevel = get_param(cs, 'TargetTypeEmulationWarnSuppressLevel');
    value.PreprocMaxBitsSint = get_param(cs, 'TargetPreprocMaxBitsSint');
    value.PreprocMaxBitsUint = get_param(cs, 'TargetPreprocMaxBitsUint');
    if cs.isValidParam('TargetEndianess')
      value.Endianess = get_param(cs, 'TargetEndianess');
    end
  end
  

  
  
