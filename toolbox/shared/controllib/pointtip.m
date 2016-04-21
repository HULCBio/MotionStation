function tip = pointtip(POINT, varargin)
%POINTTIP  Creates a data tip locked to a given point.
%
%   h = POINTTIP(POINT,'PropertyName1',value1,'PropertyName2,'value2,...) 
%   will attach a data tip to the point POINT (single-point HG line).

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:20:07 $

% Create linetip
try
    tip = graphics.datatip(POINT);
catch
    error('Linetip can only be a child of a line object.')
    return
end
% Set Properties
set(tip,'Visible','on',varargin{:});
tip.ZStackMinimum = 10;
tip.EnableZStacking = true;
tip.EnableAxesStacking = true;
tip.movetofront;
if ~max(strcmpi(varargin,'X')) | isempty(varargin)
    curr = get(get(POINT,'Parent'),'CurrentPoint');
    oldpos = tip.Position;
    tip.Position = [curr(1,1),oldpos(2),oldpos(3)];    
end

if ~max(strcmpi(varargin,'Y')) | isempty(varargin)
    curr = get(get(POINT,'Parent'),'CurrentPoint');
    oldpos = tip.Position;
    tip.Position = [oldpos(1),curr(1,2),oldpos(3)];
end

%% Build uicontextmenu handle for marker text
ax = get(POINT,'Parent');
tip.UIContextMenu = uicontextmenu('Parent',get(ax,'Parent'));
%% Add the default menu items
ltitipmenus(tip,'alignment','fontsize','delete');
