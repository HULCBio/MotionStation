function deselectall(fig)
%DESELECTALL Deselect all selected objects.

%   DESELECTALL(FIG) deselects all selected objects in the
%   figure FIG.
%
%   See also GETSELECTOBJECTS, SELECTOBJECT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $  $  $  $


error(nargchk(1,1,nargin));

if isempty(fig), return; end

if ~ishandle(fig)
    error('first argument must be a handle to a figure');
end

% get the scribe axes
scribeax = handle(findall(fig,'Tag','scribeOverlay'));
% make a scribe model if it doesn't exist
if isempty(scribeax)
    scribeax = scribe.scribeaxes(fig);
    % this should go into scribemodel constructor
end
% call model's deselectall function
scribeax.methods('deselectall');
