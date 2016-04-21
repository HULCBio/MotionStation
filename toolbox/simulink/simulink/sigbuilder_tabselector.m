function varargout = sigbuilder_tabselector(method,varargin)
%TABSELECTOR - Create and manage a tabbed selector
%
%   AXESH = TABSELECTOR('CREATE',FIGH,ORIGIN,WIDTH,NAMES,ACTIVEIDX,CALLBACK)
%   Create a tab based selector in the figure with handle FIGH positioned at
%   ORIGIN with a width of WIDTH points including scroll buttons.
%
%

%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 1.5.2.2 $  $Date: 2004/04/15 00:49:07 $

switch(method)
case 'create'
    figH = varargin{1};
    origin = varargin{2};
    width = varargin{3};
    entryNames = varargin{4};
    activeEntry = varargin{5};
    contextMenuH = varargin{6};

    handleStruct = create_selector(figH,origin,width,entryNames,activeEntry,contextMenuH);
    varargout{1} = handleStruct;
    
case 'addentry'

    axesH = varargin{1};
    labelStr = varargin{2};
    UD = get(axesH,'UserData');
    
    UD = add_entry(UD,axesH,labelStr);

    if (nargin>3 & varargin{3}) % Force new entry to be selected
        UD = activate_entry(UD,axesH,length(UD.tabentries));
    end
    set(axesH,'UserData',UD);

case 'rename'
    axesH = varargin{1};
    index = varargin{2};
    labelStr = varargin{3};
    UD = get(axesH,'UserData');
    
    UD = rename_entry(UD,axesH,index,labelStr);

    set(axesH,'UserData',UD);

case 'removeentry'
    axesH = varargin{1};
    index = varargin{2};
    UD = get(axesH,'UserData');
    UD = remove_entry(UD,axesH,index);
    set(axesH,'UserData',UD);

case 'movetab'
    axesH = varargin{1};
    oldIdx = varargin{2};
    newIdx = varargin{3};
    UD = get(axesH,'UserData');
    UD = move_tab(UD,axesH,oldIdx,newIdx);
    set(axesH,'UserData',UD);


case 'mouseAction'
    switch(get(gcbo,'Type'))
    case {'text','image','line','patch','rectangle'}
        axesH = get(gcbo,'Parent');
    case 'axes'
        axesH = gcbo;
    otherwise
        error('Unkown object type');
    end
    
    UD = get(axesH,'UserData');
    cPoint = get(axesH,'CurrentPoint');
    xpos = cPoint(1,1);
    action = varargin{1};
    
    UD = mouse_handler(action,axesH,UD,xpos);
    set(axesH,'UserData',UD);

case 'tab_left'
    switch(get(gcbo,'Type'))
    case {'text','image','line','patch','rectangle'}
        axesH = get(gcbo,'Parent');
    case 'axes'
        axesH = gcbo;
    case 'uicontrol'
        axesH = get(gcbo,'UserData');
    otherwise
        error('Unkown object type');
    end
    
    UD = get(axesH,'UserData');
    UD = tab_left(UD,axesH);
    set(axesH,'UserData',UD);


case 'tab_right'
    switch(get(gcbo,'Type'))
    case {'text','image','line','patch','rectangle'}
        axesH = get(gcbo,'Parent');
    case 'axes'
        axesH = gcbo;
    case 'uicontrol'
        axesH = get(gcbo,'UserData');
    otherwise
        error('Unkown object type');
    end
    
    UD = get(axesH,'UserData');
    UD = tab_right(UD,axesH);
    set(axesH,'UserData',UD);



case 'activate'
    axesH = varargin{1};
    index = varargin{2};
    if nargin>3
        ignoreCB = varargin{3};
    else
        ignoreCB = 0;
    end
    
    UD = get(axesH,'UserData');
    UD = activate_entry(UD,axesH,index,ignoreCB);
    set(axesH,'UserData',UD);



case 'resize'
    axesH = varargin{1};
    deltaWidth = varargin{2};
        
    UD = get(axesH,'UserData');
    UD = resize(UD,axesH,deltaWidth);
    
    set(axesH,'UserData',UD);


case 'touch'
    axesH = varargin{1};
    UD = get(axesH,'UserData');
    touch(UD,axesH);
    
