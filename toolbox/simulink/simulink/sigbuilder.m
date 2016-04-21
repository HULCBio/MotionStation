function varargout = sigbuilder(method,varargin)
%SIGBUILDER - Graphical signal editing tool
%
% Selecting Signals, Points and Segments:
%
% Signals are selected at mouse button down time.  The selected signal
% is indicated with diamond shape markers at each of the breakpoints.
% Once a signal has been selected a breakpoint can be selected by
% clicking on a marker and a segment can be  selected by clicking between 
% markers.  Point and segment coordinates can be specified numerically
% in the adjust fields.
%
% Adjusting point and segment coordinates:
%
% Signals are edited by dragging points or segments to new values
% Breakpoint Y value can be adjusted are adjusted by dragging with the left 
% mouse button. If the shift key is depressed before dragging, the breakpoint 
% time value will be adjusted.  Vertical segments (discontinuities in time) 
% are adjusted along the time axis and segments that span a time interval 
% are adjusted along the Y axis.  
%
% Changing grid settings:
%
% Coordinates can be constrained to grid lines on the time and/or Y axis.
% Grid settings are property of the signal and can be modified from the
% signal Context menu or the Signal menu .
% 
% Adding points
%
% Breakpoints are added to a signal by single clicking on the signal while 
% depressing the shift key.  

%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 1.26.4.13 $  $Date: 2004/04/15 00:49:05 $


extra_args = {};
switch(nargin)
    case 0
        error('The signal builder block should be copied from the Simulink library');
        method = 'Create';
        dialog = [];
        UD = [];
    case 1
        % The input could be a file or a method
        if any(method=='.')
            fileName = method;
            method = 'open_existing_file';
            dialog = [];
            UD = [];
        else
            dialog = gcbf;
            UD = get(dialog,'UserData');
        end
    case 2
        dialog = varargin{1};
        UD = get(dialog,'UserData');
    otherwise,
        dialog = varargin{1};
        UD = varargin{2};
        extra_args = varargin(3:end);
end

switch(method)

    case 'apicall'
        varargout = cell(1,nargout);
        [varargout{:}] = apicall(varargin{:});
        
    case 'Create'
        dialog = create(dialog,UD,extra_args{:});
        
        % Choose a starting file name
        UD = get(dialog,'UserData');
        UD = reset_dirty_flag(UD);
        set(dialog,'UserData',UD);

        if is_simulating_l(UD), UD = enter_iced_state_l(UD); end;

    case 'tuVar'
        blockH = dialog;
        modelH = UD;
        dialogH = get_param(blockH,'UserData');
        if ~isempty(dialogH) & ishandle(dialogH)
            UD = get(dialogH,'UserData');
            varargout{1} = create_sl_input_variable(UD,UD.simulink.fromWsH);
        else
            varargout{1} = init_tu_var(blockH);
        end

    case 'cmdApi'
        % sigbuilder('cmdApi', 'create', method, time, data, sigLabels, groupLabels)
        subMethod = varargin{1};
        varargout = cell(1,nargout);
        extra_args = varargin(2:end);
        [varargout{:}] = cmdApi(subMethod, extra_args{:});
        
    case 'assertApi'
        % sigbuilder('assertApi',blockH,'method',  extraArgs )
        blockH = dialog;
        subMethod = UD;
        varargout = cell(1,nargout);
        [varargout{:}] = assert_api(subMethod, blockH, varargin(3:end));
        
    case 'writeToSl'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = save_session(UD);
        set(dialog,'UserData',UD);

        if vnv_enabled && isfield(UD,'verify') && isfield(UD.verify,'jVerifyPanel') && ...
            ~isempty(UD.verify.jVerifyPanel)
                vnv_panel_mgr('sbClosePanel',UD.simulink.subsysH,UD.verify.jVerifyPanel);
        end
    

    case 'SlBlockOpen'
        % sigbuilder('SlBlockOpen',handleStruct);
        handleStruct = dialog;

        dialog = create(1);
        UD = get(dialog,'UserData');
        UD = load_session(UD,handleStruct.subsysH);
        UD.simulink = handleStruct;
        update_titleStr(UD);
        set(dialog,'UserData',UD);
        enable_mouse_callback(UD);
        varargout{1} = dialog;

        if is_simulating_l(UD), UD = enter_iced_state_l(UD); end;

	case 'slBlockRename'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
		update_titleStr(UD);
		UD = set_dirty_flag(UD);
		
	case 'sim_start',
        UD = enter_iced_state_l(UD);
	    hgObjs = [UD.toolbar.stop UD.toolbar.pause];
	    set(hgObjs,'Enable','on');
	    set(UD.toolbar.start,'Enable','off');
	    set(UD.dialog,'Pointer','arrow');
	    
	case 'sim_stop'
        UD = enter_idle_state_l(UD);
	    hgObjs = [UD.toolbar.stop UD.toolbar.pause];
	    set(hgObjs,'Enable','off');
	    set(UD.toolbar.start,'Enable','on');
	    if strcmp(UD.current.simMode,'PlayAll')
	        simTime = get_param(UD.simulink.modelH,'SimulationTime');
	        stopTime = str2num(get_param(UD.simulink.modelH,'StopTime'));
	        if (simTime < stopTime)
	            UD.current.simWasStopped = 1;
                set(dialog,'UserData',UD);
            end
	    end
	
    case 'open_existing_file'
        dialog = create(dialog,UD,extra_args{:});
        UD = get(dialog,'UserData');
        UD = load_session(UD,fileName);
        set(dialog,'UserData',UD);

        if is_simulating_l(UD), UD = enter_iced_state_l(UD); end;

    case 'NewChannel'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        
        % DROP the event if the UI is iced!
        if ~in_iced_state_l(UD),
        	UD = new_channel(dialog,UD,extra_args{:});
        end;
        set(dialog,'UserData',UD);
        
    case 'NewAxis'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = new_axes(UD,extra_args{:});
        set(dialog,'UserData',UD);

    case 'close'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        close_internal(UD);

    case 'DSChange'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = dataSet_activate(UD,extra_args{:});
        set(dialog,'UserData',UD);

    case 'ButtonDown'
        [UD,modified] = mouse_handler('ButtonDown',dialog,UD,extra_args{:});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'ButtonUp'
        [UD,modified] = mouse_handler('ButtonUp',dialog,UD,extra_args{:});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'ButtonMotion'
        [UD,modified] = mouse_handler('ButtonMotion',dialog,UD,extra_args{:});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'KeyPress'
        [UD,modified] = mouse_handler('KeyPress',dialog,UD,extra_args{:});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'Toolbar'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        [UD,modified] = toolbar_handler(extra_args{1},dialog,UD);
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'chContext'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        [UD,modified] = channel_handler(extra_args{1},dialog,UD,extra_args{2:end});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'chanUi'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        
        if ~in_iced_state_l(UD), 
        	[UD,modified] = channel_ui_handler(extra_args{1},dialog,UD,extra_args{2:end});
        	if modified
            	set(dialog,'UserData',UD);
        	end
        end;
            
    case 'timeUi'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        [UD,modified] = time_ui_handler(extra_args{1},dialog,UD,extra_args{2:end});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'trange'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = set_new_time_range(UD,extra_args{1});
        set(dialog,'UserData',UD);
            
    case 'axesContext'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        [UD,modified] = axes_context_handler(extra_args{1},dialog,UD,extra_args{2:end});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'Resize'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = resize(UD);
        set(dialog,'UserData',UD);

    case 'YeditBox'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = apply_new_point_value(UD,'Yvalue');
        set(dialog,'UserData',UD);
            
    case 'XeditBox'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = apply_new_point_value(UD,'Xvalue');
        set(dialog,'UserData',UD);
            
    case 'Scrollbar'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = scrollbar_handler(UD);
        set(dialog,'UserData',UD);
            
    case 'FigMenu'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        [UD,modified] = fig_menu_handler(extra_args{1},dialog,UD,extra_args{2:end});
        if modified
            set(dialog,'UserData',UD);
        end
            
    case 'ChanListbox'
        if isempty(UD)
            UD = get(dialog,'UserData');
        end
        UD = chan_listbox_mgr(UD);
        set(dialog,'UserData',UD);
            
    
    otherwise,
        error('Unkown Method');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                         FIGURE LAYOUT FUNCTIONS                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FIGURE_LAYOUT_FUNCTIONS   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE - Create the editor figure
% 
function dialog = create(varargin)

    persistent stvbmp;
    
    if nargin>0 & ~isempty(varargin{1})
        keep_hidden = varargin{1};
    else
        keep_hidden = 0;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Default values for user data structures
    geomConst.scrollHieght = 15;            
    geomConst.axesVdelta = 4;           
    geomConst.figBuffer = 8;
    geomConst.smallFigBuff = 3;
    geomConst.bevelBuff = 1.5;

    if (ispc)
        geomConst.bevelBevelDelta = 1.5;
        geomConst.wideBevelBevelDelta = 0.75;
        geomConst.bevelFigDelta = 0;
        geomConst.bevelInset = 8;
        geomConst.bevelSelectorDelta = 1.5;
        geomConst.bevelDelta = 0;
        geomConst.bevelOff = 3;
    else
        geomConst.bevelBevelDelta = 1.5;
        geomConst.wideBevelBevelDelta =0.75;
        geomConst.bevelFigDelta = 0.75;
        geomConst.bevelInset = 8;
        geomConst.bevelSelectorDelta = 1.5;
        geomConst.bevelDelta = 0.75;
        geomConst.bevelOff = 3;
    end

    geomConst.legdBorder = 4;     
    geomConst.msgWdth = 210;     
    geomConst.objVdelta = 6;
    geomConst.objHdelta = 6;
    geomConst.smallVdelta = 2;
    geomConst.smallHdelta = 3;
    geomConst.verySmallHdelta = 1.5;
    geomConst.numDispExt = [60 14];
    geomConst.numEntryExt = [45 14];
    geomConst.intPopupExt = [30 14];
    geomConst.popupYoff = 1.5;
    geomConst.numDispVDelta = 2;
    geomConst.lineDispWidth = 15;
    geomConst.legdEntryVDelta = 6;
    geomConst.legdEntryHDelta = 4;
    geomConst.legdlineVsep = 4;
    geomConst.axes2tabBuff = 20;         
    geomConst.axesOffset = [20 20];         
    geomConst.singleClickThresh = 3;            
    geomConst.staticTextH = 12;         
    
    axesEnty = struct(  'handle',           {}, ...
                        'numChannels',      {}, ...
                        'channels',         {}, ...
                        'vertProportion',   {});

    adjust.XDisp = [];
    adjust.YDisp = [];

    current.verifyWidth = 160;
    current.state = 'IDLE';
    current.mode = 1;       
    current.channel = 0;    
    current.axes = 0;       
    current.editPoints = [];
    current.tempPoints = [];
    current.bdPoint = [0 0];
    current.bdObj = [];     
    current.prevbdObj = [];     
    current.selectLine = [];        
    current.figPos = [50 50 520 400];
    current.zoomStart = [];     
    current.zoomAxesInd = [];           
    current.zoomXLine = [];         
    current.zoomYLine = [];
    current.lockOutSingleClick = 0;         
    current.dataSetIdx = 1;
    current.simMode = [];
    current.simWasStopped = 0;
    current.isVerificationVisible = 0;
    buff =  geomConst.figBuffer;    
    legdWidth =  2*(geomConst.legdBorder + geomConst.numDispExt(1)) ...
                   + geomConst.legdEntryHDelta;

    current.axesExtent = [buff buff current.figPos(3:4)-2*buff] - ...
                        [0 0 legdWidth+geomConst.objHdelta geomConst.scrollHieght+geomConst.axesVdelta];
    current.gridSetting = 'on';

    figbgcolor = [1 1 1]*0.8;
    dialog = figure('Name',                 'Signal Builder', ...
                    'NumberTitle',          'off', ...
                    'MenuBar',              'none', ...
                    'Color',                figbgcolor, ...
                    'DoubleBuffer',         'on', ...
                    'Units',                'points', ...
                    'HandleVisibility',     'callback', ...
                    'Interruptible',        'off', ...
                    'IntegerHandle',        'off', ...
                    'Visible',        		'off', ...
                    'Position',             current.figPos);

    %
    % Create a text object for text sizing.
    %
    
    UD.textExtent = uicontrol( ...
        'Units',     'points', ...
        'Parent',     dialog, ...
        'Visible',    'off', ...
        'Style',      'text', ...
        'String',     'abcdefghijklABCDEFG' ...
        );
    
    %
    % Correct the uicontrol heights based on text size
    %
    txtExt = get(UD.textExtent,'Extent');
    if(ispc)
        txtDispHeight = 1.15*txtExt(4);
        geomConst.staticTextH = txtExt(4);         

    else
        txtDispHeight = txtExt(4);
        geomConst.staticTextH = txtExt(4);
    end
    
    geomConst.numDispExt = [60 txtDispHeight];
    geomConst.numEntryExt = [45 txtDispHeight];
    geomConst.intPopupExt = [45 txtDispHeight];



    % tabpageH = uicontrol('Parent',dialog,'Position',[0 0 10 10],'style','frame');
    dataSet = dataSet_data_struct;    


    % Build the userData
    UD.adjust = adjust;
    UD.dialog = dialog;
    UD.current = current;
    UD.numChannels = 0;
    UD.numAxes = 0;
    UD.geomConst = geomConst;
    UD.dataSet = dataSet;
    
    load('sigbuilder_pointer_images');
    UD.pointerdata = pointerdata;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the message text
    currX = geomConst.smallFigBuff;
    msgPos = [currX 0.5*geomConst.smallVdelta geomConst.msgWdth geomConst.staticTextH];

    UD.hgCtrls.status.msgText = uicontrol(   'Parent',                   UD.dialog,...
                                    'Units',                    'points', ...
                                    'BackgroundColor',          figbgcolor,...
                                    'Position',                 msgPos, ...
                                    'String',                   'ok', ...
                                    'HorizontalAlignment',      'left', ...
                                    'FontWeight',               'normal', ...
                                    'Style',                    'text', ...
                                    'handlevisibility',         'callback');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the selection text and frame
    currX = currX + geomConst.msgWdth + geomConst.bevelFigDelta;
%    frameWidth = current.figPos(3) - currX  - geomConst.bevelBuff;
%    frameHeight = geomConst.staticTextH + 2*geomConst.bevelOff;
%    selectFramePos = [currX geomConst.bevelBuff frameWidth frameHeight];
    frameWidth = current.figPos(3) - currX - geomConst.bevelFigDelta;
    frameHeight = geomConst.staticTextH + geomConst.smallVdelta;
    selectFramePos = [currX geomConst.bevelFigDelta frameWidth frameHeight];
    selectTxtPos = [selectFramePos(1:3)+[1 0 0]*geomConst.bevelOff+[0 .5 -.5]*geomConst.smallVdelta, geomConst.staticTextH];
    
    UD.hgCtrls.status.selText = uicontrol( ...
                                'parent',                   UD.dialog,...
                                'Units',                    'points', ...
                                'BackgroundColor',          figbgcolor,...
                                'Position',                 selectTxtPos, ...
                                'String',                   '', ...
                                'HorizontalAlignment',      'left', ...
                                'FontWeight',               'normal', ...
                                'Style',                    'text', ...
                                'handlevisibility',         'callback');
    UD.hgCtrls.status.selFrame = sigbuilder_beveled_frame(UD.dialog, selectFramePos);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the channel controls and frame
    currY = geomConst.bevelFigDelta + frameHeight + geomConst.bevelBevelDelta;
    currX = geomConst.bevelFigDelta;

    currOrg = [currX currY]+geomConst.bevelInset;
    [UD.hgCtrls.chDispProp,groupExtent] = create_channel_disp_controls(UD,currOrg,[],[]);
    controlsHeight = groupExtent(2)+2*geomConst.bevelOff;

    currOrg = currOrg + [groupExtent(1)+geomConst.bevelInset 0];
    [UD.hgCtrls.chLeftPoint,groupExtent] = create_channel_point_disp(UD,currOrg,[],[],'Left Point');

    currOrg = currOrg + [groupExtent(1)+geomConst.bevelInset 0];
    [UD.hgCtrls.chRightPoint,groupExtent] = create_channel_point_disp(UD,currOrg,[],[],'Right Point');
    

    controlsWidth = current.figPos(3) - currX - geomConst.bevelFigDelta;
    controlsOrigin = [currX currY];

    currOrg = currOrg + [groupExtent(1)+2*geomConst.bevelInset 0];
    lboxWidth = controlsWidth - currOrg(1) - geomConst.bevelFigDelta;
    lboxHeight = controlsHeight -2*geomConst.bevelFigDelta;
    
    listBoxToolTip = 'All signals, double-click to toggle visibility';

    UD.hgCtrls.chanListbox = uicontrol(  'Parent',                   dialog,...
                                    'Units',                    'points', ...
                                    'Position',                 [currOrg(1) currY-0.75 lboxWidth lboxHeight], ...
                                    'Style',                    'listbox', ...
                                    'FontName',                  'FixedWidth', ...
                                    'BackgroundColor',          'w', ...
                                    'Callback',                 'sigbuilder(''ChanListbox'',gcbf,[]);', ...
                                    'Enable',                   'on', ...
                                    'Visible',                   'on', ...
                                    'HorizontalAlignment',      'left', ...
                                    'Tooltipstring',            listBoxToolTip, ...
                                    'handlevisibility',         'callback');

    % Add the scrollbar
    currY = currY + controlsHeight + geomConst.objVdelta;
    currX = geomConst.bevelInset+geomConst.axesOffset(1);
    width = current.figPos(3)- currX - geomConst.bevelInset;
    scrollPos = [   currX, ... 
                    currY , ...
                    width, ...
                    geomConst.scrollHieght];
                    
    tlegend.scrollbar = uicontrol(  'Parent',                   dialog,...
                                    'Units',                    'points', ...
                                    'Position',                 scrollPos, ...
                                    'Style',                    'slider', ...
                                    'BackgroundColor',          figbgcolor, ...
                                    'Callback',                 'sigbuilder(''Scrollbar'',gcbf,[]);', ...
                                    'Enable',                   'off', ...
                                    'Visible',                   'off', ...
                                    'HorizontalAlignment',      'left', ...
                                    'handlevisibility',         'callback');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate the axes drawing rectangle
    %currY = currY + geomConst.scrollHieght + geomConst.figBuffer;
    currY = currY + geomConst.figBuffer;
    UD.current.axesExtent = [   geomConst.figBuffer, ...
                                currY, ...
                                current.figPos(3)-2*geomConst.figBuffer, ...
                                current.figPos(4)-currY-geomConst.figBuffer];        


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the tab context menu:
    tabMenuTable = ...
    {'Rename',              'sigbuilder(''FigMenu'',gcbf,[],''dataSetRename'');',         'rename',  
     'Copy',                'sigbuilder(''FigMenu'',gcbf,[],''dataSetCopy'');',           'copy',  
     'Delete',              'sigbuilder(''FigMenu'',gcbf,[],''dataSetDelete'');',         'delete',
     'Move Right',          'sigbuilder(''FigMenu'',gcbf,[],''dataSetRight'');',          'right',
     'Move Left',           'sigbuilder(''FigMenu'',gcbf,[],''dataSetLeft'');',           'left'};  
    topHandle = uicontextmenu('Parent',dialog);
    tabContext = sigbuilder_makemenu(topHandle,char(tabMenuTable(:,1)),char(tabMenuTable(:,2)),char(tabMenuTable(:,3)));
    tabContext.handle = topHandle;
    set(tabContext.delete,'Enable','off');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tabselector
    estHeight = 18;
    currY = current.figPos(4) - geomConst.figBuffer - estHeight;
    currX = geomConst.bevelBevelDelta;
    UD.hgCtrls.tabselect = sigbuilder_tabselector( 'create', ...
                                        dialog, ...
                                        [currX currY], ...
                                        current.figPos(3)-currX - geomConst.bevelBevelDelta, ...
                                        {UD.dataSet.name},1,tabContext.handle);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine height adjustment
    tabExt = get(UD.hgCtrls.tabselect.axesH,'Position');
    hDelta = tabExt(4)-estHeight;
    adjust_y_coord([UD.hgCtrls.tabselect.axesH UD.hgCtrls.tabselect.leftScroll ...
                    UD.hgCtrls.tabselect.rightScroll],-hDelta);
    bottomOfTabSelector = currY-hDelta;
    
    tabHeight = bottomOfTabSelector - controlsOrigin(2) - geomConst.bevelSelectorDelta - ...
                geomConst.wideBevelBevelDelta +0.75;

    UD.hgCtrls.chFrame = sigbuilder_beveled_frame(UD.dialog, [controlsOrigin controlsWidth tabHeight],'WideTrans');
    tabFramePos(1) = controlsOrigin(1);
    tabFramePos(2) = controlsOrigin(2)+tabHeight+geomConst.wideBevelBevelDelta;
    tabFramePos(3) = controlsWidth;
    tabFramePos(4) = current.figPos(4)-tabFramePos(2)-geomConst.bevelFigDelta;
                
    UD.hgCtrls.tabFrame = sigbuilder_beveled_frame(UD.dialog, tabFramePos,'NarrowTrans');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reduce the axes drawing area by the
    % height ot the tab selector and a delta
    UD.current.axesExtent(4) = UD.current.axesExtent(4) - tabExt(4)- geomConst.axes2tabBuff;
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Install callbacks
    set(UD.hgCtrls.chLeftPoint.xNumDisp , ...
        'Callback',  'sigbuilder(''chanUi'',gcbf,[],''leftX'');');

    set(UD.hgCtrls.chLeftPoint.yNumDisp , ...
        'Callback',  'sigbuilder(''chanUi'',gcbf,[],''leftY'');');

    set(UD.hgCtrls.chRightPoint.xNumDisp , ...
        'Callback',  'sigbuilder(''chanUi'',gcbf,[],''rightX'');');

    set(UD.hgCtrls.chRightPoint.yNumDisp , ...
        'Callback',  'sigbuilder(''chanUi'',gcbf,[],''rightY'');');

    set(UD.hgCtrls.chDispProp.labelEdit , ...
        'Callback',  'sigbuilder(''chanUi'',gcbf,[],''label'');');

    set(UD.hgCtrls.chDispProp.indexPopup , ...
        'Callback',  'sigbuilder(''chanUi'',gcbf,[],''index'');');


    % Add the main menu
    menuTable = ...
    {...
'&File',                    ' ',                                                    'file',
'>&Open^o',                 'sigbuilder(''FigMenu'',gcbf,[],''open'');',            'open',
'>&Save^s',                 'sigbuilder(''FigMenu'',gcbf,[],''save'');',            'save',
'>Save &as ...',            'sigbuilder(''FigMenu'',gcbf,[],''saveas'');',          'saveas',
'>---',                    ' ',                                                    '',
'>&Export to workspace ...','sigbuilder(''FigMenu'',gcbf,[],''export_ws'');',       'exportWs', 
'>Simulation o&ptions ...', 'sigbuilder(''FigMenu'',gcbf,[],''simOpts'');',         'slBlock',
'>---',                    ' ',                                                    '',
'>&Close^w',                'sigbuilder(''close'',gcbf,[]);',                       'close',
'&Edit',                    ' ',                                                   'edit',
'>&Undo^z',                 'sigbuilder(''FigMenu'',gcbf,[],''undo'');',            'undo',
'>&Redo^y',                 'sigbuilder(''FigMenu'',gcbf,[],''redo'');',            'redo',
'>---',                    ' ',                                                    '',
'>Cu&t^x',                  'sigbuilder(''FigMenu'',gcbf,[],''cut'');',             'cut',
'>&Copy^c',                 'sigbuilder(''FigMenu'',gcbf,[],''copy'');',            'copy',
'>&Paste^v',                'sigbuilder(''FigMenu'',gcbf,[],''paste'');',           'paste',
'>&Delete',                 'sigbuilder(''FigMenu'',gcbf,[],''delete'');',          'delete',
'&Group',                     ' ',                                                    'tab',
'>&Rename...',              'sigbuilder(''FigMenu'',gcbf,[],''dataSetRename'');',   'tabrename',  
'>&Copy',                   'sigbuilder(''FigMenu'',gcbf,[],''dataSetCopy'');',     'tabcopy',
'>&Delete',                 'sigbuilder(''FigMenu'',gcbf,[],''dataSetDelete'');',   'tabdelete',
'>---',                    ' ',                                                    '',
'>&Verification settings...', 'sigbuilder(''FigMenu'',gcbf,[],''verification'');',   'verification',  
'>---',                    ' ',                                                    '',
'>Move righ&t',             'sigbuilder(''FigMenu'',gcbf,[],''dataSetRight'');',    'tabMoveRight',
'>Move &left',              'sigbuilder(''FigMenu'',gcbf,[],''dataSetLeft'');',     'tabMoveLeft',
'&Signal',                  ' ',                                                    'signal',
'>&New',                    ' ',                                                    'new',
'>>Constant',              'sigbuilder(''FigMenu'',gcbf,[],''constant'',1);',      'constant_n', 
'>>Step',                  'sigbuilder(''FigMenu'',gcbf,[],''step'',1);',          'step_n',
'>>Pulse',                 'sigbuilder(''FigMenu'',gcbf,[],''pulse'',1);',         'pulse_n',
'>>---',                   ' ',                                                    '',
'>>Square...',             'sigbuilder(''FigMenu'',gcbf,[],''square'',1);',        'square_n',
'>>Triangle...',           'sigbuilder(''FigMenu'',gcbf,[],''triangle'',1);',      'triangle_n',
'>>Sampled sin...',        'sigbuilder(''FigMenu'',gcbf,[],''sampled_sin'',1);',   'sin_n',
'>>---',                   ' ',                                                    '',
'>>Sampled Gaussian noise...','sigbuilder(''FigMenu'',gcbf,[],''gausian_noise'',1);','gaussian_n',
'>>Pseudorandom noise...','sigbuilder(''FigMenu'',gcbf,[],''binary_noise'',1);',  'prbn_n',
'>>Poisson random noise...','sigbuilder(''FigMenu'',gcbf,[],''poison_noise'',1);',  'poisson_n',
'>>---',                   ' ',                                                    '',
'>>Custom...',             'sigbuilder(''FigMenu'',gcbf,[],''import'',1);',        'import_n',
'>&Show',                   ' ',                                                    'show',
'>---',                    ' ',                                                    '',
'>---',                    ' ',                                                    '',
'>&Hide',                   'sigbuilder(''chContext'',gcbf,[],''sighide'');',       'sighide',
'>&Rename...',              'sigbuilder(''chContext'',gcbf,[],''sigrename'');',     'sigrename',
'>Replace &with',           ' ',                                                    'replace',
'>>Constant',              'sigbuilder(''FigMenu'',gcbf,[],''constant'',0);',      'constant_r', 
'>>Step',                  'sigbuilder(''FigMenu'',gcbf,[],''step'',0);',          'step_r',
'>>Pulse',                 'sigbuilder(''FigMenu'',gcbf,[],''pulse'',0);',         'pulse_r',
'>>---',                   ' ',                                                    '',
'>>Square...',             'sigbuilder(''FigMenu'',gcbf,[],''square'',0);',        'square_r',
'>>Triangle...',           'sigbuilder(''FigMenu'',gcbf,[],''triangle'',0);',      'triangle_r',
'>>Sampled sin...',        'sigbuilder(''FigMenu'',gcbf,[],''sampled_sin'',0);',   'sin_r',
'>>---',                   ' ',                                                    '',
'>>Sampled Gaussian noise...','sigbuilder(''FigMenu'',gcbf,[],''gausian_noise'',0);','gaussian_r',
'>>Pseudorandom noise...','sigbuilder(''FigMenu'',gcbf,[],''binary_noise'',0);',  'prbn_r',
'>>Poisson random noise...','sigbuilder(''FigMenu'',gcbf,[],''poison_noise'',0);',  'poisson_r',
'>>---',                   ' ',                                                    '',
'>>Custom...',             'sigbuilder(''FigMenu'',gcbf,[],''import'',0);',        'import_r',
'>---',                    ' ',                                                    '',
'>&Color...',               'sigbuilder(''chContext'',gcbf,[],''setColor'');',      'color',
'>Line s&tyle',             ' ',                                                    'lineStyle',
'>>Solid',     'sigbuilder(''FigMenu'',gcbf,[],''chanLineStyle'',''solid'');',     'solid',
'>>Dashed',    'sigbuilder(''FigMenu'',gcbf,[],''chanLineStyle'',''dashed'');',    'dashed',
'>>Dotted',    'sigbuilder(''FigMenu'',gcbf,[],''chanLineStyle'',''dotted'');',    'dotted',
'>>Dashed-dotted','sigbuilder(''FigMenu'',gcbf,[],''chanLineStyle'',''dash-dott'');',  'dashdott',
'>Line wi&dth...', 'sigbuilder(''FigMenu'',gcbf,[],''chanLineWidth'');',               'lineWidth',
'>---',                    ' '                                                     '',
'>Change &index...',        'sigbuilder(''FigMenu'',gcbf,[],''chanIndex'');',       'chanIndex',
'&Axes',                    ' ',                                                    'axes',
'>Change &time range...',   'sigbuilder(''FigMenu'',gcbf,[],''setTrange'');',       'setTrange',
'>---',                    ' ',                                                    '',
'>Set Y snap grid',        ' ',                                                    'ysnap',
'>Set T snap grid',        ' ',                                                    'tsnap',
'>---',                    ' ',                                                    '',
'>Set Y display limits...','sigbuilder(''axesContext'',gcbf,[],''setYrange'');',   'ydisprange',
'>Set T display limits...','sigbuilder(''axesContext'',gcbf,[],''tdisprange'');',  'tdisprange',
'&Help',                    ' ',                                                    'help',
'>Helpdesk',               'helpdesk',                                             'helpdesk'
'>---',                    ' ',                                                    '',
'>Simulink help',          'doc(''simulink/'');',                                  'slhelp'
'>Simulink demos',         'demo(''simulink'');',                                  'sldemos'
'>---',                    ' ',                                                    '',
'>Signal Builder',          'helpwin(''sigbuilder'');',                             'helpintro' ...
};


    figmenu = sigbuilder_makemenu(dialog,char(menuTable(:,1)),char(menuTable(:,2)),char(menuTable(:,3)));

    set( figmenu.undo,'Enable','off');
    set( figmenu.redo,'Enable','off');

    if ~figure_has_java(dialog) || ~vnv_enabled
        set(figmenu.verification,'Enable','off');
    end

    % Add submenus for selecting Y grid and T grid steps
    figmenu.setStepX.children = add_submenu_number_selection( ...
                                        figmenu.tsnap, ...
                                        'sigbuilder(''chContext'',gcbf,[],''setStepX''', ...
                                        [0 .001 .002 .005 .01 .02 .05 .1 .2 .5 1 2 5]);

    figmenu.setStepY.children = add_submenu_number_selection( ...
                                        figmenu.ysnap, ...
                                        'sigbuilder(''chContext'',gcbf,[],''setStepY''', ...
                                        [0 .01 .02 .05 .1 .2 .5 1 2 5 10 20 50 100]);



    figmenu.channelEnabled = [figmenu.cut figmenu.copy figmenu.delete];
    set([figmenu.paste figmenu.channelEnabled],'Enable','off');

    % Add the toolbar
    if isempty(stvbmp)
        load('sigbuilder_images');
    end
    ut=uitoolbar(dialog);

    
    toolbar.open = uipushtool('cdata',       stvbmp.open_btn, ...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''FigMenu'',gcbf,[],''open'')' ,...
                                 'tooltipstring',   'Open model');

    toolbar.save = uipushtool('cdata',       stvbmp.save, ...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''FigMenu'',gcbf,[],''save'')' ,...
                                 'tooltipstring',   'Save model');


    toolbar.cut = uipushtool('cdata',       stvbmp.cut_btn, ...
                                 'Enable',          'off',...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''FigMenu'',gcbf,[],''cut'')' ,...
                                 'tooltipstring',   'Cut signal');
    toolbar.copy = uipushtool('cdata',       stvbmp.copy_btn, ...
                                 'Enable',          'off',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''FigMenu'',gcbf,[],''copy'')' ,...
                                 'tooltipstring',   'Copy signal');
    toolbar.paste = uipushtool('cdata',       stvbmp.paste_btn,...
                                 'Enable',          'off',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''FigMenu'',gcbf,[],''paste'')' ,...
                                 'tooltipstring',   'Paste signal');

    toolbar.undo = uipushtool('cdata',       stvbmp.undo_btn, ...
                                 'Enable',          'off',...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''FigMenu'',gcbf,[],''undo'')' ,...
                                 'tooltipstring',   'Undo last edit');
    toolbar.redo = uipushtool('cdata',       stvbmp.redo_btn, ...
                                 'Enable',          'off',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''FigMenu'',gcbf,[],''redo'')' ,...
                                 'tooltipstring',   'Redo last edit');

    toolbar.constantSig = uipushtool('cdata',       stvbmp.constantSig,...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'Interruptible',   'off', ...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''constantSig'')' ,...
                                 'tooltipstring',   'Add a constant signal');

    toolbar.stepSig = uipushtool('cdata',           stvbmp.stepSig,...
                                 'parent',          ut,...
                                 'Interruptible',   'off', ...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''stepSig'')' ,...
                                 'tooltipstring',   'Add a step signal');

    toolbar.pulseSig = uipushtool('cdata',          stvbmp.pulseSig,...
                                 'parent',          ut,...
                                 'Interruptible',   'off', ...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''pulseSig'')' ,...
                                 'tooltipstring',   'Add a pulse signal');

    toolbar.snapGrid = uitoggletool('cdata',            stvbmp.snapGrid,...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'Interruptible',   'off', ...
                                 'state',           'on',...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''snapGrid'')' ,...
                                 'tooltipstring',   'Toggle grid lines');

    toolbar.zoomX = uitoggletool('cdata',       stvbmp.zoomX,...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'Interruptible',   'off', ...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''zoomX'')' ,...
                                 'tooltipstring',   'Zoom in T');

    toolbar.zoomY = uitoggletool('cdata',       stvbmp.zoomY,...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''zoomY'')' ,...
                                 'tooltipstring',   'Zoom in Y');

    toolbar.zoomXY = uitoggletool('cdata',      stvbmp.zoomXY,...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''zoomXY'')' ,...
                                 'tooltipstring',   'Zoom in T and Y');

    toolbar.fullview = uipushtool('cdata',      stvbmp.fullview,...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''fullview'')' ,...
                                 'tooltipstring',   'Zoom out (fullview)');


    toolbar.start = uipushtool('cdata',      stvbmp.start_btn,...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''start'')' ,...
                                 'tooltipstring',   'Start simulation');


    toolbar.pause = uipushtool('cdata',      stvbmp.pause_btn,...
                                 'Enable',          'off',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''pause'')' ,...
                                 'tooltipstring',   'Pause simulation');


    toolbar.stop = uipushtool('cdata',      stvbmp.stop_btn,...
                                 'Enable',          'off',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''stop'')' ,...
                                 'tooltipstring',   'Stop simulation');

% UNCOMMENT To GET THE PLAY ALL Button
    toolbar.playall = uipushtool('cdata',      stvbmp.playall_btn,...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''playAll'')' ,...
                                 'tooltipstring',   'Run all and produce coverage');
                                 
    toolbar.up = uipushtool('cdata',      stvbmp.up_btn,...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''up'')' ,...
                                 'tooltipstring',   'Go to Simulink Diagram');

    toolbar.simulink = uipushtool('cdata',      stvbmp.simulink_btn,...
                                 'parent',          ut,...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''simulink'')' ,...
                                 'tooltipstring',   'Open Simulink Library Browser');

    toolbar.verifyView = uitoggletool('cdata',       stvbmp.vnv_btn,...
                                 'separator',       'on',...
                                 'parent',          ut,...
                                 'Interruptible',   'off', ...
                                 'clickedcallback', 'sigbuilder(''Toolbar'',gcbf,[],''verifyView'')' ,...
                                 'tooltipstring',   'Show verification settings');


    if ~figure_has_java(dialog) || ~vnv_enabled
        set(toolbar.verifyView,'Enable','off');
    end




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the channel context menu:
    % Add the main menu
    chanMenuTable = ...
    {'Rename...',       'sigbuilder(''chContext'',gcbf,[],''rename'');',            'rename',  
     'Hide',                'sigbuilder(''chContext'',gcbf,[],''sighide'');'                'cut', 
     '---',                 ' ',                                                        ' ',                                       
     'Format',              ' ',                                                        'format',  
     '>Color',              'sigbuilder(''chContext'',gcbf,[],''setColor'');',          'setColor'  
     '>Line style',         ' ',                                                        'lineStyle',    
     '>>Solid',             'sigbuilder(''chContext'',gcbf,[],''setLineStyle'',''solid'');',   'lineStyle_solid',  
     '>>Dashed',            'sigbuilder(''chContext'',gcbf,[],''setLineStyle'',''dashed'');',  'lineStyle_dashed',  
     '>>Dotted',            'sigbuilder(''chContext'',gcbf,[],''setLineStyle'',''dotted'');',  'lineStyle_dotted',  
     '>>Dashed-dotted',     'sigbuilder(''chContext'',gcbf,[],''setLineStyle'',''dash-dott'');',  'lineStyle_dashdott',  
     '>Line width...',      'sigbuilder(''chContext'',gcbf,[],''setWidth'');'           'setWidth',                
     'Set Signal Y limits', 'sigbuilder(''chContext'',gcbf,[],''yminmax'');',           'yminmax', 
     '---',                 ' ',                                                        ' ',                                       
     'Cut',                 'sigbuilder(''chContext'',gcbf,[],''cut'');'                'cut', 
     'Copy',                'sigbuilder(''chContext'',gcbf,[],''copy'');'               'copy', 
     'Paste',               'sigbuilder(''chContext'',gcbf,[],''paste'');'              'paste', 
     'Delete',              'sigbuilder(''chContext'',gcbf,[],''delete'');'             'delete', 
     '---',                 ' ',                                                        ' ',                                       
     'Set Y snap grid',     ' ',                                                        'setStepY_main', 
     'Set T snap grid',  ' ',                                                        'setStepX_main', 
     '---',                 ' ',                                                        ' ',                                       
     'Set Y display limits...',    'sigbuilder(''axesContext'',gcbf,[],''setYrange'');',       'yDispLimits', 
     'Set T display limits...',    'sigbuilder(''axesContext'',gcbf,[],''tdisprange'');',      'tDispLimits', 
     '---',                 ' ',                                                        ' ',                                       
     'Change time range...','sigbuilder(''FigMenu'',gcbf,[],''setTrange'');'            'cut'};
    topHandle = uicontextmenu('Parent',dialog);
    channelContext = sigbuilder_makemenu(topHandle,char(chanMenuTable(:,1)),char(chanMenuTable(:,2)),char(chanMenuTable(:,3)));
    channelContext.handle = topHandle;
    set(channelContext.paste,'Enable','off');



    channelContext.setStepX.children = add_submenu_number_selection( ...
                                        channelContext.setStepX_main, ...
                                        'sigbuilder(''chContext'',gcbf,[],''setStepX''', ...
                                        [0 .001 .002 .005 .01 .02 .05 .1 .2 .5 1 2 5]);

    channelContext.setStepY.children = add_submenu_number_selection( ...
                                        channelContext.setStepY_main, ...
                                        'sigbuilder(''chContext'',gcbf,[],''setStepY''', ...
                                        [0 .01 .02 .05 .1 .2 .5 1 2 5 10 20 50 100]);

    channelContext.chngAxes.children = [];


    clipboard.type = 'none';
    clipboard.content = [];

    UD.menus.channelContext = channelContext;
    UD.menus.tabContext = tabContext;
    UD.menus.figmenu = figmenu;
    UD.menus.tabmenus = [];
    UD.toolbar  = toolbar;
    UD.tlegend  = tlegend;
    UD.common = common_data_struct([0 10]);
    UD.fromSL = 0;
    UD.simulink = [];
    UD.clipboard = clipboard;
    UD.undo = struct('command','none','action','','contents','','index',-1,'data',[]);

