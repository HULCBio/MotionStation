function x = vrmfunc(varargin)
%VRMFUNC Simulink VR block controller function.
%   This function controls the behavior of the Simulink VR blocks (VR Source
%   and VR Sink).
%
%   Not to be used directly.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.35.4.13 $ $Date: 2004/03/30 13:18:01 $ $Author: batserve $


% invoke appropriate handler, returning a value if requested
if nargout>0
  x = feval(varargin{:});
else
  feval(varargin{:});
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% PORTS CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when Simulink wants to know the number
%%% of ports of this block. This happens when the diagram is open,
%%% when the simulation starts, and on every set_param (except
%%% setting UserData).
%%% We return a structure with two fields: 'InputPorts' and
%%% 'OutputPorts', containing information of port widths for every
%%% desired port.
%%%
function x = FnPorts(handle)    %#ok called by name from switchboard

% if we are in the VR Toolbox library, create fake ports and do nothing more
if islibrary(handle) && strcmp(get_param(bdroot(handle), 'Name'), 'vrlib')
  blkname = get_param(handle, 'Name');
  if strcmp(blkname, 'VR Source')
    x.InputPorts = struct('Size', {}, 'Class', {});
    x.OutputPorts = struct('Size', [1 1], 'Class', 1);
    return;
  elseif strcmp(blkname, 'VR Sink')
    x.InputPorts = struct('Size', [1 1], 'Class', 1);
    x.OutputPorts = struct('Size', {}, 'Class', {});
    return;
  end
end

% get the userdata structure
userdata = getsetuserdata(handle);

% try to open the new world
% if opening fails (e.g. world does not exist) we quietly ignore any error
% and we'll complain later during FnStart or FnDialog
[newworld, newworldopen] = tryopenworld(handle);

% close figures if the world has changed
if newworld==userdata.World
  figurepos = {};
else
  figurepos = get(userdata.FiguresOpen(find(isvalid(userdata.FiguresOpen),1)), 'Position');
  userdata = closeallfigures(userdata);
end