otherwise
    error('Unkown Method')
end


function UD = mouse_handler(action,axesH,UD,xpos)

    switch(action)
    case 'BD'
        pressedIdx = sum(xpos > UD.tabBoundaries) + 1;
        if (pressedIdx > length(UD.tabentries)) % User pressed outside the tabs
            return
        end
        UD = activate_entry(UD,axesH,pressedIdx);
        
    otherwise,
        error('Unknown method');
    end
    

function UD = tab_left(UD,axesH)

    xlim = get(axesH,'Xlim');
    idx = sum(xlim(1) > UD.tabBoundaries);
    if idx==0
        widthChange = xlim(1);
    else
        widthChange = xlim(1) - UD.tabBoundaries(idx);
    end
    set(axesH,'Xlim',xlim-widthChange);
    UD = resize(UD,axesH,0);

function UD = tab_right(UD,axesH)
    xlim = get(axesH,'Xlim');
    if (UD.totalAxesWidth < xlim(2))
        return;     % No need to tab
    end
    
    idx = sum(xlim(1) >= UD.tabBoundaries);
    widthChange = UD.tabBoundaries(idx+1) - xlim(1) ;
    set(axesH,'Xlim',xlim+widthChange);
    UD = resize(UD,axesH,0);
        
function UD = resize(UD,axesH,deltaWidth)
    
    axesDelta = deltaWidth/UD.pix2points(1);
    oldXlim = get(axesH,'XLim');
    oldPos = get(axesH,'Position');
    if oldXlim(1)<=0.5 | oldXlim(2) < UD.totalAxesWidth
        newXlim = oldXlim + [0 axesDelta];
    else
        newXlim = max(0.5,oldXlim(1)-axesDelta) + [0 diff(oldXlim)+axesDelta];
    end
    
    
    set(axesH,  'Xlim',         newXlim ...
                ,'Position',    oldPos+[0 0 deltaWidth 0] ...
        );
    
    lftPos = get(UD.leftScroll,'Position');
    if newXlim(1) <=0.5
        set(UD.leftScroll,  'Position',     lftPos+[deltaWidth 0 0 0] ...
                            ,'CData',       UD.images.left_triangle_disabled ...
                            ,'Enable',      'off' ...
                            );
    else
        set(UD.leftScroll,  'Position',     lftPos+[deltaWidth 0 0 0] ...
                            ,'CData',       UD.images.left_triangle ...
                            ,'Enable',      'on' ...
                            );
    end
    
    rightPos = get(UD.rightScroll,'Position');
    if newXlim(2) >=UD.totalAxesWidth
        set(UD.rightScroll, 'Position',     rightPos+[deltaWidth 0 0 0] ...
                            ,'CData',       UD.images.right_triangle_disabled ...
                            ,'Enable',      'off' ...
                            );
    else
        set(UD.rightScroll, 'Position',     rightPos+[deltaWidth 0 0 0] ...
                            ,'CData',       UD.images.right_triangle ...
                            ,'Enable',      'on' ...
                            );
    end



function touch(UD,axesH)
    % 
    % Force a render of the axes
    %
    
    pos = get(axesH,'Position');
    set(axesH,'Position',pos+[1 1 0 0]);
    set(axesH,'Position',pos);
    


