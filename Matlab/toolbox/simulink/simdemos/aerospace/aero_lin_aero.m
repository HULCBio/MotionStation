% AERO_LIN_AERO - Linear models from Simulink
%
% See Also :  Simulink models 'aero_guidance_airframe' and
%             'aero_guidance'

% J.Hodgson
% Copyright 1990-2002 The MathWorks, Inc.
% $Revision: 1.16.4.1 $ $Date: 2004/04/13 00:34:41 $

%
% Initialize Guidance Model
%
echo off
aero_guid_dat;
load_system('aero_guidance_airframe');

clc
disp('This script file (aero_lin_aero.m) demonstrates how to trim and')
disp('linearize the non-linear Simulink model aero_guidance_airframe.mdl.')
disp('The first problem is to find the elevator deflection, and the')
disp('resulting trimmed body rate (q), which will generate a given')
disp('incidence value when the missile is travelling at a set speed.')
disp('Once the trim condition is found, a linear model can be derived')
disp('for the dynamics of the perturbations in the states around ')
disp('the trim condition. ')
disp(' ')
disp('          Fixed parameters  :- ')
disp('                              Mach Number ')
disp('                              Incidence ')
disp('                              Body Attitude')
disp('                              Position')
disp('          Trimmed parameters :-')
disp('                              Elevator deflection')
disp('                              Body rate')
disp('          Output parameters :-')
disp('                              Normal acceleration az')
disp(' ')
disp('Step 1 : Define fixed state values.')
disp(' ');

echo on
h_ini       = 10000/m2ft;      % Trim Height [m]
M_ini       = 3;               % Trim Mach Number
alpha_ini   = -10*d2r;         % Trim Incidence [rad]
theta_ini   = 0*d2r;           % Trim Flightpath Angle [rad]
echo off

v_ini   = M_ini*(340+(295-340)*h_ini/11000); 	% Total Velocity [m/s]

disp(' ')
disp('Step 2 : Initialize states which are allowed to vary.')
disp(' ');echo on

q_ini       = 0;               % Pitch Body Rate [rad/sec]

echo off;
disp(' ')
disp('** Press any key **')
pause

clc
if exist('slcontrol','dir') % Check to see if Simulink Control Design is present
disp('Step 3 : Find operating specification object.')
disp(' ');

echo on
opspec = operspec('aeroblk_guidance_airframe');

echo off
disp(' ')
disp('** Press any key **')
pause

clc
disp('Step 4 : Define state specifications.')
disp(' ');
disp('The first state specifications are Position states which are known');
disp('but not at steady state.');
disp(' ');

echo on
opspec.State(1).Known = [1;1];
opspec.State(1).SteadyState = [0;0];

echo off
disp('The second state specification is Theta which is known');
disp('but not at steady state.');
disp(' ');

echo on
opspec.State(2).Known = 1;
opspec.State(2).SteadyState = 0;

echo off
disp('The third state specifications are body axis angular rates which the');
disp('variable w is at steady state.');
disp(' ');

echo on
opspec.State(3).Known = [1 1];
opspec.State(3).SteadyState = [0 1];

echo off
disp(' ')
disp('** Press any key **')
pause

clc
disp('Step 5 : Search for operating point that meets this specification.')
disp(' ');

echo on 
op = findop('aeroblk_guidance_airframe',opspec);

echo off
disp(' ')
disp('** Press any key **')
pause

clc
disp('Step 6 : Linearize model.')
disp(' ');
disp('Specify input and output points');
disp(' ');

echo on 
io(1) = linio('aeroblk_guidance_airframe/Fin Deflection',1,'in');
io(2) = linio(sprintf(['aeroblk_guidance_airframe/Aerodynamics &\n', ...
                    'Equations of Motion']),3,'out');
io(3) = linio('aeroblk_guidance_airframe/Selector',1,'out');

sys = linearize('aeroblk_guidance_airframe',op,io);

echo off
disp(' ')
disp('** Press any key **')
pause

