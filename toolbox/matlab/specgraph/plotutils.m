function plotutils(str,h,code)
%PLOTUTILS Helper function for plot objects
%  PLOTUTILS('makemcode',H,HCODE) adds common code-generation
%  fragments to HCODE for graphics object H. Do not directly
%  call this function outside of code generation or plot
%  object management.
%  
%  See also MAKEMCODE

%  PLOTUTILS('BeginAxesUpdate',AX) turns off legend, colorbar,
%  and subplot layout listeners for axes AX. Nesting of update 
%  blocks is not supported.
%  PLOTUTILS('EndAxesUpdate',AX) turns on legend, colorbar,
%  and subplot layout listeners. 

%   Copyright 1984-2004 The MathWorks, Inc. 

% check for BeginAxesUpdate or EndAxesUpdate
% since this gets called often code for performance
isBeginUpdate = str(1) == 'B';
if isBeginUpdate || (str(1) == 'E')
  if isempty(h) || ~ishandle(h), return; end
  p = get(h,'Parent');
  if ~ishandle(p), return; end
  if strcmp(get(p,'BeingDeleted'),'on'), return; end
  list = [];

  % Get subplot listeners, if any
  grid = getappdata(p,'SubplotGrid');
  if ~isempty(grid),
    test = double(h) == double(grid);
    if any(test(:))
      list = getappdata(p,'SubplotListeners');
    end
  end

  % Get legend listeners, if any
  if isprop(h,'LegendColorbarListeners')
    if isempty(list)
      list = get(h,'LegendColorbarListeners');
    else
      list2 = get(h,'LegendColorbarListeners');
      list = [list(:) ; list2(:)];
    end
  end

  if ~isempty(list)
    if isBeginUpdate
      set(list,'enable','off');
    else
      set(list,'enable','on');
      invalidateaxis(h);
    end
  end

% must be makemcode
else
  % process Parent - assume if there is only 1 axes that it should be
  % implicit
  fig = ancestor(h,'figure');
  ax = findobj(fig,'type','axes');
  if length(ax) == 1
    ignoreProperty(code,'Parent')
  end
end