function UD = remove_entry(UD,axesH,index)
    
    if (index<1 | index>length(UD.tabentries))
        return;
    end
    
    leftIm = UD.tabentries(index).imageH(1);
    textIm = UD.tabentries(index).imageH(2);
    rightIm = UD.tabentries(index).imageH(3);
    textH = UD.tabentries(index).textH;
    
    deltaX = UD.tabentries(index).textWidth + 2*UD.imBuff;
    
    delete([textH textIm rightIm]);
    UD.tabentries(index) = [];
    
    newActive = [];
    if index <= length(UD.tabentries) % We deleted a middle entry
        for entryIndex=index:length(UD.tabentries)
            txtIm = UD.tabentries(entryIndex).imageH(2);
            rghtIm = UD.tabentries(entryIndex).imageH(3);
            txtH = UD.tabentries(entryIndex).textH;
            
            set(txtIm,'XData',get(txtIm,'XData')-deltaX);
            set(rghtIm,'XData',get(rghtIm,'XData')-deltaX);
            set(txtH,'Position',get(txtH,'Position')-[deltaX 0 0]);
            
        end
        
        if UD.activeIdx == index;
            newActive = index;
        elseif (UD.activeIdx > index)
            newActive = UD.activeIdx-1;
        end
        
        UD.tabentries(index).imageH(1) = leftIm;
        UD.tabBoundaries = [UD.tabBoundaries(1:(index-1)) UD.tabBoundaries((index+1):end)-deltaX];
    else % We deleted the last entry
        if (UD.activeIdx>=index-1) % The new end tab is active
            newActive = index-1;
        else
            set(leftIm,'CData',UD.images.gonly_right_bmp);
        end
        UD.tabBoundaries = UD.tabBoundaries(1:(end-1));
    end
    
    % Adjust the active index
    if ~isempty(newActive)
        UD.activeIdx = -1;
        UD = activate_entry(UD,axesH,newActive,1);
    end
    
    UD.totalAxesWidth = UD.totalAxesWidth - deltaX;
    UD = resize(UD,axesH,0);



function UD = move_tab(UD,axesH,oldIdx,newIdx)

    if oldIdx==newIdx
        return;
    end
    
    % Make sure the old tab is active.
    oldActive = [];
    if oldIdx~=UD.activeIdx
        oldActive = UD.activeIdx;
        UD = activate_entry(UD,axesH,oldIdx,1);
    end
    
    if oldIdx==1
        tabWidth = UD.tabBoundaries(1) - UD.imBuff - 1;
    else
        tabWidth = UD.tabBoundaries(oldIdx) - UD.tabBoundaries(oldIdx-1);
    end
    
    tabCnt = length(UD.tabentries);
    if newIdx>oldIdx
        UD = shift_xpos_tabs(UD,(oldIdx+1):newIdx,-tabWidth);
        UD = shift_xpos_tabs(UD,oldIdx,UD.tabBoundaries(newIdx) - UD.tabBoundaries(oldIdx));
        old2NewIdx = [1:(oldIdx-1)  (oldIdx+1):newIdx oldIdx (newIdx+1):tabCnt];
        
        set(UD.tabentries(oldIdx+1).imageH(3),'CData',UD.images.woverg_left_bmp);
        if newIdx==tabCnt
            % Set the rightmost image
            set(UD.tabentries(oldIdx).imageH(3),'CData',UD.images.wonly_right_bmp);
        end
        
        if oldIdx==1
            % Set the leftmost image
            set(UD.tabentries(oldIdx).imageH(1),'CData',UD.images.gonly_left_bmp);
        else
            set(UD.tabentries(oldIdx).imageH(1),'CData',UD.images.goverg_left_bmp);
        end
    else
        if newIdx==1
            leftShift = UD.tabBoundaries(oldIdx-1) - UD.imBuff - 1;
        else
            leftShift = UD.tabBoundaries(oldIdx-1) - UD.tabBoundaries(newIdx-1);
        end
        UD = shift_xpos_tabs(UD,newIdx:(oldIdx-1),tabWidth);
        UD = shift_xpos_tabs(UD,oldIdx,-leftShift);
        old2NewIdx = [1:(newIdx-1)  oldIdx newIdx:(oldIdx-1)  (oldIdx+1):tabCnt];
        
        if newIdx==1
            % Set the rightmost image
            set(UD.tabentries(1).imageH(1),'CData',UD.images.wonly_left_bmp);
        else
            set(UD.tabentries(newIdx-1).imageH(3),'CData',UD.images.woverg_left_bmp);
        end
        
        if oldIdx==tabCnt
            % Set the leftmost image
            set(UD.tabentries(oldIdx).imageH(3),'CData',UD.images.woverg_right_bmp);
            set(UD.tabentries(oldIdx-1).imageH(3),'CData',UD.images.gonly_right_bmp);
        else
            set(UD.tabentries(oldIdx-1).imageH(3),'CData',UD.images.goverg_right_bmp);
        end


    end            

    leftmostImage = UD.tabentries(1).imageH(1);
    UD.tabentries = UD.tabentries(old2NewIdx);
    
    % Correct the left image handle
    for k=2:tabCnt
        UD.tabentries(k).imageH(1) = UD.tabentries(k-1).imageH(3);
    end
    UD.tabentries(1).imageH(1) = leftmostImage;
    UD.activeIdx = newIdx;
    
    % Correct the tab boundaries
    tabWidths = [UD.tabBoundaries(1)-UD.imBuff-1 diff(UD.tabBoundaries)];
    tabWidths = tabWidths(old2NewIdx);
    UD.tabBoundaries = cumsum(tabWidths)+UD.imBuff+1;
    
