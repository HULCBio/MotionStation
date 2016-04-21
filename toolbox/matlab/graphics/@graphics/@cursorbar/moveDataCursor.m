function moveDataCursor(hThis,hDataCursor,direc)
%MOVEDATACURSOR

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\moveDataCursor.m : start moveDataCursor');

% debug(hThis,['@cursorbar\moveDataCursor.m : direction : ' direc]);

pos = hDataCursor.Position;

% debug(hThis,['@cursorbar\moveDataCursor.m : original position : ' num2str(pos)]);

hTarget = hThis.Target;
hAxes = get(hThis,'Parent');

xdir = get(hAxes,'XDir');
ydir = get(hAxes,'YDir');

if all(isa(hTarget,'hg.line'))
    % determine next vertex
    x = pos(1);
    y = pos(2);
    
    XData = hThis.TargetXData;
    YData = hThis.TargetYData;
    
    switch hThis.Orientation
        case 'vertical'    
            % determine what the next possible X value is
            switch xdir
                case 'normal'
                    switch direc
                        case 'right'
                            % find next largest x value
                            ind = localNextIndex(x,XData,'greater');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind);
                        case 'left'  
                            % find next smallest x value
                            ind = localNextIndex(x,XData,'less');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind);
                        otherwise
                            % do nothing
                    end
                case 'reverse'
                    switch direc
                        case 'right'
                            % find next smallest x value
                            ind = localNextIndex(x,XData,'less');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind); 
                        case 'left'
                            % find next largest x value
                            ind = localNextIndex(x,XData,'greater');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind);                            
                        otherwise
                            % do nothing
                    end
            end
        case 'horizontal'
            % determine what the next possible Y value is           
            switch ydir
                case 'normal'
                    switch direc
                        case 'up'
                            % find next largest x value
                            ind = localNextIndex(y,YData,'greater');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind);
                        case 'down'  
                            % find next smallest x value
                            ind = localNextIndex(y,YData,'less');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind);                            
                        otherwise
                            % do nothing
                    end
                case 'reverse'
                    switch direc
                        case 'up'
                            % find next smallest x value
                            ind = localNextIndex(y,YData,'less');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind);     
                        case 'down'  
                            % find next largest x value
                            ind = localNextIndex(y,YData,'greater');
                            pos(1) = XData(ind);
                            pos(2) = YData(ind);
                        otherwise
                            % do nothing
                    end
            end            
    end
elseif numel(hTarget) == 1 && isa(hTarget,'hg.axes')
    pixperdata = getPixelsPerData(hThis);
    switch hThis.Orientation
        case 'vertical'
            switch xdir
                case 'normal'
                    switch direc
                        case 'right'
                            pos(1) = pos(1) + pixperdata(1);
                        case 'left'
                            pos(1) = pos(1) - pixperdata(1);
                        otherwise
                            % do nothing
                    end
                case 'reverse'
                    switch direc
                        case 'right'
                            pos(1) = pos(1) - pixperdata(1);
                        case 'left'
                            pos(1) = pos(1) + pixperdata(1);
                        otherwise
                            % do nothing
                    end
            end            
        case 'horizontal'
            switch ydir
                case 'normal'
                    switch direc
                        case 'up'
                            pos(2) = pos(2) + pixperdata(2);
                        case 'down'
                            pos(2) = pos(2) - pixperdata(2);
                        otherwise
                            % do nothing
                    end
                case 'reverse'
                    switch direc
                        case 'up'
                            pos(2) = pos(2) - pixperdata(2);
                        case 'down'
                            pos(2) = pos(2) + pixperdata(2);
                        otherwise
                            % do nothing
                    end
            end   
        otherwise
            % not vertical or horizontal
    end
else
    % not lines or an axes
end

% debug(hThis,['@cursorbar\moveDataCursor.m : position : ' num2str(pos)]);

set(hDataCursor,'Position',pos);

% debug(hThis,'@cursorbar\moveDataCursor.m : end moveDataCursor');

function ind = localNextIndex(d,Data,cmp)

switch cmp
    case 'greater'
        ind = find(Data > d);
        if isempty(ind)
            ind = length(Data);
            return
        end
        ind = min(ind);
    case 'less'
        ind = find(Data < d);
        if isempty(ind)
            ind = 1;
            return
        end
        ind = max(ind);
end



