function fuzzy(action);
%FUZZY  Basic FIS editor.
%   The FIS Editor displays high-level information about a 
%   Fuzzy Inference System. At the top is a diagram of the 
%   system with each input and output clearly labeled. By 
%   double-clicking on the input or output boxes, you can bring 
%   up the Membership Function Editor. Double-clicking on the 
%   fuzzy rule box in the center of the diagram will bring up 
%   the Rule Editor.                     
%                                                
%   Just below the diagram is a text field that displays the 
%   name of the current FIS. In the lower left of the window are 
%   a series of popup menus that allow you to specify the various 
%   functions used in the fuzzy implication process. In the lower 
%   right are fields that provide information about the current 
%   variable. The current variable is determined by clicking once
%   on one of the input or output boxes.
%
%   See also MFEDIT, RULEEDIT, RULEVIEW, SURFVIEW, ANFISEDIT.

%   Ned Gulley, 4-30-94, Kelly Liu 7-10-96, N. Hickey 17-03-01
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.41.2.2 $  $Date: 2004/04/10 23:15:27 $

% The # symbol is used to mark all callbacks into this function
selectColor=[1 0.3 0.3];

if nargin<1,
    newFis=newfis('Untitled');
    newFis=addvar(newFis,'input','input1',[0 1],'init');
    newFis=addvar(newFis,'output','output1',[0 1],'init');
    action=newFis;
end

if isstr(action),
    if action(1)~='#',
        % The string "action" is not a switch for this function, 
        % so it must be a disk file
        fis=readfis(action);
        action='#initialize';
    end
else
    % For initialization, the fis matrix is passed in as the parameter
    fis=action;
    action='#initialize';
end;

