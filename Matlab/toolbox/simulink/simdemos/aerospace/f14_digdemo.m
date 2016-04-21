% The example will take you through the entire design of a digital autopilot 
% for a high angle of attack controller.  The text of this show assumes that 
% you have the Control System Toolbox, Simulink Control Design, Simulink, 
% Real Time Workshop, and Stateflow.  However the example changes depending 
% on which of these tools you have. Obviously, since this example illustrates 
% a control system design using MATLAB's object oriented  programming features 
% (and in particular, lti objects), the Control System Toolbox and Simulink 
% Control Design is a significant part of the demonstration.  To obtain a 
% demonstration of the Control System Toolbox and/or Simulink Control Design
% contact your sales agent, or visit the MathWorks web site (www.mathworks.com)
% and request a demo version of the Control System Toolbox

% This is the master script for the f14 demo.
% The first action required is to determine what products the user has.
% The options are:
%
%    1. Both control toolbox and stateflow are detected, and the complete
%        design GUI is used.
%   
%    2. The user has stateflow and not control and Simulink Control Design:
%	    -- In this case the model does not have the control design in it
%    
%    3. The user has control and not stateflow:
%       -- In this case a model of the F14 without stateflow is used
%
%    4 The user only has Simulink (No control toobox or stateflow):
%       -- In this case only the F14 model is shown and not the GUI


%   Copyright 2000-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2004/04/15 00:39:03 $

% Test for licenses
cst_scd = license('test','Control_Toolbox') && license('test','Simulink_Control_Design');
stateflow = license('test','Stateflow');

if (cst_scd && stateflow)
    modelName = 'f14_digital';
   
 elseif (stateflow && ~cst_scd)
   disp('Stateflow has been detected.')
   disp('You do not have the Control System Toolbox and Simulink Control')
   disp('Design so you can not exercise all the control system design')
   disp('features in this demo.')
   modelName = 'f14_dig_sf';
    
 elseif (cst_scd && ~stateflow) 
   disp('Control Toolbox and Simulink Control Design have been detected')
   disp('You do not have Stateflow, so this example will not illustrate')
   disp('the anti wind-up feature discussed in this demo.')
   modelName = 'f14_dig_ctrl';

 else
   modelName = 'f14_dig_basic';
end

open_system(modelName)
playshow f14_show





