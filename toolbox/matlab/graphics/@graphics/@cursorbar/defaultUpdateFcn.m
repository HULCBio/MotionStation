function defaultUpdateFcn(hThis)
%DEFAULTUPDATEFCN

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\defaultUpdateFcn.m start defaultUpdateFcn')

hText = get(hThis,'DisplayHandle');


if strcmp(hThis.ShowText,'off') 
    if ~isempty(hText)
        delete(hText);
        hThis.DisplayHandle = [];
        return
    end
    return    
end

% get the locations of the markers

xData = get(hThis.TargetMarkerHandle,'XData');
yData = get(hThis.TargetMarkerHandle,'YData');

numIntersections = length(xData);

% get the handles for the text objects, corrseponding to each intersection

hAxes = get(hThis,'Parent');


%%%%%%%%%%%%%

AXCOLOR = get(hAxes,'Color');

if isstr(AXCOLOR), AXCOLOR = get(hAxes,'Color'); end

% light colored axes
if sum(AXCOLOR)>1.5 
    TEXTCOLOR = [0,0,0]; FACECOLOR = [1 1 238/255]; EDGECOLOR = [.8 .8 .8];
% dark colored axes (i.e. simulink scopes)
else 
    TEXTCOLOR = [.8 .8 .6]; FACECOLOR = 48/255*[1 1 1]; EDGECOLOR = [.8 .8 .6];
end

%%%%%%%%%%%%%



% create text objects if necessary
if isempty(hText)  | any(~ishandle(hText))    
    
    % debug(hThis,'@cursorbar\defaultUpdateFcn.m empty hText')
    
    hText = zeros(numIntersections,1);
    for n = 1:numIntersections,
        hText(n) = text(xData(n),yData(n),'',...
                              'Parent',hAxes,...
                              'Color',TEXTCOLOR,...
                              'EdgeColor',EDGECOLOR,...
                              'BackgroundColor',FACECOLOR,...
                              'Visible','off');
    end
    numText = numIntersections;
else
    % if the number of intersections isn't equal to the number of text objects,
    % add/delete them as necessary  
    
    % debug(hThis,'@cursorbar\defaultUpdateFcn.m nonempty hText')
    
    
    set(hText,'Visible','off');
    
    numText = length(hText);

    if numText ~= numIntersections
        % unequal number of text objects and intersections
        delete(hText)
        
        hText = [];
        
        % debug(hThis,'@cursorbar\defaultUpdateFcn.m numText ~= numIntersections')
        
        for n = numIntersections: -1 : 1
            hText(n) = text(xData(n),yData(n),'',...
                                  'Parent',hAxes,...
                                  'Color',TEXTCOLOR,...
                                  'EdgeColor',EDGECOLOR,...
                                  'BackgroundColor',FACECOLOR,...
                                  'Visible','off');
        end
        numText = numIntersections;
    end

    
end

% now update the text objects

set(hText,'Visible','off','Units','data')

xl = get(hAxes,'XLim');
yl = get(hAxes,'YLim');

xdir = get(hAxes,'XDir');
ydir = get(hAxes,'YDir');

pixperdata = getPixelsPerData(hThis);
pixoffset = 12;

xoffset = 0;
yoffset = 0;

for n = 1:numText
    x = xData(n);
    y = yData(n);
    
    if x >= mean(xl)
        if strcmp(xdir,'normal')
            halign = 'right';
            xoffset = -pixoffset * 1/pixperdata(1);
        else
            halign = 'left';
            xoffset = pixoffset * 1/pixperdata(1);
        end
    else
        if strcmp(xdir,'normal')
            halign = 'left';
            xoffset = pixoffset * 1/pixperdata(1);
        else
            halign = 'right';
            xoffset = -pixoffset * 1/pixperdata(1);
        end
    end   
    
    
    if y >= mean(yl)
        if strcmp(ydir,'normal')
            valign = 'top';
            yoffset = -pixoffset * 1/pixperdata(2);
        else
            valign = 'bottom';
            yoffset = pixoffset * 1/pixperdata(2);
        end
    else
        if strcmp(ydir,'normal')
            valign = 'bottom';
            yoffset = pixoffset * 1/pixperdata(2);
        else
            valign = 'right';
            yoffset = -pixoffset * 1/pixperdata(2);
        end
    end
    
    set(hText(n),'Position',[x+xoffset, y+yoffset, 0],...
                       'String',makeString(x,y,hThis.Orientation),...
                       'HorizontalAlignment',halign,...
                       'VerticalAlignment',valign);    
end



set(hThis,'DisplayHandle',hText);

set(hText,'Visible','on');

% debug(hThis,'@cursorbar\defaultUpdateFcn.m end defaultUpdateFcn')

% --------------------------------------
function str = makeString(x,y,orient)

switch orient
    case 'vertical'
        str = ['Y: ' num2str(y)];
    case 'horizontal'
        str = ['X: ' num2str(x)];
end