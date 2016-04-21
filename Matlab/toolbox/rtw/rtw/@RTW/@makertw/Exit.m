function Exit(h)
%   EXIT is the method get called inside make_rtw method at exit point.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/15 00:23:48 $

% This is the 'exit' point of make_rtw. If makeRTWHookMFile is
% existing call it with Method equal 'exit'.
if ~isempty(h.MakeRTWHookMFile)
	feval(h.MakeRTWHookMFile, 'exit', h.ModelName, h.RTWRoot,...
        h.TemplateMakefile, h.BuildOpts, h.BuildArgs);
else
  if strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM')
    targetInfo = 'Successfully updated the model reference SIM target';
  elseif strcmpi(h.MdlRefBuildArgs.ModelReferenceTargetType,'RTW')
    targetInfo = 'Successfully updated the model reference RTW target';
  else
    targetInfo = 'Successful completion of Real-Time Workshop build procedure';
  end
  msg = sprintf('\n### %s for model: %s', targetInfo, h.ModelName);
  feval(h.DispHook{:}, msg);
end
