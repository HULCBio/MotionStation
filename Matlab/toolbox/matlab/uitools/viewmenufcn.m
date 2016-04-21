function viewmenufcn(hfig, cmd)
%VIEWMENUFCN Implements part of the figure view menu.
%  VIEWMENUFCN(CMD) invokes view menu command CMD on figure GCBF.
%  VIEWMENUFCN(H, CMD) invokes view menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    FigureToolbar
%    CameraToolbar

%  CMD Values For Internal Use Only:
%    ViewPost

%  Copyright 1984-2003 The MathWorks, Inc.


error(nargchk(1,2,nargin))

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

% DELETE THESE OLD MENU ENTRIES FROM FIGTOOLS.M ONCE TESTED
%   '&View',               'figMenuView',            'domymenu menubar initviewmenu',
%   '>&Figure Toolbar',    'figMenuFigureToolbar',   'domymenu(''menubar'',''toggletoolbar'',gcbf)',
%   '>&Camera Toolbar',    'figMenuCameraToolbar',   'cameratoolbar toggle',

switch cmd
case 'ViewPost'
    LUpdateViewMenu(hfig);
case 'FigureToolbar'
    domymenu('menubar','toggletoolbar',hfig)
case 'CameraToolbar'
    cameratoolbar toggle
case 'PloteditToolbar'
    plotedit({'plotedittoolbar',hfig,'toggle'})
case 'FigurePalette'
    figurepalette (hfig, 'toggle')
case 'PlotBrowser'
    plotbrowser (hfig, 'toggle')
case 'PropertyEditor'
    propertyeditor (hfig, 'toggle')
end

%-----------------------------------------------------------------------%
function LUpdateViewMenu(fig)

offon = {'off','on'};

viewMenuItems = allchild(findobj(allchild(fig),'flat',...
    'Type','uimenu','Tag','figMenuView'));

tagList={
    'FigureToolBar',    'figMenuFigureToolbar'
    'CameraToolBar',    'figMenuCameraToolbar'
    'PlotEditToolBar',    'figMenuPloteditToolbar'
};
plottoolsTagList={
    'figurepalette',    'figMenuFigurePalette'
    'plotbrowser',      'figMenuPlotBrowser'
    'propertyeditor',   'figMenuPropertyEditor'
};

toolbarHandles=findall(fig,'type','uitoolbar');

for i=1:size(tagList,1)
    toolbarShowing = ~isempty(findall(toolbarHandles,...
        'tag',tagList{i,1},...
        'Visible','on'));
    menuHandle = findall(viewMenuItems,...
        'Type','uimenu',...
        'Tag',tagList{i,2});
    if ~isempty(menuHandle)
        set(menuHandle,...
            'Checked',offon{toolbarShowing+1});
    end    
end

for i=1:size(plottoolsTagList,1)
    menuHandle = findall(viewMenuItems,...
        'Type','uimenu',...
        'Tag',plottoolsTagList{i,2});
    if ~isempty(menuHandle)
        if ~isempty (get (fig, 'JavaFrame'))
            if isprop (fig, plottoolsTagList{i,1})
                comp = get (handle(fig), plottoolsTagList{i,1});
                compShowing = (comp.isVisible == 1);
            else
                compShowing = false;
            end
            set(menuHandle,...
                'Checked',offon{compShowing+1});
        else
            set (menuHandle, 'Enable', 'off');
        end
    end    
end
     