function UD = shift_xpos_tabs(UD,Ind,deltaX)

    for k=Ind
        txtIm = UD.tabentries(k).imageH(2);
        rghtIm = UD.tabentries(k).imageH(3);
        txtH = UD.tabentries(k).textH;
        
        set(txtIm,'XData',get(txtIm,'XData')+deltaX);
        set(rghtIm,'XData',get(rghtIm,'XData')+deltaX);
        set(txtH,'Position',get(txtH,'Position')+[deltaX 0 0]);
    end

function UD = activate_entry(UD,axesH,pressedIdx,ignoreCB)

    if nargin<4
        ignoreCB = 0;
    end
    
    if (pressedIdx<1 | pressedIdx>length(UD.tabentries))
        return;
    end
    
    if (UD.activeIdx ==pressedIdx)
        return;
    end
    
    % First de-activate the current active tab
    if(UD.activeIdx>0)
        if (pressedIdx>UD.activeIdx)
            if(UD.activeIdx==1)
                set(UD.tabentries(UD.activeIdx).imageH(1),'CData',UD.images.gonly_left_bmp);
            else
                set(UD.tabentries(UD.activeIdx).imageH(1),'CData',UD.images.goverg_left_bmp);
            end
            set(UD.tabentries(UD.activeIdx).imageH(3),'CData',UD.images.goverg_left_bmp);
        else
            set(UD.tabentries(UD.activeIdx).imageH(1),'CData',UD.images.goverg_right_bmp);
            if(UD.activeIdx==length(UD.tabentries))
                set(UD.tabentries(UD.activeIdx).imageH(3),'CData',UD.images.gonly_right_bmp);
            else
                set(UD.tabentries(UD.activeIdx).imageH(3),'CData',UD.images.goverg_right_bmp);
            end
        end
        centerCdata(:,:,1) = UD.images.gtext_bmp(:,:,1)*ones(round([1,UD.tabentries(UD.activeIdx).textWidth]));
        centerCdata(:,:,2) = UD.images.gtext_bmp(:,:,2)*ones(round([1,UD.tabentries(UD.activeIdx).textWidth]));
        centerCdata(:,:,3) = UD.images.gtext_bmp(:,:,3)*ones(round([1,UD.tabentries(UD.activeIdx).textWidth]));
        set(UD.tabentries(UD.activeIdx).imageH(2),'CData',centerCdata);
        set(UD.tabentries(UD.activeIdx).textH,'FontWeight','Normal');
    end
    
    
    % Activate the new tab
    clear('centerCdata');
    centerCdata(:,:,1) = UD.images.wtext_bmp(:,:,1)*ones(round([1,UD.tabentries(pressedIdx).textWidth]));
    centerCdata(:,:,2) = UD.images.wtext_bmp(:,:,2)*ones(round([1,UD.tabentries(pressedIdx).textWidth]));
    centerCdata(:,:,3) = UD.images.wtext_bmp(:,:,3)*ones(round([1,UD.tabentries(pressedIdx).textWidth]));
    
    if(pressedIdx==1)
        set(UD.tabentries(pressedIdx).imageH(1),'CData',UD.images.wonly_left_bmp);
    else
        set(UD.tabentries(pressedIdx).imageH(1),'CData',UD.images.woverg_left_bmp);
    end
    
    set(UD.tabentries(pressedIdx).imageH(2),'CData',centerCdata);


    if(pressedIdx==length(UD.tabentries))
        set(UD.tabentries(pressedIdx).imageH(3),'CData',UD.images.wonly_right_bmp);
    else
        set(UD.tabentries(pressedIdx).imageH(3),'CData',UD.images.woverg_right_bmp);
    end
    set(UD.tabentries(pressedIdx).textH,'FontWeight','Bold');
    
    UD.activeIdx = pressedIdx;
    
    % Make the tab visible if it is not already
    xlim = get(axesH,'Xlim');
    tabRightLim = UD.tabBoundaries(pressedIdx);
    move = 0;
    if pressedIdx==1
        tabLeftLim = 0.5;
    else
        tabLeftLim = UD.tabBoundaries(pressedIdx-1);
    end
    
    if xlim(1)>tabLeftLim
        move = tabLeftLim - xlim(1); % <0 ==> move left
    else
        if xlim(2)<tabRightLim
            move = min([tabRightLim-xlim(2) tabLeftLim-xlim(1)]);
        end
    end
    if (move~=0)
        set(axesH,'Xlim',xlim+move);
        UD = resize(UD,axesH,0);
    end
        
    
    
    % Callback to the application
    figH = get(axesH,'Parent');
    
    if ~ignoreCB
        sigbuilder('DSChange',figH,[],pressedIdx);
    end


    
