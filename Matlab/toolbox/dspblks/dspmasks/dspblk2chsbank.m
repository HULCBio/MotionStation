function varargout = dspblk2chsbank(action)
% DSPBLK2CHSBANK Signal Processing Blockset 2-Channel Synthesis Filter Bank block helper function.

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1.4.5 $ $Date: 2004/04/12 23:05:53 $
      
if nargin==0, action = 'dynamic'; end

blk = gcbh;

% Get dtInfo for return value
dtInfo    = dspGetFixptDataTypeInfo(blk,47);
varargout = {dtInfo};

fullblk     = getfullname(blk);
sum_blk     = [fullblk '/Sum'];
dt_cnvt_blk = [fullblk '/Data Type Conversion'];

% Under the block mask, set the Sum and Convert
% block rounding and overflow parameters to what
% was specified at the top-level of the mask
if (dtInfo.roundingMode == 1)
    set_param(sum_blk,     'RndMeth', 'Floor');
    set_param(dt_cnvt_blk, 'RndMeth', 'Floor');
else
    set_param(sum_blk,     'RndMeth', 'Nearest');
    set_param(dt_cnvt_blk, 'RndMeth', 'Nearest');
end

if (dtInfo.overflowMode == 2)
    set_param(sum_blk,     'SaturateOnIntegerOverflow', 'on');
    set_param(dt_cnvt_blk, 'SaturateOnIntegerOverflow', 'on');
else
    set_param(sum_blk,     'SaturateOnIntegerOverflow', 'off');
    set_param(dt_cnvt_blk, 'SaturateOnIntegerOverflow', 'off');
end
	
% [EOF] dspblk2chsbank.m
