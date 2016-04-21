function scfreerundemo
% SCFREERUNDEMO Demonstrates FreeRun display mode of xPC Scope.
%
%   SCFREERUNDEMO takes the model xpcsosc.mdl, builds it, and downloads it to
%   the target PC. A scope of type host is then added to the target
%   application, and the application is started.
%
%   It then runs the application, using the scope as a data acquisition
%   medium. The scope is set up to acquire 200 samples at a decimation of
%   4 (thus corresponding to an interval of 250e-6 * 200 * 4 = 0.2 seconds).
%
%   The scope is then started in FreeRun mode, and its status monitored until
%   it goes into state 'Finished'. At that point, the scope data is acquired
%   and plotted. This process repeats 25 times. After every fifth time, the
%   'Gain1/Gain (damping)' parameter (the property name is determined via the
%   GETPARAMID function) is set to a random value.
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.6.1 $ $Date: 2004/04/08 21:05:24 $

% is connection with target working?
if ~strcmp(xpctargetping, 'success')
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

sc = addscope(tg, 'host');              % define (add) a scope object

% get indices of signals 'Integrator1', 'Signal Generator'
signals(1) = getsignalid(tg, 'Integrator1');
signals(2) = getsignalid(tg, 'Signal Generator');

addsignal(sc, signals);     % add signals to signal list of scope object

sc.NumSamples  = 200;                   % set number of samples to 200
sc.Decimation  = 4;                     % set decimation to 4

sc.TriggerMode = 'Freerun';             % set TriggerMode to FreeRun

figh = findobj('Name', 'scfreerundemo'); % Does the figure exist?
if isempty(figh)
  figh = figure; set(figh, 'Name', 'scfreerundemo', 'NumberTitle', 'off');
else
  figure(figh);
end

m = 1; flag = 0;
for n = 1 : 25     % loop to acquire 25 data packages from the scope object
  if isempty(find(get(0, 'Children') == figh)), flag = 1; break; end
  if ~m
    setparam(tg, tPar, 2*1000*rand);
    % change parameter Gain1/Gain every fifth acquisition loop
    % to a random value between 0 and 2000
  end
  m = rem(m + 1,  5);

  start(sc);                           % start scope object

  while ~strcmpi(sc.Status,'finished');
    % wait until scope-object has state 'finished'
  end;

  % create time vector, upload scope data and display it
  t = sc.Time;
  plot(t,sc.Data);                      % upload and plot acquired data
  title(['scfreerundemo: ',num2str(n),' of 25 data packages']);
  set(gca,'XLim',[t(1), t(end)]);       % set axes limits
  set(gca,'YLim',[-10,  10]);
  drawnow;
end

if ~flag, title('scfreerundemo: demo finished'); end
stop(tg);
close_system('xpcosc');

%% EOF scfreerundemo.m