%    UD = new_channel(dialog,UD,[0 4 4 6 6 10],[0 0 0.8 0.8 0 0]);
%    UD = new_axes(UD,1,1);
%    UD.current.axes = 0;
%    UD = dataSet_sync_menu_state(UD);
    
%    UD = update_channel_select(UD);
%    UD = update_show_menu(UD);
%    UD = update_tab_sub_menu(UD);
    UD = create_verify_data(UD);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save the userData and install callbacks
    if keep_hidden
        set(dialog,'UserData',UD);
    else
        set(dialog,		'UserData',				UD, ...
                        'Visible',				'on');
        enable_mouse_callback(UD);        
    end


function disable_mouse_callback(UD)
    set(UD.dialog,  'CloseRequestFcn',      '', ...
                    'ResizeFcn',            '', ...
                    'KeyPressFcn',          '', ...
                    'WindowButtonDownFcn',  '', ...
                    'WindowButtonMotionFcn','', ...
                    'WindowButtonUpFcn',    '');

function enable_mouse_callback(UD)
    set(UD.dialog,  'CloseRequestFcn',      'sigbuilder(''close'',gcbf,[]);', ...
                    'ResizeFcn',            'sigbuilder(''Resize'',gcbf);', ...
                    'KeyPressFcn',          'sigbuilder(''KeyPress'',gcbf);', ...
                    'WindowButtonDownFcn',  'sigbuilder(''ButtonDown'',gcbf);', ...
                    'WindowButtonMotionFcn','sigbuilder(''ButtonMotion'',gcbf);', ...
                    'WindowButtonUpFcn',    'sigbuilder(''ButtonUp'',gcbf);');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET_TEXT_WIDTH - Get the width that test will display
% 
function extent = get_text_width(labelStr,hgObj)
    set(hgObj, 'String', labelStr);
    ext = get(hgObj, 'Extent');
    extent = ext(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%              Data Structure Creation                  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% These can be relatively lean functions that just create a consistent 
% structure

function chStruct = channel_data_struct(xData,yData,stepX,stepY,labelStr,outIndex,dataSetCnt,color)

    if nargin<8
        color = [];
    end
    
    if nargin<7
        dataSetCnt = 1;
    end
    
    if nargin<6
        outIndex = 1;
    end
    
    if nargin<5
        labelStr = [];
    end
    
    if nargin<4
        stepY = [];
    end
    
    if nargin<3
        stepX = [];
    end
    
    if nargin<2
        yData = [0 0];
    end
    
    if nargin<1
        xData = [0 10];
    end
    
    chStruct = struct(   'xData',       xData, ...
                         'yData',       yData, ...
                         'stepX',       stepX, ...
                         'stepY',       stepY, ...
                         'yMin',        [], ...
                         'yMax',        [], ...
                         'color',       [], ...
                         'lineStyle',   [], ...
                         'lineWidth',   [], ...
                         'label',       labelStr, ...
                         'lineH',       [], ...
                         'leftDisp',    0, ...
                         'rightDisp',   0, ...
                         'outIndex',    outIndex, ...
                         'allXData',    {cell(1,dataSetCnt)}, ...
                         'allYData',    {cell(1,dataSetCnt)}, ...
                         'axesInd',     0);




function commonStruct = common_data_struct(trange)

    if nargin<1
        trange = [0 10];
    end
    commonStruct = struct(  'dispTime',     trange, ...
                            'dispMode',     1, ...
                            'minTime',      trange(1), ...
                            'maxTime',      trange(2), ...
                            'dirtyFlag',    0);




function dataSet = dataSet_data_struct(name,trange,activeDispIdx)

    if nargin<3
        activeDispIdx = [];
    end

    if nargin<2
        trange = [0 10];
    end
    
    if nargin<1
        name = 'Group 1';
    end
    
    dataSet = struct(   'activeDispIdx',    activeDispIdx, ...
                        'timeRange',        trange, ...
                        'name',             name, ...
                        'displayRange',     trange);


function axStruct = axes_data_struct(ylimits,vertProportion)

    if nargin<2
        vertProportion = 1;
    end
    
    if nargin<1
        ylimits = [-1 1];
    end
    
    axStruct = struct(  'handle',          [], ...
                        'numChannels',      [], ...
                        'channels',         [], ...
                        'yLim',             ylimits, ...
                        'lineLabels',       [], ...
                        'labelPos',         'TL', ...
                        'labelH',           0, ...
                        'labelPatch',       0, ...
                        'vertProportion',   vertProportion);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                        UICONTROL LAYOUT FUNCTIONS                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UICONTROL_LAYOUT_FUNCTIONS   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_CHANNEL_POINT_DISP - Layout the displays for 
% indicating the xy coordinates of a single point.
% 
function [chPointDisp,extent] = create_channel_point_disp(UD,origin,width,height,titleStr)
    
    geomConst = UD.geomConst;
    figbgcolor = get(UD.dialog,'Color');

    % Calulate the label width
    set(UD.textExtent,'FontWeight','bold');
    wdth(1) = get_text_width('X:',UD.textExtent);
    wdth(2) = get_text_width('Y:',UD.textExtent);
    labelWidth = max(wdth);
    set(UD.textExtent,'FontWeight','normal');

    % Calculate positions:
    currX = origin(1);
    currY = origin(2);
    margin1 = currX + labelWidth + geomConst.verySmallHdelta;

    ylabelPos = [currX, currY, labelWidth, geomConst.staticTextH];
    yeditPos = [margin1, currY, geomConst.numDispExt];

    totalWidth = margin1 + geomConst.numDispExt(1) - origin(1);
    currY = currY + geomConst.numDispExt(2) + geomConst.smallVdelta;

    xlabelPos = [currX, currY, labelWidth, geomConst.staticTextH];
    xeditPos = [margin1, currY, geomConst.numDispExt];

    currY = currY + geomConst.numDispExt(2) + geomConst.smallVdelta;
    titlePos = [origin(1), currY, totalWidth, geomConst.staticTextH];

    totalHeight = currY + geomConst.staticTextH - origin(2);
    extent = [totalWidth totalHeight];


    % Add the controls for the first index
    chPointDisp.xLabel = uicontrol(   'parent',                   UD.dialog,...
                                    'Units',                    'points', ...
                                    'BackgroundColor',          figbgcolor,...
                                    'Position',                 xlabelPos, ...
                                    'String',                   'T:', ...
                                    'HorizontalAlignment',      'left', ...
                                    'FontWeight',               'bold', ...
                                    'Style',                    'text', ...
                                    'Enable',                   'off', ...
                                    'handlevisibility',         'callback');


    chPointDisp.xNumDisp = uicontrol( 'parent',           UD.dialog,...
                                    'Units',            'points', ...
                                    'Position',         xeditPos, ...
                                    'Enable',                   'off', ...
                                    'Style',            'edit', ...
                                    'BackgroundColor',  figbgcolor, ...
                                    'HorizontalAlignment',  'left', ...
                                    'handlevisibility', 'callback');



    % Add the controls for the second index
    chPointDisp.yLabel = uicontrol(   'parent',                   UD.dialog,...
                                    'Units',                    'points', ...
                                    'BackgroundColor',          figbgcolor,...
                                    'Position',                 ylabelPos, ...
                                    'String',                   'Y:', ...
                                    'HorizontalAlignment',      'left', ...
                                    'FontWeight',               'bold', ...
                                    'Style',                    'text', ...
                                    'Enable',                   'off', ...
                                    'handlevisibility',         'callback');


    chPointDisp.yNumDisp = uicontrol( 'parent',           UD.dialog,...
                                    'Units',            'points', ...
                                    'Position',         yeditPos, ...
                                    'Enable',                   'off', ...
                                    'Style',            'edit', ...
                                    'BackgroundColor',  figbgcolor, ...
                                    'HorizontalAlignment',  'left', ...
                                    'handlevisibility', 'callback');


    if nargin<5 | isempty(titleStr)
        titleStr = 'Point Coordinates';
    end

    chPointDisp.title = uicontrol(   'parent',                   UD.dialog,...
                                    'Units',                    'points', ...
                                    'BackgroundColor',          figbgcolor,...
                                    'Position',                 titlePos, ...
                                    'String',                   titleStr, ...
                                    'HorizontalAlignment',      'center', ...
                                    'FontWeight',               'bold', ...
                                    'Enable',                   'off', ...
                                    'Style',                    'text', ...
                                    'handlevisibility',         'callback');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_CHANNEL_BOUNDS_DISP - Layout the displays for 
% indicating the xy coordinates of a single point.
% 
function [chBoundsDisp,extent] = create_channel_bounds_disp(UD,origin,width,height)
    
    geomConst = UD.geomConst;
    figbgcolor = get(UD.dialog,'Color');

    % Calulate the label width
    labelWidth = get_text_width('Max:',UD.textExtent);
    totalWidth = labelWidth + geomConst.numEntryExt(1) + geomConst.smallHdelta;

    % Calculate positions
    currX = origin(1);
    currY = origin(2);
    margin1 = currX + labelWidth + geomConst.smallHdelta;

    maxLabelPos = [currX currY labelWidth geomConst.staticTextH];
    maxEditPos = [margin1 currY geomConst.numEntryExt];

    currY = currY + geomConst.numEntryExt(2) + geomConst.smallVdelta;
    minLabelPos = [currX currY labelWidth geomConst.staticTextH];
    minEditPos = [margin1 currY geomConst.numEntryExt];

    currY = currY + geomConst.numEntryExt(2) + geomConst.smallVdelta;
    checkBoxPos = [currX currY totalWidth geomConst.numEntryExt(2)];

    totalHeight = currY + geomConst.numEntryExt(2);
    extent = [totalWidth totalHeight];

    % Layout the controls
    chBoundsDisp.maxLabel = uicontrol(  'parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 maxLabelPos, ...
                                        'String',                   'Max:', ...
                                        'HorizontalAlignment',      'left', ...
                                        'FontWeight',               'bold', ...
                                        'Style',                    'text', ...
                                    'Enable',                   'off', ...
                                        'handlevisibility',         'callback');

    chBoundsDisp.maxEdit = uicontrol(   'parent',           UD.dialog,...
                                        'Units',            'points', ...
                                        'Position',         maxEditPos, ...
                                        'Style',            'edit', ...
                                        'String',            'inf', ...
                                        'Enable',            'off', ...
                                        'BackgroundColor',  figbgcolor, ...
                                        'HorizontalAlignment',  'left', ...
                                    'Enable',                   'off', ...
                                        'handlevisibility', 'callback');
    


    chBoundsDisp.minLabel= uicontrol(   'parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 minLabelPos, ...
                                        'String',                   'Min:', ...
                                        'HorizontalAlignment',      'left', ...
                                        'FontWeight',               'bold', ...
                                        'Style',                    'text', ...
                                    'Enable',                   'off', ...
                                        'handlevisibility',         'callback');

    chBoundsDisp.minEdit  = uicontrol(  'parent',           UD.dialog,...
                                        'Units',            'points', ...
                                        'Position',         minEditPos, ...
                                        'Style',            'edit', ...
                                        'String',            '-inf', ...
                                        'Enable',            'off', ...
                                        'BackgroundColor',  figbgcolor, ...
                                        'HorizontalAlignment',  'left', ...
                                    'Enable',                   'off', ...
                                        'handlevisibility', 'callback');

    chBoundsDisp.checkbox = uicontrol(  'parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 checkBoxPos, ...
                                        'String',                   'Bound signal', ...
                                        'HorizontalAlignment',      'left', ...
                                        'FontWeight',               'normal', ...
                                        'Value',                    0, ...
                                        'Style',                    'checkbox', ...
                                    'Enable',                   'off', ...
                                        'handlevisibility',         'callback');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_CHANNEL_DISP_CONTROLS - Layout the displays for 
% indicating the channel label, number, and  axes.
% 
function [chDispCntrls,extent] = create_channel_disp_controls(UD,origin,width,height)
    
    geomConst = UD.geomConst;
    figbgcolor = get(UD.dialog,'Color');

    % Calulate the label width
    set(UD.textExtent,'FontWeight','bold');
    wdth(1) = get_text_width(xlate('Index:'),UD.textExtent);
    wdth(2) = get_text_width('Axes:',UD.textExtent);
    set(UD.textExtent,'FontWeight','normal');

    totalWidth = sum(wdth) + geomConst.intPopupExt(1) + 3*geomConst.smallHdelta;

    % Calculate positions:
    currX = origin(1);
    currY = origin(2);
    
    indexLabelPos = [currX currY wdth(1) geomConst.staticTextH];
    currX = currX + wdth(1) + geomConst.smallHdelta;
    indexPopupPos = [currX currY+geomConst.popupYoff geomConst.intPopupExt];   
    currX = currX + geomConst.intPopupExt(1) + geomConst.smallHdelta;
    axesLabelPos = [currX currY wdth(2) geomConst.staticTextH];   
    currX = origin(1);
    currY = currY + geomConst.intPopupExt(2) + geomConst.smallVdelta +geomConst.popupYoff;
    labelLabelPos = [currX currY wdth(1) geomConst.staticTextH];
    currX = currX + wdth(1) + geomConst.smallHdelta;
    labelEditPos = [currX currY totalWidth-wdth(1)-geomConst.smallHdelta geomConst.intPopupExt(2)];
    currY = currY + geomConst.intPopupExt(2) + geomConst.smallVdelta;
    legendAxesPos = [currX currY totalWidth geomConst.intPopupExt(2)];

    totalHeight = currY + geomConst.intPopupExt(2) - origin(2);
    extent = [totalWidth totalHeight];

    chDispCntrls.indexLabel = uicontrol('parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 indexLabelPos, ...
                                        'String',                   'Index:', ...
                                        'HorizontalAlignment',      'left', ...
                                        'FontWeight',               'bold', ...
                                        'Style',                    'text', ...
                                        'Enable',                   'off', ...
                                        'Tooltipstring',            'Change the signal output index in Simulink', ...
                                        'handlevisibility',         'callback');

    chDispCntrls.indexPopup = uicontrol('parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 indexPopupPos, ...
                                        'String',                   '1', ...
                                        'Style',                    'popup', ...
                                        'Tooltipstring',            'Change the signal output index in Simulink', ...
                                        'Enable',                   'off', ...
                                        'handlevisibility',         'callback');

    chDispCntrls.labelLabel = uicontrol('parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 labelLabelPos, ...
                                        'String',                   'Name:', ...
                                        'HorizontalAlignment',      'left', ...
                                        'FontWeight',               'bold', ...
                                        'Style',                    'text', ...
                                        'Enable',                   'off', ...
                                        'handlevisibility',         'callback');

    chDispCntrls.labelEdit = uicontrol( 'parent',           UD.dialog,...
                                        'Units',            'points', ...
                                        'Position',         labelEditPos, ...
                                        'Style',            'edit', ...
                                        'String',            '', ...
                                        'Tooltipstring',     'Change the selected signal label', ...
                                        'Enable',            'off', ...
                                        'BackgroundColor',  figbgcolor, ...
                                        'HorizontalAlignment',  'left', ...
                                        'handlevisibility', 'callback');

    chDispCntrls.legendAxes = axes( 'parent',           UD.dialog,...
                                    'units',            'points',...
                                    'Position',          legendAxesPos,...
                                    'box',              'off',...
                                    'color',            figbgcolor,...
                                    'XColor',           figbgcolor,...
                                    'YColor',           figbgcolor,...
                                    'XLim',             [0 1],...
                                    'YLim',             [-1 1],...
                                    'xtick',            [],...
                                    'ytick',            [],...
                                    'handlevisibility', 'callback');

    chDispCntrls.legendLine = line( 'parent',           chDispCntrls.legendAxes,...
                                    'XData',            [0 1],...
                                    'YData',            [0 0],...
                                    'Visible',          'off'...
                                    );




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_TIME_ADJUST_CONTROLS - Layout the displays for 
% adjusting time in event sequence mode.
% 
function [timeAdjCtrls,extent] = create_time_adjust_controls(UD,origin)
    
    
    % Set positions 
    gConst = UD.geomConst;
    currX = origin(1);
    currY = origin(2);
    currX = currX + gConst.legdBorder;
    currY = currY + gConst.legdBorder + gConst.numDispExt(2) + gConst.objVdelta;
    editPos = [currX currY gConst.numDispExt];

    currX = currX + gConst.numDispExt(1) + gConst.objHdelta;
    txtSize = get_text_width('megS',UD.textExtent);
    popupWidth = txtSize(1) + 15;
    popupPos = [currX currY popupWidth gConst.numDispExt(2)];

    currX = currX + popupWidth + gConst.objHdelta;
    txtSize = get_text_width('from right',UD.textExtent);
    checkboxWidth = txtSize(1) + 10;
    checkboxPos = [currX currY checkboxWidth gConst.numDispExt(2)];
    
    totalWidth = currX + checkboxWidth + gConst.legdBorder;
    scrollWidth = totalWidth - 2*gConst.legdBorder;
    currX = origin(1) + gConst.legdBorder;
    currY = currY + gConst.numDispExt(2) + gConst.objVdelta;
    scrollPos = [currX currY scrollWidth gConst.numDispExt(2)];

    currY = currY + gConst.numDispExt(2) + gConst.objVdelta;
    textPos = [currX currY scrollWidth gConst.staticTextH];

    totalHeight = currY + gConst.objVdelta + gConst.staticTextH + ...
                    gConst.legdBorder;
    framePos = [origin totalWidth totalHeight];
    applyX = origin(1) + (totalWidth-gConst.numDispExt(1))/2;    
    applyPos = [applyX origin(2)+gConst.legdBorder gConst.numDispExt];
    
    figbgcolor = get(UD.dialog,'Color');
    extent = [totalWidth totalHeight];
    
    timeAdjCtrls.origin = origin;

    timeAdjCtrls.frame = uicontrol(     'parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 framePos, ...
                                        'String',                   '1', ...
                                        'Tooltipstring',            'Change the axes', ...
                                        'Style',                    'frame', ...
                                        'handlevisibility',         'callback');
    
    timeAdjCtrls.scroll = uicontrol(    'parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          'white',...
                                        'Position',                 scrollPos, ...
                                        'String',                   '1', ...
                                        'Tooltipstring',            'Time adjustment', ...
                                        'Max',                      1, ...
                                        'Min',                      0, ...
                                        'callback',                 'sigbuilder(''timeUi'',gcbf,[],''scroll'',gcbf);', ...
                                        'SliderStep',               [0.02 0.15], ...
                                        'Style',                    'slider', ...
                                        'handlevisibility',         'callback');
    
    timeAdjCtrls.edit = uicontrol(  'parent',                   UD.dialog,...
                                    'Units',                    'points', ...
                                    'BackgroundColor',          'white',...
                                    'Position',                 editPos, ...
                                    'String',                   '', ...
                                    'Tooltipstring',            'Displacement time from neighboring point', ...
                                    'Style',                    'edit', ...
                                    'handlevisibility',         'callback');
                                    

    timeAdjCtrls.scalePopup = uicontrol('parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          'white',...
                                        'Position',                 popupPos, ...
                                        'String',                   'nS|uS|mS|sec|kS|megS', ...
                                        'Tooltipstring',            'Displacement time scale', ...
                                        'callback',                 'sigbuilder(''timeUi'',gcbf,[],''scale'',gcbf);', ...
                                        'Style',                    'popup', ...
                                        'handlevisibility',         'callback');
    
    timeAdjCtrls.direction = uicontrol( 'parent',                   UD.dialog,...
                                        'Units',                    'points', ...
                                        'BackgroundColor',          figbgcolor,...
                                        'Position',                 checkboxPos, ...
                                        'String',                   'From right', ...
                                        'Tooltipstring',            'Change the axes', ...
                                        'Style',                    'checkbox', ...
                                        'handlevisibility',         'callback');
    
    timeAdjCtrls.label = uicontrol( 'parent',                   UD.dialog,...
                                    'Units',                    'points', ...
                                    'BackgroundColor',          figbgcolor,...
                                    'Position',                 textPos, ...
                                    'String',                   'Adjust time', ...
                                    'Tooltipstring',            'Change the axes', ...
                                    'Style',                    'text', ...
                                    'handlevisibility',         'callback');
        
    timeAdjCtrls.apply = uicontrol( 'parent',                   UD.dialog,...
                                    'Units',                    'points', ...
                                    'BackgroundColor',          figbgcolor,...
                                    'Position',                 applyPos, ...
                                    'String',                   'Apply', ...
                                    'callback',                 'sigbuilder(''timeUi'',gcbf,[],''apply'',gcbf);', ...
                                    'Tooltipstring',            'Set new time', ...
                                    'Style',                    'push', ...
                                    'handlevisibility',         'callback');
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                          AXES UTILITY FUNCTIONS                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AXES_UTILITY_FUNCTIONS   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update_gca_display - Indicate the current axes by making the
% yTick labels bold;
%
function update_gca_display(UD)
    persistent BoldAxesH

    sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    
    if ~isempty(BoldAxesH) & UD.current.axes==BoldAxesH
        return;
    end

    axesH = UD.current.axes;
    set(axesH,'FontWeight','bold')
    
    if ~isempty(BoldAxesH) & ishandle(BoldAxesH)
        set(BoldAxesH,'FontWeight','normal');
    end

    BoldAxesH = axesH;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEW_AXES - Create a new axes in the figure
% 
% UD = new_axes(UD,index,channels,[ylimits,xlimits,vertProportion])
%
function UD = new_axes(UD,index,channels,varargin)

    position = [];

    switch(nargin)
    case 6,
        ylimits = varargin{1}; 
        xlimits = varargin{2};
        doFast = varargin{3};
        vertProportion = 1/(UD.numAxes+1);
    case 5,
        ylimits = varargin{1}; 
        xlimits = varargin{2};
        doFast = 0;
        vertProportion = 1/(UD.numAxes+1);
    case 4,
        ylimits = varargin{1}; % Default;
        xlimits = UD.common.dispTime;
        doFast = 0;
        vertProportion = 1/(UD.numAxes+1);
    case 3,
        ylimits = [-1 1]; % Default;
        xlimits = UD.common.dispTime;
        doFast = 0;
        vertProportion = 1/(UD.numAxes+1);
    otherwise,
        error('Must have at least 3 input argumets');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Handle empty properties
    if isempty(vertProportion)
        vertProportion = 1/(UD.numAxes+1);
    end
    
    if isempty(xlimits)
            xlimits = UD.common.dispTime;
    end
    if isempty(ylimits)
            ylimits = [-1 1]; % Default;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Position should only be applied for
    % the first axes in the object
    if ~isempty(position)
        if(UD.numAxes>0)
            error('Can not specify a position when adding an axes');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update all the axes UD fields and object
    % properties
    
    UD.numAxes = UD.numAxes+1;
    if(UD.numAxes>1)
        xlabelAxes = UD.axes(1).handle;
        ySizeReduction = 1-vertProportion;
        if (index <= length(UD.axes))
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Move existing axes and legends up 
            moveUpAxes = UD.axes(index:end);
            for j=1:length(moveUpAxes)
                axUd = get(moveUpAxes(j).handle,'UserData');
                axUd.index = axUd.index+1;
                set(moveUpAxes(j).handle,'UserData',axUd);
                moveUpchannels = moveUpAxes(j).channels;
                for chIdx = moveUpchannels
                    UD.channels(chIdx).axesInd = axUd.index;
                end
            end
            UD.axes(index) = axes_data_struct(ylimits,vertProportion);   
            UD.axes = [UD.axes(1:index) moveUpAxes];

        else
            UD.axes(index) = axes_data_struct(ylimits,vertProportion); 
        end
        for(i=1:UD.numAxes)
            if(i~=index)
                UD.axes(i).vertProportion = ySizeReduction*UD.axes(i).vertProportion;
            end
        end

        
    else
        UD.axes = axes_data_struct(ylimits,vertProportion); 
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the axes, label text and patch
    axesUD = struct('type','editAxes','index',index);
    
    if in_iced_state_l(UD),
        color = light_gray_l;
    else,
        color = default_axes_bg_color_l;
    end;
   
    axesH = axes('Parent',              UD.dialog, ...
                 'Units',               'points', ...
                 'XGrid',               UD.current.gridSetting, ...
                 'YGrid',               UD.current.gridSetting, ...
                 'XLim',                xlimits, ...
                 'YLim',                ylimits, ...
                 'UIContextMenu',       UD.menus.channelContext.handle, ...
                 'HandleVisibility',    'callback', ...
                 'Box',                 'off', ...
                 'Visible',             'off', ...
                 'Color',               color, ...
                 'UserData',            axesUD);

    patchH = patch(0,0,[1 1 1],'Parent',axesH,'LineStyle','none','Erasemode','normal');
    labelH = text(  'String',               ' ', ...
                    'Parent',               axesH, ...
                    'Position',             [0 0 0], ...
                    'VerticalAlignment',    'middle', ...
                    'Erasemode',            'normal', ...
                    'Interpreter',          'none', ...
                    'HorizontalAlignment',  'left');

    UD.axes(index).labelH = labelH;
    UD.axes(index).labelPatch = patchH;
                 
    UD.axes(index).handle = axesH;
    UD.current.axes = axesH;
    update_gca_display(UD)
    xl = get(axesH,'XLabel');
    
    if(UD.numAxes>1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Additional axes must use the same 
        % values for X axis ticks and labels
        if index==1
            set(axesH,'XTick',get(xlabelAxes,'XTick'));
            set(axesH,'XTickLabel',get(xlabelAxes,'XTickLabel'));
            set(xlabelAxes,'XTickLabel','');
            xlold = get(xlabelAxes,'XLabel');
            set(xlold,'String','');
            if UD.common.dispMode==1
                ax.XTickLabelMode = 'auto';
                ax.XTickMode = 'auto';
                set(xl,'String','Time (sec)','FontWeight','Bold');  
            else
                ax.XTickLabelMode = 'manual';
                ax.XTickLabel = '';
                set(xl,'String','Event time sequence','FontWeight','Bold'); 
            end 
        else
            ax.XTick = get(xlabelAxes,'XTick');
            ax.XTickLabel = '';
            ax.XTickLabelMode = 'manual';
            ax.XTickMode = 'auto';
        end
        set(axesH,ax);
    else
        if (UD.common.dispMode==1)
            set(xl,'String','Time (sec)','FontWeight','Bold');  
        else    
            set(axesH,'XTickLabel','','XTickLabelMode','manual','FontWeight','Bold');
            set(xl,'String','Event time sequence'); 
        end 
    end 

    % top_of_hg_stack(axesH,UD.dialog);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update the position of all axes 
    for(i=1:UD.numAxes)
        pos = calc_new_axes_position(UD,i);
        set(UD.axes(i).handle,'Position',pos);
        set(UD.axes(i).handle,'Visible','on');
    end
                        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the channel data on the axes
    for i = 1:length(channels)
        chIndex = channels(i);
        [UD,lineH] = new_plot_channel(UD,chIndex,index);
    end
    
    if ~doFast
        update_all_axes_label(UD);
    	drawnow
    end
    	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_AXES_LABEL - Adjust the position of the axes label
% 
function update_axes_label(UD,axIdx)
    % This function should be called
    % whenever the axes is resized, its
    % range is changed or the label is 
    % changed
    
    labelOff = [15 5];  % offset in points

    axesH = UD.axes(axIdx).handle;
    labelH = UD.axes(axIdx).labelH;
    patchH = UD.axes(axIdx).labelPatch;
    labelPos = UD.axes(axIdx).labelPos;
    xyoff = fig_2_ax_ext(labelOff,axesH);
    
    xlim = get(axesH,'XLim');
    ylim = get(axesH,'YLim');
    extent = get(labelH,'Extent');  
    
    switch(labelPos)
    case 'BR'
        xpos = xlim(2) - xyoff(1) - extent(3);
        ypos = ylim(1) + xyoff(2) + extent(4)/2;
    case 'BL'
        xpos = xlim(1) + xyoff(1);
        ypos = ylim(1) + xyoff(2) + extent(4)/2;
    case 'TR'
        xpos = xlim(2) - xyoff(1) - extent(3);
        ypos = ylim(2) - xyoff(2) - extent(4)/2;
    case 'TL'
        xpos = xlim(1) + xyoff(1);
        ypos = ylim(2) - xyoff(2) - extent(4)/2;
    end
    
    set(labelH,'Position',[xpos ypos 0]);
    
    % Adjust the patch to just cover the text
    patchx = xpos + [0 0 1 1]*extent(3);
    patchy = ypos +[-1 1 1 -1]*extent(4)/2;
    set(patchH,'XData',patchx,'YData',patchy);


function update_all_axes_label(UD)

    for i=1:length(UD.axes);
        update_axes_label(UD,i);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEW_PLOT_CHANNEL - Plot a channel on the selected axes.
% 
function [UD,lineH] = new_plot_channel(UD,chIndex,axesInd,doFast)

    if nargin<4
        doFast = 0;
    end
    

    axesH = UD.axes(axesInd).handle;
    UD.channels(chIndex) = check_and_apply_line_properties(UD.channels(chIndex),chIndex);
    
    lineUD.index = chIndex;
    lineUD.type = 'Channel';

    lName = sprintf('(#%d) %s',UD.channels(chIndex).outIndex,UD.channels(chIndex).label);
    lineH = line(   'Parent',               axesH, ...
                    'Color',                UD.channels(chIndex).color, ...
                    'EraseMode',            'normal', ...
                    'HandleVisibility',     'callback', ...
                    'LineWidth',            UD.channels(chIndex).lineWidth, ...
                    'LineStyle',            UD.channels(chIndex).lineStyle, ...
                    'Xdata',                UD.channels(chIndex).xData, ...
                    'Ydata',                UD.channels(chIndex).yData, ...
                    'UIContextMenu',        UD.menus.channelContext.handle, ...
                    'UserData',             lineUD);

    % Put on the bottom (WISH change this in future)
    bottom_of_hg_stack(lineH);

    UD.channels(chIndex).lineH = lineH;
    UD.channels(chIndex).axesInd = axesInd;
    UD.channels(chIndex).color = get(lineH,'Color');
    UD.axes(axesInd).channels(end+1) = chIndex;

    % Upate the label text
    set(UD.axes(axesInd).labelH,'String',UD.channels(chIndex).label,'Color',UD.channels(chIndex).color);

    if ~doFast
        % Resize the axes if necessary (Will cause markers and labels to be refreshed)
        UD = rescale_axes_to_fit_data(UD,axesInd,[],1);
    
        update_axes_label(UD,axesInd);
        
        % Update the channel display listbox
        chanStr = get(UD.hgCtrls.chanListbox,'String');
        chanStr(chIndex,(end-6):end) = '(shown)';
        set(UD.hgCtrls.chanListbox,'String',chanStr);
    
        % Update the dataSet entry
        activeDispIdx = UD.dataSet(UD.current.dataSetIdx).activeDispIdx;
        UD.dataSet(UD.current.dataSetIdx).activeDispIdx = fliplr(sort([activeDispIdx chIndex]));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK_AND_APPLY_LINE_PROPERTIES - 
% 
function chStruct = check_and_apply_line_properties(chStruct,chNum)

    persistent colorOrder

    if isempty(colorOrder)
        colorOrder = {  [0.8431         0         0], ...
                        [0.7176         0    0.7176], ...
                        [0              0         1], ...
                        [0.2510         0    0.2510], ...
                        [0.9843    0.8627    0.0157], ...
                        [0.2510    0.5020    0.5020], ...
                        [0         0.5020    0.2510], ...
                        [1.0000         0    0.5020], ...
                        [0.1529    0.6588    0.1412], ...
                        [1.0000    0.5020    0.2510], ...
                        [0.6275    0.3922    0.2118], ...
                        [0.2510         0    0.2510]};
    end

    if ~isfield(chStruct,'color') | isempty(chStruct.color)
        chStruct.color = colorOrder{mod(chNum-1,length(colorOrder))+1};
    end

    if ~isfield(chStruct,'lineStyle') | isempty(chStruct.lineStyle)
        chStruct.lineStyle = '-';
    end

    if ~isfield(chStruct,'lineWidth') | isempty(chStruct.lineWidth)
        chStruct.lineWidth = 1.5;
    end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESIZE
% 
function UD = resize(UD)
    newPos = get(UD.dialog,'Position');


    makeWiderObjs = [ UD.hgCtrls.chFrame.top  ...
                      UD.hgCtrls.chFrame.bottom  ...
                      UD.hgCtrls.tabFrame.top  ...
                      UD.hgCtrls.tabFrame.bottom  ...
                      UD.hgCtrls.chFrame.topInner  ...
                      UD.hgCtrls.chFrame.bottomInner  ...
                      UD.hgCtrls.chanListbox ...
                      UD.hgCtrls.status.selFrame.top ...
                      UD.hgCtrls.status.selFrame.bottom];

	if strcmp(get(UD.tlegend.scrollbar,'Enable'),'on')
		makeWiderObjs = [makeWiderObjs UD.tlegend.scrollbar];
	end
%                     UD.tlegend.scrollbar ...

    moveXPosObjs = [ UD.hgCtrls.chFrame.right  ...
                     UD.hgCtrls.chFrame.rightInner ...
                     UD.hgCtrls.tabFrame.right ...
                     UD.hgCtrls.status.selFrame.right ...
                     ];

	makeTallerObjs = [ UD.hgCtrls.chFrame.left  ...
                       UD.hgCtrls.chFrame.right ...
                       UD.hgCtrls.chFrame.leftInner ...
                       UD.hgCtrls.chFrame.rightInner];
                        
    moveYPosObjs = [ UD.hgCtrls.tabselect.axesH ...
                     UD.hgCtrls.chFrame.top ...
                     UD.hgCtrls.chFrame.topInner ...
                     UD.hgCtrls.tabselect.leftScroll ...
                     UD.hgCtrls.tabselect.rightScroll ...
                     UD.hgCtrls.tabFrame.top  ...
                     UD.hgCtrls.tabFrame.bottom  ...
                     UD.hgCtrls.tabFrame.left  ...
                     UD.hgCtrls.tabFrame.right];
                     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If we have not resized before we need
    % to determine the min size
    if ~isfield(UD,'minExtent') | isempty(UD.minExtent)
        allPos = get(makeWiderObjs,'Position');
        allPos = cat(1,allPos{:});
        minAdjWidth = min(allPos(:,3));
        minWidth = UD.current.figPos(3) - minAdjWidth;
        minHeight = UD.current.figPos(4) - UD.current.axesExtent(4);
        UD.minExtent = [minWidth minHeight];        
    end

    minWidth = UD.minExtent(1)+5;
    minHeight = (UD.minExtent(2) + UD.geomConst.axesOffset(2) + (UD.numAxes-1)*UD.geomConst.axesVdelta) + 10;
    
    if (newPos(3) < minWidth  | newPos(4) < minHeight)
        if isfield(UD,'tooSmall') & ~isempty(UD.tooSmall)
            return;
        end

        UD.allChildren = findobj(UD.dialog,'Visible','on');
        UD.allChildren = UD.allChildren(UD.allChildren~=UD.dialog);
        set(UD.allChildren,'Visible','off');
        UD.tooSmall = uicontrol('Parent',           UD.dialog ...
                                ,'Style',           'Text' ...
                                ,'Visible',         'off' ...
                                ,'String',          'Window too small!' ...
                                );
        ext = get(UD.tooSmall,'Extent');
        set(UD.tooSmall,'Position', [0.5*(newPos(3:4)-ext(3:4)) ext(3:4)],'Visible','on');
        return;
    end
    
    if isfield(UD,'tooSmall') & ~isempty(UD.tooSmall) 
        if ishandle(UD.tooSmall)
        	delete(UD.tooSmall);
        end
        keepIdx = ishandle(UD.allChildren);
        actChildren = UD.allChildren(keepIdx);
        set(actChildren,'Visible','on');
        UD.tooSmall = [];
    end
    
    
    delta = newPos-UD.current.figPos;
    UD.current.axesExtent = UD.current.axesExtent+[0 0 delta(3:4)];
    
    if UD.numAxes>0 & ~ishandle(UD.axes(1).handle)
        return;
    end
                   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update the position of all axes
    for(i=1:UD.numAxes)
        pos = calc_new_axes_position(UD,i);
        set(UD.axes(i).handle,'Position',pos);
    end

    adjust_width(makeWiderObjs,delta(3));
    adjust_x_coord(moveXPosObjs,delta(3));
    adjust_y_coord(moveYPosObjs,delta(4));
    adjust_height(makeTallerObjs,delta(4));
    update_all_axes_label(UD);
    sigbuilder_tabselector('resize',UD.hgCtrls.tabselect.axesH,delta(3));
    
    if ~isempty(UD.verify.hg.component) && strcmp(get(UD.verify.hg.componentContainer,'visible'),'on')
        pos = find_verify_position(UD);
        set(UD.verify.hg.componentContainer, 'Position', pos);
    end

    UD.current.figPos = newPos;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IS_SPACE_FOR_NEW_AXES
% 
function out = is_space_for_new_axes(UD)
    out = (UD.current.axesExtent(4)-10) > (UD.geomConst.axesOffset(2) +  ...
        UD.numAxes * UD.geomConst.axesVdelta);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALC_NEW_AXES_POSITION
% 
function position = calc_new_axes_position(UD,index),

    axesExtent = UD.current.axesExtent;
    xvalue = axesExtent(1) + UD.geomConst.axesOffset(1);
    startY = axesExtent(2) + UD.geomConst.axesOffset(2);
    width = axesExtent(3) - UD.geomConst.axesOffset(1);
    totalY = axesExtent(4);

    pureAxesY = totalY - UD.geomConst.axesOffset(2) - ...
                (UD.numAxes-1)*UD.geomConst.axesVdelta;

%    allProportions = cat(UD.axes(1).vertProportion,UD.axes.vertProportion);
%
%    % Perform a sanity check
%    if (abs(sum(allProportions)-1)>(10*eps))
%        error('Internal error, vertical proportions do not sum to 1');
%    end
    allProportions = ones(1,UD.numAxes)*(1/UD.numAxes);

    height = allProportions(index)*pureAxesY;
    startY = startY + sum(allProportions(1:(index-1)))*pureAxesY + ...
            (index-1)*UD.geomConst.axesVdelta;

    position = [xvalue startY width height];


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESCALE_AXES_TO_FIT_DATA - Rescale the axes if there are 
% any points with y values outside of the current display 
% range.
%
function UD = rescale_axes_to_fit_data(UD,axesIndex,modifiedChannel,forceResize,doFast),

    if length(UD.axes(axesIndex).channels)==0
        return;
    end


    if nargin<5
        doFast = 0;
    end



    if nargin<4
        forceResize = 0;
    end

    if ~doFast
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end
    
    channelIdx = UD.axes(axesIndex).channels;
    minYvalues = [];
    maxYvalues = [];
    for ch = channelIdx(:)',
        [ymin,ymax] = find_y_range_from_x(  UD.channels(ch).xData, ...
                                            UD.channels(ch).yData, ...
                                            UD.common.dispTime(1), ...
                                            UD.common.dispTime(2));
        minYvalues = [minYvalues ymin];
        maxYvalues = [maxYvalues ymax];
    end
    minY = min(minYvalues);
    maxY = max(maxYvalues);



    % Check if values are within the current limits
    if ~forceResize
        yLim = get(UD.axes(axesIndex).handle,'YLim');
        if (yLim(1) < minY & yLim(2) > maxY)
            return;
        end
    end

    % If all values are the same, set the range to y +/- 1
    if maxY==minY,
        newYlim = round(maxY + [-1 1]);
        UD.axes(axesIndex).yLim = newYlim;
        set(UD.axes(axesIndex).handle,'YLim',newYlim);
        if ~doFast
            update_axes_label(UD,axesIndex);        
        end
        return;
    end
    

    % Use some intelligence to set a nice y range
    diff = maxY-minY;
    if (maxY*minY>0  & ((minY>0 & diff>(2*minY)) | (maxY<0 & diff>(-2*maxY))))
        includeZero = 1;
    else
        includeZero = 0;
    end
    orderOfMagnitude = ceil(log10(diff));

    baseStep = 10^(orderOfMagnitude-1);

    if (diff/baseStep)<1.5
        step = baseStep/10;
    elseif (diff/baseStep)<6
        step = baseStep/2;
    else
        step = baseStep;
    end

    if (maxY>0)
        newYlim(2) = step*ceil(1.05*maxY/step);
        if minY == 0
            newYlim(1) = -step;
        elseif includeZero
            newYlim(1) = 0;
        else
            if minY>0
                newYlim(1) = step*floor(0.95*minY/step);
            else
                newYlim(1) = step*floor(1.05*minY/step);
            end
        end
    else
        if maxY==0
             newYlim(2) = step;
        elseif includeZero
             newYlim(2) = 0;
        else
             newYlim(2) = step*ceil(0.95*maxY/step);
        end
        newYlim(1) = step*floor(1.05*minY/step);
    end

    UD.axes(axesIndex).yLim = newYlim;
    set(UD.axes(axesIndex).handle,'YLim',newYlim);
    
    if ~doFast
        update_axes_label(UD,axesIndex);        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEW_CHANNEL - Add a new channel to the repository
% 
function UD = new_channel(dialog,UD,xData,yData,stepX,stepY,labelStr,outIndex)
    
    switch(nargin)
        case 4
            stepX = 0;
            stepY = 0;
            outIndex = UD.numChannels+1;
            labelStr = sprintf('Signal %d',outIndex);
        case 5
            stepY = 0;
            outIndex = UD.numChannels+1;
            labelStr = sprintf('Signal %d',outIndex);
        case 6
            outIndex = UD.numChannels+1;
            labelStr = sprintf('Signal %d',outIndex);
        case 7
            outIndex = UD.numChannels+1;
        case 8
        otherwise,
            error('Bad number of input arguments for ''NewChannel'' method')
    end
    
    if isfield(UD,'channels') & ~isempty(UD.channels)
        allNames = {UD.channels.label};
        labelStr = uniqueify_str_with_number(labelStr,0,allNames{:});
    end
    
    dataSetCnt = length(UD.dataSet);
    
    chStruct = channel_data_struct(xData,yData,stepX,stepY,labelStr,outIndex,dataSetCnt);

    % Update the x/y points for other data sets
    copyToAllSets = 1;
    for i=1:dataSetCnt
        if i~=UD.current.dataSetIdx
            if copyToAllSets
                [newx,newy] = correct_endpoints([],xData,yData, ...
                                                UD.dataSet(i).timeRange(1), ...
                                                UD.dataSet(i).timeRange(2));
                chStruct.allXData{i} = newx;
                chStruct.allYData{i} = newy;
                                                
            else
                % Make a 0 value constant
                chStruct.allXData{i} = UD.dataSet(i).timeRange;
                chStruct.allYData{i} = [0 0];
            end
        else
            chStruct.allXData{i} = xData;
            chStruct.allYData{i} = yData;
        end
    end

    if ~isfield(UD,'channels') | isempty(UD.channels)
        UD.channels = chStruct;
    else
        UD.channels(end+1) = chStruct;
    end

    % Add new entry to the channel display listbox
    if length(labelStr)>22
        newStr = [labelStr(1:18) '...      '];
    else
        newStr = [labelStr char(32*ones(1,29-length(labelStr)))];
    end
    
    % Update the channel display listbox
    if UD.numChannels==0
        set(UD.hgCtrls.chanListbox,'String',newStr);
    else
        chanStr = get(UD.hgCtrls.chanListbox,'String');
        set(UD.hgCtrls.chanListbox,'String',strvcat(chanStr,newStr));
    end
    
    UD.numChannels = UD.numChannels+1;

    % Set the undo action to delete this channel
    UD = update_undo(UD,'add','channel',UD.numChannels,[]);

    UD = set_dirty_flag(UD);

    if isfield(UD,'simulink') & ~isempty(UD.simulink)
        UD.simulink = sigbuilder_block('add_outport',UD.simulink,labelStr);
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE_CHANNEL - Remove the channel from its current axes
% 
function UD = hide_channel(UD,index)

    % Delete the associated line if it exists
    if ~isempty(UD.channels(index).lineH)
        delete(UD.channels(index).lineH);
        UD.channels(index).lineH = [];
    end

    % Update the channel display listbox
    chanStr = get(UD.hgCtrls.chanListbox,'String');
    chanStr(index,(end-6):end) = '       ';
    set(UD.hgCtrls.chanListbox,'String',chanStr);

    % Remove reference to this channel from the axes
    axesInd = [];
    if (~isempty(UD.channels(index).axesInd) & UD.channels(index).axesInd~=0)
        axesInd = UD.channels(index).axesInd;
        chAxesInd = find(UD.axes(axesInd).channels==index);
        UD.axes(axesInd).channels(chAxesInd) = [];
    end
    
    UD.channels(index).axesInd = 0;
    UD = update_show_menu(UD);    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE_CHANNEL - Delete a channel from the repository and
% insure the remaining channels are consistent.
% 
function UD = remove_channel(UD,index)

	axIdx = UD.channels(index).axesInd;
    UD = hide_channel(UD,index);    
	
	if axIdx>0
		UD = remove_axes(UD,axIdx);
	end
	
    outIndex = UD.channels(index).outIndex;

	% Update the channel listbox
    chanStr = get(UD.hgCtrls.chanListbox,'String');
    chanStr(index,:) = [];
    set(UD.hgCtrls.chanListbox,'String',chanStr,'Value',1);


    moveChannels = [];
    if (index~=UD.numChannels)
        moveChannels = (index+1):UD.numChannels;
        moveDownChannels = UD.channels(moveChannels);
        UD.channels = [UD.channels(1:(index-1)) moveDownChannels];

        % Update references to the moved channels
        for i=moveChannels-1;
            if ~isempty(UD.channels(i).lineH)
                lineUD = get(UD.channels(i).lineH,'UserData');
                lineUD.index = i;
                set(UD.channels(i).lineH,'UserData',lineUD);
                mvAxesInd = UD.channels(i).axesInd;
                chAxesInd = find(UD.axes(mvAxesInd).channels==i+1);
                UD.axes(mvAxesInd).channels(chAxesInd) = i;
            end
        end
    else
        UD.channels = UD.channels(1:(index-1));
    end

    % Correct data set channel references
    for i=1:length(UD.dataSet)
        chanIdx = UD.dataSet(i).activeDispIdx;
        chanIdx(chanIdx==index) = [];
        decChanIdx = chanIdx>index;
        chanIdx(decChanIdx) = chanIdx(decChanIdx)-1;
        UD.dataSet(i).activeDispIdx = chanIdx;
    end


    % Correct existing outIndex if needed
    if outIndex~=UD.numChannels
        decrementIdx = (outIndex+1):UD.numChannels;    
        chanOutIndex = cat(1,UD.channels(1:(UD.numChannels-1)).outIndex);
        for i=1:(UD.numChannels-1)
            if any(UD.channels(i).outIndex == decrementIdx)
                UD.channels(i).outIndex = UD.channels(i).outIndex-1;
            end
        end
    end

    if isfield(UD,'simulink') & ~isempty(UD.simulink)
        UD.simulink = sigbuilder_block('delete_outport',UD.simulink,index);
    end
    
    UD.numChannels = UD.numChannels-1;
    UD = set_dirty_flag(UD);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE_AXES 
% 
function UD = remove_axes(UD,index,doFast)

    if nargin<3
        doFast = 0;
    end

    oldAxStruct = UD.axes(index);
    
    % Reset the axesInd and lineH for all channels in this axes
    channels = UD.axes(index).channels;
    for chNum = channels;
        UD.channels(chNum).axesInd = 0;
        UD.channels(chNum).lineH = [];
    end
            
    % Reorder all the remaining axes and their legend
    moveAxesInd = (index+1):UD.numAxes;
    
    if ~isempty(moveAxesInd)
        for oldAxInd = moveAxesInd,
            axUD = get(UD.axes(oldAxInd).handle,'UserData');
            axUD.index = oldAxInd-1;
            set(UD.axes(oldAxInd).handle,'UserData',axUD);
            for chNum = UD.axes(oldAxInd).channels
                UD.channels(chNum).axesInd = oldAxInd-1;
            end
            if (axUD.index == 1)
                xl = get(UD.axes(oldAxInd).handle,'XLabel');
                if (UD.common.dispMode==1)
                    set(xl,'String','Time (sec)','FontWeight','Bold');  
                    set(UD.axes(oldAxInd).handle,'XTickLabelMode','auto');
                else    
                    set(UD.axes(oldAxInd).handle,'XTickLabel','','XTickLabelMode','manual','FontWeight','Bold');
                    set(xl,'String','Event time sequence'); 
                end 
            end
        end
        UD.axes = [UD.axes(1:(index-1)) UD.axes(moveAxesInd)];
    else
        UD.axes(index) = [];    
    end
    
    % Delete the axes
    delete(oldAxStruct.handle);
    UD.numAxes = UD.numAxes-1;
    
    if UD.numAxes>0
	    % Recalculate the vertical proportion for the remaining axes
	    ySizeIncrease = (1/(1-oldAxStruct.vertProportion))-eps;
	    for(i=1:UD.numAxes)
	        UD.axes(i).vertProportion = ySizeIncrease*UD.axes(i).vertProportion;
	    end
	    UD.current.axes = UD.axes(1).handle;
	else
        UD.current.axes = 0;
	end
    
    % Call the resize function to structure the remaining axe
    if ~doFast
        UD = resize(UD);
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QUICK_DELETE_ALL_CHANNELS_AXES
% 
function UD = quick_delete_all_channels_axes(UD)

    % Destroy the channels data
    UD.channels = [];
    UD.numChannels = 0;
    
    if ~isfield(UD,'axes')
        return;
    end
    
    % Destroy the axes
    allAxes = [];
    for axStruct = UD.axes
        allAxes = [allAxes axStruct.handle];
    end
    delete(allAxes);
    set(UD.hgCtrls.chanListbox,'Value',1,'String',' ');
    
    % Destroy the axes data
    UD.axes = [];
    UD.numAxes = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD_NONREPEAT_NORMALIZED_SIGNAL_TO_GCA
% 
function UD = add_nonrepeat_normalized_signal(UD,xNorm,yNorm,dontScale,add_new)

    % Check input args
    if nargin<4
        dontScale = 0;
    end
    
    chIdx = UD.current.channel;

    % Force out of any zoom mode
    UD = mouse_handler('ForceMode',UD.dialog,UD,1);
    
    if isempty(UD.current.axes) | UD.current.axes==0
    	if length(UD.axes)==0
    		dontScale = 1;
    	else
        	UD.current.axes = UD.axes(1).handle;
        end
    end


    % Calculate the actual X,Y values based on the current zoomed view
    if dontScale
        xData = xNorm;
        yData = yNorm;
    else
        xData = UD.common.dispTime(1) + xNorm*diff(UD.common.dispTime);
        ylim = get(UD.current.axes,'YLim');
        yData = yNorm;
    end

    % Set the first and last X points so the signal is defined for the
    % entire time range
    xData(1) = UD.common.minTime;
    xData(end) = UD.common.maxTime;

    % Create the new channel and add to gca
    if (add_new==0 & chIdx>0) % We are replacing a channel
        UD = apply_new_channel_data(UD,chIdx,xData,yData);
        UD = rescale_axes_to_fit_data(UD,UD.channels(chIdx).axesInd,chIdx,1);
        UD = set_dirty_flag(UD);
    else
        UD = new_channel(UD.dialog,UD,xData,yData,0,0);
        if is_space_for_new_axes(UD)
    	    UD = new_axes(UD,1,[]);
            UD = new_plot_channel(UD,UD.numChannels,1);  
            UD.current.mode = 3;
            UD.current.channel = UD.numChannels;
            UD.current.bdPoint = [0 0];
            UD.current.bdObj = UD.channels(UD.numChannels).lineH;
        end
        UD = update_channel_select(UD);
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD_REPEAT_NORMALIZED_SIGNAL_TO_GCA
% 
function UD = add_repeat_normalized_signal(UD,xNorm,yNorm,freq,dontScale,add_new)
    
    % Check input args
    if nargin<5
        dontScale = 0;
    end

    chIdx = UD.current.channel;

    % Force out of any zoom mode
    UD = mouse_handler('ForceMode',UD.dialog,UD,1);

    if isempty(UD.current.axes) | UD.current.axes==0
    	if length(UD.axes)==0
    		dontScale = 1;
    	else
        	UD.current.axes = UD.axes(1).handle;
        end
    end

    % Calculate the actual X,Y values based on the freq
    T = 1/freq;
    n = ceil((UD.common.maxTime - UD.common.minTime)/T)+1;
    nsub = length(xNorm);
    xData = (xNorm(:) * ones(1,n)*T) + (T*ones(nsub,1))*(0:(n-1)) + UD.common.minTime;
    yData = yNorm(:) * ones(1,n);
    xData = xData(:)';
    yData = yData(:)';
    
    % Correct the end points
    I_remove = find(xData > UD.common.maxTime);
    xData(I_remove) = [];
    yData(I_remove) = [];
    xData(1) = UD.common.minTime;
    xData(end) = UD.common.maxTime;

    % Create the new channel and add to gca
    if (add_new==0 & chIdx>0) % We are replacing a channel
        UD = apply_new_channel_data(UD,chIdx,xData,yData);
        UD = rescale_axes_to_fit_data(UD,UD.channels(chIdx).axesInd,chIdx,1);
        UD = set_dirty_flag(UD);
    else
        UD = new_channel(UD.dialog,UD,xData,yData,0,0);
        if is_space_for_new_axes(UD)
    	    UD = new_axes(UD,1,[]);
            UD = new_plot_channel(UD,UD.numChannels,1);  
            UD.current.mode = 3;
            UD.current.channel = UD.numChannels;
            UD.current.bdPoint = [0 0];
            UD.current.bdObj = UD.channels(UD.numChannels).lineH;
        end
        UD = update_channel_select(UD);
    end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET_NEW_TIME_RANGE
% 
function UD = set_new_time_range(UD,range,fromScrollbar)

    if nargin==2 | isempty(fromScrollbar)
        fromScrollbar = 0;
    end
    
    % Ignore if the range is not valid
    if diff(range)<=0
        return;
    end
    
    % Constrain the range to be within the total extremes
    if range(1)<UD.common.minTime
        range(1)=UD.common.minTime;
    end
    if range(2)>UD.common.maxTime
        range(2)=UD.common.maxTime;
    end


    % Set the new axes limits 
    for i=1:UD.numAxes
        set(UD.axes(i).handle,'XLim',range);
    end

    UD.common.dispTime = range;

    % Set the properties of the scrollbar
    if ~fromScrollbar
        scrollBarVisible = strcmp(get(UD.tlegend.scrollbar,'Visible'),'on');

        if(range(1)== UD.common.minTime & range(2)== UD.common.maxTime) 
            if scrollBarVisible
                figbgcolor = get(UD.dialog,'Color');
                set(UD.tlegend.scrollbar,'Enable','off','Visible','off');
                UD.current.axesExtent = UD.current.axesExtent + [0 -1 0 1]*UD.geomConst.scrollHieght;
                for(i=1:UD.numAxes)
                    pos = calc_new_axes_position(UD,i);
                    set(UD.axes(i).handle,'Position',pos);
                end
            end
        else
            if ~scrollBarVisible
                visTime = diff(range);
                pageStep = visTime/(UD.common.maxTime - UD.common.minTime - visTime);
                oldScrollPos = get(UD.tlegend.scrollbar,'Position');
                scrollPos = [	oldScrollPos(1:2) ...
                				UD.current.axesExtent(3)-UD.geomConst.axesOffset(1) ...
                				oldScrollPos(4)];
                set(UD.tlegend.scrollbar, ...
                        'Min',                  UD.common.minTime, ...
                        'Max',                  UD.common.maxTime-visTime, ...
                        'SliderStep',           [0.1 0.9]*pageStep, ...
                        'Value',                range(1), ...
                        'BackgroundColor',      'w', ...
                        'Position',             scrollPos, ...
                        'Visible',              'on', ...
                        'Enable',               'on');
                UD.current.axesExtent = UD.current.axesExtent + [0 1 0 -1]*UD.geomConst.scrollHieght;
                for(i=1:UD.numAxes)
                    pos = calc_new_axes_position(UD,i);
                    set(UD.axes(i).handle,'Position',pos);
                end
            end
        end
    end
    update_all_axes_label(UD);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCROLLBAR_HANDLER
% 
function UD = scrollbar_handler(UD)
    startTime = get(UD.tlegend.scrollbar,'Value');
    trange = UD.common.dispTime + (startTime - UD.common.dispTime(1));
    UD = set_new_time_range(UD,trange,1);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET_NEW_TOTAL_TIME_RANGE
% 
function UD = set_new_total_time_range(UD,minTime,maxTime)

    moveMax = (maxTime ~= UD.common.maxTime);
    moveMin = (minTime ~= UD.common.minTime);
    
    if (~moveMax & ~moveMin)
        return;
    end
    
    % Update UNDO 
    undoData.timeRange = UD.common.dispTime;
    undoData.channels = UD.channels;
    
    UD = update_undo(UD,'timeRange','dataSet',0,undoData);
    
    % Add a point to each channel at the new maximum time
    for i=1:UD.numChannels
        X = UD.channels(i).xData;
        Y = UD.channels(i).yData;

        % If signal is piecewise constant at current max time
        % just move the X value
        if moveMax
            if (maxTime > UD.common.maxTime)
                if Y(end-1)==Y(end)
                    X(end) = maxTime;
                else
                    X(end+1) = maxTime;
                    Y(end+1) = Y(end);
                end
            else
                yNew = scalar_interp(maxTime,X,Y,-1);
                delIdx = (X>=maxTime);
                X(delIdx) = [];
                Y(delIdx) = [];
                X = [X maxTime];
                Y = [Y yNew];
            end
        end

        if moveMin
            if (minTime < UD.common.minTime)
                if Y(1)==Y(2)
                    X(1) = minTime;
                else
                    X = [minTime X];
                    Y = [Y(1) Y];
                end
            else
                yNew = scalar_interp(minTime,X,Y,1);
                delIdx = (X<=minTime);
                X(delIdx) = [];
                Y(delIdx) = [];
                X = [minTime X];
                Y = [yNew Y];
            end
        end

        UD = apply_new_channel_data(UD,i,X,Y,1);
    end

    UD.common.maxTime = maxTime;
    UD.common.minTime = minTime;

    UD = set_new_time_range(UD,[minTime maxTime]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                            MISC HG UTILITIES                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MISC_HG_UTILITIES   

function top_of_hg_stack(hgObj,parent)
    if nargin<2
        parent = get(hgObj,'Parent');
    end
    allChildren = get(parent,'Children');
    isObj = (allChildren==hgObj);
    set(parent,'Children',[hgObj ; allChildren(~isObj)]);


function bottom_of_hg_stack(hgObj,parent)
    if nargin<2
        parent = get(hgObj,'Parent');
    end
    parent = get(hgObj,'Parent');
    allChildren = get(parent,'Children');
    isObj = (allChildren==hgObj);
    set(parent,'Children',[allChildren(~isObj) ; hgObj]);


function adjust_width(hgObjs,deltaWidth)

    if length(hgObjs)>1
        positionCell = get(hgObjs,'Position');
        positionMatrix = cat(1,positionCell{:});
        positionMatrix(:,3) = positionMatrix(:,3) + deltaWidth;
        newPositionCell = num2cell(positionMatrix,2);
        set(hgObjs,{'Position'},newPositionCell);
    else
        oldPos = get(hgObjs,'Position');
        set(hgObjs,'Position',oldPos+[0 0 deltaWidth 0]);
    end

function adjust_height(hgObjs,deltaHeight)

    if length(hgObjs)>1
        positionCell = get(hgObjs,'Position');
        positionMatrix = cat(1,positionCell{:});
        positionMatrix(:,4) = positionMatrix(:,4) + deltaHeight;
        newPositionCell = num2cell(positionMatrix,2);
        set(hgObjs,{'Position'},newPositionCell);
    else
        oldPos = get(hgObjs,'Position');
        set(hgObjs,'Position',oldPos+[0 0 0 deltaHeight]);
    end

function adjust_y_coord(hgObjs,deltaY)

    if length(hgObjs)>1
        positionCell = get(hgObjs,'Position');
        positionMatrix = cat(1,positionCell{:});
        positionMatrix(:,2) = positionMatrix(:,2) + deltaY;
        newPositionCell = num2cell(positionMatrix,2);
        set(hgObjs,{'Position'},newPositionCell);
    else
        oldPos = get(hgObjs,'Position');
        set(hgObjs,'Position',oldPos+[0 deltaY 0 0]);
    end

function adjust_x_coord(hgObjs,deltaX)

    if length(hgObjs)>1
        positionCell = get(hgObjs,'Position');
        positionMatrix = cat(1,positionCell{:});
        positionMatrix(:,1) = positionMatrix(:,1) + deltaX;
        newPositionCell = num2cell(positionMatrix,2);
        set(hgObjs,{'Position'},newPositionCell);
    else
        oldPos = get(hgObjs,'Position');
        set(hgObjs,'Position',oldPos+[deltaX 0 0 0]);
    end

% Return empty if conversion fails
function out = eval_to_real_scalar(str,description)

	try,
		out = evalin('base',str);
	catch,
		out = [];
        errordlg(sprintf('Could not evaluate %s "%s"\n%s', description, str, lasterr));
		return;
	end
	
	if length(out)>1 | imag(out)>0
		errordlg(sprintf('%s parameter should be a real scalar',description ));
		out = [];
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNIQUEIFY_STR_WITH_NUMBER
% 
function newStr = uniqueify_str_with_number(str,ignoreThisIdx,varargin)

    if isempty(ignoreThisIdx)
        ignoreThisIdx = 0;
    end
    
    % See if this label ends with a number
    lsti = length(str);
    numStr = '';
    while lsti>0 & isNumChar(str(lsti))
        numStr = [str(lsti) numStr];
        lsti = lsti-1;
    end 
    rootStr = str(1:lsti);
    if ~isempty(numStr)
        num = str2num(numStr);
    else
        num = [];
    end
    
    % Search through other labels for same root
    maxnum = 0;
    mustChange = 0;
    for i=1:length(varargin)
        if i~=ignoreThisIdx & (isempty(rootStr) | strncmp(rootStr,varargin{i},lsti))
            trailNum = str2num(varargin{i}((lsti+1):end));
            if ~isempty(trailNum)
                if ~isempty(num) & trailNum==num
                    mustChange = 1;
                end
                if trailNum>maxnum
                    maxnum = trailNum;
                end
            elseif isempty(num) % Exactly the same string
                mustChange = 1;
            end
        end
    end

    if(mustChange)
        newStr = [rootStr num2str(maxnum+1)];
    else
        newStr = str;
    end
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET_DISP_STRING - Convert a number to a string
% 
function str = get_disp_string(value)
    str = num2str(value);        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                             DATA SET FUNCTIONS                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DATA_SET_FUNCTIONS   

% Related UserData fields:
%
% UD.dataSet(i).activeDispIdx: Channels displayed.
%              .timeRange
%              .name
%            
% UD.current.dataSetIdx
%
% UD.channel(i).allXData
%              .allYData
             
             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATASET_STORE - Copy the active values to the data set
% repository
% 
function UD = dataSet_store(UD)

    dsIdx = UD.current.dataSetIdx;
    
    for chIdx=1:length(UD.channels)
        UD.channels(chIdx).allXData{dsIdx} = UD.channels(chIdx).xData;
        UD.channels(chIdx).allYData{dsIdx} = UD.channels(chIdx).yData;
    end

    UD.dataSet(dsIdx).timeRange = [UD.common.minTime UD.common.maxTime];
    UD.dataSet(dsIdx).displayRange = UD.common.dispTime;
    UD.dataSet(dsIdx).activeDispIdx = fliplr(unique([UD.axes.channels]));
    


function UD = dataSet_sync_menu_state(UD)

    dsCnt = length(UD.dataSet);
    
    if dsCnt==1
        hgObjs = [  UD.menus.figmenu.tabdelete ...
                    UD.menus.figmenu.tabMoveRight ...
                    UD.menus.figmenu.tabMoveLeft ...
                    UD.menus.tabContext.delete ...
                    UD.menus.tabContext.right ...
                    UD.menus.tabContext.left ...
                 ];
		set(hgObjs,'Enable','off');
    else
		set([UD.menus.figmenu.tabdelete UD.menus.tabContext.delete],'Enable','on');
		if UD.current.dataSetIdx==1
		    set([UD.menus.figmenu.tabMoveLeft UD.menus.tabContext.left],'Enable','off');
		else
		    set([UD.menus.figmenu.tabMoveLeft UD.menus.tabContext.left],'Enable','on');
		end
		
		if UD.current.dataSetIdx==dsCnt
		    set([UD.menus.figmenu.tabMoveRight UD.menus.tabContext.right],'Enable','off');
		else
		    set([UD.menus.figmenu.tabMoveRight UD.menus.tabContext.right],'Enable','on');
		end
    end

function UD = dataSet_copy(UD,copyIdx)
    
    UD = dataSet_store(UD);
    
    UD.dataSet(end+1) = UD.dataSet(copyIdx);
    
    % Change the name slightly
    oldName = UD.dataSet(copyIdx).name;
    allNames = {UD.dataSet.name};

    newname = uniqueify_str_with_number(oldName,0,allNames{:});
    UD.dataSet(end).name = newname;
    
    newIdx = length(UD.dataSet);
    
    for chIdx=1:length(UD.channels)
        UD.channels(chIdx).allXData{end+1} = UD.channels(chIdx).allXData{copyIdx};
        UD.channels(chIdx).allYData{end+1} = UD.channels(chIdx).allYData{copyIdx};
    end

    sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,newname);
    UD = dataSet_sync_menu_state(UD);
    UD = update_tab_sub_menu(UD);

    set(UD.dialog,'UserData',UD) % Push changes before calling vnv_manager
    vnv_notify('sbBlkGroupAdd',UD.simulink.subsysH,newIdx);
    
    
function UD = dataSet_delete(UD,deleteIdx)

    if length(UD.dataSet)<2
        return;
    end
    
    if nargin<2 | isempty(deleteIdx)
        deleteIdx = UD.current.dataSetIdx;
    end
    
    if deleteIdx==1
        UD = dataSet_activate(UD,2);
    else
        UD = dataSet_activate(UD,deleteIdx-1);
    end

    sigbuilder_tabselector('removeentry',UD.hgCtrls.tabselect.axesH,deleteIdx);
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);
    UD.dataSet(deleteIdx) = [];

    for chIdx=1:length(UD.channels)
        UD.channels(chIdx).allXData(deleteIdx) = [];
        UD.channels(chIdx).allYData(deleteIdx) = [];
    end
    
    if deleteIdx==1
        UD.current.dataSetIdx = 1;
    end
    UD = dataSet_sync_menu_state(UD);
    UD = update_tab_sub_menu(UD);
    
    % Update the vnv manager
    set(UD.dialog,'UserData',UD) % Push changes before calling vnv_manager
    vnv_notify('sbBlkGroupDelete',UD.simulink.subsysH,deleteIdx);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATASET_LEFT - Move this tab one position to the left
% 
function UD = dataSet_left(UD)

    dsIdx = UD.current.dataSetIdx;
    
    if dsIdx==1
        return;
    end
    
    dsCnt = length(UD.dataSet);
    old2NewIdx = [1:(dsIdx-2) dsIdx-[0 1] (dsIdx+1):dsCnt];
    UD = dataSet_reorder(UD,old2NewIdx,dsIdx-1);
    UD = update_undo(UD,'move','dataSet',dsIdx,dsIdx-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATASET_RIGHT - Move this tab one position to the left
% 
function UD = dataSet_right(UD)

    dsIdx = UD.current.dataSetIdx;
    dsCnt = length(UD.dataSet);
    
    if dsIdx==dsCnt
        return;
    end
    
    old2NewIdx = [1:(dsIdx-1) dsIdx+[1 0] (dsIdx+2):dsCnt];
    UD = dataSet_reorder(UD,old2NewIdx,dsIdx+1);
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,dsIdx+1,1);
    UD = update_undo(UD,'move','dataSet',dsIdx,dsIdx+1);


function UD = dataSet_reorder(UD,old2NewIdx,newActiveIdx)
    UD.dataSet = UD.dataSet(old2NewIdx);
    for chIdx=1:length(UD.channels)
        UD.channels(chIdx).allXData = UD.channels(chIdx).allXData(old2NewIdx);
        UD.channels(chIdx).allYData = UD.channels(chIdx).allYData(old2NewIdx);
    end
    UD.current.dataSetIdx = newActiveIdx;
    
    % Find the tab that moved
    deltaIdx = old2NewIdx - (1:(length(old2NewIdx)));
    destIdx = find(deltaIdx == max(abs(deltaIdx)) | deltaIdx == -max(abs(deltaIdx)));
    destIdx = destIdx(1);
    srcIdx = find(deltaIdx ~= 0);
    if deltaIdx(destIdx) > 0
        srcIdx = srcIdx(end);
    else
        srcIdx = srcIdx(1);
    end
    
    sigbuilder_tabselector('movetab',UD.hgCtrls.tabselect.axesH,srcIdx,destIdx);
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,newActiveIdx,1);
    UD = dataSet_sync_menu_state(UD);
    UD = update_tab_sub_menu(UD);

    % Notify the signal builder
    remap(old2NewIdx) = 1:(length(UD.dataSet));
    vnv_notify('sbBlkGroupMove',UD.simulink.subsysH,remap,newActiveIdx);
    

