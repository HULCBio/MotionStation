function setrulxdata(h,xdata)
%SETRULXDATA Checks to see if ruler lines are on top of each other.
%   If they are, sets thickness of line 1 to 3, otherwise sets
%   thickness of line 1 to the default.
%   If markers are visible, sets marker size of line 1 to twice that
%   of marker size of line 2.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    ax = get(h,'parent');
    fig = get(ax,'parent');
    
    ud = get(fig,'userdata');
    R = find(h==ud.ruler.lines(1:2));
    R1 = 1 + (R==1);
    
    xdata1 = get(ud.ruler.lines(R1),'xdata');
    
    if xdata1(1) ~= xdata(1)
        set(ud.ruler.lines(1),'linewidth',get(ud.ruler.lines(2),'linewidth'))
        set(ud.ruler.markers(1),'markersize',...
                    get(ud.ruler.markers(2),'markersize'))
    else
        set(ud.ruler.lines(1),'linewidth',3)
        set(ud.ruler.markers(1),'markersize',...
                    1.5*get(ud.ruler.markers(2),'markersize'))
    end
    set(ud.ruler.lines(R),'xdata',xdata)