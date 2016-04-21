function AddNewSession(this, model, sessiontype)
% ADDNEWSESSION 

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:24 $

% Open the model if it has not been opened
try
  open_system(model);
  model = gcs;
catch
  errordlg('Invalid Simulink Model', 'Open Model Error')
  return
end

if strcmpi(sessiontype,'Linearization Project')
  simcontdesigner('initialize_linearize',model);
elseif strcmpi(sessiontype,'Controller Design Project')
  simcontdesigner('initialize_controller_design',model);
elseif strcmpi(sessiontype, 'Parameter Estimation Project')
  slparamestim('initialize', model);
elseif strcmpi(sessiontype, 'Model Predictive Control Project')
  slmpctool('initialize');
end
