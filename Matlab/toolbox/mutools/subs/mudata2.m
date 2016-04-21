% ABOUT MUSYNDEMO2:
%
% This demo provides a SISO closed loop control system designed
% by using Mu-Tools. Use the pulldown menus to run
% the simulation. Double-click the blocks on the bottom for
% more functions.
%
% All of the parameters are read in from MATLAB workspace
% variables. The plant model is [a,b,c,d]. The input and output
% weighting functions are:
%          num_i(s)              num_o(s)
% wi(s) = ----------;   wo(s) = ----------.
%          den_i(s)              den_o(s)
%
% The designed controller is given by [ak,bk,ck,dk]. During the
% simulation system perturbation and measurement noise are added.
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
% The following functions in MuSyn are used:
% sysic     --- system interconnection
% hinfsyn   --- H_infinity controller design
% mu        --- Mu analysis
% musynfit  --- curve fitting
% mmult     --- system multiplication
%
% A simpler SISO example is given in musyndm1 and a MIMO example is given
% in musyndm3.
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
%   $Revision: 1.7.2.3 $

% data file of mu-synthesis demo1 for SIMULINK
% [a b c d] for plant
% [ak bk ck dk] for controller
% [num den] for weighting
% g1 and k1 are closed loop system and controller system matrix
%

disp('Loading data');
a = [
  -3.6600e+01  -1.8923e+01
  -1.9000e+00   9.8300e-01];
b = [
  -4.1400e-01
  -7.7800e+01 ];
c = [       0   5.7300e+01];
d =         0;
ak = [
  -9.0892e+01  -3.1427e+02
   3.1427e+02  -4.5083e+03];
bk = [
  -3.6226e-01
   5.9251e-01 ];
ck = [
  -3.6226e-01  -5.9251e-01 ];
dk =        0;
num_i =[   50        5000];
den_i =[    1       10000];
num_o = [
   5.0000e-01   1.5000e+00];
den_o = [   1       10000];
g1 = [
  -9.0892e+01  -3.1427e+02            0  -2.0758e+01  -3.6226e-01   4.0000e+00
   3.1427e+02  -4.5083e+03            0   3.3951e+01   5.9251e-01            0
   1.4998e-01   2.4530e-01  -3.6600e+01  -1.8923e+01            0            0
   2.8184e+01   4.6097e+01  -1.9000e+00   9.8300e-01            0            0
            0            0            0   5.7300e+01            0            0
            0            0            0            0            0         -Inf
];
k1 = [
  -9.0892e+01  -3.1427e+02  -3.6226e-01   2.0000e+00
   3.1427e+02  -4.5083e+03   5.9251e-01            0
  -3.6226e-01  -5.9251e-01            0            0
            0            0            0         -Inf];
disp('...done');
disp('>>');