function handleStruct = create_selector(figH,origin,width,entryNames,activeIdx,contextMenuH)

    % Layout constants
    buttonWidth = 14;
    axesButtonDelta = 3;
    
    % Load image data
    load('sigbuilder_tab_images');
    imHeight = length(gtext_bmp);

    % Determine pixels to points conversion
    figPosPoints = get(figH,'Position');
    set(figH,'Units','Pixels');
    figPosPixels = get(figH,'Position');
    set(figH,'Units','Points');
    pix2points = figPosPoints(3:4) ./ figPosPixels(3:4);
    axHeight = imHeight*pix2points(2);
    axWidth = width - 2*buttonWidth - axesButtonDelta;
    bgColor = get(figH,'Color');

    axesH = axes( ...
                    'Parent',                   figH ...
                    ,'Units',                   'points' ...
                    ,'Color',                   bgColor ...
                    ,'Box',                     'off' ...
                    ,'Position',                [origin axWidth axHeight] ...
                    ,'XLim',                    [0.5 0.5+axWidth/pix2points(1)] ...
                    ,'XLimMode',                'manual' ...
                    ,'YLim',                    [0.5 imHeight+0.5] ...
                    ,'YLimMode',                'manual' ...
                    ,'XTick',                   [] ...
                    ,'XTickLabel',              '' ...
                    ,'XTickLabelMode',          'manual' ...
                    ,'XTickMode',               'manual' ...
                    ,'YTick',                   [] ...
                    ,'YTickLabel',              '' ...
                    ,'YTickLabelMode',          'manual' ...
                    ,'YTickMode',               'manual' ...
                    ,'XColor',                  bgColor ...
                    ,'YColor',                  bgColor ...
                    ,'Interruptible',           'off' ...
                    ,'ButtonDownFcn',           'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                    ,'HandleVisibility',        'callback' ...
                    ,'Visible',                 'off' ...
                 ); 
    
    % Scroll buttons on right
    uiCurrX = origin(1) + axWidth + axesButtonDelta;
    uiCurrY = origin(2);

    UD.leftScroll = uicontrol('Parent',         figH ...
                    ,'Units',                   'Points' ...
                    ,'Position',                [uiCurrX uiCurrY buttonWidth axHeight] ...
                    ,'UserData',                axesH ...
                    ,'FontWeight',              'bold' ...
                    ,'CData',                   left_triangle_disabled ...
                    ,'Callback',                'sigbuilder_tabselector(''tab_left'');' ...
                    ,'HandleVisibility',        'callback' ...
                    ,'Enable',                  'off' ...
                    );
                    
    UD.rightScroll = uicontrol('Parent',            figH ...
                    ,'Units',                   'Points' ...
                    ,'Position',                [uiCurrX+buttonWidth uiCurrY buttonWidth axHeight] ...
                    ,'UserData',                axesH ...
                    ,'FontWeight',              'bold' ...
                    ,'CData',                   right_triangle_disabled ...
                    ,'Callback',                'sigbuilder_tabselector(''tab_right'');' ...
                    ,'HandleVisibility',        'callback' ...
                    ,'Enable',                  'off' ...
                    );
                    
                    
    handleStruct.axesH = axesH;
    handleStruct.leftScroll = UD.leftScroll;
    handleStruct.rightScroll = UD.rightScroll;
    
    
    currX = 1;
    yPos = 1;
    
    if(activeIdx==1)
    
        dims = size(wonly_left_bmp);
        thisImageWidth = dims(2);
        
        lftIm = image(      'Parent',                   axesH ...
                            ,'XData',                   currX + [0 thisImageWidth-1] ...
                            ,'YData',                   [1 imHeight] ...
                            ,'Interruptible',           'off' ...
                            ,'ButtonDownFcn',           'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                            ,'UIContextMenu',           contextMenuH ...
                            ,'HandleVisibility',        'callback' ...
                            ,'CData',                   wonly_left_bmp ...
                     ); 
        currX = currX + thisImageWidth;
        
    else
        dims = size(gonly_left_bmp);
        thisImageWidth = dims(2);
        
        lftIm = image(  'Parent',                   axesH ...
                        ,'XData',                   currX + [0 thisImageWidth-1] ...
                        ,'YData',                   [1 imHeight] ...
                        ,'Interruptible',           'off' ...
                        ,'ButtonDownFcn',           'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                        ,'UIContextMenu',           contextMenuH ...
                        ,'HandleVisibility',        'callback' ...
                        ,'CData',                   gonly_left_bmp ...
                     ); 
        currX = currX + thisImageWidth;
        
    end
    

    tabBoundaries = [];
        
    for entryIdx = 1:length(entryNames),
        
        textIm = image( 'Parent', axesH, 'Visible','off');

        % Place the text and get its extent
        txtH = text(    'Parent',                       axesH ...
                        ,'Position',                    [currX 1] ...
                        ,'Clipping',                    'on' ...
                        ,'VerticalAlignment',           'bottom' ...
                        ,'Interruptible',               'off' ...
                        ,'ButtonDownFcn',               'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                        ,'String',                      [' ' entryNames{entryIdx} ' '] ...
                        ,'UIContextMenu',               contextMenuH ...
                        ,'FontWeight',                  'Bold' ...
                        ,'HandleVisibility',            'callback' ...
                        ,'Visible',                     'off' ...
                    ); 

        extent = get(txtH,'Extent');
        
        if(entryIdx==activeIdx)
            set(txtH,'Visible','on');
        else
            set(txtH,'FontWeight','Normal','Visible','on');
        end
        
        % Stretch the text image on top of the text
        txtWidth = extent(3);
        
        if exist('imdata')
            clear('imdata');
        end
        
        if (entryIdx==activeIdx)
            imdata(:,:,1) = wtext_bmp(:,:,1) * ones(round([1 txtWidth]));
            imdata(:,:,2) = wtext_bmp(:,:,2) * ones(round([1 txtWidth]));
            imdata(:,:,3) = wtext_bmp(:,:,3) * ones(round([1 txtWidth]));
        else 
            imdata(:,:,1) = gtext_bmp(:,:,1) * ones(round([1 txtWidth]));
            imdata(:,:,2) = gtext_bmp(:,:,2) * ones(round([1 txtWidth]));
            imdata(:,:,3) = gtext_bmp(:,:,3) * ones(round([1 txtWidth]));
        end
        
        
        set( textIm ... 
                    ,'XData',                   currX + [0 txtWidth-1] ...
                    ,'YData',                   [1 imHeight] ...
                    ,'CData',                   imdata ...
                    ,'UIContextMenu',           contextMenuH ...
                    ,'Interruptible',           'off' ...
                    ,'ButtonDownFcn',           'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                    ,'Visible',                 'on' ...
                    ,'HandleVisibility',        'callback' ...
             ); 

        currX = currX + txtWidth;
        %text(txtH)  % Bring to front
        
        if (length(entryNames) > entryIdx)
            if (entryIdx==activeIdx)
                rCdata = woverg_right_bmp;
            elseif (entryIdx+1==activeIdx)
                rCdata = woverg_left_bmp;
            elseif (entryIdx < activeIdx)
                rCdata = goverg_left_bmp;
            else % (entryIdx > activeIdx)
                rCdata = goverg_right_bmp;
            end
        else
            if (entryIdx==activeIdx)
                rCdata = wonly_right_bmp;
            else
                rCdata = gonly_right_bmp;
            end
        end
        
        dims = size(rCdata);
        thisImageWidth = dims(2);

        rightIm = image(    'Parent',                   axesH ...
                            ,'XData',                   currX + [0 thisImageWidth-1] ...
                            ,'YData',                   [1 imHeight] ...
                            ,'Interruptible',           'off' ...
                            ,'ButtonDownFcn',           'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                            ,'UIContextMenu',           contextMenuH ...
                            ,'CData',                   rCdata ...
                     ); 
        tabBoundaries = [tabBoundaries currX+thisImageWidth/2];
        currX = currX + thisImageWidth;

        % Create the userdata entry
        if (entryIdx==1)
            UD.tabentries = struct( 'String',           entryNames{entryIdx} ...
                                    ,'textH',           txtH ...
                                    ,'imageH',          [lftIm textIm rightIm] ...
                                    ,'textWidth',       txtWidth ...
                                   );
        else
            UD.tabentries(end+1) = struct( 'String',            entryNames{entryIdx} ...
                                    ,'textH',           txtH ...
                                    ,'imageH',          [lftIm textIm rightIm] ...
                                    ,'textWidth',       txtWidth ...
                                   );
        end
        
        lftIm = rightIm;  % right button becomes the left of the next tab
    end 

    % Other User Data fields:
    UD.leftMostIdx = 1;
    UD.activeIdx = activeIdx;
    UD.tabBoundaries = tabBoundaries;
    UD.pix2points = pix2points;
    UD.images.woverg_right_bmp = woverg_right_bmp;
    UD.images.woverg_left_bmp = woverg_left_bmp;
    UD.images.goverg_right_bmp = goverg_right_bmp;
    UD.images.goverg_left_bmp = goverg_left_bmp;
    UD.images.wonly_right_bmp = wonly_right_bmp;
    UD.images.wonly_left_bmp = wonly_left_bmp;
    UD.images.gonly_right_bmp = gonly_right_bmp;
    UD.images.gonly_left_bmp = gonly_left_bmp;
    UD.images.gtext_bmp = gtext_bmp;
    UD.images.wtext_bmp = wtext_bmp;
    UD.images.left_triangle = left_triangle;
    UD.images.left_triangle_disabled = left_triangle_disabled;
    UD.images.right_triangle = right_triangle;
    UD.images.right_triangle_disabled = right_triangle_disabled;
    UD.totalAxesWidth = currX;
    UD.imBuff = thisImageWidth/2;
    UD.contextMenuH = contextMenuH;
    
    set(axesH,'Visible','on','UserData',UD);


