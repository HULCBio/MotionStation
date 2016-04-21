function [dat] = getCursorInfo(hThis)

% Copyright 2003 The MathWorks, Inc.

dat = [];
hdc = get(hThis,'DataCursor');
  
% Populate structure
dat.Position = get(hdc,'Position');
dat.Target = get(hThis,'Host');

% For now, only populate this field for lines
% since no spec is defined other object types.
if isa(dat.Target,'line')
  dat.DataIndex = get(hdc,'DataIndex');
  dat.InterpolationFactor = get(hdc,'InterpolationFactor');
end


