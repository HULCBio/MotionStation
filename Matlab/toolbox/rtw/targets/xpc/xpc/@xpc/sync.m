function [xpcObj] = sync(xpcObj)
% SYNC Synchronize the target application
%
% SYNC(XPCOBJ) synchronizes the parameters for the target application
% in accordance with the changes made to the xPC object XPCOBJ.
% This is usually not called by the user.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.22 $ $Date: 2002/03/25 04:16:52 $

propname = xpcObj.prop.propname;
conn = 1;
if ~isempty(xpcObj.execqueue)
  try
    for i = xpcObj.execqueue
      switch i
       case 6                           % StopTime
        xpcgate('settfin', str2num(xpcObj.StopTime));
       case 7                           % SampleTime
        if strmatch(lower(xpcObj.Application), 'loader')
          error('No application loaded');
        end
        if strmatch(lower(xpcObj.Status), 'running'),
          error('Stop the simulation first');
        end
        xpcgate('setts', str2num(xpcObj.SampleTime));
       case 10                          % Command
        if     strcmp(xpcObj.Command, 'Start'),  xpcgate('rlstart',1);
        elseif strcmp(xpcObj.Command, 'Stop'),   xpcgate('rlstop');
        elseif strcmp(xpcObj.Command, 'Boot'),   xpcgate('xpcreboot');
          conn = 0;
        elseif strcmp(xpcObj.Command, 'Remove'), xpcgate('stopsess');
        end
        xpcObj.Command = '';
       case 11                          % ViewMode
        if ischar(xpcObj.ViewMode)      % it's char, must be 'all'
          xpcgate('settgscviewmode', 0);
        else                            % double: must be a legal scopeid
          xpcgate('settgscviewmode', xpcObj.ViewMode);
        end
       case 17                          % LogMode
        if ((xpcObj.LogMode == 0) | ...
            strmatch(lower(num2str(xpcObj.LogMode)), 'normal'))
          xpcgate('setlgmod', 0);       % Time-equidistant
          xpcObj.LogMode = 'Normal';
        else                            % Value-equidistant
          xpcgate('setlgmod', 1, xpcObj.LogMode);
        end
       case 26                          % ParameterValue
        if (xpcObj.TunParamIndex(1) < str2num(xpcObj.NumParameters))
          xpcgate('setpar', xpcObj.TunParamIndex(1), ...
                  xpcObj.ParameterValue{1});
          xpcObj.TunParamIndex(1)  = [];
          xpcObj.ParameterValue(1) = [];
        else
          error(['Parameter ' xpcObj.TunParamIndex ' is invalid. ' ...
                 'There are only ' xpcObj.NumParameters ...
                 ' tunable parameters.']);
        end
      end % switch i
    end % for i = xpcObj.execqueue
  catch
    error(xpcgate('xpcerrorhandler'));
  end % try
end % if ~isempty(xpcObj.execqueue)

xpcObj.execqueue = [];

if conn
  try,   modelname = xpcgate('getname');
  catch, modelname = lasterr; end
else
  modelname = 'TCP/IP Connect';
end

if findstr(modelname, 'TCP/IP Connect') % no connection established
  xpcObj.Connected   = 'No';
  xpcObj.Application = 'unknown';
  if (nargout == 0)
    if ~isempty(inputname(1))
      assignin('caller', inputname(1), xpcObj);
      end
  end
  return
end


if strcmp(modelname, 'loader')        % loader is active
  xpcObj.Connected   = 'Yes';
  xpcObj.Application = 'loader';
  if (nargout == 0)
      if ~isempty(inputname(1))
        assignin('caller', inputname(1), xpcObj);
      end
  end
  return
end

xpcObj.Application = modelname;
xpcObj.Connected   = 'Yes';

