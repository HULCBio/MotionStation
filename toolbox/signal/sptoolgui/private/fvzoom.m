function fvzoom(action,varargin)
%FVZOOM  Filter Viewer zoom function.
%  Contains callbacks for Zoom button group of Filter Viewer.
%    mousezoom
%    zoomout

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2002/04/15 00:02:49 $

if nargin < 3
    fig = gcbf;
else
    fig = varargin{2};
end
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
    if strcmp(action,'zoomout') & nargin>1
        action = 'zoomoutall';
    end
    spthelp('exit','fvzoom',action)
    return
end

switch action

case 'mousezoom'
    state = strcmp(get(ud.toolbar.mousezoom,'state'),'on');
    if state == 1   % button is currently down
        set(fig,'windowbuttondownfcn','sbswitch(''fvzoom'',''mousedown'')')
        ud.pointer = 1;  
        set(fig,'userdata',ud)
        setptr(fig,'arrow')
        set(ud.ht.a,'uicontextmenu',[])
    else   % button is currently up - turn off zoom mode
        set(fig,'windowbuttondownfcn','')
        ud.pointer = 0;
        set(fig,'userdata',ud)
        setptr(fig,'arrow')
        set(ud.ht.a,'uicontextmenu',ud.contextMenu.u)
    end

%--------
%  call will be either
%     fvzoom('zoomout')   - "Full View" button callback - zooms out main axes
%     fvzoom('zoomout','all') - "Full View (ALL)" button callback - zooms out all axes
%     fvzoom('zoomout',plots) - plots is a 6 element binary vector, containing
%                               a '1' in each location for which to zoom out
%           1 - magnitude
%           2 - phase
%           3 - group delay
%           4 - zeros & poles
%           5 - impulse response
%           6 - step response
%     fvzoom('zoomout',plots,fig) - same as above except with input figure

case 'zoomout'
    if nargin > 1
        if isstr(varargin{1})
            plots = ones(size(ud.ht.a));
        else
            plots = varargin{1};
        end
    else
        plots = (ud.ht.a == ud.mainaxes);
    end
    if nargin > 2
        fig = varargin{2};
    end
    Fs = evalin('base',ud.prefs.Fs,'1');

    if strcmp(ud.prefs.freqscale,'log')
        xlim1 = Fs/ud.prefs.nfft;
    else
        xlim1 = 0;
    end

    switch ud.prefs.freqrange
    case 1
       xlim = [xlim1 Fs/2];
    case 2
       xlim = [xlim1 Fs];
    case 3
       xlim = [-Fs/2 Fs/2];
    end

    plotIndex = find(ud.mainaxes == ud.ht.a);    
    if ud.prefs.tool.ruler & plots(plotIndex)
        % don't allow rulers to affect maximum axes limits computations
        ruler('hidelines',fig,'all')
    end

    for i=1:2
        if plots(i)
            set(ud.ht.a(i),'ylimmode','auto','xlim',xlim);
        end
    end

    if plots(3) & strcmp(get(ud.ht.a(3),'visible'),'on')
        gd_ylim = filtview('gd_ylim',ud.filt);
        set(ud.ht.a(3),'ylim',gd_ylim)
        set(ud.ht.a(3),'xlim',xlim)
    end
 
    if plots(4)
        set(ud.ht.a(4),'ylimmode','auto','xlimmode','auto');
        apos = get(ud.ht.a(4),'Position');
        set(ud.ht.a(4),'DataAspectRatio',[1 1 1],...
            'PlotBoxAspectRatio',apos([3 4 4]))

        if  ~isempty(ud.filt) 
            [xlim1,xlim2,ylim1,ylim2] = filtview('zeropolePlotLims',ud.filt);
            set(get(ud.ht.a(4),'xlabel'),'userdata',[xlim1 xlim2 ylim1 ylim2]);
        else
            set(get(ud.ht.a(4),'xlabel'),'userdata',[-1 1 -1 1]);
        end
    end

    if any(plots([5 6])) & ~isempty(ud.filt)
        tmax = -inf;
        for i = 1:length(ud.filt)
            if ~isempty(ud.filt(i).t)
                tmax = max([tmax; ud.filt(i).t(end)]);
            else
                tmax = max([tmax; 0]);
            end
        end
        xlim = [-1/Fs tmax+1/Fs];
    else
        xlim = [0 1/Fs];
    end
    if plots(5),set(ud.ht.a(5),'ylimmode','auto','xlim',xlim), end
    if plots(6),set(ud.ht.a(6),'ylimmode','auto','xlim',xlim), end

    visPlots = find(strcmp(get(ud.ht.a,'visible'),'on'));
    if ~isempty(visPlots)
       ud = filtview('setudlimits',ud,ud.ht.a,visPlots);
       set(fig,'userdata',ud)
    end

    if ud.prefs.tool.ruler & plots(plotIndex)
        ruler('showlines',fig,ud.focusline)
        ruler('newlimits',fig,plotIndex)
    end

