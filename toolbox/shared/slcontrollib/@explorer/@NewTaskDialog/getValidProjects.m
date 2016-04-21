function ComboBoxObject = getValidProjects(this);
% GETVALIDPROJECTS 

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:12 $

import java.lang.* java.awt.* javax.swing.*;

%% Create an empty default list model
ComboBoxObject = DefaultComboBoxModel;

%% If Simulink Control Designer exists add it to the list
if license('test','Simulink_Control_Design')
  ComboBoxObject.addElement('Linearization Task');
%   ComboBoxObject.addElement('Controller Design Task');
end

%% If Simulink Parameter Estimator exists add the project types to the list
if exist( 'slparamestim' )
  ComboBoxObject.addElement('Parameter Estimation Task');
end

%% If MPC GUI exists add the project types to the list
if exist( 'slmpctool' )
  ComboBoxObject.addElement('Model Predictive Control Task');
end
