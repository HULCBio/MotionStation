function simprmDlgCloseCallback(hDlg, action)
% SIMPRMDLGCLOSECALLBACK 

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

  hSrc  = getDialogSource(hDlg);
  model = hSrc.getModel;
  hConfigSet = hSrc.getConfigSet;
  if isempty(hConfigSet)
    return;
  end
  
  hTarget    = getComponent(hConfigSet, 'any', 'Target');

  % no need to proceed if it is not stf target
  if ~isa(hTarget, 'Simulink.STFCustomTargetCC')
    return;
  end

  DlgData    = get(hTarget, 'DialogData');
  
  % If rtw not installed or available
  if ~(exist('rtwprivate')==2 | exist('rtwprivate')==6)
    error(['The required Real-Time Workshop components are not available.']);
    return;
  end
  
  fileName = getProp(hConfigSet, 'SystemTargetFile');
  [fullSTFName,fid, prevfpos] = rtwprivate('getstf', [], fileName);
 
  if (fid == -1)
    error(['File "' fileName '" not found']);
    return;
  end
  
  rtwoptions = rtwprivate('tfile_optarr', fid);

  rtwprivate('closestf', fid, prevfpos);
  
  if (DlgData.supportCB)
    assignin('caller', 'model', model);
    assignin('caller', 'hConfigSet', hConfigSet);
    assignin('caller', 'hDlg', hDlg);
    assignin('caller', 'hSrc', hTarget);
  end
  
  % Update corresponding field in configuration set
  for i = 1:length(rtwoptions)
    thisOption        = rtwoptions(i);
    thisOptionName    = thisOption.tlcvariable;
    thisOptionPrompt  = thisOption.prompt;
    if isfield(thisOption, 'closecallback') & ~isempty(thisOption.closecallback) ...
          & DlgData.supportCB
      try
        evalin('caller', thisOption.closecallback);
      catch
        slsfnagctlr('Clear', ...
		    get_param(model, 'name'), ...
		    'RTW Options category');
	warnmsg = (['The RTW option "' thisOptionPrompt '" has some invalid settings', ...
		    sprintf('\n'), ...
		    'in its closecallback field. Please see Real-Time Workshop User''s Guide' ...
		    sprintf('\n'), ...
		    'as reference to set it up correctly']);

	nag                = slsfnagctlr('NagTemplate');
	nag.type           = 'Warning';
	nag.msg.details    = warnmsg;
	nag.msg.type       = 'SYSTLC';
	nag.msg.summary    = warnmsg;
	nag.component      = 'RTW';
	nag.sourceName     = getProp(hConfigSet, 'SystemTargetFile');
	nag.sourceFullName = evalc( ...
	    ['which ' getProp(hConfigSet, 'SystemTargetFile')]);
        
	slsfnagctlr('Naglog', 'push', nag);
	slsfnagctlr('ViewNaglog');
      end
    end
  end