function UD = add_entry(UD,axesH,labelStr)

    leftIm = UD.tabentries(end).imageH(3);
    
    if(UD.activeIdx == length(UD.tabentries))
        set(leftIm,'Cdata',UD.images.woverg_right_bmp);
    else
        set(leftIm,'Cdata',UD.images.goverg_right_bmp);
    end
    
    currX = UD.totalAxesWidth;
    
    textIm = image( 'Parent', axesH, 'Visible','off');

    % Place the text and get its extent
    txtH = text(    'Parent',                       axesH ...
                    ,'Position',                    [currX 1] ...
                    ,'Clipping',                    'on' ...
                    ,'VerticalAlignment',           'bottom' ...
                    ,'Interruptible',               'off' ...
                    ,'ButtonDownFcn',               'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                    ,'String',                      [' ' labelStr ' '] ...
                    ,'UIContextMenu',               UD.contextMenuH ...
                    ,'FontWeight',                  'Bold' ...
                    ,'Visible',                     'off' ...
                ); 
    
    extent = get(txtH,'Extent');    
    set(txtH,'FontWeight','Normal','Visible','on');

    % Stretch the text image on top of the text
    txtWidth = extent(3);
    
    imdata(:,:,1) = UD.images.gtext_bmp(:,:,1) * ones(round([1 txtWidth]));
    imdata(:,:,2) = UD.images.gtext_bmp(:,:,2) * ones(round([1 txtWidth]));
    imdata(:,:,3) = UD.images.gtext_bmp(:,:,3) * ones(round([1 txtWidth]));
    imdims = size(imdata);
    
    set( textIm ... 
                ,'XData',                   currX + [0 txtWidth-1] ...
                ,'YData',                   [1 imdims(1)] ...
                ,'CData',                   imdata ...
                ,'Visible',                 'on' ...
         ); 
    currX = currX + txtWidth;


    rCdata = UD.images.gonly_right_bmp;
    dims = size(rCdata);
    thisImageWidth = dims(2);

    rightIm = image(    'Parent',                   axesH ...
                        ,'XData',                   currX + [0 thisImageWidth-1] ...
                        ,'YData',                   [1 dims(1)] ...
                        ,'Interruptible',           'off' ...
                        ,'ButtonDownFcn',           'sigbuilder_tabselector(''mouseAction'',''BD'');' ...
                        ,'UIContextMenu',           UD.contextMenuH ...
                        ,'CData',                   rCdata ...
                 ); 
                 
    UD.tabBoundaries = [UD.tabBoundaries currX+thisImageWidth/2];
    currX = currX + thisImageWidth;

    UD.tabentries(end+1) = struct( 'String',            labelStr ...
                            ,'textH',                   txtH ...
                            ,'imageH',                  [leftIm textIm rightIm] ...
                            ,'textWidth',               txtWidth ...
                           );
    
    UD.totalAxesWidth = currX;
    UD = resize(UD,axesH,0);