function out = isNumChar(c)
    out = isempty(strtok(c,'0123456789'));


function UD = dataSet_rename(UD,dsIdx,newName)

    UD.dataSet(dsIdx).name = newName;
    sigbuilder_tabselector('rename',UD.hgCtrls.tabselect.axesH,dsIdx,newName);
    UD = update_tab_sub_menu(UD);
    

function UD = dataSet_activate(UD,newDatasetIdx,suppressStore)

    oldDatasetIdx = UD.current.dataSetIdx;
    if oldDatasetIdx==-1
        oldDatasetIdx = [];
        oldVisChannels = [];
        oldCnt = 0;
    else
        oldVisChannels = UD.dataSet(oldDatasetIdx).activeDispIdx;
        oldCnt = length(oldVisChannels);
    end
    newVisChannels = UD.dataSet(newDatasetIdx).activeDispIdx;
    newCnt = length(newVisChannels);
   
    DO_FAST = 1;

    if newDatasetIdx == oldDatasetIdx
        return;
    end     

    if nargin<3
        suppressStore = 0;
    end

    % Force out of any zoom mode
    switch(UD.current.mode)
    case {1,3}
        % Do nothing
    otherwise
        UD = mouse_handler('ForceMode',UD.dialog,UD,1);
    end
    
    if strcmp(get(UD.tlegend.scrollbar,'Visible'),'on')
        set(UD.tlegend.scrollbar,'Enable','off','Visible','off');
        UD.current.axesExtent = UD.current.axesExtent + [0 -1 0 1]*UD.geomConst.scrollHieght;
    end
    
    if UD.current.dataSetIdx >= 1
        set(UD.menus.tabmenus(UD.current.dataSetIdx),'Checked','off');
    end
    set(UD.menus.tabmenus(newDatasetIdx),'Checked','on');
    
    UD = cant_undo(UD);
    if ~suppressStore
        UD = dataSet_store(UD);
    end
    
    set(UD.dialog,'Pointer','watch');
    

    if isequal(oldVisChannels,newVisChannels)
        applyDataOnly = ones(1,oldCnt);
        lastApply = oldCnt;
    else
        newCnt = length(newVisChannels);
    
        % Determine if we must add or remove channels
        if oldCnt > newCnt
            if newCnt>0
                applyDataOnly = oldVisChannels(1:newCnt)==newVisChannels;
            end
            lastApply = newCnt;
            for i=(newCnt+1):oldCnt
                UD = remove_axes(UD,newCnt+1,DO_FAST);
            end
            
            % Update the HG line handles
            if newCnt>0
                [UD.channels(newVisChannels).lineH] = deal(UD.channels(oldVisChannels(1:newCnt)).lineH);
                [UD.channels(newVisChannels).axesInd] = deal(UD.channels(oldVisChannels(1:newCnt)).axesInd);
            end

        elseif newCnt > oldCnt
            if oldCnt>0
                applyDataOnly = oldVisChannels==newVisChannels(1:oldCnt);
            else
                applyDataOnly = [];
            end
            lastApply = oldCnt;
            cantShow = 0;
            for i=(oldCnt+1):newCnt
                if is_space_for_new_axes(UD)
                    UD = new_axes(UD,i,[],[-1 1],UD.common.dispTime,DO_FAST); 
                else
                    cantShow = cantShow+1;
                end
            end
            if cantShow>0;
                newVisChannels(oldCnt -(1:cantShow)) = [];
                UD.dataSet(newDatasetIdx).activeDispIdx = newVisChannels;
                newCnt = newCnt - cantShow;
            end

            % Update the HG line handles
            if oldCnt>0
                [UD.channels(newVisChannels(1:oldCnt)).lineH] = deal(UD.channels(oldVisChannels).lineH);
                [UD.channels(newVisChannels(1:oldCnt)).axesInd] = deal(UD.channels(oldVisChannels).axesInd);
            end

        else
            applyDataOnly = oldVisChannels==newVisChannels;
            lastApply = newCnt;

            % Update the HG line handles
            [UD.channels(newVisChannels).lineH] = deal(UD.channels(oldVisChannels).lineH);
            [UD.channels(newVisChannels).axesInd] = deal(UD.channels(oldVisChannels).axesInd);
        end
        
        % Update the HG line handles
        newInvisible = setdiff(1:length(UD.channels),newVisChannels);
        if ~isempty(newInvisible)
            [UD.channels(newInvisible).lineH] = deal([]);
            [UD.channels(newInvisible).axesInd] = deal(0);
        end
        
        % Update the axes channel idx
        if lastApply>0
            chCell = num2cell(newVisChannels(1:lastApply));
            [UD.axes(1:lastApply).channels] = deal(chCell{:});
        end
    end
        
    
    % Copy actived data from repository
    for chIdx=1:length(UD.channels)
        UD.channels(chIdx).xData = UD.channels(chIdx).allXData{newDatasetIdx};
        UD.channels(chIdx).yData = UD.channels(chIdx).allYData{newDatasetIdx};
    end
    
    % Set current values to default
    UD.current.mode = 1;
    if isempty(UD.dataSet(newDatasetIdx).activeDispIdx)
        UD.current.channel  = 0;
        UD.current.axes = 0;        
    else
        UD.current.channel  = UD.dataSet(newDatasetIdx).activeDispIdx(end);
        UD.current.axes = UD.axes(1).handle;        
    end
    
    UD.current.editPoints = [];
    UD.current.tempPoints = [];
    UD.current.bdPoint  = [0 0];
    UD.current.bdObj = [];      
    UD.current.prevbdObj = [];      
    UD.current.selectLine = [];     
    UD.current.zoomStart = [];      
    UD.current.zoomAxesInd = [];            
    UD.current.zoomXLine = [];          
    UD.current.zoomYLine = [];
    UD.current.lockOutSingleClick = 0;          
    UD.common.dispMode = 1;
    UD.common.minTime   = UD.dataSet(newDatasetIdx).timeRange(1);
    UD.common.maxTime   = UD.dataSet(newDatasetIdx).timeRange(2);
    UD.common.dispTime = UD.dataSet(newDatasetIdx).timeRange;
    UD.current.dataSetIdx = newDatasetIdx;
    
    % Set the YLim to the full scale for all axes
    if length(UD.axes)>1
        set([UD.axes.handle],{'XLim'},{UD.dataSet(newDatasetIdx).timeRange});
    elseif length(UD.axes)>0
        set(UD.axes.handle,'XLim',UD.dataSet(newDatasetIdx).timeRange);
    end
    
    % Display the required channels
    lineUD.index = 0;
    lineUD.type = 'Channel';
    
    for i=1:lastApply
        chIdx = newVisChannels(i);
        lineUD.index = chIdx;
        
        if (applyDataOnly(i))
            set(    UD.channels(chIdx).lineH ...
                    ,'UserData',        lineUD ...            
                    ,'XData',           UD.channels(chIdx).xData ...            
                    ,'YData',           UD.channels(chIdx).yData); 
        else
            set(    UD.channels(chIdx).lineH ...
                    ,'UserData',        lineUD ...
                    ,'Color',           UD.channels(chIdx).color ...
                    ,'LineWidth',       UD.channels(chIdx).lineWidth ...
                    ,'LineStyle',       UD.channels(chIdx).lineStyle ...
                    ,'XData',           UD.channels(chIdx).xData ...            
                    ,'YData',           UD.channels(chIdx).yData); 

            % Upate the label text
            set(UD.axes(i).labelH,'String',UD.channels(chIdx).label,'Color',UD.channels(chIdx).color);
        end           
    end
    
    
    for i=(lastApply+1):newCnt
        chIdx = newVisChannels(i);
        [UD,lineH] = new_plot_channel(UD,chIdx,i,DO_FAST);
    end
    
    