% close the old world (always, even if it's the same - we have just opened it second time)
if isvalid(userdata.World)
  close(userdata.World);
end

% replace old world by the new one (even by invalid one)
userdata.World = newworld;
userdata.WorldOpen = newworldopen;

% read lists of fields to be read or written.
issrc = issource(handle);
if issrc
  nodelist = get_param(handle, 'FieldsRead');
  [userdata.NodesRead, userdata.FieldsRead, x.OutputPorts] = nodelist2fields(nodelist);
  x.InputPorts = struct('Size', {}, 'Class', {});
else
  nodelist = get_param(handle, 'FieldsWritten');
  [userdata.NodesWritten, userdata.FieldsWritten, x.InputPorts] = nodelist2fields(nodelist);
  x.OutputPorts = struct('Size', {}, 'Class', {});
end

% the world is open and valid
if userdata.WorldOpen

  % copy block parameters to world
  setparamtoworldprop(userdata.World, handle);
  
  % retrieve port sizes if we don't know them all
  % if this fails we must live with the defaults
  if ~issrc && any([x.InputPorts.Class]==0)
    x.InputPorts = getfieldsizeinfo(userdata.World, userdata.NodesWritten, userdata.FieldsWritten);
  elseif issrc && any([x.OutputPorts.Class]==0)
    x.OutputPorts = getfieldsizeinfo(userdata.World, userdata.NodesRead, userdata.FieldsRead);
  end

  % open one figure at the position of the first valid one if the world has changed
  if ~isempty(figurepos)
    userdata.FiguresOpen = FnOpenFigure(handle, userdata.World, figurepos);
  end

end

% update the user data
getsetuserdata(handle, userdata);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% DESTROY CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is used when the block is being destroyed.
%%% Here we close the world we used (if any).
%%%
function FnDestroy(handle)    %#ok called by name from switchboard

% get userdata
% no need to set UserData in the end - the block is being destroyed anyway
userdata = getsetuserdata(handle);

% close any open figures
closeallfigures(userdata);

% destroy the dialog if it was created
if isfield(userdata, 'Dialog')
  userdata.Dialog.dispose();
end

% close the world we used, if any (don't complain if the world
% does not exist, it might be removed by the user)
if userdata.WorldOpen
  try
    close(userdata.World);
  catch
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% START CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is used when the simulation starts.
%%% If an error occurs, we return a string containing an error message;
%%% it will be printed from the Simulink.
%%%
function err = FnStart(h)    %#ok called by name from switchboard

% get userdata
userdata = getsetuserdata(h);

% open the world if not yet open by FnPorts
if ~userdata.WorldOpen
  [userdata.World, userdata.WorldOpen, err] = tryopenworld(h);
  userdata = restorefigures(h, userdata);
end

% return error if world cannot be open
if ~userdata.WorldOpen
  return;
end

% Now we check whether all mentioned nodes and fields still exist
% For read fields, we also set sync status to 'on' automatically.
nodes = userdata.NodesRead;
fields = userdata.FieldsRead;
for i=1:length(nodes)
  try node = vrnode(userdata.World, nodes{i}); catch err = lasterr; return; end
  try getfield(node, fields{i}); catch err = lasterr; return; end    %#ok this is overloaded GETFIELD
  sync(node, fields{i}, 'on');
end
nodes = userdata.NodesWritten;
fields = userdata.FieldsWritten;
for i=1:length(nodes)
  try node = vrnode(userdata.World, nodes{i}); catch err = lasterr; return; end
  try getfield(node, fields{i}); catch err = lasterr; return; end    %#ok this is overloaded GETFIELD
end

% set the simulation-running flag and signal reload needed
userdata.Running = true;
userdata.ReloadNeeded = true;

% if the dialog is open, disable untunable fields
if userdata.DialogOpen
  userdata.Dialog.setEnableStatus(userdata.Dialog.ENABLESTATUS_SIMULATING);
end

% write userdata
err = '';
getsetuserdata(h, userdata);

% update the simulation status on the figures
set(userdata.FiguresOpen, 'SimStatus', 'running');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% FINISH CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is used when the simulation stops.
%%%
function FnFinish(h)    %#ok called by name from switchboard

% get userdata
userdata = getsetuserdata(h);

% clear the simulation-running flag
userdata.Running = false;

% if the dialog is open, re-enable untunable fields
if userdata.DialogOpen
  userdata.Dialog.setEnableStatus(userdata.Dialog.ENABLESTATUS_ENABLED);
end

% write userdata
getsetuserdata(h, userdata);

% update the simulation status on the figures
set(userdata.FiguresOpen, 'SimStatus', 'stopped');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% APPLY CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is used when the user clicks 'Apply' or 'OK'
%%% in the VR block configuration dialog.
%%% Errors in this function are mostly ignored, so that the user
%%% can at least set the block properties. Errors will be reported
%%% when the user tries to start the simulation.
%%%
function FnApply(handle, worldfile, worlddesc, nodelist, view, rview, sampletime)    %#ok called by name from switchboard

% block in locked library can't be changed, ignore all settings
if islibrary(handle)
  return;
end

% get the user data
userdata = getsetuserdata(handle);

% decorate node list with size and datatype info
tryreconnect = isopen(userdata.DialogWorld);
if tryreconnect
  [newnodes, newfields] = nodelist2fields(nodelist);
  sizes = getfieldsizeinfo(userdata.DialogWorld, newnodes, newfields);
  nodelist = fields2nodelist(newnodes, newfields, sizes);
end

% determine if we are source or sink
if issource(handle)
  fieldparm = 'FieldsRead';
  portdir = 'Outport';
else
  fieldparm = 'FieldsWritten';
  portdir = 'Inport';
end

% determine if we'll try to reconnect ports
[oldnodes, oldfields] = nodelist2fields(get_param(handle, fieldparm));
tryreconnect = tryreconnect && ( (numel(oldnodes)~=numel(newnodes)) || (~all(strcmp([oldnodes; oldfields], [newnodes; newfields]))) );

% save old port connectivity, ports and line info
if tryreconnect
  model = get_param(handle,'Parent');
  oldconn = get_param(handle, 'PortConnectivity');
  oldports = get_param(handle, 'PortHandles');
  oldports = oldports.(portdir);
  oldlines = get_param(oldports, 'Line');
  if ~iscell(oldlines)
    oldlines = {oldlines};
  end

% save old line coordinates, then delete the line
  oldlnpoints = cell(size(oldlines));
  for i=1:numel(oldlines)
    ln = oldlines{i};
    if ln>0
      oldlnpoints{i} = get_param(ln, 'Points');
      delete_line(ln);
    end
  end

% only reconnect if world has not changed
 tryreconnect = userdata.DialogWorld==userdata.World;
end

% set all the parameters in one command, avoiding temporary parameter inconsistency
% and eliminating repeated mdlInitializeSizes callbacks
% (disable warnings so that MATLAB does not complain when we're creating
% a new port which has a name assigned before it really exists)
offon = { 'off', 'on' };
getsetuserdata(handle, userdata);
set_param(handle, ...
          'SampleTime', num2str(sampletime), ...
          'WorldFileName', worldfile, ...
          'WorldDescription', worlddesc, ...
          'RemoteView', offon{rview+1}, ...
          'AutoView', offon{view+1}, ...
          fieldparm, nodelist ...
          );
clear userdata;   % invalidate UserData after set_param

% try to reconnect lines if the same world but ports have changed
if tryreconnect

  % loop through old nodes
  oldnf = strread(fields2nodelist(oldnodes, oldfields), '%s', 'delimiter', '#');
  newnf = strread(fields2nodelist(newnodes, newfields), '%s', 'delimiter', '#');
  for i = 1:numel(oldnf)

    % test if there was a line
    lnp = oldlnpoints{i};
    if ~isempty(lnp)

      % test if the line leads to/from a still existing port
      idx = find(strcmp(oldnf{i}, newnf), 1);
      if ~isempty(idx)
        dst = sprintf('%s/%d', strrep(get_param(handle,'Name'), '/', '//'), idx);

        % if we are a sink, reconnect the line from source and set its points
        if strcmpi(portdir, 'Inport')
          src = sprintf('%s/%d', strrep(get_param(oldconn(i).SrcBlock,'Name'), '/', '//'), oldconn(i).SrcPort + 1);
          lnp = lnp(1:end-1,:);
          lnh = add_line(model, src, dst);
          if size(lnp,1)>2
            set_param(lnh, 'Points', lnp);
          end

        % if we are a source, reconnect the line to all sinks and set all the points to the same value
        else
          src = dst;
          dstname = strrep(get_param(oldconn(i).DstBlock,'Name'), '/', '//');
          dstport = oldconn(i).DstPort;
          if ~iscell(dstname)
            dstname={dstname};
          end
          lnp = lnp(2:end,:);
          for j=1:numel(dstname)
            dst = sprintf('%s/%d', dstname{j}, dstport(j) + 1);
            lnh = add_line(model, src, dst);
            if size(lnp,1)>2
              set_param(lnh, 'Points', lnp);
            end
          end
        end
        
      % if line doesn't connect to an existing port, just draw it unconnected
      else
        add_line(model, lnp);
      end
    end
  end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% OPEN CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the block is opened.
%%% If there are no VR figures for this block, a new one is open,
%%% otherwise the first one is brought to front.
%%% If there is no world associated, or if something fails,
%%% the configuration dialog is open instead so that the user
%%% can change whatever is needed to make the block work.
%%%
function FnOpen(h)    %#ok called by name from switchboard

% get userdata and file name of the associated world
[ud, created] = getsetuserdata(h);
filename = get_param(h, 'WorldFileName');

% if not initialized yet, or if in a library, or if no world
% is associated, or if default viewer is Web, 
% open the config dialog instead of a figure
if created || islibrary(h) || isempty(filename) || strcmpi(vrgetpref('DefaultViewer'), 'web')
  FnDialog(h);
  return;
end

% check if the world is still open, try reopening it if needed
if ~isopen(ud.World)
  [ud.World, ud.WorldOpen, err] = tryopenworld(h);

  % update the userdata to reflect the current state
  getsetuserdata(h, ud);

  % if it can't be opened, complain and open the config dialog
  if ~ud.WorldOpen
    uiwait(msgbox( ...
            sprintf('Can''t reopen world ''%s'': %s', filename, err), ...
            'Can''t reopen world'));
    FnDialog(h);
    return;
  end
end

% remove invalid figure handles from the block
ud.FiguresOpen(~isvalid(ud.FiguresOpen)) = [];
getsetuserdata(h, ud);

% open a figure or bring the existing figure to front
if isempty(ud.FiguresOpen)
  fig = FnOpenFigure(h, ud.World);
  ud.FiguresOpen = [ud.FiguresOpen fig];
  getsetuserdata(h, ud);
else
  fig = ud.FiguresOpen(1);
  set(fig, 'WindowCommand', 'raise');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% CLOSE CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the block is closed.
%%% It closes any open figures and block dialog if it is open.
%%%
function FnClose(h)    %#ok called by name from switchboard

% close any open figures
ud = getsetuserdata(h);
closeallfigures(ud);
getsetuserdata(h, ud);

% close the dialog if it was open
% UserData must be saved at this point because it is modified by FnDialogClosing
if ud.DialogOpen
  ud.Dialog.showDialog(false);
  drawnow;
  FnDialogClosing(h);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% OPENFIGURE CALLBACK %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked from Figure->New menu item.
%%% It is also called internally when a figure needs to be opened.
%%%
function f = FnOpenFigure(handle, world, position)
% Opens a figure with installing appropriate callbacks.

% open the Web browser if DefaultViewer is 'web'
if strcmpi(vrgetpref('DefaultViewer'), 'web')
  view(world);
  f = [];
  return;
end

% create the figure
if nargin>2
  f = vrfigure(world, position);
else
  f = vrfigure(world);
end

% install for create, delete ad block parameters
mdlh = bdroot(handle);
set(f, 'CreateFigureFcn', sprintf('vrmfunc(''FnOpenFigure'', hex2num(''%bX''), get(vrgcbf,''World''));', handle), ...
       'DeleteFcn',       sprintf('vrmfunc(''FnFigureDelete'', hex2num(''%bX''), vrgcbf);', handle), ...
       'BlockParametersFcn', sprintf('vrmfunc(''FnDialog'', hex2num(''%bX''));', handle) ...
   );

% install for start, stop, pause and continue only when not in external mode
if ~strcmpi(get_param(mdlh, 'SimulationMode'), 'external')
  set(f, 'SimStartFcn',     sprintf('set_param(hex2num(''%bX''), ''SimulationCommand'', ''start'');', mdlh), ...
         'SimPauseFcn',     sprintf('set_param(hex2num(''%bX''), ''SimulationCommand'', ''pause'');', mdlh), ...
         'SimContinueFcn',  sprintf('set_param(hex2num(''%bX''), ''SimulationCommand'', ''continue'');', mdlh), ...
         'SimStopFcn',      sprintf('set_param(hex2num(''%bX''), ''SimulationCommand'', ''stop'');', mdlh) ...
     );

  % reflect the simulation status to the figure
  simstate = get_param(mdlh, 'SimulationStatus');
  if strcmpi(simstate, 'running') || strcmpi(simstate, 'paused')
    set(f, 'SimStatus', simstate);
  else
    set(f, 'SimStatus', 'stopped');
  end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% VIEW CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when a world should be viewed.
%%%
function FnView(handle)    %#ok called by name from switchboard

% retrieve UserData
ud = getsetuserdata(handle);

% view the world
if isopen(ud.DialogWorld)
  figs = FnOpenFigure(handle, ud.DialogWorld);
  ud.FiguresOpen = [ud.FiguresOpen figs];
  getsetuserdata(handle, ud);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% EDIT CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when a world editor should be invoked.
%%%
function FnEdit(handle)    %#ok called by name from switchboard

% retrieve UserData
ud = getsetuserdata(handle);

% if we have a valid world, open it in the editor
if isvalid(ud.DialogWorld)
  edit(ud.DialogWorld);
else
% else open empty world
  edit(vrworld([]));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% LOAD CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when loading the block.
%%%
function FnLoad(handle)    %#ok called by name from switchboard

% try opening the world if not open yet
ud = getsetuserdata(handle);
if ~ud.WorldOpen
  [ud.World, ud.WorldOpen] = tryopenworld(handle);
end

% restore saved figures
ud = restorefigures(handle, ud);
getsetuserdata(handle, ud);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% INIT CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the world should be initialized.
%%%
function FnInit(handle)    %#ok called by name from switchboard

% retrieve UserData
ud = getsetuserdata(handle);

% reload the world
if ud.ReloadNeeded && isopen(ud.World)
  reload(ud.World);
end

% signal reload not needed
ud.ReloadNeeded = false;
getsetuserdata(handle, ud);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% RELOAD CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the dialog world should be reloaded.
%%%
function FnReload(handle)    %#ok called by name from switchboard

% retrieve UserData
ud = getsetuserdata(handle);

% reload the dialog world
if isopen(ud.DialogWorld)
  reload(ud.DialogWorld);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% ICON CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the block icon needs to be drawn.
%%% The return value is a string containing commands needed to draw
%%% the icon.
%%%
function drawcmd = FnIcon    %#ok called by name from switchboard

% get the block handle
handle = gcbh;

% compose the command - load the background bitmap, then label the ports
drawcmd = [sprintf('image(imread(''vrblockicon.png''));\n'), ...
           nodelist2iconlabel(handle, 'FieldsWritten', 'input'), ...
           nodelist2iconlabel(handle, 'FieldsRead', 'output') ];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% DIALOG CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the block properties dialog
%%% should be open.
%%%
function FnDialog(h)

% ensure the input parameter is a block handle, not a block path
h = get_param(h, 'handle');

% get the block user data - if we are in a locked or the main VR library, use persistent data instead
inlibrary = islibrary(h);
userdata = getsetuserdata(h);

% just bring dialog window to foreground if one is already open
if userdata.DialogOpen
  userdata.Dialog.showDialog(true);
  drawnow;
  return;
end

% create the dialog frame if not yet created
issrc = issource(h);
if ~isfield(userdata, 'Dialog')
  userdata.Dialog = com.mathworks.toolbox.vr.dialog.VRDialog(h, issrc);
end

% open the world if not yet open by FnPorts
err = '';
if ~inlibrary && ~userdata.WorldOpen
  [userdata.World, userdata.WorldOpen, err] = tryopenworld(h);
  userdata = restorefigures(h, userdata);
end

% set block-specific values
userdata.Dialog.setBlockParameters(get_param(h, 'WorldFileName'), ...
                                   fileparts(get_param(bdroot(h), 'FileName')), ...
                                   get_param(h, 'SampleTime'), ...
                                   strcmpi(get_param(h, 'AutoView'), 'on') ...
                                  );

% if not in library, display the fields
if ~inlibrary
  userdata.DialogWorld = userdata.World;

  % if the world is ok, fill in appropriate fields of the dialog
  if userdata.WorldOpen

    % if the world is open, open it once more for use in the dialog
    open(userdata.DialogWorld);

    % get a list of items which are checked
    if issrc
      checked = get_param(h, 'FieldsRead');
    else
      checked = get_param(h, 'FieldsWritten');
    end;

    id = get(userdata.World, 'Id');
    chain = vrsfunc('GetSceneSimpleChain', id);
    userdata.Dialog.setWorldParameters(chain, ...
                                       checked, ...
                                       strcmpi(get(userdata.World, 'RemoteView'), 'on') ...
                                      );
  else
    % if no world open, put any error message to the dialog
    userdata.Dialog.setNoWorldMessage(err);
  end

  % if the simulation is running, disable untunable fields
  if userdata.Running
    userdata.Dialog.setEnableStatus(userdata.Dialog.ENABLESTATUS_SIMULATING);
  end

else  % in library
  userdata.Dialog.setNoWorldMessage('Copy the block to a model to enable this dialog.');
  userdata.Dialog.setEnableStatus(userdata.Dialog.ENABLESTATUS_DISABLED);
end

% show the dialog
userdata.Dialog.showDialog(true);
drawnow;
userdata.DialogOpen = true;

% store the dialog handle to the user data
getsetuserdata(h, userdata);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% DIALOGCLOSING CALLBACK %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the block properties dialog
%%% is being closed by user.
%%%
function FnDialogClosing(h)    %#ok called by name from switchboard

ud = getsetuserdata(h);

% flag dialog as closed
ud.DialogOpen = false;

% close the dialog world
if isvalid(ud.DialogWorld)
  close(ud.DialogWorld);
  ud.DialogWorld = vrworld;
end

getsetuserdata(h, ud);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% HELP CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the help is requested.
%%%
function FnHelp(h)    %#ok called by name from switchboard

helpdir = fullfile(docroot, 'toolbox', 'vr', 'vr.map');
if isfield(get_param(h, 'DialogParameters'), 'FieldsRead');
  helpview(helpdir, 'vr_vrsource');
else
  helpview(helpdir, 'vr_vrsink');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% PRESAVE CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked before the block is saved.
%%%
function FnPreSave(h)    %#ok called by name from switchboard

% don't do anything for library block, AutoView=='off' or DefaultViewer=='web'
ud = getsetuserdata(h);
if islibrary(h) || isempty(ud.FiguresOpen) ...
                || strcmpi(get_param(h, 'AutoView'), 'off') ...
                || strcmpi(vrgetpref('DefaultViewer'), 'web')
  return;
end

% read figure properties
propn = {
         'Position', ...        % set figure Position and Name first
         'Name', ...
         'Viewpoint', ...       % ViewPoint must be set before camera properties
         'CameraBound', ...
         'CameraDirection', ...
         'CameraPosition', ...
         'CameraUpVector', ...
         'ZoomFactor' ...
         'Antialiasing', ...    % then set the rendering flags
         'Headlight', ...
         'Lighting', ...
         'NavPanel', ...
         'StatusBar', ...
         'ToolBar', ...
         'Textures', ...
         'Transparency', ...
         'Wireframe', ...
         'NavZones', ...
         'NavMode', ...         % navigation settings
         'NavSpeed', ...
         'Record2DCompressMethod', ...      % recording settings
         'Record2DCompressQuality', ...
         'Record2D', ...
         'Record2DFileName', ...
        };
propv = [propn; get(get(ud.World,'Figures'),propn)];

% save them into FigureProperties parameter
propstr = '{';
for i=1:size(propv,1)
  for j=1:size(propv,2)
    if ischar(propv{i,j})
      propstr = [propstr '''' strrep(propv{i,j},'''','''''') ''', '];
    else
      propstr = [propstr '[' num2str(propv{i,j}, '%25.16e') '], '];
    end
  end
  propstr(end-1) = ';';    % replace the final comma with a semicolon
end
propstr(end-1) = '}';      % replace the final semicolon with the closing bracket
set_param(h, 'FigureProperties', propstr);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% WORLDCHANGED CALLBACK %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the world in dialog is changed.
%%%
function x = FnDialogWorld(handle, filename)    %#ok called by name from switchboard

% try to open the world entered in dialog
[w, wvalid, err] = tryopenworld(handle, filename);
if wvalid
  chain = vrsfunc('GetSceneSimpleChain', get(w,'Id'));
  remoteview = strcmpi(get(w, 'RemoteView'), 'on');
  dlgworld = w;
else
  chain = err;
  remoteview = false;
  dlgworld = vrworld;
end

% store the dialog world into UserData, closing the old dialog world first
ud = getsetuserdata(handle);
if isvalid(ud.DialogWorld)
  close(ud.DialogWorld)
end
ud.DialogWorld = dlgworld;
getsetuserdata(handle, ud);

% update the dialog
x = {java.lang.Boolean(wvalid), chain, java.lang.Boolean(remoteview)};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% COPY CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the block is copied.
%%%
function FnCopy(handle)    %#ok called by name from switchboard

% clear UserData for the copy of the block
% it will get recreated as if it came from the library
getsetuserdata(handle, []);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% DELETE CALLBACK %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when the block is removed from
%%% the model (but not yet destroyed)
%%%
function FnDelete(handle)    %#ok called by name from switchboard

% the same as FnClose
FnClose(handle);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% FIGUREDELETE CALLBACK %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This callback is invoked when a figure is being deleted.
%%%
function FnFigureDelete(blk, f)    %#ok called by name from switchboard

% get the figure list, don't error out if the block doesn't exist anymore
try
  ud = getsetuserdata(blk);
catch
  return;
end

% remove the figure from the figure list, as well as all invalid figures
ud.FiguresOpen((ud.FiguresOpen==f) | ~isvalid(ud.FiguresOpen)) = [];

% commit the changes
getsetuserdata(blk, ud);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = islibrary(handle)
% Returns true if this block is inside either a locked library or the VRLIB library

bh = bdroot(handle);
x = strcmp(get_param(bh, 'Type'), 'block_diagram') ...
    && strcmp(get_param(bh, 'BlockDiagramType'), 'library') ...
    && (strcmp(get_param(bh, 'Name'), 'vrlib') || strcmp(get_param(bh, 'Lock'), 'on'));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = issource(handle)
% Returns true if this block is a VR Source
x = isfield(get_param(handle, 'DialogParameters'), 'FieldsRead');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ud, created] = getsetuserdata(handle, ud)
% Get or set userdata for the block; create it if empty.

persistent sourceud;
persistent sinkud;

% SET
if nargin>1
  if ~islibrary(handle)
    set_param(handle, 'UserData', ud);
  else
    if issource(handle)
      sourceud = ud;
    else
      sinkud = ud;
    end
  end
  created = false;

% GET
else
  % get the userdata structure
  if ~islibrary(handle)
    ud = get_param(handle, 'UserData');
  else
    if issource(handle)
      ud = sourceud;
    else
      ud = sinkud;
    end
  end
  % if empty, create the structure
  created = isempty(ud);
  if created
    ud = struct( ...
                'World', vrworld, ...
                'WorldOpen', false, ...
                'NodesRead', [], ...
                'NodesWritten', [], ...
                'FieldsRead', [], ...
                'FieldsWritten', [], ...
                'Running', false, ...
                'DialogOpen', false, ...
                'DialogWorld', vrworld, ...
                'ReloadNeeded', false, ...
                'FiguresOpen', vrfigure([]) ...
               );
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nodes, fields, sizes] = nodelist2fields(nodelist)
% Extracts node names, field names and their sizes from nodelist.

