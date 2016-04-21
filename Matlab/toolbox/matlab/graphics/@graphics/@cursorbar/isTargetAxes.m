function tf = isTargetAxes(hThis)
%ISTARGETAXES - is the Target an axes

% Copyright 2003 The MathWorks, Inc.

tf = false;

% return empty if there is no Target
if isempty(hThis.Target)
    tf = [];
    return
end


if (length(hThis.Target) == 1) && ishandle(hThis.Target) && isa(hThis.Target,'hg.axes')
    tf = true;
end