function UD = rename_entry(UD,axesH,tabIdx,labelStr)

    textH = UD.tabentries(tabIdx).textH;
    textIm = UD.tabentries(tabIdx).imageH(2);
    rightIm = UD.tabentries(tabIdx).imageH(3);
    oldtxtWidth = UD.tabentries(tabIdx).textWidth;

    set(textH,'Visible','off','FontWeight','Bold','String',[' ' labelStr ' ']);
    extent = get(textH,'Extent');   
    newWidth = extent(3);
    UD.tabentries(tabIdx).textWidth = newWidth;
    deltaWidth = newWidth - oldtxtWidth;
    
    % Compute new CData for text image
    if tabIdx==UD.activeIdx
        imdata(:,:,1) = UD.images.wtext_bmp(:,:,1) * ones(round([1 newWidth]));
        imdata(:,:,2) = UD.images.wtext_bmp(:,:,2) * ones(round([1 newWidth]));
        imdata(:,:,3) = UD.images.wtext_bmp(:,:,3) * ones(round([1 newWidth]));
        set(textH,'Visible','on');
    else
        imdata(:,:,1) = UD.images.gtext_bmp(:,:,1) * ones(round([1 newWidth]));
        imdata(:,:,2) = UD.images.gtext_bmp(:,:,2) * ones(round([1 newWidth]));
        imdata(:,:,3) = UD.images.gtext_bmp(:,:,3) * ones(round([1 newWidth]));
        set(textH,'Visible','on','FontWeight','Normal');
    end
    oldImXdata = get(textIm,'XData');
    
    set( textIm ,'CData',imdata,'Visible','on','XData',oldImXdata+[0 deltaWidth]); 
    set(rightIm,'XData',get(rightIm,'XData')+deltaWidth);
    

    if tabIdx <= length(UD.tabentries) % We deleted a middle entry
        for entryIndex=(tabIdx+1):length(UD.tabentries)
            txtIm = UD.tabentries(entryIndex).imageH(2);
            rghtIm = UD.tabentries(entryIndex).imageH(3);
            txtH = UD.tabentries(entryIndex).textH;
            
            set(txtIm,'XData',get(txtIm,'XData')+deltaWidth);
            set(rghtIm,'XData',get(rghtIm,'XData')+deltaWidth);
            set(txtH,'Position',get(txtH,'Position')+[deltaWidth 0 0]);
        end

    end

    UD.totalAxesWidth = UD.totalAxesWidth + deltaWidth;
    UD.tabBoundaries = [UD.tabBoundaries(1:(tabIdx-1)) UD.tabBoundaries((tabIdx):end)+deltaWidth];
    UD = resize(UD,axesH,0);
