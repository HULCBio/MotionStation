function x = vrgetpref(prefname, defswitch)
%VRGETPREF Get Virtual Reality Toolbox preferences.
%   X = VRGETPREF(PREFNAME) returns a value of the specified Virtual Reality Toolbox
%   preference. If PREFNAME is a cell array of preference names, a cell array of
%   corresponding preference values is returned.
%
%   X = VRGETPREF returns values of all the preferences in a structure.
%
%   X = VRGETPREF(PREFNAME, 'factory') returns the initial built-in value for
%   the specified preference.
%
%   X = VRGETPREF('factory') returns the initial built-in value for all the
%   preferences in a structure.
%
%   Valid preferences are:
%
%     'DataTypeBool'
%        The MATLAB data type returned for VRML fields of type Bool.
%        It can be either 'logical' or 'char'. 'char' is the version 3.x
%        compatible behavior. Change to this preference takes effect only
%        after restarting MATLAB.
%
%     'DataTypeInt32'
%        The MATLAB data type returned for VRML fields of type Int32.
%        It can be either 'int32' or 'double'. 'double' is the version 3.x
%        compatible behavior. Change to this preference takes effect only
%        after restarting MATLAB.
%
%     'DataTypeFloat'
%        The MATLAB data type returned for VRML fields of type Float.
%        It can be either 'single' or 'double'. 'double' is the version 3.x
%        compatible behavior. Change to this preference takes effect only
%        after restarting MATLAB.
%
%     'DefaultFigureAntialiasing'
%        If antialiasing will be set by default for newly created VR figures.
%        See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureDeleteFcn'
%        Default figure callback invoked when the figure is closing.
%        See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureLighting'
%        If lights will be rendered by default for newly created VR figures.
%        See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureMaxTextureSize'
%        The maximum texture size that will be used by default for newly
%        created VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureNavPanel'
%        Panel mode that will be set by default for newly created VR figures.
%        See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureNavZones'
%        If navigation zones will be rendered by default for newly created
%        VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultFigurePosition'
%        The initial position and size of the internal viewer window.
%        See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureRecord2DCompressMethod'
%        Compression method for creating 2D animation files used for
%        newly created VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureRecord2DCompressQuality'
%        Compression quality for creating 2D animation files used for
%        newly created VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureRecord2DFileName'
%        File name of 2D animation files used for newly created VR figures.
%        See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureStatusBar'
%        If status bar will be displayed by default for newly created
%        VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureToolBar'
%        If status bar will be displayed by default for newly created
%        VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureTransparency'
%        If transparency is taken into account by default for newly created
%        VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultFigureWireframe'
%        If wireframes should be drawn by default for newly created
%        VR figures. See VRFIGURE/GET for detailed description.
%
%     'DefaultViewer'
%        This preference specifies which viewer will be used when the VIEW
%        command is issued. The 'internal' value specifies that the internal
%        viewer should be used, 'web' causes a Web browser to be invoked.
%
%     'DefaultWorldRecord3DFileName'
%        File name of 3D animation files used for newly created VR worlds.
%        See VRWORLD/GET for detailed description.
%
%     'DefaultWorldRecordMode'
%        Recording start/stop mode used for newly created VR worlds.
%        See VRWORLD/GET for detailed description.
%
%     'DefaultWorldRecordInterval'
%        Recording start/stop interval used for newly created VR worlds.
%        See VRWORLD/GET for detailed description.
%
%     'DefaultWorldRemoteView'
%        Remote view enable flag used for newly created VR worlds.
%        See VRWORLD/GET for detailed description.
%
%     'DefaultWorldTimeSource'
%        Time source used for newly created VR worlds.
%        See VRWORLD/GET for detailed description.
%
%     'Editor'
%        Command line used to run the VRML editor. It can contain
%        the following special tokens:
%          '%file' will be replaced by the appropriate VRML file name
%          '%matlabroot' will be replaced by MATLABROOT
%        If this preference is empty, the built-in MATLAB editor is used.
%
%     'HttpPort'
%        IP port number for accessing the VR server from the Web via HTTP.
%        Change to this preference takes effect only after restarting MATLAB.
%
%     'TransportBuffer'
%        Length of transport buffer (network packet overlay) for communication
%        between the VR server and its clients.
%
%     'TransportTimeout'
%        Time the VR server waits for a client response before it disconnects
%        the client.
%
%     'VrPort'
%        IP port used for communication between the VR server and its clients.
%        Change to this preference takes effect only after restarting MATLAB.

