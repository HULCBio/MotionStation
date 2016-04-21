function bool = isUsingHighSpeedRTDX_TItarget
% return TRUE if high-speed RTDX is requested and allowed

% $RCSfile: isUsingHighSpeedRTDX_TItarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:33:56 $
% Copyright 2001-2004 The MathWorks, Inc.

try
    
    configSet = getActiveConfigSet(gcs);
    
    cbox = get_param(configSet,'useHSRTDX');
    targetType = getTargetType_DSPtarget(gcs);
    
    bool = strcmp(cbox,'on') && ~strcmp(targetType,'C6701EVM');
    
catch
    
    % Can't error out when called from TLC
    disp(lasterr)
    disp('Error evaluating m-file isUsingHighSpeedRTDX_TItarget')
    bool = 0;
    error(lasterr)
    
end

% [EOF] isUsingHighSpeedRTDX_TItarget.m
