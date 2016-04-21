function [fullh, h, arrowh, hscale, vscale] = makearrow(x,y,varargin)
%MAKEARROW Draw arrows for scribe plot editor

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/19 02:22:44 $

switch nargin
case 1
   redrawArrows(x);
   return
case 3
   % we have three handles, rebuild an arrow from
   % components
   fullline = x;
   lineHandle = y;
   arrowhead = varargin{1};
   fRebuild = 0;
otherwise
   fRebuild = 1;
end

% setup some defaults
aSize  = 10;
aStyle = 'Solid';

newVarargin = {};
    
if (nargin > 2) & fRebuild

   ind1 = 1;
   ind2 = 1;
   
   while (ind1 <= length(varargin))
      % parse the input args
      Param = varargin{ind1};
      if (length(varargin) > ind1)
         Value = varargin{ind1+1};
      else
         newVarargin{ind2} = Param;
         break;
      end
   
      switch lower(Param)
      case {'arrowsize', 'arrowsi'}
         aSize  = Value;
      case {'arrowstyle','arrowst'}
         aStyle = Value;
      otherwise
         newVarargin{ind2} = Param;
         ind2 = ind2 + 1;
         newVarargin{ind2} = Value;
         ind2 = ind2 + 1;
      end
      ind1 = ind1 + 2;
   end
end


if fRebuild
   % draw the line
   fullline = graph2d.arrow('XData',x,'YData',y,'CreateFcn','',newVarargin{:});
   parentAxis = get(fullline,'Parent');
   lineHandle = line(x,y,'CreateFcn','',newVarargin{:},'HandleVisibility','off');
   set(fullline,'LineHandle',lineHandle);
else
   set(lineHandle,'HandleVisibility','off');
   parentAxis = get(fullline,'Parent');
end

setappdata(lineHandle,'ScribeButtonDownFcn','doclick');
setappdata(lineHandle,'ScribeButtonDownHGObj',double(fullline));
set(fullline,'LineStyle','none');

% get the scale factors
[vertScale, horizScale] = dataToPoints(parentAxis);

% build the new arrow
[aX, aY] = buildArrow(lineHandle, fullline, horizScale, vertScale, aSize, aStyle);

% draw the arrow
if fRebuild
   arrowhead = addArrow(aX, aY, lineHandle, fullline, aSize, aStyle);
   % update the rest of the arrows on the current axis
   % redrawArrows(horizScale, vertScale);
else
   arrowhead = addArrow(aX, aY, lineHandle, fullline, aSize, aStyle,...
           arrowhead);
end

try
    set(handle(fullline),'HeadHandle',arrowhead);
end


% return the handle if asked
switch nargout
case 2
   fullh = double(fullline);
   h = lineHandle;
case 3
   fullh = double(fullline);   
   h = lineHandle;
   arrowh = arrowhead;
case 5
   fullh = double(fullline);   
   h = lineHandle;
   arrowh = arrowhead;
   vscale = vertScale;
   hscale = horizScale;   
end

%% end main

function [vscale, hscale] = dataToPoints(axH);
% create a conversion from data to points for the current axis
oldUnits = get(axH,'Units');
set(axH,'Units','points');
Pos = get(axH,'Position');
set(axH,'Units',oldUnits);
vscale = 1/Pos(4);
hscale = 1/Pos(3);

function [xt, yt] = buildArrow(lh, fh, hscale, vscale, ah, sty);
% returns x and y coord vectors for an arrow head

if (nargin < 5)
    sty = 'solid'; % default to solid arrowhead
end

if (nargin < 4)
    ah = 16;       % default to 12 points high
end

% get the line width
lw = get(lh, 'LineWidth');
if (iscell(lw))
    lw = lw{end}
end

% scale ah by line width
ah = ah * lw/2;
ah = max(ah,6);

X = get(fh, 'XData');
Y = get(fh, 'YData');

x1 = X(end - 1);
x2 = X(end);
y1 = Y(end - 1);
y2 = Y(end);

% calculate the x, and y lengths (in points)
xl = (x2 - x1) / hscale;
yl = (y2 - y1) / vscale;
hy = (xl^2 + yl^2)^.5;

% calculate the cosine and sine
co =  xl / hy;
si =  yl / hy;

