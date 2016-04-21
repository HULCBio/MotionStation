function [Pos]=lscan(ha,wdt,hgt,tol,stickytol,hl)
%LSCAN  Scan for good legend location.
%   LSCAN is used by LEGEND to determine a "good" place for
%   the legend to appear. LSCAN returns either the
%   position (in figure normalized units) the legend should
%   appear, or a -1 if no "good" place is found.
%
%   LSCAN searches for the best place on the graph according
%   to the following rules.
%       1. Legend must obscure as few data points as possible.
%          Number of data points the legend may cover before plot
%          is "squeezed" can be set with TOL. The default is a 
%          large number so to enable squeezing, TOL must 
%          be set. A negative TOL will force squeezing.
%       2. Regions with neighboring empty space are better.
%       3. Top and right are better than bottom and left.
%       4. If a legend already exists and has been manually placed,
%          then try to put new legend "close" to old one. 
%
%   LSCAN(HA,WDT,HGT,TOL,STICKYTOL,HL) returns a 2 element
%   position vector. WDT and HGT are the Width and Height of
%   the legend object in figure normalized units. TOL
%   and STICKYTOL are tolerances for covering up data points.
%   HL is the handle of the current legend or -1 if none exist. 
%
%   LSCAN(HA,WDT,HGT,TOL) allows up to TOL data
%   points to be covered when selecting the best
%   legend location.

%   Drea Thomas     5/7/93
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/10 23:26:13 $

% Defaults

% See if legend has been recently moved by a moveaxis

sticky=0;
if nargin==6,
    if hl>0,
        udata=get(hl,'userdata');
        if length(udata)==7,
            if udata(7)==1,
                sticky=1;
                set(hl,'units','normalized');
                clp=get(hl,'position');
            end
        end
    end
end

% Calculate tile size

% save old units
axoldunits = get(ha,'units');
set(ha,'units','normalized')
cap=get(ha,'Position');
set(ha,'units',axoldunits);

xlim=get(ha,'Xlim');
ylim=get(ha,'Ylim');
H=ylim(2)-ylim(1);
W=xlim(2)-xlim(1);

dh=.03*H;
dw=.03*W;   % Scale so legend is away from edge of plot
H=.94*H;
W=.94*W;
xlim=xlim+[dw -dw];
ylim=ylim+[dh -dh];

Hgt=hgt/cap(4)*H;
Wdt=wdt/cap(3)*W;
Thgt=H/round(-.5+H/Hgt);
Twdt=W/round(-.5+W/Wdt);

% Get data, points and text

Kids=get(ha,'children');
Xdata=[];Ydata=[];
for i=1:size(Kids),
    if strcmp(get(Kids(i),'type'),'line'),
        Xdata=[Xdata,get(Kids(i),'Xdata')];
        Ydata=[Ydata,get(Kids(i),'Ydata')];
    elseif strcmp(get(Kids(i),'type'),'text'),
        tmpunits = get(Kids(i),'units');
        set(Kids(i),'units','data')
        tmp=get(Kids(i),'Position');
        ext=get(Kids(i),'Extent');
        set(Kids(i),'units',tmpunits);
        Xdata=[Xdata,[tmp(1) tmp(1)+ext(3)]];
        Ydata=[Ydata,[tmp(2) tmp(2)+ext(4)]];
    end
end

%   Determine # of data points under each "tile"

i=1;j=1;
for yp=ylim(1):Thgt/2:(ylim(2)-Thgt),
    i=1;
    for xp=xlim(1):Twdt/2:(xlim(2)-Twdt),
       pop(j,i) = ...
           sum(sum((Xdata >= xp).*(Xdata<=xp+Twdt).*(Ydata>=yp).*(Ydata<=yp+Thgt)));    
%      line([xp xp],[ylim(1) ylim(2)]);
       i=i+1;   
    end
%      line([xlim(1) xlim(2)],[yp yp]);
    j=j+1;
end

% Cover up fewest points.

if min(min(pop)) > tol,
    Pos=-1;
    return
end

if sticky,
    xol=(clp(1)+clp(3)/2-cap(1))/cap(3); % axis rel units
    yol=(clp(2)+clp(4)/2-cap(2))/cap(4);