%    if isfield(UD.dataSet,'displayRange') && ~isempty(UD.dataSet(newDatasetIdx).displayRange)
%        UD = set_new_time_range(UD,UD.dataSet(newDatasetIdx).displayRange);
%    else
%        UD = set_new_time_range(UD,UD.dataSet(newDatasetIdx).timeRange);
%    end
    

    % Update the channel listbox
    numChan = length(UD.channels);
    notShown = logical(zeros(1,numChan));
    for i=1:numChan
        notShown(i) = isempty(UD.channels(i).lineH);
    end
    chanStr = get(UD.hgCtrls.chanListbox,'String');
    chanStr(notShown,(end-6):end) = ' ';
    chanStr(~notShown,(end-6):end) = char(ones(sum(~notShown),1) * '(shown)');
    set(UD.hgCtrls.chanListbox,'String',chanStr);

    UD = update_channel_select(UD);
    UD = update_show_menu(UD);
    UD = set_dirty_flag(UD);
    UD = dataSet_sync_menu_state(UD);
    
    for i=1:newCnt
        UD = rescale_axes_to_fit_data(UD,i,[],1,DO_FAST);
    end
    
    % Adjust all axes sizes and label positions
    UD = resize(UD);
    
    set(UD.dialog,'Pointer','arrow');

    % Send an event to the assert control to refresh its display
    if isfield(UD,'simulink') && ~isempty(UD.simulink)
        vnv_notify('sbBlkGroupChange',UD.simulink.subsysH,newDatasetIdx);
        
        if vnv_enabled && isfield(UD,'verify') && isfield(UD.verify,'jVerifyPanel')
            vnv_panel_mgr('sbGroupChange',UD.simulink.subsysH,UD.verify.jVerifyPanel);
            % UD = sigbuild_verify_control('groupChange', UD);
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                        MOUSE HANDLING STATE MACHINE                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MOUSE_HANDLING_STATE_MACHINE   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MOUSE_HANDLER
% 
function [UD,modified] = mouse_handler(method,dialog,UD,varargin)
%mouse_handler - Handle mouse events in the stv tool
%

modified = 1;  % Assume that userData has changed

if isempty(UD)
    modified = 0;
    return;
end

% DROP the event if the UI is iced!
if in_iced_state_l(UD),
   switch UD.current.mode,
       case {9, 10, 11}, 
           % allow zooming modes.
       otherwise,
           switch method,
               case 'ForceMode',
                   % allow zooming mode transitions.
               otherwise,
                    modified = 0;
                    return;
            end;
   end;
end;

% 
% The mouse handler is implemented as a state machine
%
%

% Return early if we are above the drawing axes
Pfig = get(dialog,'CurrentPoint');

% Useful variables (Don't use in force mode)
if ~strcmp(method,'ForceMode')
    if ~in_drag_mode(UD.current.mode) && ...
            ((Pfig(2) < UD.current.axesExtent(2)) || ...
             (Pfig(2) > UD.current.axesExtent*[0;1;0;1]))
        modified = 0;
        return;
    end
    
    selctType = get(dialog,'SelectionType');
    currObj = gco;
    currAx = get(dialog,'CurrentAxes');
end
oldMode = UD.current.mode;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     EVENT DETERMINATION         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


switch(method)
    case 'ButtonDown'
        % Common button down actions:
        UD.current.prevbdObj = UD.current.bdObj;
        UD.current.axes = currAx;
        UD.current.bdPoint = Pfig;
        UD.current.bdObj = currObj;
        UD.current.bdMode = oldMode;
        update_gca_display(UD);

        switch(selctType)
        case 'normal'
            event = 'BD';
        case 'extend'
            event = 'EBD';
        case 'alt'
            event = 'ABD';
        case 'open'
            event = 'OBD';
        end
    case 'ButtonUp'
        switch(selctType)
        case 'normal'
            event = 'BU';
        case 'extend'
            event = 'EBU';
        case 'alt'
            event = 'ABU';
        case 'open'
            event = 'OBU';
        end
    case 'ButtonMotion'
        switch(selctType)
        case 'normal'
            event = 'BM';
        case 'extend'
            event = 'EBM';
        case 'alt'
            event = 'ABM';
        case 'open'
            event = 'OBM';
       end
    case 'ForceMode'
        event = 'FRC';
        nextMode = varargin{1};
    case 'KeyPress'
        event = 'KP';
    otherwise
        error('Unrecognized method');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         TRANSITION LOGIC        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch(UD.current.mode)
case 1 % Normal mode, nothing selected
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    if(strcmp(event,'OBD'))
        [UD,modified] = toolbar_handler('fullview',UD.dialog,UD);
    end

    if(strcmp(event,'BD') & ~isempty(currObj))
        UD = calc_new_drag_mode(UD,currObj,Pfig,currAx);
    end

    if(strcmp(event,'BM') | strcmp(event,'EBM') | strcmp(event,'ABM') | strcmp(event,'OBM') )
        refresh_dynamic_pointer(UD,Pfig);
    end
    
    if(strcmp(event,'EBD') )
        UD = calc_new_extend_drag_mode(UD,currObj,Pfig,currAx);
    end
    
    if(strcmp(event,'ABD'))
        UD = perform_abd_select(UD,currObj);
    end
    
    
    
case 2 % Splitter adjust mode

    % Saturate the splitter at a reasonable width
    if Pfig(1) < 15*UD.geomConst.figBuffer
        newXpos = 15*UD.geomConst.figBuffer; 
    else
        newXpos = Pfig(1);
    end
    
    if(strcmp(event,'BM'))
        % Move the position of the splitter to follow the mouse
        % If opaque dragging is too expensive.
         splitterPos = UD.current.splitterPos;
         splitterPos(1) = newXpos;
         set(UD.verify.hg.splitter,'Position',splitterPos);
%        deltaWidth = UD.current.splitterStart - Pfig(1);
%        UD = adjust_verify_width(UD,deltaWidth);        
%        UD.current.splitterStart = Pfig(1);
    end

    if(strcmp(event,'BU'))
        deltaWidth = UD.current.splitterStart - newXpos;
        UD = adjust_verify_width(UD,deltaWidth);        
        set(UD.verify.hg.splitter,'Visible','off');
        UD.current.mode = 1;
    end

case 3 % Line edit mode
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    chNum = UD.current.channel;

    if(strcmp(event,'BM') | strcmp(event,'EBM') |strcmp(event,'ABM') )
        refresh_dynamic_pointer(UD,Pfig);
        modified = 0;
        return;
    end

    if(strcmp(event,'ABD'))
        UD = perform_abd_select(UD,currObj);
    end
    
    if(strcmp(event,'EBD') )
        UD = calc_new_extend_drag_mode(UD,currObj,Pfig,currAx);
    end
    
    if(strcmp(event,'BD'))
        if strcmp(get(currObj,'Type'),'line')
            if (currObj==UD.current.prevbdObj)
                % We have buttoned down on the currently 
                % selected channel
                UD.current.lockOutSingleClick = 0;
                Pax = fig_2_ax_coord(Pfig,currAx);
                I = calc_channel_points(UD.channels(chNum),Pfig,currAx);
                UD.current.editPoints = I;
                if(length(I)==2)
                    if(diff(UD.channels(chNum).xData(I))==0)  % Are points in a vertical line?
                        UD.current.mode = 6;
                    else
                        UD.current.mode = 5;
                    end
                else
                    UD.current.mode = 4;
                end
            else
                UD.current.bdMode = 1;   % To prevent adding extraneous points
                UD = calc_new_drag_mode(UD,currObj,Pfig,currAx);
            end
        else
            UD.current.mode = 1;
        end
    end 
    
    if(strcmp(event,'KP'))
        Y = UD.channels(chNum).yData;
        X = UD.channels(chNum).xData;
        switch(get(dialog,'CurrentCharacter'))
        case 27  % Esc
            UD.current.mode = 1;
        
        case 28  % Right arrow (<-)
            if UD.channels(chNum).stepX==0
                X = X - 0.1;
            else
                X = snap_x_vect(UD,X-UD.channels(chNum).stepX,UD.channels(chNum));
            end
            [X,Y] = correct_endpoints(UD,X,Y);
            %set(UD.channels(chNum).lineH,'XData',X);
            %UD.channels(chNum).xData = X;
            UD = apply_new_channel_data(UD,chNum,X,Y);
            UD = set_dirty_flag(UD);
            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum,[]);


        case 29  % Left arrow (->)
            if UD.channels(chNum).stepX==0
                X = X + 0.1;
            else
                X = snap_x_vect(UD,X+UD.channels(chNum).stepX,UD.channels(chNum));
            end
            [X,Y] = correct_endpoints(UD,X,Y);
            %set(UD.channels(chNum).lineH,'XData',X);
            %UD.channels(chNum).xData = X;
            UD = apply_new_channel_data(UD,chNum,X,Y);
            UD = set_dirty_flag(UD);
            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum,[]);

        case 30  % Up arrow (^)
            % Move this point by its step value or the default
            % value of 0.1
            if UD.channels(chNum).stepY==0
                Y = Y + 0.1;
            else
                Y = snap_y_vect(UD, Y+UD.channels(chNum).stepY,UD.channels(chNum));
            end
            %set(UD.channels(chNum).lineH,'YData',Y);
            %UD.channels(chNum).yData = Y;
            UD = apply_new_channel_data(UD,chNum,[],Y);
            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum,[]);

        case 31  % Down arrow (v)
            if UD.channels(chNum).stepY==0
                Y = Y - 0.1;
            else
                Y = snap_y_vect(UD, Y-UD.channels(chNum).stepY,UD.channels(chNum));
            end
            %set(UD.channels(chNum).lineH,'YData',Y);
            %UD.channels(chNum).yData = Y;
            UD = apply_new_channel_data(UD,chNum,[],Y);
            UD = set_dirty_flag(UD);
            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum,[]);

        case 127 % Delete this signal
        	if length(UD.channels)==1
        		warndlg('Can not delete the only signal');
            else
                UD.current.mode = 1;
                UD.adjust.XDisp = [];
                UD.adjust.YDisp = [];
                UD = update_undo(UD,'delete','channel',chNum,UD.channels(chNum));
                UD = remove_channel(UD,chNum);
                UD.current.channel = 0;
           	end    
        end
    end


case 4 % point y adjust
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    Ind = UD.current.editPoints;
    chNum = UD.current.channel;

    if(strcmp(event,'BU'))
        % If we moved less than the single click threshold then 
        % we are selecting this point
        pPrev = UD.current.bdPoint;
        [th,r] = cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
        if r<UD.geomConst.singleClickThresh
            if UD.current.bdMode==1 | UD.current.lockOutSingleClick
                UD.current.mode = 3;
            else 
                UD.current.mode = 7;
            end
            set(UD.channels(chNum).lineH,'YData',UD.channels(chNum).yData);
        else
            % Use the current Y position as the new value
            % of the point being edited.
            Y = UD.channels(chNum).yData;
            Pax = fig_2_ax_coord(Pfig,currAx);
            PfixStep = snap_point(UD,Pax,UD.channels(chNum));
            Y(Ind) = PfixStep(2); % Change the point y value
            UD = apply_new_channel_data(UD,chNum,[],Y);

            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum);
            % We are now in the edit mode of the line
            UD = set_dirty_flag(UD);
            UD.current.mode = 3;
        end 
    end

    if(strcmp(event,'BM'))
        % Use the current Y position as the new value
        % of the point being edited.
        Pax = fig_2_ax_coord(Pfig,currAx);
        PfixStep = snap_point(UD,Pax,UD.channels(chNum));
        yData = UD.channels(chNum).yData;
        if (yData(Ind)~=PfixStep(2))
            yData(Ind)=PfixStep(2);
            set(UD.channels(chNum).lineH,'YData',yData);
            UD = update_numeric_displays(UD,[],yData(Ind));
        end
        [UD,modified] = update_click_lockout(UD,Pfig);

    end

case 12 % point x adjust    
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    Ind = UD.current.editPoints;
    chNum = UD.current.channel;

    if(strcmp(event,'EBU'))
        % If we moved less than the single click threshold then 
        % we are selecting this point
        pPrev = UD.current.bdPoint;
        [th,r] = cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
        if r<UD.geomConst.singleClickThresh
            if UD.current.bdMode==1 | UD.current.lockOutSingleClick
                UD.current.mode = 3;
            else 
                UD.current.mode = 7;
            end
        else
            % Use the current Y position as the new value
            % of the point being edited.
            X = UD.channels(chNum).xData;
            Pax = fig_2_ax_coord(Pfig,currAx);
            PfixStep = snap_point(UD,Pax,UD.channels(chNum),Ind);
            X(Ind) = PfixStep(1); % Change the point y value

            if UD.common.dispMode==2
                if PfixStep(1)~=ceil(PfixStep(1))
                    x1 = floor(PfixStep(1)) + 1;
                    x2 = x1+1;
                    UD.current.timeEditIdx = [x1 x2];
                    UD.current.timeAdjIdx = Ind;
                    timeDiff = diff( UD.common.timeVect(x1:x2));
                    UD = show_adjustment_displays(UD,currAx,X(Ind), ...
                                                  UD.channels(chNum).yData(Ind),timeDiff);
                else
                    UD = hide_time_arrows(UD,chNum);
                end
            else
                UD = apply_new_channel_data(UD,chNum,X,[]);
            end

            % We are now in the edit mode of the line
            UD = set_dirty_flag(UD);
            UD.current.mode = 3;
        end 
    end

    if(strcmp(event,'EBM'))
        % Use the current Y position as the new value
        % of the point being edited.
        Pax = fig_2_ax_coord(Pfig,currAx);
        PfixStep = snap_point(UD,Pax,UD.channels(chNum),Ind);
        xData = UD.channels(chNum).xData;
        xData(Ind)=PfixStep(1);
        set(UD.channels(chNum).lineH,'XData',xData);
        UD = update_numeric_displays(UD,xData(Ind),[]);

        if UD.common.dispMode==2
            if PfixStep(1)~=ceil(PfixStep(1))
                UD = update_time_arrows(UD,chNum,xData(Ind),UD.channels(chNum).yData(Ind));
            else
                UD = hide_time_arrows(UD,chNum);
            end
        end
        [UD,modified] = update_click_lockout(UD,Pfig);
    end


case 13 % line x-y adjust (Also used to add points)   
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    Pax = fig_2_ax_coord(Pfig,currAx);
    chNum = UD.current.channel;
    PfixStep = snap_point(UD,Pax,UD.channels(chNum));

    if(strcmp(event,'EBU') | strcmp(event,'BU'))
        pPrev = UD.current.bdPoint;
        [th,r] = cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
        if r<UD.geomConst.singleClickThresh
            UD = add_new_interpolated_points(UD,chNum,PfixStep(1));
            UD.current.mode = 3;
            UD.current.editPoints = [];
            UD.current.tempPoints = [];
        else
            delta = PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
            Y = snap_y_vect(UD, UD.channels(chNum).yData+delta(2),UD.channels(chNum));
            X = snap_x_vect(UD, UD.channels(chNum).xData+delta(1),UD.channels(chNum));
            [X,Y] = correct_endpoints(UD,X,Y);
            UD = apply_new_channel_data(UD,chNum,X,Y);
            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum);
            UD.current.mode = 3;
        end
        UD = set_dirty_flag(UD);
    end
    
    if(strcmp(event,'EBM'))
        delta = PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
        Y = snap_y_vect(UD, UD.channels(chNum).yData+delta(2),UD.channels(chNum));
        X = snap_x_vect(UD, UD.channels(chNum).xData+delta(1),UD.channels(chNum));
        set(UD.channels(chNum).lineH,'YData',Y,'XData',X);
        [UD,lo_mod] = update_click_lockout(UD,Pfig);
        if lo_mod, modified = 1; end
    end


case 5 % segment vertical adjust
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    Ind = UD.current.editPoints;
    chNum = UD.current.channel;
    pPrev = UD.current.bdPoint;
    Pax = fig_2_ax_coord(Pfig,currAx);
    PfixStep = snap_point(UD,Pax,UD.channels(chNum));
    Itemp = UD.current.tempPoints;
    if isempty(Itemp)
        oldX = UD.channels(chNum).xData;
        oldY = UD.channels(chNum).yData;
        if(Ind(1)>1 & oldX(Ind(1)-1)~=oldX(Ind(1))) % No discontinuity at left?
            X = [oldX(1:Ind(1)) oldX(Ind(1):end)];
            Y = [oldY(1:Ind(1)) oldY(Ind(1):end)];
            Itemp = Ind+1;
        else
            X = oldX;
            Y = oldY;
            Itemp = Ind;
        end
        if(Ind(2)<length(oldX) & oldX(Ind(2))~=oldX(Ind(2)+1)) % No discontinuity at right?
            X = [X(1:Itemp(2)) X(Itemp(2):end)];
            Y = [Y(1:Itemp(2)) Y(Itemp(2):end)];
        end
    else
        X = get(UD.channels(chNum).lineH,'XData');
        Y = get(UD.channels(chNum).lineH,'YData');
    end

    if(strcmp(event,'BU'))

        % If we moved less than the single click threshold then 
        % we are selecting this segment
        [th,r] = cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
        if r<UD.geomConst.singleClickThresh
            if UD.current.bdMode==1 | UD.current.lockOutSingleClick | UD.current.bdMode==8 % <= WISH (Change this)!!!!
                UD.current.mode = 3;
            else
                UD.current.mode = 8;
            end
            UD = apply_new_channel_data(UD,chNum,X,Y);
        else
            % Use the current Y position as the new value
            % of the point being edited.
            delta = PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
            Y(Itemp) = snap_y_vect(UD, UD.channels(chNum).yData(Ind)+delta(2),UD.channels(chNum));
            [X,Y] = remove_unneeded_points(X,Y);
            UD = apply_new_channel_data(UD,chNum,X,Y);

            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum);
            % We are now in the edit mode of the line
            UD = set_dirty_flag(UD);
            UD.current.mode = 3;
        end 
    end

    if(strcmp(event,'BM'))
        delta = PfixStep-fig_2_ax_coord(UD.current.bdPoint,currAx);
        Y(Itemp) = snap_y_vect(UD, UD.channels(chNum).yData(Ind)+delta(2),UD.channels(chNum));
        set(UD.channels(chNum).lineH,'YData',Y,'XData',X);
        UD = update_numeric_displays(UD,[],Y(Itemp));
        [UD,lo_mod] = update_click_lockout(UD,Pfig);
        if lo_mod, modified = 1; end
    end

case 6 % segment horizontal adjust
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    Ind = UD.current.editPoints;
    chNum = UD.current.channel;
    pPrev = UD.current.bdPoint;
    Pax = fig_2_ax_coord(Pfig,currAx);
    PfixStep = snap_point(UD,Pax,UD.channels(chNum),Ind);

    if(strcmp(event,'BM'))
        X = get(UD.channels(chNum).lineH,'XData');
        X(Ind) = [1 1]*PfixStep(1);
        set(UD.channels(chNum).lineH,'XData',X);
        UD = update_numeric_displays(UD,X(Ind),[]);
        [UD,modified] = update_click_lockout(UD,Pfig);
        ymean = mean(UD.channels(chNum).yData(Ind));
        if UD.common.dispMode==2
            if PfixStep(1)~=ceil(PfixStep(1))
                UD = update_time_arrows(UD,chNum,X(Ind(1)),ymean);
            else
                UD = hide_time_arrows(UD,chNum);
            end
        end

    end

    if(strcmp(event,'BU'))
        % If we moved less than the single click threshold then 
        % we are selecting this segment
        [th,r] = cart2pol(Pfig(1)-pPrev(1),Pfig(2)-pPrev(2));
        if r<UD.geomConst.singleClickThresh
            if UD.current.bdMode==1 | UD.current.lockOutSingleClick | UD.current.bdMode==8 % <= WISH (Change this)!!!!
                UD.current.mode = 3;
            else
                UD.current.mode = 8;
            end
            %UD = apply_new_channel_data(UD,chNum,X,Y);
            %X = UD.channels(chNum).xData;
            %Y = UD.channels(chNum).yData;
            %set(UD.channels(chNum).lineH,'YData',Y,'XData',X);
        else
            X = get(UD.channels(chNum).lineH,'XData');
            Y = get(UD.channels(chNum).lineH,'YData');
            X(Ind) = [1 1]*PfixStep(1);
            [X,Y] = remove_unneeded_points(X,Y);
    
            if UD.common.dispMode==2
                if PfixStep(1)~=ceil(PfixStep(1))
                    x1 = floor(PfixStep(1)) + 1;
                    x2 = x1+1;
                    UD.current.timeEditIdx = [x1 x2];
                    UD.current.timeAdjIdx = Ind;
                    timeDiff = diff( UD.common.timeVect(x1:x2));
                    UD = show_adjustment_displays(UD,currAx,X(Ind(1)), ...
                                                  mean(UD.channels(chNum).yData(Ind)),timeDiff);
                else
                    UD = hide_time_arrows(UD,chNum);
                end
            else
                UD = apply_new_channel_data(UD,chNum,X,Y);
            end
    
    
            % We are now in the edit mode of the line
            UD = set_dirty_flag(UD);
            UD.current.mode = 3;
        end
    end
    
case 7 % point select  
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    chNum = UD.current.channel;
    Ind = UD.current.editPoints;

    if(strcmp(event,'BD'))
        if(currObj==UD.channels(chNum).lineH)
            UD = calc_new_drag_mode(UD,currObj,Pfig,currAx);
        else
%           unselect_line(UD.channels(chNum).lineH);
            UD = calc_new_drag_mode(UD,currObj,Pfig,currAx);
        end
    end

    if(strcmp(event,'ABD'))
        UD = perform_abd_select(UD,currObj);
    end
    
    if(strcmp(event,'BM') )
        refresh_dynamic_pointer(UD,Pfig);
    end
    
    if(strcmp(event,'KP'))
        keyChar = get(dialog,'CurrentCharacter');
        switch(keyChar)
        case 27  % Esc
            UD.current.mode = 3;
            UD.current.editPoints = [];

        case {28,29,30,31}  % Arrow keys
            [xDelta,yDelta] = arrow_key_move(UD, chNum, keyChar);
            X = UD.channels(chNum).xData;
            Y = UD.channels(chNum).yData;
            if Ind~=1 & Ind~=length(X)
                Pax = [X(Ind)+xDelta, Y(Ind) + yDelta];
            else
                Pax = [X(Ind), Y(Ind) + yDelta];
            end
            PfixStep = snap_point(UD,Pax,UD.channels(chNum),Ind);
            X(Ind) = PfixStep(1);
            Y(Ind) = PfixStep(2);
            UD = apply_new_channel_data(UD,chNum,X,Y);
            %set(UD.channels(chNum).lineH,'YData',Y,'XData',X);
            UD = update_selection_display_line(UD,X(Ind),Y(Ind));
            %UD.channels(chNum).yData = Y;
            %UD.channels(chNum).xData = X;
            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum,[]);
            UD = update_numeric_displays(UD,X(Ind),Y(Ind));
            UD = set_dirty_flag(UD);

        case 9  % Tab key
            if(Ind<length(UD.channels(chNum).xData))
                Ind = Ind+1;
            else
                Ind = 1;
            end     
            x =  UD.channels(chNum).xData(Ind); 
            y =  UD.channels(chNum).yData(Ind);    
            UD.current.editPoints = Ind;
            set(UD.current.selectLine,'XData',x, 'YData',y);
            UD = update_numeric_displays(UD,x,y);
            axes(UD.current.axes);  % Bring focus back to axes

        case 127 % Delete
            % Remove the point and return to line edit mode
            Y = UD.channels(chNum).yData;
            X = UD.channels(chNum).xData;
            if Ind == 1 | Ind == length(X)
                return;
            end
            Y(Ind) = [];
            X(Ind) = [];
            UD = apply_new_channel_data(UD,chNum,X,Y);
            %UD.channels(chNum).xData = X;
            %UD.channels(chNum).yData = Y;

            if (Ind>length(X))
                Ind = Ind-1;
                UD.current.editPoints = Ind;
            end

            %set(UD.channels(chNum).lineH,'XData',X,'YData',Y);
            set(UD.current.selectLine, ...
                    'XData',        UD.channels(chNum).xData(Ind), ...
                    'YData',        UD.channels(chNum).yData(Ind));
            UD = set_dirty_flag(UD);
            UD = update_numeric_displays(UD,X(Ind),Y(Ind));

        end
         update_selection_msg(UD);
    end
    
 
case 8 % segment select    
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    chNum = UD.current.channel;
    Ind = UD.current.editPoints;

    if(strcmp(event,'BM') )
        refresh_dynamic_pointer(UD,Pfig);
    end
    
    if(strcmp(event,'BD'))
        if(currObj==UD.channels(chNum).lineH)
            UD = calc_new_drag_mode(UD,currObj,Pfig,currAx);
        else
            UD = calc_new_drag_mode(UD,currObj,Pfig,currAx);
        end
    end

    if(strcmp(event,'ABD'))
        UD = perform_abd_select(UD,currObj);
    end
    
    if(strcmp(event,'KP'))
        keyChar = get(dialog,'CurrentCharacter');
        switch(keyChar)
        case 27  % Esc
            UD.current.mode = 3;
            UD.current.editPoints = [];

        case {28,29,30,31}  % Arrow keys
            [xDelta,yDelta] = arrow_key_move(UD, chNum, keyChar);
            X = UD.channels(chNum).xData;
            Y = UD.channels(chNum).yData;
            if min(Ind)~=1 & max(Ind)~=length(X)
                X(Ind) = X(Ind) + xDelta;
            end
            Y(Ind) = Y(Ind) + yDelta;
            UD = apply_new_channel_data(UD,chNum,X,Y);
            %set(UD.channels(chNum).lineH,'YData',Y,'XData',X);
            UD = update_selection_display_line(UD,X(Ind),Y(Ind));
            %UD.channels(chNum).yData = Y;
            %UD.channels(chNum).xData = X;
            UD = rescale_axes_to_fit_data(UD,UD.channels(chNum).axesInd,chNum,[]);
            UD = update_numeric_displays(UD,X(Ind),Y(Ind));
            UD = set_dirty_flag(UD);

        case 9  % Tab key (->)
            if(Ind(2)<length(UD.channels(chNum).xData))
                Ind = Ind+1;
            else
                Ind = [1 2];
            end
            x =  UD.channels(chNum).xData(Ind); 
            y =  UD.channels(chNum).yData(Ind);    
            UD.current.editPoints = Ind;
            set(UD.current.selectLine,'XData',x, 'YData',y);
            UD = update_numeric_displays(UD,x,y);
            axes(UD.current.axes);  % Bring focus back to axes
        end
        update_selection_msg(UD);
    end
            


case 9  % zoom in x (time)
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    if(strcmp(event,'KP'))
        keyChar = get(dialog,'CurrentCharacter');
        switch(keyChar)
        case 27  % Esc
            UD.current.mode = 1;
        end
    end

    if(strcmp(event,'BD'))
        UD.current.zoomStart = fig_2_ax_coord(Pfig,currAx);
        axUd = get(currAx,'UserData');

		% Put the zoom lines down
    	props = struct(...
        'Parent',currAx,...
        'Visible','on',...
        'EraseMode','normal',...
        'Color','k');

		X0 = UD.current.zoomStart(1);
		Y0 = UD.current.zoomStart(2);
		ext = fig_2_ax_ext([8 8],currAx);
        dY = ext(2);

        UD.current.zoomXLine = [line([X0 X0],[Y0 Y0+2*dY],props);...
                line([X0 X0],[Y0+dY Y0+dY],props);...
                line([X0 X0],[Y0 Y0+2*dY],props)];
        UD.current.zoomAxesInd = axUd.index;
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end

    if(strcmp(event,'BM'))
    	if ~isempty(UD.current.zoomXLine)
        	Pax = fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
        	set(UD.current.zoomXLine(2),'Xdata',[UD.current.zoomStart(1) Pax(1)]);
        	set(UD.current.zoomXLine(3),'Xdata',[Pax(1) Pax(1)]);
        	sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
        end
    end

    if(strcmp(event,'BU'))
        Pax = fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
        range = sort([UD.current.zoomStart(1) Pax(1)]);
        delete(UD.current.zoomXLine);
        UD.current.zoomXLine = [];
        UD = set_new_time_range(UD,range);
		UD = cant_undo(UD);
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end

 
case 10 % zoom in y (time)      
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    if(strcmp(event,'KP'))
        keyChar = get(dialog,'CurrentCharacter');
        switch(keyChar)
        case 27  % Esc
            UD.current.mode = 1;
        end
    end

    if(strcmp(event,'BD'))
        UD.current.zoomStart = fig_2_ax_coord(Pfig,currAx);
        axUd = get(currAx,'UserData');

		% Put the zoom lines down
    	props = struct(...
        'Parent',currAx,...
        'Visible','on',...
        'EraseMode','normal',...
        'Color','k');

		X0 = UD.current.zoomStart(1);
		Y0 = UD.current.zoomStart(2);
		ext = fig_2_ax_ext([8 8],currAx);
        dX = ext(1);

        UD.current.zoomYLine = [line([X0-2*dX X0],[Y0 Y0],props);...
                line([X0-dX X0-dX],[Y0 Y0],props);...
                line([X0-2*dX X0],[Y0 Y0],props)];
        UD.current.zoomAxesInd = axUd.index;
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end

    if(strcmp(event,'BM'))
    	if ~isempty(UD.current.zoomYLine)
        	Pax = fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
        	set(UD.current.zoomYLine(2),'Ydata',[UD.current.zoomStart(2) Pax(2)]);
        	set(UD.current.zoomYLine(3),'Ydata',[Pax(2) Pax(2)]);
        	sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
        end
    end

    if(strcmp(event,'BU'))
        Pax = fig_2_ax_coord(Pfig,UD.axes(UD.current.zoomAxesInd).handle);
        range = sort([UD.current.zoomStart(2) Pax(2)]);
        delete(UD.current.zoomYLine);
        UD.current.zoomYLine = [];
        if diff(range)>0
            UD.axes(UD.current.zoomAxesInd).yLim = range;
            set(UD.axes(UD.current.zoomAxesInd).handle,'YLim',range);
    		update_axes_label(UD,UD.current.zoomAxesInd);  
		end      
		UD = cant_undo(UD);
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end


case 11 % zoom in xy (time)     
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end

    if(strcmp(event,'KP'))
        keyChar = get(dialog,'CurrentCharacter');
        switch(keyChar)
        case 27  % Esc
            UD.current.mode = 1;
        end
    end

    if(strcmp(event,'BD'))
        UD.current.zoomStart = fig_2_ax_coord(Pfig,currAx);
        axUd = get(currAx,'UserData');


        UD.current.zoomAxesInd = axUd.index;
        finalRect = rbbox;
        Pax = fig_2_ax_coord(finalRect(1:2),UD.axes(UD.current.zoomAxesInd).handle);
        RBext = fig_2_ax_ext(finalRect(3:4),UD.axes(UD.current.zoomAxesInd).handle);
		trange = [0 RBext(1)] + Pax(1);
		yrange = [0 RBext(2)] + Pax(2);
        UD.axes(UD.current.zoomAxesInd).yLim = yrange;
        if diff(yrange) <= 0
            return;
        end        
        set(UD.axes(UD.current.zoomAxesInd).handle,'YLim',yrange);
        UD = set_new_time_range(UD,trange);
		UD = cant_undo(UD);
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end


case 14 % Point add mode (add a point with each button down, double click to exit mode)
    if strcmp(event,'FRC')
        UD.current.mode = nextMode;
    end


otherwise,
    error('Bad value for mode variable')
end
    


if(oldMode ~= UD.current.mode)
    update_status_msg(UD);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%       STATE EXIT ACTIONS        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch(oldMode)
    case 1 % Normal mode, nothing selected
    case 2 % Marker adjust mode
    case 3 % Line edit mode
    case 4 % point y adjust
        set(UD.channels(UD.current.channel).lineH,'EraseMode','normal');
        UD = disable_adjustment_displays(UD);
        
    case 12 % point x adjust
        if UD.current.channel>0
            set(UD.channels(UD.current.channel).lineH,'EraseMode','normal');
        end
        UD = disable_adjustment_displays(UD);
    case 13 % line adjust
        set(UD.channels(UD.current.channel).lineH,'EraseMode','normal');
    
    case 5 % segment vertical adjust
        if UD.current.channel>0
            set(UD.channels(UD.current.channel).lineH,'EraseMode','normal');
        end
        UD = disable_adjustment_displays(UD);
    case 6 % segment horizontal adjust
        set(UD.channels(UD.current.channel).lineH,'EraseMode','normal');
        UD = disable_adjustment_displays(UD);
    case 7 % point select
        UD = remove_selection_display_line(UD);
        UD = disable_adjustment_displays(UD);
        
    case 8 % segment select    
        UD = remove_selection_display_line(UD);
        UD = disable_adjustment_displays(UD);
        
    case 9  % zoom in x (time)   
        set(UD.toolbar.zoomX,'state','off'); 
    case 10 % zoom in y (time)      
        set(UD.toolbar.zoomY,'state','off'); 
    case 11 % zoom in xy (time)     
        set(UD.toolbar.zoomXY,'state','off'); 

    otherwise,
        error('Bad value for mode variable')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%       STATE ENTRY ACTIONS       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    chIdx = UD.current.channel;
    Ipts = UD.current.editPoints;
    switch(UD.current.mode)
    case 1 % Normal mode, nothing selected
        set(UD.dialog,'Pointer','arrow');
        UD.current.channel = 0;
        UD = update_channel_select(UD);
    case 2 % Splitter adjust mode
        set(UD.dialog,'Pointer','right');
        UD.current.splitterStart = Pfig(1);
        UD.current.splitterPos = get(UD.verify.hg.splitter,'Position');
        
    case 3 % Line edit mode
         UD.current.editPoints = [];
         UD.current.tempPoints = [];
         set(UD.dialog,'Pointer','arrow');
         UD = update_channel_select(UD);

    case 12 % point x adjust
        set(UD.dialog,'Pointer','circle');
        set(UD.channels(UD.current.channel).lineH,'EraseMode','xor');
        UD = activate_adjustment_displays(UD);
    case 13 % point x adjust
        set(UD.channels(UD.current.channel).lineH,'EraseMode','xor');
    case 4 % point y adjust
        set(UD.dialog,'Pointer','circle');
        set(UD.channels(UD.current.channel).lineH,'EraseMode','xor');
        UD = activate_adjustment_displays(UD);
    case 5 % segment vertical adjust
        setptr(UD.dialog,'uddrag');
        set(UD.channels(UD.current.channel).lineH,'EraseMode','xor');
        UD = activate_adjustment_displays(UD);
    case 6 % segment horizontal adjust
        setptr(UD.dialog,'lrdrag');
        set(UD.channels(UD.current.channel).lineH,'EraseMode','xor');
        UD = activate_adjustment_displays(UD);
    case 7 % point select  
        set(UD.dialog,'Pointer','arrow');
        Ind = UD.current.editPoints;
        UD = activate_adjustment_displays(UD);
        UD = add_selection_display_line(UD,chIdx,Ipts);
         update_selection_msg(UD);

    case 8 % segment select    
        set(UD.dialog,'Pointer','arrow');
        Ind = UD.current.editPoints;
        UD = activate_adjustment_displays(UD);
        UD = add_selection_display_line(UD,chIdx,Ipts);
        update_selection_msg(UD);

    case 9  % zoom in x (time)    
        set(UD.dialog,		'Pointer',				'custom' ...
        					,'PointerShapeCData',	UD.pointerdata.zoomt ...
        					,'PointerShapeHotSpot',	[4 4] ...
        					);
    case 10 % zoom in y (time)      
        set(UD.dialog,		'Pointer',				'custom' ...
        					,'PointerShapeCData',	UD.pointerdata.zoomy ...
        					,'PointerShapeHotSpot',	[4 4] ...
        					);
    case 11 % zoom in xy (time)     
        set(UD.dialog,		'Pointer',				'custom' ...
        					,'PointerShapeCData',	UD.pointerdata.zoomty ...
        					,'PointerShapeHotSpot',	[4 4] ...
        					);
    otherwise,
        error('Bad value for mode variable')
    end

end

% Utility that determines when we are in a drag mode
function out = in_drag_mode(mode)
    out = any(mode==4 | mode==5 | mode==6  | mode==12  | mode==13); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_STATUS_MSG - Ensure the correct status message is
% displayed for the current editor mode. If dynamic messages
% are being used, the dynamicMode should indicate the next
% button down mode.
% 
function update_status_msg(UD,dynamicMode)
    persistent  index outMsgs
    
    if isempty(index)
        outMsgs = { ...
            'Click to select signal' ...
            ,'Adjust marker T position' ...
            ,'Click to select point or segment, Shift+click to add points' ...
            ,'Drag point to new Y position' ...
            ,'Drag segment to new Y position' ...
            ,'Drag segment to new time position' ...
            ,'Enter coordinates or use arrow keys to change points' ...
            ,'Enter coordinates or use arrow keys to change segment' ...
            ,'Select a T region to zoom' ...
            ,'Select a Y range to zoom' ...
            ,'Select a boxed region to zoom' ...
            ,'Drag point to new T position' ...
            ,'Button down to add points' ...
            ,'Adjust point Y position' ...
            ,'Adjust point T position' ...
            ,'Adjust segment Y position' ...
            ,'Adjust segment T position' ...
            ,'Add new point' ...
            };
       index=1;
       set(UD.hgCtrls.status.msgText,'String',outMsgs{index});
   end
   
   if nargin>1 
        if dynamicMode~=index
            index = dynamicMode;
            set(UD.hgCtrls.status.msgText,'String',outMsgs{dynamicMode});
        end
   elseif(UD.current.mode~=index)
        index = UD.current.mode;
        set(UD.hgCtrls.status.msgText,'String',outMsgs{index});
   end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_SELECTION_MSG - Ensure the correct selection message is
