function scsoftwaredemo
% SCSOFTWAREDEMO Demonstrates software triggered xPC Scope
%
%    SCSOFTWAREDEMO takes the model xpcsosc.mdl, builds it, and downloads it
%    to the target PC. A scope of type host is added to the application, and
%    the signals 'Intergrator1' and 'Signal Generator' added to the
%    scope. The scope is set up in software triggering mode. The
%    application and the scope are then started.
%
%    The scope is monitored to determine when its data acquisition run is
%    complete, and the data is uploaded and plotted. This process repeats for
%    a total of 25 runs. The parameter Gain1/Gain (damping) (the property name
%    is determined via the GETPARAMID function) is changed to a random value
%    every fifth run. The software triggering is done each time after a random
%    pause of between 0 and 4 seconds.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.6.1 $ $Date: 2004/04/08 21:05:28 $

if ~strcmp(xpctargetping, 'success')    % is connection with target working?
  error('Connection with target cannot be established');
end

% build xPC application xpcosc and download it onto the target
rtwbuild('xpcosc');

tg = xpc;                               % create an xPC Object

tg.SampleTime = 0.000250;               % set sample time to 250us
tg.StopTime   = 10000;                  % set stoptime to a high value

start(tg);                              % start execution

% get property name of Parameter to tune
tPar = getparamid(tg, 'Gain1', 'Gain');

sc = addscope(tg);                      % define (add) a scope object

% get indices of signals 'Integrator1', 'Signal Generator'
signals(1) = getsignalid(tg, 'Integrator1');
signals(2) = getsignalid(tg, 'Signal Generator');

addsignal(sc, signals); % add signals to signal list of scope object

sc.NumSamples  = 200;                   % set number of samples to 200
sc.Decimation  = 4;                     % set decimation to 4
sc.TriggerMode ='Software';             % set TriggerMode to FreeRun

figh = findobj('Name','scsoftwaredemo');
if isempty(figh)
  figh = figure; set(figh, 'Name', 'scsoftwaredemo', 'NumberTitle', 'off');
else
  figure(figh);
end

m = 1; flag = 0;
for n = 1 : 25 % loop to acquire 25 data packages from the scope object
  if isempty(find(get(0, 'Children') == figh)), flag = 1; break; end
  if ~m
    setparam(tg, tPar, 2*1000*rand);
    % change parameter Gain1/Gain every fifth acquisition loop
    % to a random value between 0 and 2000
  end
  m = rem(m + 1, 5);

  start(sc);                            % start scope object

  while ~strcmp(sc.Status, 'Ready for being Triggered'), end
  % wait until scope object has state 'ready'
  ttrigger = rand * 4;
  title(['scsoftwaredemo: ', num2str(n), ...
         ' of 25 data packages, will be triggered in ', ...
         num2str(ttrigger), 's']);
  pause(ttrigger);                      % wait a random period (0..4s)
  if isempty(find(get(0, 'Children') == figh)), flag = 1; break; end
  trigger(sc);                          % software trigger the scope object

  while ~strcmpi(sc.Status,'finished');
    % wait until scope-object has state 'finished'
  end

  % create time vector, upload scope data and display it
  t = sc.Time;
  plot(t, sc.Data);               % upload and plot acquired data
  set(gca, 'XLim', [t(1), t(end)], 'YLim', [-10, 10]); % set axes limits
  drawnow;
end

if ~flag, title('scsoftwaredemo: demo finished'); end
stop(tg);
close_system('xpcosc');

%% EOF scsoftwaredemo.m