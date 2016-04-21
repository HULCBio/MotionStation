function setpos(obj,fig)
%SETPOS Set positions of axes objects

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

ud = get(fig,'userdata');

% compute position:
%   rule is: position from top to bottom according to order in ud.Objects.fdax
%     and to which are currently visible.
%   OR if .position field is not a scalar, use it
allObj = struct(ud.Objects.fdax);
if isempty(allObj)
    return
end

a1 = [];  % list of handles for placement on grid
a1i = []; % indices
a2 = [];  % list of handles for arbitrary positioning
a2i = [];
for i=1:length(allObj)
    if strcmp(get(allObj(i).h,'visible'),'on')
        if length(get(ud.Objects.fdax(i),'position'))==1
            a1 = [a1; allObj(i).h];
            a1i = [a1i; i];
        else
            a2 = [a2; allObj(i).h];
            a2i = [a2i; i];
        end
    end
end

afp = get(ud.ht.axFrame,'position');
pos = axpos(afp,[length(a1) 1],length(a1),ud.sz.as);
for i = 1:length(a1)    
    xlim = get(a1(i),'xlim');
    ylim = get(a1(i),'ylim');
    set(a1(i),'position',pos{i})
    objud = get(a1(i),'userdata');
    if strcmp(objud.aspectmode,'equal')
        apos = pos{i};
        [newxlim,newylim] = newlims(apos,xlim,ylim);
        set(a1(i),'xlim',newxlim,'ylim',newylim,...
                'DataAspectRatio',[1 1 1],...
                'PlotBoxAspectRatio',apos([3 4 4]))
    end
end

for i = 1:length(a2)   % use position as passed in by user
    xlim = get(a2(i),'xlim');
    ylim = get(a2(i),'ylim');
    objud = get(a2(i),'userdata');
    apos = objud.position;
    set(a2(i),'position',apos)
    if strcmp(objud.aspectmode,'equal')
        [newxlim,newylim] = newlims(apos,xlim,ylim);
        set(a2(i),'xlim',newxlim,'ylim',newylim,...
                'DataAspectRatio',[1 1 1],...
                'PlotBoxAspectRatio',apos([3 4 4]))
    end
end    

function pos = axpos(r,tilemode,numplots,spacing)
%AXPOS Filter Viewer Axes Positions
%       Inputs:
%           r - panel rectangle for outer edges which bounds all axes, in pixels
%           tilemode - size vector
%           numplots - number of plots to fit into r
%           spacing - spacing in pixels from [left bottom right top] 
%       Outputs:
%         pos - cell array of position vectors for axes, has one element for
%              each nonzero entry of plots.

    if prod(tilemode)<numplots
        error(sprintf('Can''t fit %g plots in %g spaces!',numplots,tilemode))
    end
    if numplots == 0
        pos = {};
        return
    end

    numrows = tilemode(1);
    numcols = min(tilemode(2),ceil(numplots/numrows));

    if numcols == 1, numrows = min(numrows,numplots); end

    % now break r into a numrows-by-numcols grid
    for i=1:numrows
        for j=1:numcols
            pos{i,j} = [r(1)+r(3)*(j-1)/numcols r(2)+r(4)*(i-1)/numrows ...
                         r(3)/numcols r(4)/numrows];
        end
    end    

    pos = flipud(pos);  

    pos = pos(:);  % rearrange into a column

    pos = pos(1:numplots);   

    % offset each position rectangle by spacing

    spacing = [spacing(1:2)  -(spacing(3:4)+spacing(1:2))];
    for i = 1:length(pos)
        pos{i} = pos{i} + spacing;
        pos{i}(3) = max(1,pos{i}(3));
        pos{i}(4) = max(1,pos{i}(4));
    end

% =================================

function [newxlim,newylim] = newlims(apos,xlim,ylim);
% Get the limits when aspectmode is 'equal'
% This function was copied from signal/private/fvresize.m

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

