function y = get(f, propertyname)
%GET Get a Virtual Reality figure property.
%   GET(F) displays values of all properties of the Virtual
%   Reality figure.
%
%   X = GET(F, PROP) returns a value of the specified property.
%
%   The following properties are valid (names are case insensitive):
%
%      'Antialiasing' (settable)
%         Determines whether antialiasing is used when rendering scene.
%         Antialiasing smoothes textures by interpolating values between
%         texture points. This causes a significant CPU load but makes
%         the scene look more natural.
%
%      'CameraBound' (settable)
%         This property controls whether the camera is bound to the
%         current viewpoint (i.e. it moves with it) or not.
%         When the camera is bound, its position, direction, and up vector
%         are relative to the viewpoint. For unbound camera, these values
%         are absolute.
%
%      'CameraDirection' (settable)
%         Camera direction, relative to the current viewpoint's direction.
%
%      'CameraDirectionAbs' (read-only)
%         Camera direction, in world coordinates.
%
%      'CameraPosition' (settable)
%         Camera position, relative to the current viewpoint's position.
%
%      'CameraPositionAbs' (read-only)
%         Camera position, in world coordinates.
%
%      'CameraUpVector' (settable)
%         Camera up vector, relative to the current viewpoint's up vector.
%
%      'CameraUpVectorAbs' (read-only)
%         Camera up vector, in world coordinates.
%
%      'DeleteFcn' (settable)
%         Callback invoked when the figure is closing.
%
%      'Headlight' (settable)
%         Specifies whether headlight is enabled.
%         The headlight is an additional white directional light
%         that moves and rotates with the camera.
%
%      'Lighting' (settable)
%         Specifies whether lighting is taken into account when rendering.
%         If it is off, all objects are drawn as if uniformly lit.
%
%      'MaxTextureSize' (settable)
%         The maximum pixel size used for drawing textures. The value must be
%         power of two and may be further adjusted to match specific hardware
%         renderer limits. Increasing this value improves image quality but
%         decreases performance. The value 'auto' sets the maximum possible
%         texture size.
%
%      'Name' (settable)
%         Name of this VR figure.
%
%      'NavMode' (settable)
%         Specifies the current navigation mode. Valid settings are
%         'walk', 'examine', or 'fly'.
%
%      'NavSpeed' (settable)
%         Specifies the current navigation speed. Valid settings are
%         'veryslow', 'slow', 'normal', 'fast', or 'veryfast'.
%
%      'NavPanel' (settable)
%         Panel mode. This affects how the control panel in the figure
%         is shown, and can have one of the following values:
%
%           'none'
%              Panel is not visible.
%
%           'translucent'
%              Panel floats half transparently above the scene.
%
%           'opaque'
%              Panel floats above the scene. This is the default.
%
%           'halfbar'
%              Most of the panel (except large items, like navigation wheel)
%              is drawn into a bar below the scene.
%
%           'bar'
%              Whole panel is drawn into a bar below the scene.
%
%      'NavZones' (settable)
%         Specifies if the navigation zones should be displayed.
%
%      'Position' (settable)
%         Screen coordinates of this VR figure.
%
%      'Record2D' (settable)
%         Enables 2D offline animation recording.
%
%      'Record2DCompressMethod' (settable)
%         Specifies compression method for creating 2D animation files.
%         Valid settings are '', 'auto', 'lossless', 'codec_code'
%         For valid 'codec_code' settings see AVIFILE.
%
%      'Record2DCompressQuality' (settable)
%         Specifies quality of 2D animation file compression.
%
%      'Record2DFileName' (settable)
%         2D offline animation file name.
%         The file name can contain following tokens that will be interpreted
%         at the time of creating the animation file:
%
%           '%f' will be replaced by the virtual world filename  
%           '%d' will be replaced by the full path of the world file directory  
%           '%n' will be replaced by an incremental number  
%           '%h' will be replaced by current time hour (hh)  
%           '%m' will be replaced by current time minute (mm)  
%           '%s' will be replaced by current time second (ss)  
%           '%D' will be replaced by current day in month (dd)  
%           '%M' will be replaced by current month (mm)  
%           '%Y' will be replaced by current year (yyyy)  
%
%      'StatusBar' (settable)
%         Specifies whether the status bar is shown.
%
%      'Textures' (settable)
%         Specifies whether textures are rendered.
%
%      'Transparency' (settable)
%         Specifies whether transparency is taken into account when
%         rendering. If it is off, all objects are drawn opaque.
%
%      'Viewpoint' (settable)
%         Viewpoint currently active for the given VR figure
%         (an empty string if the active viewpoint has no description).
%
%      'Wireframe' (settable)
%         Specifies whether wireframes should be drawn instead of solid
%         objects.
%
%      'World' (read-only)
%         World this VR figure is showing.
%
%      'ZoomFactor' (settable)
%         Camera zoom factor. Default zoom factor value is 1,
%         zoom factor of 2 makes the scene look twice as big,
%         zoom factor of 0.1 makes it look 10 times smaller, etc.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.12.4.6 $ $Date: 2004/03/02 03:08:05 $ $Author: batserve $


% use this overloaded GET only if the first argument is VRFIGURE
if ~isa(f, 'vrfigure')
  builtin('get',f,propertyname);
  return
end

% if no name given return all properties
if nargin<2
  if length(f)>1 && nargout==0
    error('VR:invalidinarg', 'Vector of VRFIGUREs is not allowed if there is no output parameter.');
  end
  
  % get a list of all gettable properties
  propertyname = vrsfunc('EnumFigureProperties', 'get');
  
  % 'World' is a special case in that it is processed directly here
  propertyname = { propertyname{:} 'World' };
  propertyname = sort(propertyname);
end

% validate PROPERTYNAME
if ischar(propertyname)
  propertyname = {propertyname};
elseif ~iscellstr(propertyname)
  error('VR:invalidinarg', 'PROPERTYNAME must be a string or a cell array of strings.');
end

% create the renamed properties table
renametbl = { 'InfoStrip', 'StatusBar';
              'PanelMode', 'NavPanel';
              'Title',     'Name';
            };

% initialize variables
y = cell(numel(f), numel(propertyname));

% loop through figures
for i=1:size(y, 1)

  % validate figure
  fh = f(i).handle;
  worldid = vrsfunc('VRT3SceneFromView', fh);

  % loop through property names
  for j=1:size(y, 2)

    % handle the renamed properties
    newname = renametbl(strcmpi(propertyname{j}, renametbl(:,1)), 2);
    if ~isempty(newname)
      newname = newname{1};
      warning('VR:obsoleteproperty', 'The property "%s" has been renamed to "%s". The old name still works, but will stop working in future releases.', ...
              propertyname{j}, newname);
      propertyname{j} = newname;
    end

    switch lower(propertyname{j})

    case 'handle'
      y{i,j} = fh;

    case 'world'
      y{i,j} = vrworld(worldid);

        otherwise
      % the new way of getting figure properties
      % (vrsfunc handles errors automatically).
      y{i,j} = vrsfunc('GetFigureProperty', fh, propertyname{j});

    end
  end
end

% convert to structure if getting all the properties
if nargin < 2
  y = cell2struct(y, propertyname, 2);

  % if no output arguments just print the result
  if nargout == 0
    vrprintval(y);
    clear y;
  end

% handle the scalar case
elseif length(y) == 1
  y = y{1};
end
