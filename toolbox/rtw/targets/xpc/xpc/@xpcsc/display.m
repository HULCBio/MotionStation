function display(xpcScopeObj)
% DISPLAY Display method for a xpcsc object.
% 
% The method will display a vector of such objects, one at a time
% (columnwise for matrices).
% 
% This is a private method which is not to be called directly.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.1 $ $Date: 2004/04/08 21:03:34 $

if (prod(size(xpcScopeObj)) > 1)        % Vector of scope objects
  flag = 0;
  for scopeElement = reshape(xpcScopeObj, 1, prod(size(xpcScopeObj)))
    try
      display(scopeElement);
    catch
      error(xpcgate('xpcerrorhandler'));
    end
  end
  return
end                                     % if (prod(size(varargin{1})) > 1)

% Start working on the scalar case
if ~sum(ismember(xpcgate('getscopes'), str2num(xpcScopeObj.ScopeId)))
  warning(sprintf(['This Scope object is no longer associated', ...
                   ' with a Scope object on the target\n', ...
                   'Clear the object by typing: clear objectname\n']));
  return;
end

try
  xpcScopeObj = sync(xpcScopeObj);
catch
  error(xpcgate('xpcerrorhandler'));
end

propname  = xpcScopeObj.prop.propname;
propval   = xpcScopeObj.prop.propval;
fmt       = '   %-20s = %s\n';
fmtNum    = '   %-20s = %g\n';       
fprintf(2,'\nxPC Scope Object\n\n\n');

fprintf(2, fmt, propname{16}, xpcScopeObj.Application);
fprintf(2, fmt, propname{2},  xpcScopeObj.ScopeId);
fprintf(2, fmt, propname{3},  xpcScopeObj.Status);
fprintf(2, fmt, propname{4},  xpcScopeObj.Type);
fprintf(2, fmt, propname{5},  xpcScopeObj.NumSamples);
fprintf(2, fmt, propname{21}, xpcScopeObj.NumPrePostSamples);
fprintf(2, fmt, propname{6},  xpcScopeObj.Decimation);
fprintf(2, fmt, propname{7},  xpcScopeObj.TriggerMode);

%if strcmpi(xpcScopeObj.TriggerMode,'Scope')
fprintf(2, fmt, propname{11}, xpcScopeObj.TriggerScope);
  %  trigsamval=str2num(xpcScopeObj.TriggerScopeSample);
  %      if (str2num(xpcScopeObj.TriggerScopeSample) < 0)
  %      fprintf(2, fmt, propname{22}, '-1');
  %  else
fprintf(2, fmtNum, propname{22},xpcScopeObj.TriggerSample);
 %  end
 %end

%if strcmpi(xpcScopeObj.TriggerMode,'Signal')
fprintf(2, fmt, propname{8},  xpcScopeObj.TriggerSignal);
fprintf(2, fmt, propname{9},  xpcScopeObj.TriggerLevel);
fprintf(2, fmt, propname{10}, xpcScopeObj.TriggerSlope);
%end



if strcmp(xpcScopeObj.Type, 'Target')
  fprintf(2, fmt, propname{17}, xpcScopeObj.Mode);
  YLimit = xpcScopeObj.YLimit;
  if ((YLimit(1) == 0) & (YLimit(2) == 0))
    fprintf(2, '   %-20s = %s\n', propname{18}, 'Auto');
  else
    fprintf(2, '   %-20s = [%f,%f]\n', propname{18}, YLimit(1), YLimit(2));
  end
  fprintf(2, fmt, propname{19}, xpcScopeObj.Grid);
end

fprintf(2, fmt,propname{12}, xpcScopeObj.StartTime);% StartTime


if (strcmpi(xpcScopeObj.Status, 'Finished') | ...
    strcmpi(xpcScopeObj.Status, 'Interrupted'))
  try
    fprintf(2,'   %-20s = %s\n', propname{14}, ...
            xpcScopeObj.Data);          % Data
    fprintf(2,'   %-20s = %s\n', propname{20}, ...
            xpcScopeObj.Time);          % Time
  catch
    error(xpcgate('xpcerrorhandler'));
  end
else
  fprintf(2, fmt, propname{14}, xpcScopeObj.Data); % Data
  fprintf(2, fmt, propname{20}, xpcScopeObj.Time); % Time
end
fprintf(2, '   %-20s = ', propname{13}); % Signals
scs = xpcScopeObj.Signals;
if isempty(scs)
  fprintf(2, 'no Signals defined\n');
else
    signals= xpcScopeObj.Signalnames;
    for i = 1 : length(scs)
        if (i == 1)
          fprintf(2, '%-3d: %s\n', scs(i), signals{i});
        else
          fprintf(2, '   %-20s   %-3d: %s\n', ' ', scs(i), signals{i});
        end
    end
end
fprintf(2,'\n');

%% EOF display.m
