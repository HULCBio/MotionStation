function accelbuild_private()
%ACCELBUILD_PRIVATE Private Acclerator build function
%
%   This is a back-end function for use with the Real-Time Workshop
%   when creating an Accelerator MEX-file for use with the Simulink
%   Accelerator. It is not intended to be directly used or modified.
%  
%   See also ACCELBUILD.

%
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.7.2.7 $

  modelName = bdroot;
  errmsg    = '';
  
  disp([sprintf('\n'), ...
	'### Building Simulink Accelerator mex file: ', modelName, ...
	'_acc.',mexext]);
  
  % Build the mex file
  try
    LocalAccelbuildprivate(modelName);
  catch
    errmsg = lasterr;
  end

  % Exit
  if ~isempty(errmsg)
    error(errmsg);
  end;

%endfunction accelbuild_private


% Function: LocalAccelbuild_private ==========================================
% Abstract:
%	Build a mex file (model_acc.mex) corresponding to a Simulink model
%       for the Simulink accelerator.
%
%       Switches RTW parameters for Accelerator builds and then uses
%       make_rtw as is.  Also, returns success or failure so that
%       Simulink can take appropriate steps.
%
function LocalAccelbuildprivate(modelName)

  hModel = get_param(modelName,'handle');

  errmsg = '';

  accelSystemTargetFile = get_param(hModel,'AccelSystemTargetFile');
  accelTemplateMakeFile = get_param(hModel,'AccelTemplateMakeFile');
  accelMakeCommand      = get_param(hModel,'AccelMakeCommand');
  activeConfigSet       = getActiveConfigSet(hModel);
  CustomSymbolStr       = get_param(activeConfigSet, 'CustomSymbolStr');
  MangleLength          = get_param(activeConfigSet, 'MangleLength');
  switchTarget(activeConfigSet, accelSystemTargetFile, []);
  set_param(hModel,'RTWTemplateMakeFile',  accelTemplateMakeFile);
  set_param(hModel,'RTWMakeCommand',       accelMakeCommand);
  set_param(hModel,'RTWBuildArgs',         '');
  set_param(hModel,'RTWGenerateCodeOnly',  'off');
  set_param(activeConfigSet, 'CustomSymbolStr', CustomSymbolStr);
  set_param(activeConfigSet, 'MangleLength',    MangleLength);

  warningState = warning;   % don't disp backtraces when we get rtwgen errors
  warning on

  % xxx{Murali} How to distinguish between the menu vs. command line calls?
  if 0
    % this will push nags into the slsfnagctlr
    errmsg = simprm('RTWPage','Build',-2);
    warning(warningState);
    error(errmsg);
  else
    % this will *not push nags into the slsfnagctlr
    rtwbuild(modelName);
    warning(warningState);
  end

%endfunction LocalAccelbuildprivate


%[eof] accelbuild_private.m
