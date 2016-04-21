function objs=getselectobjects(fig)
%GETSELECTOBJECTS Returns selected objects.

%   H=GETSELECTOBJECTS(FIG) returns a vector H of handles to selected 
%   objects in the figure FIG.
%   H=GETSELECTOBJECTS returns a vector H of handles to selected 
%   objects in the current figure
%
%   See also DESELECTALL, SELECTOBJECT.
%
%   Copyright 1984-2003 The MathWorks, Inc.
%   $  $  $  $

nargchk(1,1,nargin);

if ~ishandle(fig) || ~strcmpi('figure',get(fig,'type'))
    error('first argument must be a handle to a figure');
end
objs=[];
% get the scribe axes
scribeaxes = handle(findall(fig,'Tag','scribeOverlay'));
if ~isempty(scribeaxes)
  methods(scribeaxes,'fixselectobjs');
  objs = scribeaxes.SelectedObjects;
end
