function display_intersect_rect(rect,tag,number)

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/10/14 18:13:34 $

    persistent  hFig hAxes;
    
    blueColor = [0.5294    0.6863    0.9804];
    redColor = [1.0000    0.3922    0.4078];
    
    
    if ischar(rect)
        switch(rect)
        case 'clear'
        case 'new'
            hFig = figure;
            figPos = get(hFig,'Position');
            hAxes = axes('Parent',hFig,'XLim',[-0.25 11],'YLim',[-1 3], ...
                        'XTick',[],'YTick',[],'Box','on');
                        
            % ,'Position',[2.5 2.5 figPos(3:4)-5]
        otherwise,
            error('Bad input');
        end
    else

        if isempty(hFig) || ~ishandle(hFig)
            display_intersect_rect('new');
        end


        if tag
            useColor = redColor;
        else
            useColor = blueColor;
        end
    
    
        rectangle(  'Parent',       hAxes ...
                    ,'Position',    rect ...
                    ,'FaceColor',   useColor ...
                    ,'EdgeColor',   'k');
                    
        str = num2str(number);

        text(  'Parent',                    hAxes ...
                ,'Position',                rect(1:2) + 0.5*rect(3:4) ...
                ,'String',                  str ...
                ,'HorizontalAlignment',     'center' ...
                ,'VerticalAlignment',       'middle' ...
                ,'FontWeight',              'bold');
                    
        
    end
    
    