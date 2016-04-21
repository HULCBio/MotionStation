function configHelp(hDlg, hObj, schemaName, page)

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
  
  if strcmp(page, 'ConfigSet') && strcmp(schemaName, 'simprm')
    hSrc = hObj.getSourceObject;
    currentPage = hSrc.CurrentDlgPage;
    page = strtok(currentPage, '/');
  end
    
  switch page
   case 'ConfigSet' 
    dest = '';
    
   case 'Solver'
    dest = '';
    
   case {'Data Import', 'Data Import/Export'}
    dest = '_data';
    
   case 'Optimization'
    dest = '_optimization';
    
   case 'Diagnostics'
    dest = '_diagnostics';
    
   case 'Hardware Implementation'
    dest = '_hardware';
    
   case 'Model Referencing'
    dest = '_model_ref';
    
   case 'Real-Time Workshop'
    % special case rtw page since it does not belong to simulink doc
    helpview([docroot '/mapfiles/rtw_ug.map'], 'rtw_ui_overview');
    return;
    
   case 'Stateflow Simulation'
    % special case stateflow sim target page
    helpview([docroot '/toolbox/stateflow/stateflow.map'], ...
             'simulation_target_dialog');
    return;
    
   otherwise
    dest = '';
  end
  
  dest = ['model_config' dest];
  
  helpview([docroot '/mapfiles/simulink.map'], dest);

  
  % EOF