%   Undocumented preferences:
%     'Verbose'          - if this is 'on', both the VR Toolbox server
%                          and the client will show debugging info (very slow,
%                          produces much output)

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.12.4.6 $ $Date: 2004/03/15 22:35:37 $ $Author: batserve $

% create the defaults
defaults = struct( ...
                  'DataTypeBool', 'logical', ...
                  'DataTypeInt32', 'double', ...
                  'DataTypeFloat', 'double', ...
...
                  'DefaultFigureAntialiasing',            'off', ...
                  'DefaultFigureDeleteFcn',               '', ...
                  'DefaultFigureLighting',                'on', ...
                  'DefaultFigureMaxTextureSize',          'auto', ...
                  'DefaultFigureNavPanel',                'halfbar', ...
                  'DefaultFigureNavZones',                'off', ...
                  'DefaultFigurePosition',                [5 92 576 380], ...
                  'DefaultFigureRecord2DCompressMethod',  'auto', ...
                  'DefaultFigureRecord2DCompressQuality', 75, ...
                  'DefaultFigureRecord2DFileName',        '%f_anim_%n.avi', ...
                  'DefaultFigureStatusBar',               'on', ...
                  'DefaultFigureToolBar',                 'on', ...
                  'DefaultFigureTransparency',            'on', ...
                  'DefaultFigureWireframe',               'off', ...
...
                  'DefaultViewer', 'internal', ...
...
                  'DefaultWorldRecord3DFileName',         '%f_anim_%n.wrl', ...
                  'DefaultWorldRecordMode',               'manual', ...
                  'DefaultWorldRecordInterval',           [0 0], ...
                  'DefaultWorldRemoteView',               'off', ...
                  'DefaultWorldTimeSource',               'external', ...
...
                  'Editor', '', ...
                  'HttpPort', 8123, ...
                  'TransportBuffer', 5, ...
                  'TransportTimeout', 20, ...
                  'VrPort', 8124, ...
                  'Verbose', 'off' ...
                 );
if ispc
  defaults.Editor = '"%matlabroot\toolbox\vr\vrealm\program\vrbuild2.exe" "%file"';
end

% check the 'factory' switch
if nargin>1
  if strcmp(defswitch, 'factory')
    factory = true;
  else
    error('VR:invalidinarg', 'Invalid switch.');
  end
else
  factory = false;
end

% get all the preferences if no argument given
if nargin==0
  prefname = fieldnames(defaults);
end

% get the default value for the specified preference(s)
if ischar(prefname)
  if strcmp(prefname, 'factory')
    prefname = fieldnames(defaults);
    defval = defaults;
    factory = true;
  else
    try
      defval = defaults.(prefname);
    catch
      error('VR:invalidpref', 'Invalid preference name.');
    end
  end

elseif iscell(prefname)
  defval = cell(size(prefname));
  for i=1:numel(prefname)
    try
      defval{i} = defaults.(prefname{i});
    catch
      error('VR:invalidpref', 'Invalid preference name.');
    end
  end;

else
  error('VR:invalidinarg', 'Preference name must be a string or a cell array of strings.');

end

% return preferences or default preferences, as required
if factory
  x = defval;
else
  x = getpref('VirtualReality', prefname, defval);
end;

% return structure if no argument given, with undocumented preferences removed
if nargin==0
  x = rmfield(cell2struct(x, prefname, 2), {'Verbose'});
end