% scale the line down

hlx2=x2-ah*co*hscale;
hly2=y2-ah*si*vscale;

set(lh,'XData', [x1 hlx2], 'YData', [y1 hly2]);

% 3 : 2 aspect ratio
aw = ah * .66;

% determine arrowhead style
if (strcmp(lower(sty),'solid') | strcmp(lower(sty),'hollow'))
    xt = [ -ah,  -ah, 0,   -ah, -ah ];
    yt = [   0, aw/2, 0, -aw/2,   0 ];
elseif (strcmp(lower(sty),'line'))
    xt = [  -ah,  0,   -ah ];
    yt = [ aw/2,  0, -aw/2 ];
else
    error(sprintf('Unknown arrow style %s',sty));
end

% rotate the triangle based on the slope of the last line
foo = [co -si; si  co] * [xt; yt];
    
% convert points back to to data units and add in the offset
xt = foo(1,:) * hscale + x2;
yt = foo(2,:) * vscale + y2;



function [] = redrawArrows(hscale, vscale);
% finds all arrow objects in the current axis and redraws them.
% removes arrows who's line no longer exists

if (nargin == 1)
   arrows = hscale;
else
   arrows = findall(gcbf,'Tag','ScribeArrowlineHead');
end


% find all other arrow objects and scale to fit new axis
for (i = 1:length(arrows))
    thisArrow = arrows(i);
    if (nargin < 2)
        % get the scale factors
        [vscale, hscale] = dataToPoints(get(thisArrow,'Parent'));
    end
    ud = getappdata(thisArrow,'ScribeArrowData');
    % ud{1} -> lineHandle
    % ud{2} -> arrowSize
    % ud{3} -> arrowStyle
    if (~ishandle(ud{1}))
        delete(thisArrow)
    else
        [aX, aY] = buildArrow(ud{1}, ud{4}, hscale, vscale, ud{2}, ud{3});
        set(thisArrow,'xdata',aX,'ydata',aY);
    end
end

function [arrowhead] = addArrow(ax, ay, lh, fh, siz, sty, varargin);
% add arrow to the current axis

if nargin == 7
   fRebuild = 0;
   arrowhead = varargin{1};
else
   fRebuild = 1;
end

color = get(lh,'color');
parent = get(lh,'Parent');
if (iscell(color))
    color = color{end}
end

% determine arrowhead style
if (strcmp(lower(sty),'solid') | strcmp(lower(sty),'hollow'))
    % set the fill color to the background color if the ArrowStyle is Hollow
    if (strcmp(lower(sty),'hollow'))
        fillColor = get(parent,'Color');
    else
        fillColor = color;
    end
    % draw a patch for the arrowhead
    arrowProps = struct(...
            'XData',ax,...
            'YData',ay,...
            'FaceColor',fillColor,...
            'EdgeColor',color,...
            'Tag','ScribeArrowlineHead',...
            'CreateFcn','',...
            'HandleVisibility','off',...
            'Parent',parent);
    if fRebuild
       arrowhead = patch(ax,ay,fillColor,arrowProps);
    else
       set(arrowhead,arrowProps);
    end
    setappdata(arrowhead, 'ScribeArrowData', {lh, siz, sty, fh});
    setappdata(arrowhead, 'ScribeButtonDownHGObj', double(fh));
    setappdata(arrowhead, 'ScribeButtonDownFcn', 'doclick');    
    % flag for nodither to set colors properly in printing
    setappdata(arrowhead,'NoDither','on');

elseif (strcmp(lower(sty),'line'))
    % draw a line for the arrowhead
    arrowProps = struct(...
            'XData',ax,...
            'YData',ay,...
            'Color',color,...
            'Tag','ScribeArrowlineHead',...
            'CreateFcn','',...
            'Parent',parent);
    if fRebuild
       arrowhead = line(ax,ay,color,arrowProps);
    else
       set(arrowhead,arrowProps);
    end
    setappdata(arrowhead, 'ScribeArrowData',{lh, siz, sty, fh});
    setappdata(arrowhead, 'ScribeButtonDownHGObj', fh);
    setappdata(arrowhead, 'ScribeButtonDownFcn', 'doclick');

else
    arrowhead = [];
    error(sprintf('Unknown arrow style %s',sty));
end



