% ABOUT LTRDEMO2:
%
% This demo provides a SISO closed loop control system designed
% by using the Robust Control Toolbox. Use the pulldown menus to run
% the simulation. Double-click the blocks on the bottom for
% more functions.
%
% All of the parameters are read in from MATLAB workspace variables.
% The plant model is [a,b,c,d], Q and R are the LQ regulator
% design weighting matrices, and Th and Xi are loop
% transfer recovery weighting matrices.
%
% The designed controller is given by [ae,be,ce,de]. In the simulation
% both system perturbation (additive perturbation and multiplicative
% perturbation) and measurement noise are added.
%
% By changing the plant and the weighting function parameters, you
% can convert the example to solve a problem of your own.
%
% Re-Load Data
% Re-load data from file. This refreshes the data in the workspace.
%
% Re-Design
% After changing the workspace parameters, you should redesign the
% controller to fit your data.
%
% In the design, the following command in the Robust Control Toolbox
% is used: ltry  --- LQG loop transfer recovery controller design
%
% A MIMO control system can be designed using a similar structure.
% A simpler simulation is shown in LTRDEMO1
%

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $

% pre-calculated data for ltrdemo2
disp('loading LTR data...')
a = [  -1.0285    0.9853   -0.9413    0.
   -1.2903   -1.0957    2.8689    1.5
    0.1871   -3.8184   -2.0788   -.2
    0.4069   -4.1636    2.5407   3.23];
b = [    0
    6.6389
         0
         0];
c = [  -1.7786    1.1390         0   -1.0294];
d = 0.000001;
Q = 0.1*c'*c;
R = eye(1,1);
Xi = 0.1 * b * b';
Th = eye(1,1);
ae= 1.0e+03 *...
[  -0.2500    0.1798   -0.0240   -0.2120
    2.6920   -1.9609    0.2792    2.3823
    3.3233   -2.3905    0.3057    2.8303
   -5.0789    3.6439   -0.4679   -4.3232];
be=[-0.1217
   -0.2869
    1.6246
   -2.4833];
ce=1.0e+04 * [-4.9402    3.5863   -0.4981   -4.3384];
de=[  0];
disp('Done')