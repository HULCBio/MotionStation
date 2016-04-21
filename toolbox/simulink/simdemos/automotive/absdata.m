%ABSDATA Data for the ABS braking model
%   ABSDATA script which places abs model parameters in the MATLAB workspace
%   when typed at the command line
%
%   See also RUNABS

%   Author(s): L. Michaels, S. Quinn, 12/1/97 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

fprintf('Loading data for ABS braking model...')

g = 32.18;
v0 = 88;
Rr = 15/12;  % Wheel radius
Kf = 1;
m = 50;
PBmax = 1500;
TB = 0.01;
I = 5;

%
% Mu slip curve
%
slip = (0:.05:1.0); 
mu = [0 .4 .8 .97 1.0 .98 .96 .94 .92 .9 .88 .855 .83 .81 .79 .77 .75 .73 .72 .71 .7];
ctrl = 1;

disp('done.');
