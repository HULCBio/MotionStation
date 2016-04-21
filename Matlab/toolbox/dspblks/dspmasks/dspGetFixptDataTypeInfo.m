function dtInfo = dspGetFixptDataTypeInfo(blk,modebitmask)
% dtInfo = dspGetFixptDataTypeInfo(blk,modebitmask)
%
%   blk         = handle of fixed-point enabled block ('gcbh')
%   modebitmask = integer representation of relevant fixpt params
%                 The value of this integer is formed by summing 
%                 the values of the respective fixpt params:
%                      misc        1
%                      output      2
%                      accum       4 
%                      prodOutput  8
%                      memory      16
%                      firstCoeff  32
%                      secondCoeff 64
%                      thirdCoeff  128
%                      interProd   256
%
% This function returns a structure with fields for each of the
% relevant fixed-point parameters.  There are 23 possible fields - 
% 20 of the field names are formed from the different combinations 
% of prefix and suffix as listed below:
%    prefixes:           suffixes:
%      output              Mode
%      accum               WordLength
%      prodOutput          FracLength
%      memory     
%      firstCoeff 
%      secondCoeff
%      thirdCoeff 
%      interProd  
% 
% The last two possible fields are roundingMode and overflowMode.
%
% For the prefix/suffix combinations, the possibilities for Mode are:
%   -2 : custom (a block-specific option, such as "Same as numerator")
%   -1 : unused
%    0 : Specified by user
%    1 : Specify word length
%    2 : Same [word length] as [first] input
%    3 : Same as product output
%    4 : Same as accumulator
%    5 : Inherit via internal rule
% If the Mode is anything other than 'Specified by user' (0), the 
% corresponding WordLength and FracLength fields will be equal to zero.
%
% roundingMode has these possibilities:
%    1 : round to floor
%    2 : round to nearest
%
% overflowMode has these possibilities:
%    1 : wrap on overflow
%    2 : saturate on overflow
%
% If the roundingMode popup and overflowMode checkbox are not present, then
% these fields will be equal to zero.
%
%   NOTE: This function is not intended to be used with source blocks.  For
%   fixed-point-enabled source blocks, use dspGetDataTypeInfo.
%
%   NOTE: This is a Signal Processing Blockset mask utility function.  It is 
%   not intended to be used as a general-purpose function.
  
%  Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.9.6.7 $  $Date: 2004/04/12 23:05:48 $
  
% There are nine (9) different 'sections' that may exist in the mask:
%
% (1) first coefficient    : firstCoeffMode, firstCoeffWordLength,
%     params                 firstCoeffFracLength
%
% (2) second coefficient   : secondCoeffMode, secondCoeffWordLength,
%     params                 secondCoeffFracLength
%
% (3) third coefficient    : thirdCoeffMode, thirdCoeffWordLength,
%     params                 thirdCoeffFracLength
%
% (4) intermediate product : interProdMode, interProdWordLength, 
%     params                 interProdFracLength
%
% (5) product output       : prodOutputMode, prodOutputWordLength, 
%     params                 prodOutputFracLength
%
% (6) accumulator params   : accumMode, accumWordLength, 
%                            accumFracLength
%
% (7) memory params        : memoryMode, memoryWordLength, 
%                            memoryFracLength
%
% (8) output params        : outputMode, outputWordLength, 
%                            outputFracLength
%
% (9) misc                 : roundingMode, overflowMode
%
% Note that sections (5) through (9) may be controlled by one or more
% DSP Fixed-Point Attributes blocks
%
 
% Force all calls to pass in valid blk and modebitmask values
if (nargin < 2) 
  error('ModeBitMask Parameter is required in calls to dspGetFixptDataTypeInfo');
end

if isempty(blk)
  blk = gcbh;
  % Ensure we call get_param with gcbh instead of SLOW gcb
  obj = get_param(gcbh,'object');
else
  obj = get_param(blk,'object');    
end

dtInfo = [];

%
% mode bit mask values
% arranged approx. according to commonality
%
% miscMode         : 1
% outputMode       : 2
% accumMode        : 4
% prodOutputMode   : 8
% memoryMode       : 16
% firstCoeffMode   : 32
% secondCoeffMode  : 64
% thirdCoeffMode   : 128
% interProdMode    : 256

