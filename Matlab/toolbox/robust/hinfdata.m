% ABOUT HINFDM --- H_infinity DEMO
%
% This demo provides a SISO closed loop control system designed
% by using the Robust Control Toolbox. Use the pulldown menus to run
% the simulation. Double-click the blocks on the bottom for
% more functions.
%
% All of the parameters are read in from MATLAB workspace variables.
% The plant model is [a,b,c,d].
%   -1      num1(s)           num2(s)      -1      num3(s)
% w1  (s) = -------;  w2(s) = -------;   w3  (s) = -------
%           den1(s)           den2(s)              den3(s)
% are the performance weighting function, input weighting function, and
% robustness weighting function respectively. The curves inside the
% weighting function blocks are the magnitudes of the bode plots
% of each weighting function.
%
% The designed H_infinity controller is given by [ae,be,ce,de]. During the
% simulation system measurement noise is added.
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
% In this design, the following commands in the Robust Control
% Toolbox are used:
% augss     --- state space plant augmentation with weighting function
% obalreal  --- balance realization
% hinfsaf   --- h_infinity controller design
%
% A MIMO control system can be designed using a similar structure.
%

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $

% pre-calculated data for hinfdemo
disp('loading H_infinity data...')
a = [  -1.0285    0.9853   -0.9413    0.0927
   -1.2903   -1.0957    2.8689    4.7950
    0.1871   -3.8184   -2.0788   -0.9781
    0.4069   -4.1636    2.5407   -1.4236];
b = [         0
    6.6389
         0
         0];
c = [  -1.7786    1.1390         0   -1.0294];
d = 0;
num1=[1 2 1]/100/1.5;
den1=[1/30/30 2/30 1];
num3=3.16*[1/300 1];
den3=[1/10 1];
num2=[1/100 1/10];
den2=[1 1/10];
ae=[
 -128.3546   64.4236 -389.6330   50.1446  -43.6734   33.6223  -27.6848 261.3307
   38.1303  -20.9851  125.3862  -15.9982   16.6089   -8.7515    5.5914 -63.4715
 -180.5533   98.3216 -622.2643   81.7920  -98.7638   37.7746  -16.4259 259.3109
   22.5212  -11.7687   74.4666   -9.9342    9.3847   -4.6403    1.3007 -24.4900
  -18.7103    9.4631  -57.4201    7.8872  -12.4971    0.8487    7.2508 -19.2360
    2.5666   -1.3160   11.4041   -0.6599    3.5805   -2.7610    2.2395 -16.7860
   -6.4443    1.7350   -5.5548   -0.0908    7.0539    5.6556  -12.4661  62.7433
   10.5030   -2.4994    5.7297    0.0394   -9.5189   -8.3279    0.8816 -62.3812
];
be=[5.5496
   -1.0711
   -1.6475
   -1.5227
    2.7529
    2.5319
   12.4694
  -15.5621];
ce=[14.7152   -7.6451   45.7153   -6.2972  5.5336  -3.8930  3.5445 -33.0199];
de=[     0];
disp('Done')