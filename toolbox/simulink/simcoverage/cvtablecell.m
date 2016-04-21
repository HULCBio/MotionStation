function cvtablecell(tableId,execCnt,index,minVal,maxVal,tableDims)
%CVTABLECELL - A dialog for displaying table coverage details
%
%   CVTABLECELL(TABLEID,EXECCNT,INDEX,MINVAL,MAXVAL) Produce
%   a dialog box which lists the interpolation or saturation, 
%   region based on the intervals MINVAL(i) - MAXVAL(i),
%   execution counts, EXECCNT, and table index, INDEX.
%   Saturation is indicated by replacing elements in MINVAL 
%   or MAXVAL with NaN. If MAXVAL is empty and MIVAL is a scalar
%   the information will be displayed for a break point definied
%   by the nonzero INDEX element and the value of MINVAL.

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $  $Date: 2004/04/15 00:37:02 $


% =======================================================================
%  INTERVAL CALCULATION 
% 
%% *      Given a series of break points find the interval that x belongs to.  The
%% *      ouput is between [0,n]. The break point array is defined over [0,n-1]
%% *      
%% *              0:      x < brk[0]
%% *              n:      x > brk[n-1]
%% *
%% *
%% *                     /                      / brk[i-1] < 0  AND  brk[i-1] != brk[i]
%% *                    |  x == brk[i-1]  AND  |               OR    
%% *                    |                       \ i == 1
%% *                    |          OR         
%% *                    |                   
%% *              i:    |  x is in (brk[i-1],brk[i])  
%% *                    |                 
%% *                    |          OR       
%% *                    |                     / brk[i] >= 0    AND  brk[i-1] != brk[i]
%% *                    |  x == brk[i] AND   |                 OR
%% *                     \                    \  i == (n-1)  
%% *
%% *              NOTE:   If there are duplicated break points, brk[i-1]==brk[i], for some i,
%% *                      then some intervals will not be acheivable for any x.
%% */
%% =======================================================================
%%

    if nargin<6
        tableDims = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reuse an existing figure if it exists.
    dlg = findobj(0,'Type','figure','Tag','cvtablecell');
   
    if isempty(dlg)
        dlg = create_dialog;
    end

    UD = get(dlg,'UserData');
    
    if isempty(maxVal)  % Info is for an X break point

        titleStr = sprintf('Break Point #%d',index);
        rowDispStr = sprintf('X = %g',minVal);
        execDispStr = sprintf('%g',execCnt);
        
        set(dlg,'Name', titleStr);
        set(UD.rowDisp,'String',rowDispStr);
        set(UD.execDisp,'String',execDispStr);
        set(UD.rowLabel,'String','Value:');
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hide unused text entries
        set([UD.colDisp UD.colLabel UD.regionDisp UD.regionLabel],'Visible','off');
                  
    elseif isempty(minVal)  % Info is for an Y break point

        titleStr = sprintf('Break Point #%d',index);
        rowDispStr = sprintf('Y = %g',maxVal);
        execDispStr = sprintf('%g',execCnt);
        
        set(dlg,'Name', titleStr);
        set(UD.rowDisp,'String',rowDispStr);
        set(UD.execDisp,'String',execDispStr);
        set(UD.rowLabel,'String','Value:');
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hide unused text entries
        set([UD.colDisp UD.colLabel UD.regionDisp UD.regionLabel],'Visible','off');
                  
    else % Info is for an interpolation/saturation interval

        execDispStr = sprintf('%g',execCnt);
        if any(isnan(minVal)) | any(isnan(maxVal))
            regionStr = 'Extrapolation/Saturation';
        else
            regionStr = 'Interpolation';
        end
        
    
        switch(length(index))  % The dimension of the look-up table
        case 1,
            titleStr = sprintf('Interpolation Interval (%d)',index(1));

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Row display
            set(UD.rowLabel,'String','Interval:');
            if isnan(maxVal(1))
                rowDispStr = sprintf('X > %g',minVal(1));
            elseif isnan(minVal(1))
                rowDispStr = sprintf('X < %g',maxVal(1));
            else
                rowDispStr = sprintf('%g <= X < %g',minVal(1),maxVal(1));
            end
        
            set([UD.colDisp UD.colLabel],'Visible','off');
        
        
        case 2,
            titleStr = sprintf('Interpolation Interval (%d,%d)',index(1),index(2));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Row display
            set(UD.rowLabel,'String','Row:');
            if isnan(maxVal(1))
                rowDispStr = sprintf('X > %g',minVal(1));
            elseif isnan(minVal(1))
                rowDispStr = sprintf('X < %g',maxVal(1));
            else
                if (index(1)==2 || minVal(1)<0)
                    leftRelation = '<=';
                else
                    leftRelation = '<';
                end
                
                if (maxVal(1)>=0 || (~isempty(tableDims) && index(1)==tableDims(1)))
                    rightRelation = '<=';
                else
                    rightRelation = '<';
                end
                
                rowDispStr = sprintf('%g %s X %s %g',minVal(1),leftRelation,rightRelation,maxVal(1));
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Column display
            if isnan(maxVal(2))
                colDispStr = sprintf('Y > %g',minVal(2));
            elseif isnan(minVal(2))
                colDispStr = sprintf('Y < %g',maxVal(2));
            else
                if (index(2)==2 || minVal(2)<0)
                    leftRelation = '<=';
                else
                    leftRelation = '<';
                end
                
                if (maxVal(2)>=0 || (~isempty(tableDims) && index(2)==tableDims(2)))
                    rightRelation = '<=';
                else
                    rightRelation = '<';
                end
                
                colDispStr = sprintf('%g %s Y %s %g',minVal(2),leftRelation,rightRelation,maxVal(2));
            end
            
            set(UD.colDisp,'String',colDispStr);
            set([UD.colDisp UD.colLabel],'Visible','on');
            
        otherwise,
            error('Tables with more than two dimensions are not supported');


        end

        set(UD.regionDisp,'String',regionStr);
        set(dlg,'Name', titleStr);
        set(UD.rowDisp,'String',rowDispStr);
        set(UD.execDisp,'String',execDispStr);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Show needed text entries
        set([UD.regionDisp UD.regionLabel],'Visible','on');

    end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Bring figure to foreground
   figure(dlg);
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function dialog = create_dialog(),

    % Layout constants
    figBuffer = 8;     % Border around figure
    vertSpace = 3;
    displWidth = 120;
    labelDelta = 10;
    textSize = 10;
    textHeight = 12;
    figBgColor = [1 1 1]*0.8;

    Labels = {'Region: ', 'Row: ','Column: ','Execution counts: '};


    dialog = figure(   'NumberTitle','off'...
                      ,'Menu','none'...
                	  ,'Toolbar', 'none' ...
                      ,'Tag','cvtablecell'...
                      ,'HandleVisibility', 'on'...
                      ,'Visible','off'...
                      ,'Color',figBgColor...
                      ,'Resize','off'...
                      ,'DeleteFcn',''...
                      ,'Units','points'...
                      ,'IntegerHandle','off'...
                      ,'DefaultUiControlUnits','points'...
                      ,'DefaultUiControlClipping','off'...
                      ,'DefaultUiControlHorizontalAlign','left'...
                      ,'DefaultUiControlEnable','on'...
                      ,'Interruptible','off'...
                      ,'BusyAction','cancel'...
	                );


    
    labelProps = {  ...
                    'Parent',                   dialog, ...
                    'style',                    'text', ...
                    'HorizontalAlignment',      'left', ...
                    'BackgroundColor',          figBgColor, ...
                    'Units',                    'points', ...
                    'FontWeight',               'bold', ...    
                    'FontSize',                 textSize ...
                 };
                 
    dispProps = {  ...
                    'Parent',                   dialog, ...
                    'style',                    'text', ...
                    'HorizontalAlignment',      'left', ...
                    'BackgroundColor',          figBgColor, ...
                    'Units',                    'points', ...
                    'FontWeight',               'normal', ...    
                    'FontSize',                 textSize ...
                 };
                 
    sizeCheck = uicontrol( ...
        labelProps{:}, ...
        'Visible',    'off' ...
        );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate positions
    currX = figBuffer;
    currY = figBuffer;
    
    set(sizeCheck,'String',Labels{4});
    txtExtent = get(sizeCheck,'Extent');
    labelWidth = txtExtent(3);
    dispCol = currX + labelWidth + labelDelta;
   
    execLabelPos = [currX currY labelWidth textHeight];
    execDispPos = [dispCol currY displWidth textHeight];
    
    currY = currY + 2*vertSpace + textHeight;
    
    colLabelPos = [currX currY labelWidth textHeight];
    colDispPos = [dispCol currY displWidth textHeight];
    
    currY = currY + vertSpace + textHeight;
    
    rowLabelPos = [currX currY labelWidth textHeight];
    rowDispPos = [dispCol currY displWidth textHeight];
    
    currY = currY + vertSpace + textHeight;
    
    regionLabelPos = [currX currY labelWidth textHeight];
    regionDispPos = [dispCol currY displWidth textHeight];
    
    totalY = currY + figBuffer + textHeight;
    totalX = dispCol + displWidth + figBuffer;
    
    oldUnits = get(0,'Units');
    set(0,'Units','points');
    defaultFigPos = get(0,'defaultFigurePosition');
    set(0,'Units',oldUnits);

    
    defaultFigPos(3:4) = [totalX totalY];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the uicontrol objects
    UD.regionLabel = uicontrol( labelProps{:}, ...
                                'Position',         regionLabelPos, ...
                                'String',           Labels{1});
    
    UD.regionDisp = uicontrol(  dispProps{:}, ...
                                'Position',         regionDispPos, ...
                                'String',           '');
        
    UD.rowLabel = uicontrol(    labelProps{:}, ...
                                'Position',         rowLabelPos, ...
                                'String',           Labels{2});
    
    UD.rowDisp = uicontrol(     dispProps{:}, ...
                                'Position',         rowDispPos, ...
                                'String',           '');
    
    UD.colLabel = uicontrol(    labelProps{:}, ...
                                'Position',         colLabelPos, ...
                                'String',           Labels{3});
    
    UD.colDisp = uicontrol(     dispProps{:}, ...
                                'Position',         colDispPos, ...
                                'String',           '');
    
    UD.execLabel = uicontrol(   labelProps{:}, ...
                                'Position',         execLabelPos, ...
                                'String',           Labels{4});
    
    UD.execDisp = uicontrol(    dispProps{:}, ...
                                'Position',                 execDispPos, ...
                                'Parent',                   dialog, ...
                                'style',                    'text', ...
                                'HorizontalAlignment',      'left', ...
                                'BackgroundColor',          [1 1 1], ...
                                'Units',                    'points', ...
                                'FontWeight',               'bold', ...    
                                'FontSize',                 textSize, ...
                                'String',           '');
    
    set(dialog,'Position',defaultFigPos,'UserData',UD,'Visible','on');
                