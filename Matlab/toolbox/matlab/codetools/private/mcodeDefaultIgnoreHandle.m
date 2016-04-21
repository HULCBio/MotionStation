function [retval] = mcodeDefaultIgnoreHandle(hParent,h)

% Copyright 2003 The MathWorks, Inc.

% By default, do not ignore handle
retval = false;

hParent = handle(hParent);
h = handle(h);

% Ignore all ui components 
% ToDo: GUIDE support will require ui components
classname = class(h);
if strncmp(classname,'ui',2)
  retval = true;
  
% Ignore handle if it is an hg object with handle visibility off
elseif (isa(hParent,'hg.GObject') ...
        && strcmp(get(hParent,'HandleVisibility'),'off') ...
        && h==hParent)
    retval = true;

% Default for axes
elseif isa(hParent,'hg.axes')
    retval = localHGAxes_mcodeIgnoreChild(hParent,h);

% Ignore children of objects that subclass group or transform objects
elseif isa(hParent,'hg.hggroup') || isa(hParent,'hg.hgtransform')
    hClass = hParent.classhandle;
    hPk = get(hClass,'Package');
    if ~strcmp(get(hPk,'Name'),'hg')
       retval = ~isequal(hParent,h);
    end
end

%----------------------------------------------------------%
function [bool] = localHGAxes_mcodeIgnoreChild(hObj,hChild)
% Default implementation for axes.

bool = false;

% Ignore label objects
h(1) = get(hObj,'XLabel');
h(2) = get(hObj,'YLabel');
h(3) = get(hObj,'ZLabel');
h(4) = get(hObj,'Title');
if any(isequal(h,hObj))
  bool =  true;
end