if bitand(modebitmask,2)
  dtInfo = processParamSection(obj, 'outputMode', ...
                               'outputWordLength', ...
                               'outputFracLength', ...
                               dtInfo);
end
if bitand(modebitmask,4)
  dtInfo = processParamSection(obj, 'accumMode', ...
                               'accumWordLength', ...
                               'accumFracLength', ...
                               dtInfo);
end
if bitand(modebitmask,8)
  dtInfo = processParamSection(obj, 'prodOutputMode', ...
                               'prodOutputWordLength', ...
                               'prodOutputFracLength', ...
                               dtInfo);
end
if bitand(modebitmask,16)
  dtInfo = processParamSection(obj, 'memoryMode', ...
                               'memoryWordLength', ...
                               'memoryFracLength', ...
                               dtInfo);
end
if bitand(modebitmask,32)
  dtInfo = processParamSection(obj, 'firstCoeffMode' , ...
                               'firstCoeffWordLength' , ...
                               'firstCoeffFracLength', ...
                               dtInfo);
end
if bitand(modebitmask,64)
  dtInfo = processParamSection(obj, 'secondCoeffMode', ...
                               'secondCoeffWordLength', ...
                               'secondCoeffFracLength', ...
                               dtInfo);
end
if bitand(modebitmask,128)
  dtInfo = processParamSection(obj, 'thirdCoeffMode', ...
                               'thirdCoeffWordLength', ...
                               'thirdCoeffFracLength', ...
                               dtInfo);
end
if bitand(modebitmask,256)
  dtInfo = processParamSection(obj, 'interProdMode', ...
                               'interProdWordLength', ...
                               'interProdFracLength' , ...
                               dtInfo);
end

% MISC (ROUNDING and OVERFLOW)
if bitand(modebitmask,1) 
  % possibilites are:
  %  1 = floor
  %  2 = nearest
  if strcmp(obj.roundingMode,'Floor')
    dtInfo.roundingMode = 1;
  else
    dtInfo.roundingMode = 2;
  end
  % possibilities are:
  %  1 = wrap
  %  2 = saturate
  if strcmp(obj.overflowMode,'off')
    dtInfo.overflowMode = 1;
  else
    dtInfo.overflowMode = 2;
  end 
else
  dtInfo.roundingMode = 0;
  dtInfo.overflowMode = 0;
end

%------------------------------------
function dtInfo = processParamSection(obj,modeStr,wlStr,flStr,dtInfo)
% MODE VALUES:
%
%   CUSTOM                    = -2;
%   UNUSED                    = -1;
%   USER_SPECIFIED            =  0;
%   SPECIFY_WORD_LENGTH       =  1;
%   SAME_AS_INPUT             =  2;
%   SAME_AS_PROD_OUTPUT       =  3;
%   SAME_AS_ACCUM             =  4;
%   INHERIT_VIA_INTERNAL_RULE =  5;
%
% NOTE: SAME_WORD_LENGTH_AS_INPUT replaces SAME_AS_INPUT for coeffs
%
switch (obj.(modeStr))
 case {'User-defined',...
       'Binary point scaling',...
       'Slope and bias scaling'}
  modeValue = 0;
  
 case 'Specify word length'
  modeValue = 1;
  
 case {'Same as input',...
       'Same as first input',...
       'Same word length as input',...
       'Same word length as first input'}
  modeValue = 2;
  
 case 'Same as product output'
  modeValue = 3;
  
 case 'Same as accumulator'
  modeValue = 4;
  
 case 'Inherit via internal rule'
  modeValue = 5;

 otherwise
  modeValue = -2;
end

if modeValue == 0
  wlValue = dspGetEditBoxParamValue(obj.Handle,wlStr);
  flValue = dspGetEditBoxParamValue(obj.Handle,flStr);
elseif modeValue == 1
  wlValue = dspGetEditBoxParamValue(obj.Handle,wlStr);
  flValue = 0; % will get figured out by the S-fcn
else
  wlValue = 0; % will get figured out by the S-fcn
  flValue = 0; % will get figured out by the S-fcn
end

dtInfo.(modeStr) = modeValue;
dtInfo.(wlStr)   = wlValue;
dtInfo.(flStr)   = flValue;
