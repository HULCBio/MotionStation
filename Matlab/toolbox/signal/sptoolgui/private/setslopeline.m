function [xd,yd,dydx] = setslopeline(mainaxes,limits,x1,x2,y1,y2,dx,dy,plotIndex)
% SETSLOPELINE Set ruler slope line
%   This is a function called by ruler.m and private/setrul.m
%   Inputs:
%     mainaxes - axes where the rulers are
%     limits - list of XY limits for all the subplots
%     x1 - x value of ruler 1
%     x2 - x value of ruler 2
%     y1 - y value of ruler 1
%     y2 - y value of ruler 2
%     dx - x2-x1
%     dy - y2-y1
%     plotIndex - index, into list of possible subplots, indicating
%         mainaxes (where rulers are focused).
%   Outputs:
%     xd - x data for ruler slope line
%     yd - y data for ruler slope line
%     dydx - slope of the ruler slope line

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    xl = get(mainaxes,'xlim');
    yl = get(mainaxes,'ylim');
    
    if strcmp(get(mainaxes,'yscale'),'log')
        if (y1 == 0), y1 = eps*y2; end
        y1 = log10(y1);
        y2 = log10(y2);
        yl = log10(yl);
        dy = y2-y1;
    end
    if strcmp(get(mainaxes,'xscale'),'log')
        if (x1 == 0), x1 = eps*x2; end
        x1 = log10(x1);
        x2 = log10(x2);
        xl = log10(xl);
        dx = x2-x1;
    end
    
    if dy == 0
        dydx = 0;
        xd = xl;
        yd = [y1 y2];
    else
        dydx = dy/dx;
        f = [dydx (y1-dydx*x1)];  % forward line equation
        fi = [1 -(y1-dydx*x1)]./dydx;  % inverse line equation
        p = [polyval(fi,yl(1)) yl(1)  
            xl(1) polyval(f,xl(1))  
            xl(2) polyval(f,xl(2))   
            polyval(fi,yl(2)) yl(2)];
        ind = find(pinrect(p,[xl yl]));
        xd = p(ind,1);
        yd = p(ind,2);
    end
    if strcmp(get(mainaxes,'yscale'),'log')
        dy = y2-y1;
        yd = 10.^(yd);
    end
    if strcmp(get(mainaxes,'xscale'),'log')
        xd = 10.^(xd);
    end
    
