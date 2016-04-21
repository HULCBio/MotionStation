function cfmplot(hSrc,event,ds)
%CFMPLOT Create plot for curve fitting gui

%   $Revision: 1.14.2.4 $  $Date: 2004/02/01 21:39:57 $
%   Copyright 2001-2004 The MathWorks, Inc.


% Re-create figure if it does not exist
cffig = cftool('makefigure');

ax = findall(cffig,'Type','axes','Tag','main');

if ds.plot
    if isempty(ds.line) || ~ishandle(ds.line)
        if isequal(size(ds.x(:)), size(ds.y(:)))
           x = ds.x;
           y = ds.y;
        else
           x = [];
           y = [];
        end
        set(ax,'XLimMode','manual');
        set(ax,'YLimMode','manual');
        [c,m,l,w] = cfswitchyard('cfgetcolor',ax,'data',ds);
        ds.line=line('XData',x, 'YData',y, 'Parent',ax,'ButtonDownFcn',@cftips,...
                     'marker',m,'linestyle',l,'color',c,...
                     'LineWidth',w,'tag','cfdata','UserData',ds);
        
        if isequal(m,'.')
           set(ds.line, 'MarkerSize',12);
        end
        savelineproperties(ds);

        % Give it a context menu
        c = findall(get(ax,'Parent'),'Type','uicontextmenu',...
                    'Tag','datacontext');
        if ~isempty(c)
           set(ds.line,'uiContextMenu',c);
        end

        if ~isempty(ds.x)
           cfupdatexlim([min(ds.x) max(ds.x)]);
           cfupdateylim;
        end
        cfupdatelegend(cffig);
    end
else
    if (~isempty(ds.line)) && ishandle(ds.line)
        savelineproperties(ds);
        set(ax,'XLimMode','manual');
        set(ax,'YLimMode','manual');
        delete(ds.line);
        ds.line=[];
        zoom(cffig,'reset');
        
        % Update axis limits
        if ~isempty(ds.x)
           cfupdatexlim;
           cfupdateylim;
        end

        cfupdatelegend(cffig);
    end
end