case 'zoominx'
    xlim = get(ud.mainaxes,'xlim');
    newxlim = .25*[3 1]*xlim' + [0 diff(xlim)/2];
    ylim = get(ud.mainaxes,'ylim');
    plots = (ud.mainaxes==ud.ht.a);
    plotInd = find(plots);
    if plotInd == 4  % zeros and poles
        % need to zoom other limit too to keep aspect ratio the same
        newylim = .25*[3 1]*ylim' + [0 diff(ylim)/2];
    else
        newylim = ylim;
    end
    if diff(newxlim) > 1e-13 & diff(newylim) > 1e-13
       set(ud.mainaxes,'xlim',newxlim,'ylim',newylim)
       if ud.prefs.tool.ruler
           ruler('newlimits',fig,plotInd)
       end
    end

case 'zoomoutx'
    xlim = get(ud.mainaxes,'xlim');
    xlim = .5*[3 -1]*xlim' + [0 diff(xlim)*2];
    ylim = get(ud.mainaxes,'ylim');
    plots = (ud.mainaxes==ud.ht.a);
    plotInd = find(plots);
    if plotInd == 4  % zeros and poles
        % need to zoom other limit too to keep aspect ratio the same
        ylim = .5*[3 -1]*ylim' + [0 diff(ylim)*2];
    end
    fvzoom('zoomout',plots,fig)
    ud=get(fig,'userdata');
    xlim = [max(xlim(1),ud.limits(plotInd).xlim(1)) min(xlim(2),ud.limits(plotInd).xlim(2))];
    ylim = [max(ylim(1),ud.limits(plotInd).ylim(1)) min(ylim(2),ud.limits(plotInd).ylim(2))];
    set(ud.mainaxes,'xlim',xlim,'ylim',ylim)
    if ud.prefs.tool.ruler
       ruler('newlimits',fig,plotInd)
    end

case 'zoominy'
    ylim = get(ud.mainaxes,'ylim');
    newylim = .25*[3 1]*ylim' + [0 diff(ylim)/2];
    xlim = get(ud.mainaxes,'xlim');
    plots = (ud.mainaxes==ud.ht.a);
    plotInd = find(plots);
    if plotInd == 4  % zeros and poles
       % need to zoom other limit too to keep aspect ratio the same
       newxlim = .25*[3 1]*xlim' + [0 diff(xlim)/2];
    else
       newxlim = xlim;
    end
    if diff(newylim) > 1e-13 & diff(newxlim) > 1e-13
       set(ud.mainaxes,'ylim',newylim,'xlim',newxlim)
       if ud.prefs.tool.ruler
           ruler('newlimits',fig,plotInd)
       end
    end

case 'zoomouty'
    ylim = get(ud.mainaxes,'ylim');
    ylim = .5*[3 -1]*ylim' + [0 diff(ylim)*2];
    xlim = get(ud.mainaxes,'xlim');
    plots = (ud.mainaxes==ud.ht.a);
    plotInd = find(plots);
    if plotInd == 4  % zeros and poles
        % need to zoom other limit too to keep aspect ratio the same
        xlim = .5*[3 -1]*xlim' + [0 diff(xlim)*2];
    end
    fvzoom('zoomout',plots,fig)
    ud=get(fig,'userdata');
    ylim = [max(ylim(1),ud.limits(plotInd).ylim(1)) min(ylim(2),ud.limits(plotInd).ylim(2))];
    xlim = [max(xlim(1),ud.limits(plotInd).xlim(1)) min(xlim(2),ud.limits(plotInd).xlim(2))];
    set(ud.mainaxes,'xlim',xlim,'ylim',ylim)
    if ud.prefs.tool.ruler
       ruler('newlimits',fig,plotInd)
    end

