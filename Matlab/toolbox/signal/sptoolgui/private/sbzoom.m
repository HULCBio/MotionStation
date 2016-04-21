function sbzoom(action)
%SBZOOM  Signal Browser zoom function.
%  Contains callbacks for Zoom button group of Signal Browser.
%    mousezoom
%    zoomout
%    zoominx
%    zoomoutx
%    zoominy
%    zoomouty
 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2002/04/15 00:01:25 $

fig = gcbf;
ud = get(fig,'userdata');

if ud.pointer==2   % help mode
    if strcmp(action,'mousezoom')
        state = strcmp(get(ud.toolbar.mousezoom,'state'),'on');
        % toggle button state back to the way it was:
        if state
              set(ud.toolbar.mousezoom,'state','off')
        else
              set(ud.toolbar.mousezoom,'state','on')
        end
    end
    spthelp('exit','sbzoom',action)
    return
end

switch action

case 'mousezoom'
    state = strcmp(get(ud.toolbar.mousezoom,'state'),'on');
    if state == 1   % button is currently down
        set(fig,'windowbuttondownfcn','sbswitch(''sbzoom'',''mousedown'')')
        ud.pointer = 1;  
        set(fig,'userdata',ud)
        set(ud.mainaxes,'uicontextmenu',[])
        setptr(fig,'arrow')
    else   % button is currently up - turn off zoom mode
        set(fig,'windowbuttondownfcn','')
        ud.pointer = 0;  
        set(fig,'userdata',ud)
        set(ud.mainaxes,'uicontextmenu',ud.contextMenu.u)
        setptr(fig,'arrow')
    end

case 'zoomout'
    if ud.prefs.tool.panner
        panner('zoom',ud.limits.xlim,ud.limits.ylim)
    end
    set(ud.mainaxes,'xlim',ud.limits.xlim,'ylim',ud.limits.ylim)
    if ud.prefs.tool.ruler
        ruler('newlimits')
    end

case 'zoominx'
    xlim = get(ud.mainaxes,'xlim');
    newxlim = .25*[3 1]*xlim' + [0 diff(xlim)/2];
 %   if diff(newxlim) > ud.Ts/10;
       if ud.prefs.tool.panner
           panner('zoom',newxlim,get(ud.mainaxes,'ylim'))
       end
       set(ud.mainaxes,'xlim',newxlim)
       if ud.prefs.tool.ruler
           ruler('newlimits')
       end
  %  end

case 'zoomoutx'
    xlim = get(ud.mainaxes,'xlim');
    xlim = .5*[3 -1]*xlim' + [0 diff(xlim)*2];
    xlim = [max(xlim(1),ud.limits.xlim(1)) min(xlim(2),ud.limits.xlim(2))];
    if ud.prefs.tool.panner
        panner('zoom',xlim,get(ud.mainaxes,'ylim'))
    end
    set(ud.mainaxes,'xlim',xlim)
    if ud.prefs.tool.ruler
        ruler('newlimits')
    end

case 'zoominy'
    ylim = get(ud.mainaxes,'ylim');
    newylim = .25*[3 1]*ylim' + [0 diff(ylim)/2];
    if diff(newylim) > 0;
       if ud.prefs.tool.panner
           panner('zoom',get(ud.mainaxes,'xlim'),newylim)
       end
       set(ud.mainaxes,'ylim',newylim)
       if ud.prefs.tool.ruler
           ruler('newlimits')
       end
    end

case 'zoomouty'
    ylim = get(ud.mainaxes,'ylim');
    ylim = .5*[3 -1]*ylim' + [0 diff(ylim)*2];
    ylim = [max(ylim(1),ud.limits.ylim(1)) min(ylim(2),ud.limits.ylim(2))];
    if ud.prefs.tool.panner
        panner('zoom',get(ud.mainaxes,'xlim'),ylim)
    end
    set(ud.mainaxes,'ylim',ylim)
    if ud.prefs.tool.ruler
        ruler('newlimits')
    end

%-------------- these are self callbacks:
case 'mousedown'
    ud.justzoom = get(fig,'currentpoint'); 
    set(fig,'userdata',ud)

    pstart = get(fig,'currentpoint');

    % don't do anything if click is outside mainaxes_port
    fp = get(fig,'position');   % in pixels already
    sz = ud.sz;
    toolbar_ht = 0; %sz.ih;
    left_width = 0;
    panner_port = [left_width 0 fp(3)-(left_width+sz.rw*ud.prefs.tool.ruler) ...
                    sz.ph*ud.prefs.tool.panner];
    mp = [left_width panner_port(4) ...
                     fp(3)-(left_width+sz.rw*ud.prefs.tool.ruler) ...
                     fp(4)-(toolbar_ht+panner_port(4))];
    %click is outside of main panel:
    if ~pinrect(pstart,[mp(1) mp(1)+mp(3) mp(2) mp(2)+mp(4)])
        return
    end

    r=rbbox([pstart 0 0],pstart);

    oldxlim = get(ud.mainaxes,'xlim');
    oldylim = get(ud.mainaxes,'ylim');

    if all(r([3 4])==0)
        % just a click - zoom about that point
        p1 = get(ud.mainaxes,'currentpoint');

        switch get(fig,'selectiontype')
        case 'normal'     % zoom in
            xlim = p1(1,1) + [-.25 .25]*diff(oldxlim);
            ylim = p1(1,2) + [-.25 .25]*diff(oldylim);
        otherwise    % zoom out
            xlim = p1(1,1) + [-1 1]*diff(oldxlim);
            ylim = p1(1,2) + [-1 1]*diff(oldylim);
        end

    elseif any(r([3 4])==0)  
        % zero width or height - stay in zoom mode and 
        % try again
        return

    else 
        % zoom to the rectangle dragged
        set(fig,'currentpoint',[r(1) r(2)])
        p1 = get(ud.mainaxes,'currentpoint');
        set(fig,'currentpoint',[r(1)+r(3) r(2)+r(4)])
        p2 = get(ud.mainaxes,'currentpoint');
        
        xlim = [p1(1,1) p2(1,1)];
        ylim = [p1(1,2) p2(1,2)];
    end
    newxlim = inbounds(xlim,ud.limits.xlim);
    newylim = inbounds(ylim,ud.limits.ylim);
    if diff(newxlim) > 1e-30
       if ud.prefs.tool.panner
           panner('zoom',newxlim,oldylim)
       end
       set(ud.mainaxes,'xlim',newxlim)
    else
       newxlim = oldxlim;
    end
    if diff(newylim) > 0
       if ud.prefs.tool.panner
           panner('zoom',newxlim,newylim)
       end
       set(ud.mainaxes,'ylim',newylim)
    end
    if ud.prefs.tool.ruler
        ruler('newlimits')
    end
    if ~ud.prefs.tool.zoompersist
    % LEAVE ZOOM MODE
        setptr(fig,'arrow')
        set(fig,'windowbuttondownfcn','')
        %btnup(fig,'zoomgroup',1);
        set(ud.toolbar.mousezoom,'state','off')
        set(ud.mainaxes,'uicontextmenu',ud.contextMenu.u)
        ud.pointer = 0;  
    end
    set(fig,'userdata',ud)
    set(fig,'currentpoint',ud.justzoom)

end

