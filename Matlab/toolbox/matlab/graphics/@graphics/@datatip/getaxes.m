function [ax] = getaxes(hThis)
% Determine which axes the host references

% Copyright 2002-2003 The MathWorks, Inc.

ax = [];
hHost = hThis.Host;
if ~ishandle(hHost)
    return;
end

ax = ancestor(hThis.Host,'axes');

if isempty(ax)
    ax = get(hThis,'Parent');
end

ax = handle(ax);