%-------------- these are self callbacks:
case 'mousedown'

    ud.justzoom = get(fig,'currentpoint');
    set(fig,'userdata',ud)
    Fs = evalin('base',ud.prefs.Fs,'1');

    pstart = get(fig,'currentpoint');

    % don't do anything if click is outside mainaxes_port
    fp = get(fig,'position');   % in pixels already
    sz = ud.sz;
    toolbar_ht = 0; %ud.resize.topheight;
    ruler_port = [ud.left_width 0 fp(3)-ud.left_width sz.rh*ud.prefs.tool.ruler];
    mp = [ud.left_width ruler_port(4) fp(3)-ud.left_width fp(4)-ruler_port(4)];
    %click is outside of main panel:
    if ~pinrect(pstart,[mp(1) mp(1)+mp(3) mp(2) mp(2)+mp(4)])
        return
    end

    r = rbbox([pstart 0 0],pstart);

    % Find out which axes was clicked in according to rules:
    % rule 1: click inside an axes - zoom in that axes
    % rule 2: current point is not in any axes - zoom in on axes most
    %         overlapping dragged rectangle
    open_axes = ud.ht.a(find(ud.prefs.plots));
    rects = [];
    target_axes = [];
    for i=1:length(open_axes)
        rects = [rects; get(open_axes(i),'position')];
        if pinrect(pstart,rects(i,[1 1 2 2])+[0 rects(i,3) 0 rects(i,4)])
            target_axes = open_axes(i);
        end
    end
    
    if isempty(open_axes)  % no visible plots
        return   % stay in zoom mode and return
    elseif isempty(target_axes)
        overlap = rectint(r,rects);
        overlap = overlap(:)...
              ./ (rects(:,3).*rects(:,4));
            % what percentage of the area of the axis is 
            %  covered by the dragged out rectangle?
        [maxoverlap,k] = max(overlap);
        if maxoverlap > 0
            target_axes = open_axes(k);
        end
    end

    if isempty(target_axes)
        return   % stay in zoom mode and return
    end
    oldxlim = get(target_axes,'xlim');
    oldylim = get(target_axes,'ylim');
    
    if all(r([3 4])==0)
        % just a click - zoom about that point
        p1 = get(target_axes,'currentpoint');

        xlim = get(target_axes,'xlim');
        ylim = get(target_axes,'ylim');

        switch get(fig,'selectiontype')
        case 'normal'     % zoom in
            xlim = p1(1,1) + [-.25 .25]*diff(xlim);
            ylim = p1(1,2) + [-.25 .25]*diff(ylim);
        otherwise    % zoom out
            % first do a full zoom out so we know 
            % the bounding rect (stored in ud.limits.xlim, .ylim)
            fvzoom('zoomout',ud.ht.a == target_axes,fig)
            ud = get(fig,'userdata');
            xlim = p1(1,1) + [-1 1]*diff(xlim);
            ylim = p1(1,2) + [-1 1]*diff(ylim);
        end
        
    elseif any(r([3 4])==0)  
        % zero width or height - stay in zoom mode and 
        % try again
        return

    else 
        % zoom to the rectangle dragged
        set(fig,'currentpoint',[r(1) r(2)])
        p1 = get(target_axes,'currentpoint');
        set(fig,'currentpoint',[r(1)+r(3) r(2)+r(4)])
        p2 = get(target_axes,'currentpoint');
        
        xlim = [p1(1,1) p2(1,1)];
        ylim = [p1(1,2) p2(1,2)];
    end

    axesIndex = find(target_axes == ud.ht.a);
    newxlim = inbounds(xlim,ud.limits(axesIndex).xlim);
    newylim = inbounds(ylim,ud.limits(axesIndex).ylim);
    
    switch target_axes
    
    case {ud.ht.a(1), ud.ht.a(2), ud.ht.a(3)}
        xdiff = Fs / (4*ud.prefs.nfft);
    case ud.ht.a(4)
        xdiff = 0;
    case {ud.ht.a(5), ud.ht.a(6)}
        xdiff = .1/Fs;
    end

    if target_axes ~= ud.ht.a(4)
        if diff(xlim) > xdiff
           set(target_axes,'xlim',newxlim)
        end
        if diff(ylim) > 0
           set(target_axes,'ylim',newylim)
        end
    else		% Pole-zero
        apos = get(target_axes,'Position');
        set(get(ud.ht.a(4),'xlabel'),'userdata',[newxlim newylim]);
        [newxlim,newylim] = newlims(apos,newxlim,newylim);
          set(target_axes,'xlim',newxlim,'ylim',newylim)
    end
    ud.limits(axesIndex).xlim = newxlim;
    ud.limits(axesIndex).ylim = newylim;
    set(fig,'userdata',ud)    
    
    if ~ud.prefs.tool.zoompersist
    % LEAVE ZOOM MODE
        setptr(fig,'arrow')
        set(fig,'windowbuttondownfcn','')
        set(ud.toolbar.mousezoom,'state','off')
        ud.pointer = 0;  
        set(fig,'userdata',ud)
        set(ud.ht.a,'uicontextmenu',ud.contextMenu.u)
    end
    if ud.prefs.tool.ruler & (ud.mainaxes == target_axes)
        ruler('newlimits',fig,find(ud.mainaxes == ud.ht.a),ud.focusline)
    end
    set(fig,'currentpoint',ud.justzoom)
end


%================================================================

function [newxlim,newylim] = newlims(apos,xlim,ylim);

dx = diff(xlim);
dy = diff(ylim);

if dx * apos(4)/apos(3) >= dy   % Snap to the requested x limits, expand y to fit
   newxlim = xlim;
   newylen = apos(4)/apos(3) * dx;
   newylim = mean(ylim) + [-newylen/2 newylen/2];
else
   newylim = ylim;
   newxlen = apos(3)/apos(4) * dy;
   newxlim = mean(xlim) + [-newxlen/2 newxlen/2];
end

if diff(newxlim) <= 0
   newxlim = xlim;
end
if diff(newylim) <= 0
   newylim = ylim;
end
