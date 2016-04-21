function [dat] = getCursorInfo(hThis)

% Copyright 2003 The MathWorks, Inc.

dat = [];

hDataCursorList = get(hThis,'DataCursors');

for n = 1:length(hDataCursorList)
  h = hDataCursorList(n);
  
  % Populate structure
  hTarget = handle(get(h,'Host'));
  dat(n).Target = double(hTarget);
  dat(n).Position = get(h,'Position');
  
  % For now, only populate this field for lines
  % since no spec is defined for other objects.
  if isa(hTarget,'line')
     hdc = get(h,'DataCursorHandle');
     dat(n).DataIndex = get(hdc,'DataIndex');
  end
end


