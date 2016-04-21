function surfview(action);
%SURFVIEW Output surface viewer.
%   The Surface Viewer invoked using surfview('a') is a GUI tool that lets you 
%   examine the output surface of a FIS, a.fis, for any one or two inputs. 
%   Since it does not alter the fuzzy system or its associated FIS matrix in 
%   any way, it is a read-only editor. Using the pop-up menus, you select the 
%   two input variables you want assigned to the two input axes (X and Y), as 
%   well the output variable you want assigned to the output (or Z) axis. Select 
%   the Evaluate button to perform the calculation and plot the output surface.
%   By clicking on the plot axes and dragging the mouse, you can actually 
%   manipulate the surface so that you can view it from different angles.
%   If there are more than two inputs to your system, you must supply, in the 
%   reference input section, the constant values associated with any unspecified 
%   inputs. 
%   
%   See also ANFISEDIT, FUZZY, GENSURF, MFEDIT, RULEEDIT, RULEVIEW

%   Ned Gulley, 3-30-94, Kelly Liu 7-20-96, N. Hickey 03-17-01
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.49.2.2 $  $Date: 2004/04/10 23:15:39 $

if nargin<1,
    % Open up an untitled system.
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
    %====================================
    fisName=fis.name;
    % Set up default colormap
    colorMap=jet(150);
    colorMap=colorMap(33:97,:);
    nameStr=['Surface Viewer: ' fisName];
    thisfis{1}=fis;
    figNumber=figure( ...
        'Name',nameStr, ...
        'NumberTitle','off', ...
        'Visible','off', ...
        'IntegerHandle','off',...
        'MenuBar','none', ...
        'UserData',thisfis, ...
        'Tag','surfview', ...
        'Renderer', 'zbuffer', ...
        'DefaultAxesFontSize',8, ...
        'ColorMap',colorMap, ...
        'DockControls', 'off');
    figPos=get(figNumber,'position');

    %====================================
    % The MENUBAR items
    % Call fisgui to create the menubar items
    fisgui #initialize
 
    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    axColor=128/255*[1 1 1];
    border=6;
    spacing=6;
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=90;
    btnHt=22;

    bottom=border;
    top=bottom+4*btnHt+9*spacing;
    right=maxRight-border;
    left=border;
 
    %====================================
    % The MAIN frame
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2];
    frmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %====================================
    % The AXIS
    axBorder=40;
    axPos=[left+3*axBorder top+axBorder right-left-6.5*axBorder ...
        maxTop-top-border-1.5*axBorder];
    axHndl=axes( ...
        'Units','pixel', ...
        'Position',axPos, ...
        'NextPlot','replace', ...
        'Box','on');
    titleStr=['Output surface for the FIS ' fisName];
    title(titleStr);

    %====================================
    % The DATA frame 
    top=top-spacing;
    bottom=top-spacing-2*btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2];
    dataFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    dtBtnWid=0.95*btnWid;
    dtBtnWidWide=1.1*dtBtnWid;
    dtBtnWidNarrow=2*dtBtnWid-dtBtnWidWide;
    dtSpacing=(right-left-6*dtBtnWid)/5;
    %------------------------------------
    % The X-AXIS text field
    n=1;
    labelStr='X (input):';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-btnHt dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The X-AXIS popup menu
    n=2;
    name='xaxis';
    callbackStr='surfview #xaxis';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
        top-btnHt dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','popupmenu', ...
        'BackgroundColor',popupColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Callback',callbackStr, ...
        'String', ' ', ...
        'Tag',name);

    %------------------------------------
    % The Y-AXIS text field
    n=3;
    labelStr='Y (input):';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-btnHt dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The Y-AXIS popup menu
    n=4;
    name='yaxis';
    callbackStr='surfview #yaxis';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
        top-btnHt dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','popupmenu', ...
        'BackgroundColor',popupColor, ...
        'HorizontalAlignment','left', ...
        'Callback',callbackStr, ...
        'Units','pixel', ...
        'Position',pos, ...
        'String', ' ', ...
        'Tag',name);

    %------------------------------------
    % The Z-AXIS text field
    n=5;
    labelStr='Z (output):';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-btnHt dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The Z-AXIS popup menu
    n=6;
    name='zaxis';
    callbackStr='surfview #refinputedit';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
        top-btnHt dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','popupmenu', ...
        'BackgroundColor',popupColor, ...
        'HorizontalAlignment','left', ...
        'Callback',callbackStr, ...
        'Units','pixel', ...
        'Position',pos, ...
        'String', ' ', ...
        'Tag',name);

    %------------------------------------
    % The X-GRID text field
    n=1;
    labelStr='X grids:';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-2*btnHt-spacing dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The X-GRID edit field
    n=2;
    labelStr=' 15';
    name='xgrid';
    callbackStr='surfview #grids';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
        top-2*btnHt-spacing dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','edit', ...
        'BackgroundColor',editColor, ...
        'HorizontalAlignment','left', ...
        'Callback',callbackStr, ...
        'Units','pixel', ...
        'Position',pos, ...
        'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The Y-GRID text field
    n=3;
    labelStr='Y grids:';
    pos=[left+(n-1)*(dtBtnWid+dtSpacing) top-2*btnHt-spacing dtBtnWidNarrow btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The Y-GRID edit field
    n=4;
    labelStr=' 15';
    name='ygrid';
    callbackStr='surfview #grids';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
        top-2*btnHt-spacing dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','edit', ...
        'BackgroundColor',editColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Callback',callbackStr, ...
        'Tag',name, ...
        'String',labelStr);

    %------------------------------------
    % The EVALUATE button
    n=6;
    labelStr='Evaluate';
    name='evaluate';
    callbackStr='surfview #evaluate';
    pos=[left+(n-2)*(dtBtnWid+dtSpacing)+dtBtnWidNarrow+dtSpacing ...
        top-2*btnHt-spacing dtBtnWidWide btnHt];
    ruleDispHndl=uicontrol( ...
        'Style','pushbutton', ...
        'BackgroundColor',btnColor, ...
        'Units','pixel', ...
        'Position',pos, ...
        'Callback',callbackStr, ...
        'Enable','off', ...
        'Tag',name, ...
        'String',labelStr);

    %====================================
    % The REFERENCE INPUT frame 
    bottom=border+4*spacing+btnHt;
    top=bottom+btnHt;
    left=border+spacing;
    right=maxRight-border-2*btnWid-5*spacing;

    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    refSpacing=(right-left-3*btnWid)/2;
    %------------------------------------
    % The REFERENCE INPUT text window
    labelStr='Ref. Input:';
    pos=[left bottom btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The INPUT edit window
    name='refinputedit';
    callbackStr='surfview #refinputedit';
    pos=[left+btnWid+spacing bottom right-left-btnWid-spacing btnHt];
    inputDispHndl=uicontrol( ...
        'Style','edit', ...
        'BackgroundColor',editColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Tag',name, ...
        'Callback',callbackStr);

    %====================================
    % The CLOSE frame 
    right=maxRight-border-spacing;
    left=right-2*btnWid-spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The HELP button
    labelStr='Help';
    callbackStr='surfview #help';
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

    %====================================
    % The STATUS frame 
    bottom=border+spacing;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2];
    dataFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The STATUS text window
    labelStr='Status info go here';
    name='status';
    pos=[left bottom right-left btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor', ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Tag',name, ...
        'String',labelStr);

    surfview #update
    rotate3d on

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');
 
    % Uncover the figure
    set(figNumber, ...
        'Visible','on');