% split nodelist string into cell array; initialize output values
nodelist = strread(nodelist, '%s', 'delimiter', '#');
nodes = cell(size(nodelist(:)));
fields = nodes;
sizes = struct('Size', {[-1 -1]}, 'Class', num2cell(zeros(size(nodelist(:)))) );

% fill in output values
for i=1:numel(nodelist)
  nodeandfield = strread(nodelist{i}, '%s', 'delimiter', '.');
  nodes(i) = nodeandfield(1);
  fields(i) = nodeandfield(2);
  if length(nodeandfield)>=3
    sizes(i).Size(1) = str2double(nodeandfield{3});
  end
  if length(nodeandfield)>=4
    sizes(i).Size(2) = str2double(nodeandfield{4});
  end
  if length(nodeandfield)>=5
    sizes(i).Class = feval(nodeandfield{5}, 1);
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sizes = getfieldsizeinfo(world, nodes, fields)
% Get size and datatype info for fields.

% initialize output structure
sizes = struct('Size', {[-1 -1]}, 'Class', num2cell(zeros(size(nodes(:)))) );
if ~isopen(world)
  return;
end

for i=1:numel(nodes)
  % try to read field value from the node
  try
    val = getfield(vrnode(world, nodes{i}), fields{i});    %#ok this is overloaded GETFIELD
  catch
    continue;
  end
  % treat chars as logicals, otherwise use the field class
  if ischar(val)
    sizes(i).Size = [1 1];
    sizes(i).Class = true;
  else
    sizes(i).Size = size(val');
    sizes(i).Class = feval(class(val), 1);
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nodelist = fields2nodelist(nodes, fields, sizes)
% Construct nodelist from nodes, fields and sizes.

nodeinfo = [nodes'; fields'];
fmt = '%s.%s#';
if nargin>=3
  nodeinfo = [nodeinfo; {sizes.Size}];
  for i=1:numel(sizes)
    nodeinfo{4,i} = class(sizes(i).Class);
  end
  fmt = '%s.%s.%d.%d.%s#';
end
nodelist = sprintf(fmt, nodeinfo{:});
nodelist=nodelist(1:end-1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawcmd = nodelist2iconlabel(handle, param, io)
% Constructs icon labels from from nodelist

drawcmd = '';
if ~isfield(get_param(handle, 'DialogParameters'), param)
  return;
end

labels = strread(get_param(handle, param), '%s', 'delimiter', '#');
for n=1:length(labels);
  lab = labels{n};
  labdot = find(lab=='.');
  if length(labdot)>1
    lab = lab(1:labdot(2)-1);
  end
  drawcmd = [drawcmd sprintf('port_label(''%s'', %d, ''%s'');\n', io, n, lab)];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setparamtoworldprop(w, handle)
% Sets world properties to match block parameters

set(w, 'RemoteView', get_param(handle, 'RemoteView'));
wdesc = get_param(handle, 'WorldDescription');
if ~isempty(wdesc)
  set(w, 'Description', wdesc);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [w, wvalid, err] = tryopenworld(handle, filename)
% Tries to open the world, returns open world on success or invalid world on failure.

% read filename from the block parameter if not explicitly specified
if nargin<2
  filename = get_param(handle, 'WorldFileName');
end

% a frequent special case
if isempty(filename)
    w = vrworld;
    wvalid = false;
    err = 'No world filename specified.';
    return;
end

% try to get the VRWORLD handle, then open the world
mfilepath = fullfile(fileparts(get_param(bdroot(handle), 'Filename')), filename);
try
  if (exist(mfilepath, 'file') == 2)
    w = vrworld(mfilepath);
  else
    w = vrworld(filename);
  end
  open(w);
catch
  w = vrworld;
  wvalid = false;
  err = lasterr;

  % try to make the error message simple
  pos = find(err==':', 1, 'last');
  if ~isempty(pos)
    err = err(pos(1)+1 : end);
  end

  return;
end

% set world properties according to block parameters
setparamtoworldprop(w, handle);

% everything OK
wvalid = true;
err = '';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = closeallfigures(ud)
% Close all figures for the block

ud.FiguresOpen(~isvalid(ud.FiguresOpen)) = [];
close(ud.FiguresOpen);
ud.FiguresOpen = vrfigure([]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = restorefigures(handle, ud)
% Restores open figures saved with the block

% clear invalid figures
ud.FiguresOpen(~isvalid(ud.FiguresOpen)) = [];

% only if autoview is on and world is open
if ~strcmpi(get_param(handle, 'AutoView'), 'on') || ~ud.WorldOpen
  return;
end;

% restore figures with their properties
figprop = eval(get_param(handle, 'FigureProperties'));
if strcmpi(vrgetpref('DefaultViewer'), 'internal') && size(figprop,1)>1
  figprop = cell2struct(figprop(2:end,:), figprop(1,:), 2);
  figs = FnOpenFigure(handle, ud.World(ones(size(figprop))), {figprop.Position});
  try
    set(figs, figprop);
  catch
    err = lasterr;
    errnl = find(err==char(10), 1, 'last');
    if ~isempty(errnl)
      err = err(errnl+1:end);
    end;
    warning('VR:cantrestorefigureprops', 'Some saved VR figure properties cannot be restored. {%s}', err);
  end

% or open a new figure at default position
else
  figs = FnOpenFigure(handle, ud.World);
end

% return modified UserData
ud.FiguresOpen = [ud.FiguresOpen figs];