% See if new current position covers any data or goes out of bounds.

    dx=(wdt-clp(3))/cap(3);
    dy=(hgt-clp(4))/cap(4);
    tmp=ones(9,1)*[[clp(1)-cap(1) clp(1)+clp(3)-cap(1)]/cap(3) ...
                   [clp(2)-cap(2) clp(2)+clp(4)-cap(2)]/cap(4)];
    tmp2=tmp(1,:).*[W W H H]+[xlim(1) xlim(1) ylim(1) ylim(1)];
    oldpop= ...
sum(sum((Xdata>=tmp2(1)).*(Xdata<=tmp2(2)).*(Ydata>=tmp2(3)).*(Ydata<=tmp2(4))));
    tmp=tmp+ [ -dx/2 dx/2 -dy/2 dy/2
               -dx   0    -dy/2 dy/2
                0    dx   -dy/2 dy/2
               -dx/2 dx/2 -dy   0
               -dx/2 dx/2  0    dy
                0    dx    0    dy
                0    dx   -dy   0
               -dx   0    -dy   0
               -dx   0     0    dy] ;                  
    for k=1:9,
        if (tmp(k,:) <= 1 ).*(tmp(k,:)>=0),
            tmp2=tmp(k,:).*[W W H H]+[xlim(1) xlim(1) ylim(1) ylim(1)];
            clpop= ...
sum(sum((Xdata>=tmp2(1)).*(Xdata<=tmp2(2)).*(Ydata>=tmp2(3)).*(Ydata<=tmp2(4))));
            if clpop <= oldpop*(1+stickytol),
                Pos=tmp(k,[1 3]).*cap(3:4)+cap(1:2);
                return
            end
        end
end
% Otherwise, put it in the closest fitting tile with < tol data points in it
    j=fix(W/Twdt*2*xol)+1;
    i=fix(H/Thgt*2*yol)+1;
    [tmp,tmp2]=size(pop);
    if j>tmp2, j=tmp2; end
    if j<0,    j=0; end
    if i>tmp,  i=tmp; end
    if i<0,    i=0; end  
    if pop(i,j)<=tol,
Pos=[((j-1)/(2*W/Twdt/.94)+.03)*cap(3)+cap(1),((i-1)/(2*H/Thgt/.94)+.03)*cap(4)+cap(2)];
        return
    end
end

popmin = pop == min(min(pop));
if sum(sum(popmin))>1,     % Multiple minima in # of points

    [a,b]=size(pop);
    if min(a,b)>1,

% Look at adjacent tiles and see if they are empty

    pop=[pop(2,:)',pop(1:(a-1),:)']'+[pop(2:(a),:)',pop((a-1),:)']'+...
         [pop(:,2),pop(:,1:(b-1))]+[pop(:,2:b),pop(:,(b-1))];
    pop=[pop(2,:)',pop(1:(a-1),:)']'+[pop(2:(a),:)',pop((a-1),:)']'+...
         [pop(:,2),pop(:,1:(b-1))]+[pop(:,2:b),pop(:,(b-1))];
    popx=popmin.*(pop==min(pop(popmin)));

        if sum(sum(popx))>1,
            flag=1;i=a;j=b;
                while flag,
                    if flag == 2,
                        if popx(i,j) == 1,
                            popx=popx*0;popx(i,j)=1;
                            flag = 0;
                        else,
                            popx=popx*0;popx(i,j+1)=1;
                            flag = 0;
                        end
                    
                    else
                        if popx(i,j)==1,
                            flag = 2;
                            popx=popx*0;popx(i,j)=1;
                        else,
                            i=i-1;
                            if i==0,
                                i=a;j=j-1;
                            end
                        end
                    end
                end
        end
    else,
        popx=popmin*0;popx(1,1)=1;
    end
else,   % Only 1 minima in # covered points
    popx=popmin;
end

   i=find(max(popx));i=i(1);
   j=find(max(popx'));j=j(1);

Pos=[((i-1)/(W/Twdt*2/.94)+.03)*cap(3)+cap(1),((j-1)/(H/Thgt*2/.94)+.03)*cap(4)+cap(2)];





