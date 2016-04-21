function ud = setrul(fig,ud,val,RN,evenlySpaced,force_flag,plotIndex)
% SETRUL Set ruler values.
%   This is a function used by the callback of the ruler edit 
%   boxes and the ruler buttons (when one of the measurable parameters
%   has been changed, i.e. x1 or x2 in the vertical case).
%   Inputs:
%     fig - figure handle of ruler object
%     ud - userdata structure
%     val - value of ruler input
%     RN - Ruler Number (1 or 2)
%     evenlySpaced - if 1 assumes xdata of focusline is evenly spaced
%         Default = 0.
%     force_flag - if 1, this will force an update even
%         when val is the same as the current value of ud.ruler.value.
%         Default = 0.
%     plotIndex - index, into list of possible subplots, indicating
%         mainaxes (where rulers are focused).
%     NOTE: if ud.ruler.lines(4) (or ..lines(5)) is visible, then peaks
%     (or valleys) is enabled and ruler value is snapped to the nearest
%     peak (or valley).
%   Outputs:
%     ud - userdata with changed values
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    if nargin<5
        evenlySpaced = 0;
    end
    if nargin<6
        force_flag = 0;
    end
    if nargin<7
       plotIndex = 1;
    end
       
    if ud.ruler.type(1) == 'h'  % horizontal
        y = val;
        if RN == 1
            y1 = y; y2 = ud.ruler.value.y2;
            if ~force_flag
                if y1 == ud.ruler.value.y1
                   return
                end
            end
        else
            y1 = ud.ruler.value.y1; y2 = y;
            if ~force_flag
                if y2 == ud.ruler.value.y2
                   return
                end
            end
        end
        dy = y2-y1;
        setrulhorz(y,ud.ruler.lines(RN),ud.ruler.hand.boxes(RN));
        set(ud.ruler.hand.dytext,'string',num2str(dy))
        ud.ruler.value.y1 = y1;
        ud.ruler.value.y2 = y2;
        ud.ruler.value.dy = dy;
        ylim = get(ud.mainaxes,'ylim');
        if y<ylim(1) | y>ylim(2)
            set(ud.ruler.hand.buttons(RN),'visible','on')
        else
            set(ud.ruler.hand.buttons(RN),'visible','off')
        end

    else   % not horizontal
        x = val;
        if ud.ruler.type(1) == 'v'    % vertical
            if ~force_flag
                if RN == 1
                    if x == ud.ruler.value.x1
                       return
                    end
                else
                    if x == ud.ruler.value.x2
                       return
                    end
                end
            end
            setrulvert(x,ud.ruler.lines(RN),ud.ruler.hand.boxes(RN) );
            xlim = get(ud.mainaxes,'xlim');
            if (x>=xlim(1))&(x<=xlim(2))
                set(ud.ruler.hand.buttons(RN),'visible','off')
            else
                set(ud.ruler.hand.buttons(RN),'visible','on')
            end
        else   % not vertical  (track or slope)
            old_x = (RN==1)*ud.ruler.value.x1 + (RN==2)*ud.ruler.value.x2;
            [x,y] = setrulvert(x,ud.ruler.lines(RN),...
                    ud.ruler.hand.boxes(RN),...
                    ud.ruler.markers(RN),ud.focusline,...
                    old_x,evenlySpaced,force_flag,...
                    ud.ruler.lines(4),ud.ruler.lines(5));
            if ~force_flag
                if x == old_x
                   return
                end
            end
            if RN == 1
                y1 = y; y2 = ud.ruler.value.y2;
                set(ud.ruler.hand.y1text,'string',sprintf('%.8g',y1))
            else
                y1 = ud.ruler.value.y1; y2 = y;
                set(ud.ruler.hand.y2text,'string',sprintf('%.8g',y2))
            end 
            dy = y2-y1;
            ud.ruler.value.y1 = y1;
            ud.ruler.value.y2 = y2;
            ud.ruler.value.dy = dy;
            set(ud.ruler.hand.dytext,'string',sprintf('%.8g',dy))
            mainaxes = ud.mainaxes;
            xlim = get(mainaxes,'xlim');
            if (x>=xlim(1))&(x<=xlim(2))
                set(ud.ruler.hand.buttons(RN),'visible','off')
            else
                set(ud.ruler.hand.buttons(RN),'visible','on')
            end
        end
        if RN == 1
            x1 = x; x2 = ud.ruler.value.x2;
        else
            x1 = ud.ruler.value.x1; x2 = x;
        end
        dx = x2-x1;
        ud.ruler.value.x1 = x1;
        ud.ruler.value.x2 = x2;
        ud.ruler.value.dx = dx;
        set(ud.ruler.hand.dxtext,'string',sprintf('%.8g',dx))

        if ud.ruler.type(1)=='s'    % slope
           if dx ~= 0
               [xd,yd,dydx] = setslopeline(ud.mainaxes,ud.limits,...
               x1,x2,y1,y2,dx,dy,plotIndex);
               set(ud.ruler.lines(3),'xdata',xd,'ydata',yd)
               if strcmp(get(ud.ruler.lines(3),'visible'),'off')
                   set(ud.ruler.lines(3),'visible','on')
               end
           else
               dydx = NaN;
               set(ud.ruler.lines(3),'visible','off')
           end
           set(ud.ruler.hand.dydxtext,'string',sprintf('%.8g',dydx))
       end
    end

