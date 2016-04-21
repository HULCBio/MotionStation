function AddNewProject(this, model, sessiontype)
% ADDNEWPROJECT 

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:14 $

% Open the model if it has not been opened
try
    open_system(model);
    model = gcs;
catch
    errordlg('Invalid Simulink Model', 'Open Model Error')
    return
end

if strcmpi(sessiontype,'Linearization Task')
    simcontdesigner('initialize_linearize',model);
elseif strcmpi(sessiontype,'Controller Design Task')
    simcontdesigner('initialize_controller_design',model);
elseif strcmpi(sessiontype,'Block Linearization Task')
    simcontdesigner('linearizeblock',model);  
elseif strcmpi(sessiontype, 'Parameter Estimation Task')
    slparamestim('initialize', model);
elseif strcmpi(sessiontype, 'Model Predictive Control Task')
    slmpctool('initialize', model);
end
