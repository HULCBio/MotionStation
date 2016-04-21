function updateplot(ds)
%UPDATEPLOT Update plotting of data set

%   $Revision: 1.1.6.7 $  $Date: 2004/01/24 09:32:39 $
%   Copyright 2003-2004 The MathWorks, Inc.

dffig = dfgetset('dffig');
ax = get(dffig,'CurrentAxes');

% Make sure we can plot into the current display
if dfswitchyard('dfcanplotdata',ds)
   ds.plotok = 1;
else
   ds.plot = 0;
   ds.plotok = 0;
end

if ds.plot
    haveline = (~isempty(ds.line)) && ishandle(ds.line);
    havebounds = ~isempty(ds.boundline) && ishandle(ds.boundline);
    needbounds = ds.showbounds>0;
    if (~haveline) || (needbounds ~= havebounds)
        [c,m,l,w] = dfswitchyard('statgetcolor',ax,'data',ds);
        ds.ColorMarkerLine = {c m l w};

        if isequal(ds.ftype, 'probplot')
           if ~isempty(ds.line) && ishandle(ds.line)
              delete(ds.line);
           end
           ds.line = probplot(ax, ds.y, ds.censored, ds.frequency, 'noref');
           set(ds.line,'Color',c,'Marker',m);
           ds.plotx = get(ds.line, 'XData');
           ds.ploty = get(ds.line, 'YData');
           ds.plotbnds = [];
           ybounds = [];
        else
           % Compute data for plot
           if ds.showbounds
              [plotx,ploty,ybounds] = getplotdata(ds);
           else
              [plotx,ploty] = getplotdata(ds);
           end
           ds.plotx = plotx;
           ds.ploty = ploty;
           
           if isempty(ds.line) || ~ishandle(ds.line)
              ds.line = line(plotx,ploty,'Parent',ax,...
                     'marker','none','linestyle',l,'color',c,...
                     'LineWidth',w);
           else
              set(ds.line, 'XData',plotx, 'YData',ploty);
           end
           if isequal(m,'.')
              set(ds.line, 'MarkerSize',12);
           end
        end
        hTipFcn = dfittool('gettipfcn');
        set(ds.line,'ButtonDownFcn',hTipFcn,...
                    'UserData',ds,'Tag','dfdata');
        savelineproperties(ds);
        
        % Give it a context menu
        if isempty(get(ds.line,'uiContextMenu'))
           ctxt = findall(get(ax,'Parent'),'Type','uicontextmenu',...
                          'Tag','datacontext');
           set(ds.line,'uiContextMenu',ctxt);
        end

        % Add bounds if requested
        if ~isempty(ds.boundline) && ishandle(ds.boundline)
           delete(ds.boundline);
        end
        if ds.showbounds && ~isempty(ybounds)
           ds.boundline = line([plotx(:); NaN; plotx],...
                               [ybounds(:,1); NaN; ybounds(:,2)],...
                               'Parent',ax,'ButtonDownFcn',hTipFcn,...
                               'marker','none','linestyle',':','color',c,...
                               'LineWidth',w,'Tag','dfdbounds','UserData',ds);
        else
           ds.boundline = [];
        end
        
        updatelim(ds);
    end
else
    if (~isempty(ds.line)) && ishandle(ds.line)
        savelineproperties(ds);
        set(ax,'XLimMode','manual');
        delete(ds.line);
        ds.line=[];
        delete(ds.boundline);
        ds.boundline = [];
        zoom(dffig,'reset');
        
        % Update axis limits
        if ~isempty(ds.x)
           dfittool('defaultaxes');
        end
    end
end

% See if our ability to plot positive distributions has changed
dfswitchyard('dfupdateppdists', dffig);

dfswitchyard('dfupdatelegend', dfgetset('dffig'));
