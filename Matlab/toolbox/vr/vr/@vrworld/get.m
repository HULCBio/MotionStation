function y = get(world, propertyname)
%GET Get a property of VRWORLD.
%   Y = GET(W, 'propertyname') returns the value of the specified
%   property for the world referenced by the VRWORLD handle W. If
%   W is a vector of VRWORLD handles, then GET will return an
%   M-by-1 cell array of values where M is equal to LENGTH(W).
%   If 'propertyname' is a 1-by-N or N-by-1 cell array of strings containing
%   field names, then GET will return an M-by-N cell array of
%   values. If 'propertyname' is not specified, all properties are
%   printed.
%
%   Y = GET(W) where W is a scalar, returns a structure where
%   each field name is the name of a property and each field contains
%   the value of that property.
%
%   Valid properties are (property names are case-insensitive):
%
%     'Clients' (read-only)
%        Number of clients currently viewing this world.
%
%     'ClientUpdates' (settable)
%        This is 'on' when the clients are allowed to update the viewed scene
%        and 'off' if they are not.
%
%     'Description' (settable)
%        Descriptive name of the world.
%
%     'Figures' (read-only)
%        Handles of figures currently open for this world.
%
%     'FileName' (settable)
%        A name of the VRML file associated with this world.
%
%     'Nodes' (read-only)
%        A vector of VRNODE objects representing the world nodes.
%        This is only valid if the world is open, otherwise it is 
%        an empty vector.
%
%     'Open' (read-only)
%        This is 'on' for an open world and 'off' for a closed world.
%
%     'Record3D' (settable)
%        Enables 3D offline animation recording.
%
%     'Record3DFileName' (settable)
%        3D - VRML offline animation file name.
%        The file name can contain following tokens that will be interpreted
%        at the time of creating the animation file:
%
%          '%f' will be replaced by the virtual world filename 
%          '%d' will be replaced by the full path of the world file directory  
%          '%n' will be replaced by an incremental number  
%          '%h' will be replaced by current time hour (hh)  
%          '%m' will be replaced by current time minute (mm)  
%          '%s' will be replaced by current time second (ss)  
%          '%D' will be replaced by current day in month (dd)  
%          '%M' will be replaced by current month (mm)  
%          '%Y' will be replaced by current year (yyyy)  
%
%     'Recording' (settable)
%        Animation recording toggle. This property acts as the master 
%        recording switch.
%        When this property is set to 'on', offline animation files 
%        are recorded according to the current settings of other 
%        recording-related VRWORLD and VRFIGURE properties.
%        When set to 'off', offline animation recording is not active,
%        is stopped or recording mechanism waits for scheduled recording 
%        to take place, if defined properly by 'RecordMode' and 'RecordInterval'
%        properties.
%
%     'RecordMode' (settable)
%        Specifies the offline animation recording mode. Valid settings are:
%
%          'manual'    for recording to be controlled interactively by the user
%          'scheduled' for 'Recording' property to be controlled by scheduling
%                      mechanism.
%
%        The user can always override the recording schedule by starting 
%        or stopping the recording interactively earlier than scheduled.
%
%     'RecordInterval' (settable)
%        Vector of two doubles representing start and stop times 
%        for scheduled animation recording. Corresponds to 'Time' property.
%
%     'RemoteView' (settable)
%        This is 'on' when this world is viewable from a remote computer,
%        and 'off' if it is not.
%
%     'Time' (settable)
%        Current time in the scene.
%
%     'TimeSource' (settable)
%        How the time in the scene is handled. This can be 'external' if
%        the scene time should be controlled from MATLAB or Simulink, or
%        'system' to increment the scene time with the system time.
%
%     'View' (settable)
%        This is 'on' if the world can be viewed, 'off' if it is not.

% Undocumented properties:
%     'Id' (read-only)
%        This is an automatically generated world identification number.
%
%     'OpenCount' (read-only)
%        How many times the world was opened (0 if it is closed).

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.16.4.6 $ $Date: 2004/03/15 22:35:30 $ $Author: batserve $


% use this overloaded GET only if the first argument is VRWORLD
if ~isa(world, 'vrworld')
  builtin('get',world,propertyname);
  return
end

% if no name given return all properties
if nargin<2
  if nargout==0 && length(world)>1
    error('VR:invalidinarg', 'Vector of VRWORLDs is not allowed if there is no output parameter.');
  end
  propertyname = { ...
                  'Clients', ...
                  'ClientUpdates', ...
                  'Description', ...
                  'Figures', ...
                  'FileName', ...
                  'Nodes', ...
                  'Open', ...
                  'Record3D', ...
                  'Record3DFileName', ...
                  'Recording', ...
                  'RecordMode', ...
                  'RecordInterval', ...
                  'RemoteView', ...
                  'Time', ...
                  'TimeSource', ...
                  'View', ...
                 };
end

% validate PROPERTYNAME
if ischar(propertyname) 
  propertyname = {propertyname};
elseif ~iscellstr(propertyname)
  error('VR:invalidinarg', 'PROPERTYNAME must be a string or a cell array of strings.');
end

% initialize variables
y = cell(numel(world), numel(propertyname));

% loop through worlds
for i=1:size(y, 1)

  wid = world(i).id;
  
  % loop through property names
  for j=1:size(y, 2)

    switch lower(propertyname{j})

      % some properties need special handling

      case 'clients'
        y{i,j} = numel(vrsfunc('VRT3ListViews', wid)) + vrsfunc('GetRemoteCount', wid);

      case 'figures'
        y{i,j} = vrfigure(vrsfunc('VRT3ListViews', wid));
      
      case 'nodes'
        if isopen(world(i))
          y{i,j} = vrnode(world(i), vrsfunc('ListSceneNodes', wid));
        else
          y{i,j} = vrnode([]);
        end

      case 'id'
        y{i,j} = wid;

      otherwise

        % it is not a special property, use the common way
        y{i,j} = vrsfunc('GetSceneProperty', wid, propertyname{j});

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
