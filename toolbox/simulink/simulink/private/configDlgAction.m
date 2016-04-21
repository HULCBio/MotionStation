function [ok, msg] = configDlgAction(hDlg, hObj, action, page)
%

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.8 $

  % prevent recursive call
  persistent entry;
  
  if isempty(entry)
    entry = 1;
  end
  
  needUpdate = hDlg.hasUnappliedChanges;
  
  ok = 1;
  msg = '';
  
  if ~isa(hObj, 'Simulink.ConfigSetDialogController')    
    return
  end
  
  hCache = hObj.getSourceObject;
  model  = hCache.getModel;

  if (isequal(action, 'preApply') || isequal(action, 'apply')) && needUpdate
    [ok, msg] = loc_preApplyPageAction(hDlg, hObj, page);
    if ~ok || isequal(action, 'preApply')
      return;
    end
    
    % preApply action stop here; postApply action does not come in here; apply
    % action come in here and the go to the next step.
  end
  
  if (strcmp(action, 'postApply') || strcmp(action, 'apply')) && ...
        entry == 1 && needUpdate
    % since we only have pre-apply callback, we need to apply the changes first
    entry = 2;
    hDlg.apply;
  end
  
  if entry > 1
    entry = 1;
    return;
  end

  if strcmp(action, 'preApply')
    return;
  end
  
  % We are entering the post apply domain for non-cached dialog
  
  switch action
    
   case {'apply', 'postApply'}

    if ~isempty(model) 
      if isequal(hCache, get_param(model, 'ConfigDialogCache'))
      
        hSrc = getActiveConfigSet(model);
        
        if needUpdate
          % copy information from cache to source
          hSrc.assignFrom(hCache, true);
          hSrc.TargetSwitched = 'off';
          hCache.TargetSwitched = 'off';
          
          % Call to refresh any buddy dialog in model explorer
          dar = DAStudio.Root;
          dame = find(dar, '-isa', 'DAStudio.Explorer');
          if ~isempty(dame)
            daDlg = dame.getDialog;
            if ~isempty(daDlg) && isa(daDlg, 'DAStudio.Dialog') && ...
                  isa(daDlg.getDialogSource, 'Simulink.BaseConfig') && ...
                  isequal(daDlg.getDialogSource.getConfigSet, hSrc)
              daDlg.refresh;
            end
          end
        else
          % carry over graphical setting
          hSrc.CurrentDlgPage = hCache.CurrentDlgPage;
        end
        
        position = hDlg.Position;
        set_param(model, 'ConfigPrmDlgPosition', ...
                         [position(1) position(2) position(1)+position(3) position(2)+position(4)]);
      else
        
        % refresh the corresponding simprm dialog if it is open
        csDlg = get_param(model, 'SimPrmDialog');
        if ~isempty(csDlg) && isa(csDlg, 'DAStudio.Dialog')
          csDlg.refresh;
        end
      end        
    end
    
    % Post apply callback for STFCustomTarget
    hConfigSet = hCache.getConfigSet;
    if ~isempty(hConfigSet)
      hTarget = getComponent(hConfigSet, 'any', 'Target');
      
      if isa(hTarget, 'Simulink.STFCustomTargetCC')
        if exist('rtwprivate')
          [ok, errmsg] = rtwprivate('stfTargetApplyCB', hDlg, hTarget);
        end
      end

      if strcmp(class(hConfigSet.up), 'Simulink.Root')
        rootCS = getActiveConfigSet(0);
        set(rootCS, 'HasUnsavedChanges', 'on');
        hDlg.refresh;
      end
    end
    
   case {'ok', 'cancel'}

    loc_closePageAction(hDlg, hObj, page);
    
    if ~isempty(model) && isequal(hCache, get_param(model, 'ConfigDialogCache'))
      
      % if dialog is going away, so is the cache
      set_param(model, 'ConfigDialogCache', []);
    end
    
   otherwise
    error(['Unknown action "' action '" when closing configuration dialog.']);
  end
  
  
  
function [ok, errmsg] = loc_preApplyPageAction(hDlg, hObj, page)
  
  ok = 1;
  errmsg = '';

  hSrc = hObj.getSourceObject;
  
  if isempty(page) || isequal(page, 'Solver')
    
    if isequal(getProp(hSrc, 'SampleTimeConstraint'), 'Specified')
      strVal = hDlg.getWidgetValue('Tag_ConfigSet_Solver_SampleTimeProperty');
      if ~isempty(strVal)
        try
          newVal = slprivate('convertSampleTimeInfo', strVal);
          set_param(hSrc, 'SampleTimeProperty', newVal);
        catch
          errmsg = ['Error applying changes in ''Solver'' page:' sprintf('\n') lasterr];
          ok = 0;
        end
      end
    end
  end
  
  if isempty(page) || isequal(page, 'ModelReference')
    tag = 'Tag_ConfigSet_ModelReferencing_ModelDependencies';
    strVal = mdlRefDepsComment(hObj, true, tag, hDlg);
    set_param(hSrc, 'ModelDependencies', strVal);
  end

function loc_closePageAction(hDlg, hObj, page)
  
  hSrc = hObj.getSourceObject;
  
  if isempty(page) || isequal(page, 'Optimization')  
    config_dlg_configure_param('ParentClose', hDlg, hSrc);
  end
  
  if isempty(page) || isequal(page, 'RTW')    
    browser = hObj.TLCBrowser;
    if ~isempty(browser) && isa(browser, 'RTW.TargetBrowser')
      browserDlg = get(browser, 'ThisDlg');
      if ~isempty(browserDlg) && isa(browserDlg, 'DAStudio.Dialog')
        browserDlg.connect([], 'up');
        delete(browserDlg);
        set(browser, 'ThisDlg', []);
      end
    end
    hObj.TLCBrowser = [];
  end
  
