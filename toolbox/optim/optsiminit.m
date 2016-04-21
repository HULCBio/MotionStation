%OPTSIMINIT Sets up necessary data files for optimization of optsim.
% Define Optimization parameters

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:27 $


% Define Tunable Variable initial values
Kp = 0.63;
Ki = 0.0504;
Kd = 1.9688;

% Define Uncertain Variable initial values
a2 = 43;
a1 = 3;

disp('Done initializing optsim.')
% end optsiminit