% displayed for the current editor mode.
% 
function update_selection_msg(UD)

    if UD.current.channel==0
        set(UD.hgCtrls.status.selText,'String','');
        return
    end
    
    chStruct = UD.channels(UD.current.channel);
    Ipts = UD.current.editPoints;
    if isempty(Ipts)
        portionStr = '';
    else
        if length(Ipts)==1,
            portionStr = ['(Pt ' int2str(Ipts) ') '];
        else
            portionStr = ['(Pts ' int2str(Ipts(1)) ',' int2str(Ipts(2)) ') '];
        end
    end

    props = '';
    if chStruct.stepX > 0
        props = [props 'TGrid '];
    end
    if chStruct.stepY > 0
        props = [props 'YGrid '];
    end
    if ~isempty(chStruct.yMin)
        props = [props 'YMin '];
    end
    if ~isempty(chStruct.yMax)
        props = [props 'YMax '];
    end

    str = sprintf('%s (#%d) %s [ %s]',chStruct.label,chStruct.outIndex,portionStr,props);
    set(UD.hgCtrls.status.selText,'String',str);

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD_SELECTION_DISPLAY_LINE - Add a new selection display 
% indicating the portion of a line (point or segment) that 
% us being edited.
% 
function UD = add_selection_display_line(UD,chIdx,Ipts)

    lineUd = get(UD.channels(chIdx).lineH,'UserData'); % Copy the channel line UD
    chColor = UD.channels(chIdx).color;
    
    if length(Ipts)==1,    % We are selecting a point
        if isequal(chColor,[1 0 0])
            lcolor = [0 0 0];
        else
            lcolor = [1 0 0];
        end
        LineProps = {   'Marker',       'o', ...
                        'Color',        lcolor, ...
                        'MarkerSize',   10, ...
                        'linestyle',    'none' };
                               
    else
        if 1| (chColor(1)==chColor(2) & chColor(1)==chColor(3)) % Is this a grey or black line?
            lcolor = [1 0 0];
        else
            lcolor = 1 - chColor; % Invert the color 
        end
        LineProps = {   'Marker',       'none', ...
                        'Color',        lcolor, ...
                        'LineWidth',    4, ...
                        'lineStyle',    '-' };
    
    end
    
    UD = remove_selection_display_line(UD);
    UD.current.selectLine = line(   'Parent',       UD.current.axes, ...
                                    'XData',        UD.channels(chIdx).xData(Ipts), ...
                                    'YData',        UD.channels(chIdx).yData(Ipts), ...
                                    'UserData',     lineUd, ...
                                    LineProps{:});

    % 
    % Flip the stacking order
    %
    
    allAxesObjs = get(UD.current.axes,'Children');
    Iselect = (allAxesObjs== UD.current.selectLine);
    set(UD.current.axes,'Children',[allAxesObjs(~Iselect);UD.current.selectLine])   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_SELECTION_DISPLAY_LINE
% 
function UD = update_selection_display_line(UD,x,y)
    set(UD.current.selectLine,'XData',x,'YData',y);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE_SELECTION_DISPLAY_LINE
% 
function UD = remove_selection_display_line(UD)
    
    if isempty(UD.current.selectLine)
        return;
    end
    if ishandle(UD.current.selectLine)
        delete(UD.current.selectLine)
        UD.current.selectLine = [];
    end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALC_NEW_DRAG_MODE - Calculate the next drawing mode.
% 
% This is called when there is a button down on a new 
% object.
%
function UD = calc_new_drag_mode(UD,currObj,Pfig,currAx)

    switch(get(currObj,'Type'))
    case 'line'
        objUd = get(currObj,'UserData');
        if isempty(objUd)
            % Stay in the current mode
            return;
        end
        switch(objUd.type)
        case 'Channel'
            chNum = objUd.index;
            UD.current.channel = chNum;
            Pax = fig_2_ax_coord(Pfig,currAx);
            I = calc_channel_points(UD.channels(chNum),Pfig,currAx);
            UD.current.editPoints = I;
            if(length(I)==2)
                if(diff(UD.channels(chNum).xData(I))==0)  % Are points in a vertical line?
                    UD.current.mode = 6;
                else
                    UD.current.mode = 5;
                end
            else
                UD.current.mode = 4;
            end
            UD.current.lockOutSingleClick = 0;
            UD = update_channel_select(UD);
        otherwise
        end
    case 'axes'
        % Ignore this button down if this is the tab display axes.
        axesBottom = UD.current.axesExtent(2);
        axesTop = axesBottom + UD.current.axesExtent(4);
        
        if (Pfig(2)<axesBottom || Pfig(2)>axesTop) 
            UD.current.mode = 1;
            return;
        end
        
        Pax = fig_2_ax_coord(Pfig,currAx);
        if (Pax(1) > UD.common.dispTime(2))
            UD.current.mode = 2;
            UD.current.channel = 0;
            UD = update_channel_select(UD);
            axExtent = UD.current.axesExtent;
            splitterPos = [axExtent(1)+axExtent(3), axExtent(2), 0, axExtent(4)] + ...
                                [0.375 0 0.25 0]*UD.geomConst.figBuffer;
            set(UD.verify.hg.splitter,'Visible','on','Position',splitterPos);
        else
            UD.current.mode = 1;
            UD.current.channel = 0;
            UD = update_channel_select(UD);
        end
    case 'figure'
        if UD.current.isVerificationVisible
            axExtent = UD.current.axesExtent;
            leftPos = axExtent(1) + axExtent(3);
            
            if (Pfig(1)>leftPos && Pfig(1)<(leftPos+UD.geomConst.figBuffer))
                if (Pfig(2)>axExtent(2) && Pfig(2)<(axExtent(2)+axExtent(3)))
                    UD.current.mode = 2;
                    UD.current.channel = 0;
                    UD = update_channel_select(UD);
                    axExtent = UD.current.axesExtent;
                    splitterPos = [axExtent(1)+axExtent(3), axExtent(2), 0, axExtent(4)] + ...
                                        [0.375 0 0.25 0]*UD.geomConst.figBuffer;
                    set(UD.verify.hg.splitter,'Visible','on','Position',splitterPos);
                end
            end
        end
        
    case 'uicontrol'
        % If the verification panel is visible and this is the splitter 
        % object enter the splitter adjust mode.
        if (UD.current.isVerificationVisible && currObj==UD.verify.hg.splitter)
            UD.current.mode = 2;
            UD.current.channel = 0;
            UD = update_channel_select(UD);
        end
    otherwise,
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARROW_KEY_MOVE - Determine an adjustment from an arrow 
% key
%
function [xDelta,yDelta] = arrow_key_move(UD, chIdx, keyChar)

    channelStruct = UD.channels(chIdx);
    % A default snap value appox 2 pixels will be used if the signal has
    % no explicit snap value so that values are more likely to be round 
    % numbers
    axesH = UD.axes(channelStruct.axesInd).handle;
    rawSnap = fig_2_ax_ext([0.75 0.75],axesH);
    defaultStepX = nearest_125(rawSnap(1));
    defaultStepY = nearest_125(rawSnap(2));

    if UD.common.dispMode==2
        stepX = 0.5;
    elseif(channelStruct.stepX >0)
        stepX = channelStruct.stepX;
    else
        stepX = defaultStepX;
    end
    

    if(channelStruct.stepY >0)
        stepY = channelStruct.stepY;
    else
        stepY = defaultStepY;
    end

    switch(keyChar)
    case 28  % Right arrow (<-)
        xDelta = -stepX;
        yDelta = 0;
    case 29  % Left arrow (->)
        xDelta = stepX;
        yDelta = 0;
    case 30  % Up arrow (^)
        xDelta = 0;
        yDelta = stepY;
    case 31  % Down arrow (v)
        xDelta = 0;
        yDelta = -stepY;
    otherwise,
        xDelta = 0;
        yDelta = 0;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALC_NEW_EXTEND_DRAG_MODE - Calculate the next drawing mode.
% 
% This is called when there is a button down on a new 
% object.
%
function UD = calc_new_extend_drag_mode(UD,currObj,Pfig,currAx)

    switch(get(currObj,'Type'))
    case 'line'
        objUd = get(currObj,'UserData');
        if isempty(objUd)
            % Stay in the current mode
            return;
        end
        switch(objUd.type)
        case 'Channel'
            chNum = objUd.index;
            UD.current.channel = chNum;
            Pax = fig_2_ax_coord(Pfig,currAx);
            I = calc_channel_points(UD.channels(chNum),Pfig,currAx);
            UD.current.editPoints = I;
            if(length(I)==2)
                UD.current.mode = 13;   % Drag the entire line
            else
                if I>1 & I<length(UD.channels(chNum).xData)
                    UD.current.mode = 12;   % adjust the y position of a point
                end
            end
            UD.current.lockOutSingleClick = 0;
            UD = update_channel_select(UD);
        otherwise
        end
    case 'axes'
        UD.current.mode = 1;
        UD.current.channel = 0;
    case 'figure'
    otherwise,
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REFRESH_DYNAMIC_POINTER - Update the pointer based on its
% position.
% 
function refresh_dynamic_pointer(UD,Pfig)
    
    persistent lockout;
    if isempty(lockout)
        lockout = (exist('hittest')~=5);
    end
    if lockout
        return;
    end
    
    hitObj = hittest(UD.dialog);

    % See if the shift key is pressed
    isExtended = 0;
%    modes = get(UD.dialog,'CurrentModifier');
%    if isempty(modes)
%        isExtended = 0;
%    else
%        isExtended = strcmp(modes{1},'shift');
%    end  

    switch(get(hitObj,'Type'))
    case 'line'
        objUd = get(hitObj,'UserData');
        if isempty(objUd)
            % Stay in the current mode
            return;
        end
        switch(objUd.type)
        case 'Channel'
            chNum = objUd.index;
            currAx = get(hitObj,'Parent');
            Pax = fig_2_ax_coord(Pfig,currAx);
            I = calc_channel_points(UD.channels(chNum),Pfig,currAx);
            if(length(I)==2)
                if (diff(UD.channels(chNum).xData(I))==0)
                    if isExtended
                        setptr(UD.dialog,'add');
                        update_status_msg(UD,18);
                    else
                        setptr(UD.dialog,'lrdrag');
                        update_status_msg(UD,17);
                    end
                else
                    if isExtended
                        setptr(UD.dialog,'add');
                        update_status_msg(UD,18);
                    else
                        setptr(UD.dialog,'uddrag');
                        update_status_msg(UD,16);
                    end
                end
            else
                if isExtended
                    setptr(UD.dialog,'lrdrag');
                    update_status_msg(UD,15);
                else
                    set(UD.dialog,'Pointer','circle');
                    update_status_msg(UD,14);
                end
          
            end
        otherwise
            set(UD.dialog,'Pointer','arrow');
            update_status_msg(UD);
        end
    otherwise,
       set(UD.dialog,'Pointer','arrow');
       update_status_msg(UD);
    end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_CLICK_LOCKOUT - Update the lockout flag which
% prevents the interpreting of a buttondown buttonup pair
% as a single click.
% 
function  [UD,modified] = update_click_lockout(UD,Pfig),

    modified = 0;

    if (UD.current.lockOutSingleClick==1)
        return;
    end
    
    sep = UD.current.bdPoint - Pfig;
    [th,r] = cart2pol(sep(1),sep(2));

    if (r > UD.geomConst.singleClickThresh)
        UD.current.lockOutSingleClick = 1;
        modified = 1;
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PERFORM_ABD_SELECT - Check if the alternate button down
% point is on top of a channel line and if so, select the 
% line.
% 
function UD = perform_abd_select(UD,currObj)

	if isempty(currObj)
		return;
	end
	
    switch(get(currObj,'Type'))
    case 'line'
        lineUd = get(currObj,'UserData');
        if ~isempty(lineUd) && strcmp(lineUd.type,'Channel')
            chNum = lineUd.index;
            UD.current.channel = chNum;
            UD.current.mode = 3;
            UD = update_channel_select(UD);
        end
        
    case 'axes'
        axUD = get(currObj,'UserData');
        if ~isempty(axUD) && isfield(axUD,'type') && strcmp(axUD.type,'editAxes')
            chNum = UD.axes(axUD.index).channels(1);
            if chNum~=UD.current.channel
                UD.current.channel = chNum;
                UD.current.mode = 3;
                UD = update_channel_select(UD);
            end
        else
            UD.current.channel = 0;
            UD.current.mode = 1;
            UD = update_channel_select(UD);
        end
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESYNC_ADJUSTMENT_DISPLAYS - If needed, change the enable.
% and background of the right display.
% 
function UD = resync_adjustment_displays(UD)
    I = UD.current.editPoints;
    if length(I)<2
        return;
    end

    chNum = UD.current.channel;
    axesInd = UD.channels(chNum).axesInd;
    chAxesInd = find(UD.axes(axesInd).channels==chNum);
    rpStruct = UD.hgCtrls.chRightPoint;
    figBgColor = get(UD.dialog,'Color');

    X = UD.channels(chNum).xData(I);
    Y = UD.channels(chNum).yData(I);

    if diff(X)==0
        if strcmp(get(rpStruct.xNumDisp,'Enable'),'on')
            set(rpStruct.xNumDisp,'Enable','off','BackgroundColor',figBgColor);
        end
    else
        if strcmp(get(rpStruct.xNumDisp,'Enable'),'off')
            set(rpStruct.xNumDisp,'Enable','on','BackgroundColor','w');
        end
    end

    if diff(Y)==0
        if strcmp(get(rpStruct.yNumDisp,'Enable'),'on')
            set(rpStruct.yNumDisp,'Enable','of','BackgroundColor',figBgColor);
        end
    else
        if strcmp(get(rpStruct.yNumDisp,'Enable'),'off')
            set(rpStruct.yNumDisp,'Enable','on','BackgroundColor','w');
        end
    end
    UD = update_numeric_displays(UD,X,Y);

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACTIVATE_ADJUSTMENT_DISPLAYS - Make the point adjustment
% numeric displays have a white background.
% 
function UD = activate_adjustment_displays(UD)
    I = UD.current.editPoints;
    chNum = UD.current.channel;
    axesInd = UD.channels(chNum).axesInd;
    chAxesInd = find(UD.axes(axesInd).channels==chNum);

    X = UD.channels(chNum).xData(I);
    Y = UD.channels(chNum).yData(I);

    lpStruct = UD.hgCtrls.chLeftPoint;
    adjust.XDisp(1) = lpStruct.xNumDisp;
    adjust.YDisp(1) = lpStruct.yNumDisp;
    set([lpStruct.xLabel lpStruct.yLabel lpStruct.title],'Enable','on');
    set(adjust.XDisp(1),'Enable','on','BackgroundColor','w') 
    set(adjust.YDisp(1),'Enable','on','BackgroundColor','w') 

    if(length(I)==2)
        rpStruct = UD.hgCtrls.chRightPoint;
        set(rpStruct.title,'Enable','on');
        if (diff(UD.channels(chNum).xData(I))~=0)
            adjust.XDisp(2) = rpStruct.xNumDisp;
            set(adjust.XDisp(2),'Enable','on','BackgroundColor','w'); 
            set(rpStruct.xLabel,'Enable','on');
        end
        if (diff(UD.channels(chNum).yData(I))~=0)
            adjust.YDisp(2) = rpStruct.yNumDisp;
            set(adjust.YDisp(2),'Enable','on','BackgroundColor','w');
            set(rpStruct.yLabel,'Enable','on');
        end
    end

    UD.adjust = adjust;
    UD = update_numeric_displays(UD,X,Y);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_NUMERIC_DISPLAYS - Update the numeric displays
