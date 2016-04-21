function dataloggingdemo(param)
% DATALOGGINGDEMO Demonstrates time- and value-equidistant data logging.
%
%   DATALOGGINGDEMO takes the model xpcsosc.mdl, builds it, and downloads it to
%   the target PC. The option to log states is turned off for this demo.
%
%   The stoptime of the application is set to 0.2 seconds. At the end of
%   the first run, the time and the outputs logs are retrieved, and
%   plotted. At this time, the logging is time-equidistant, and every
%   sample is logged. Subsequently, the logging mode is set to value
%   equidistant with values between 0.02 and 0.2 in steps of 0.02.
%
%   If the optional argument PARAM is set to 1, the 'Gain1/Gain' (damping)
%   parameter (the property name is retrieved using the GETPARAMID function)
%   is set to a random value every time. Otherwise, it is held constant.
%   However, for the random gain setting, the results may not look correct due
%   to a combination of the effects of changing the gain and the
%   value-equidistant logging.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.3.6.1 $ $Date: 2004/04/08 21:05:22 $

% process command line argument, if any
if (nargin == 0)
  changeParam = 0;
else
  if (nargin == 1)
    if (param ~= 1)
      error('Invalid argument');
    end
    changeParam = 1;
  else
    error('Too many arguments');
  end
end

% is connection with target working?
if ~strcmp(xpctargetping, 'success')
  error('Connection with target cannot be established');
end

% is xpcosc already open?
systems = find_system('type', 'block_diagram');
if isempty(strmatch('xpcosc', systems, 'exact'))
  mdlOpen = 0;
  load_system('xpcosc');
else
  mdlOpen = 1;
end

if (mdlOpen), stateOption = get_param('xpcosc', 'SaveState'); end

% turn statelogging off for this demo
set_param('xpcosc', 'SaveState', 'off');

% build xPC application xpcosc and download it onto the target
rtwbuild('xpcosc');

% close the system if we 
if (mdlOpen)
  set_param('xpcosc', 'SaveState', stateOption);
else
  bdclose('xpcosc');
end

tg = xpc;                               % create an xPC Object

tg.SampleTime = 0.000250;               % set sample time to 250us
tg.StopTime   = 0.2;                    % set stoptime to 0.2s

tg.LogMode = 'normal';                  % Time-equidistant logging.
start(tg);                              % start execution

% get property name of Parameter to tune
tPar = getparamid(tg, 'Gain1','Gain');

figh = findobj('Name', 'dataloggingdemo');  % Does the figure exist?
if isempty(figh)
  figh = figure;
  set(figh, 'Name','dataloggingdemo','NumberTitle','off');
else
  figure(figh);
end

% wait till the application is complete
while strcmp(tg.Status, 'running')
  pause(0.05);
end

% retrieve the logged data and plot it.
tm = tg.TimeLog;
op = tg.OutputLog;
plot(tm, op);
set(gca, 'XLim', [tm(1), tm(end)], 'YLim', [-10, 10]);
title(['Time equidistant logging, ' num2str(length(tm)) ' samples']);
drawnow;

flag = 0;
for n = 0.02 : 0.02 : 0.2
  % loop over the value equidistant logging
  if isempty(find(get(0, 'Children') == figh)), flag = 1; break; end

  % change parameter Gain1/Gain to random value between 0 and 2000;
  % set Value equidistant logging to value n
  set(tg, 'LogMode', n);                % can use tg.LogMode = n as well
  if (changeParam)
    setparam(tg, tPar, 2 * 1000 * rand);
  end

  start(tg);
  % wait till the application is complete
  while strcmp(tg.Status, 'running')
    pause(0.05);
  end
  
  % retrieve the logged data and plot it.
  tm = tg.TimeLog;
  op = tg.OutputLog;
  plot(tm, op);
  set(gca, 'XLim', [tm(1), tm(end)], 'YLim', [-10, 10]);
  title(['Value equidistant logging (' num2str(n) '): ' ...
         num2str(length(tm)) ' samples']);
  drawnow;
end

if ~flag, title('dataloggingdemo: demo finished'); end
stop(tg);

%% EOF dataloggingdemo.m