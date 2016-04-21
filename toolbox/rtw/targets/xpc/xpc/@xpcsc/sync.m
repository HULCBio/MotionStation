function [xpcScopeObj] = sync(xpcScopeObj)
% SYNC Synchronize the xPC scope
%
%   SYNC(XPCOBJ) synchronizes the parameters for the scope represented
%   by the object XPCSCOPEOBJ, in accordance with the changes made to the
%   xpcsc object.
%
%   This is a private function and is not to be called directly.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $ $Date: 2004/04/08 21:03:41 $

propname = xpcScopeObj.prop.propname;

if ~isempty(xpcScopeObj.execqueue)
  for i = xpcScopeObj.execqueue
    try
      switch i
       case 5                           % NumSamples
        xpcgate('setscnosamples', str2num(xpcScopeObj.ScopeId), ...
                str2num(xpcScopeObj.NumSamples));

       case 6                           % Decimation
        xpcgate('setscinterleave', str2num(xpcScopeObj.ScopeId), ...
                str2num(xpcScopeObj.Decimation));

       case 7                           % TriggerMode
        if strcmp(getfield(struct(xpcScopeObj), propname{i}), 'FreeRun')
          xpcgate('setsctriggermode', str2num(xpcScopeObj.ScopeId), 0);
        elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Software')
          xpcgate('setsctriggermode', str2num(xpcScopeObj.ScopeId), 1);
        elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Signal')
          xpcgate('setsctriggermode', str2num(xpcScopeObj.ScopeId), 2);
        elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Scope')
          xpcgate('setsctriggermode', str2num(xpcScopeObj.ScopeId), 3);
        elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), 'EndScope')
          xpcgate('setsctriggermode', str2num(xpcScopeObj.ScopeId), 4);
        end

       case 8                           % TriggerSignal
        xpcgate('setsctriggersignal', str2num(xpcScopeObj.ScopeId), ...
                str2num(xpcScopeObj.TriggerSignal));

       case 9                           % TriggerLevel
        xpcgate('setsctriggerlevel', str2num(xpcScopeObj.ScopeId), ...
                str2num(xpcScopeObj.TriggerLevel));
       case 10                          % TriggerSlope
        if strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Either')
          xpcgate('setsctriggerslope', str2num(xpcScopeObj.ScopeId), 0);
        elseif strcmp(getfield(struct(xpcScopeObj),propname{i}), 'Rising')
          xpcgate('setsctriggerslope', str2num(xpcScopeObj.ScopeId), 1);
        elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Falling')
          xpcgate('setsctriggerslope', str2num(xpcScopeObj.ScopeId), 2);
        end

       case 11                          % TriggerScope
        xpcgate('setsctriggerscope', str2num(xpcScopeObj.ScopeId), ...
                str2num(xpcScopeObj.TriggerScope));       
        case 13                         % Signals
        xpcgate('addsig', str2num(xpcScopeObj.ScopeId), xpcScopeObj.Signals);
        
       case 15                          % Command
        if strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Start')
          xpcgate('scstart',str2num(xpcScopeObj.ScopeId));
        elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Stop')
          xpcgate('scstop', str2num(xpcScopeObj.ScopeId));
        elseif strcmp(getfield(struct(xpcScopeObj),propname{i}), 'Trigger')
          xpcgate('softtrig', str2num(xpcScopeObj.ScopeId));
        end
        xpcScopeObj.Command = '';
       case 17                          % Mode
        if strcmp(xpcScopeObj.Type, 'Target')
          if strcmp(getfield(struct(xpcScopeObj), propname{i}), 'Numerical')
            xpcgate('settgscmode', str2num(xpcScopeObj.ScopeId), 0);
          elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), ...
                        'Redraw (Graphical)')
            xpcgate('settgscmode', str2num(xpcScopeObj.ScopeId), 1);
          elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), ...
                        'Sliding (Graphical)')
            xpcgate('settgscmode', str2num(xpcScopeObj.ScopeId), 2);
          elseif strcmp(getfield(struct(xpcScopeObj), propname{i}), ...
                        'Rolling (Graphical)')
            xpcgate('settgscmode', str2num(xpcScopeObj.ScopeId), 3);
          end
        end
       case 18                          % YLimit
        if strcmp(xpcScopeObj.Type, 'Target')
          if (isa(xpcScopeObj.YLimit, 'double') & ...
              (size(xpcScopeObj.YLimit) == [1 2]) & ...
              (xpcScopeObj.YLimit(1) <= xpcScopeObj.YLimit(2)))
            xpcgate('settgscylimits', str2num(xpcScopeObj.ScopeId), ...
                    xpcScopeObj.YLimit);
          elseif ~isempty(strmatch(lower(xpcScopeObj.YLimit), 'auto'))
            xpcgate('settgscylimits', str2num(xpcScopeObj.ScopeId), [0 0]);
          else
            error('Invalid value for YLimit');
          end
        end
       case 19                          % Grid
        if strcmp(xpcScopeObj.Type, 'Target')
          if strcmpi(getfield(struct(xpcScopeObj), propname{i}), 'On')
            xpcgate('settgscgrid', str2num(xpcScopeObj.ScopeId), 1);
          elseif strcmpi(getfield(struct(xpcScopeObj), propname{i}), 'Off')
            xpcgate('settgscgrid', str2num(xpcScopeObj.ScopeId), 0);
          end
        end
      case 21                           % NumPrePostSamples
        xpcgate('setscnoprepostsamples', str2num(xpcScopeObj.ScopeId), ...
                str2num(xpcScopeObj.NumPrePostSamples));
      case 22                           % triggersample
            xpcgate('setsctriggerscsample', str2num(xpcScopeObj.ScopeId), ...
                 xpcScopeObj.TriggerSample);        
        end % switch i
    catch
      error(xpcgate('xpcerrorhandler'));
    end
  end % for i = xpcScopeObj.execqueue
