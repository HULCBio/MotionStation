function ti_c2000_grt_make_rtw_hook (hookPoint, modelName, rtwroot, tmf, buildOpts, buildArgs)
% TI_C2000_GRT_MAKE_RTW_HOOK - TI C2000 Target 
%            hook file for the build process (make_rtw).

% $RCSfile: ti_c2000_grt_make_rtw_hook.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:16 $
% Copyright 2003-2004 The MathWorks, Inc.

%
% This function is called four times in make_rtw.m:
%   Upon entry.
%   Before tlc_c.m is invoked.
%   Before before make is invoked.
%   Upon exit.
%
%   NOTE:  Do not change the name of this file.  The prefix must be the same as 
%          the name of the system target file (minus the '.tlc').

% save current warning mode, and disable warnings
saveWarn = warning;
warning off;

% Declare a persistent variable to retain info from subsequent calls to this 
% function during the targetting process. Once we exit, we clear this variable.
persistent target_state

% get user-specified build arguments
args = get_param(modelName,'RTWBuildArgs'); % get RTW model arguments

modelInfo.name      = modelName;
modelInfo.rtwroot   = rtwroot;
modelInfo.tmf       = tmf;
modelInfo.buildOpts = buildOpts;
modelInfo.buildArgs = args;

target_state=feval(getMethodName(hookPoint),target_state,modelInfo);

% restore original warning mode
warning(saveWarn);



%-------------------------------------------------------------------------------
function methodName = getMethodName(hookPoint)

methodName = [strrep(hookPoint,'_','') 'Hookpoint_tic2000target'];

% [EOF] ti_c2000_grt_make_rtw_hook.m
