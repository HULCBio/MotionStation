function value = rtwhostwordlengths(model)
% RTWHOSTWORDLENGTHS - returns the word lengths for the host computer
% inside a MATLAB structure.
%
% See also RTWWORDLENGTHS, EXAMPLE_RTW_INFO_HOOK.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.3.4.3 $
  
  comp = computer;
  
  switch comp
   case {'PCWIN', 'SOL2', 'GLNX86', 'HPUX', 'MAC'}
    value.CharNumBits  = int32(8);
    value.ShortNumBits = int32(16);
    value.IntNumBits   = int32(32);
    value.LongNumBits  = int32(32);
    value.WordSize     = int32(32);
   case {'GLNXI64'}
    value.CharNumBits  = int32(8);
    value.ShortNumBits = int32(16);
    value.IntNumBits   = int32(32);
    value.LongNumBits  = int32(64);
    value.WordSize     = int32(32);
  end
  
  
