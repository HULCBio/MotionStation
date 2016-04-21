function hAxesVector = findaxes(hZoom)
%FINDAXES Find axes (one/multiple) under the current mouse position

% Copyright 2002-2003 The MathWorks, Inc.

% ToDo: This code is replicated in rotate3d.m and pan.m, centralize

hAxesVector = [];
hFigure = get(hZoom,'FigureHandle');

if ~ishandle(hFigure)
    return;
end

% Determine which axes mouse ptr hits. We can't use the 
% figure's "currentaxes" property since the current
% axes may not be under the mouse ptr.
allAxes = findobj(datachildren(hFigure),'type','axes');
orig_fig_units = get(hFigure,'units');
set(hFigure,'units','pixels');
cp = get(hFigure,'CurrentPoint');
for i=1:length(allAxes)
    candidate_ax=allAxes(i);
    
    % Check behavior support
    b = hggetbehavior(candidate_ax,'Zoom','-peek');
    doIgnore = false;
    if ~isempty(b) & ishandle(b)
       if ~get(b,'Enable')
             doIgnore = true;
       end
    end
    
    if ~doIgnore
        orig_ax_units = get(candidate_ax,'units');
        set(candidate_ax,'units','pixels')
        pos = get(candidate_ax,'position');
        set(candidate_ax,'units',orig_ax_units)
        if cp(1) >= pos(1) & cp(1) <= pos(1)+pos(3) & ...
            cp(2) >= pos(2) & cp(2) <= pos(2)+pos(4)
            hAxesVector = [candidate_ax,hAxesVector];
            
            % Only return one axes
            break;
            
        end 
    end % if
end % for

% restore state
set(hFigure,'units',orig_fig_units)






