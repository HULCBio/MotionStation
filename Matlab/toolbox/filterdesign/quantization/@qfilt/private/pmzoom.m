function pmzoom(opt)
%PMZOOM Setup zoom for plotmatrix.
%   PMZOOM(AX) sets up zoom for the axes in the matrix AX.  Zooming an axis will
%   also zoom the axes in the same row and column.
%
%   PMZOOM ON turns the zoom on.
%   PMZOOM OFF turns the zoom off.
%   PMZOOM by itself toggles the state.

%   Clay Thompson
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:27:22 $

nin = nargin;
if nin==1 & ~isstr(opt),
  ax = opt; nin = nin-1;
else
  ax = findobj('Tag','PlotMatrix');
end

if nin==0, zoom, else zoom(opt), end

% If no plotmatrix just return
if isempty(ax), return, end

%ax = get(ax,'UserData');
zlabels = zeros(size(ax));
for i=1:prod(size(ax)),
  zlabels(i) = get(ax(i),'zlabel');
  ud = getappdata(zlabels(i),'ZOOMAxesData');
  if isempty(ud),
    setappdata(zlabels(i),'ZOOMAxesData',...
      [get(ax(i),'xlim') get(ax(i),'ylim');ax(i)*ones(1,4)])
  elseif isequal(size(ud),[1 4])
    setappdata(zlabels(i),'ZOOMAxesData',[ud;ax(i)*ones(1,4)])
  elseif ~isequal(size(ud),[2 4])
    Warning('Can''t setup plotmatrix zoom.')
    return
  end
end

% Set up circular lists.  ud(2,1) points to next x zoom axis, ud(2,2)
% points to next y zoom axis.
[rows,cols] = size(ax);
for i=1:rows,
  for j=1:cols-1,
    ud = getappdata(zlabels(i,j),'ZOOMAxesData');
    ud(2,2) = ax(i,j+1);
    setappdata(zlabels(i,j),'ZOOMAxesData',ud)
  end
  ud = getappdata(zlabels(i,cols),'ZOOMAxesData');
  ud(2,2) = ax(i,1);
  setappdata(zlabels(i,cols),'ZOOMAxesData',ud)
end
for j=1:cols,
  for i=1:rows-1,
    ud = getappdata(zlabels(i,j),'ZOOMAxesData');
    ud(2,1) = ax(i+1,j);
    setappdata(zlabels(i,j),'ZOOMAxesData',ud)
  end
  ud = getappdata(zlabels(rows,j),'ZOOMAxesData');
  ud(2,1) = ax(1,j);
  setappdata(zlabels(rows,j),'ZOOMAxesData',ud)
end


