function varargout = example_rtw_info_hook(varargin)
% EXAMPLE_RTW_INFO_HOOK
% 

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.2.3 $
%
% NOTE: This file is obsolete.
%
% Beginning in R14, Real-Time Workshop provides a more convenient way to specify 
% hardware characteristics of production target and current target, including 
% the word lengths and c implementation information.  You can now specify this 
% information directly in the configuration parameters dialog or 
% programmatically through the active configuration set of the model.  The 
% following is a mapping between old field names to the parameter names in the 
% configuration set:
%
% For 'wordlengths'
%  
%  CharNumBits   <==>  TargetBitPerChar
%  ShortNumBits  <==>  TargetBitPerShort
%  IntNumBits    <==>  TargetBitPerInt
%  LongNumBits   <==>  TargetBitPerLong
% 
% For 'cImplementation'
%  
%  ShiftRightIntArith             <==>  TargetShiftRightIntArith
%  TypeEmulationWarnSuppressLevel <==>  TargetTypeEmulationWarnSuppressLevel
%  PreprocMaxBitsSint             <==>  TargetPreprocMaxBitsSint
%  PreprocMaxBitsUint             <==>  TargetPreprocMaxBitsUint
%  Float2IntSaturates   (obsolete)
%  IntPlusIntSaturates  (obsolete)
%  IntTimesIntSaturates (obsolete)
%
% For backward compatibility, Real-Time Workshop continues to honor information
% specified in a <target>_rtw_info_hook file when generating code for a pre-R14 
% model.  This information will be imported into the active configuration set of
% the model during the code generation process.  Once you specify target 
% hardware characteristics information in the configuration set, it supersedes 
% settings in the <target>_rtw_info_hook file.
%
% For more details regarding how to specify the hardware characteristics and how 
% to migrate a <target>_rtw_info_hook file, please refer to  the section 
% "Specifying Hardware Characteristics to Optimize Generated Code" in the 
% Real-Time Workshop release notes.
%

% EOF