elseif strcmp(action,'#update');
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    xaxisHndl=findobj(figNumber,'Type','uicontrol','Tag','xaxis');
    yaxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    zaxisHndl=findobj(figNumber,'Type','uicontrol','Tag','zaxis');
    xgridHndl=findobj(figNumber,'Type','uicontrol','Tag','xgrid');
    ygridHndl=findobj(figNumber,'Type','uicontrol','Tag','ygrid');
    plotHndl=findobj(figNumber,'Type','uimenu','Tag','plottype');
    evalHndl=findobj(figNumber,'Type','uimenu','Tag','alwayseval');
    refinputHndl=findobj(figNumber,'Type','uicontrol','Tag','refinputedit');
    hndlList=[xaxisHndl yaxisHndl zaxisHndl xgridHndl ygridHndl ...
         plotHndl evalHndl refinputHndl];
    set(hndlList,'Enable','off');
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

    if (numInputs<1) | (numOutputs<1),
        statmsg(figNumber, ...
            'Need at least one input and one output to view output surface');
        cla     
        watchoff(figNumber)
        return
    end
    if isfield(fis, 'rule')
      numRules=length(fis.rule);
    else
      numRules=0;
    end

    if numRules<1,
        statmsg(figNumber,'Need at least one rule to view output surface');
        cla
        watchoff(figNumber)
        return
    end

    % The X-AXIS popup menu
    inLabels=getfis(fis,'inLabels');
    xAxisLabelStr=[32*ones(size(inLabels,1),1) inLabels];
    labelStr=xAxisLabelStr;
    set(xaxisHndl,'String',labelStr);

    % The Y-AXIS popup menu
    inLabels(1,:)=[];
    if ~isempty(inLabels),
        labelStr=[32*ones(size(inLabels,1)+1,1) str2mat(inLabels,'- none -')];
    else
        labelStr=' - none -';
    end
    set(yaxisHndl,'String',labelStr);

    % The Z-AXIS popup menu
    outLabels=getfis(fis,'outLabels');
    labelStr=[32*ones(size(outLabels,1),1) outLabels];
    set(zaxisHndl,'String',labelStr);

    % The REFERENCE INPUT edit field
    if numInputs==0,
        refInput=[];
    else
        Range=getfis(fis,'inRange');
        refInput=mean(Range');
    end
    set(refinputHndl,'UserData',refInput);

    set(hndlList,'Enable','on');
    surfview #refinputedit

elseif strcmp(action,'#refinputedit');
    %====================================
    figNumber=watchon;
    refInputHndl=findobj(figNumber,'Type','uicontrol','Tag','refinputedit');
    if isempty(refInputHndl)
       watchoff(figNumber);
       return;
    end
    % The edit field's UserData is where the actual reference input is stored
    oldRefInput=get(refInputHndl,'UserData');

    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    numInputs=length(fis.input);
    inLabels=getfis(fis,'inLabels');

    % Determine the x axis
    xAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','xaxis');
    xAxisValue=get(xAxisHndl,'Value');
    xAxisList=get(xAxisHndl,'String');
    xAxisStr=deblank(xAxisList(xAxisValue,:));
    xIndex=findrow(xAxisStr,inLabels);
 
    % Determine the y axis
    yAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    yAxisValue=get(yAxisHndl,'Value');
    yAxisList=get(yAxisHndl,'String');
    yAxisStr=deblank(yAxisList(yAxisValue,:));
    yIndex=findrow(yAxisStr,inLabels);

    newRefInput=eval(get(refInputHndl,'String'),'oldRefInput');

    if length(newRefInput)~=length(oldRefInput),
        newRefInput=oldRefInput;
    end

    % Fill in the spots that are currently occupied by NaN place-holders
    nanIndex=find(isnan(newRefInput));
    newRefInput(nanIndex)=oldRefInput(nanIndex);

    inRange=getfis(fis,'inRange');

    % Guarantee that new input falls within the accepted range for the variable
    newRefInput=max(inRange(:,1)',newRefInput);
    newRefInput=min(inRange(:,2)',newRefInput);
 
    set(refInputHndl,'UserData',newRefInput);

    % Re-insert the NaN place-holders
    if isempty(yIndex),
        newRefInput(xIndex)=NaN;
    else
        newRefInput([xIndex yIndex])=[NaN NaN];
    end

    if all(isnan(newRefInput)),
        % If it's nothing but NaNs, then don't let the user edit (or see) the field
        set(refInputHndl,'String',' ', ...
            'Enable','off')
    else
        set(refInputHndl,'String',[' ' mat2str(newRefInput,4)], ...
            'Enable','on')
    end

    % Plot right away if always-eval is checked
    evalHndl=findobj(gcf,'Type','uimenu','Tag','alwayseval');
    if strcmp(get(evalHndl,'Checked'),'on'),
        surfview #evaluate
    end
        
    watchoff(figNumber);

elseif strcmp(action,'#xaxis');
    %====================================
    % We need to prevent the x-axis and y-axis from being the same thing
    figNumber=watchon;
    xAxisHndl=get(figNumber,'CurrentObject');
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    numInputs=length(fis.input);
    inLabels=getfis(fis,'inLabels');
    outLabels=getfis(fis,'outLabels');
    % Determine the x axis
    xAxisValue=get(xAxisHndl,'Value');
    xAxisList=get(xAxisHndl,'String');
    xAxisStr=deblank(xAxisList(xAxisValue,:));
    xIndex=findrow(xAxisStr,inLabels);
    yAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    yAxisValue=get(yAxisHndl,'Value');
    inLabels(xIndex,:)=[];
    if ~isempty(inLabels),
        yAxisList=[32*ones(numInputs,1) str2mat(inLabels,'- none -')];
    else
        yAxisList=' - none -';
    end
    set(yAxisHndl,'String',yAxisList);
    set(yAxisHndl,'Value',yAxisValue);
    yAxisStr=deblank(yAxisList(yAxisValue,:));
    yIndex=findrow(yAxisStr,inLabels);

    % Now update the reference input area
    surfview #refinputedit
    watchoff(figNumber);

elseif strcmp(action,'#yaxis');
    %====================================
    % We need to prevent the x-axis and y-axis from being the same thing
    figNumber=watchon;
    % Update the reference input area
    surfview #refinputedit
    watchoff(figNumber);

elseif strcmp(action,'#grids');
    %====================================
    % Calculate immediately if necessary
    gridHndl=gco;
    % Use try-catch to avoid bogus grids
    gridNum=eval(get(gridHndl,'String'),'15');
    gridNum=abs(round(gridNum(1)));
    gridNum=max(gridNum,3);
    gridNum=min(gridNum,100);
    set(gridHndl,'String',[' ' num2str(gridNum)]);
    evalHndl=findobj(gcf,'Type','uimenu','Tag','alwayseval'); 
    if strcmp(get(evalHndl,'Checked'),'on'),
        surfview #evaluate
    end

elseif strcmp(action,'#evaluate');
    %====================================
    figNumber=get(0,'CurrentFigure');
    axHndl=get(figNumber,'CurrentAxes');
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    statmsg(figNumber,'Calculating new surface');

    % Determine the number of points to be evaluated
    xGridHndl=findobj(figNumber,'Type','uicontrol','Tag','xgrid');
    xGrids=eval(get(xGridHndl,'String'));
    yGridHndl=findobj(figNumber,'Type','uicontrol','Tag','ygrid');
    yGrids=eval(get(yGridHndl,'String'));

    inLabels=getfis(fis,'inLabels');
    outLabels=getfis(fis,'outLabels');

    % Determine the x axis
    xAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','xaxis');
    xAxisValue=get(xAxisHndl,'Value');
    xAxisList=get(xAxisHndl,'String');
    xAxisStr=deblank(xAxisList(xAxisValue,:));
    xIndex=findrow(xAxisStr,inLabels);
 
    % Determine the y axis
    yAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','yaxis');
    yAxisValue=get(yAxisHndl,'Value');
    yAxisList=get(yAxisHndl,'String');
    yAxisStr=deblank(yAxisList(yAxisValue,:));
    yIndex=findrow(yAxisStr,inLabels);

    zAxisHndl=findobj(figNumber,'Type','uicontrol','Tag','zaxis');
    zIndex=get(zAxisHndl,'Value');
    Range=getfis(fis,'inRange');

    % Retrieve the reference input from the edit field's UserData
    refInputHndl=findobj(figNumber,'Type','uicontrol','Tag','refinputedit');
    refInput=get(refInputHndl,'UserData');

    [x,y,z]=gensurf(fis,[xIndex yIndex],zIndex,[xGrids yGrids],refInput);

    % Put the results in the appropriate hiding places
    plotMenuHndl=findobj(figNumber,'Type','uimenu','Tag','plottype');
    cmapMenuHndl=findobj(figNumber,'Type','uimenu','Tag','colormap');
    if isempty(y),
%       set(axHndl,'NextPlot','replace');
%       set(figNumber,'NextPlot','replace');
        plot(x,z,'Color','blue','LineWidth',3);
        xlabel(deblank(inLabels(xIndex,:)));
        ylabel(deblank(outLabels(zIndex,:)));
        set(axHndl,'Box','on')
        set(plotMenuHndl,'Enable','off');
        set(cmapMenuHndl,'Enable','off');
        rotate3d off
        set(figNumber,'HandleVisibility','callback');
        set(axHndl,'HandleVisibility','callback');
    else
        xlabel(deblank(inLabels(xIndex,:)));
        ylabel(deblank(inLabels(yIndex,:)));
        zlabel(deblank(outLabels(zIndex,:)));
        set(axHndl,'UserData',[x y z],'Box','on')
        set(plotMenuHndl,'Enable','on');
        set(cmapMenuHndl,'Enable','on');
        rotate3d on
        surfview #plot
    end
    statmsg(figNumber,'Ready');

elseif strcmp(action,'#plot');
    figNumber=watchon;
    plotMenuHndl=findobj(figNumber,'Type','uimenu','Tag','plottype');
    plotTypeHndl=findobj(plotMenuHndl,'Checked','on');
    plotType=deblank(get(plotTypeHndl,'Label'));
    axHndl=get(figNumber,'CurrentAxes');

    % Unpack the hidden data
    xyz=get(axHndl,'UserData');
    viewData=get(axHndl,'View');
    numCols=size(xyz,2)/3;
    x=xyz(:,1:numCols);
    y=xyz(:,numCols+(1:numCols));
    z=xyz(:,2*numCols+(1:numCols));
    xStr=get(get(axHndl,'XLabel'),'String');
    yStr=get(get(axHndl,'YLabel'),'String');
    zStr=get(get(axHndl,'ZLabel'),'String');

    cla

    rotate3d on
    colorMap=get(figNumber,'Colormap');
    if all(viewData==[0 90]),
        viewData=[-37.5 30];
    end

    % Generate the plot
    if strcmp(plotType,'Surface'),
        surf(x,y,z);
        rotate3d on;
    elseif strcmp(plotType,'Lit Surface'),
        surfl(x,y,z);
        rotate3d on;
    elseif strcmp(plotType,'Mesh'),
        meshHndl=mesh(x,y,z);
        set(meshHndl,'LineWidth',2);
        rotate3d on;
    elseif strcmp(plotType,'X Mesh'),
        meshHndl=mesh(x,y,z);
        set(meshHndl,'MeshStyle','row','FaceColor','none','LineWidth',2);
        rotate3d on;
    elseif strcmp(plotType,'Y Mesh'),
        meshHndl=mesh(x,y,z);
        set(meshHndl,'MeshStyle','column','FaceColor','none','LineWidth',2);
        rotate3d on;
    elseif strcmp(plotType,'Contour'),
        numContours=20;
        [c,h]=contour3(x,y,z,numContours);
        set(h,'LineWidth',3);
        rotate3d on;
    elseif strcmp(plotType,'Pseudo-Color'),
        pcolor(x,y,z);
        viewData=[0 90];
        rotate3d off
    elseif strcmp(plotType,'Quiver'),
        [px,py]=gradient(z);
        quiver(x,y,px,py,2,'b')
        viewData=[0 90];
        rotate3d off
    end

    set(axHndl,'UserData',xyz,'Box','on')
    xlabel(xStr);
    ylabel(yStr);
    zlabel(zStr);
    xMin=min(min(x)); xMax=max(max(x));
    yMin=min(min(y)); yMax=max(max(y));
    zMin=min(min(z)); zMax=max(max(z));
    if zMin==zMax, zMin=-inf; zMax=inf; end;
    axis([xMin xMax yMin yMax zMin zMax])
    set(axHndl,'View',viewData)
    watchoff(figNumber);

elseif strcmp(action,'#colormap');
    figNumber=watchon;
    menuHndl=gcbo;
    newMapName=deblank(get(menuHndl,'Label'));
    % Ensure menu items are unchecked
    mapmenuHndl  = get( menuHndl,'Parent');
    submenuHndls = get( mapmenuHndl,'Children');
    set(submenuHndls,'Checked','off');
    % Check selected menu
    set(menuHndl,'Checked','on');
    
    if strcmp(newMapName,'Default'),
        newMap=jet(150);
        newMap=newMap(33:97,:);
    elseif strcmp(newMapName,'Blue'),
        newMap=fliplr(pink(120));
        newMap=newMap(43:107,:);
    elseif strcmp(newMapName,'Hot'),
        newMap=hot(128);
        newMap=newMap(43:107,:);
    elseif strcmp(newMapName,'HSV'),
        newMap=hsv;
    end

    colormap(newMap)
    watchoff(figNumber)

elseif strcmp(action,'#shading');
    %====================================
    figNumber=watchon;
    menuHndl=gcbo;
    shadingType=deblank(get(menuHndl,'Label'));
    surfHndl=findobj(figNumber,'Type','surface');
    if strcmp(shadingType,'Faceted'),
        set(surfHndl,'FaceColor','flat');
        set(surfHndl,'EdgeColor',mean(get(figNumber,'Colormap')));
    elseif strcmp(shadingType,'Flat'),
        set(surfHndl,'FaceColor','flat');
        set(surfHndl,'EdgeColor','none');
    elseif strcmp(shadingType,'Smooth'),
        set(surfHndl,'FaceColor','interp');
        set(surfHndl,'EdgeColor',mean(get(figNumber,'Colormap')));
    end

    watchoff(figNumber)

elseif strcmp(action,'#evaltoggle');
    %====================================
    figNumber=watchon;
    evalMenuHndl=gcbo;
    evalBtnHndl=findobj(figNumber,'Type','uicontrol','Tag','evaluate');
    if strcmp(get(evalMenuHndl,'Checked'),'on'),
        set(evalMenuHndl,'Checked','off');
        set(evalBtnHndl,'Enable','on');
    else
        set(evalMenuHndl,'Checked','on');
        set(evalBtnHndl,'Enable','off');
    end
    watchoff(figNumber)

elseif strcmp(action,'#plotselect');
    %====================================
    figNumber=watchon;
    plotSelectHndl=gcbo;
    plotMenuHndl=get(plotSelectHndl,'Parent');
    plotUnselectHndl=findobj(plotMenuHndl,'Checked','on');
    set(plotUnselectHndl,'Checked','off');
    set(plotSelectHndl,'Checked','on');
    surfview #plot
    watchoff(figNumber)

elseif strcmp(action,'#help');
    %====================================
    figNumber=watchon;
    helpwin(mfilename);
    watchoff(figNumber)
                                               
end;