% indicating point position during point and segment 
% editing.
% 
function UD = update_numeric_displays(UD,X,Y)

    % Check if we need to change the active controls
    figBgColor = get(UD.dialog,'Color');
    if length(X)==2
        rpStruct = UD.hgCtrls.chRightPoint;
        if (X(1) ~= X(2))
            if (length(UD.adjust.XDisp)==1)
                % Activate the second X display
                UD.adjust.XDisp(2) = rpStruct.xNumDisp;
                set(UD.adjust.XDisp(2),'Enable','on','BackgroundColor','w'); 
                set(rpStruct.xLabel,'Enable','on');
            end
        else
            if (length(UD.adjust.XDisp)==2)   
                % Disable the second X display
                set(UD.adjust.XDisp(2),'Enable','off','BackgroundColor',figBgColor,'String',''); 
                set(rpStruct.xLabel,'Enable','off');
                UD.adjust.XDisp(2) = [];
            end
        end

        if ~isempty(Y)
            if (Y(1) ~= Y(2))
                if (length(UD.adjust.YDisp)==1)
                    % Activate the second Y display
                    UD.adjust.YDisp(2) = rpStruct.yNumDisp;
                    set(UD.adjust.YDisp(2),'Enable','on','BackgroundColor','w'); 
                    set(rpStruct.yLabel,'Enable','on');
                end
            else
                if (length(UD.adjust.YDisp)==2)   
                    % Disable the second Y display
                    set(UD.adjust.YDisp(2),'Enable','off','BackgroundColor',figBgColor,'String',''); 
                    UD.adjust.YDisp(2) = [];
                    set(rpStruct.yLabel,'Enable','off');
                end
            end
        end
    end



    if ~isempty(X) & ~isempty(UD.adjust.XDisp)
        if UD.common.dispMode==1
            str = get_disp_string(X(1));
            set(UD.adjust.XDisp(1),'String',str);
            if length(UD.adjust.XDisp)>1
                str = get_disp_string(X(2));
                set(UD.adjust.XDisp(2),'String',str);
            end
        else
            if floor(X(1))==X, % X is integer
                str = get_disp_string(UD.common.timeVect(X(1)+1));
            else
                if X(1) > 0.5
                    str = ['> ' get_disp_string(UD.common.timeVect(X(1)+0.5))];
                else
                    str = ['< ' get_disp_string(UD.common.timeVect(X(1)+1.5))];
                end
            end
            set(UD.adjust.XDisp(1),'String',str);

            if length(UD.adjust.XDisp)>1
                str = get_disp_string(UD.common.timeVect(X(2)+1));
                set(UD.adjust.XDisp(2),'String',str);
            end
        end                    
    end

    if ~isempty(Y) & ~isempty(UD.adjust.YDisp)
        str = get_disp_string(Y(1));
        set(UD.adjust.YDisp(1),'String',str);
        if length(UD.adjust.YDisp)>1
            str = get_disp_string(Y(2));
            set(UD.adjust.YDisp(2),'String',str);
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLACE_ZOOM_START_LINES - Place x and y lines to delimit 
% the 
% 
function UD = place_zoom_start_lines(UD,xfig,yfig),

    return;
    
    allAxPos = UD.current.axesExtent;
    if ~isempty(xfig)
        pos = [xfig allAxPos(2) 1 allAxPos(4)];
        UD.current.zoomXLine = uicontrol( ...
                                'Parent',               UD.dialog, ...
                                'Units',                'points', ...
                                'Style',                'text', ...
                                'HandleVisibility',     'callback', ...
                                'BackgroundColor',      'k', ...
                                'Position',              pos);
    end
        
    if ~isempty(yfig)
        pos = [allAxPos(1) yfig allAxPos(3) 1];
        UD.current.zoomYLine = uicontrol( ...
                                'Parent',               UD.dialog, ...
                                'Units',                'points', ...
                                'Style',                'text', ...
                                'HandleVisibility',     'callback', ...
                                'BackgroundColor',      'k', ...
                                'Position',              pos);
    end
        
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISABLE_ADJUSTMENT_DISPLAYS - Make the point adjustment
% numeric displays have a grey background.
% 
function UD = disable_adjustment_displays(UD)
    objs = [UD.adjust.XDisp UD.adjust.YDisp];

    if isempty(objs)
        return;
    end
    figBgColor = get(UD.dialog,'Color');
    set(objs,'String','','BackgroundColor',figBgColor,'Enable','off');
    UD.adjust.XDisp = [];
    UD.adjust.YDisp = [];

    rpStruct = UD.hgCtrls.chRightPoint;
    lpStruct = UD.hgCtrls.chLeftPoint;
    objs = [rpStruct.title rpStruct.xLabel rpStruct.yLabel ...
            lpStruct.title lpStruct.xLabel lpStruct.yLabel];
    set(objs,'Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% APPLY_NEW_POINT_VALUE - Make a point adjustment
% based on the numeric display.
% 
function UD = apply_new_point_value(UD,mode)

    if UD.current.mode~=7 & UD.current.mode~=8
        return;
    end

    chIdx = UD.current.channel;
    axIdx = UD.channels(chIdx).axesInd;
    Ipt = UD.current.editPoints;

    switch(mode)
    case 'Xvalue'
        value = str2num(get(UD.adjust.XDisp,'String'));
        xnew = snap_x_vect(UD,value,UD.channels(chIdx));
        X = UD.channels(chIdx).xData;
        if length(Ipt)>1 
            if abs(diff(X(Ipt)))>0
                return;
            else
                X(Ipt) = xnew*[1 1];
            end
        else
            X(Ipt) = xnew;
        end
        UD = apply_new_channel_data(UD,chIdx,X,Y);
        %set(UD.channels(chIdx).lineH,'XData',X);
        set(UD.current.selectLine,'XData', xnew);
        %UD.channels(chIdx).xData = X;
        UD = set_dirty_flag(UD);
 
     case 'Yvalue'
        value = str2num(get(UD.adjust.YDisp,'String'));
        ynew = snap_y_vect(UD, value,UD.channels(chIdx));

        Y = UD.channels(chIdx).yData;
        if length(Ipt)>1 
            if abs(diff(Y(Ipt)))>0
                return;
            else
                Y(Ipt) = ynew*[1 1];
            end
        else
            Y(Ipt) = ynew;
        end

        set(UD.channels(chIdx).lineH,'YData',Y);
        UD = apply_new_channel_data(UD,chIdx,[],Y);
        %set(UD.current.selectLine,'YData', ynew);
        %UD.channels(chIdx).yData = Y;
        UD = rescale_axes_to_fit_data(UD,axIdx,chIdx,[]);
        UD = set_dirty_flag(UD);

    otherwise,
        return;
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% APPLY_NEW_CHANNEL_DATA - Function to modify channel data.
% This function performs all needed side effects: updating
% hg, setting the dirty flag, enabling undo, etc.
% 
function UD = apply_new_channel_data(UD,chIdx,X,Y,dontUpdateUndo)
    
    if nargin<5 | ~dontUpdateUndo
        UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
    end
    
    doUpdate = (    ~isempty(UD.channels(chIdx).lineH) && ...
                    ishandle(UD.channels(chIdx).lineH));
                
    if isempty(X)
        UD.channels(chIdx).yData = Y;
        if doUpdate
            set(UD.channels(chIdx).lineH,'YData',Y);
        end
    elseif isempty(Y)
        UD.channels(chIdx).xData = X;
        if doUpdate
            set(UD.channels(chIdx).lineH,'XData',X);
        end
    else
        UD.channels(chIdx).yData = Y;
        UD.channels(chIdx).xData = X;
        if doUpdate
            set(UD.channels(chIdx).lineH,'XData',X,'YData',Y);
        end
    end
    
    if doUpdate
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                  GEOMETRY CALCULATIONS AND CONVERSIONS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GEOMETRY_CALCULATIONS_AND_CONVERSIONS   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIG_2_AX_COORD
% 
function P = fig_2_ax_coord(Pfig,axesH),
    axPos = get(axesH,'Position');
    xLim = get(axesH,'XLim');
    yLim = get(axesH,'YLim');
    conv2points = [axPos(3)/diff(xLim) axPos(4)/diff(yLim)];

    P = [xLim(1) yLim(1)] + (Pfig - axPos(1:2))./conv2points;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AX_2_FIG_COORD
% 
function P = ax_2_fig_coord(Pax,axesH),
    axPos = get(axesH,'Position');
    xLim = get(axesH,'XLim');
    yLim = get(axesH,'YLim');
    conv2points = [axPos(3)/diff(xLim) axPos(4)/diff(yLim)];

    P = (Pax - [xLim(1) yLim(1)]).*conv2points + axPos(1:2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIG_2_AX_EXT
% 
function Ext = fig_2_ax_ext(Fext,axesH),
    axPos = get(axesH,'Position');
    xLim = get(axesH,'XLim');
    yLim = get(axesH,'YLim');
    conv2points = [axPos(3)/diff(xLim) axPos(4)/diff(yLim)];

    Ext = Fext./conv2points;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AX_2_FIG_EXT
% 
function Ext = ax_2_fig_ext(Aext,axesH),
    axPos = get(axesH,'Position');
    xLim = get(axesH,'XLim');
    yLim = get(axesH,'YLim');
    conv2points = [axPos(3)/diff(xLim) axPos(4)/diff(yLim)];

    Ext = Aext.*conv2points;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONV_X_TO_FIG_COORD
% 
function xFig = conv_x_to_fig_coord(xAx,axesH);
    axPos = get(axesH,'Position');
    xLim = get(axesH,'XLim');
    conv = axPos(3)/diff(xLim);
    xFig = (xAx - xLim(1))*conv + axPos(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONV_Y_TO_FIG_COORD
% 
function yFig = conv_y_to_fig_coord(yAx,axesH);
    axPos = get(axesH,'Position');
    yLim = get(axesH,'YLim');
    conv = axPos(4)/diff(yLim);
    yFig = (yAx - yLim(1))*conv + axPos(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND_Y_RANGE_FROM_X - Find the Y range in a signal given 
% an interval in X.
% 
function [ymin,ymax] = find_y_range_from_x(X,Y,xmin,xmax)
    xWinthinLims = (X>=xmin & X<=xmax);
    if all(xWinthinLims)
        ymin = min(Y);
        ymax = max(Y);
    else
        Ind = find(xWinthinLims);
        if isempty(Ind)
        	y1 = scalar_interp(xmin,X,Y);
        	y2 = scalar_interp(xmax,X,Y);
        	ymin = min([y1 y2]);
        	ymax = max([y1 y2]);
        else
	        if Ind(1)~=1
	            I = Ind(1)-1;
	            Y(I) = scalar_interp(xmin,X,Y);
	            xWinthinLims(I) = logical(1);
	        end
	        if Ind(end)~=length(X)
	            I = Ind(end)+1;
	            Y(I) = scalar_interp(xmax,X,Y);
	            xWinthinLims(I) = logical(1);
	
	        end 
	        Y = Y(xWinthinLims);
	        ymin = min(Y);
	        ymax = max(Y);
	    end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALC_CHANNEL_POINTS - Determine the index of a point or
% a segment on the channel based on the mouse position
% 
function I = calc_channel_points(channelStruct,Pfig,axesH),

    Xfigcoord = conv_x_to_fig_coord(channelStruct.xData,axesH);
    Yfigcoord = conv_y_to_fig_coord(channelStruct.yData,axesH);

    [th,r] = cart2pol(Xfigcoord-Pfig(1),Yfigcoord-Pfig(2));
    minDist = min(r);
    
    % segment geometric mean distance
    geomMeanX = r(1:(end-1)) .* r(2:end) ./ (r(1:(end-1)) + r(2:end));

    % segment colinear factor
    colinear = abs( mod(th(1:(end-1)) - th(2:end),2*pi) -pi);

    % approximate the distance to each segment and find closest segment
    d = colinear.*geomMeanX;
    closestSegment = find(d==min(d));
    closestSegment = closestSegment(1) + [0 1];

    % Find the index of the closest point
    closestIndx = find(r==minDist);
    closestIndx = closestIndx(1);

    if (minDist > 4)
        I = closestSegment;
    else
        I = closestIndx;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNAP_POINT - Calculate the point value using the channel
% increment settings.
% 
function PfixStep = snap_point(UD,P,channelStruct,Ind,OverrideDefault),

    if nargin==3
        Ind = [];
        OverrideDefault = 0;
    end

    if nargin==4
        OverrideDefault = 0;
    end
    
    % Apply saturation based on channel properties
    if ~isempty(Ind)
        if min(Ind) > 1
            minx = channelStruct.xData(min(Ind)-1);
        else
            minx = -inf;
        end

        if max(Ind)<length(channelStruct.xData)
            maxx = channelStruct.xData(max(Ind)+1);
        else
            maxx = inf;
        end

        if P(1)>maxx
            P(1) = maxx;
        elseif P(1) < minx
            P(1) = minx;
        end
    else
        minx = -inf;
        maxx = inf;
    end
    if isfield(channelStruct,'yMax') & ~isempty(channelStruct.yMax) & P(2)> channelStruct.yMax
        P(2) = channelStruct.yMax;
    elseif isfield(channelStruct,'yMin') & ~isempty(channelStruct.yMin) & P(2)< channelStruct.yMin
        P(2) = channelStruct.yMin;
    end
    
    % A default snap value appox 2 pixels will be used if the signal has
    % no explicit snap value so that values are more likely to be round 
    % numbers
    axesH = UD.axes(channelStruct.axesInd).handle;
    rawSnap = fig_2_ax_ext(pixels2points(UD,[1 1]),axesH);
    defaultStepX = nearest_125(rawSnap(1));
    defaultStepY = nearest_125(rawSnap(2));

    if UD.common.dispMode==2
        stepX = 0.5;
    elseif(channelStruct.stepX >0)
        stepX = channelStruct.stepX;
    elseif (OverrideDefault)
        stepX = 0;
    else
        stepX = defaultStepX;
    end
    
    if stepX>0 & P(1)~=maxx & P(1)~=minx
        PfixStep(1) = stepX * round(P(1)/stepX);
    else
        PfixStep(1) = P(1);
    end

    if(channelStruct.stepY >0)
        stepY = channelStruct.stepY;
    elseif (OverrideDefault)
        stepY = 0;
    else
        stepY = defaultStepY;
    end

    if stepY>0
        PfixStep(2) = stepY * round(P(2)/stepY);
    else
        PfixStep(2) = P(2);
    end



function out = pixels2points(UD,in);

    persistent conversion;
    if isempty(conversion)
        set(UD.dialog,'Units','Pixels');
        posPixels = get(UD.dialog,'Position');
        set(UD.dialog,'Units','Points');
        posPoints = get(UD.dialog,'Position');
        conversion = posPoints(3:4) ./ posPixels(3:4);
    end

    out = in .* conversion;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEAREST_125 - Round a number to the nearest 1,2,5 * 10^n 
% 
function out = nearest_125(x)

    decade = ceil(log10(x));
    m = x/(10^decade);

    if m < 0.2
        m = 0.2;
    elseif m < 0.5
        m = 0.5;
    else
        m = 1;
    end

    out = m*(10^decade);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNAP_Y_VECT - Calculate the y values using the channel
% increment settings. 
% 
function YfixStep = snap_y_vect(UD,Y,channelStruct),

    if(channelStruct.stepY >0)
        YfixStep = channelStruct.stepY * round(Y/channelStruct.stepY);
    else
        axesH = UD.axes(channelStruct.axesInd).handle;
        rawSnap = fig_2_ax_ext([0.75 0.75],axesH);
        defaultStepY = nearest_125(rawSnap(2));
        YfixStep = defaultStepY * round(Y/defaultStepY);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNAP_X_VECT - Calculate the x values using the channel
% increment settings. 
% 
function XfixStep = snap_x_vect(UD,X,channelStruct),

    if UD.common.dispMode==2
        XfixStep = 0.5 * round(X/0.5);
    elseif(channelStruct.stepX >0)
        XfixStep = channelStruct.stepX * round(X/channelStruct.stepX);
    else
        axesH = UD.axes(channelStruct.axesInd).handle;
        rawSnap = fig_2_ax_ext([1.5 1.5],axesH);
        defaultStepX = nearest_125(rawSnap(1));
        XfixStep = defaultStepX * round(X/defaultStepX);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                          UNDO REDO FUNCTIONS                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UNDO_REDO_FUNCTIONS   


function UD = cant_undo(UD,exceptionContents)

    if nargin>1 & strcmp(exceptionContents,UD.undo.contents)
        return;
    end
    
    UD.undo.command = 'none';
    UD.undo.action = '';
    UD.undo.contents = '';
    UD.undo.index = -1;
    UD.undo.data = [];

    set([UD.menus.figmenu.undo UD.toolbar.undo],'Enable','off');
    set([UD.menus.figmenu.redo UD.toolbar.redo],'Enable','off');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_UNDO - Set the undo buffer contents
% 
function UD = update_undo(UD,action,contents,index,data)
    
    if nargin > 3,
        UD.undo.data = data;
    end

    set([UD.menus.figmenu.undo UD.toolbar.undo],'Enable','on');
    set([UD.menus.figmenu.redo UD.toolbar.redo],'Enable','off');

    UD.undo.command = 'undo';
    UD.undo.action = action;
    UD.undo.contents = contents;
    UD.undo.index = index;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PERFORM_UNDO - Perform undo by copying the buffer 
% contents
% 
function UD = perform_undo_or_redo(UD,method)

    if ~strcmp(UD.undo.command,method);
        return;
    end

    dataStruct = UD.undo.data;
    undoIdx = UD.undo.index;

    switch(UD.undo.contents)
    case 'channel'
        switch(UD.undo.action)
        case 'edit'
            UD.undo.data = UD.channels(undoIdx);
            UD.channels(undoIdx) = dataStruct;
            UD = rescale_axes_to_fit_data(UD,dataStruct.axesInd,undoIdx);
            axIdx = dataStruct.axesInd;
            set(dataStruct.lineH ...
                    ,'XData',               dataStruct.xData ...
                    ,'YData',               dataStruct.yData ...
                    ,'Color',               dataStruct.color ...
                    ,'LineWidth',           dataStruct.lineWidth ...
                    ,'LineStyle',           dataStruct.lineStyle ...
                    );
            if axIdx>0
            	set(UD.axes(axIdx).labelH,'Color',dataStruct.color);
            end
            UD = update_channel_select(UD);

        case 'move'
        	prevIdx = dataStruct;
        	UD.undo.data = undoIdx;
        	UD.undo.index = prevIdx;
        	UD = change_channel_index(UD,prevIdx,undoIdx);
        	
        case 'delete'
            % First restore the channel, then set its
            % index to the old value
            UD = new_channel(   UD.dialog,UD, ...
                                dataStruct.xData, ...
                                dataStruct.yData, ...
                                dataStruct.stepX, ...
                                dataStruct.stepY, ...
                                dataStruct.label);                
            UD.channels(end).allXData = dataStruct.allXData;
            UD.channels(end).allYData = dataStruct.allYData;
            UD.channels(end).color = dataStruct.color;
            UD.channels(end).lineStyle = dataStruct.lineStyle;
            UD.channels(end).lineWidth = dataStruct.lineWidth;
    	    UD = new_axes(UD,1,[]);
            UD = new_plot_channel(UD,UD.numChannels,1);  
            UD = change_channel_index(UD,undoIdx,UD.numChannels);
            UD.current.mode = 3;
            UD.current.channel = undoIdx;
            UD.current.bdPoint = [0 0];
            UD.current.bdObj = UD.channels(UD.numChannels).lineH;
            UD = update_channel_select(UD);
            UD.undo.action = 'add';
            UD.undo.data = [];
            UD.undo.index = undoIdx;
            UD = update_show_menu(UD);

        case 'add'
            UD.undo.data = UD.channels(undoIdx);
            UD.undo.action = 'delete';
            UD = remove_channel(UD,undoIdx);
			UD.current.channel = 0;
			UD = update_channel_select(UD);
			UD = update_show_menu(UD);

        case 'rename'
			oldName = dataStruct;
            UD.undo.data = UD.channels(undoIdx).label;
            [UD,applyStr] = rename_channel(UD,undoIdx,oldName);

        otherwise
        end
        
        
    case 'dataSet'
        switch(UD.undo.action)
        case 'delete'
            % First restore the old dataSet and then move the index
            UD = dataSet_store(UD); 
            oldActiveDsIdx = UD.current.dataSetIdx;
            UD.dataSet(end+1) = UD.undo.data.dataSet;
            for chIdx=1:length(UD.channels)
                UD.channels(chIdx).allXData{end+1} = UD.undo.data.chXData{chIdx};
                UD.channels(chIdx).allYData{end+1} = UD.undo.data.chYData{chIdx};
            end
            sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,UD.undo.data.dataSet.name);
            dsCnt = length(UD.dataSet);
            if dsCnt~=undoIdx
                old2NewIdx = [1:(undoIdx-1) dsCnt undoIdx:(dsCnt-1)];
                UD = dataSet_reorder(UD,old2NewIdx,old2NewIdx(oldActiveDsIdx));
            end
            UD.undo.action = 'add';
            UD.undo.data = [];
            UD = dataSet_sync_menu_state(UD);
            UD = update_tab_sub_menu(UD);

        case 'add'
            UD.undo.data.dataSet = UD.dataSet(undoIdx);
            for chIdx=1:length(UD.channels)
                UD.undo.data.chXData{chIdx} = UD.channels(chIdx).allXData{undoIdx};
                UD.undo.data.chYData{chIdx} = UD.channels(chIdx).allYData{undoIdx};
            end
            UD.undo.action = 'delete';
            UD = dataSet_delete(UD,undoIdx);

        case 'move'
            newIdx = undoIdx;
            oldIdx = UD.undo.data;
            dsCnt = length(UD.dataSet);
            if (oldIdx>newIdx)
		        old2newIdx = [1:(newIdx-1) oldIdx  newIdx:(oldIdx-1) (oldIdx+1):dsCnt];
		    else
        		old2newIdx = [1:(oldIdx-1) (oldIdx+1):newIdx oldIdx (newIdx+1):dsCnt];
            end
            UD = dataSet_reorder(UD,old2newIdx,old2newIdx(UD.current.dataSetIdx));
        	UD.undo.data = newIdx;
        	UD.undo.index = oldIdx;
            UD = dataSet_sync_menu_state(UD);
            UD = update_tab_sub_menu(UD);
            
            
        case 'rename'
            tempName = UD.undo.data;
            UD.undo.data = UD.dataSet(undoIdx).name;
            UD.dataSet(undoIdx).name = tempName;
            sigbuilder_tabselector('rename',UD.hgCtrls.tabselect.axesH,undoIdx,tempName);
            UD = update_tab_sub_menu(UD);
            
            
        case 'timeRange'
            tempChannels = UD.undo.data.channels;
            timeRange = UD.undo.data.timeRange;
            UD.undo.data.channels = UD.channels;
            UD.undo.data.timeRange = UD.common.dispTime;
            UD.channels = tempChannels;
            UD.common.dispTime = timeRange;
            UD.common.minTime = timeRange(1);
            UD.common.maxTime = timeRange(2);
            set_new_time_range(UD,timeRange);
            UD = redraw(UD);
        
        otherwise
        end
    
    otherwise
    end


	if strcmp(method,'undo')
        UD.undo.command = 'redo';
        set([UD.menus.figmenu.undo UD.toolbar.undo],'Enable','off');
        set([UD.menus.figmenu.redo UD.toolbar.redo],'Enable','on');
    else
        UD.undo.command = 'undo';
        set([UD.menus.figmenu.undo UD.toolbar.undo],'Enable','on');
        set([UD.menus.figmenu.redo UD.toolbar.redo],'Enable','off');
    end
    

function UD = redraw(UD),

    % Update the line XY plots
    dsIdx = UD.current.dataSetIdx;
    dispChans = UD.dataSet(dsIdx).activeDispIdx;
    
    for i=1:length(dispChans)
        chIdx = dispChans(i);
        set(UD.channels(chIdx).lineH,   'Xdata',     UD.channels(chIdx).xData, ...
                                        'Ydata',     UD.channels(chIdx).yData);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                      CHANNEL DATA TRANSFORMATIONS                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CHANNEL_DATA_TRANSFORMATIONS   


function [UD,applyStr] = rename_channel(UD,chIdx,str)
    oldStr = UD.channels(chIdx).label;

    otherLabels = {UD.channels.label};
    applyStr = uniqueify_str_with_number(str,chIdx,otherLabels{:});

    if UD.current.channel == chIdx
        set(UD.hgCtrls.chDispProp.labelEdit,'String',applyStr);
    end

    if ~strcmp(applyStr,UD.channels(chIdx).label) & ~isempty(UD.simulink)
        sigbuilder_block('rename_outport',UD.simulink,chIdx,applyStr);
    end

    UD.channels(chIdx).label = applyStr;   

    % Update the channel display listbox
    if length(applyStr)>22
        newStr = [applyStr(1:18) '...        '];
    else
        newStr = [applyStr char(32*ones(1,29-length(applyStr)))];
    end

    chanStr = get(UD.hgCtrls.chanListbox,'String');
    newStr((end-6):end) = chanStr(chIdx,(end-6):end);
    
    chanStr(chIdx,:) = newStr;
    set(UD.hgCtrls.chanListbox,'String',chanStr);
    
    axesIdx = UD.channels(chIdx).axesInd;
    if ~isempty(axesIdx) && axesIdx>0
        labelH = UD.axes(axesIdx).labelH;
        set(labelH,'String',applyStr);
        update_axes_label(UD,axesIdx);
    end
    sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
    update_selection_msg(UD);    
    UD = set_dirty_flag(UD);


function UD = change_channel_index(UD,newIdx,oldIdx)

	dsIdx = UD.current.dataSetIdx;
	activeDispIdx = UD.dataSet(dsIdx).activeDispIdx;
	chanCnt = length(UD.channels);

    % Unselect any channel to avoid confusion
	UD.current.channel = 0;
	UD = mouse_handler('ForceMode',UD.dialog,UD,1);
    UD = update_channel_select(UD);
	
	if newIdx>oldIdx
		changeAxesIdx = find(activeDispIdx>=oldIdx & activeDispIdx<=newIdx);
		old2newIdx = [1:(oldIdx-1) (oldIdx+1):newIdx oldIdx (newIdx+1):chanCnt];
		old2newAxIdx = [	1:(changeAxesIdx(1)-1) ...
							changeAxesIdx(end) ...
							changeAxesIdx(1:(end-1)) ...
							(changeAxesIdx(end)+1):length(UD.axes)];
	else
		changeAxesIdx = find(activeDispIdx>=newIdx & activeDispIdx<=oldIdx);
		old2newIdx = [1:(newIdx-1) oldIdx  newIdx:(oldIdx-1) (oldIdx+1):chanCnt];
		old2newAxIdx = [	1:(changeAxesIdx(1)-1) ...
							changeAxesIdx(2:end) ...
							changeAxesIdx(1) ...
							(changeAxesIdx(end)+1):length(UD.axes)];
	end
	
	
	changeChanIdx = [];
	if length(changeAxesIdx)>1	% We need to swap the display axes
		changeChanIdx = activeDispIdx(changeAxesIdx);
		axesObjs = cat(1,UD.axes.handle);

		axPos = get(axesObjs(changeAxesIdx),'Position');
		newOrderAxes = axesObjs(old2newAxIdx(changeAxesIdx));	
		set(newOrderAxes,{'Position'},axPos);
	
		UD.axes = UD.axes(old2newAxIdx);
	end

	
	% Vectorized swap of channels, properties, etc
	UD.channels = UD.channels(old2newIdx);
	listBoxStr = get(UD.hgCtrls.chanListbox,'String');
	set(UD.hgCtrls.chanListbox,'String',listBoxStr(old2newIdx,:));
	
	[xxx,new2oldIdx] = sort(old2newIdx);
	for i=1:length(UD.dataSet)
        UD.dataSet(i).activeDispIdx = fliplr(sort(new2oldIdx(UD.dataSet(i).activeDispIdx)));
	end
	
	% Correct misc properties
	newActiveDispIdx = UD.dataSet(dsIdx).activeDispIdx;
	%for chIdx = changeChanIdx(:)'
        
    for i=1:length(newActiveDispIdx)
        chIdx = newActiveDispIdx(i);
		if ~isempty(UD.channels(chIdx).lineH)
			lineUd = get(UD.channels(chIdx).lineH,'UserData');
			lineUd.index = chIdx;
			set(UD.channels(chIdx).lineH,'UserData',lineUd);
			UD.channels(chIdx).axesInd = i;
		end
	end	
	
    
    
	for axIdx = changeAxesIdx(:)'
		axUd = get(UD.axes(axIdx).handle,'UserData');
		axUd.index = axIdx;
		set(UD.axes(axIdx).handle,'UserData',axUd);
		UD.axes(axIdx).channels = UD.dataSet(dsIdx).activeDispIdx(axIdx);
	end	
	
	
	% If we changed the position of the bottom axes we need to move the
	% xlabel and tick marks
	if (changeAxesIdx(1)==1) 
        xlabelAxes = UD.axes(find(old2newAxIdx==1)).handle;
        axesH = UD.axes(1).handle;
        xl = get(axesH,'XLabel');
        set(axesH,'XTick',get(xlabelAxes,'XTick'));
        set(axesH,'XTickLabel',get(xlabelAxes,'XTickLabel'));
        set(xlabelAxes,'XTickLabel','');
        xlold = get(xlabelAxes,'XLabel');
        set(xlold,'String','');
        ax.XTickLabelMode = 'auto';
        ax.XTickMode = 'auto';
        set(xl,'String','Time (sec)','FontWeight','Bold');  
        set(axesH,ax);
	end
	
	
	if ~isempty(UD.simulink)
		UD.simulink = sigbuilder_block('move_port',UD.simulink,newIdx,oldIdx);
	end
	
	update_all_axes_label(UD);
	sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
	
	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD_NEW_INTERPOLATED_POINTS - Linear interpolation for a single x value
% 
function UD = add_new_interpolated_points(UD,chIdx,x)
    X = UD.channels(chIdx).xData;
    Y = UD.channels(chIdx).yData;

    % Find the interpolated values
    newY = [];
    newX = [];
    for xi = x(:)'
        if ~any(X==xi)
            yi = scalar_interp(xi,X,Y);
            newY= [newY yi];
            newX= [newX xi];
        end
    end
    
    % Find the index in the new X vector
    n = length(X);
    p = length(newX);
    [X,I] = sort([X newX]);
    Y = [Y newY];
    Y = Y(I);
    
    % Update the data structures and hg
    UD = apply_new_channel_data(UD,chIdx,X,Y);
    %set(UD.channels(chIdx).lineH,'YData',Y,'XData',X);
    %UD.channels(chIdx).xData = X;
    %UD.channels(chIdx).yData = Y;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK_INPUT_DATA - Verify that input data can be added
% to the set of channels.  Return empty values if not
% 
function [x,y] = check_input_data(UD,rawX,rawY)

    errMsg = '';
    if ~isreal(rawX) | ~ isreal(rawY)
        errMsg = 'Imported data must be real';
    end

    if length(rawX)~=length(rawY)
        errMsg = 'X and Y data must be the same length';
    end
    
    if any(diff(rawX)<0)
        errMsg = 'X must be monotonically increasing';
    end

    if length(rawX)<2 | rawX(1)>= UD.common.maxTime | ...
       rawX(2) <= UD.common.minTime
        errMsg = ['Signal data must be at least two points', ...
                   ' and partially overlap the display region'];
    end

    if ~isempty(errMsg)
        errordlg(errMsg);
        x = [];
        y = [];
    else
        [x,y] = correct_endpoints(UD,rawX,rawY);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORRECT_ENDPOINTS - Correct the time range of a signal so
% that the extreme points match the current time span.
% 
function [x,y] = correct_endpoints(UD,rawX,rawY,minx,maxx)

    if nargin<5
        minx = UD.common.minTime;
        maxx = UD.common.maxTime;
    end

    deletePoints = (rawX<minx | rawX>maxx);

    % Maintain at least two points:
    keepInd = find(~deletePoints);

    if(keepInd(1)>1 & rawX(keepInd(1))>minx)
        keepInd = [keepInd(1)-1 keepInd];
    end

    if(keepInd(end)<length(rawX) & rawX(keepInd(end))<maxx)
        keepInd = [keepInd keepInd(end)+1];
    end

    x = rawX(keepInd);
    y = rawY(keepInd);

    if x(1) > minx
        if y(2)==y(1),
            x(1) = minx;
        else
            x = [minx x];
            y = [y(1) y];
        end
    elseif x(1)< minx
        newY = scalar_interp(minx,x,y);
        x(1) = minx;
        y(1) = newY;
    end

    if x(end) < maxx
        if y(end-1)==y(end)
            x(end) = maxx;
        else
            x = [x maxx];
            y = [y y(end)];
        end
    elseif x(end) > maxx
        newY = scalar_interp(maxx,x,y);
        x(end) = maxx;
        y(end) = newY;
    end
            


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCALAR_INTERP - Linear interpolation for a single x value
% 
function y = scalar_interp(x,xVect,yVect,direction)

    I = find(x>=xVect(1:(end-1)) & x<=xVect(2:end));
    
    if isempty(I)
        y = [];
        return;
    end
    
    if length(I)>1
       if nargin>3 &  direction<0
            y = yVect(I(1));
       else
            y = yVect(I(end));
       end
    else
        ind = I + [0 1];
        y = yVect(I) + (x-xVect(I))*diff(yVect(ind))/diff(xVect(ind));
    end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE_DUPLICATE_POINTS 
% 
function [x,y] = remove_duplicate_points(x,y)

    isDuplicate = (x(1:(end-1))==x(2:end) & y(1:(end-1))==y(2:end));
    x(isDuplicate) = [];
    y(isDuplicate) = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMON_TIME_VECT - Utility function for combining multiple time vectors
% 
% [t, I1, I2, ...] = COMMON_TIME_VECT(t1, t2, ...) Find a common time vector t
% that contains every element in t1, t2, ..., in order without repeats, and a
% set of index vectors such that t(I1) = t1, t(I2) = t2, ...

function varargout = common_time_vect(varargin)

    if (nargout==0 | (nargout > 1 & nargout~=(nargin+1)))
        error('Inconsistent arguments');
    end


    allTimes = [];
    for i=1:nargin
        allTimes = [allTimes varargin{i}(:)'];
    end

    T = sort(allTimes);
    T(find(diff(T)==0)) = [];  % Remove duplicates

    varargout{1} = T;

    if nargout>1,
        for i=1:nargin
            Tin = varargin{i}(:)';
            rawInd = find(diff(sort([T Tin]))==0);
            varargout{i+1} = rawInd - (1:length(rawInd)) + 1;
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_TIME_ARROWS - Add or move a pair of arrows that 
% indicate the current time is undefined
% 
function UD = update_time_arrows(UD,chNum,x,y),

    axesH = UD.axes(UD.channels(chNum).axesInd).handle;
    H = findobj(axesH,'Tag','IndicatorArrows');

    if isempty(H)
        indicator = create_time_arrows(UD,axesH,x,y);
        return;
    else
        indicator = get(H,'UserData');
    end

    deltaY = y - indicator.origin(2);
    deltaX = x - indicator.origin(1);
    
    objs = [indicator.patchR indicator.lineR indicator.arrowR ...
            indicator.patchL indicator.lineL indicator.arrowL];

    if(deltaY==0 & deltaX==0)
        set(objs,'Visible','on');
        return;
    end

    XData = get(objs,'XData');
    YData = get(objs,'YData');

    for i=1:length(objs)
        set(objs(i),'XData',XData{i}+deltaX,'YData',YData{i}+deltaY);
    end
    indicator.origin = [x y];
    set(indicator.patchR,'UserData',indicator);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_TIME_ARROWS - Create a pair of arrows that 
% indicate the current time is undefined
% 
function indicator = create_time_arrows(UD,axesH,x,y)

    % Geometry constants in points:
    arrowWidth = 6;
    arrowLength = 10;
    segmentLength = 15;
    indicatorSep = 4;
    lineColor = 0.4*[1 1 1];

    arrowExt = fig_2_ax_ext([arrowLength arrowWidth],axesH);
    wConv = arrowExt(1)/arrowLength;

    patchX = [0 0 1 1]*(arrowExt(1)+wConv*segmentLength) + wConv*indicatorSep/2;
    patchY = [1 -1 -1 1]*(arrowExt(2)/2);

    headPatchX = [0 0 1]*arrowExt(1) + (wConv *(segmentLength + indicatorSep/2));
    headPatchY = [.5 -.5 0]*arrowExt(2);

    lineX = [0 1]*wConv*segmentLength + wConv*indicatorSep/2;
    lineY = [0 0];

    indicator.origin = [x y];
    
    % Right patch
    indicator.patchR = patch(   'Parent',           axesH, ...
                                'LineStyle',        'none', ...
                                'XData',            x+patchX, ...
                                'YData',            y+patchY, ...
                                'FaceColor',        [1 1 1]);
    
    % Right line
    indicator.lineR =  line(    'Parent',           axesH, ...
                                'XData',            x+lineX, ...
                                'YData',            y+lineY, ...
                                'Color',            lineColor);

    % Right arrowhead
    indicator.arrowR = patch(   'Parent',           axesH, ...
                                'LineStyle',        'none', ...
                                'XData',            x+headPatchX, ...
                                'YData',            y+headPatchY, ...
                                'FaceColor',        lineColor);
    
    % Left patch
    indicator.patchL = patch(   'Parent',           axesH, ...
                                'LineStyle',        'none', ...
                                'XData',            x-patchX, ...
                                'YData',            y+patchY, ...
                                'FaceColor',        [1 1 1]);
    
    % Left line
    indicator.lineL =  line(    'Parent',           axesH, ...
                                'XData',            x-lineX, ...
                                'YData',            y+lineY, ...
                                'Color',            lineColor);

    % Left arrowhead
    indicator.arrowL = patch(   'Parent',           axesH, ...
                                'LineStyle',        'none', ...
                                'XData',            x-headPatchX, ...
                                'YData',            y+headPatchY, ...
                                'FaceColor',        lineColor);
    
    
    set(indicator.patchR,'Tag','IndicatorArrows','UserData',indicator);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHOW_ADJUSTMENT_DISPLAYS - Create or make visible a set of
% uicontrols that adjust the time of the selected object
% 
function UD = show_adjustment_displays(UD,axesH,x,y,maxTime),

    displX = 40;

    % Create the objects if the uicontrols don't exist
    if ~isfield(UD.hgCtrls,'timeAdjCtrls')
        [UD.hgCtrls.timeAdjCtrls,extent] = create_time_adjust_controls(UD,[0 0]);
        oldOrigin = [0 0];
    else
        framePos = get(UD.hgCtrls.timeAdjCtrls.frame,'Position');
        extent = framePos(3:4);
        oldOrigin = UD.hgCtrls.timeAdjCtrls.origin;
    end

    % Determine the desired position
    P = ax_2_fig_coord([x y],axesH);
    axT = UD.current.axesExtent(2) + UD.current.axesExtent(4);
    axB = UD.current.axesExtent(2);
    axL = UD.current.axesExtent(1) + UD.current.axesExtent(3);
    
    if (axL - P(1)) < (extent(1)+displX)
        newOrigin(1) = P(1) - (extent(1)+displX);
    else
        newOrigin(1) = P(1) + displX;
    end
    
    if (axT - P(2)) < (extent(2)/2)
        newOrigin(2) = axT - extent(2);
    else
        if (P(2) - axB) < (extent(2)/2)
            newOrigin(2) = axB;
        else
            newOrigin(2) = P(2) - extent(2)/2;
        end
    end

    % Move the controls
    moveVect = newOrigin - oldOrigin;
    objs = [UD.hgCtrls.timeAdjCtrls.frame, UD.hgCtrls.timeAdjCtrls.scroll, ...
            UD.hgCtrls.timeAdjCtrls.edit, UD.hgCtrls.timeAdjCtrls.scalePopup, ...
            UD.hgCtrls.timeAdjCtrls.direction, UD.hgCtrls.timeAdjCtrls.label, ...
            UD.hgCtrls.timeAdjCtrls.apply];
    positionCell = get(objs,'Position');
    positionMatrix = cat(1,positionCell{:});
    positionMatrix(:,1) = positionMatrix(:,1) + moveVect(1);
    positionMatrix(:,2) = positionMatrix(:,2) + moveVect(2);
    newPositionCell = num2cell(positionMatrix,2);
    UD.hgCtrls.timeAdjCtrls.origin = newOrigin;
    set(objs,{'Position'},newPositionCell);
    
    % Set the starting values for settings
    decade = floor(log10(maxTime));
    if decade<-7,
        mult = -9;
    elseif decade > 4
        mult = 6;
    else
        mult = 3*floor((decade+1)/3);
    end
    UD.hgCtrls.timeAdjCtrls.mult = mult;
    popupVal = mult/3 + 4;
    dispNum = (10^(-mult)) * (maxTime/2);
    dispStr = num2str(dispNum);
    set(UD.hgCtrls.timeAdjCtrls.scroll,'Value',0.5);
    set(UD.hgCtrls.timeAdjCtrls.scalePopup,'Value',popupVal);
    set(UD.hgCtrls.timeAdjCtrls.edit,'String',dispStr);
    set(UD.hgCtrls.timeAdjCtrls.direction,'Value',0);
    
    % Make the controls visible
    set(objs,'Visible','on');
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE_TIME_ADJUST_DISPLAYS - Hide the time adjustment 
% uicontrols.
% 
function UD = hide_time_adjust_displays(UD),


    objs = [UD.hgCtrls.timeAdjCtrls.frame, UD.hgCtrls.timeAdjCtrls.scroll, ...
            UD.hgCtrls.timeAdjCtrls.edit, UD.hgCtrls.timeAdjCtrls.scalePopup, ...
            UD.hgCtrls.timeAdjCtrls.direction, UD.hgCtrls.timeAdjCtrls.label, ...
            UD.hgCtrls.timeAdjCtrls.apply];

    % Make the controls visible
    set(objs,'Visible','off');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIDE_TIME_ARROWS - Hide a pair of arrows that 
% indicate the current time is undefined
% 
function UD = hide_time_arrows(UD,chNum),
    if chNum==0
        return;
    end
    
    axesH = UD.axes(UD.channels(chNum).axesInd).handle;
    H = findobj(axesH,'Tag','IndicatorArrows');

    if isempty(H)
        return;
    else
        indicator = get(H,'UserData');
    end
    
    objs = [indicator.patchR indicator.lineR indicator.arrowR ...
            indicator.patchL indicator.lineL indicator.arrowL];

    set(objs,'Visible','off');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE_TU_PAIR - Combine different T/Y pairs into a single vector pair.
% [T,U] = generate_TU_pair(t1, t2, ..., y1, y2, y3, ...);
%
% NOTE: We assume that t1(0)==t2(0)==... and t1(end)==t2(end)==...
%
function [Tnew,Unew] = generate_TU_pair(varargin)

    if mod(nargin,2)~=0 
        error('Must have matched t,y input arguments');
    end
    
    nVars = nargin/2;
    indVar = cell(1,nVars);
    
    [T,indVar{:}] = common_time_vect(varargin{1:(nVars)});

    % First we build T U without duplicate time values, i.e., no
    % discontinuities.  Then we insert the discontinuities.
    T = T(:);
    U =[];
    dupValues = [];
    for i=1:nVars
        I = indVar{i};

        % Some calculations for handling discontinuities
        irep = find(diff(I)==0);
        dup{i} = I(irep);
        Irepeat{i} = sort([irep irep+1]);
        dupValues = [dupValues dup{i}];

        t_in = varargin{i};
        y_in = varargin{i+nVars};
        
        Y(I) = y_in; % Non-interpolated values
        
        for int_lft = find(diff(I)>1),
            Idx_in = int_lft +[0 1];
            Idx_out = I(Idx_in);
            Idx_interp = (Idx_out(1)+1):(Idx_out(2)-1);
            
            slope = diff(y_in(Idx_in))/diff(t_in(Idx_in));
            Y(Idx_interp) = y_in(int_lft)-t_in(int_lft)*slope+T(Idx_interp)*slope;
        end
        
        U = [U Y'];
    end

    % Insert the discontinuities
    dupValues = sort(dupValues);
    dupValues(find(diff(dupValues)==0)) = [];   % Remove duplicate dups (ignore mult 
                                                % discontinuities at the same time value)

    % Develop a mapping for final T vector to its non duplicate
    reMap = 1:length(T);
    reMap = sort([reMap dupValues]);

    % Duplicate data at discontinuities
    Tnew = T(reMap);
    Unew = U(reMap,:);

    for i=1:nVars
        y_in = varargin{i+nVars};
        Irep = Irepeat{i};
        Iout = [];
        for dupInIdx = dup{i}
            Iout = [Iout find(reMap==dupInIdx)];
        end
        Unew(Iout,i) = y_in(Irep)';
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE_PIECEWISE_CONSTANT - Convert a signal to it stair
% step equivalent by making all y value changes 
% instantaneous in x.
% 
function [xnew,ynew] = make_piecewise_constant(x,y,hold_forward)
    
    % Hold forward by default
    if nargin==2 | isempty(hold_forward)
        hold_forward = 1;
    end

    xnew = x;
    ynew = y;

    % Find the index of continuous y value changes
    ImustChange = find(abs(diff(y))>0 & diff(x)~=0);
    if isempty(ImustChange)
        return;
    end
    
    Iout = ImustChange + (1:length(ImustChange));

    for ind = Iout,
        if hold_forward
            xinsert = xnew(ind);
            yinsert = ynew(ind-1);
        else
            xinsert = xnew(ind-1);
            yinsert = ynew(ind);
        end

        xnew = [xnew(1:(ind-1)) xinsert xnew(ind:end)];
        ynew = [ynew(1:(ind-1)) yinsert ynew(ind:end)];
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE_COLINEAR_POINTS - Ensure that no more than two 
% points in a row have the same Y value
% 
function [xnew,ynew] = remove_colinear_points(x,y)

    xnew = x;
    ynew = y;

    % Allow no more than two points with the exact same x value
    sameY = diff(y)==0;
    I_eliminate = find(sameY(1:(end-1)) & diff(sameY)==0)+1;
    xnew(I_eliminate) = [];
    ynew(I_eliminate) = [];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE_UNNEEDED_POINTS - Ensure that x is monotonically
% increasing and duplicates only occur if the y values
% change.
% 
function [xnew,ynew] = remove_unneeded_points(x,y)

    xnew = x;
    ynew = y;

    % Allow no more than two points with the exact same x value
    sameX = diff(x)==0;
    
    % Check for the degenerate case
    if length(sameX)==1 & sameX==0
        return;
    end
    
    I_eliminate = find(sameX(1:(end-1)) & diff(sameX)==0)+1;
    xnew(I_eliminate) = [];
    ynew(I_eliminate) = [];
    
    % Remove duplicate points
    I_eliminate = find(diff(xnew)==0 & diff(ynew)==0);
    xnew(I_eliminate) = [];
    ynew(I_eliminate) = [];
    
    % Ensure that there are no discontinuities at the end points
    if diff(xnew(1:2))==0,
        xnew(1) = [];
        ynew(1) = [];
    end
    if diff(xnew((end-1):end))==0;
        xnew(end) = [];
        ynew(end) = [];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET_AMPLITUDE_OFFSET
% 
function [amplitude,offset] = get_amplitude_offset(y)
    yMax = max(y);
    yMin = min(y);
    amplitude = (yMax-yMin)/2;
    offset = (yMax+yMin)/2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET_AMPLITUDE_OFFSET
% 
function ynew = set_amplitude_offset(y,amplitude,offset)
    yMax = max(y);
    yMin = min(y);
    oldAmp = (yMax-yMin)/2;
    oldOff = (yMax+yMin)/2;

    ynew = (y- oldOff)*(amplitude/oldAmp) + offset;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE_CHANNEL_LABEL_UNIQUE
% 
function UD = make_channel_label_unique(UD,chIdx)
    allLabels = strvcat(UD.channels.label);
    thisLabel = UD.channels(chIdx).label;

    % If the label is 'Signal ' foloowed by non-letters
    % end the label with the correct signal number
    if length(thisLabel)>6  & strcmp(thisLabel(1:7),'Signal ') & ...
                all(~isletter(thisLabel(8:end)))
        
        UD.channels(chIdx).label = sprintf('Signal %s', num2str(chIdx));
        return
    end

    otherIdx = [1:(chIdx) (chIdx+1):UD.numChannels];
    matches = 0;
    for ind = otherIdx
        if strcmp(thisLabel,deblank(allLabels(ind,:)))
            matches = 1;
        end
    end
    
    if matches,
        [nonNum,start] = strtok(fliplr(thisLabel),'0123456789');
        prefixL = length(nonNum) + length(start);
        lastNum = str2num(thisLabel((prefixL+1):end));
        UD.channels(chIdx).label = [thisLabel(1:prefixL) num2str(lastNum+1)];
    end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_CHANNEL_SELECT - Perform all the side effects of
% selecting a channel or changing the channel selected.
% (Enabling controls, syncing display strings, etc.).  When
% the current channel is 0, this function removes strings
% and disables controls
% 
function UD = update_channel_select(UD)

    persistent LastChannelSelected
    if isempty(LastChannelSelected)
        LastChannelSelected = 0;
    end

    chIdx = UD.current.channel;

    
    if chIdx==0 | in_iced_state_l(UD),   % We are disabling channel controls

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % DISABLE_CHANNEL_SPECIFIC_CONTROLS 
        menuHandles = get(UD.menus.figmenu.signal,'Children');
        menuHandles(menuHandles==UD.menus.figmenu.new) = []; % Filter out New menu which is always enabled
        menuHandles(menuHandles==UD.menus.figmenu.show) = []; % Filter out Show menu
        menuHandles = [menuHandles(:)'   UD.menus.figmenu.channelEnabled]; 
        set(menuHandles, 'Enable','off');
        set([UD.toolbar.cut UD.toolbar.copy], 'Enable','off');
        
        

        figbgcolor = get(UD.dialog,'Color');
        set(UD.hgCtrls.chDispProp.legendLine,'Visible','off');
        set(UD.hgCtrls.chDispProp.labelEdit, ...
             'String',              '', ...
             'Enable',              'off', ...
             'BackgroundColor',     figbgcolor);
        
        set(UD.hgCtrls.chDispProp.indexPopup, ...
             'String',              ' ', ...
             'Value',               1, ...
             'Enable',              'off', ...
             'BackgroundColor',     figbgcolor);
        set([UD.hgCtrls.chDispProp.indexLabel UD.hgCtrls.chDispProp.labelLabel], ...
             'Enable',              'off');


        % Unselect the previous line 
        if (LastChannelSelected<=UD.numChannels) && LastChannelSelected>0 && ...
                ~isempty(UD.channels(LastChannelSelected).lineH) && ...
                ishandle(UD.channels(LastChannelSelected).lineH)
                    set(UD.channels(LastChannelSelected).lineH,'Marker','none');
        end


    else    % (chIdx>0)  We are enabling channel controls
        if(LastChannelSelected==0) 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % ENABLE_CHANNEL_SPECIFIC_CONTROLS 
            menuHandles = get(UD.menus.figmenu.signal,'Children');
            menuHandles(menuHandles==UD.menus.figmenu.show) = []; % Filter out Show menu
            menuHandles = [menuHandles(:)'   UD.menus.figmenu.channelEnabled]; 
            set(menuHandles,'Enable','on');
            set([UD.toolbar.cut UD.toolbar.copy], 'Enable','on');

            set([UD.hgCtrls.chDispProp.indexLabel UD.hgCtrls.chDispProp.labelLabel], ...
                 'Enable',              'on');
            set(UD.hgCtrls.chDispProp.labelEdit, ...
                 'Enable',              'on', ...
                 'BackgroundColor',     'w');
 
           set(UD.hgCtrls.chDispProp.indexPopup, ...
                  'Enable',              'on', ...
                 'BackgroundColor',     'w');
        end

        lineH = UD.channels(chIdx).lineH; 

        % Select this line 
        set(lineH,'Marker','diamond','MarkerSize',5);

        % Unselect the previous line 
        % Update the legend line
        props = {'Color','LineStyle','LineWidth'};   
        vals = get(lineH,props);
        set(UD.hgCtrls.chDispProp.legendLine,'Visible','on',props,vals);
        
        % Update the label edit box
        set(UD.hgCtrls.chDispProp.labelEdit, ...
             'String',              UD.channels(chIdx).label);
        
        % Update the listbox selection
        set(UD.hgCtrls.chanListbox,'Value',chIdx);
        
        % Update the index popup
        nums = 1:UD.numChannels;
        outIdx = UD.channels(chIdx).outIndex;
        set(UD.hgCtrls.chDispProp.indexPopup, ...
             'String',              num2str(nums'), ...
             'Value',               chIdx);
        
        if LastChannelSelected>0 && (LastChannelSelected<=UD.numChannels) && ...
            LastChannelSelected~=chIdx && ...
            ~isempty(UD.channels(LastChannelSelected).lineH) && ...
            ishandle(UD.channels(LastChannelSelected).lineH)
                set(UD.channels(LastChannelSelected).lineH,'Marker','none');
        end

        % Mark the appropriate t-step and y-step submenus as checked:
        stepX = UD.channels(chIdx).stepX;
        stepY = UD.channels(chIdx).stepY;
        
        check_mark_matching_submenu(UD.menus.figmenu.ysnap,stepY);
        check_mark_matching_submenu(UD.menus.figmenu.tsnap,stepX);
        check_mark_matching_submenu(UD.menus.channelContext.setStepY_main,stepY);
        check_mark_matching_submenu(UD.menus.channelContext.setStepX_main,stepX);
     end

    update_selection_msg(UD)
    if in_iced_state_l(UD),
       LastChannelSelected = 0; % to force a clean refresh when the simulation is done.
    else,
       LastChannelSelected = chIdx;
    end;
    sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%               CONTEXT MENU AND TOOLBAR UTILITY FUNCTIONS               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CONTEXT_MENU_AND_TOOLBAR_UTILITY_FUNCTIONS   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIG_MENU_HANDLER - Execute a callback for a figure menu.
% 
function [UD,modified] = fig_menu_handler(method,dialog,UD,varargin)

    modified = 1;
    if nargin>3
        add_new = varargin{1};
    else
        add_new = 0;
    end

    switch(method)
    case 'open'
        [filename, pathname] = uigetmdlfile;
        if (~isempty(filename)), 
        	% Temporarily cd'ing to the directory in question is the only way 
        	% to get rid of unwanted name crufts (such as: 'f:\...'); 
        	% These are to be avoided as they will polute the name of the model
        	% and then in turn corrupt the machine name.

        	pwDir = pwd;
        	cd(pathname);
        	open_system(filename); 
        	cd(pwDir);
        else
            modified = 0;
        end;
        
    case 'save'
        UD = sl_command(UD,'save');

    case 'saveas'
        if isempty(UD.simulink.modelH)
            modified = 0;
            return;            
        end
        
        [filename, pathname] = uiputmdlfile;
        if (~isempty(filename)), 
        	% Temporarily cd'ing to the directory in question is the only way 
        	% to get rid of unwanted name crufts (such as: 'f:\...'); 
        	% These are to be avoided as they will polute the name of the model
        	% and then in turn corrupt the machine name.

        	pwDir = pwd;
        	cd(pathname);
        	save_system(UD.simulink.modelH,filename); 
        	cd(pwDir);
        else
            modified = 0;
        end;

    case 'show'
        chanIdx = varargin{1};
        dsIdx = UD.current.dataSetIdx;
    	axesIdx = find(UD.dataSet(dsIdx).activeDispIdx==chanIdx);
        
        if isempty(axesIdx)
            if is_space_for_new_axes(UD)
                newAxesIdx = sum(UD.dataSet(dsIdx).activeDispIdx>chanIdx)+1;
                UD = new_axes(UD,newAxesIdx,[]);
                [UD,lineH] = new_plot_channel(UD,chanIdx,newAxesIdx);
                UD.current.channel = chanIdx;
                mouse_handler('ForceMode',[],UD,3);
                UD = update_channel_select(UD);
                UD = update_show_menu(UD);
            else
                msgTxt = sprintf(['Insufficient drawing space.  ' ... 
                               'Resize the window or hide other signals before ' ...
                               'attempting to display this signal']);
                msgbox(msgTxt,'Out of Space');
                modified = 0;
           end
        else
            modified = 0;
        end
        
    case 'showTab'
        dsIdx = varargin{1};
        UD = dataSet_activate(UD,dsIdx);
        sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);
        
    case 'undo'
        UD = perform_undo_or_redo(UD,'undo');

    case 'redo'
        UD = perform_undo_or_redo(UD,'redo');

    case 'cut'
        [UD,modified] = channel_handler(method,dialog,UD);
    case 'copy'
        [UD,modified] = channel_handler(method,dialog,UD);
    case 'paste'
        if UD.current.mode==3 | UD.current.mode==7
            [UD,modified] = channel_handler(method,dialog,UD);
        else
            if strcmp(UD.clipboard.type,'channel')
                UD = new_channel(   dialog,UD, ...
                                    UD.clipboard.content.xData, ...
                                    UD.clipboard.content.yData, ...
                                    UD.clipboard.content.stepX, ...
                                    UD.clipboard.content.stepY, ...
                                    UD.clipboard.content.label);
                if length(UD.channels(end).allXData)==length(UD.clipboard.content.allXData)                
                    UD.channels(end).allXData = UD.clipboard.content.allXData;
                    UD.channels(end).allYData = UD.clipboard.content.allYData;
                end
        	    UD = new_axes(UD,1,[]);
                UD = new_plot_channel(UD,UD.numChannels,1);  
                UD.current.mode = 3;
                UD.current.channel = UD.numChannels;
                UD.current.bdPoint = [0 0];
                UD.current.bdObj = UD.channels(UD.numChannels).lineH;
                UD = update_channel_select(UD);
            end
        end

    case 'delete'
        [UD,modified] = channel_handler(method,dialog,UD);
    case 'export_ws'
        name = sigbuilder_modal_edit_dialog('Export to workspace','Variable name: ','channels');
        if ischar(name)
            try,
                assignin('base',name,UD.channels);
            catch,
                errordlg(sprintf('Error while exporting:\n%s', lasterr));
            end
        end
        
    case 'export_sl'
        UD = export_to_simulink(UD);
        modified = 1;
    case 'close'
    case 'setTrange'
        prompts = {'Min time: ', 'Max Time: '};
        startVals = {num2str(UD.common.minTime), num2str(UD.common.maxTime)};
        vals = sigbuilder_modal_edit_dialog('Set the total time range',prompts,startVals);
        if iscell(vals)
	        minTime = eval_to_real_scalar(vals{1},'minimum');
	        maxTime = eval_to_real_scalar(vals{2},'maximum');
			if isempty(minTime) | isempty(maxTime)
	            modified = 0;
	            return;
			end
			if maxTime <= minTime
				errordlg('Minimum value must be less than maximum.');
	            modified = 0;
	            return;
			end
            UD = set_new_total_time_range(UD,minTime,maxTime);
        else
            modified = 0;
        end

    case 'simOpts'
        prompts = {'Signal values after final time: ','Sample time: '};
        afterFinalStrs = {'Hold final value','Extrapolate','Set to zero'};

        if ~isfield(UD.common,'afterFinalStr') | isempty(UD.common.afterFinalStr)
            UD.common.afterFinalStr = afterFinalStrs{1};
        end
        if ~isfield(UD.common,'sampleTime') | isempty(UD.common.sampleTime)
            UD.common.sampleTime = 0;
        end
        currentIdx = find(strcmp({UD.common.afterFinalStr},afterFinalStrs));
        startVals = {currentIdx,num2str(UD.common.sampleTime)};
        vals = sigbuilder_modal_edit_dialog('Simulation Options',prompts,startVals,[],{afterFinalStrs,[]});
        if iscell(vals)
        	ts = eval_to_real_scalar(vals{2},'sample time');
        	if isempty(ts)
            	modified = 0;
            	return;
			end
			
            UD.common.sampleTime = ts;
            UD.common.afterFinalStr = vals{1};
            UD = set_simulink_simopts(UD);
        else
            modified = 0;
        end
        
       
        
    case 'newAxes'
        UD = new_axes(UD,1,[]); 

    case 'chanColor'     
        [UD,modified] = channel_handler('setColor',dialog,UD);
     
    case 'chanLineStyle' 
        [UD,modified] = channel_handler('setLineStyle',dialog,UD,varargin{1});
     
    case 'chanLineWidth' 
        [UD,modified] = channel_handler('setWidth',dialog,UD);
     
    case 'setYgrid'     
        [UD,modified] = channel_handler('setStepY',dialog,UD);
     
    case 'setTgrid'     
        [UD,modified] = channel_handler('setStepX',dialog,UD);
     
    case 'complement'   
        [UD,modified] = channel_handler('complement',dialog,UD);
     
	case 'chanIndex'
		oldIdx = UD.current.channel;
		if oldIdx==0
			modified = 0;
			return;
		end
		title = sprintf('Change %s index', UD.channels(oldIdx).label);
		labels = {xlate('Index: ')};
		chanCount = length(UD.channels);
		choices = {cellstr(num2str((1:chanCount)'))};
		startvals = {oldIdx};
        vals =  sigbuilder_modal_edit_dialog(title, labels, startvals, [], choices);
		if ischar(vals)	
			newIdx = round(str2num(vals));
			if newIdx<1
				newIdx = 1;
			elseif newIdx > length(UD.channels)
				newIdx = length(UD.channels);
			end	
			if newIdx==oldIdx
				modified = 0;
			else
	        	UD = update_undo(UD,'move','channel',newIdx,oldIdx);
				UD = change_channel_index(UD,newIdx,oldIdx);
	        	UD = set_dirty_flag(UD);
			end
        else
            modified = 0;
        end

    case 'constant'
        UD = add_nonrepeat_normalized_signal(UD,[0 1],[0 0],0,add_new);

    case 'step' 
        xNorm = [0 0.5 0.5 1];
        yNorm = [0 0 1 1];
        UD = add_nonrepeat_normalized_signal(UD,xNorm,yNorm,0,add_new);

    case 'pulse'
        xNorm = [0 0.4 0.4 0.6 0.6 1];
        yNorm = [0 0 1 1 0 0 ];
        UD = add_nonrepeat_normalized_signal(UD,xNorm,yNorm,0,add_new);

    case 'square'
        title = 'Add a square wave';
        labels = {'Frequency: ','Amplitude: ', 'Offset: ','% Duty cycle: '};
        startVals = {'1.0','1.0','1.0','50.0'};
        vals =  sigbuilder_modal_edit_dialog(title, labels, startVals);
        if iscell(vals)
            freq = eval_to_real_scalar(vals{1},'frequency');
            amp = eval_to_real_scalar(vals{2},'amplitude');
            off = eval_to_real_scalar(vals{3},'offset');
            duty = eval_to_real_scalar(vals{4},'duty cycle');
            if isempty(freq) | isempty(amp) | isempty(off) | isempty(duty)
            	modified = 0;
            	return;
            end
            if freq<=0
            	errordlg('Frequency must be a postive number.');
            	modified = 0;
            	return;
            end
            if (duty<0 | duty>100)
            	errordlg('Duty cycle should be between 0 and 100.');
            	modified = 0;
            	return;
            end
            xNorm = [0 0 1 1]*(duty/100);
            yNorm = off + [-1 1 1 -1]*amp;
            UD = add_repeat_normalized_signal(UD,xNorm,yNorm,freq,0,add_new);
        else
            modified = 0;
        end
            
    case 'poison_noise'
        title = 'Add poisson noise';
        labels = {'Avg rate (1/sec): ', 'Seed: (empty to use current state)'};
        startVals = {'10.0',''};
        vals =  sigbuilder_modal_edit_dialog(title, labels, startVals);
        if iscell(vals)
            rate = eval_to_real_scalar(vals{1},'rate');
            if isempty(rate)
            	modified = 0;
            	return;
            end

            if rate<=0
            	errordlg('Rate must be a postive number.');
            	modified = 0;
            	return;
            end
            if ~isempty(vals{2})
                seed = eval_to_real_scalar(vals{2},'seed');
                if isempty(seed)
                	modified = 0;
                	return;
                end
                rand('state',seed);
            end
            
            % Estimate how many samples to take
            expectedL = rate*(UD.common.maxTime-UD.common.minTime)*1.2;
            if (expectedL<2)
                expectedL = 2;
            end
            x = rand(1,expectedL);
            t = -log(x)/rate;
            xNorm = UD.common.minTime + [0 cumsum(t)];
            xNorm = xNorm(xNorm<=UD.common.maxTime);
            xx = [xNorm(1:(end-1));xNorm(2:end)];
            xNorm = xx(:)';
            quartL = ceil(length(xNorm)/4);
            yNorm = repmat([0 0 1 1],1,quartL);
            yNorm = yNorm(1:length(xNorm));
            if isempty(xNorm) % Rate too slow
                UD = add_nonrepeat_normalized_signal(UD,[UD.common.minTime UD.common.maxTime],[0 0],1,add_new);
            else
                UD = add_nonrepeat_normalized_signal(UD,xNorm,yNorm,1,add_new);
            end
        else
            modified = 0;
        end
            
    case 'gausian_noise'
        title = 'Add sampled Gaussian noise';
        labels = {'Frequency: ','Mean: ', 'Variance: ','Seed: (empty to use current state)'};
        startVals = {'10.0','0.0','1.0',''};
        vals =  sigbuilder_modal_edit_dialog(title, labels, startVals);
        if iscell(vals)
            freq = eval_to_real_scalar(vals{1},'frequency');
            mean = eval_to_real_scalar(vals{2},'mean');
            var = eval_to_real_scalar(vals{3},'variance');
            if ~isempty(vals{4})
                seed = eval_to_real_scalar(vals{4},'seed');
                if isempty(seed)
                	modified = 0;
                	return;
                end
                rand('state',seed);
            end
            if isempty(freq) | isempty(mean) | isempty(var)
            	modified = 0;
            	return;
            end
            if freq<=0
            	errordlg('Frequency must be a postive number.');
            	modified = 0;
            	return;
            end

            xNorm = UD.common.minTime:(1/freq):UD.common.maxTime;
            yNorm = mean + var*randn(1,length(xNorm));
            UD = add_nonrepeat_normalized_signal(UD,xNorm,yNorm,1,add_new);
        else
            modified = 0;
        end
            
    case 'binary_noise'
        title = 'Add pseudo random binary noise';
        labels = {'Frequency: ','Upper value: ', 'Lower value: ','Seed: '};
        startVals = {'10.0','1.0','0.0',''};
        vals =  sigbuilder_modal_edit_dialog(title, labels, startVals);
        if iscell(vals)
            freq = eval_to_real_scalar(vals{1},'frequency');
            uval = eval_to_real_scalar(vals{2},'upper value');
            lval = eval_to_real_scalar(vals{3},'lower value');
            if ~isempty(vals{4})
                seed = eval_to_real_scalar(vals{4},'seed');
                if isempty(seed)
                	modified = 0;
                	return;
                end
                rand('state',seed);
            end
            if isempty(freq) | isempty(uval) | isempty(lval)
            	modified = 0;
            	return;
            end
            if freq<=0
            	errordlg('Frequency must be a postive number.');
            	modified = 0;
            	return;
            end
            if uval<lval
            	errordlg('Lower value should be less than upper value.');
            	modified = 0;
            	return;
            end
            
            xNorm = UD.common.minTime:(1/freq):UD.common.maxTime;
            yNorm = lval + (1+sign(rand(1,length(xNorm))-0.5))*(uval-lval)/2;
            [xnew,ynew] = make_piecewise_constant(xNorm,yNorm,1);
            [xnew,ynew] = remove_colinear_points(xnew,ynew);
            UD = add_nonrepeat_normalized_signal(UD,xnew,ynew,1,add_new);
        else
            modified = 0;
        end
            
    case 'sampled_sin'
        title = 'Add a sampled sin';
        labels = {'Frequency (hz): ','Amplitude: ', 'Offset: ','Samples Per Period: '};
        startVals = {'1.0','1.0','1.0','10'};
        vals =  sigbuilder_modal_edit_dialog(title, labels, startVals);
        if iscell(vals)
            freq = eval_to_real_scalar(vals{1},'frequency');
            amp = eval_to_real_scalar(vals{2},'amplitude');
            off = eval_to_real_scalar(vals{3},'offset');
            ns = eval_to_real_scalar(vals{4},'sample count');
            if isempty(freq) | isempty(amp) | isempty(off) | isempty(ns)
            	modified = 0;
            	return;
            end
            if freq<=0
            	errordlg('Frequency must be a postive number.');
            	modified = 0;
            	return;
            end
            if ns<1
            	errordlg('Sample count should be an integer greater than 0.');
            	modified = 0;
            	return;
            end
            
            xNorm = 0:(1/ns):(1-eps);
            yNorm = off + amp*sin(2*pi*xNorm);
            UD = add_repeat_normalized_signal(UD,xNorm,yNorm,freq,0,add_new);
        else
            modified = 0;
        end
            
    case 'triangle'
        title = 'Add a Triangle wave';
        labels = {'Frequency: ','Amplitude: ', 'Offset: '};
        startVals = {'1.0','1.0','1.0'};
        vals =  sigbuilder_modal_edit_dialog(title, labels, startVals);
        if iscell(vals)
            freq = eval_to_real_scalar(vals{1},'frequency');
            amp = eval_to_real_scalar(vals{2},'amplitude');
            off = eval_to_real_scalar(vals{3},'offset');
            if isempty(freq) | isempty(amp) | isempty(off)
            	modified = 0;
            	return;
            end
            if freq<=0
            	errordlg('Frequency must be a postive number.');
            	modified = 0;
            	return;
            end
            xNorm = [0 1];
            yNorm = off + [-1 1]*amp;
            UD = add_repeat_normalized_signal(UD,xNorm,yNorm,freq,0,add_new);
        else
            modified = 0;
        end
            
    case 'import'
        prompts = {'Time Values: ', 'Y Values: '};
        startVals = {'',''};
        vals = sigbuilder_modal_edit_dialog('Custom waveform data',prompts,startVals);
        if iscell(vals)
            try,
                rawx = evalin('base',vals{1});
            catch
                errordlg(sprintf('Could not evaluate X data "%s"\n%s', vals{1},lasterr));
                modified = 0;
                return;
            end
            try,
                rawy = evalin('base',vals{2});
            catch
                errordlg(sprintf('Could not evaluate X data "%s"\n%s', vals{1},lasterr));
                modified = 0;
                return;
            end
            rawx = rawx(:)';
            rawy = rawy(:)';
            [x,y] = check_input_data(UD,rawx,rawy);
            if ~isempty(x)
                if add_new
    				UD = new_axes(UD,1,[]);            
                    UD = new_channel(UD.dialog,UD,x,y);
                    UD = new_plot_channel(UD,UD.numChannels,1);  
                else
                    chIdx = UD.current.channel;
                    UD = apply_new_channel_data(UD,chIdx,x,y);
                    UD = rescale_axes_to_fit_data(UD,UD.channels(chIdx).axesInd,[],1);                     
                end
            else
                modified = 0;
            end
        else
            modified = 0;
        end
    
    case 'dataSetCopy'      
        UD = dataSet_copy(UD,UD.current.dataSetIdx);
        UD = update_undo(UD,'add','dataSet',length(UD.dataSet),[]);
        modified = 1;

    case 'dataSetRight'
        UD = dataSet_right(UD);
        modified = 1;
    case 'dataSetLeft'
        UD = dataSet_left(UD);
        modified = 1;
    case 'dataSetNew'
    case 'dataSetDelete'
        dsIdx = UD.current.dataSetIdx;
        undoData.dataSet = UD.dataSet(dsIdx);
        for chIdx=1:length(UD.channels)
            undoData.chXData{chIdx} = UD.channels(chIdx).allXData{dsIdx};
            undoData.chYData{chIdx} = UD.channels(chIdx).allYData{dsIdx};
        end
        UD = update_undo(UD,'delete','dataSet',dsIdx,undoData);
        UD = dataSet_delete(UD);
        modified = 1;
    
    case 'dataSetRename'    
        dsIdx = UD.current.dataSetIdx;
        currLabel = UD.dataSet(dsIdx).name;
        newLabel = sigbuilder_modal_edit_dialog('Group Tab Name',{sprintf('Name: ',dsIdx)},{currLabel});
        if ischar(newLabel)
        	if isempty(newLabel)
        		errordlg('A group name cannot be empty');
        		modified = 0;
        		return;
        	end
        	
            allNames = {UD.dataSet.name};
            newname = uniqueify_str_with_number(newLabel,dsIdx,allNames{:});
            UD = dataSet_rename(UD,dsIdx,newname); 
            modified = 1;
            UD = update_undo(UD,'rename','dataSet',dsIdx,currLabel);    
        else
            modified = 0;
        end
    
    case 'verification'
        if ~UD.current.isVerificationVisible
            [UD,modified] = toolbar_handler('verifyView',UD.dialog,UD);
            set(UD.toolbar.verifyView,'state','on');
        end

    case 'help'
    otherwise
        error('Bad toolbar method');
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOOLBAR_HANDLER - Execute a callback for the toolbar.
% 
function [UD,modified] = toolbar_handler(method,dialog,UD)

    modified = 1;
    switch(method)
    case 'verifyView'

        if UD.current.isVerificationVisible
            if ~isempty(UD.verify.hg.component)
                UD.verify.hg.component.setVisible(0);
                set(UD.verify.hg.componentContainer, 'Visible', 'off')
                set(UD.verify.hg.splitter,'Visible','off');
            end
            % Hide the area   
            UD.current.axesExtent = UD.current.axesExtent + ...
                                    [0 0 1 0]*UD.current.verifyWidth;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Update the position of all axes
            for(i=1:UD.numAxes)
                pos = calc_new_axes_position(UD,i);
                set(UD.axes(i).handle,'Position',pos);
            end

            scrollPos = get(UD.tlegend.scrollbar,'Position');
            scrollPos = scrollPos + [0 0 1 0]*UD.current.verifyWidth;
            set(UD.tlegend.scrollbar,'Position', scrollPos);
            UD.current.isVerificationVisible = 0;
        else
            if isempty(UD.verify.hg.component)
                try,            
                    UD.verify.jVerifyPanel = vnv_panel_mgr('sbCreatePanel', ...
                                                        UD.simulink.subsysH);
                    UD.verify.jPanel = UD.verify.jVerifyPanel.getPane;
                catch
                    UD.verify.jPanel = [];
                end
            end            
            
            if ~isempty(UD.verify.jPanel)
            
                % Make the area visible
                UD.current.axesExtent = UD.current.axesExtent - ...
                                        [0 0 1 0]*UD.current.verifyWidth;
                UD.current.isVerificationVisible = 1;
                
                if isempty(UD.verify.hg.component)
                    pos = find_verify_position(UD);
                    axExtent = UD.current.axesExtent;
                    splitterPos = [axExtent(1)+axExtent(3), axExtent(2), 0, axExtent(4)] + ...
                                        [0.375 0 0.25 0]*UD.geomConst.figBuffer;
                                        
                    [UD.verify.hg.component, UD.verify.hg.componentContainer] = javacomponent(UD.verify.jPanel, ...
                                                            pos, UD.dialog);
                    UD.verify.hg.splitter = uicontrol(  'Parent',               UD.dialog, ...
                                                        'Units',                'Points', ...
                                                        'Position',             splitterPos, ...
                                                        'Visible',              'off', ...
                                                        'Style',                'Text', ...
                                                        'BackgroundColor',      'Black', ...
                                                        'ButtonDownFcn',  'sigbuilder(''ButtonDown'',gcbf);', ...
                                                        'ForegroundColor',      'Black');
                                                        
                else
                    pos = find_verify_position(UD);
                    set(UD.verify.hg.componentContainer, 'Position', pos);
                    set(UD.verify.hg.componentContainer, 'Visible', 'on');
                    UD.verify.hg.component.setVisible(1);
                end

                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Update the position of all axes
                for(i=1:UD.numAxes)
                    pos = calc_new_axes_position(UD,i);
                    set(UD.axes(i).handle,'Position',pos);
                end
    
                scrollPos = get(UD.tlegend.scrollbar,'Position');
                scrollPos = scrollPos - [0 0 1 0]*UD.current.verifyWidth;
                set(UD.tlegend.scrollbar,'Position', scrollPos);
                
                % Useless function to render the panel in the right place
                guiPos = get(UD.dialog,'Position');
                set(UD.dialog,'Position',guiPos + [1 1 0 0]);
                pause(0.1)
                set(UD.dialog,'Position',guiPos);
            end
        end
    
    
    case 'playAll'
        
        % The playAll method runs all the simuliation groups and
        % collects agregated coverage when the coverage tool
        % is available.  
        
        modelH = UD.simulink.modelH;
        testCnt = length(UD.dataSet);
        UD.current.simMode = 'PlayAll';
        
        % Make sure the Simulation stop time is not set to inf
        % as we cannot stop the sim from the toolbar.
        if strcmp(lower(strtok(get_param(UD.simulink.modelH,'StopTime'))),'inf')
            errordlg('You cannot run all simulations with an infinite stop time.');
        else
            if (is_cv_licensed)
                simOk = 1;
                oldWarnState = warning('query');
                warning('off','all');
                for testIdx = 1:testCnt
                    UD = dataSet_activate(UD,testIdx);
                    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);
                    set(UD.dialog,'UserData',UD);
                    test = cvtest(modelH);
                    try
                        covdata{testIdx} = cvsim(test);
                    catch
                        covdata{testIdx} = [];
                    end
                    
                    if isempty(covdata{testIdx})
                        % We had an error
                        simOk = 0;
                        errordlg(sprintf('Simulation failed: \n%s',lasterr));
                        break;
                    end
                    
                    % Check if the sim was stopped
                    UD = get(UD.dialog,'UserData');
                    if (UD.current.simWasStopped)
                        break
                    end
                end
                warning(oldWarnState);
                
                if (~UD.current.simWasStopped & simOk)
                    covTotal = covdata{1};
                    for testIdx = 2:testCnt
                        covTotal = covTotal+covdata{testIdx};
                    end
                    cvhtml('tempfile.html',covTotal);
                end
                
                % =====================================================================
                % Special hook for sltestgen testing
                try,
                    prevLastErr = lasterr;
                    exportTotal = evalin('base','performing_sltestgen_testing');
                catch
                    lasterr(prevLastErr);
                    exportTotal = 0;
                end
                
                if exportTotal
                    assignin('base','tvg_sigbuilder_total_cov',covTotal);
                end
                % =====================================================================
            else
                for testIdx = 1:testCnt
                    UD = dataSet_activate(UD,testIdx);
                    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);
                    set(UD.dialog,'UserData',UD);
                    try,
                        sim(get_param(modelH,'Name'));
                    catch
                        errordlg(sprintf('Simulation failed: \n%s',lasterr));
                        break;
                    end
                    
                    % Check if the sim was stopped
                    UD = get(UD.dialog,'UserData');
                    if (UD.current.simWasStopped)
                        break
                    end
                end
            end
            UD.current.simMode = '';
            UD.current.simWasStopped = 0;
        end

    case 'save'
        UD = save_session(UD);
    case 'newAxes'
        UD = new_axes(UD,1,[]); 

    case 'constantSig'
        if ~in_iced_state_l(UD), 
            UD = add_nonrepeat_normalized_signal(UD,[0 1],[0 0],0,1);
        end;

    case 'stepSig'
        xNorm = [0 0.5 0.5 1];
        yNorm = [0 0 1 1];
        if ~in_iced_state_l(UD), 
            UD = add_nonrepeat_normalized_signal(UD,xNorm,yNorm,0,1);
        end;

    case 'pulseSig'
        xNorm = [0 0.4 0.4 0.6 0.6 1];
        yNorm = [0 0 1 1 0 0 ];
        
        if ~in_iced_state_l(UD), 
            UD = add_nonrepeat_normalized_signal(UD,xNorm,yNorm,0,1);
        end;

    case 'intValues'
    case 'snapGrid'
        if strcmp(UD.current.gridSetting,'off')
            UD.current.gridSetting = 'on';
        else
            UD.current.gridSetting = 'off';
        end
        
        for(i=1:UD.numAxes)
            set(UD.axes(i).handle ,...
                'XGrid', UD.current.gridSetting, ...
                'YGrid', UD.current.gridSetting);
        end
        sigbuilder_tabselector('touch',UD.hgCtrls.tabselect.axesH);
        
    case 'zoomX'
        if UD.current.mode == 9
            UD = mouse_handler('ForceMode',dialog,UD,1);
        else
            UD = mouse_handler('ForceMode',dialog,UD,9);
        end
    case 'zoomY'
        if UD.current.mode == 10
            UD = mouse_handler('ForceMode',dialog,UD,1);
        else
            UD = mouse_handler('ForceMode',dialog,UD,10);
        end
    case 'zoomXY'
        if UD.current.mode == 11
            UD = mouse_handler('ForceMode',dialog,UD,1);
        else
            UD = mouse_handler('ForceMode',dialog,UD,11);
        end
    case 'fullview'
        UD = set_new_time_range(UD,[UD.common.minTime UD.common.maxTime]);
        for i=1:UD.numAxes
            UD = rescale_axes_to_fit_data(UD,i,[],1);
        end

    case 'start'
        set(UD.dialog,'Pointer','watch');
        UD = sl_command(UD,'start');
        
    case 'stop'
        UD = sl_command(UD,'stop');

    case 'pause'
        UD = sl_command(UD,'pause');

    case 'up'
        UD = sl_command(UD,'open');

    case 'simulink'
        simulink;

    case 'save'
        UD = sl_command(UD,'save');

    otherwise
        error('Bad toolbar method');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_SHOW_MENU - Update the list of hidden signals and
% their callbacks.
%
function UD = update_show_menu(UD)

    parentMenuH = UD.menus.figmenu.show;
    submenus = get(parentMenuH,'Children');
    delete(submenus);
    
    hiddenCount = 0;
    for i=1:length(UD.channels)
        if (UD.channels(i).axesInd==0)
            hiddenCount = hiddenCount + 1;
            handle = uimenu('Parent',       parentMenuH, ...
                            'Label',        UD.channels(i).label, ...
                            'Callback',     ['sigbuilder(''FigMenu'',gcbf,[],''show'',' num2str(i) ');']);
        end
    end

    if (hiddenCount==0)
        set(parentMenuH,'Enable','off');
    else
        set(parentMenuH,'Enable','on');
    end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE_TAB_SUB_MENU - Update the list of hidden signals and
% their callbacks.
%
function UD = update_tab_sub_menu(UD)

    parentMenuH = UD.menus.figmenu.tab;
    submenus = UD.menus.tabmenus;
    if ~isempty(submenus)
        delete(submenus);
    end
    
    newMenus = [];
    for i=1:length(UD.dataSet)
        handle = uimenu('Parent',       parentMenuH, ...
                        'Label',        [num2str(i) '. ' UD.dataSet(i).name], ...
                        'Callback',     ['sigbuilder(''FigMenu'',gcbf,[],''showTab'',' num2str(i) ');']);
        newMenus = [newMenus handle];
    end
    set(newMenus(1),'Separator','on');
    set(newMenus(UD.current.dataSetIdx),'Checked','on');
    UD.menus.tabmenus = newMenus;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADD_SUBMENU_NUMBER_SELECTION - Add a series of submenus
% for a numeric property.
% 
function handles = add_submenu_number_selection(parentMenu,callBackPrefix,values)

    handles = [];
    for v = values(:)',
        numberString = num2str(v);
        handle = uimenu('Parent',               parentMenu, ...
                        'Label',                numberString, ...
                        'Callback',             [callBackPrefix ',' numberString ');']);
        handles = [handles handle];
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK_MARK_MATCHING_SUBMENU - Given a series of numeric 
% submenus.  Check the one that matches the given value.
% 
function check_mark_matching_submenu(parentMenuH,value)

    menusH = get(parentMenuH,'Children');
    set(menusH,'Checked','off');

    labels = get(menusH,'Label');
    menuVals = str2num(strvcat(labels{:}));
    
    matchingMenu = menusH(menuVals==value);
    if ~isempty(matchingMenu)
        set(matchingMenu,'Checked','on');
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANNEL_HANDLER - Perform a callback from the channel
% context menu.
% 
function [UD,modified] = channel_handler(method,dialog,UD,varargin)

    % In case we are called from an API make sure the mode is correct
    chIdx = UD.current.channel;
    if chIdx==0
    	if UD.current.axes==0
	        modified = 0;
	        return;
	    else
	    	axUd = get(UD.current.axes,'UserData');
	    	if isempty(axUd) | ~isfield(axUd,'index')
		        modified = 0;
		        return;
	    	else
	    		chIdx = UD.axes(axUd.index).channels(1);
	    	end
	    end
    end

    switch(method)
    case {'sigrename','rename'}
        currLabel = UD.channels(chIdx).label;
        newLabel = sigbuilder_modal_edit_dialog('Set Label String',{sprintf('Channel %d: ',chIdx)},{currLabel});
        if ischar(newLabel)
        	if isempty(newLabel)
        		errordlg('A signal name cannot be empty');
            	modified = 0;
            	return;
            end
        		
            [UD,applyStr] = rename_channel(UD,chIdx,newLabel);
            UD = update_undo(UD,'rename','channel',chIdx,currLabel);
            modified = 1;
        else
            modified = 0;
        end

    case 'changeAxes'
        desAxes = UD.numAxes + 1 - varargin{1};
        if (desAxes==UD.channels(chIdx).axesInd)
            return;
        end
        UD = hide_channel(UD,chIdx);
        [UD,lineH] = new_plot_channel(UD,chIdx,desAxes);
        modified = 1;

    case 'setColor'
        lineH = UD.channels(chIdx).lineH;
        axIdx = UD.channels(chIdx).axesInd;
        C = uisetcolor(lineH, sprintf('Set Channel %d (%s) Color',chIdx,UD.channels(chIdx).label));
        if length(C)>1
            UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(lineH,'Color',C);
            UD.channels(chIdx).color = C;
            if axIdx>0
            	set(UD.axes(axIdx).labelH,'Color',C);
            end
            modified = 1;    
        else
            modified = 0;    
        end

    case 'setWidth'
        wdth = UD.channels(chIdx).lineWidth;
        title = sprintf('Set channel %d (%s) line width',chIdx,UD.channels(chIdx).label);      
        wdthStr = sigbuilder_modal_edit_dialog(title,'Width: ',num2str(wdth));
        if ~ischar(wdthStr) % Cancel button
            modified = 0;
            return;
        end
        wdth = eval_to_real_scalar(wdthStr,'width');
        if isempty(wdth)
        	modified = 0;
        	return;
        end
        
        % Check for valid range
        if wdth<=0
            errordlg('The width value should be a real number greater than 0.');
            modified = 0;
            return;
        end
        UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
 
       UD.channels(chIdx).lineWidth = wdth;
        set(UD.channels(chIdx).lineH,'LineWidth',wdth);
        modified = 1;
        
    case 'setLineStyle'
        modified = 1;
        switch(varargin{1})
        case 'solid',
            UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle','-');
            UD.channels(chIdx).lineStyle= '-';
            
        case 'dashed',
            UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle','--');
            UD.channels(chIdx).lineStyle= '--';
            
        case 'dotted',
            UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle',':');
            UD.channels(chIdx).lineStyle= ':';
            
        case 'dash-dott',
            UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
            set(UD.channels(chIdx).lineH,'LineStyle','-.');
            UD.channels(chIdx).lineStyle= '-.';

        otherwise
            modified = 0;
        end
           
             
    case 'yminmax'    
        y = UD.channels(chIdx).yData;
        labels = {'Minimum Y Value: ', 'Maximum Y Value: '};
        startVals = {num2str(UD.channels(chIdx).yMin), num2str(UD.channels(chIdx).yMin)};  
        title = sprintf('Set Channel %d (%s) Y Limits',chIdx,UD.channels(chIdx).label);      
        vals = sigbuilder_modal_edit_dialog(title,labels,startVals);
        if ~iscell(vals)
            modified = 0;
            return;
        end


        minY = eval_to_real_scalar(vals{1},'minimum');
        maxY = eval_to_real_scalar(vals{2},'maximum');
		if isempty(minY) | isempty(maxY)
            modified = 0;
            return;
		end
		if maxY <= minY
			errordlg('Minimum value must be less than maximum.');
            modified = 0;
            return;
		end

        UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
        onesY = ones(1,length(y));
        y(y>maxY) = maxY*onesY(y>maxY);
        y(y<minY) = minY*onesY(y<minY);
        UD = apply_new_channel_data(UD,chIdx,[],y);
        UD.channels(chIdx).yMin = minY;
        UD.channels(chIdx).yMax = maxY;
        modified = 1;    

    case 'cut' 
    	if length(UD.channels)==1
    		warndlg('Can not delete the last channel');
    		modified = 0;
    		return;
    	end    
    		
        UD.clipboard.type = 'channel';
        UD.clipboard.content = UD.channels(chIdx);
        UD.clipboard.content.lineH = [];
        UD.clipboard.content.axesInd = [];
        UD = enable_channel_paste(UD);
        UD.adjust.XDisp = [];
        UD.adjust.YDisp = [];
        UD = update_undo(UD,'delete','channel',chIdx,UD.channels(chIdx));
        UD = remove_channel(UD,chIdx);
        UD = update_show_menu(UD);
        UD.current.channel = 0;
        UD = mouse_handler('ForceMode',dialog,UD,1);
        UD = set_dirty_flag(UD);
        modified = 1;    
 
         
    case 'copy'         
        UD.clipboard.type = 'channel';
        UD.clipboard.content = UD.channels(chIdx);
        UD.clipboard.content.lineH = [];
        UD.clipboard.content.axesInd = [];
        UD = enable_channel_paste(UD);
        modified = 1;    

        
    case 'complement'
        y = UD.channels(chIdx).yData;
        [amp,off] = get_amplitude_offset(y);
        ynew = -1*y + (2*off);
        UD = apply_new_channel_data(UD,chIdx,[],ynew);
        modified = 1;    

    case 'paste'
        % Pasting a channel should only copy the 
        % X-Y data for this page.      
    	UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
        lineH = UD.channels(chIdx).lineH;
        chStruct = UD.clipboard.content;
        axIdx = UD.channels(chIdx).axesInd;
        UD.channels(chIdx).xData = chStruct.xData;
        UD.channels(chIdx).yData = chStruct.yData;
        
        set(lineH,  'XData',        chStruct.xData, ...
                    'YData',        chStruct.yData ...
                    );

		if axIdx>0
			UD = rescale_axes_to_fit_data(UD,axIdx,[],1);
		end
        modified = 1;

            
    case 'delete'
    	if length(UD.channels)==1
    		warndlg('Can not delete the only signal');
    		modified = 0;
    		return;
    	end    
    		
        UD.adjust.XDisp = [];
        UD.adjust.YDisp = [];
        UD = update_undo(UD,'delete','channel',chIdx,UD.channels(chIdx));
        UD = remove_channel(UD,chIdx);
        UD.current.channel = 0;
        UD = mouse_handler('ForceMode',dialog,UD,1);
        UD = set_dirty_flag(UD);
        UD = update_show_menu(UD);
        modified = 1;    
               
	case 'sighide'
    	dsIdx = UD.current.dataSetIdx;
    	axesIdx = UD.channels(chIdx).axesInd;
		UD = hide_channel(UD,chIdx);		
        UD = remove_axes(UD,axesIdx);
        UD.dataSet(dsIdx).activeDispIdx(axesIdx) = [];
        UD.current.channel = 0;
        UD = update_channel_select(UD);
        UD = update_show_menu(UD);
        modified = 1; 
            
    case 'setStepX'
    	if chIdx==0
			axesUD = get(UD.current.axes,'UserData');
		    if isempty(axesUD)
        		modified = 0;    
		    	return;
		    end
   			axesInd = axesUD.index; 
   			chIdx = UD.axes(axesInd).channels(1);   		
    	end
        UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
        UD.channels(chIdx).stepX = varargin{1};
        UD = update_channel_select(UD);
        UD = set_dirty_flag(UD); 
        modified = 1;    
    case 'setStepY'     
    	if chIdx==0
			axesUD = get(UD.current.axes,'UserData');
		    if isempty(axesUD)
        		modified = 0;    
		    	return;
		    end
   			axesInd = axesUD.index; 
   			chIdx = UD.axes(axesInd).channels(1);   		
    	end
        UD = update_undo(UD,'edit','channel',chIdx,UD.channels(chIdx));
        UD.channels(chIdx).stepY = varargin{1};
        UD = update_channel_select(UD);
        UD = set_dirty_flag(UD);
        modified = 1;     
    otherwise,
        error('Unkown Method');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANNEL_UI_HANDLER - Perform a callback from a channel
% uicontrol object.
% 
function [UD,modified] = channel_ui_handler(method,dialog,UD,varargin)
    chIdx = UD.current.channel;
    if chIdx>0
        axIdx = UD.channels(chIdx).axesInd;
    end

    switch(method)
    case 'label'
        newStr = get(UD.hgCtrls.chDispProp.labelEdit,'String');
        oldStr = UD.channels(chIdx).label;
        [UD,applyStr] = rename_channel(UD,chIdx,newStr);
        UD = update_undo(UD,'rename','channel',chIdx,oldStr);
        modified = 1;

    case 'index'
        newInd = get(UD.hgCtrls.chDispProp.indexPopup,'Value');
        chIdx = UD.current.channel;
        if (chIdx  == newInd)
            modified = 0;
            return;
        end
        UD = update_undo(UD,'move','channel',newInd,chIdx);
        UD = change_channel_index(UD,newInd,chIdx);
        oldInd = UD.channels(chIdx).outIndex;
        modified = 1;
        UD = set_dirty_flag(UD);

    case 'leftX'
        Ipts = UD.current.editPoints;
        if(Ipts(1)==1 | Ipts(1)==length(UD.channels(chIdx).xData))
            % Can't edit x position of end points
            modified = 0;
            return;
        end
        str = get(UD.hgCtrls.chLeftPoint.xNumDisp,'String');
        newVal = str2num(str);
        if isempty(newVal) | length(newVal)>1
            modified = 0;
            return;
        end
        P = snap_point(UD,[newVal 0],UD.channels(chIdx),Ipts(1),1);
        if length(Ipts==2) & diff(UD.channels(chIdx).xData(Ipts))==0
            if (newVal>UD.channels(chIdx).xData(Ipts(1)))
                P = snap_point(UD,[newVal 0],UD.channels(chIdx),Ipts(2),1);
            end
            UD.channels(chIdx).xData(Ipts) = [1 1]*P(1);
        else
            UD.channels(chIdx).xData(Ipts(1)) = P(1);
        end

        set(UD.channels(chIdx).lineH,'XData',UD.channels(chIdx).xData);
        UD = set_dirty_flag(UD);
        UD = update_selection_display_line(UD, ...
                UD.channels(chIdx).xData(Ipts), ...
                UD.channels(chIdx).yData(Ipts));
        newStr = num2str(newVal,'%.5e');
        set(UD.hgCtrls.chLeftPoint.xNumDisp,'String',newStr);
        modified = 1;

    case 'leftY'   
        Ipts = UD.current.editPoints;
        str = get(UD.hgCtrls.chLeftPoint.yNumDisp,'String');
        newVal = str2num(str);
        if isempty(newVal) | length(newVal)>1
            modified = 0;
            return;
        end
        P = snap_point(UD,[0 newVal],UD.channels(chIdx),Ipts(1),1);
        if length(Ipts==2) & diff(UD.channels(chIdx).yData(Ipts))==0
            UD.channels(chIdx).yData(Ipts) = [1 1]*P(2);
        else
            UD.channels(chIdx).yData(Ipts(1)) = P(2);
        end

        set(UD.channels(chIdx).lineH,'YData',UD.channels(chIdx).yData);
        UD = rescale_axes_to_fit_data(UD,axIdx,chIdx);
        UD = set_dirty_flag(UD);
        UD = update_selection_display_line(UD, ...
                UD.channels(chIdx).xData(Ipts), ...
                UD.channels(chIdx).yData(Ipts));
        newStr = num2str(newVal,'%.5e');
        set(UD.hgCtrls.chLeftPoint.yNumDisp,'String',newStr);
        modified = 1;

    case 'rightX'   
        Ipts = UD.current.editPoints;
        str = get(UD.hgCtrls.chRightPoint.xNumDisp,'String');
        newVal = str2num(str);
        if length(Ipts)<2 | isempty(newVal) | length(newVal)>1 |...
            Ipts(2)==length(UD.channels(chIdx).xData)
            modified = 0;
            return;
        end

        P = snap_point(UD,[newVal 0],UD.channels(chIdx),Ipts(2),1);
        UD.channels(chIdx).xData(Ipts(2)) = P(1);
        set(UD.channels(chIdx).lineH,'XData',UD.channels(chIdx).xData);
        UD = set_dirty_flag(UD);
        UD = update_selection_display_line(UD, ...
                UD.channels(chIdx).xData(Ipts), ...
                UD.channels(chIdx).yData(Ipts));
        newStr = num2str(newVal,'%.5e');
        set(UD.hgCtrls.chRightPoint.xNumDisp,'String',newStr);
        modified = 1;

    case 'rightY'   
        Ipts = UD.current.editPoints;
        str = get(UD.hgCtrls.chRightPoint.yNumDisp,'String');
        newVal = str2num(str);
        if length(Ipts)<2 | isempty(newVal) | length(newVal)>1
            modified = 0;
            return;
        end
        P = snap_point(UD,[0 newVal],UD.channels(chIdx),Ipts(2),1);
        UD.channels(chIdx).yData(Ipts(2)) = P(2);

        set(UD.channels(chIdx).lineH,'YData',UD.channels(chIdx).yData);
        UD = rescale_axes_to_fit_data(UD,axIdx,chIdx);
        UD = set_dirty_flag(UD);
        UD = update_selection_display_line(UD, ...
                UD.channels(chIdx).xData(Ipts), ...
                UD.channels(chIdx).yData(Ipts));
        newStr = num2str(newVal,'%.5e');
        set(UD.hgCtrls.chRightPoint.yNumDisp,'String',newStr);
        modified = 1;

    otherwise,
        error('Unkown Method');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHAN_LISTBOX_MGR - Perform a callback for channel list box
% adjustment controls.
% 
function UD = chan_listbox_mgr(UD),

    chanIdx = get(UD.hgCtrls.chanListbox,'Value');
    dsIdx = UD.current.dataSetIdx;
    
    if chanIdx>length(UD.channels)	% Click outside range
    	return;
    end
    
	if isempty(UD.dataSet(dsIdx).activeDispIdx)
		axesIdx = [];
	else
    	axesIdx = find(UD.dataSet(dsIdx).activeDispIdx==chanIdx);
    end
    
    switch(get(UD.dialog,'SelectionType'))
    case {'normal','extend','alt'}
        % Make this signal selected
        if ~isempty(axesIdx)
            UD.current.channel = chanIdx;
            UD = mouse_handler('ForceMode',[],UD,3);
        else
            UD.current.channel = 0;
            UD = mouse_handler('ForceMode',[],UD,1);
        end

    case 'open'
        % Toggle the visibility of this signal 
        if isempty(axesIdx)
            if is_space_for_new_axes(UD)
                newAxesIdx = sum(UD.dataSet(dsIdx).activeDispIdx>chanIdx)+1;
                UD = new_axes(UD,newAxesIdx,[]);
                [UD,lineH] = new_plot_channel(UD,chanIdx,newAxesIdx);
            else
                msgTxt = sprintf(['Insufficient drawing space.  ' ... 
                               'Resize the window or hide other signals before ' ...
                               'attempting to display this signal']);
                msgbox(msgTxt,'Out of Space');
            end
        else
            UD = hide_channel(UD,chanIdx);   
            UD = remove_axes(UD,axesIdx);
            UD.dataSet(dsIdx).activeDispIdx(axesIdx) = [];
            if (UD.current.channel~=0)
                UD.current.channel = 0;
                UD = mouse_handler('ForceMode',[],UD,1);
            end
        end
        UD = update_show_menu(UD);
    end
    
    UD = update_channel_select(UD);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIME_UI_HANDLER - Perform a callback from the time 
% adjustment controls.
% 
function [UD,modified] = time_ui_handler(method,dialog,UD,varargin)

    modified = 1;
    
    switch(method)
    case 'scroll'  
        % Update the edit field text   
        x = get(UD.hgCtrls.timeAdjCtrls.scroll,'Value');
        sliderMin = get(UD.hgCtrls.timeAdjCtrls.scroll,'Min');
        sliderMax = get(UD.hgCtrls.timeAdjCtrls.scroll,'Max');
        if isequal([sliderMin,sliderMax],[0.1 100])
           set(UD.hgCtrls.timeAdjCtrls.edit,'String',num2str(x));
        else
            dispNum = x * diff(UD.common.timeVect(UD.current.timeEditIdx));
            decade = floor(log10(diff(UD.common.timeVect(UD.current.timeEditIdx))));
            if decade<-7,
                mult = -9;
            elseif decade > 4
                mult = 6;
            else
                mult = 3*floor((decade+1)/3);
            end
            dispNum = dispNum/(10^mult);          
            set(UD.hgCtrls.timeAdjCtrls.edit,'String',num2str(dispNum));
        end
        


    case 'apply'
        Ind = UD.current.timeAdjIdx;
        chNum = UD.current.channel;
       
        % Apply based on the edit field and scale selection
        numStr = get(UD.hgCtrls.timeAdjCtrls.edit,'String');
        scaleVal = -12 + 3*(get(UD.hgCtrls.timeAdjCtrls.scalePopup,'Value'));
        timeDelta = str2num(numStr)*10^scaleVal;
        
        if (get(UD.hgCtrls.timeAdjCtrls.direction,'Value')==0)
            newTime = UD.common.timeVect(UD.current.timeEditIdx(1)) + timeDelta;
        else
            newTime = UD.common.timeVect(UD.current.timeEditIdx(2)) - timeDelta;
        end
        
        UD = toggle_display_mode(UD);
        X = UD.channels(chNum).xData;
        X(Ind) = newTime;
        UD = apply_new_channel_data(UD,chNum,X,[]);
        UD = toggle_display_mode(UD);
        UD = hide_time_adjust_displays(UD);
    case 'scale'   
        % The scale must be set to a value the same order as the maximum
        % delta.  When selecting a finer time scale the slider range changes
        % to 0.1 to 100.
        scaleVal = -12 + 3*(get(UD.hgCtrls.timeAdjCtrls.scalePopup,'Value'));
        
        if scaleVal>UD.hgCtrls.timeAdjCtrls.mult,
            resetVal = UD.hgCtrls.timeAdjCtrls.mult/3 + 4;
            set(UD.hgCtrls.timeAdjCtrls.scalePopup,'Value',resetVal);
        elseif scaleVal<UD.hgCtrls.timeAdjCtrls.mult,
            sliderMin = get(UD.hgCtrls.timeAdjCtrls.scroll,'Min');
            sliderMax = get(UD.hgCtrls.timeAdjCtrls.scroll,'Max');
            if isequal([sliderMin,sliderMax],[0.1 100])
                return;
            else
                numStr = get(UD.hgCtrls.timeAdjCtrls.edit,'String');
                set(UD.hgCtrls.timeAdjCtrls.scroll,'Min',0.1,'Max',100.0);
                x = str2num(numStr);
                if x<0.1,
                    x=0.1;
                else
                    if x>100
                        x = 100;
                    end
                end
                set(UD.hgCtrls.timeAdjCtrls.scroll,'Value',x);
            end
        else
            % Check that the number value is in the allowed range
            maxVal = diff(UD.common.timeVect(UD.current.timeEditIdx));
            numStr = get(UD.hgCtrls.timeAdjCtrls.edit,'String');
            x = str2num(numStr)* 10^(UD.hgCtrls.timeAdjCtrls.mult);
            if x > maxVal
                dispNum = maxVal/ 10^(-12 + 3*UD.hgCtrls.timeAdjCtrls.mult);
                set(UD.hgCtrls.timeAdjCtrls.scroll,'Value',1);
                set(UD.hgCtrls.timeAdjCtrls.edit,'String',num2str(dispNum));
            else
                set(UD.hgCtrls.timeAdjCtrls.scroll,'Value',x/maxVal);
            end
            set(UD.hgCtrls.timeAdjCtrls.scroll,'Min',0,'Max',1);
        end
    
    case 'direction'   
        % Change the time display to equivalent in oposite direction
    end


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AXES_CONTEXT_HANDLER - Perform a callback from the axes
% context menu.
% 
function [UD,modified] = axes_context_handler(method,dialog,UD,varargin)
    axesUD = get(UD.current.axes,'UserData');
    
    if isempty(axesUD)
    	return;
    end
    axesInd = axesUD.index;
    modified = 1;

    switch(method)
    case 'cut'   
    case 'copy'  
    case 'delete'
        channels = UD.axes(axesInd).channels;
        channels = fliplr(sort(channels));
        for chIdx = channels(:)'
            UD = remove_channel(UD,chIdx);
        end
        UD = remove_axes(UD,axesInd);
        UD.current.axes = UD.axes(1).handle;
        update_gca_display(UD);

    case 'tdisprange'
        title = 'Set time range ';
        labels = {'Minimum: ', 'Maximum: '};
        strtVals = {num2str(UD.common.dispTime(1)), num2str(UD.common.dispTime(2))};      
        vals = sigbuilder_modal_edit_dialog(title,labels,strtVals);
        if ~iscell(vals)
            modified = 0;
            return;
        end
        minT = eval_to_real_scalar(vals{1},'minimum');
        maxT = eval_to_real_scalar(vals{2},'maximum');
		if isempty(minT) | isempty(maxT)
            modified = 0;
            return;
		end
		if maxT <= minT
			errordlg('Minimum value must be less than maximum.');
            modified = 0;
            return;
		end

        newRange = [minT  maxT];
		UD = set_new_time_range(UD,newRange,0);
        modified = 1;
                      

    case 'setYrange'
        yLims = get(UD.axes(axesInd).handle,'YLim');
        dispNum = UD.numAxes + 1 - axesInd;
        title = sprintf('Set y range for axes %d ',dispNum);
        labels = {'Minimum: ', 'Maximum: '};
        strtVals = {num2str(yLims(1)), num2str(yLims(2))};      
        vals = sigbuilder_modal_edit_dialog(title,labels,strtVals);
        if ~iscell(vals)
            modified = 0;
            return;
        end
        minY = eval_to_real_scalar(vals{1},'minimum');
        maxY = eval_to_real_scalar(vals{2},'maximum');
		if isempty(minY) | isempty(maxY)
            modified = 0;
            return;
		end
		if maxY <= minY
			errordlg('Minimum value must be less than maximum.');
            modified = 0;
            return;
		end

        newYlim = [minY  maxY];
        set(UD.axes(axesInd).handle,'YLim',newYlim);
        UD.axes(axesInd).yLim = newYlim;  
        update_axes_label(UD,axesInd);
        modified = 1;
                      
    case 'setAmplitude'
        UD = apply_axes_prop(UD,axesInd,varargin{1},[]);
    case 'setOffset'
        UD = apply_axes_prop(UD,axesInd,[],varargin{1});
    otherwise,
        error('Unkown Method');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% APPLY_AXES_PROP - 
% 
function UD = apply_axes_prop(UD,axesIndex,ampl,offset),

    yLim = get(UD.axes(axesIndex).handle,'YLim');
    currAmpl = diff(ylim)/2;
    currOffset = sum(yLim)/2;

    if isempty(ampl)
        ampl = currAmpl;
    end

    if isempty(offset)
        offset = currOffset;
    end

    newYlim = ampl*[-1 1] + offset;
    set(UD.axes(axesIndex).handle,'YLim',newYlim);
    UD.axes(axesIndex).yLim = newYlim;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENABLE_CHANNEL_PASTE - 
% 
function UD = enable_channel_paste(UD),

    objs = [UD.menus.channelContext.paste ...
            UD.menus.figmenu.paste UD.toolbar.paste];
    set(objs,'Enable','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IS_CHANNEL_BOOL - Test if channel is boolean valued
% 
function val = is_channel_bool(UD,chIdx),
    chStruct = UD.channels(chIdx);
    val = (chStruct.stepY==1 & ~isempty(chStruct.yMin) & ~isempty(chStruct.yMax));
    if val,
        val = (chStruct.yMin==0 & chStruct.yMax==1);
    end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       SAVING AND LOADING FUNCTIONS                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SAVING_AND_LOADING_FUNCTIONS   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLOSE_INTERNAL - Execute a close callback
% 
function close_internal(UD)

    % If a simulation is running we can not capture the 
    % contents to the workspace block so we leave the figure in
    % memory and make it invisible
	if is_simulating_l(UD)
		set(UD.dialog,'Visible','off');
        return;
    end

    if UD.common.dirtyFlag == 1,
        UD = save_session(UD);
    end

    if ~isempty(UD.simulink)
        sigbuilder_block('figClose',UD.simulink);
    end

    if vnv_enabled && isfield(UD,'verify') && isfield(UD.verify,'jVerifyPanel') && ...
        ~isempty(UD.verify.jVerifyPanel)
            vnv_panel_mgr('sbClosePanel',UD.simulink.subsysH,UD.verify.jVerifyPanel);
    end
    
    delete(UD.dialog);
 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_SAVE_STRUCT - Create a structure with the editor
% context.
% 
function [UD,saveStruct] = create_save_struct(UD)

    UD = dataSet_store(UD);
    saveStruct.gridSetting = UD.current.gridSetting;
    saveStruct.channels = rmfield(UD.channels,{'lineH','leftDisp','rightDisp','axesInd'});
    saveStruct.axes = rmfield(UD.axes,{'handle','numChannels','lineLabels','vertProportion'});
    saveStruct.common = rmfield(UD.common,'dirtyFlag');
    saveStruct.dataSet = UD.dataSet;
    saveStruct.dataSetIdx = UD.current.dataSetIdx;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK_SAVE_STRUCT - Check the integrity of the saved data
% before opening it .
% 
function isok = check_save_struct(saveStruct)

    isok = 0;
    if ~isfield(saveStruct,'gridSetting'), return; end
    if ~isfield(saveStruct,'channels'), return; end
    if ~isfield(saveStruct,'axes'), return; end
    if ~isfield(saveStruct,'common'), return; end
    if ~isfield(saveStruct,'dataSet'), return; end

    isok = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTORE_FROM_SAVESTRUCT - Restore the enitor context
% from a saved context.
% 
function UD = restore_from_saveStruct(UD, saveStruct)

    % Delete all the existing axes and channels
    UD = quick_delete_all_channels_axes(UD);

    % Add the new channels
    for i=1:length(saveStruct.channels)
        ch = saveStruct.channels(i);
        UD = new_channel(UD.dialog,UD,ch.xData,ch.yData,ch.stepX,ch.stepY,ch.label,ch.outIndex);
        UD.channels(i).color = ch.color;
        UD.channels(i).lineStyle = ch.lineStyle;
        UD.channels(i).lineWidth = ch.lineWidth;
        UD.channels(i).allXData = ch.allXData;
        UD.channels(i).allYData = ch.allYData;
    end
    % Duplicate the plotting context
    UD.common = saveStruct.common;
    UD.common.dirtyFlag = 0;
    UD.dataSet = saveStruct.dataSet;
    UD.current.gridSetting = saveStruct.gridSetting;
    UD.current.dataSetIdx = saveStruct.dataSetIdx;
    
    switch(UD.current.gridSetting)
    case 'on'
        set(UD.toolbar.snapGrid,'state','on');
    case 'off'
        set(UD.toolbar.snapGrid,'state','off');
    end
    
    % Restore the data set tabs
    for i=1:length(UD.dataSet)
        sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,UD.dataSet(i).name);
    end
    sigbuilder_tabselector('removeentry',UD.hgCtrls.tabselect.axesH,1);
    UD = update_tab_sub_menu(UD);

    % Activate the saved tab 
    dsIdx = UD.current.dataSetIdx;
    UD.current.dataSetIdx = -1;
    UD = dataSet_activate(UD,dsIdx,1);
    sigbuilder_tabselector('activate',UD.hgCtrls.tabselect.axesH,UD.current.dataSetIdx,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE_SESSION
% 
function UD = save_session(UD)

    UD = save_to_location(UD);
    UD = reset_dirty_flag(UD);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE_TO_LOCATION
% 
function UD = save_to_location(UD);


    if ~isempty(UD.simulink) & ~isempty(UD.simulink.fromWsH) & ishandle(UD.simulink.fromWsH)
        [UD,saveStruct] = create_save_struct(UD);
        set_param(UD.simulink.fromWsH,'SigBuilderData',saveStruct);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD_SESSION
% 
function UD = load_session(UD,blockH)

	fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');

    saveStruct = get_param(fromWsH,'SigBuilderData');
    
    % Check the integrity
    if  ~check_save_struct(saveStruct)
        errordlg('Block data could not be decoded.');
        return;
    end

    UD = restore_from_saveStruct(UD, saveStruct);
    dsIdx = UD.current.dataSetIdx;
    if isempty(UD.dataSet(dsIdx).activeDispIdx)
        UD.current.channel  = 0;
    else
        UD.current.channel  = UD.dataSet(dsIdx).activeDispIdx(end);
    end
    UD = update_channel_select(UD);
    UD = update_show_menu(UD);
    
    if in_a_library(blockH)
        set(UD.toolbar.verifyView,'Enable','off');
        set(UD.menus.figmenu.verification,'Enable','off');
    end
        
    UD = reset_dirty_flag(UD);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INIT_TU_VAR - Encapsulate data for a FromWorkspace block
% 
function tu = init_tu_var(blockH)

	fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');
    UD = get_param(fromWsH,'SigBuilderData');
    tu = create_sl_input_variable(UD,fromWsH);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPORT_TO_SIMULINK - Create the model and data in Simulink
% 
function UD = export_to_simulink(UD,blckpath,blckpos)

    % Make sure the session is saved 
    if UD.common.dirtyFlag == 1,
        UD = save_session(UD);
    end

    % Create a simulink model with the required block
    for i=1:UD.numChannels
        allNames{i} = UD.channels(i).label;
    end
    
    if nargin<2
        UD.simulink = sigbuilder_block('create',UD.dialog,allNames);
    elseif nargin<3
        UD.simulink = sigbuilder_block('create',UD.dialog,allNames,blckpath);
    else
        UD.simulink = sigbuilder_block('create',UD.dialog,allNames,blckpath,blckpos);
    end    

    UD = save_to_location(UD);   % Update the block tag string

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_SL_INPUT_VARIABLE - Generate the Simulink readable
% variable which captures the input behavior
% 
function tuvar = create_sl_input_variable(UD,fromWsH)

    for i=1:length(UD.channels)
        [xVars{i},yVars{i}] = remove_duplicate_points(UD.channels(i).xData,UD.channels(i).yData);
    end

    [T,U] = generate_TU_pair(xVars{:},yVars{:});
    tuvar = [T U];  
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET_SIMULINK_SIMOPTS - Apply settings for the output
% after the final time and the sample time to the 
% 
function UD = set_simulink_simopts(UD)

    if isfield(UD.simulink,'fromWsH')
        fromWsH = UD.simulink.fromWsH;
    else
        fromWsH = [];
    end
    
    
    % Set block simulation parameters
    if ~isempty(fromWsH) & ishandle(fromWsH)
        if ~isfield(UD.common,'afterFinalStr') | isempty(UD.common.afterFinalStr)
            UD.common.afterFinalStr = 'Hold final value';
        end
        if ~isfield(UD.common,'sampleTime') | isempty(UD.common.sampleTime)
            UD.common.sampleTime = 0;
        end
    
        switch(UD.common.afterFinalStr),
        case 'Hold final value'
            set_param(fromWsH,'OutputAfterFinalValue', 'HoldingFinalValue')
        case 'Set to zero'
            set_param(fromWsH,'OutputAfterFinalValue', 'SettingToZero')
        case 'Extrapolate'
            set_param(fromWsH,'OutputAfterFinalValue', 'Extrapolation')
        end      
        set_param(fromWsH, 'SampleTime',num2str(UD.common.sampleTime));
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET_DIRTY_FLAG - Make sure a * is on the title bar.
% 
function UD = set_dirty_flag(UD)

    if UD.common.dirtyFlag==1
        return;
    end

    UD.common.dirtyFlag = 1;
    titleStr = get(UD.dialog,'Name');
    if ~strcmp(titleStr((end-1):end),' *')
    	set(UD.dialog,'Name',[titleStr ' *']);
    end
    
    if ~isempty(UD.simulink)
    	set_param(UD.simulink.modelH,'dirty','on');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESET_DIRTY_FLAG - Remove * from the title bar
% 
function UD = reset_dirty_flag(UD)

    UD.common.dirtyFlag = 0;
    titleStr = get(UD.dialog,'Name');
    if strcmp(titleStr((end-1):end),' *')
    	set(UD.dialog,'Name',titleStr(1:(end-2)));
    end


function update_titleStr(UD)

    oldTitleStr = get(UD.dialog,'Name');
	blockPath = getfullname(UD.simulink.subsysH);
	
    if strcmp(oldTitleStr((end-1):end),' *') | UD.common.dirtyFlag == 1
		titleStr = ['Signal Builder (' blockPath ') *'];
	else
		titleStr = ['Signal Builder (' blockPath ')'];
	end
	set(UD.dialog,'Name',titleStr);


function UD = sl_command(UD,method)

    if isempty(UD.simulink)
        return;
    end
    
    modelH = UD.simulink.modelH;
    blockH = UD.simulink.subsysH;

    % Starting and stopping the simulation can change the interal state of
    % the sigbuilder. Store the state before calling the sl command and
    % then pick up any change by getting it again.
    set(UD.dialog, 'userdata', UD);
    
    switch(method)
    case 'start'
	    switch get_param(modelH, 'simulationStatus')
		case {'stopped','terminating'}, 
		    set_param(modelH,'SimulationCommand','Start');
		case 'paused', 
		    set_param(modelH, 'SimulationCommand','continue');
	        set(UD.toolbar.start,'Enable','off');
		otherwise, 
            return;
		end
	    
    case 'stop'
	    switch get_param(modelH, 'simulationStatus')
		case {'stopped','terminating'}, 
		    % do nothing
		otherwise, 
		    set_param(modelH, 'SimulationCommand','Stop');
		end

    case 'pause'
	    if ~strcmp(get_param(modelH, 'SimulationStatus'),'running'), return; end;
	    set_param(modelH, 'SimulationCommand','pause');
	    set(UD.toolbar.start,'Enable','on'); % Enable the play button
	    
    case 'save'
        save_system(modelH)
        
    case 'open'
        parent = get_param(blockH,'Parent');
        open_system(parent,'force');
        set_param(blockH,'Selected','On');

    otherwise,
        error('Unkown method');
    end
    
    % Starting and stopping the simulation can change the interal state of
    % the sigbuilder.
    UD= get(UD.dialog, 'userdata');   
    
    
    
function [fileName,pathName] = uigetmdlfile

    [fileName, pathName] = uigetfile('*.mdl','Open');
    
    if fileName,
        [path,fileName,ext] = fileparts(fileName);
        
        
        if(~strcmp(ext,'.mdl'))
           errordlg(sprintf('Cannot open a model without .mdl extension: %s%s',fileName,ext),'Simulink');
           fileName = '';
        end
        
    else
        fileName = '';
        pathName = '';
    end;


function [fileName,pathName] = uiputmdlfile

    [fileName, pathName] = uiputfile('*.mdl','Save model as');
    
    if fileName,
        [path,fileName,ext] = fileparts(fileName);
    else
        fileName = '';
        pathName = '';
    end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%       Special functions for Assertion Interface       %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = assert_api(method, blockH, varargin)

    % If the figure is open, use that for the API
    dialogH = get_param(blockH,'UserData');
    if ~isempty(dialogH) & ishandle(dialogH)
        UD = get(dialogH,'UserData');
        savedUD = [];
    else
        UD = [];
	    fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all', ...
	                                'BlockType','FromWorkspace');
        savedUD = get_param(fromWsH,'SigBuilderData');
    end
    
    switch(method)
    case 'groupIndex'
        if ~isempty(UD)
            varargout{1} = UD.current.dataSetIdx;
            varargout{2} = length(UD.dataSet);
        else
            varargout{1} = savedUD.dataSetIdx;
            varargout{2} = length(savedUD.dataSet);
        end
        
    otherwise
        error(['Unrecognized Assert API method: ' method]);
    end


function UD = create_verify_data(UD)

    verify.cachedSL.allAsserts = [];
    verify.cachedSL.linkedAsserts = [];
    verify.hg.component = [];
    UD.verify = verify;

function pos = find_verify_position(UD)

    if UD.current.isVerificationVisible
        mult = [1 0 1 0;0 1 0 0;0 0 0 0;0 0 0 1];
        pos = (mult*UD.current.axesExtent(:))' + [1 1 0 1]*UD.geomConst.figBuffer + ...
              [0 0 1 0]*UD.current.verifyWidth;
        points2pixels = 1 ./ pixels2points(UD,[1 1]);
        pos = pos .* [points2pixels points2pixels];
    else
        pos = [];
    end


function UD = adjust_verify_width(UD,delta)
    if ~UD.current.isVerificationVisible
        return;
    end
    
    % If the splitter is too far to the right
    % just hide the verification settings
    if(delta<0 && (UD.current.verifyWidth + delta)<20)
        [UD,modified] = toolbar_handler('verifyView',UD.dialog,UD);
        set(UD.toolbar.verifyView,'state','off');
        return;
    end
    
    UD.current.axesExtent = UD.current.axesExtent - ...
                            [0 0 1 0]*delta;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update the position of all axes
    for(i=1:UD.numAxes)
        pos = calc_new_axes_position(UD,i);
        set(UD.axes(i).handle,'Position',pos);
    end

    if strcmp(get(UD.tlegend.scrollbar,'Visible'),'on')
        scrollPos = get(UD.tlegend.scrollbar,'Position');
        scrollPos = scrollPos - [0 0 1 0]*delta;
        set(UD.tlegend.scrollbar,'Position', scrollPos);
    end
    
    UD.current.verifyWidth = UD.current.verifyWidth + delta;
    verifyPos = find_verify_position(UD);
    set(UD.verify.hg.componentContainer,'Position',verifyPos)

    axExtent = UD.current.axesExtent;
    splitterPos = [axExtent(1)+axExtent(3), axExtent(2), 0, axExtent(4)] + ...
                        [0.375 0 0.25 0]*UD.geomConst.figBuffer;
    set(UD.verify.hg.splitter,'Position', splitterPos);                                   
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%            Command line API Functions                 %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cmdApi(method,varargin)
    switch(method)
    case 'counts'
        % Return the channel and group counts
        blockH = varargin{1};
	    figH = get_param(blockH,'UserData');
	    if ~isempty(figH) && ishandle(figH)
	        UD = get(figH,'UserData');
	        chanCnt = length(UD.channels);
	        groupCnt = length(UD.dataSet);
        else
    	    fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all', ...
    	                                'BlockType','FromWorkspace');
            savedUD = get_param(fromWsH,'SigBuilderData');
	        chanCnt = length(savedUD.channels);
	        groupCnt = length(savedUD.dataSet);
        end
        varargout{1} = chanCnt;
        varargout{2} = groupCnt;
        
    
    case 'savedData'
        % If the block is open we should generate the saved data structure
        blockH = varargin{1};
	    figH = get_param(blockH,'UserData');
	    if ~isempty(figH) && ishandle(figH)
	        UD = get(figH,'UserData');
            [UD, savedUD] = create_save_struct(UD);
        else
	    fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all', ...
	                                'BlockType','FromWorkspace');
        savedUD = get_param(fromWsH,'SigBuilderData');
        end
        varargout{1} = savedUD;
        
    case 'create'
        time = varargin{1};
        data = varargin{2};
        sigLabels = varargin{3};
        groupLabels = varargin{4};
        
        apiData = create_api_data(time,data,sigLabels,groupLabels);
        
        % Create the GUI
        dialog = create([]);
        UD = get(dialog,'UserData');
        UD = restore_from_saveStruct(UD, apiData);
        
        % Create the block
        UD = export_to_simulink(UD);
        set(dialog,'UserData',UD);
        update_titleStr(UD);

        % need this due to the restore call above.
        if is_simulating_l(UD), UD = enter_iced_state_l(UD); end;

        if nargout>0
            varargout{1} = UD.simulink.subsysH;        
        end
        
    case 'append'
        blockH = varargin{1};
        time = varargin{2};
        data = varargin{3};
        sigLabels = varargin{4};
        groupLabels = varargin{5};
        
        % Create the new dataSet structures
        [chanCnt,groupCnt] = size(data);
        timeVec = time{1,1};
        newDataSet = dataSet_data_struct(groupLabels{1},[timeVec(1) timeVec(end)],1);
        for i=2:groupCnt
            timeVec = time{1,i};
            newDataSet(end+1) = dataSet_data_struct(groupLabels{i},[timeVec(1) timeVec(end)],1);
        end
        
        % Get the existing signal data
	    figH = get_param(blockH,'UserData');
	    if ~isempty(figH) && ishandle(figH)
	        guiOpen = 1;
	        UD = get(figH,'UserData');
            channels = UD.channels;
            dataSet = UD.dataSet;
        else
            guiOpen = 0;
    	    fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all', ...
    	                                'BlockType','FromWorkspace');
            savedUD = get_param(fromWsH,'SigBuilderData');
            channels = savedUD.channels;
            dataSet = savedUD.dataSet;
        end

        dataSet = [dataSet newDataSet];
        for chanIdx = 1:chanCnt
            channels(chanIdx).allXData = [channels(chanIdx).allXData time(chanIdx,:)];
            channels(chanIdx).allYData = [channels(chanIdx).allYData data(chanIdx,:)];
            if ~isempty(sigLabels)
                channels(chanIdx).label = sigLabels{chanIdx};
            end
        end
        
        % Apply the changes
        if guiOpen
            UD.channels = channels;
            UD.dataSet = dataSet;
            for i=1:groupCnt
                sigbuilder_tabselector('addentry',UD.hgCtrls.tabselect.axesH,groupLabels{i});
            end
            UD = dataSet_sync_menu_state(UD);
            UD = update_tab_sub_menu(UD);
            if ~isempty(sigLabels)
                for chanIdx = 1:chanCnt
                    [UD,applyStr] = rename_channel(UD,chanIdx,sigLabels{chanIdx});
                end
            end            
            set(UD.dialog,'UserData',UD) % Push changes before calling vnv_manager
        else
            savedUD.channels = channels;
            savedUD.dataSet = dataSet;
            set_param(fromWsH,'SigBuilderData',savedUD);
        end

        vnv_notify('sbBlkGroupAdd',blockH,newDataSet);  % Modify this to include a set of groups

        
    case 'set'
        blockH = varargin{1};
        signalIdx= varargin{2};
        goupIdx = varargin{3};
        sigCnt = length(signalIdx);
        grpCnt = length(goupIdx);
        time = varargin{4};
        data = varargin{5};

        % Get the existing signal data
	    figH = get_param(blockH,'UserData');
	    if ~isempty(figH) && ishandle(figH)
	        guiOpen = 1;
	        UD = get(figH,'UserData');
            channels = UD.channels;
            dataSet = UD.dataSet;
            activeIdx = UD.current.dataSetIdx;
        else
            guiOpen = 0;
    	    fromWsH = find_system(blockH,'FollowLinks','on','LookUnderMasks','all', ...
    	                                'BlockType','FromWorkspace');
            savedUD = get_param(fromWsH,'SigBuilderData');
            channels = savedUD.channels;
            dataSet = savedUD.dataSet;
            activeIdx = savedUD.dataSetIdx;
        end

        if any(goupIdx==activeIdx)
            activeDataCol = find(goupIdx==activeIdx);
        else
            activeDataCol = [];
        end
        
        if guiOpen
            % Apply the active data if it exists
            if ~isempty(activeDataCol)
                for idx = 1:sigCnt
                    sigIdx = signalIdx(idx);
                    UD.channels(sigIdx).xData = time{idx,activeDataCol};
                    UD.channels(sigIdx).yData = data{idx,activeDataCol};
                    if ~isempty(UD.channels(sigIdx).lineH)
                        axIdx = UD.channels(sigIdx).axesInd;
                        UD = apply_new_channel_data(UD,sigIdx,time{idx,activeDataCol}, ...
                                                    data{idx,activeDataCol},1);
                        UD = rescale_axes_to_fit_data(UD,axIdx,sigIdx,[]);
                    end
                end
            end
            
            % Update all the other groups    
            for idx = 1:sigCnt
                sigIdx = signalIdx(idx);
                UD.channels(sigIdx).allXData(goupIdx) = time(idx,:);
                UD.channels(sigIdx).allYData(goupIdx) = data(idx,:);
            end
            set(UD.dialog,'UserData',UD) % Push changes before calling vnv_manager
        else
            % Apply the active data if it exists
            if ~isempty(activeDataCol)
                for idx = 1:sigCnt
                    sigIdx = signalIdx(idx);
                    savedUD.channels(sigIdx).xData = time{idx,activeDataCol};
                    savedUD.channels(sigIdx).yData = data{idx,activeDataCol};
                end
            end
            
            % Update all the other groups    
            for idx = 1:sigCnt
                sigIdx = signalIdx(idx);
                savedUD.channels(sigIdx).allXData(goupIdx) = time(idx,:);
                savedUD.channels(sigIdx).allYData(goupIdx) = data(idx,:);
            end
            set_param(fromWsH,'SigBuilderData',savedUD);
        end

    case 'removeSig'
        removeSignals = varargin{1};

    case 'removeGroup'
        removeGroup = varargin{1};
            
    case 'replace',
        blockH = varargin{1};
        time = varargin{2};
        data = varargin{3};
        sigLabels = varargin{4};
        groupLabels = varargin{5};
        
        apiData = create_api_data(time,data,sigLabels,groupLabels);
        
        % Force open the GUI 
        blockUD = get_param(blockH,'UserData');
        if isempty(blockUD) || ~ishandle(blockUD)
            open_system(blockH);
            blockUD = get_param(blockH,'UserData');
        end
        UD = get(blockUD,'UserData');
        UD = restore_from_saveStruct(UD, apiData);
        
    otherwise,
        error('Bad method');
    end        
        
    
function varargout = apicall(ApiData,method,varargin)

    switch(method)
    case 'create'
        ApiData = create_api_data;
        
    case 'makeBlock'
        
        % First we will ensure some consistency to the data structure
        % before instantiating the block. Only the first signal is visible in all
        % groups and the first group is active.
        
    
        % Set the time range for each data set based on the first signal
        sigCnt = length(ApiData.channels);
        for grpIdx=1:length(ApiData.dataSet)
            ApiData.dataSet(grpIdx).timeRange(1) = min(ApiData.channels(1).allXData{grpIdx});
            ApiData.dataSet(grpIdx).timeRange(2) = max(ApiData.channels(1).allXData{grpIdx});
            ApiData.dataSet(grpIdx).activeDispIdx = sigCnt:-1:1;
        end
        
        % Copy the first group as the active X and Y data for each signal
        for chIdx=1:length(ApiData.channels)
            ApiData.channels(chIdx).xData = ApiData.channels(chIdx).allXData{1};
            ApiData.channels(chIdx).yData = ApiData.channels(chIdx).allYData{1};
        end
        
        % Create the GUI
        dialog = create([]);
        UD = get(dialog,'UserData');
        UD = restore_from_saveStruct(UD, ApiData);
        
        % Create the block
        UD = export_to_simulink(UD,varargin{:});
        set(dialog,'UserData',UD);

        % need this due to the restore call above.
        if is_simulating_l(UD), UD = enter_iced_state_l(UD); end;
        
        return
        
    case 'newsignal'
        xData = varargin{1};
        yData = varargin{2};

        if length(varargin)<3
            label = sprintf('Signal %s', num2str(length(ApiData.channels+1)));
        else
            label = varargin{3};
        end
        
        if isfield(ApiData,'channels') & ~isempty(ApiData.channels)
            allNames = {ApiData.channels.label};
            label = uniqueify_str_with_number(label,0,allNames{:});
        end
        
        if length(varargin)<4
            color = [];
        else
            color = varargin{4};
        end
        
        chStruct = channel_data_struct(xData,yData,0,0,label,1,length(ApiData.dataSet),color);
        if isempty(ApiData.channels)
            ApiData.channels = check_and_apply_line_properties(chStruct,1);
            for i=1:length(ApiData.dataSet)   
                ApiData.channels.allXData{i} = xData;
                ApiData.channels.allYData{i} = yData;
            end
        else
            ApiData.channels(end+1) = check_and_apply_line_properties(chStruct, ...
                                                length(ApiData.channels)+1);
             for i=1:length(ApiData.dataSet)   
                minx =  min(ApiData.channels(1).allXData{i});
                maxx = max(ApiData.channels(1).allXData{i});
                [x,y] = correct_endpoints([],xData,yData,minx,maxx);
                ApiData.channels(end).allXData{i} = xData;
                ApiData.channels(end).allYData{i} = yData;
            end
       end
        varargout{2} = length(ApiData.channels);
        
    case 'newgroup'
        dsName = sprintf('Group %s', num2str(length(ApiData.dataSet)+1));
        allNames = {ApiData.dataSet.name};
        dsName = uniqueify_str_with_number(dsName,0,allNames{:});
        ApiData.dataSet(end+1) = dataSet_data_struct(dsName);
        dsIdx = length(ApiData.dataSet);
        if nargin<3
            for chIdx = 1:length(ApiData.channels)
                ApiData.channels(chIdx).allXData{dsIdx} = [0 10];
                ApiData.channels(chIdx).allYData{dsIdx} = [0 0];
            end
        else
            cpySet = varargin{1};
            for chIdx = 1:length(ApiData.channels)
                ApiData.channels(chIdx).allXData{dsIdx} = ApiData.channels(chIdx).allXData{cpySet};
                ApiData.channels(chIdx).allYData{dsIdx} = ApiData.channels(chIdx).allYData{cpySet};
            end
        end
        varargout{2} = dsIdx;
            
    case 'newxdata'
        % Just assume everything is ok
        chIdx = varargin{1};
        grpIdx = varargin{2};
        ApiData.channels(chIdx).allXData{grpIdx} = varargin{3};
        
    case 'newydata'
        % Just assume everything is ok
        chIdx = varargin{1};
        grpIdx = varargin{2};
        ApiData.channels(chIdx).allYData{grpIdx} = varargin{3};
    
    end

    varargout{1} = ApiData;


function apiData = create_api_data(time,data,sigLabels,groupLabels)

        if nargin==0
            sigCnt = 0;
            grpCnt = 0;
            sigLabels = [];
            groupLabels = [];
        else
            [sigCnt,grpCnt] = size(time);
        end

        if isempty(sigLabels)
            sigLabels = cell(1,sigCnt);
            for i=1:sigCnt
                sigLabels{i} = ['Signal ' num2str(i)];
            end
        end
        
        if isempty(groupLabels)
            groupLabels = cell(1,grpCnt);
            for i=1:grpCnt
                groupLabels{i} = ['Group ' num2str(i)];
            end
        end
        
        apiData.gridSetting = 'on';
        apiData.dataSetIdx = 1;
        apiData.common = common_data_struct;
        apiData.channels = [];
        apiData.axes = [];
        
        if grpCnt>0
            apiData.dataSet = dataSet_data_struct(groupLabels{1});
        else
            apiData.dataSet = dataSet_data_struct;
            return;
        end
        
        
        apiData.dataSet.activeDispIdx = 1;

        
        % Create all the signals
        actualLabels{1} = sigLabels{1};
        
        for i=1:sigCnt
            if i>1
                actualLabels{end+1} = uniqueify_str_with_number(sigLabels{i},0,actualLabels{:});
            end
    
            chStruct = channel_data_struct( time{i,1}, ...
                                            data{i,1}, ...
                                            0, ...
                                            0, ...
                                            actualLabels{i}, ...
                                            1, ...
                                            1, ...
                                            []);
            chStruct = check_and_apply_line_properties(chStruct,i);
            chStruct.allXData = time(i,:);
            chStruct.allYData = data(i,:);
            if (i==1)
                apiData.channels = chStruct;
            else
                apiData.channels(end+1) = chStruct;
            end
        end
           
        for i=2:grpCnt
            apiData.dataSet(end+1) = dataSet_data_struct(groupLabels{i});
            apiData.dataSet(end).activeDispIdx = 1;
        end





function status = is_cv_licensed
    
    [wState] = warning;
    warning('off');
    try,
        a = cv('get','default','slsfobj.isa');
        if isempty(a)
            status = 0;
        else
        	status = 1;
        end
    catch
        status = 0;
    end
    warning(wState);

     
%---------------------------------------------------------------
function lightGray = light_gray_l
%
%
%
    lightGray = [.9 .9 .9];
    
%---------------------------------------------------------------
function white = default_axes_bg_color_l
%
%
%
   white = [1 1 1];
   
%---------------------------------------------------------------
function UD = enter_iced_state_l(UD),
%
%
%
   UD.current.state = 'ICED';
   set(UD.dialog,'UserData',UD); % persist UD.current.state!
   color_axes_l(UD, 'ICED');
   toDisable = [UD.menus.figmenu.signal, ...
               UD.menus.figmenu.tab, ...
               UD.toolbar.constantSig, ...
               UD.toolbar.stepSig, ...
               UD.toolbar.pulseSig ...
            ];
              
   set(toDisable, 'enable','off');
   UD = update_channel_select(UD);
   
   
   
%---------------------------------------------------------------
function UD = enter_idle_state_l(UD),
%
%
%
   UD.current.state = 'IDLE';
   set(UD.dialog,'UserData',UD); % persist UD.current.state!
   color_axes_l(UD, 'IDLE');
   toEnable = [UD.menus.figmenu.signal, ...
               UD.menus.figmenu.tab, ...
               UD.toolbar.constantSig, ...
               UD.toolbar.stepSig, ...
               UD.toolbar.pulseSig ...
           ];
   set(toEnable, 'enable','on');
   UD = update_channel_select(UD);

%---------------------------------------------------------------
function color_axes_l(UD, style),
%
%
%
    theAxes = [UD.axes.handle];
    
     switch style,
         case 'IDLE', set(theAxes, 'color', default_axes_bg_color_l);
         case 'ICED', set(theAxes, 'color', light_gray_l);
         otherwise,   set(theAxes, 'color', default_axes_bg_color_l);
     end;
     
   
          
%---------------------------------------------------------------
function isIced = in_iced_state_l(UD),
%
%
%  
   isIced = isstruct(UD) & isfield(UD, 'current') & isfield(UD.current, 'state') & isequal(UD.current.state, 'ICED');
    
%---------------------------------------------------------------
function isSimulating = is_simulating_l(UD),
%
%
%  
   isSimulating = logical(0);
   
   if isstruct(UD) & isfield(UD,'simulink') & isfield(UD.simulink, 'modelH'),
	   if ~isequal(get_param(UD.simulink.modelH, 'simulationStatus'), 'stopped'),
		   isSimulating = logical(1);
	   end;
   end;
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notify the verification manager if it exists
function vnv_notify(method,blockH,varargin)

    if is_a_link(blockH) || ~vnv_enabled
        return;
    end
    
    preverr = lasterr;
    
    try
        vnv_assert_mgr(method,blockH,varargin{:});
    catch
        % Restore the error state
        lasterr(preverr);
    end


function out = figure_has_java(figH)
    out = ~isempty(get(figH,'JavaFrame'));


function out = vnv_enabled
    persistent enabled;
    if isempty(enabled)
        enabled = (license('test','SL_Verification_Validation') && ...
                    (exist('vnv_assert_mgr')==6 || exist('vnv_assert_mgr')==2));
    end
    out = enabled;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLink = is_a_link(blockH),
%
% Determine if a block is a link
%
if isempty(get_param(blockH, 'ReferenceBlock')),
   isLink = 0;
else,
   isLink = 1;
end;


    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = in_a_library(blockH),
%
%  
    modelH = bdroot(blockH);
    if strcmp(lower(get_param(modelH,'BlockDiagramType')),'library'), result = 1;
    else, result = 0;
    end;

