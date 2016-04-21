function invalidateaxis(ax)
%INVALIDATEAXIS Invalidate an axis to recompute limits and ticks
%   This is an internal helper m-file for Handle Graphics.

% Copyright 2003-2004 The MathWorks, Inc.

%   INVALIDATEAXIS(AX) invalidates AX so that the next GET will
%   recompute all the limits and ticks to be current. This function
%   will add an invisible line to the axis for reuse.

for k=1:length(ax)
  h = handle(ax(k));
  if ishandle(h) && isa(h,'hg.axes')
    invalidateaxis(h);
  end
end