function parsweepdemo
% PARSWEEPDEMO Demonstrates parameter updates in xPC.
%
%   PARSWEEPDEMO takes the model xpcosc.mdl, builds it and downloads it to the
%   target PC. It then sets the stop time to 0.2 seconds, and conducts several
%   runs of the application. The 'Gain1/Gain' (damping) parameter (the
%   property name is retrieved using the GETPARAMID function) is increased
%   each time, thus 'sweeping' it from 0.1 to 0.7 in steps of 0.5. After each
%   run, the output of the oscillator is uploaded and plotted. Finally, a 3-d
%   plot of the various outputs is displayed.
%
%   This demo uses the data logging feature of xPC Target to capture the
%   results of each run; specifically, output logging is used.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.2 $ $Date: 2004/04/08 21:05:23 $


if ~strcmp(xpctargetping, 'success')    % is connection with target working?
  error('Connection with target cannot be established');
end

% build xPC application xpcosc and download it onto the target
rtwbuild('xpcosc');
Stoptime=0.2;
tg = xpc;                               % create an xPC Object

tg.SampleTime = 0.000250;               % set sample time to 250us
tg.StopTime   = Stoptime;                    % set stoptime to 0.2s

% get property name of parameter to tune
tPar = getparamid(tg, 'Gain1', 'Gain');

figh = findobj('Name', 'parsweepdemo');  % Does the figure exist?
if isempty(figh)
  figh = figure;
  set(figh, 'Name', 'parsweepdemo', 'NumberTitle', 'off');
else
  figure(figh);
end

y = []; flag = 0;
for z = 0.1 : 0.05 : 0.7                % loop over damping factor z
  if isempty(find(get(0, 'Children') == figh)), flag = 1; break; end
  %set(tg, tPar, 2 * 1000 * z);          % set damping factor
  setparam(tg,tPar,2 * 1000 * z);
  start(tg);                            % start model execution
  pause(2*Stoptime);
  outp = tg.OutputLog;                  % upload output and store in a matrix
  y    = [y, outp(:, 1)];
  t    = tg.time;
  plot(t, outp(:, 1));                  % plot uploaded data
  set(gca, 'XLim', [t(1), t(end)], 'YLim', [-10, 10]); % set axes limits
  title(['parsweepdemo: z = ', num2str(z)]);
  drawnow;
end

if ~flag,
  delete(gca);                            % Prepare for 3-d plot
  surf(t(1 : 200), [0.1 : 0.05 : 0.7], y(1 : 200, :)');
  colormap cool
  shading interp
  h = light;
  set(h, 'Position', [0.0125, 0.6, 10], 'Style', 'local');
  lighting gouraud
  title('parsweepdemo: demo finished');
end
close_system('xpcosc');

%% EOF parsweepdemo.m
