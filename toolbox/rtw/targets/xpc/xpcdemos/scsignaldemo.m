function scsignaldemo
% SCSIGNALDEMO Demonstrates signal triggered xPC scope.
%
%    SCSIGNALDEMO takes the model xpcsosc.mdl, builds it, and downloads it to
%    the target PC. A scope of type host is added to the application, and the
%    'Signal Generator' and 'Integrator1' signals are added to the scope. The
%    scope is then set to trigger on the 'Signal Generator' signal (the
%    property name is retrieved using the GETSIGNALID function), with a
%    trigger level of 0.0 and a rising trigger slope.
%
%    The application is then started, and the scope monitored to determine
%    when its data acquisition is complete. The data is then uploaded and
%    plotted. This process is repeated for a total of 25 times, with the
%    value of the 'Gain1/Gain' parameter (the property name is
%    retrieved via the GETPARAMID function) being changed to a random value
%    every fifth time.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.6.1 $ $Date: 2004/04/08 21:05:27 $

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

sc = addscope(tg, 'host');              % define (add) a scope object

% get indices of signals 'Integrator1', 'Signal Generator'
signals(1) = getsignalid(tg,'Integrator1');
signals(2) = getsignalid(tg,'Signal Generator');

addsignal(sc, signals);     % add signals to signal list of scope object

sc.NumSamples    = 200;                 % set number of samples to 200
sc.Decimation    = 4;                   % set decimation to 4
sc.TriggerMode   = 'Signal';            % set TriggerMode to Signal
sc.TriggerSignal = signals(2);
% set trigger signal to signal 'Signal Generator'
sc.TriggerLevel  = 0.0;                 % set trigger level to 0.0
sc.TriggerSlope  = 'rising';            % set trigger slope to Rising

figh = findobj('Name', 'scsignaldemo'); % Does the figure exist?
if isempty(figh)
  figh = figure; set(figh, 'Name', 'scsignaldemo', 'NumberTitle', 'off');
else
  figure(figh);
end

m = 1; flag = 0;
for n = 1 : 25      % loop to acquire 25 data packages from the scope object
  if isempty(find(get(0, 'Children') == figh)), flag = 1; break; end
  if ~m
    setparam(tg, tPar, 2*1000*rand);
    % change parameter Gain1/Gain every fifth acquisition
    % loop to a random value between 0 and 2000
  end
  m = rem(m + 1, 5);

  start(sc);                            % start scope object

  % wait until scope-object has state 'finished'
  while ~strcmpi(sc.Status,'finished'), end;

  % create time vector, upload scope data and display it
  t = sc.Time;
  plot(t, sc.Data);                     % upload and plot acquired data package
  title(['scsignaldemo: ', num2str(n), ' of 25 data packages']);
  set(gca,'XLim',[t(1), t(end)], 'YLim', [-10, 10]);% set axes limits
  drawnow;
end

if ~flag, title('scsignaldemo: demo finished'); end
stop(tg);
close_system('xpcosc');

%% EOF scsignaldemo.m
