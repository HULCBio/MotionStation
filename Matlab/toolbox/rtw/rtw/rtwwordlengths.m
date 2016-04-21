function value = rtwwordlengths(model)
% RTWWORDLENGTHS - returns the word lengths for a given target.
% For example,
%
% value.CharNumBits  = int32(8);
% value.ShortNumBits = int32(16);
% value.IntNumBits   = int32(32);
% value.LongNumBits  = int32(32);
%
% Example
%   rtwwordlengths('model_name')
%
% See also EXAMPLE_RTW_INFO_HOOK.
  
% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.2.2.6 $

  cs = getActiveConfigSet(model);
  hf = rtwprivate('get_rtw_info_hook_file_name',model);
  
  if hf.FileExists;
    
    % hook file is available
    
    hookfile = hf.HookFileName;
    
    try,
      value = feval(hookfile,'wordlengths',model);
    catch
      error(['Error encountered while executing custom supplied ', ...
             'RTW hook file: ', hookfile, '.m']);
    end
    
    if ~isfield(value,'CharNumBits') | ...
          ~isfield(value,'ShortNumBits') | ...
          ~isfield(value,'IntNumBits') | ...
            ~isfield(value,'LongNumBits')
      error([hookfile, '.m does not properly specify wordlengths.'])
    end
    
    value.CharNumBits  = int32(value.CharNumBits);
    value.ShortNumBits = int32(value.ShortNumBits);
    value.IntNumBits   = int32(value.IntNumBits);
    value.LongNumBits  = int32(value.LongNumBits);
    
  else
    
      % hookfile is not available (use defaults)
      
      value = rtwhostwordlengths(model);
      
  end

  hardware = cs.getComponent('Hardware Implementation');
  if strcmp(hardware.TargetUnknown, 'off')        
    value.CharNumBits  = int32(get_param(cs, 'TargetBitPerChar'));
    value.ShortNumBits = int32(get_param(cs, 'TargetBitPerShort'));
    value.IntNumBits   = int32(get_param(cs, 'TargetBitPerInt'));
    value.LongNumBits  = int32(get_param(cs, 'TargetBitPerLong'));
    value.WordSize     = int32(get_param(cs, 'TargetWordSize'));
  end
