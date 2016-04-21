function hilite_system(sys,hilite,varargin)
%HILITE_SYSTEM Highlight a Simulink object.
%   HILITE_SYSTEM(SYS) highlights a Simulink object by first opening the system
%   window that contains the object and then highlighting the object using the
%   HiliteAncestors property.
%
%   You can specify the highlighting options as additional right hand side
%   arguments to HILITE_SYSTEM.  Options include:
%
%     default     highlight with the 'default' highlight scheme
%     none        turn off highlighting
%     find        highlight with the 'find' highlight scheme
%     unique      highlight with the 'unique' highlight scheme
%     different   highlight with the 'different' highlight scheme
%     user1       highlight with the 'user1' highlight scheme
%     user2       highlight with the 'user2' highlight scheme
%     user3       highlight with the 'user3' highlight scheme
%     user4       highlight with the 'user4' highlight scheme
%     user5       highlight with the 'user5' highlight scheme
%
%   To alter the colors of a highlighting scheme, use the following command:
%
%     set_param(0, 'HiliteAncestorsData', HILITEDATA)
%
%   where HILITEDATA is a MATLAB structure array with the following fields:
%
%     HiliteType       one of the highlighting schemes listed above
%     ForegroundColor  a color string (listed below)
%     BackgroundColor  a color string (listed below)
%
%   Available colors to set are 'black', 'white', 'red', 'green', 'blue',
%   'yellow', 'magenta', 'cyan', 'gray', 'orange', 'lightBlue', and
%   'darkGreen'.
%  
%   Examples:
%
%       % highlight the subsystem 'f14/Controller/Stick Prefilter'
%       hilite_system('f14/Controller/Stick Prefilter')
%
%       % highlight the subsystem 'f14/Controller/Stick Prefilter'
%       % in the 'error' highlighting scheme.
%       hilite_system('f14/Controller/Stick Prefilter', 'error')
%
%   See also OPEN_SYSTEM, FIND_SYSTEM, SET_PARAM

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

%
% massage the input data for easier management below:
%   chars  --> cell arrays
%   scalar --> vector of length 2 with repeate of scalar (a hack, yes, but
%              it does make things simpler...)
%
if ischar(sys),
  sys = { sys, sys };
elseif isreal(sys) & (length(sys) == 1),
  sys = [sys sys];
end

%
% it's easier to use handles instead of strings, it simplifies things
% in the code below
%
sys = get_param(sys,'Handle');
sys = [ sys{:} ];

%
% for port objects, use the line that they are connected to
%
ports = find(strcmp(get_param(sys,'type'),'port'));
portLines =  get_param(sys(ports),'Line');
if iscell(portLines),
  sys(ports) = [ portLines{:} ];
else
  sys(ports) = portLines;
end

%
% construct a list of parent windows for each of the specified objects
%
parents = get_param(sys,'Parent');

%
% weed out objects with no parent, they're models
%
mdls = find(strcmp(parents,''));
parents(mdls) = [];
sys(mdls) = [];

%
% construct a structure array that has two fields, the first a system
% name, the other being a rectangle that is the union of all objects
% that are in that system
%
hiliteBounds = LocalConstructHiliteBoundsRect(sys, parents);

%
% ok to open the parents now
%
open_system(parents, 'force');

%
% set the HiliteAncestors property for each of the blocks
%
if nargin == 1,
  hilite = 'on';
end

hiliteArgs = { 'HiliteAncestors', hilite };

%
% for each 'sys', set the HiliteAncestors property
%
for i = 1:length(sys),
  set_param(sys(i), hiliteArgs{:},varargin{:});
end

%
% the  last task to perform is to pan the systems into view
%
LocalPanSystem(hiliteBounds)

%
%===============================================================================
% LocalConstructHiliteBoundsRect
% Returns a structure array with the fields:
%   System:  name of a unique system that has some highlighting done within it
%   Bounds:  a rectangle that is the union of all object bounds  within the
%            system
%
%===============================================================================
%
function hiliteBounds = LocalConstructHiliteBoundsRect(sys, parents)

%
% if no parents, return an empty struct
%
if isempty(parents),
  hiliteBounds = cell2struct({ nan, nan }, { 'Name', 'Bounds' }, 2);
  hiliteBounds(1) = [];
  return;
end

%
% construct the basis for the return argument, a structure array with
% the unique systems
%
uniqSys = unique(parents);
for i=1:length(uniqSys),
  hiliteBounds(i).Name   = uniqSys{i};
  hiliteBounds(i).Bounds = Simulink.rect;
end

%
% for each sys, get the location and union it with the highlight bounds already
% computed for the system
%
for i=1:length(sys),
  dad = get_param(sys(i),'Parent');
  dadID = find(strcmp(uniqSys, dad));
  
  switch get_param(sys(i),'type'),
   case 'block',
    pos = Simulink.rect(get_param(sys(i),'Position'));

   case 'line',
    thisLine = LocalFindLine(dad,sys(i),get_param(dad,'Lines'));
    pos = LocalLinePosition(thisLine);
          
   case 'annotation',
    pos = get_param(sys(i),'Position');
    pos = Simulink.rect(pos, pos);
    
   otherwise,
    error('Unexpected type');
  end
  
  hiliteBounds(dadID).Bounds = hiliteBounds(dadID).Bounds + pos;

end

%
%===============================================================================
% LocalFindLine
% Finds the line from the Lines structure in the system.
%===============================================================================
%
function l = LocalFindLine(sys, lineHandle, lines)

l = [];
if isempty(lines),
  return;
end

lineIdx = find([lines(:).Handle] == lineHandle);
if ~isempty(lineIdx),
  l = lines(lineIdx);
  return;
end

for i = 1:size(lines,1),
  l = LocalFindLine(sys, lineHandle, lines(i).Branch);
  if ~isempty(l),
    return;
  end
end
  
%
%===============================================================================
% LocalLinePosition
% Constructs the bounding rectangle for a line (returned by the Lines
% parameter of a system.
%===============================================================================
%
function pos = LocalLinePosition(l)

pos = Simulink.rect;
for i = 1:size(l.Points,1)-1,
  pos = pos + Simulink.rect(l.Points(i,:), l.Points(i+1,:));
end

for i=1:size(l.Branch,1),
  pos = pos + LocalLinePosition(l.Branch(i));
end

%
%===============================================================================
% LocalPanSystem
% Pans a bounds rect within a system into view.
%===============================================================================
%
function LocalPanSystem(hiliteBounds)

%
% for each highlight bounds element, determine the scroll and zoom factor to
% bring it into view (i.e., pan)
% 
for i = 1:length(hiliteBounds),
  sys = hiliteBounds(i).Name;
  
  %
  % get the current location of the system
  %
  sysLoc = Simulink.rect(get_param(sys,'Location'));
  
  %
  % figure out the new zoom factor
  %
  bounds = inset(hiliteBounds(i).Bounds, -10, -10);
  zoom = min([1, width(sysLoc)/width(bounds), height(sysLoc)/height(bounds)]);
  
  %
  % compute the panning now
  %
  bounds = scale(hiliteBounds(i).Bounds, zoom);
  hLoc = round(bounds.left - (width(sysLoc) - width(bounds))/2);
  vLoc = round(bounds.top  - (height(sysLoc) - height(bounds))/2);
    
  newScroll = max(0, [hLoc, vLoc]);
  set_param(sys,'ZoomFactor',sprintf('%d',round(zoom * 100)),...
                'ScrollBarOffset',newScroll);
  
end
