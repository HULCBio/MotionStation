function strVals = sigbuilder_modal_edit_dialog(titleStr,labels,startvals,origin,popupChoices)
%
% strVals=0 when cancel button is pressed

%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.6 $  $Date: 2002/04/10 18:29:27 $

    % By default all entries are edit fields
    
    % Geometry constants
    geomConst.figBuff = 6;
    geomConst.ojbHoffset = 4;
    geomConst.rowDelta = 8;
    geomConst.sysButtonExt = [50 20];
    geomConst.editBoxExt = [120 15];
    
    bgColor = [0.8 0.8 0.8];

	% Get current position
	prevUnits = get(0,'Units');
	set(0,'Units','Points');
	screenPoint = get(0,'PointerLocation');
	screenSize = get(0,'ScreenSize');
	set(0,'Units',prevUnits);
	
	
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Create Dialog Fig %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    FigPos=get(0,'DefaultFigurePosition');
    FigWidth=75;FigHeight=45;
    FigPos(3:4)=[FigWidth FigHeight];
    dlg =dialog(                                               ...
                   'Visible'         ,'off'                      , ...
                   'Name'            ,titleStr                   , ...
                   'Pointer'         ,'arrow'                    , ...
                   'Units'           ,'points'                   , ...
                   'Position'        ,FigPos                     , ...
                   'UserData'        ,0                          , ...
                   'IntegerHandle'   ,'off'                      , ...
                   'Color'           ,bgColor                    , ... 
                   'WindowStyle'     ,'normal'                   , ... 
                   'HandleVisibility','callback'                 , ...
                   'Tag'             ,titleStr                   ...
                   );

    textExtent = uicontrol( ...
        'Units',     'points', ...
        'Parent',     dlg, ...
        'Visible',    'off', ...
        'Style',      'text', ...
        'String',     'abcdefghijklABCDEFG' ...
        );
    
    %
    % Correct the uicontrol heights based on text size
    %
    txtExt = get(textExtent,'Extent');
    if(ispc)
        txtDispHeight = 1.15*txtExt(4);
        geomConst.staticTextH = txtExt(4);         
    else
        txtDispHeight = txtExt(4);
        geomConst.staticTextH = txtExt(4);
    end
    geomConst.sysButtonExt = [50 txtDispHeight+4];
    geomConst.editBoxExt = [120 txtDispHeight];
    

    if iscell(labels)
        numRows = length(labels);
        if nargin==2 | isempty(startvals)
            startvals = cell(numRows,1);
        else
            if length(startvals)~=numRows
                error('Labels and starting string must have the same length');
            end
        end
        for i=1:numRows
            rowWidth(i) = get_text_width(xlate(labels{i}),textExtent);
        end
    else
        numRows = 1;
        rowWidth = get_text_width(labels,textExtent);
        if nargin==2 | isempty(startvals)
            startvals = '';
        end
        
    end

    if nargin<5
        popupChoices = cell(1,numRows);
    end

    xMargin2 = geomConst.figBuff + max(rowWidth) + geomConst.ojbHoffset;

    figWidth = xMargin2 + geomConst.editBoxExt(1) + geomConst.figBuff;
    figHeight = numRows*(geomConst.editBoxExt(2)+geomConst.rowDelta) + ...
                2*geomConst.figBuff + geomConst.sysButtonExt(2);

    if nargin<4 | isempty(origin)
        origin = screenPoint;
    end

    if origin(1)+figWidth > (screenSize(3)-40)
        origin(1) = screenSize(3) - 40 - figWidth;
    end
    if origin(2)+figHeight > (screenSize(4) - 40)
        origin(2) = screenSize(4) - 40 - figHeight;
    end
    newFigPos = [origin figWidth figHeight];

    set(dlg,'Position',newFigPos);


    currY = figHeight - geomConst.editBoxExt(2) - geomConst.figBuff;

    for i=1:numRows
        labelPos = [geomConst.figBuff currY max(rowWidth) geomConst.editBoxExt(2)];
        editPos = [xMargin2 currY geomConst.editBoxExt];
        
        if iscell(labels)
            labelStr = labels{i};
            if isempty(popupChoices{i})
                editStr = char(startvals{i});
            end
        else
            labelStr = labels;
            editStr = startvals;
        end


        labelH(i) = uicontrol(  'Parent',                   dlg, ...
                                'Style',                    'text', ...
                                'BackgroundColor',          bgColor, ...
                                'HorizontalAlignment',      'left', ...
                                'String',                   labelStr, ...
                                'Units',                    'points', ...
                                'Position',                 labelPos ...
                            );

        if isempty(popupChoices{i})
            editH(i) = uicontrol(   'Parent',                   dlg, ...
                                    'Style',                    'edit', ...
                                    'BackgroundColor',          'w', ...
                                    'HorizontalAlignment',      'left', ...
                                    'String',                   editStr, ...
                                    'Units',                    'points', ...
                                    'Position',                 editPos ...
                                );
        else
            editH(i) = uicontrol(   'Parent',                   dlg, ...
                                    'Style',                    'popup', ...
                                    'BackgroundColor',          'w', ...
                                    'HorizontalAlignment',      'left', ...
                                    'String',                   popupChoices{i}, ...
                                    'Value',                    startvals{i}, ...                     
                                    'Units',                    'points', ...
                                    'Position',                 editPos ...
                                );
        end

        currY = currY - (geomConst.editBoxExt(2)+geomConst.rowDelta);
    end

    currY = geomConst.figBuff;
    currX = figWidth - geomConst.figBuff - 2*(geomConst.sysButtonExt(1)) - ...
            geomConst.ojbHoffset;

    okPos = [currX currY geomConst.sysButtonExt];
    cancelPos = okPos + [geomConst.sysButtonExt(1)+geomConst.ojbHoffset  0 0 0];

    okH = uicontrol(   'Parent',                   dlg, ...
                        'Style',                    'push', ...
                        'BackgroundColor',          bgColor, ...
                        'HorizontalAlignment',      'left', ...
                        'HandleVisibility',         'callback', ...
                        'Callback',                 'uiresume(gcf)', ...
                        'String',                   'OK', ...
                        'Units',                    'points', ...
                        'Position',                 okPos ...
                    );

    cancelH = uicontrol(   'Parent',                dlg, ...
                        'Style',                    'push', ...
                        'BackgroundColor',          bgColor, ...
                        'HorizontalAlignment',      'left', ...
                        'HandleVisibility',         'callback', ...
                        'Callback',                 'uiresume(gcf)', ...
                        'String',                   'Cancel', ...
                        'Units',                    'points', ...
                        'Position',                 cancelPos ...
                    );

    
    
    % Temporary hack to fix strangely appearing axes
    axH = findobj(dlg,'Style','axes');
    if ~isempty(axH)
    	delete(axH);
    end
    
    set(dlg ,'WindowStyle','modal','Visible','on');
    drawnow;
    uiwait(dlg);

    if ishandle(dlg),
        objStr = get(get(dlg,'CurrentObject'),'String');
        if(strcmp(objStr,'Cancel'))
            strVals = 0;
        else
            for i=1:numRows
                if isempty(popupChoices{i})
                    strVals{i} = get(editH(i),'String');
                else
                    allStrings = get(editH(i),'String');
                    strVals{i} = allStrings{get(editH(i),'Value')};
                end
            end
        end
        delete(dlg);
        if numRows==1 & iscell(strVals)
            strVals = strVals{1};
        end
    else
        strVals = 0;
    end


function width = get_text_width(labelStr,hgObj)
    set(hgObj, 'String', labelStr);
    ext = get(hgObj, 'Extent');
    width = ext(3);



