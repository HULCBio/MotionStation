function selectobject(h,action)
%SELECTOBJECT Select object for plotedit.

%   SELECTOBJECT(H) selects the object H
%   SELECTOBJECT(H,ONOFF) if ONOFF is 'on', selects and if ONOFF is 'off'
%   deselects the object H 
%   SELECTOBJECT(H,'replace') replaces currently selected objects with the
%   vector of handles H
%
%   See also GETSELECTOBJECTS, DESELECTALL.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $  $  $  $

error(nargchk(1,2,nargin));

if iscell(h), h = [h{:}]; end
if ~all(ishandle(h))
    error('first argument must be a handle or vector of handles');
end
if nargin>1 && ...
        (~ischar(action) || ...
        ~(strcmpi(action,'on')||strcmpi(action,'off')||strcmpi(action,'replace')))
    error('second arg must be ''on'',''off'' or ''replace''');
end
if nargin==1
    action='on';
end
if isempty(h)
    fig = gcbf;
    if isempty(fig)
        fig = gcf;
    end
else
    fig = ancestor(h(1),'figure');
end
if isempty(fig)
    error('object does not have a figure ancestor');
end
% get the scribe axes
scribeaxes = handle(findall(fig,'Tag','scribeOverlay'));
% make a scribe model if it doesn't exist
if isempty(scribeaxes)
    scribeaxes = scribe.scribeaxes(fig);
end
switch action
    case {'on','off'}
        % call scribeaxes selectobject function
        scribeaxes.methods('selectobject',h,action);
    case {'replace'}
        scribeaxes.methods('replace_selected_objects',h);
end
