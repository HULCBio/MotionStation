function [imsource, dsname, dL, dH, rL, rH, dLLE, dHLE, rLLE, rHLE, excludevector, X, Y, W] = cfmakeexcludepreview(outlier, dataset, width, height)
% For use by CFTOOL

%   $Revision: 1.2.2.3 $
%   Copyright 2001-2004 The MathWorks, Inc.

if nargin < 4
    width = 250;
    height = 250;
end

o = handle(outlier);

dL = o.domainLow;
dH = o.domainHigh;
rL = o.rangeLow;
rH = o.rangeHigh;
dLLE = o.domainLowLessEqual;
dHLE = o.domainHighLessEqual;
rLLE = o.rangeLowLessEqual;
rHLE = o.rangeHighLessEqual;
            
previewwithdata = true;
if isempty(dataset)  % coming from view outlier
    dsname = o.dataset;
    if isequal(dsname, 'none')
        previewwithdata = false;
    else
        ds = find(getdsdb,'name',dsname);  
        if isempty(ds)  % can't find dataset - should never happen
            previewwithdata = false;
        end
    end
else  % coming from view dataset
    ds = handle(dataset);
    dsname = ds.name;
end
            
if previewwithdata
    tag=['helper figure for ' mfilename];

    tempfigure=figure('units','pixels','position',[0 0 width height], ...
          'handlevisibility','off', ...
          'integerhandle','off', ...
          'visible','off', ...
          'paperpositionmode', 'auto', ...
          'color','w', ...
          'tag',tag);

    x = real(ds.x);
    y = real(ds.y);


    xlo = o.domainLow;
    if isempty(xlo)
    	xlo = -Inf;
    else
    	xlo = str2double(xlo);
    end

    xhi = o.domainHigh;
    if isempty(xhi)
    	xhi = Inf;
    else
    	xhi = str2double(xhi);
    end

    ylo = o.rangeLow;
    if isempty(ylo)
    	ylo = -Inf;
    else
    	ylo = str2double(ylo);
    end

    yhi = o.rangeHigh;
    if isempty(yhi)
    	yhi = Inf;
    else
    	yhi = str2double(yhi);
    end

    xlotest = o.domainLowLessEqual;
    xhitest = o.domainHighLessEqual;
    ylotest = o.rangeLowLessEqual;
    yhitest = o.rangeLowLessEqual;

    excl = o.exclude;
    if isempty(excl)
        temp = zeros(length(x),1);
        excl = logical(temp);
    else
        excl = excl(:);
        excl = logical(excl);
    end

    xlim = [min(x) max(x)];
    xlim = xlim + .05 * [-1 1] * diff(xlim);
    ylim = [min(y) max(y)];
    ylim = ylim + .05 * [-1 1] * diff(ylim);
    if xlim(1)==xlim(2)
       xlim = xlim(1) + [-1 1] * max(1,eps(xlim(1)));
    end
    if ylim(1)==ylim(2)
       ylim = ylim(1) + [-1 1] * max(1,eps(ylim(1)));
    end

    ax=axes('position',[.05 .05 .9 .9], ...
          'parent',tempfigure, ...
          'xtick',[],'ytick',[], ...
          'box','on', ...
          'visible','off', 'XLim',xlim,'YLim',ylim);

    if xlotest==1
       inbounds = x>=xlo;
    else
       inbounds = x>xlo;
    end
    if xhitest==1
       inbounds = inbounds & x<=xhi;
    else
       inbounds = inbounds & x<xhi;
    end
    if ylotest==1
       inbounds = inbounds & y>=ylo;
    else
       inbounds = inbounds & y>ylo;
    end
    if yhitest==1
       inbounds = inbounds & y<=yhi;
    else
       inbounds = inbounds & y<yhi;
    end

    figcolor = get(0,'defaultuicontrolbackgroundcolor');

    t = inbounds & ~excl;
    l1 = line('XData',x(t),'YData',y(t),...
              'Color','b','Marker','.','LineStyle','none',...
              'Parent',ax);
    t = inbounds & excl;
    l2 = line('XData',x(t),'YData',y(t),...
              'Color','r','Marker','x','LineStyle','none',...
              'Parent',ax);
    t = ~inbounds & ~excl;
    l3 = line('XData',x(t),'YData',y(t),...
              'Color',figcolor/2,'Marker','.','LineStyle','none',...
              'Parent',ax);
    t = ~inbounds & excl;
    l4 = line('XData',x(t),'YData',y(t),...
              'Color',figcolor/2,'Marker','x','LineStyle','none',...
              'Parent',ax);
    alllines = [l1 l2 l3 l4];

    gr = [.9 .9 .9];

    % Create patches to show the area outside the domain and range

    allpatches = [];
    if (xlo ~= -Inf)
        xlo = max(xlo,xlim(1));
        xp = [xlim(1) xlo xlo xlim(1)];
        yp = [ylim(1) ylim(1) ylim(2) ylim(2)];
        p1=patch(xp,yp,gr,'LineStyle','none','Parent',ax);
        allpatches(end+1)= p1;
    end

    if (xhi ~= Inf)
        xhi = min(xhi,xlim(2));
        xp = [xlim(2) xhi xhi xlim(2)];
        yp = [ylim(1) ylim(1) ylim(2) ylim(2)];
        p2=patch(xp,yp,gr,'LineStyle','none','Parent',ax);
        allpatches(end+1)= p2;
    end

    if (ylo ~= -Inf)
        ylo = max(ylo,ylim(1));
        xp = [xlim(1) xlim(1) xlim(2) xlim(2)];
        yp = [ylim(1) ylo ylo ylim(1)];
        p3=patch(xp,yp,gr,'LineStyle','none','Parent',ax);
        allpatches(end+1)= p3;
    end

    if (yhi ~= Inf)
        yhi = min(yhi,ylim(2));
        xp = [xlim(1) xlim(1) xlim(2) xlim(2)];
        yp = [ylim(2) yhi yhi ylim(2)];
        p4=patch(xp,yp,gr,'LineStyle','none','Parent',ax);
        allpatches(end+1)= p4;
    end

    set(ax,'Child',[alllines allpatches]);

    x=hardcopy(tempfigure,'-dzbuffer','-r0');
    % give the image a black edge
    x(1,:,:)=0; x(end,:,:)=0; x(:,1,:)=0; x(:,end,:)=0;
    imsource=im2mis(x);
    delete(tempfigure);
    excludevector = cfcreateexcludevector(ds, outlier);
    [X, Y, W] = cfviewdata(ds);
else
    imsource = cfsectionpreview(outlier, width, height);
    excludevector = [];
    X = [];
    Y = [];
    W = [];
end