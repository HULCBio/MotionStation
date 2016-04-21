function stfInitTarget(unused, h)
% STFINITTARGET converting common options in system target file to the right place in 
% configuration set object

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.10 $
  
  if ~isa(h, 'Simulink.STFCustomTargetCC')
    error(['Unsupported class type']);
    return;
  end
  
  hConfigSet = getConfigSet(h);
  DlgData    = get(h, 'DialogData');
  model      = hConfigSet.getModel;
  
  if isempty(hConfigSet)
    warning(['Target initialization not performed when target component is not part of a configuration set object']);
    return;
  end
  
  hRTW = hConfigSet.getComponent('Real-Time Workshop');
  
  % If rtw not installed or available
  if ~(exist('rtwprivate')==2 | exist('rtwprivate')==6)
    error(['The required Real-Time Workshop components are not available.']);
    return;
  end
  
  fileName = get(h, 'SystemTargetFile');
  [fullSTFName,fid, prevfpos] = rtwprivate('getstf', [], fileName);
 
  if (fid == -1)
    error(['File "' fileName '" not found']);
    return;
  end
  
  [rtwoptions, gensettings] = rtwprivate('tfile_optarr', fid);

  closestf(fid, prevfpos);

  if isfield(gensettings, 'Version') && ischar(gensettings.Version) && ...
        str2num(gensettings.Version) >= 1
    supportCB = true;
  else
    supportCB = false;
  end

  % Update corresponding field in configuration set
  for i = 1:length(rtwoptions)
    thisOption        = rtwoptions(i);
    thisOptionName    = thisOption.tlcvariable;
    thisOptionDefault = thisOption.default;
    thisOptionPrompt  = thisOption.prompt;
    thisOptionEnable  = thisOption.enable;

    if ~isempty(thisOptionName) & (~isempty(thisOptionDefault) | ...
                                   ~isempty(thisOptionEnable))

      name = '';
      switch thisOptionName
       case 'RTWExpressionDepthLimit'
        name = 'ExpressionFolding';
       case 'MaxRTWIdLen'
        name = 'MaxIdLength';
       case {'RollThreshold',
             'InlineInvariantSignals',
             'BufferReuse',
             'EnforceIntegerDowncase'
             'FoldNonRolledExpr',
             'LocalBlockOutputs',
             'IncHierarchyInIds',
             'GenerateComments',
             'ForceParamTrailComments',
             'ShowEliminatedStatement',
             'IgnoreCustomStorageClasses',
             'IncDataTypeInIds', 
             'PrefixModelToSubsysFcnNames', 
             'InlinedPrmAccess',
             'GenerateReport',
             'RTWVerbose',
             'CombineOutputUpdateFcns',
             'ERTCustomFileBanners',
             'SuppressErrorStatus',
             'InsertBlockDesc',
             'LogVarNameModifier',
             'ZeroInternalMemoryAtStartup',
             'ZeroExternalMemoryAtStartup',
             'InitFltsAndDblsToZero', 
             'GenerateSampleERTMain', 
             'MatFileLogging',
             'MultiInstanceERTCode',
             'PurelyIntegerCode'}
        name = thisOptionName;
        
      end

      if isfield(thisOption, 'opencallback') && ~isempty(thisOption.opencallback) ...
            && supportCB && false   % Discontinue usage of opencallback
        try
          loc_eval(h, [], thisOption.opencallback);
        catch
          slsfnagctlr('Clear', ...
                      get_param(model, 'name'), ...
                      'RTW Options category');
          warnmsg = (['The RTW option "' thisOptionPrompt '" has some invalid settings', ...
                      sprintf('\n'), ...
                      'in its opencallback field. Please see Real-Time Workshop User''s Guide' ...
                      sprintf('\n'), ...
                      'as reference to set it up correctly. Last recorded error message:' ...
                      sprintf('\n'), ...
                      lasterr]);
          
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
      
      if hConfigSet.hasProp(name) & ~h.hasProp(name)
        if ~isempty(thisOptionDefault)          
          set_param(hConfigSet, name, thisOptionDefault);
        end
        if ~isempty(thisOptionEnable) & strcmp(thisOptionEnable, 'off')
          setPropEnabled(hConfigSet, name, 0);
        end
      end
    end
  end % for i = 1:length(rtwoptions)
  
  if isfield(gensettings, 'SelectCallback') & ~isempty(gensettings.SelectCallback) & ...
        supportCB
    try
      loc_eval(h, [], gensettings.SelectCallback);
    catch
      slsfnagctlr('Clear', ...
                  get_param(model, 'name'), ...
                  'RTW Options category');
      warnmsg = (['Error while evaluating the ''SelectCallback'' in system target ', ...                  
                  sprintf('\n'), ...
                  'file ''',fileName, '''.  Last recorded error message:' ...
                  sprintf('\n'), ...
                  lasterr]);
          
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
    
function loc_eval(hSrc, hDlg, evalStr)
  model = hSrc.getModel;
  hConfigSet = hSrc.getConfigSet;
  eval(evalStr);
