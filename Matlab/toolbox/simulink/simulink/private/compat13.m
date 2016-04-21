function simOptions = compat13(solver,X0,V1_Options)
%COMPAT13 Convert 1.3 solver options to 2.0 options.
%   COMPAT13 converts the SIMULINK 1.3 solver options into
%   a vector of options that is compatible with SIMULINK 2.0.
%   The conversion makes the following mappings:
%
%     X0           initial conditions     'InitialState'
%     solver       algorithm              'Solver'
%     options(1)   relative error         'RelativeTol'
%     options(2)   min step size          obsolete
%     options(3)   max step size          'MaxStepSize'
%     options(4)   used by adams/gear     unused
%     options(5)   display upon minstep   'TraceInfo'
%     options(6)   plot                   'Plot'
%
%   See also EULER, RK23, RK45, ADAMS, GEAR, LINSIM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

%
% Pad V1_Options (SIMULINK 1.3 options) to full length of 6.
%
if length(V1_Options) < 6,
  V1_Options(length(V1_Options)+1:6) = 0;
end

%
% Create indices for each option element from the SIMULINK 1.3 euler, etc
% commands.
%
V1_ID.RelTol          = 1;
%-----------------------------
%V1_ID.MinStepSize    = 2;   % MinStepSize is obsolete
%-----------------------------
V1_ID.MaxStep         = 3;   % no longer used
V1_ID.NotUsed         = 4;
V1_ID.Trace           = 5;
V1_ID.Plot            = 6;

%
% Create simOptions structure
%
simOptions = simset('Solver',solver,'InitialState',X0);

if V1_Options(V1_ID.RelTol) ~= 0,
  simOptions = simset(simOptions,'RelTol',V1_Options(V1_ID.RelTol));
end

if V1_Options(V1_ID.MaxStep) ~= 0,
  simOptions = simset(simOptions,'MaxStep',V1_Options(V1_ID.MaxStep), ...
		      'FixedStep',V1_Options(V1_ID.MaxStep));
end

if V1_Options(V1_ID.Trace) ~= 0,
  simOptions = simset(simOptions,'Trace','siminfo');
end