end % if ~isempty(xpcScopeObj.execqueue)
xpcScopeObj.execqueue = [];

id = str2num(xpcScopeObj.ScopeId);

% status
try
  switch xpcgate('getscstate', id);
   case 0
    xpcScopeObj.Status = 'Started';
   case 1
    xpcScopeObj.Status = 'Ready for being Triggered';
   case 2
    xpcScopeObj.Status = 'Acquiring';
   case 3
    xpcScopeObj.Status = 'Finished';
   case 4
     xpcScopeObj.Status = 'Interrupted';
   case 5
    xpcScopeObj.Status = 'Pre-Acquiring';
  end

  %type
  switch xpcgate('getsctype', id)
   case 1
    xpcScopeObj.Type     = 'Host';
   case 2
    xpcScopeObj.Type     ='Target';
  end

 xpcScopeObj.NumSamples = num2str(xpcgate('getscnosamples',  id));
 xpcScopeObj.NumPrePostSamples = num2str(xpcgate('getscnoprepostsamples',  id));
 xpcScopeObj.Decimation = num2str(xpcgate('getscinterleave', id));

  % triggermode
  switch xpcgate('getsctriggermode',id);
   case 0
    xpcScopeObj.TriggerMode = 'FreeRun';
   case 1
    xpcScopeObj.TriggerMode = 'Software';
   case 2
    xpcScopeObj.TriggerMode = 'Signal';
   case 3
    xpcScopeObj.TriggerMode = 'Scope';
  end

  xpcScopeObj.TriggerSample = xpcgate('getsctriggerscsample', id);
  xpcScopeObj.TriggerSignal = num2str(xpcgate('getsctriggersignal', id));
  xpcScopeObj.TriggerLevel  = num2str(xpcgate('getsctriggerlevel',  id));

  % triggerslope
  switch xpcgate('getsctriggerslope', id)
   case 0
    xpcScopeObj.TriggerSlope = 'Either';
   case 1
    xpcScopeObj.TriggerSlope = 'Rising';
   case 2
    xpcScopeObj.TriggerSlope = 'Falling';
  end

xpcScopeObj.TriggerScope = num2str(xpcgate('getsctriggerscope',id));
catch
  error(xpcgate('xpcerrorhandler'));
end

if strcmp(xpcScopeObj.Type,'Target')
  try
    switch xpcgate('gettgscmode', id)
     case 0
      xpcScopeObj.Mode = 'Numerical';
     case 1
      xpcScopeObj.Mode = 'Redraw (Graphical)';
     case 2
      xpcScopeObj.Mode = 'Sliding (Graphical)';
     case 3
      xpcScopeObj.Mode = 'Rolling (Graphical)';
    end % switch xpcgate('gettgscmode', id)
    xpcScopeObj.YLimit = xpcgate('gettgscylimits',id);
    switch xpcgate('gettgscgrid',id)
     case 0
      xpcScopeObj.Grid = 'Off';
     case 1
      xpcScopeObj.Grid = 'On';
    end % switch xpcgate('gettgscgrid',id)
  catch
    error(xpcgate('xpcerrorhandler'));
  end % try
end % if strcmp(xpcScopeObj.Type,'Target')

xpcScopeObj.StartTime = 'NaN';

try
  xpcScopeObj.Signals = sort(xpcgate('getscsignals', ...
                                str2num(xpcScopeObj.ScopeId)));
  sigs=xpcScopeObj.Signals;                            
  signames=[];                             
  for i=1:length(xpcScopeObj.Signals)
      signames{i,1}=xpcgate('getsignalname',sigs(i));
  end      
  xpcScopeObj.Signalnames = signames;
                            
  if (strcmp(xpcScopeObj.Status, 'Finished') | ...
      strcmp(xpcScopeObj.Status, 'Interrupted'))
    if strcmp(xpcScopeObj.Type,'Target')
      xpcScopeObj.StartTime='Not Accessible';
    else
    xpcScopeObj.StartTime = num2str(...
      xpcgate('getscstarttime', str2num(xpcScopeObj.ScopeId)), '%.6f');
    end
    if strcmp(xpcScopeObj.Type,'Target')
      xpcScopeObj.Data='Not Accessible';
    else
      xpcScopeObj.Data    = sprintf('Matrix (%d x %d)', ...
                                  str2num(xpcScopeObj.NumSamples),...
                                  length(xpcScopeObj.Signals));
    end
    if strcmp(xpcScopeObj.Type,'Target')
      xpcScopeObj.Time='Not Accessible';
    else
      xpcScopeObj.Time    = sprintf('Matrix (%d x 1)', ...
        str2num(xpcScopeObj.NumSamples));
    end
  else
    xpcScopeObj.StartTime = 'NaN';
    xpcScopeObj.Data    = '[]';
    xpcScopeObj.Time    = '[]';
  end
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller', inputname(1), xpcScopeObj);
  end
end

%% EOF sync.m