clc
disp('Step 7 : Plot Bode magnitude reponse for each condition.')
disp(' ');

echo on 
bodemag(sys);

else % use Control Toolbox & Simulink
disp('Step 3 : Find names and ordering of states from Simulink model.')
disp(' ');
echo on

[sizes,x0,names]=aero_guidance_airframe([],[],[],0);

echo off
for i = 1:length(names)
   n = max(findstr(names{i},'/'));
   state_names{i}=names{i}(n+1:end);
end

disp(' ')
disp(' State Names :-')
disp(' ')
disp(state_names)
disp(' ')
disp('** Press any key **')
pause
clc
disp(' Step 4: Specify which states (fixed_states) are fixed,')
disp('         and which state derivatives (fixed_derivatives) are to be trimmed.')
disp(' ')
echo on

fixed_states            = [{'U,w'} {'Theta'} {'Position'}];
fixed_derivatives       = [{'U,w'} {'q'}];        % w and q
fixed_outputs           = [];                     % Velocity
fixed_inputs            = [];

echo off
n_states=[];n_deriv=[];
for i = 1:length(fixed_states)
   n_states=[n_states find(strcmp(fixed_states{i},state_names))];
end
for i = 1:length(fixed_derivatives)
   n_deriv=[n_deriv find(strcmp(fixed_derivatives{i},state_names))];
end
n_deriv=n_deriv(2:end);                          % Ignore U

disp(' ')
disp('** Press any key **')
pause;
clc
disp('Step 5 : Trim model')
disp(' ')
echo on

[X_trim,U_trim,Y_trim,DX]=trim('aero_guidance_airframe',x0,[0],[0 0 v_ini]', ...
                                          n_states,fixed_inputs,fixed_outputs, ...
                                          [],n_deriv);

echo off
disp(' ')
disp(['Trimmed states with incidence = ' num2str(alpha_ini/d2r) ' degrees and,  Mach number = ' num2str(M_ini)])
disp(' ')
disp([char(state_names) num2str(X_trim,4)])
disp(' ')
disp(['Trimmed elevator deflection = ' num2str(U_trim/d2r,4) ' degrees'])
disp(['Trimmed body rate           = ' num2str(Y_trim(1)/d2r,4) ' degrees/second'])
disp(['Trimmed normal acceleration = ' num2str(Y_trim(2)/9.81',4) ' g''s'])
disp(' ')
disp('** Press any key **')
pause
clc

disp('Step 6 : Derive linear model for perturbations around trim condition (X_trim, U_trim).')
disp(' ')
disp('          dx/dt = A x + B u')
disp('          y     = C x + D u')
disp(' ');echo on

[A,B,C,D]=linmodv5('aero_guidance_airframe',X_trim,U_trim);

echo off
disp(' ')
disp('** Press any key **')
pause;
clc

disp(' Step 7 : Arrange and display linearized model for trimmed states.')
if exist('control','dir') % Check to see if Control toolbox is present
disp(' ');echo on

%
% Select trimmed states and create LTI object
%
airframe = ss(A(n_deriv,n_deriv),B(n_deriv,:),C([2 1],n_deriv),D([2 1],:));
set(airframe,'statename',state_names(n_deriv), ...
             'inputname',{'Elevator'}, ...
             'outputname',[{'az'} {'q'}]);

%
% Transform State Space model to zero/pole/gain model
%
zpk(airframe)

%
% View Frequency Response of model
%
ltiview('bode',airframe)

else

        disp(' ');
    disp('A matrix')
        disp(' ');
    disp(state_names(n_deriv))
    disp(A(n_deriv,n_deriv))
    disp('B matrix')
        disp(' ');
    disp(B(n_deriv,:))
    disp('C matrix - Ouputs az & q')
        disp(' ');
    disp(C([2 1],n_deriv))
    disp('D matrix')
        disp(' ');
    disp(D([2 1],:))
end
end

echo off
alpha_ini=0;
disp(' ')
disp('** Linearization demo complete **')
