function stfTargetDlgCallback(hObj, hDlg, propName, val, callback, prompt)
% STFTARGETDLGCALLBACK

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
  
  model = hObj.getModel;
  hConfigSet = hObj.getConfigSet;
  try
    loc_eval(hObj, hDlg, propName, val, callback);
  catch
    slsfnagctlr('Clear', ...
                get_param(model, 'name'), ...
                'RTW Options category');
    warnmsg = (['The RTW option "' prompt '" has some invalid settings', ...
		    sprintf('\n'), ...
		    'in its callback field. Please see Real-Time Workshop User''s Guide' ...
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
  
function loc_eval(hSrc, hDlg, currentVar, currentVal, evalstr)
  model = hSrc.getModel;
  hConfigSet = hSrc.getConfigSet;
  eval(evalstr);
  