try
  % Properties which do not depend on whether we are running or stopped
  tmp = xpcgate('gettfin');
  if tmp < 0
      tmp = inf;
  end
  status=xpcgate('getlogstatus');
  logstatusstr={'Off','Acquiring'};

  xpcObj.StopTime       = num2str(tmp, '%.2f');
  xpcObj.SampleTime     = num2str(xpcgate('getts'), '%.6f');
  xpcObj.SessionTime    = num2str(xpcgate('getsessiontime'), '%.2f');
  numParameters         = xpcgate('getnpar', xpcObj.Application);
  xpcObj.NumParameters  = num2str(numParameters);

  if status(5)
    xpcObj.AvgTET       = xpcgate('avgtet');
  else
    xpcObj.AvgTET       = NaN;
  end

  if status(1) %if logging is turned on
      xpcObj.MaxLogSamples  = num2str(xpcgate('maxsamp'));
      xpcObj.NumLogWraps    = num2str(xpcgate('waround'));
  else %otherwise logging is turned off
      xpcObj.MaxLogSamples  = '0';
      xpcObj.NumLogWraps    = '0';
  end

  xpcObj.ExecTime       = num2str(xpcgate('getsimtime'), '%.2f');
  xpcObj.Scopes         = sort(xpcgate('getscopes'));
  xpcObj.HostScopes     = xpcgate('getscopes', 'host');
  xpcObj.TargetScopes   = xpcgate('getscopes', 'target');
  xpcObj.NumSignals     = num2str(xpcgate('getnsig', xpcObj.Application));
%  if (str2num(xpcObj.TunParamIndex(2 : end)) < numParameters)
%    xpcObj.TunParamName = xpcgate('showpar', xpcObj.Application, ...
%                str2num(xpcObj.TunParamIndex(2 : end)));
%  xpcObj.ParameterValue = xpcgate('getpar',str2num(xpcObj.TunParamIndex(2 : end)));
%  end

  try
    tmpViewMode           = xpcgate('gettgscviewmode');
  catch
    tmpViewMode           = 'All';
  end
  if (tmpViewMode)                    % Particular scope Selected
    xpcObj.ViewMode     = tmpViewMode;
  else
    xpcObj.ViewMode     = 'All';
  end

  if ~xpcgate('isrun')                % stopped (not running)
    xpcObj.Status = 'stopped';
    % has there been a CPU overload
    if xpcgate('isoverl')             % if yes
      xpcObj.CPUoverload = 'detected';
    else
      xpcObj.CPUoverload = 'none';
    end

    if status(2)
      xpcObj.TimeLog        = sprintf('Vector(%d)', xpcgate('numsamp'));
    else
      xpcObj.TimeLog        = logstatusstr{status(2)+1};
    end

    if status(3)
        xpcObj.StateLog       = ...
        sprintf('Matrix(%dx%d)', xpcgate('numsamp'), xpcgate('getnumst'));
    else
        xpcObj.StateLog       = logstatusstr{status(3)+1};
    end

    if status(4)
        xpcObj.OutputLog      = ...
        sprintf('Matrix(%dx%d)', xpcgate('numsamp'), xpcgate('getnumop'));
    else
        xpcObj.OutputLog      = logstatusstr{status(4)+1};
    end

    if status(5)
      xpcObj.MinTET = xpcgate('mintet');
      xpcObj.MaxTET = xpcgate('maxtet');
      xpcObj.TETLog = sprintf('Vector(%d)', xpcgate('numsamp'));
    else
      xpcObj.MinTET = NaN;
      xpcObj.MaxTET = NaN;
      xpcObj.TETLog = logstatusstr{status(5)+1};
    end

    if status(1) %if logging is turned on
      [tmp1, tmp2] = xpcgate('getlgmod');
      if (tmp1 == 0), xpcObj.LogMode = 'Normal';
      else,    xpcObj.LogMode = tmp2; end
    else %otherwise logging is turned off
      xpcObj.LogMode = 'Normal'; %BC
    end

else % if ~xpcgate('isrun')     (running)
    xpcObj.Status         = 'running';
    xpcObj.CPUoverload    = 'none';
    xpcObj.MinTET         = NaN;
    xpcObj.MaxTET         = NaN;
    xpcObj.TimeLog        = logstatusstr{status(2)+1};
    xpcObj.StateLog       = logstatusstr{status(3)+1};
    xpcObj.OutputLog      = logstatusstr{status(4)+1};
    xpcObj.TETLog         = logstatusstr{status(5)+1};
  end % if ~xpcgate('isrun')


   switch xpcgate('getsimmode')
   case 0
    xpcObj.Mode = 'Target not ready due a model initialization error';
   case 1
    xpcObj.Mode = 'Real-Time Single-Tasking';
   case 2
    xpcObj.Mode = 'Real-Time Multi-Tasking';
   case 3
    xpcObj.Mode = 'Freerun';
  end
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
  if ~isempty(inputname(1)), assignin('caller', inputname(1), xpcObj); end
end

%% EOF sync.m
