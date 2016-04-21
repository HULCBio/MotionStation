function vrsetpref(varargin)
%VRSETPREF Set Virtual Reality Toolbox preferences.
%   VRSETPREF(PREFNAME, PREFVALUE) sets Virtual Reality Toolbox preference
%   PREFNAME to value PREFVALUE.
%   PREFNAME can be a cell array of preference names and PREFVALUE can be
%   a cell array of corresponding preference values; in this case multiple
%   preferences are set.
%
%   VRSETPREF(PREFNAME1, PREFVALUE1, PREFNAME2, PREFVALUE2, ...) is another
%   way to set multiple preferences at once.
%
%   VRSETPREF(PREFS), where PREFS is a structure, sets multiple preferences.
%   It treats field names as preference names and their values as the
%   corresponding preference values.
%
%   A special value 'factory' can be used for any preference, causing it
%   to be reset to factory defaults.
%   VRSETPREF('factory') resets all preferences to their factory values.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.12.4.6 $ $Date: 2004/03/15 22:35:39 $ $Author: batserve $

% handle single 'factory'
if ~isstruct(varargin{1}) && nargin==1
  if ischar(varargin{1}) && strcmpi(varargin{1}, 'factory')
    prefn = fieldnames(vrgetpref);
    prefv(1,1:numel(prefn)) = {'factory'};
    vrsetpref(prefn, prefv);
    return;
  else
    error('VR:invalidinarg', 'Not enough input arguments.');
  end
end

% prepare cell array pair of names and arguments
[prefname, prefval] = vrpreparesetargs(1, varargin, 'preference');

% process all preferences
for i=1:numel(prefname)
  prefn = prefname{i};
  prefv = prefval{i};

% process 'factory'
  if strcmpi(prefv, 'factory')
    vrsetpref(prefn, vrgetpref(prefn, 'factory'));
    continue;
  end

% process individual preferences
  switch prefn

   % Transport buffer, VR and HTTP ports
    case {'TransportBuffer', 'TransportTimeout', 'HttpPort', 'VrPort'}
      switch prefn
        case 'TransportBuffer'
          prefmin = 1;
          prefmax = 400;
        case 'TransportTimeout'
          prefmin = 1;
          prefmax = 3600;
        case {'HttpPort', 'VrPort'}
          prefmin = 1025;
          prefmax = 65535;
      end
      if isnumeric(prefv) && prefv >= prefmin && prefv <= prefmax
        prefv = round(prefv);
        if prefv ~= vrgetpref(prefn)
          setpref('VirtualReality', prefn, prefv);
          warning('VR:prefneedsrestart', ...
                  '''%s'' change will take effect after restarting MATLAB.', prefn);
        end
      else
        error('VR:invalidprefvalue', ...
              'Value for ''%s'' must be a number in range %d to %d or ''factory''.', prefn, prefmin, prefmax);
      end

   % figure maximum texture size
    case {'DefaultFigureMaxTextureSize'}
      if isnumeric(prefv) || strcmpi(prefv, 'auto')
        if isnumeric(prefv)
          prefv = round(prefv);
        end
        setpref('VirtualReality', prefn, prefv);
      else
        error('VR:invalidprefvalue', ...
              'Value for ''%s'' must be a number, ''auto'', or ''factory''.', prefn);
      end

    % world record interval
    case {'DefaultWorldRecordInterval'}
      

    % preferences that take an integer
    case {'DefaultFigureRecord2DCompressQuality'}
      if isnumeric(prefv)
        prefv = round(prefv);
        setpref('VirtualReality', prefn, prefv);
      else
        error('VR:invalidprefvalue', ...
              'Value for ''%s'' must be a number, or ''factory''.', prefn);
      end

    % preferences that take a string
    case {'DefaultFigureDeleteFcn', 'DefaultFigureRecord2DCompressMethod', ...
          'DefaultFigureRecord2DFileName', 'DefaultWorldRecord3DFileName', ...
          'Editor'}
      if ischar(prefv)
        setpref('VirtualReality', prefn, prefv);
      else
        error('VR:invalidprefvalue', ...
              'Value for ''%s'' must be a string.', prefn);
      end

    % preferences that take numeric vectors
    case {'DefaultFigurePosition', 'DefaultWorldRecordInterval' }
      switch prefn
        case 'DefaultFigurePosition'
          len = 4;
        case 'DefaultWorldRecordInterval'
          len = 2;
      end

      if isnumeric(prefv) && numel(prefv)==len
        setpref('VirtualReality', prefn, prefv);
      else
        error('VR:invalidprefvalue', ...
              'Value for ''%s'' must be a %d element numeric vector.', ...
              prefn, len);
      end

    % preferences that take string enumerations
    case {'DefaultFigureNavPanel', 'DefaultViewer', ...
          'DataTypeBool', 'DataTypeInt32', 'DataTypeFloat', ...
          'DefaultWorldRecordMode', 'DefaultWorldTimeSource' }
      switch prefn
        case 'DefaultFigureNavPanel'
          values = {'none', 'translucent', 'opaque', 'halfbar', 'bar'};
          restart = false;
        case 'DefaultViewer'
          values = {'internal', 'web'};
          restart = false;
        case 'DataTypeBool'
          values = {'logical', 'char'};
          restart = true;
        case 'DataTypeInt32'
          values = {'int32', 'double'};
          restart = true;
        case 'DataTypeFloat'
          values = {'single', 'double'};
          restart = true;
        case 'DefaultWorldRecordMode'
          values = {'manual', 'scheduled'};
          restart = false;
        case 'DefaultWorldTimeSource'
          values = {'external', 'freerun'};
          restart = false;
      end;
      if ischar(prefv) && any(strcmp(prefv, values))
        if restart && ~strcmp(prefv, vrgetpref(prefn))
          warning('VR:prefneedsrestart', ...
                  '''%s'' change will take effect after restarting MATLAB.', prefn);
        end
        setpref('VirtualReality', prefn, prefv);
      else
        error('VR:invalidprefvalue', ...
              'Value for ''%s'' must be one of %sor ''factory''.', ...
              prefn, sprintf('''%s'', ', values{:}));
      end

    % preferences that are 'on'/'off' switches
    case {'DefaultFigureAntialiasing', 'DefaultFigureLighting', ...
          'DefaultFigureNavZones', 'DefaultFigureStatusBar', ...
          'DefaultFigureToolBar', 'DefaultFigureTransparency', ...
          'DefaultFigureWireframe', 'DefaultWorldRemoteView', ...
          'Verbose' }
      values = {'on', 'off'};
      if ischar(prefv) && any(strcmp(prefv, values))
        setpref('VirtualReality', prefn, prefv);
      else
        error('VR:invalidprefvalue', ...
              'Value for ''%s'' must be one of %sor ''factory''.', ...
              prefn, sprintf('''%s'', ', values{:}));
      end

    otherwise
      error('VR:invalidprefname', 'Unknown preference name ''%s''.', prefn);
    end

end
