function ti_c6000_make_rtw_hook(hookPoint,modelName,rtwroot,tmf,buildOpts,buildArgs)
% TI_C6000_MAKE_RTW_HOOK - TI C6000 Target 
%            hook file for the build process (make_rtw).
%
% Enter giant switchyard.  This function is called four times in make_rtw.m:
%   Upon entry.
%   Before tlc_c.m is invoked.
%   Before before make is invoked.
%   Upon exit.

% $RCSfile: ti_c6000_make_rtw_hook.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:28:47 $
% Copyright 2001-2003 The MathWorks, Inc.
%
%   NOTE:  Do not change the name of this file.  The prefix must be the same as 
%          the name of the system target file (minus the '.tlc').

% Declare a persistent variable to retain info
% from subsequent calls to this function during
% the targetting process.  Once we exit, we
% clear this variable.
%
persistent target_state

% get user-specified build arguments
args = get_param(modelName,'RTWBuildArgs'); % get RTW model arguments

modelInfo.name      = modelName;
modelInfo.rtwroot   = rtwroot;
modelInfo.tmf       = tmf;
modelInfo.buildOpts = buildOpts;
modelInfo.buildArgs = args;

target_state=feval(getMethodName(hookPoint),target_state,modelInfo);


%-------------------------------------------------------------------------------
function methodName = getMethodName(hookPoint)

methodName = [strrep(hookPoint,'_','') 'Hookpoint_DSPtarget'];

% [EOF] ti_c6000_make_rtw_hook.m