if strcmp(action,'#initialize'),
    % Detect any FIS Editors out there with exactly the same name
    fisName=fis.name;
    figName=['FIS Editor: ' fisName];
    while findall(0,'Type','figure','Name',figName),
        nameLen=length(fisName);
        lastChar=fisName(nameLen);
        if abs(lastChar)>47 & abs(lastChar)<58,
            fisName(nameLen)=lastChar+1;
        else
            fisName=[fisName '2'];
        end
        fis.name=fisName;
        figName=['FIS Editor: ' fisName];
    end

    fisType=fis.type;

    if isfield(fis, 'input')
      NumInputs=length(fis.input);
    else
      NumInputs=0;
    end

    if isfield(fis, 'output')
      NumOutputs=length(fis.output);
    else
      NumOutputs=0;
    end
    if isfield(fis, 'rule')
      NumRules=length(fis.rule);
    else
      NumRules=0;
    end
 

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    border=6;
    spacing=6;
    figPos=get(0,'DefaultFigurePosition');
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=110;
    btnHt=23;
 
    %====================================
    % The FIGURE
    thisfis{1}=fis;
    figNumber=figure( ...
        'Name',figName, ...
        'NumberTitle','off', ...
        'Color',[0.9 0.9 0.9], ...
        'CloseRequestFcn','fisgui #close',...
        'IntegerHandle','off',...
        'Visible','off', ...
        'MenuBar','none', ...
        'UserData',thisfis, ...
        'Units','pixels', ...
        'DefaultAxesXColor','black', ...
        'DefaultAxesYColor','black', ...
        'Position',figPos, ...
        'Tag','fuzzy', ...
        'ButtonDownFcn','fuzzy #deselect', ...
        'KeyPressFcn','fuzzy #keypress', ...
        'DockControls', 'off');
    figPos=get(figNumber,'position');

    %====================================
    % The MENUBAR items
    % Call fisgui to create the menubar items
    fisgui #initialize

    %====================================
    % The AXES frame 
    top=maxTop-border;
    bottom=border+7*btnHt+14*spacing;
    right=maxRight-border;
    left=border;
    axBorder=spacing;
    axPos=[left-axBorder bottom-0.5*axBorder ...
        right-left+axBorder*2 top-bottom+axBorder*2];
    axHndl=axes( ...
        'Box','on', ...
        'Units','pixels', ...
        'Position',axPos, ...
        'Tag','mainaxes', ...
        'Visible','on');

    %====================================
    % The MAIN frame 
    top=border+7*btnHt+12*spacing;
    bottom=border; 
    right=maxRight-border;
    left=border;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %====================================
    % The STATUS frame 
    bottom=border+spacing;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The STATUS text window
    labelStr=' ';
    name='status';
    pos=[left bottom right-left btnHt];
    statHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Tag',name, ...
        'String',labelStr);

    %====================================
    % The TOP frame 
    top=border+7*btnHt+11*spacing;
    bottom=top-btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;

    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The FIS NAME text window
    labelStr='FIS Name:';
    pos=[left top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The FIS NAME edit window
    name='fisname';
    pos=[left+spacing+btnWid top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'Tag',name);

    %------------------------------------
    % The FIS TYPE text window
    labelStr='FIS Type:';
    pos=[right-spacing-2*btnWid top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'Units','pixel', ...
        'String',labelStr);

    %------------------------------------
    % The FIS TYPE text display
    labelStr=' mamdani';
    name='fistype';
    pos=[right-btnWid top-btnHt btnWid btnHt];
    hndl=uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'BackgroundColor',frmColor, ...
        'Position',pos, ...
        'Tag',name, ...
        'String',labelStr);

    %====================================
    % The VARIABLES frame 
    top=border+6*btnHt+8*spacing;
    bottom=border+7*spacing+2*btnHt;
    right=maxRight-border-spacing;
    left=(maxRight)/2+2*spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    varFrmHndl=uicontrol( ...
        'Units','pixel', ...
        'Style','frame', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    varSpacing=(top-bottom-4*btnHt)/3;
    %------------------------------------
    % The CURRENT VARIABLE text field
    n=1;
    labelStr='Current Variable';
    pos=[left top-btnHt*n-varSpacing*(n-1) right-left btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The CURRENT VARIABLE NAME text field
    n=2;
    labelStr='Name';
    pos=[left top-btnHt*n-varSpacing*(n-1) right-left btnHt];
    hndl=uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The CURRENT VARIABLE NAME edit field
    callbackStr='fuzzy #varname';
    name='currvarname';
    pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    inputVarNameHndl=uicontrol( ...
        'Units','pixel', ...
        'Style','edit', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'Enable','off', ...
        'BackgroundColor',editColor, ...
        'Tag',name, ...
        'Callback',callbackStr);

    %------------------------------------
    % The CURRENT VARIABLE TYPE text field
    n=3;
    labelStr='Type';
    pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'String',labelStr);

    %------------------------------------
    % The CURRENT VARIABLE TYPE text field
    name='currvartype';
    pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'BackgroundColor',frmColor, ...
        'Units','pixel', ...
        'Position',pos, ...
        'Tag',name);

    %------------------------------------
    % The CURRENT VARIABLE RANGE text field
    n=4;
    labelStr='Range';
    pos=[left top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    outputVarNameHndl=uicontrol( ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Units','pixel',...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'String',labelStr);

    %------------------------------------
    % The CURRENT VARIABLE RANGE display field
    name='currvarrange';
    pos=[right-btnWid top-btnHt*n-varSpacing*(n-1) btnWid btnHt];
    outputVarNameHndl=uicontrol( ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Units','pixel',...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'Tag',name);


    %====================================
    % The METHODS frame 
    bottom=border+4*spacing+btnHt;
    left=border+spacing;
    right=(maxRight)/2-spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    mthFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    mthSpacing=(top-bottom-5*btnHt)/4;
    %------------------------------------
    % The AND METHOD text field
    n=1;
    labelStr='And method';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The AND METHOD popup menu
    labelStr=str2mat(' min',' prod',' Custom...');
    name='andMethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
        'BackgroundColor',popupColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Callback',callbackStr, ...
        'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The OR METHOD text field
    n=2;
    labelStr='Or method';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The OR METHOD popup menu
    labelStr=str2mat(' max',' probor',' Custom...');
    name='orMethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
        'HorizontalAlignment','left', ...
        'BackgroundColor',popupColor, ...
        'Units','pixel', ...
        'Position',pos, ...
        'Callback',callbackStr, ...
        'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The IMPLICATION METHOD text field
    n=3;
    labelStr='Implication';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The IMPLICATION METHOD popup menu
    labelStr=str2mat(' min',' prod',' Custom...');
    name='impMethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
        'HorizontalAlignment','left', ...
        'BackgroundColor',popupColor, ...
        'Units','pixel', ...
        'Position',pos, ...
        'Callback',callbackStr, ...
        'Tag',name, ...
        'String',labelStr);
    if strcmp(fisType,'sugeno'),
        set(hndl,'Enable','off');
    end

    %------------------------------------
    % The AGGREGATION METHOD text field
    n=4;
    labelStr='Aggregation';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The AGGREGATION METHOD popup menu
    labelStr=str2mat(' max',' sum',' probor',' Custom...');
    name='aggMethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'BackgroundColor',popupColor, ...
        'Callback',callbackStr, ...
        'Tag',name, ...
        'String',labelStr);
    if strcmp(fisType,'sugeno'),
        set(hndl,'Enable','off');
    end

    %------------------------------------
    % The DEFUZZIFICATION METHOD text field
    n=5;
    labelStr='Defuzzification';
    pos=[left top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The DEFUZZIFICATION METHOD popup menu
    if strcmp(fisType,'mamdani'),
        % Defuzzification methods are different depending on the FIS type
        labelStr=str2mat(' centroid',' bisector',' mom',' lom', ...
            ' som',' Custom...');
    else
        labelStr=str2mat(' wtaver',' wtsum');
    end
    name='defuzzMethod';
    callbackStr='fuzzy #methodchange';
    pos=[right-btnWid top-btnHt*n-mthSpacing*(n-1) btnWid btnHt];
    hndl=uicontrol( ...
        'Style','popupmenu', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'BackgroundColor',popupColor, ...
        'Callback',callbackStr, ...
        'Tag',name, ...
        'String',labelStr);

    %====================================
    % The CLOSE frame 
%    top=border+2*spacing+2*btnHt;
    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=(maxRight)/2+2*spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The HELP button
    labelStr='Help';
    callbackStr='fuzzy #help';
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The CLOSE button
    labelStr='Close';
    callbackStr='fisgui #close';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[right-btnWid bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    fuzzy #update
    
    % Check to see if there is a populated input/output field
    if isfield(fis,'input') & length(fis.input) >= 1
        % Call localSelectVar to select it and populate the text boxes
        localSelectVar( 'input','1', figNumber, selectColor);
    elseif isfield(fis,'output') & length(fis.output) >= 1
        localSelectVar( 'output','1', figNumber, selectColor);
    end  
    
    % Uncover the figure
    set(figNumber, ...
        'Visible','on', ...
        'HandleVisibility','callback');


elseif strcmp(action,'#update'),
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    if isfield(fis, 'input')
      NumInputs=length(fis.input);
    else
      NumInputs=0;
    end

    if isfield(fis, 'output')
      NumOutputs=length(fis.output);
    else
      NumOutputs=0;
    end
    if isfield(fis, 'rule')
      NumRules=length(fis.rule);
    else
      NumRules=0;
    end
 
    % The FIS NAME edit window
    name='fisname';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    fisName=fis.name;
    labelStr=[' ' fisName];
    set(hndl,'String',labelStr);

    % The FIS TYPE text field
    name='fistype';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    fisType=fis.type;
    set(hndl,'String',fisType);

    % Clear all current variable display registers ...
    varTypeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(varTypeHndl,'String',' ');
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    set(varNameHndl,'String',' ','Enable','off');
    varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    set(varRangeHndl,'String',' ');
    
    % The AND METHOD popup menu
    name='andMethod';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    labelStr=get(hndl,'String');
    andMethod=fis.andMethod;
    val=findrow(andMethod,labelStr);
    if isempty(val),
        labelStr=str2mat([' ' andMethod],labelStr);
        msgStr=['Installing custom And method "' andMethod '"'];
        statmsg(figNumber,msgStr);
        set(hndl,'String',labelStr,'Value',1);
    elseif val~=get(hndl,'Value'),
        set(hndl,'Value',val);
    end

    % The OR METHOD popup menu
    name='orMethod';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    labelStr=get(hndl,'String');
    orMethod=fis.orMethod;
    val=findrow(orMethod,labelStr);
    if isempty(val),
        labelStr=str2mat([' ' orMethod],labelStr);
        msgStr=['Installing custom Or method "' orMethod '"'];
        statmsg(figNumber,msgStr);
        set(hndl,'String',labelStr,'Value',1);
    elseif val~=get(hndl,'Value'),
        set(hndl,'Value',val);
    end

    if ~strcmp(fisType,'sugeno'),
        % The IMPLICATION METHOD popup menu
        name='impMethod';
        hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
        labelStr=get(hndl,'String');
        impMethod=fis.impMethod;
        val=findrow(impMethod,labelStr);
        if isempty(val),
            labelStr=str2mat([' ' impMethod],labelStr);
            msgStr=['Installing custom Implication method "' impMethod '"'];
            statmsg(figNumber,msgStr);
            set(hndl,'String',labelStr,'Value',1);
        elseif val~=get(hndl,'Value'),
            set(hndl,'Value',val);
        end

        % The AGGREGATION METHOD popup menu
        name='aggMethod';
        hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
        labelStr=get(hndl,'String');
        aggMethod=fis.aggMethod;
        val=findrow(aggMethod,labelStr);
        if isempty(val),
            labelStr=str2mat([' ' aggMethod],labelStr);
            msgStr=['Installing custom Aggregation method "' aggMethod '"'];
            statmsg(figNumber,msgStr);
            set(hndl,'String',labelStr,'Value',1);
        elseif val~=get(hndl,'Value'),
            set(hndl,'Value',val);
        end
    end

    % The DEFUZZIFICATION METHOD popup menu
    name='defuzzMethod';
    hndl=findobj(figNumber,'Type','uicontrol','Tag',name);
    labelStr=get(hndl,'String');
    defuzzMethod=fis.defuzzMethod;
    val=findrow(defuzzMethod,labelStr);
    if isempty(val),
        labelStr=str2mat([' ' defuzzMethod],labelStr);
        msgStr=['Installing custom Defuzzification method "' defuzzMethod '"'];
        statmsg(figNumber,msgStr);
        set(hndl,'String',labelStr,'Value',1);
    elseif val~=get(hndl,'Value'),
        set(hndl,'Value',val);
    end

    % Now plot the FIS diagram
    % First delete all axes except for the main one
    axHndlList=findobj(figNumber,'Type','axes');
    mainAxHndl=findobj(figNumber,'Type','axes','Tag','mainaxes');
    axHndlList(find(axHndlList==mainAxHndl))=[];
    delete(axHndlList);
    lineHndlList=findobj(figNumber,'Type','line');
    delete(lineHndlList);
    fuzzy #plotfis

    fisName=fis.name;
    msgStr=[ 'System "' fisName '": ' num2str(NumInputs) ' inputs, ' ...
        num2str(NumOutputs) ' outputs, and ' ...
        num2str(NumRules) ' rules'];
    if NumInputs==1, msgStr=strrep(msgStr,'inputs','input'); end
    if NumOutputs==1, msgStr=strrep(msgStr,'outputs','output'); end
    if NumRules==1, msgStr=strrep(msgStr,'rules','rule'); end
    statmsg(figNumber,msgStr);

    watchoff(figNumber)
    
elseif strcmp(action,'#keypress'),
    %====================================
    figNumber=gcf;
    key_number = get(figNumber,'CurrentCharacter');
    if ~isempty(key_number)
        if abs(key_number)==127,
            if ~isempty(findobj(figNumber,'Type','axes','XColor',selectColor)),
                fuzzy #rmvar
            end
        end
    end
    

elseif strcmp(action,'#addvar'),
    figNumber=watchon;
    currMenu=gcbo;
    %currMenu = eventSrc;
    varType=get(currMenu,'Tag');
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    % "Add" has been selected, so add a variable
    fis=addvar(fis,varType,'',[0 1],'init');
    if strcmp(varType,'input')
        numVars=length(fis.input);
    else
        numVars=length(fis.output);
    end
    newVarName=[varType num2str(numVars)];
    eval(['fis.' varType '(numVars).name = newVarName; '])
    msgStr=['Adding the ' varType ' variable "' newVarName '"'];
    statmsg(figNumber,msgStr);
    pushundo(figNumber,fis);
    %    set(figNumber,'UserData',fis);
    
    % Now replot the FIS diagram
    % First delete all axes except for the main one
    axHndlList=findobj(figNumber,'Type','axes');
    mainAxHndl=findobj(figNumber,'Type','axes','Tag','mainaxes');
    axHndlList(find(axHndlList==mainAxHndl))=[];
    delete(axHndlList);
    lineHndlList=findobj(figNumber,'Type','line');
    delete(lineHndlList);
    fuzzy #plotfis
    
    % Clear the VARIABLE NAME, TYPE, and RANGE fields
    hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    set(hndl,'String',' ');
    hndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(hndl,'String',' ');
    hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    set(hndl,'String',' ');
    
    statmsg(figNumber,'Ready');
    
    % Call localSelectVar to select variable and populate text boxes
    localSelectVar( lower(varType), num2str(numVars), figNumber, selectColor);
    % Update all the other editors 
    updtfis(figNumber,fis,[2 3 4 5 6]);
   
    watchoff(figNumber);
    
    
elseif strcmp(action,'#rmvar'),
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
    if isempty(currVarAxes),
        statmsg(figNumber,'No variable was selected!');
        watchoff(figNumber)
        return
    end
    varIndex=get(currVarAxes,'UserData');
    tag=get(currVarAxes,'Tag');
    if strcmp(tag(1:5),'input'),
        varType='input';
    else
        varType='output';
    end
    
    % Find the corresponding name display field
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    if strcmp(varType, 'input'),
        varName=fis.input(varIndex).name;
    elseif strcmp(varType, 'output'),
        varName=fis.output(varIndex).name;
    end
    if strcmp(varType,'input'), 
        numVars=length(fis.input);
        %%%    varLabels=fis.InLabels;
    else
        numVars=length(fis.output);
        %%%    varLabels=fis.OutLabels;
    end
    
    % Remove a variable
    [fis,errorMsg]=rmvar(fis,varType,varIndex, true);
    if isempty(fis),
        % rmvar has failed for one reason or other
        statmsg(figNumber,errorMsg)
    else
        msgStr=['Removing the ' varType ' variable "' varName '"'];
        statmsg(figNumber,msgStr);
        
        pushundo(figNumber,fis);
        
        % Now replot the FIS diagram
        % First delete all axes except for the main one
        axHndlList=findobj(figNumber,'Type','axes');
        mainAxHndl=findobj(figNumber,'Type','axes','Tag','mainaxes');
        axHndlList(find(axHndlList==mainAxHndl))=[];
        delete(axHndlList);
        lineHndlList=findobj(figNumber,'Type','line');
        delete(lineHndlList);
        fuzzy #plotfis
        
        % Clear the VARIABLE NAME, TYPE, and RANGE fields
        hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
        set(hndl,'String',' ');
        hndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
        set(hndl,'String',' ');
        hndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
        set(hndl,'String',' ');
    end
    
    % Call localSelectVar to select the variable and populate the text boxes    
    if strcmp(varType,'input')  & isfield(fis, 'input')
        if length(fis.input) == 0 & isfield(fis, 'output')
            % If no inputs left select the first output
            if length(fis.output) >= 1
                localSelectVar( 'output', '1', figNumber, selectColor);
            else
                % There is nothing left to plot so deselect remove variable from menu
                rmvarMenuHndl=findobj(figNumber,'Type','uimenu','Tag','removevar');
                set(rmvarMenuHndl,'Enable','off');
            end    
        elseif length(fis.input) == 1
            localSelectVar( 'input', '1', figNumber, selectColor);
        else
            localSelectVar( 'input',  num2str(max(varIndex-1, 1)), figNumber, selectColor);
        end
    elseif strcmp(varType,'output') & isfield(fis, 'output')
        if length(fis.output) == 0 & isfield(fis, 'input')
            % If no outputs left select the first input
            if length(fis.input) >= 1
                localSelectVar( 'input', '1', figNumber, selectColor);
            else
                % There is nothing left to plot so deselect remove variable from menu
                rmvarMenuHndl=findobj(figNumber,'Type','uimenu','Tag','removevar');
                set(rmvarMenuHndl,'Enable','off');
            end    
        elseif length(fis.output) == 1
            localSelectVar( 'output', '1', figNumber, selectColor);
        else
            localSelectVar( 'output',  num2str(max(varIndex-1, 1)), figNumber, selectColor);
        end
    end
    
    % Update all the other editors now that the new variable has been highlighted
    updtfis(figNumber,fis,[2 3 4 5 6]);
    
    watchoff(figNumber)
    

elseif strcmp(action,'#deselect'),
    %====================================
    figNumber=watchon; 
    % Deselect all variables
    oldCurrVar=findobj(figNumber,'Type','axes','XColor',selectColor);
    set(oldCurrVar, ...
        'LineWidth',1, ...
        'XColor','black','YColor','black');
    
    % Clear all current variable display registers ...
    varTypeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(varTypeHndl,'String',' ');
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    set(varNameHndl,'String',' ','Enable','off');
    varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    set(varRangeHndl,'String',' ');
    rmvarMenuHndl=findobj(figNumber,'Type','uimenu','Tag','removevar');
    set(rmvarMenuHndl,'Enable','off');
    
    % Ensure plot has been redrawn correctly
    refresh(figNumber);
    
    watchoff(figNumber)
    
    
elseif strcmp(action,'#varname'),
    %====================================
    figNumber=watchon; 
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    currVarAxes=findobj(figNumber,'Type','axes','XColor',selectColor);
    varIndex=get(currVarAxes,'UserData');
    tag=get(currVarAxes,'Tag');
    if strcmp(tag(1:5),'input'),
        varType='input';
    else
        varType='output';
    end
    
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    newName=deblank(get(varNameHndl,'String'));
    % Strip off the leading space
    newName=fliplr(deblank(fliplr(newName)));
    % Replace any remaining blanks with underscores
    newName(find(newName==32))=setstr(95*ones(size(find(newName==32))));
    set(varNameHndl,'String',[' ' newName]);
    msgStr=['Renaming ' varType ' variable ' num2str(varIndex) ' to "' newName '"'];
    statmsg(figNumber,msgStr);
    
    % Change the name of the label in the input-output diagram
    txtHndl=get(currVarAxes,'XLabel');
    set(txtHndl,'String',newName);
    
    eval(['fis.' varType '(' num2str(varIndex) ').name=''' newName ''';']);
    pushundo(figNumber,fis);                     %%strcmp does not work for structures
    updtfis(figNumber,fis,[2 3 4 5]);
    watchoff(figNumber);
    
elseif strcmp(action,'#methodchange'),
    %====================================
    figNumber=watchon;
    mthHndl=gco;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    mthList=get(mthHndl,'String');
    numMth=size(mthList,1);
    
    % The UserData for the popup will tell which method is being 
    % changed, e.g. andmethod, ormethod, impmethod, etc.
    mthName=get(mthHndl,'Tag');
    newMthValue=get(mthHndl,'Value');
    newMth=deblank(mthList(newMthValue,:));
    newMth=fliplr(deblank(fliplr(newMth)));
    tempStr=['fis.' mthName];
    oldMth=eval(tempStr);
    oldMthValue=findrow(oldMth,mthList);
    if strcmp(newMth,'Custom...'),
        % Handle customized methods...
        mthName2=strrep(mthName,'method',' method');
        tString=['Adding customized ' mthName2];
        statmsg(figNumber,tString);

        cmthdlg(figNumber,fis,mthName);

        % In case there's a Cancel, return to the old value
        set(mthHndl,'Value',oldMthValue);

    elseif newMthValue~=oldMthValue,
        % Only change things if the method has actually changed
        mthName2=strrep(mthName,'method',' method');
        tString=['Changing ' mthName2 ' to "' newMth '"'];
        statmsg(figNumber,tString);
        eval(['fis.' mthName '=''' newMth ''';']);

        % Handle undo    
        pushundo(figNumber,fis)
        updtfis(figNumber,fis,[4 5]);
%       set(figNumber,'UserData',fis);
    end

%    statmsg(figNumber,'Ready');
    watchoff(figNumber);

elseif strcmp(action,'#openruleedit'),
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    if strcmp(get(figNumber,'SelectionType'),'open'),
      % Open the Rule Editor 
      fisName=fis.name;
      guiName='Rule Editor';
      newFigNumber=findobj(0,'Name',[guiName ': ' fisName]);
      if ~isempty(newFigNumber),
         statmsg(figNumber,['Updating ' guiName]);
         figure(newFigNumber);
         ruleedit('#update');
      else
         statmsg(figNumber,['Opening ' guiName]);
         ruleedit(fis);
      end
   end
   watchoff(figNumber)

elseif strcmp(action,'#plotfis'),
    %====================================
    figNumber=gcf;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    set(figNumber,'Nextplot','replace')
    if isfield(fis, 'input')
      numInputs=length(fis.input);
    else
      numInputs=0;
    end

    if isfield(fis, 'output')
      numOutputs=length(fis.output);
    else
      numOutputs=0;
    end
     numInputMFs=0;
    for k=1:numInputs, 
      numInputMFs=numInputMFs+length(fis.input(k)); 
    end;
    numOutputMFs=0;
    for k=1:numOutputs, 
      numOutputMFs=numOutputMFs+length(fis.output(k)); 
    end;    

    numRules=length(fis.rule);
    ruleList=getfis(fis, 'ruleList');
    fisName=fis.name;
    fisType=fis.type;

    mainAxHndl=gca;
    set(mainAxHndl,'Units','pixel','Visible','off')
    mainAxPos=get(mainAxHndl,'Position');
    axis([mainAxPos(1) mainAxPos(1)+mainAxPos(3) ...
        mainAxPos(2) mainAxPos(2)+mainAxPos(4)]);
    xCenter=mainAxPos(1)+mainAxPos(3)/2;
    yCenter=mainAxPos(2)+mainAxPos(4)/2;
    axList=[];

    if get(0,'ScreenDepth')>2,
        inputColor=[1 1 0.5];
        outputColor=[0.5 1 1];
    else
        inputColor=[1 1 1];
        outputColor=[1 1 1];
        set(gcf,'Color',[1 1 1])
    end

    % For plotting three cartoon membership functions in the box
    xMin=-1; xMax=1;
    x=(-1:0.1:1)';
    y1=exp(-(x+1).^2/0.32); y2=exp(-x.^2/0.32); y3=exp(-(x-1).^2/0.32);
    xlineMatrix=[x x x];
    ylineMatrix=[y1 y2 y3];

    % Inputs first
    fontSize=8;
    boxWid=(1/3)*mainAxPos(3);
    xInset=boxWid/5;
    if numInputs>0,
        boxHt=(1/(numInputs))*mainAxPos(4);
        yInset=boxHt/5;
    end

    for varIndex=1:numInputs,
        boxLft=mainAxPos(1);
        boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
        axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];

        % Draw the line that connects the input to the main block
        axes(mainAxHndl);
        % Make it a dotted line if the variable is not used in the rule base
        if numRules==0,
            lineStyle='--';
        elseif ~any((ruleList(:,varIndex))), 
            lineStyle='--';
        else
            lineStyle='-';
        end
        xInputCenter=axPos(1)+axPos(3);
        yInputCenter=axPos(2)+axPos(4)/2;
        line([xInputCenter xCenter],[yInputCenter yCenter], ...
            'LineStyle',lineStyle, ...
            'LineWidth',2, ...
            'Color','black');
       % Now draw the little arrowhead on the line
   %    perpSlope=(xInputCenter-xCenter)/(yCenter-yInputCenter);
   %    arrowPt=[(xCenter+xInputCenter)/2 (yCenter+yInputCenter)/2];
   %    delta=(xCenter-xInputCenter)/10;
   %    line([xArrowPt xArrowPt

        varName=fis.input(varIndex).name;
        axName=['input' num2str(varIndex)];
        axHndl=axes( ...
            'Units','pixel', ...
            'Box','on', ...
            'XTick',[],'YTick',[], ...  
            'XLim',[xMin xMax],'YLim',[-0.1 1.1], ...
            'Color',inputColor, ...
            'Tag',axName, ...
            'UserData',varIndex, ...
            'Position',axPos);

        axList=[axList axHndl];

        line(xlineMatrix,ylineMatrix,'Color','black');
        xiInset=(xMax-xMin)/10;
        axis([xMin-xiInset xMax+xiInset -0.1 1.1])

        % Lay down a patch that simplifies clicking on the region
        patchHndl=patch([xMin xMax xMax xMin],[0 0 1 1],'black');
        set(patchHndl, ...
            'EdgeColor','none', ...
            'FaceColor','none', ...
            'UserData',struct('Index',varIndex,'Type','input','Handle',axHndl), ...
            'ButtonDownFcn', {@localSelectVar figNumber selectColor});

        % Now put on the variable name as a label
%        xlabel([varName ' (' num2str(numInputMFs(varIndex)) ')']);
        xlabel(varName);
        labelName=[axName 'label'];
        set(get(axHndl,'XLabel'), ...
            'FontSize',fontSize, ...
            'Color','black', ...
            'Tag',labelName);
    end

    % Now for the outputs
    if numOutputs>0,
        boxHt=(1/(numOutputs))*mainAxPos(4);
        yInset=boxHt/5;
    end

    for varIndex=1:numOutputs,
        boxLft=mainAxPos(1)+2*boxWid;
        boxBtm=mainAxPos(2)+mainAxPos(4)-boxHt*varIndex;
        axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset]; 

        % Draw the line connect the center block to the output
        axes(mainAxHndl);
        % Make it a dotted line if the variable is not used in the rule base
        if numRules==0,
            lineStyle='--';
        elseif ~any(ruleList(:,varIndex+numInputs)), 
            lineStyle='--';
        else
            lineStyle='-';
        end
        line([axPos(1) xCenter],[axPos(2)+axPos(4)/2 yCenter], ...
            'LineWidth',2, ...
            'LineStyle',lineStyle, ...
            'Color','black');

        varName=fis.output(varIndex).name;
        axName=['output' num2str(varIndex)];
        axHndl=axes( ...
            'Units','pixel', ...
            'Box','on', ...
            'Color',outputColor, ...
            'XTick',[],'YTick',[], ...  
            'Tag',axName, ...
            'UserData',varIndex, ...
            'Position',axPos);

        %set(axHndl,'UserData',struct('Index',varIndex,'Handle',axHndl);
        axList=[axList axHndl];
        if ~strcmp(fisType,'sugeno'),
            % Don't try to plot outputs it if it's a Sugeno-style system
            x=[-1 -0.5 0 0.5 1]';
            xlineMatrix=[x x x];
            ylineMatrix=[0 1 0 0 0;0 0 1 0 0; 0 0 0 1 0]';
            line(xlineMatrix,ylineMatrix,'Color','black');
            xoInset=(xMax-xMin)/10;
            axis([xMin-xoInset xMax+xoInset -0.1 1.1])
        else
            set(axHndl,'XLim',[xMin xMax],'YLim',[-0.1 1.1])
            text(0,0.5,'f(u)', ...
                'FontSize',fontSize, ...
                'Color','black', ...
                'HorizontalAlignment','center');
        end

        % Lay down a patch that simplifies clicking on the region
        patchHndl=patch([xMin xMax xMax xMin],[0 0 1 1],'black');
        set(patchHndl, ...
            'EdgeColor','none', ...
            'FaceColor','none', ...
            'UserData',struct('Index',varIndex,'Type','output','Handle',axHndl), ...
            'ButtonDownFcn', {@localSelectVar figNumber selectColor});

%        xlabel([varName ' (' num2str(numOutputMFs(varIndex)) ')']);
        xlabel(varName);
        labelName=[axName 'label'];
        set(get(axHndl,'XLabel'), ...
            'FontSize',fontSize, ...
            'Color','black', ...
            'Tag',labelName);
    end

    % Now draw the box in the middle
    boxLft=mainAxPos(1)+boxWid;
    boxBtm=mainAxPos(2);
    boxHt=mainAxPos(4);
    yInset=boxHt/4;
    axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
    axHndl=axes( ...
        'Units','pixel', ...
        'Box','on', ...
        'XTick',[],'YTick',[], ...      
        'YLim',[-1 1],'XLim',[-1 1], ...
        'XColor','black','YColor','black', ...
        'LineWidth',2, ...
        'ButtonDownFcn','fuzzy #openruleedit', ...
        'Color','white', ...
        'Position',axPos);
    axList=[axList axHndl];
    text(0,1/3,fisName, ...
        'Tag','fisname', ...
        'FontSize',fontSize, ...
        'ButtonDownFcn','fuzzy #openruleedit', ...
        'Color','black', ...
        'HorizontalAlignment','center');
    text(0,-1/3,['(' fisType ')'], ...
        'FontSize',fontSize, ...
        'ButtonDownFcn','fuzzy #openruleedit', ...
        'Color','black', ...
        'HorizontalAlignment','center');
    %    text(0,-1/2,[num2str(numRules) ' rules'], ...
    %        'ButtonDownFcn','fuzzy #openruleedit', ...
    %               'FontSize',fontSize, ...
    %               'Color','black', ...
    %               'HorizontalAlignment','center');
    set(get(axHndl,'Title'),'FontSize',fontSize,'Color','black');
    
    for count=1:length(axList),
        axes(axList(count));
    end
    set(figNumber,'HandleVisibility','callback')
    
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized')
    
    % Ensure plot has been redrawn correctly
    refresh(figNumber);
    
elseif strcmp(action,'#help');
    %====================================
    figNumber=watchon;
    helpwin('fuzzy/fuzzy/fuzzy');
    watchoff(figNumber)
    
end;    % if strcmp(action, ...


%%%%%%%%%%%%%%%%%%%%
%  localSelectVar  %
%%%%%%%%%%%%%%%%%%%%
function localSelectVar(eventSrc, eventData, figNumber, selectColor)
% This used to be called using elseif strcmp(action,'#selectvar')
% Function is called on initialization of the fuzzy editor and
% when user btn's down on, or deletes an input or output variable.
figX=watchon;
oldfis=get(figNumber,'UserData');
fis=oldfis{1};

if ishandle(eventSrc)
    % Function was called via callback from btn down on a variables patch
    info = get(eventSrc, 'UserData');
    newCurrVar = info.Handle;           % axes where patch is drawn
    varIndex   = info.Index;
    varType    = info.Type;
    % Reset any selected items
    kids = findobj(figNumber,'Type','Axes','XColor',selectColor);
    set(kids,'LineWidth',1,'XColor','k','YColor','k');
else 
    % Function was called at initialization of a new GUI or variable, therefore
    varType  = eventSrc;   % A string of the variable type to select
    numVars  = eventData;  % A string of the variable index number to select
    kids = get(figNumber,'children');
    newCurrVar = findobj(kids,'tag', [varType numVars]);
    varIndex = str2num(numVars);
    % Plot will have already been redrawn therefore no need to reset
end  

% Ensure plot has been redrawn correctly
refresh(figNumber);

% If there are no variables left to plot dont try to plot them
if varIndex ~= 0
    % Now highlight the new selection
    set(newCurrVar,'XColor',selectColor,'YColor',selectColor,'LineWidth',3);
    
    % Set all current variable display registers ...
    varNameHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarname');
    varRangeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvarrange');
    if strcmp(varType, 'input'),
        set(varNameHndl,'String',[' ' fis.input(varIndex).name],'Enable','on');
        set(varRangeHndl,'String',mat2str(fis.input(varIndex).range));
    else
        set(varNameHndl,'String',[' ' fis.output(varIndex).name],'Enable','on');
        set(varRangeHndl,'String',mat2str(fis.output(varIndex).range));
    end
    varTypeHndl=findobj(figNumber,'Type','uicontrol','Tag','currvartype');
    set(varTypeHndl,'String',varType);
    
    rmvarMenuHndl=findobj(figNumber,'Type','uimenu','Tag','removevar');
    set(rmvarMenuHndl,'Enable','on')
    
    if strcmp(get(figNumber,'SelectionType'),'open'),
        % Open the MF Editor with the right variable in view,
        % when user double clicks on variable.
        fisName=fis.name;
        guiName='Membership Function Editor';
        newFigNumber=findobj(0,'Name',[guiName ': ' fisName]);
        if ~isempty(newFigNumber),
            statmsg(figNumber,['Updating ' guiName]);
            figure(newFigNumber);
            mfedit('#update',varType,varIndex);
        else
            statmsg(figNumber,['Opening ' guiName]);
            mfedit(fis,varType,varIndex);
        end
        
    end
end

watchoff(figX)