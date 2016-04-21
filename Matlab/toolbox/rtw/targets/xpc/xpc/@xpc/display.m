function display(xpcObj)
% DISPLAY Display method for a xPC object.
%
%   This is a private method which is not to be called directly.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2002/03/25 04:17:03 $

try, xpcObj = sync(xpcObj); catch, error(xpcgate('xpcerrorhandler')); end

propname = xpcObj.prop.propname;
propval  = xpcObj.prop.propval;

fprintf(2, '\nxPC Object\n\n');

fprintf(2, '   %-20s = %s\n', propname{2}, ...
        getfield(struct(xpcObj), propname{2}));      % Connected
if ~strcmp(xpcObj.Application, 'unknown')
  fprintf(2, '   %-20s = %s\n', propname{3}, ...
          getfield(struct(xpcObj), propname{3}));    % Application

  if ~strcmp(xpcObj.Application, 'loader')
    fprintf(2, '   %-20s = %s\n', propname{32}, ...
            getfield(struct(xpcObj), propname{32})); % Mode
    fprintf(2, '   %-20s = %s\n', propname{4}, ...
            getfield(struct(xpcObj), propname{4}));  % Status
    fprintf(2, '   %-20s = %s\n', propname{5}, ...
            getfield(struct(xpcObj), propname{5}));  % CPUOverload
  end

end

if (~strcmp(xpcObj.Application,'unknown') & ...
    ~strcmp(xpcObj.Application,'loader'))
  fprintf(2, '\n');
  fprintf(2, '   %-20s = %s\n', propname{8}, ...
          getfield(struct(xpcObj), propname{8})); % SimTime
  fprintf(2, '   %-20s = %s\n', propname{9}, ...
          getfield(struct(xpcObj), propname{9})); % SessionTime
  fprintf(2, '   %-20s = %s\n',propname{6}, ...
          getfield(struct(xpcObj), propname{6})); % StopTime
  fprintf(2, '   %-20s = %s\n', propname{7}, ...
          getfield(struct(xpcObj), propname{7})); % SampleTime
  fprintf(2, '   %-20s = %f\n', propname{14}, ...
          xpcObj.(propname{14}));                 % AvgTET
  fprintf(2, '   %-20s = %f\n', propname{12}, ...
          xpcObj.(propname{12}));                  % MinTET
  fprintf(2, '   %-20s = %f\n', propname{13}, ...
          xpcObj.(propname{13}));                  % MaxTET
  fprintf(2, '   %-20s = %s\n', propname{11}, ...
          num2str(getfield(struct(xpcObj), propname{11}))); % ViewMode

  fprintf(2, '\n');
  fprintf(2, '   %-20s = %s\n', propname{19}, ...
          getfield(struct(xpcObj), propname{19})); % TimeLog
  fprintf(2, '   %-20s = %s\n', propname{20}, ...
          getfield(struct(xpcObj), propname{20})); % StateLog
  fprintf(2, '   %-20s = %s\n', propname{21}, ...
          getfield(struct(xpcObj), propname{21})); % OutputLog
  fprintf(2, '   %-20s = %s\n', propname{22}, ...
          getfield(struct(xpcObj), propname{22})); % TETLog
  fprintf(2, '   %-20s = %s\n', propname{16}, ...
          getfield(struct(xpcObj), propname{16})); % MaxLogSamples
  fprintf(2, '   %-20s = %s\n', propname{18}, ...
          getfield(struct(xpcObj), propname{18})); % NumLogWraps
  if isa(getfield(struct(xpcObj), propname{17}), 'char')
    fprintf(2, '   %-20s = %s\n', propname{17}, ...
            getfield(struct(xpcObj), propname{17})); % LogMode
  else                                  % is a double
    fprintf(2, '   %-20s = %.2f\n', propname{17}, ...
            getfield(struct(xpcObj), propname{17}));
  end
  fprintf(2, '\n');

  scs = xpcObj.Scopes;
  if isempty(scs)
    out = 'No Scopes defined';
  else
    out = [sprintf('%d, ', scs(1 : end - 1)) num2str(scs(end))];
  end

  fprintf(2, '   %-20s = %s\n', propname{27}, out); % Scopes
  fprintf(2, '   %-20s = %s\n', propname{31}, ...
          getfield(struct(xpcObj), propname{31}));  % NumSignals
  fprintf(2, '   %-20s = %s\n', propname{28}, ...
          getfield(struct(xpcObj), propname{28}));  % ShowSignals

if strcmp(xpcObj.ShowSignals, 'On')
    fprintf(2, '   %-20s = %-8s%-18s%-10s\n', ...
            'Signals','PROP.','VALUE','BLOCK NAME')
    try
      displaySignals(xpcObj);
    catch
      error(xpcgate('xpcerrorhandler'));
    end
  end

  fprintf(2, '\n');
  fprintf(2, '   %-20s = %s\n', propname{15}, ...
          getfield(struct(xpcObj), propname{15})); % NumParameters
  fprintf(2, '   %-20s = %s\n', propname{23}, ...
          getfield(struct(xpcObj), propname{23})); % ShowParameters

  if strcmp(xpcObj.ShowParameters,'On')
    fprintf(2, '   %-20s = %-8s%-18s%-10s%-8s%-30s%-30s\n', ...
            'Parameters','PROP.','VALUE','TYPE','SIZE','PARAMETER NAME', ...
            'BLOCK NAME');
    try
      displayParameters(xpcObj);
    catch
      error(xpcgate('xpcerrorhandler'));
    end
  end
end
fprintf(2,'\n');

%% EOF display.m
