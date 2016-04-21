function layout_disc_window(systemname, command, varargin)
%LAYOUT_DISC_WINDOW Lays out Simulink/Stateflow for Simulink Model Discretizer.
% Note: This function is designed to be called only by Simulink Model Discretizer alone.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/03/30 16:10:30 $

persistent currentSettings;
persistent openScopes;

if (strcmpi(command, 'layout'))
  currentSettings1 = [];
  openScopes1 = [];
  [currentSettings1 openScopes1] = layoutwindow(systemname, varargin{1}, varargin{2}, varargin{3}, varargin{4});
  if(isempty(currentSettings))
      currentSettings = currentSettings1;
  end
  if(isempty(openScopes))
      openScopes = openScopes1;
  end
  if(~mislocked)
      mlock;
  end
elseif (strcmpi(command, 'restore'))
   try
      if (~isempty(currentSettings))
          restorewindow(currentSettings, openScopes);
      end      
      if (strcmp(get_param(systemname, 'dirty'), 'on'))
	    set_param(bdroot(systemname), 'open', 'on');
        try
            conflib = get_param(systemname,'disc_configurable_lib');
            if (strcmp(get_param(conflib, 'dirty'), 'on'))
                showConfLib = varargin{1};
                if(showConfLib==1)
                    set_param(conflib, 'open', 'on');
                else
                    bdclose(conflib);
                end
            else
                bdclose(conflib);
            end
        catch
        end        
      else
        try
            conflib = get_param(systemname,'disc_configurable_lib');
            if (strcmp(get_param(conflib, 'dirty'), 'on'))
                set_param(conflib, 'open', 'on');
            else
                bdclose(conflib);
            end
        catch
        end
        set_param(bdroot(systemname), 'open', 'on');
%         close_system(systemname);        
      end
      munlock layout_disc_window;
      clear layout_disc_window;
   catch
      munlock layout_disc_window;    
      clear layout_disc_window;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAYOUTWINDOW Lays out Simulink or Stateflow models at the given location.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [currentValue, openScopes1] = layoutwindow(systemname, topLeftPoint, bottomLeftPoint, topRightPoint, bottomRightPoint)

blockDiagramType        = get_param(systemname, 'BlockDiagramType');
shouldLock              = 'off';
if (strcmp(blockDiagramType, 'library') & ...
	strcmp(get_param(systemname, 'lock'), 'on'))                          % Unlock the system if it is a library.
	set_param(systemname, 'lock', 'off');
	shouldLock            = 'on';                                         % To lock the library again at the end.
end


if ( strcmp(get_param(systemname, 'ModelBrowserVisibility'), 'on') & ispc)
  deltaX				      = get_param(systemname, 'ModelBrowserWidth') + 10;
else
  deltaX			          = 10;
end

if ( strcmp(get_param(systemname, 'Toolbar'), 'on') & ispc)
  deltaY				      = 75;
else
  deltaY			          = 50;
end

if ( strcmp(get_param(systemname, 'Statusbar'), 'on') & ispc)
  deltabottomRightPoint	= 25;
else
  deltabottomRightPoint = 5;
end

currentValue            = cell(0, 1);
% subsystems              = find_system(systemname, 'SearchDepth', 'all', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'BlockType', 'SubSystem');
subsystems              = find_system(systemname, 'SearchDepth', 'all', 'BlockType', 'SubSystem');
allsystems              = cell(length(subsystems)+1,1);
allsystems{1}         = systemname;
for i = 2:length(allsystems)
    allsystems{i} = subsystems{i-1};
end
subsystems              = allsystems;
for i                   = 1: length(subsystems)
  presentSettings       = cell(1, 3);                                  % Record present settings
  presentSettings{1, 1} = subsystems{i};
  presentSettings{1, 2} = get_param(subsystems{i}, 'open');
  presentSettings{1, 3} = get_param(subsystems{i}, 'location');
  presentSettings{1, 4} = get_param(subsystems{i}, 'zoomfactor');
  currentValue{length(currentValue) + 1, 1} = presentSettings;

  if (strcmp(subsystems{i}, systemname))
    set_param(systemname, 'open', 'on');
    set_param(systemname, 'location',			                          ...% Set the location.
			[(topLeftPoint + deltaX)				                              ...
       (bottomLeftPoint + deltaY)				                            ...
       (topRightPoint  + topLeftPoint - 20)			                    ...
       (bottomRightPoint + bottomLeftPoint - deltabottomRightPoint) ...
      ]);
    set_param(systemname, 'Zoomfactor', 'FitSystem');                  % Set zoom factor
  else
    set_param(subsystems{i}, 'open', 'off');                           % Close subsystems.
  end
end

scopeToClose            = find_system(systemname, 'BlockType', 'Scope');
openScopes1              = cell(0);
for i                   = 1 : length(scopeToClose)                      % Close all open scopes.
  figId                 = get_param(scopeToClose{i}, 'figure');
  if (figId <= 0)
    continue;
  end
  openScopes1{length(openScopes1) + 1} = figId;
	set(figId, 'visible', 'off');
end


machineID 		          = getmachineid(systemname);                     % close stateflow charts.
if (~isempty(machineID) & machineID ~= 0)
  charts				  = sf('get', machineID, '.charts');
  for i = 1:length(charts)
	chart			      = charts(i);
    sfclose(chart); 		  				                              % Close the chart.
  end
end

if (strcmp(blockDiagramType, 'library') & strcmp(shouldLock, 'on'))     % Lock the system if necessary.
	set_param(systemname, 'lock', 'on');
end

%end layoutwindow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTOREWINDOW Restores Simulink windows to locations prior to running layoutwindow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restorewindow(currentsettings, openscopes)

for i = 1 : length(currentsettings)
    try
        system                = currentsettings{i};
        systemname            = system{1};
        
        if strcmp(get_param(systemname,'type'),'block_diagram')
            systemtype            = 'block_diagram';
        elseif strcmp(get_param(systemname,'blocktype'),'SubSystem')
            systemtype            = 'subsystem';
        else
            systemtype            = 'block';
        end
        
        if (strcmpi(systemtype, 'block_diagram') | strcmpi(systemtype, 'subsystem'))
            if(~strcmpi(system{2}, get_param(systemname, 'open')))
                set_param(systemname, 'open', system{2});
            end
            if(strcmpi(system{2}, 'on'))
                if(strcmpi(systemtype, 'block_diagram'))
                    hilitediscblock(systemname,3,[],[],1);
                else
                    hilitediscblock(systemname,3,[],[],0);
                end        
                set_param(systemname, 'location', system{3});
                set_param(systemname, 'zoomfactor', system{4});
            end
            %   else
            %     % TODO
        end
    catch
    end
end

for i = 1 : length(openscopes)
  set(openscopes{i}, 'visible', 'on');
end

%end restorewindow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GETMACHINEID Get the Stateflow machine id for a model if any.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function machineId = getmachineid(model)

[mf, mexf]        = inmem;
sfIsHere          = any(strcmp(mexf,'sf'));
if(sfIsHere)
    machineId     = sf('find', 'all', 'machine.name', model);
else
    machineId     = 0;
end

%end getmachineid