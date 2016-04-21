function scscopedemo
% SCSCOPEDEMO Demonstrates scope triggered xPC Scope.
%
%   SCSCOPEDEMO takes the model xpcsosc.mdl, builds it, and downloads it to
%   the target PC. Two scopes of type host are then added to the target
%   application. The first scope is set up to be signal triggered by the
%   'Signal Generator' signal (the only signal in the scope). The
%   'Integrator1' signal is added to the second scope, which is then set up to
%   be triggered by the first scope (i.e., it triggers at the same time as the
%   first scope triggers). This ensures that the scopes are always in
%   synchronization. Both property names (for the signals) are retrieved using
%   the GETSIGNALID function.
%
%   The scopes and the application are both started. The scopes are monitored
%   to determine when their data acquisition cycle is complete. The data from
%   the scopes is then uploaded and plotted. This cycle is repeated for a
%   total of 25 times, with the value of the parameter 'Gain1/Gain' (the
%   property name is determined via the GETPARAMID function) being set to a
%   random value every fifth time.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11.6.1 $ $Date: 2004/04/08 21:05:26 $

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
tPar = getparamid(tg, 'Gain1','Gain');

scs    = addscope(tg, 'host');          % define (add) first scope object
scs(2) = addscope(tg, 'host');          % define (add) second scope object

% get indices of signals 'Integrator1', 'Signal Generator'
signals(1) = getsignalid(tg,'Integrator1');
signals(2) = getsignalid(tg,'Signal Generator');

% set properties of first scope object
addsignal(scs(1), signals);             % add signals to signal list
scs(1).NumSamples    = 200;             % set number of samples to 200
scs(1).Decimation    = 4;               % set decimation to 4
scs(1).TriggerMode   = 'Signal';        % set TriggerMode to Signal
scs(1).TriggerSignal = signals(2);
% set trigger signal to signal 'Signal Generator'
scs(1).TriggerLevel  = 0.0;             % set trigger level to 0.0
scs(1).TriggerSlope  = 'rising';        % set trigger slope to Rising

% set properties of second scope object
addsignal(scs(2),signals(1));           % add first signal to signal list
scs(2).NumSamples    = 200;             % set number of samples to 200
scs(2).Decimation    = 10;              % set decimation to 10
scs(2).TriggerMode   = 'Scope';         % set TriggerMode to Scope

% set triggering scope to first scope object
scs(2).TriggerScope  = scs(1).ScopeId;

figh = findobj('Name', 'scscopedemo');  % Does the figure exist?
if isempty(figh)
  figh = figure; set(figh, 'Name','scscopedemo','NumberTitle','off');
else
  figure(figh);
end

m = 1; flag = 0;
for n = 1 : 25      % loop to acquire 25 data packages from the scope object
  if isempty(find(get(0, 'Children') == figh)), flag = 1; break; end
  if ~m
    setparam(tg, tPar, 2*1000*rand);
    % change parameter Gain1/Gain every fifth acquisition loop
    % to a random value between 0 and 2000
  end
  m = rem(m + 1, 5);
  
  scs(2).start;
  scs(1).start;

  % wait until both scope objects have state 'finished'
  while ~strcmpi(scs(1).Status,'finished') | ...
        ~strcmpi(scs(2).Status,'finished')
  end

  % first scope object: create time vector, upload scope data and display it
  subplot(2, 1, 1);
  t1 =  scs(1).Time;
  plot(t1, scs(1).Data);                % upload and plot acquired data
  set(gca, 'XLim', [t1(1), t1(end)], 'YLim', [-10, 10]); % set axes limits

  title(['scscopedemo: ', num2str(n), ' of 25 data packages']);

  % second scope object: create time vector, upload scope data and display it
  subplot(2,1,2);
  t2 =  scs(2).Time;
  plot(t2, scs(2).Data);                % upload and plot acquired data
  set(gca,'XLim',[t2(1),t2(end)],'YLim',[-10,10]); % set axes limits
  drawnow;
end

if ~flag, title('scscopedemo: demo finished'); end
stop(tg);
close_system('xpcosc');

%% EOF scscopedemo.m