function continueProcess = checkSimPrm(hMdl)
% CHECKSIMPRM: check whether there is any unapplied changes to simprm dialog

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $

  continueProcess = true;  
  hDlg = get_param(hMdl, 'SimPrmDialog');
  if ~isempty(hDlg) && isa(hDlg, 'DAStudio.Dialog')
    if hDlg.hasUnappliedChanges
      choice = questdlg(['There are unapplied changes in the Configuration ', ...
                         'Parameter dialog.  Do you want to apply ', ...
                         'the changes, discard the changes, or cancel', ...
                         ' this operation?'], ...
                        get_param(hMdl, 'name'), ...
                        'Apply', 'Discard', 'Cancel', 'Apply');
      % force the quest dialog to go away
      drawnow;
      switch(choice)
       case 'Apply',
        hDlg.apply;
        continueProcess = true;
       case 'Discard',
        % Waiting for Adas term to provide true refresh capability
        % geck 166150
        delete(hDlg);
        continueProcess = true;
       case 'Cancel'
        % Set the simulation command to stop so that simulatioin process
        % will terminate.  However, slbuild will use the return flag
        % continueProcess
        set_param(hMdl, 'SimulationCommand','stop');
        continueProcess = false;
       otherwise,
        error('M-assert');
      end
    end    
  end
  