function [x,y]=setrulvert(x,lh,th,mh,fh,old_x,evenlySpaced,force_flag,pl,vl)
%SETRULVERT Set value of ruler for vertical case.
% uses gcf
%   Inputs:
%      x - value of ruler
%      lh - line handle
%      th - text handle (uicontrol, either edit or static)
%         The following inputs are given only when tracking is happening:
%      mh - marker handle (not present if no tracking)
%      fh - focus handle - line being tracked
%      old_x - previous value of x
%      evenlySpaced - boolean - 1 ==> line being tracked is evenly spaced
%      force_flag - if == 1, change objects even if old_x == x
%      pl - handle to peaks line
%      vl - handle to valleys line
%   Outputs:
%      x - updated value of x in track / slope case
%      y - updated value of y in track / slope case

    if nargin <= 3 % no tracking
        setrulxdata(lh,[x x])
        set(th,'string',sprintf('%.8g',x),'userdata',x)
    else
        xd = get(fh,'xdata');
        yd = get(fh,'ydata');
        if length(xd)<=1
            x = 0;
            if length(yd) == 1
                y = yd;
            else
                y = 0;
            end
            setrulxdata(lh,[x x])
            set(th,'string',sprintf('%.8g',x),'userdata',x)
            set(mh,'xdata',x,'ydata',y)
            return
        end
        peaksVisible = strcmp(get(pl,'visible'),'on');
        valleysVisible = strcmp(get(vl,'visible'),'on');
        if peaksVisible | valleysVisible
            if peaksVisible & ~valleysVisible
                xx = get(pl,'xdata');
            elseif valleysVisible & ~peaksVisible
               xx = get(vl,'xdata');
            else
                xx = merge(get(pl,'xdata'),get(vl,'xdata'));
            end
            [minDist,peaksInd] = min(abs(xx-x));
            x = xx(peaksInd);
        end
        if ~evenlySpaced
            [minDist,ind] = min(abs(xd-x));
        else
            t0 = xd(1);  Ts = xd(2)-xd(1);
            ind = round((x - t0)/Ts)+1;    % snap to grid
            ind = max(1,ind);
            ind = min(length(xd),ind);
        end
        x=xd(ind);
        y=yd(ind);
        if ~force_flag & (old_x == x)
            return
        end
        setrulxdata(lh,[x x])
        set(th,'string',sprintf('%.8g',x),'userdata',x)
        set(mh,'xdata',x,'ydata',y)
    end

function setrulhorz(y,lh,th)
%SETRULHORZ Set value of ruler for horizontal case.
% uses gcf
%   Inputs:
%      y - value of ruler
%      lh - line handle
%      th - text handle (uicontrol, either edit or static)

    set(lh,'ydata',[y y])
    set(th,'string',sprintf('%.8g',y),'userdata',y)
