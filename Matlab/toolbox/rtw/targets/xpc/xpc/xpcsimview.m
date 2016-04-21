function xpcsimview(system,flag)
% XPCSIMVIEW Launches the xPC Target Simulink viewer.
%
%   XPCSIMVIEW(SYSTEM) launches the xPC Target Simulink Viewer.
%   The Simulink Viewer enables to interface with the xPC Target
%   application on the Target PC, tuning parameters, tracing signals,
%   adding/removing signals to xPC Target Scopes.
%
%   Use of Simulink Viewer:
%
%   Tuning Parameters:
%
%   To tune parameters using the Simulink Viewer scroll over viewer area
%   with your mouse. When the pointer of the mouse falls within the borders
%   of any block, that block becomes highlighted with a specific color indicator
%   (Blue, Red, Black).
%  - If block highlight is blue: indicates the block contains tunable parameters.
%    Result of left clicking when blue opens the xPC Target block parameters dialog box.
%  - If block highlight is red: indicates the block does not contain tunable parameters.
%    Result of clicking when red, no action on a red highlighed block.
%  - If block highlight is black: indicates the block is a subsystem.
%    Result of left clicking when black, opens the clicked subsystem in the same figure.
%
%   Signal Tracing:
%
%   To trace signals using the Simulink Viewer scroll over the block output signals.
%   When pointer of the mouse is over a block output signal, the signal becomes
%   highlighted with a specific color (blue and red).
% - If Signal highlight is blue: indicates that signal can be traced by placing the mouse
%   directly over the blue highlight and a tracing tool appears with its corresponding
%   signal value.
%   Result when right clicked adds corresponding signal to defined scopes.
% - If Signal higlight is red, indicates that Signal can not be traced.
%
%   Navigating the Simulink Viewer:
%
%   If the simulink model contains subsystems you can navigate into each subsystem by
%   right clicking inside a subystem block highlighted with the black color. To go 
%   back up one level, you can right click and select "go back one level" or press the
%   Escape key.
%
%   Note: The Simulink Viever is not recommnded for use with large scale models.
%   See Also XPCRCTOOL.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/05/18 02:05:57 $

error(nargchk(1,3,nargin));

fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandle=findobj(0,'type','figure','tag','xPCSLViewFigure');
set(0,'showhiddenhandles',fvisibiltystat);
if fighandle %if instance of xPCTool already exist
   delete(fighandle)
end

if nargin < 2
  flag = 1;                             % save the data in a struct
end
if nargin < 3
  status = '';
end
sysinfo = getModelStruct(system);
if isempty(sysinfo)
  sysinfo = genxml(system,'struct');
end
slbd(sysinfo,flag);

function str = getModelStruct(sys)
% will regenerate the structure if
% 1. mdl file does not exist, but model is loaded.
% 2. mdl file exists, model is loaded, but is dirty (matFile date is
%    irrelevant).
% 3. matFile does not exist (mdlDate is irrelevant).
% 4. If model is not loaded or if it is loaded, but not dirty, the
%    timestamps are used: regeneration happens if matfile is older than
%    mdlFile.

%default values
mdlTime = inf;
matTime = 0;
dirty   = 0;

model_open = ~isempty(strmatch(sys, find_system('Type', 'block_diagram')));
if model_open
  dirty = strcmp(get_param(sys, 'Dirty'), 'on');
end

% if model does not exist or is dirty, mdlTime remains inf (will regen)
if ~dirty & exist(sys) == 4             % .mdl file exists
  mdlTime = getFileTime([sys '.mdl']);
end

% if matFile does not exist, matTime remains 0 (will regen)
matFileName = [sys, 'view.mat'];
if exist(matFileName, 'file')
  matTime = getFileTime(matFileName);
end

if mdlTime < matTime
  str = load(matFileName);
  if isfield(str, 'str')
    str = str.str;
  else
    error(['Incorrect format for MAT file ' matFileName]);
  end
else
  str = genxml(sys, 'struct');
  save(matFileName, 'str');
end


function time = getFileTime(file)
time = datenum(getfield(dir(which(file)), 'date'));