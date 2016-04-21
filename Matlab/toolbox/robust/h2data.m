% ABOUT H2DEMO1:
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
% The designed H_2 controller is given by [ae,be,ce,de]. During the
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
% h2lqg     --- H_2 optimal controller design
%
% A MIMO control system can be designed using a similar structure.
%

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $

% pre-calculated data for h2demo1
disp('loading H_2 data...')
% plant system
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
% performance weighting function
num1=[1 2 1]/100/1.5;
den1=[1/30/30 2/30 1];
% robust weighting function
num3=3.16*[1/300 1];
den3=[1/10 1];
% inout weighting function
num2=[1/10 1];
den2=[1 1];
ae = [
-580.8535 -434.9162  156.8785   37.3680  -84.0740  148.3578  283.8053  1.0754
 536.8839  399.0551 -142.7945  -35.8304   76.4565 -136.7502 -262.2886 -0.9717
-347.4481 -261.4218   99.3504   26.2048  -47.4273   87.5253  170.9555  0.4758
-126.5428  -93.6142   29.1575    7.7284  -18.5234   32.3450   61.9881  0.2230
-192.8846 -145.0006   55.0188   10.8707  -29.0403   50.3266   96.1560  0.3817
 324.7107  242.9528  -90.8090  -18.7097   51.4394 -127.2741 -253.2817 -0.6090
 680.2542  508.7275 -189.8258  -39.2972  107.8616 -288.4519 -590.1309 -0.9654
   9.7948    7.3611   -2.7937   -0.5505    1.5814   -5.2320  -12.1836 -0.9387];
be=[-6.3295
     5.9574
     1.1247
    -0.7807
     1.1156
    -0.1364
     0.0596
    -0.0485];
ce=[-91.5798  -68.8587   26.0568  5.4869  -12.9152  23.1599   44.8974  0.1389];
de = [0];
disp('Done')