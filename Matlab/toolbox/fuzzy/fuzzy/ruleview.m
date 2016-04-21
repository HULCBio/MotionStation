function ruleview(action, input, figNumber);
%RULEVIEW Rule viewer and fuzzy inference diagram.
%   RULEVIEW(fis) opens the Rule Viewer, or Inference Diagram
%   Viewer, for the fuzzy inference system, fis. 
%   RULEVIEW('FILENAME') depicts the fuzzy inference 
%   diagram for the fuzzy inference system stored in file
%   FILENAME.FIS.
%
%   The Rule Viewer displays, in one screen, all parts of 
%   the fuzzy inference process from inputs to outputs. Each 
%   row of plots corresponds to one rule, and each column of 
%   plots corresponds to either an input variable (yellow, on 
%   the left) or an output variable (blue, on the right). You
%   can change the system input either by typing a specific 
%   value into the Input window or by moving the long yellow 
%   index lines that go down each input variable's column of 
%   plots.
%                                                                     
%   See also ADDRULE, MFEDIT, RULEEDIT, SURFVIEW

%   Ned Gulley, 3-30-94 Kelly Liu 4-20-97, N. Hickey 03-17-01
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.63.2.2 $  $Date: 2004/04/10 23:15:36 $

inputColor=[1 0 0];
outputColor=[0 0 1];

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
    fisName=fis.name;
    numRules=length(fis.rule);
    thisfis{1}=fis;
    figNumber=figure( ...
        'Name',['Rule Viewer: ' fisName], ...
        'NumberTitle','off', ...
        'IntegerHandle','off',...
        'MenuBar','none', ...
        'Visible','off', ...
        'UserData',thisfis, ...
        'Tag','ruleview', ...
        'Color',[.9 .9 .9], ...
        'DoubleBuffer', 'on', ...
        'BackingStore','off', ...
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
    border=6;
    spacing=6;
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=90;
    btnHt=22;

    bottom=border;
    top=bottom+2*btnHt+5*spacing;
    right=maxRight-border;
    left=border;
 
    %====================================
    % The MAIN frame
    % This frame is given a name so that it can be located later on
    % using "findobj". The UserData for this frame will contain the
    % matrix of line handles used in the callbacks.
    name='dataframe';
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    frmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'Tag',name, ...
        'BackgroundColor',frmColor);

    %====================================
    % The INPUT frame 
    top=top-spacing;
    bottom=top-btnHt;
    left=border+spacing;
    right=maxRight-border-1.5*btnWid-5*spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left-1.75*btnWid top-bottom+frmBorder*2]+[1 0 1 0];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);
    %-------numPts----------------------
    frmPos=[right-frmBorder-1.75*btnWid+.5*spacing bottom-frmBorder ...
        1.25*btnWid+1.5*spacing top-bottom+frmBorder*2]+[1 0 1 0];
    topFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The num of points text window
    labelStr='Plot points:';
    pos1=[right-frmBorder-1.75*btnWid+spacing*1 bottom .78*btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor', frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos1, ...
        'String',labelStr);
    %------------------------------------
    % The INPUT text window
    labelStr='Input:';
    pos=[left-spacing*.5 bottom btnWid/2 btnHt];
    helpHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'String',labelStr);

    %------------------------------------
    % The INPUT edit window
    callbackStr='ruleview #updateinputs';
    name='inputdisp';
    pos=[left+btnWid/2-2*spacing bottom right-left-btnWid*2.25 btnHt];
    inputDispHndl=uicontrol( ...
        'Style','edit', ...
        'BackgroundColor',editColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Tag',name, ...
        'Callback',callbackStr);
    %------------------------------------
    % The #points edit window
    name='numdisp';
    pos=[right-frmBorder-.85*btnWid-spacing*1 bottom .5*btnWid btnHt];
%pos1+[btnWid*.4 0 0 0];
    inputDispHndl=uicontrol( ...
        'Style','edit', ...
        'BackgroundColor',editColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Callback', 'ruleview #update',...
        'Tag',name);

    %====================================
    % The CLOSE/HELP frame 
    right=maxRight-border-spacing;
    left=right-2*btnWid-spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);
 
    frmPos=[left-frmBorder 7 ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);
    %------------------------------------
    % The postion text window
    pos1=[right-frmBorder-2*btnWid-spacing*.5 bottom 1.5*btnWid btnHt];
    helpHndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos1, ...
        'String','Move:');

    %------------------------------------
    % The HELP button
    labelStr='Help';
    callbackStr='ruleview #help';
    helpHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left bottom-40 btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The CLOSE button
    labelStr='Close';
    callbackStr='fisgui #close';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[right-btnWid bottom-40 btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);
    %------------------------------------
    % The shift horizontal button
    labelStr='left';
    callbackStr='ruleview #shiftleft';
    left=left+37;
    btnWid1= btnWid*2/5;
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left 53 btnWid*2/5 btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    % The shift horizontal button
    labelStr='right';
    callbackStr='ruleview #shiftright';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left+38 53 btnWid1 btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    % The shift horizontal button
    labelStr='down';
    callbackStr='ruleview #shiftdown';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left+76 53 btnWid1 btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);
    labelStr='up';
    callbackStr='ruleview #shiftup';
    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left+114 53 btnWid1 btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);
%    callbackStr='ruleview #slidehori';
%    closeHndl=uicontrol( ...
%        'Style','slide', ...
%        'Position',[20 90 3*btnWid btnHt], ...
%        'Max', 2,...
%        'Min', -2,...
%        'Value', 0, ...
%        'BackgroundColor',btnColor, ...
%        'String',labelStr, ...
%        'Callback',callbackStr);


    %====================================
    bottom=border+spacing;


   % The STATUS frame 
    top=bottom+btnHt;
    right=maxRight-border-2*btnWid-5*spacing;

    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
        right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    dataFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);



    %------------------------------------
    % The STATUS text window
    labelStr=['Opened system ' fisName ', ' num2str(numRules) ' rules'];
    name='status';
    pos=[left bottom right-left btnHt];
    hndl=uicontrol( ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Units','pixel', ...
        'Position',pos, ...
        'Tag',name, ...
        'String',labelStr);

    ruleview #update

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');
 
    % Uncover the figure
    set(figNumber, ...
        'Visible','on', ...
        'HandleVisibility','callback');
       
elseif strcmp(action,'#update'),
    %====================================
    figNumber=watchon;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    % Find and destroy all axes if they exist, since we might be updating
    % a previously existing system
    axHndlList=findobj(figNumber,'Type','axes');
    delete(axHndlList);
    set(figNumber,'Units','pixel')

    inputDispHndl=findobj(figNumber,'Type','uicontrol','Tag','inputdisp');
    set(inputDispHndl,'Enable','off');

    % First some error-checking
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
        statmsg(figNumber,'Need at least one input and one output to view rules');
        watchoff(figNumber)
        return
    end
    numRules=length(fis.rule);
    if numRules<1,
        statmsg(figNumber,'Need at least one rule to view rules');
        watchoff(figNumber)
        return
    end

    border=6; 
    spacing=6;
    btnHt=22;
    figPos=get(figNumber,'Position');
    maxRight=figPos(3);
    maxTop=figPos(4);
    axColor='black';

    bottom=border;
    top=bottom+2*btnHt+5*spacing;
    right=maxRight-border;
 
    % The mainAxPos is a border that defines where the rules will be displayed
    % Getting it the right size was mostly trial and error
    mainAxPos=[border top-bottom+border*6 maxRight-border*2 maxTop-top-border*10];

    % Now build all the appropriate axes
    % For each rule, there will be as many axes as (numInputs+numOutputs)
    ruleList=getfis(fis, 'ruleList');
    numRules=size(ruleList,1);
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
    for i=1:numInputs
      numInputMFs(i)=length(fis.input(i).mf);
    end
    for i=1:numOutputs
      numOutputMFs(i)=length(fis.output(i).mf);
    end
    
    
    for i=1:numInputs
         inRange(i, 1:2)=fis.input(i).range;
    end

    for i=1:numOutputs
         outRange(i,1:2)=fis.output(i).range;
    end
    totalRange = [inRange;outRange];
    totalRange = totalRange + [totalRange(:,1) == totalRange(:,2)] * [-eps +eps];
    totalVars=numInputs+numOutputs;
    fisType=fis.type;

    boxWid=max((1/totalVars)*(maxRight-border*2), 30);
    boxHt=max((1/(numRules+3))*(maxTop-top-border*2), 10);
    xInset=boxWid/5;
    yInset=boxHt/10;

    % Here we're precalculating all MF x and y values for plotting later
    numPts=101;
    pthndl=findobj(gcf, 'Tag', 'numdisp');
    temp=str2double(get(pthndl, 'String'));
    if ~isempty(temp) & temp>=101
      numPts=temp;
    end
    [xIn,yIn,xOut,yOut,R]=discfis(fis,numPts);
    inputVector1=get(inputDispHndl,'Value');
    inputValidFlag=0;
    % If the previous value of the input vector is still valid, use it.
    if length(inputVector1)==numInputs,
        if all(inputVector1'>inRange(:,1)) & all(inputVector1'<inRange(:,2)),
            inputValidFlag=1;
        end
    end
    if inputValidFlag,
        inputVector=inputVector1;
    else
        inputVector=mean(inRange');
    end

    % Do the actual FIS evaluation
    numPts=101;
    pthndl=findobj(gcf, 'Tag', 'numdisp');
    temp=str2double(get(pthndl, 'String'));
    if ~isempty(temp) & temp>=101
      numPts=temp;
    else
      set(pthndl, 'String', num2str(numPts));
    end
    [v,irr,orr,arr]=evalfis(inputVector,fis, numPts);
    axHndlMat=zeros(numRules+1,totalVars);
    if strcmp(fisType,'sugeno'),
        sugenoOutputRange=sugmax(fis);
    end

    for ruleIndex=1:(numRules+1),
%        boxBtm=(rem(numRules+1-ruleIndex,(numRules+1))/(numRules+1))*mainAxPos(4)+ ...
%            mainAxPos(2);
        xInset2=xInset*0.1;
        yInset2=yInset*0.2;
        boxBtm= mainAxPos(2)+mainAxPos(4)-ruleIndex*(boxHt+yInset2); 
        for varIndex=1:totalVars,
%            boxLft=max((rem(varIndex-1,totalVars)/totalVars)*mainAxPos(3)+mainAxPos(1), mainAxPos(1)+(varIndex-1)*(boxWid+xInset2));
            boxLft=(rem(varIndex-1,totalVars)/totalVars)*mainAxPos(3)+mainAxPos(1);
            if (varIndex==1) & (ruleIndex<=numRules),
                %====================================
                % RULE NUMBER
                %====================================
                % Every rule number has its own axis
                axPos=[boxLft+xInset2 boxBtm+yInset+yInset2 ...
                    xInset-2*xInset2 boxHt-2*yInset-2*yInset2];
                axes( ...
                    'Units','pixel', ...
                    'Box','on', ...
                    'Visible','off', ...
                    'XTick',[],'YTick',[], ...
                    'XLim',[-1 1],'YLim',[-1 1], ...
                    'Position',axPos);
               text(0,0,num2str(ruleIndex), ...
                    'ButtonDownFcn','ruleview #disprule', ...
                    'FontSize',8, ...
                    'Tag','rulelabel', ...
                    'HorizontalAlignment','center');
            end

            axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset boxHt-2*yInset];
            axHndlMat(ruleIndex,varIndex)=axes( ...
                'Units','pixel', ...
                'Box','on', ...
                'XColor',axColor,'YColor',axColor, ...
                'Xlim', totalRange(varIndex,:), 'Ylim', [-0.05 1.05], ...
                'XTick',[],'YTick',[], ...
                'Position',axPos);

            if (ruleIndex<=numRules) & (varIndex<=numInputs),
                %====================================
                % INPUT MFs
                %====================================
                % Here we are plotting the input variable membership functions
                % R is the modified rule list returned by discfis.
                mfColIndex=abs(R(ruleIndex,varIndex));
                % Use abs because negative refers to the use of NOT
                

                if mfColIndex,
                    % Don't plot it if the index is zero
                    x=xIn(:,mfColIndex);
                    y=yIn(:,mfColIndex);
                    if R(ruleIndex,varIndex)<0,
                        % Invert the MF if a NOT has been applied
                        y=1-y;
                    end
                    line(x,y,'Color',[.5 .5 0]);
                    xMin=min(x);
                    xMax=max(x);
                    xData=[xMin; x; xMax];
                    yData=min(irr(ruleIndex,varIndex),[0; y; 0]);
                    MFHndlMat(ruleIndex,varIndex)=patch( ...
                        xData,yData,[1 1 0]);
                end

                if ruleIndex==numRules, 
                    % Display the axis limits
                    set(gca,'XTick',totalRange(varIndex,:),'FontSize',8);
                end

            end

            if (ruleIndex<=numRules) & (varIndex>numInputs),
                %====================================
                % OUTPUT MFs
                %====================================
                % Here we are plotting the output variable membership functions
                % Remember the index may be negative
                outputVarIndex=varIndex-numInputs;
                % we have to subtract off the number of inputs since the
                % inputs are given before the outputs

                if ruleIndex==1, 
                    % Plot the variable name at the top of each column
                    varName=fis.output(varIndex-numInputs).name;
                    titleH=title([varName ' = ' num2str(v(varIndex-numInputs),3)], 'visible', 'on', 'fontSize', 8, 'interpreter','none');
                    set(gca, 'Tag', ['output' num2str(varIndex-numInputs)]);
                end

                mfIndex=abs(ruleList(ruleIndex,varIndex));
                if mfIndex,
                    % Plot it only if the index is nonzero
                    mfColIndex=sum(numOutputMFs(1:(outputVarIndex-1)))+mfIndex;
                    if strcmp(fisType,'mamdani'),
                        % MAMDANI system
                        x=xOut(:,mfColIndex);
                        y=yOut(:,mfColIndex);
                        if R(ruleIndex,varIndex)<0,
                            % Invert the MF if a NOT has been applied
                            y=1-y;
                        end
                        xMin=min(x);
                        xMax=max(x);
                        xData=[xMin; x; xMax];
                        yData=[0; orr(:,ruleIndex+(varIndex-numInputs-1)*numRules); 0];
                        MFHndlMat(ruleIndex,varIndex)=patch( ...
                            xData,yData,[.3 .3 1]);
                        line(x,y, ...
                             'Color',[0 0 .5]);
                    else
                        % SUGENO system
                        range=fis.output(varIndex-numInputs).range;
                        % The next line represents an educated guess at what the x axis
                        % limits should be
                        outRange=sugenoOutputRange(varIndex-numInputs,:);
                        outRange=outRange+0.1*(outRange(2)-outRange(1))*[-1 1];
                   %     outRange=.3*outRange;
                        outRange=eval(mat2str(outRange,4));
                        if outRange(1)==outRange(2)
                           outRange=outRange+[0 .1];
                        end
                        set(gca, ...
                            'XLim',outRange, ...
                            'YLim',[-0.05 1.05]);
                        xData2=[1 1]*orr(ruleIndex,varIndex-numInputs);
                        yData2=[0 1];
                        % The handle for the thin line will be carried by the fat line
                        lineHndl=line(xData2,yData2, ...
                            'LineWidth',5, ...
                            'LineStyle','-', ...
                            'Visible','on', ...
                            'Color',[.6 .8 .8]);
                        xData1=xData2;
                        yData1=[0 1]*arr(ruleIndex,varIndex-numInputs);
                        MFHndlMat(ruleIndex,varIndex)=line(xData1,yData1, ...
                            'LineWidth',4, ...
                            'UserData',lineHndl, ...
                            'Color',[0 0 1]);
                    end
                end
            end

            if (ruleIndex>numRules) & (varIndex<=numInputs),
                %====================================
                % MOVEABLE INDEX LINES
                %====================================
                % Draw in moveable input index lines
                % This axes position covers all axes in this input column
 %       boxBtm= mainAxPos(2)+mainAxPos(4)-ruleIndex*(10*yInset+yInset2); 
%                axPos=[boxLft+xInset mainAxPos(2) boxWid-2*xInset mainAxPos(4)];
                axPos=[boxLft+xInset boxBtm+yInset boxWid-2*xInset ruleIndex*(10*yInset+yInset2)];
                colIndex=sum(numInputMFs(1:(varIndex-1)))+1;
                xMin=inRange(varIndex,1);
                xMax=inRange(varIndex,2);
                inputVal=inputVector(varIndex);
                set(gca, ...
                    'Units','pixel', ...
                    'Visible','off', ...                  
                    'XLim',[xMin xMax],'YLim',[0 1], ...
                    'Position',axPos);
                line([1 1]*inputVal,[0.01 1], ...
                    'LineWidth',0.5, ...
                    'Color',[1 0 0], ...
                    'ButtonDownFcn','ruleview #clickline', ...
                    'UserData',varIndex, ...
                    'Tag','indexline', ...
                    'LineStyle','-');
                % The following patch is used to allow click-anywhere 
                % positioning of the index line
                patchHndl=patch([xMin xMax xMax xMin xMin],[0 0 1 1 0],'black');
                set(patchHndl, ...
                    'ButtonDownFcn','ruleview #patchclick', ...
                    'FaceColor','none', ...
                    'EdgeColor','none');
                if ruleIndex==numRules+1, 
                    % Plot the variable name at the top of each column
                    varName=fis.input(varIndex).name;
                    title([varName ' = ' num2str(inputVal,3)], 'visible', 'on', 'fontSize', 8, 'interpreter','none')
                end

            end

            if (ruleIndex>numRules) & (varIndex>numInputs),
                %====================================
                % AGGREGATE MF PLOT
                %====================================
                varName=fis.output(varIndex-numInputs).name;
                mfColIndex=sum(numOutputMFs(1:(varIndex-numInputs-1)))+1;
                if mfColIndex<=size(xOut,2),
                    x=xOut(:,mfColIndex);
                else
                    x=zeros(size(arr,1),1);
                end
%                compStr=computer;
%                if compStr(1:2)=='PC',
%                    eraseMode='normal';
%                else
%                    eraseMode='background';
%                end     
%                xlabel(num2str(v(varIndex-numInputs),3), ...
%                    'FontSize',8,'EraseMode',eraseMode);
                if strcmp(fisType,'mamdani'),
                    % MAMDANI
                    xMin=outRange(varIndex-numInputs,1);
                    xMax=outRange(varIndex-numInputs,2);
                    set(gca, ...
                        'XLim',totalRange(varIndex,:),'YLim',[-0.1 1.1], ...
                        'XTick',totalRange(varIndex,:), ...
                        'FontSize',8, ...
                        'XColor','b','YColor','b')
                    xData=[xMin; x; xMax];
                    yData=[0; arr(:,varIndex-numInputs); 0];
                    MFHndlMat(ruleIndex,varIndex)=patch( ...
                        xData,yData,[.3 .3 1]);
                    line(v(varIndex-numInputs)*[1 1],[-0.05 1.05], ...
                        'Color',[1 0 0], ...
                        'MarkerSize',12, ...
                        'LineWidth',3)
                else
                    % SUGENO system
                    set(gca, ...
                        'XLim',outRange, ...
                        'YLim',[-0.05 1.05], ...
                        'XTick',outRange, ...
                        'XColor','black','YColor','black')
                    lineHndl=line(v(varIndex-numInputs)*[1 1],[-0.05 1.05], ...
                        'Color',[1 0 0], ...
                        'MarkerSize',15, ...
                        'LineWidth',2);

                    xData=orr(:,varIndex-numInputs)';
                    xData=[xData; xData; NaN*ones(size(xData))];
                    yData=arr(:,varIndex-numInputs)';
                    yData=[zeros(size(yData)); yData; NaN*ones(size(yData))];

                    MFHndlMat(ruleIndex,varIndex)=line(xData(:),yData(:), ...
                        'LineWidth',4, ...
                        'UserData',lineHndl, ...
                        'Color',[.3 .3 1]);
                end
            end
        end
    end

    % The UserData will contain the varIndex to simplify 
    % calculations later on.
    set(inputDispHndl, ...
        'Value',inputVector, ...
        'String',[' ' mat2str(inputVector,4)]);

    % Get handles to axes for plotting
    frameName='dataframe';
    dataFrmHndl=findobj(figNumber,'Type','uicontrol', ...
        'Style','frame','Tag',frameName);
    set(dataFrmHndl,'UserData',MFHndlMat);

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');
 
    set(inputDispHndl,'Enable','on');
    watchoff(figNumber)

elseif strcmp(action,'#clickline'),
    %====================================
    figNumber=gcf;
    set(figNumber,'WindowButtonMotionFcn','ruleview #dragline');
    set(figNumber,'WindowButtonUpFcn','ruleview #updateinputs');
    ruleview #dragline

elseif strcmp(action,'#dragline'),
    %====================================
    lineHndl=gco;
    axHndl=get(lineHndl,'Parent');
    textHndl1=get(axHndl,'Title');
    ptMat=get(axHndl,'CurrentPoint');
    x=ptMat(1,1);
    xLims=get(axHndl,'XLim');
    if (x < xLims(1)),
        x=xLims(1);
    elseif (x > xLims(2)),
        x=xLims(2);
    end
    set(lineHndl,'XData',[x x]);
    oldtext = get(textHndl1, 'String');
    stopn=find(oldtext=='=');
    set(textHndl1,'String',[oldtext(1:stopn),' ', num2str(x(1),3)]);
% Uncomment the following lines if you want to see continuous update
% during a line drag
%    ruleview #updateinputs
%    set(figNumber,'WindowButtonMotionFcn','ruleview #dragline');
%    set(figNumber,'WindowButtonUpFcn','ruleview #updateinputs');

elseif strcmp(action,'#updateinputs'),
    %====================================
    figNumber=gcf;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
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

    if strcmp(get(gco,'Type'),'line'),
        % We're here because the moveable line indices have been moved
        lineHndl=gco;
        xData=get(lineHndl,'XData');
        varIndex=get(lineHndl,'UserData');
        inputDispHndl=findobj(figNumber,'Type','uicontrol','Tag','inputdisp');
        inputVector=get(inputDispHndl,'Value');
        inputVector(varIndex)=xData(1);
        set(inputDispHndl,'Value',inputVector);
        set(inputDispHndl,'String',[' ' mat2str(inputVector,4)]);    
    else
        % We're here because the input vector text field has been changed
        inputDispHndl=gco;

        % Error-checking
        % The backupInputVector is the previous (or safety) value
        backupInputVector=get(inputDispHndl,'Value');
        % Use try-catch eval statement to keep out ASCII trash

        newInputStr=get(inputDispHndl,'String');
        % We'll put the brackets in later; no point in dealing with the hassle
        index=[find(newInputStr=='[') find(newInputStr==']')];
        newInputStr(index)=32*ones(size(index));
        newInputStr=['[' newInputStr ']'];

        % Use eval try-catch to prevent really weird stuff...
        inputVector=eval(newInputStr,'backupInputVector');
        if length(inputVector)<numInputs,
            inputVector=backupInputVector;
        else
            inputVector=inputVector(1:numInputs);
        end

        for i=1:numInputs
         inRange(i, 1:2)=fis.input(i).range;
        end
        
        for count=1:numInputs,
            % Find the appropriate index line
            indexLineHndl=findobj(figNumber, ...
                'Type','line','Tag','indexline','UserData',count);
            textHndl=get(get(indexLineHndl,'Parent'),'Title');
            xLims=inRange(count,:);

            % Check to make sure each input is within its limits
            if (inputVector(count) < xLims(1)),
                inputVector(count)=xLims(1);
            elseif (inputVector(count) > xLims(2)),
                inputVector(count)=xLims(2);
            end
            set(indexLineHndl,'XData',inputVector(count)*[1 1]);
            oldtext=get(textHndl,'String');
            textn=find(oldtext=='=');
            set(textHndl,'String',[oldtext(1:textn), ' ', num2str(inputVector(count),3)]);
        end

        set(inputDispHndl,'Value',inputVector);
        set(inputDispHndl,'String',[' ' mat2str(inputVector,4)]);
    end
   
    % Get handles to axes for plotting
    frameName='dataframe';
    dataFrmHndl=findobj(figNumber,'Type','uicontrol', ...
        'Style','frame','Tag',frameName);
    MFHndlMat=get(dataFrmHndl,'UserData');

    % Remove the button motion and button up functions
    set(figNumber,'WindowButtonMotionFcn',' ');
    set(figNumber,'WindowButtonUpFcn',' ');
    numPts=101;
    pthndl=findobj(gcf, 'Tag', 'numdisp');
    temp=str2double(get(pthndl, 'String'));
    if ~isempty(temp) & temp>=101
      numPts=temp;
    end

    [v,IRR,ORR,ARR]=evalfis(inputVector,fis, numPts);
    numRules=length(fis.rule);
    fisType=fis.type;
    %====================================
    % Update INPUTS (we only need to update ONE of the inputs)
    for ruleIndex=1:numRules,
        for varIndex=1:numInputs,
            % If the handle is zero, then the plot doesn't exist, so
            % don't mess with anything
            if MFHndlMat(ruleIndex,varIndex),
                axHndl=get(MFHndlMat(ruleIndex,varIndex),'Parent');
                lineHndl=findobj(axHndl,'Type','line');
                yData=get(lineHndl,'YData');
                yData=min(yData,IRR(ruleIndex,varIndex));
                yData=[0 yData 0];

                set(MFHndlMat(ruleIndex,varIndex), ...
                    'YData',yData);
            end
        end
    end

    %====================================
    % Update OUTPUTS
    if strcmp(fisType,'mamdani'),
        % MAMDANI system
        % Update individual rule output displays (implication)
        for ruleIndex=1:numRules
            for varIndex=(1:numOutputs)+numInputs,
                yData=ORR(:,ruleIndex+(varIndex-numInputs-1)*numRules);
                yData=[0 yData' 0];
                lineHndl=MFHndlMat(ruleIndex,varIndex);
                if ruleIndex==1
                  axHndl=findobj(gcbf, 'Tag', ['output' num2str(varIndex-numInputs)]);
                  titleHndl=get(axHndl,'Title');
                  oldtext=get(titleHndl,'String');
                  if ~isempty(oldtext)
                    textn=find(oldtext=='=');
                  else
                    textn=[];
                  end
                  set(titleHndl,'Visible', 'on', 'String',[oldtext(1:textn), ' ', num2str(v(varIndex-numInputs),3)], 'fontSize', 8);
                end
                if lineHndl,
                    % Don't update it if it doesn't exist
                    set(lineHndl,'YData',yData);
                end
            end
        end

        % Update aggregate output display
        for varIndex=(1:numOutputs)+numInputs,
            patchHndl=MFHndlMat(numRules+1,varIndex);
            axHndl=get(patchHndl,'Parent');
            yData=ARR(:,varIndex-numInputs);
            yData=[0 yData' 0];
            set(patchHndl, ...
                'YData',yData);
            lineHndl=findobj(axHndl,'Type','line');
            set(lineHndl,'XData',v(varIndex-numInputs)*[1 1]);
        end
    else
        % SUGENO system
        for ruleIndex=1:numRules
            for varIndex=(1:numOutputs)+numInputs,
                thickLineHndl=MFHndlMat(ruleIndex,varIndex);
                % Don't update it if it doesn't exist
                if thickLineHndl,
                    thinLineHndl=get(MFHndlMat(ruleIndex,varIndex),'UserData');
                    xData2=[1 1]*ORR(ruleIndex,varIndex-numInputs);
                    set(thinLineHndl,'XData',xData2);
                    yData=[0 1]*ARR(ruleIndex,varIndex-numInputs);
                    set(MFHndlMat(ruleIndex,varIndex), ...
                        'XData',xData2,'YData',yData);
                if ruleIndex==1
                  axHndl=get(thinLineHndl,'Parent');
                  titleHndl=get(axHndl,'Title');
                  oldtext=get(titleHndl,'String');
                  textn=find(oldtext=='=');
                  set(titleHndl,'Visible', 'on', 'String',[oldtext(1:textn), ' ', num2str(v(varIndex-numInputs),3)]);
                end
                end
            end
        end

        % Update aggregate output display
        for varIndex=(1:numOutputs)+numInputs,
            xData=ORR(:,varIndex-numInputs)';
            xData=[xData; xData; NaN*ones(size(xData))];
            yData=ARR(:,varIndex-numInputs)';
            yData=[zeros(size(yData)); yData; NaN*ones(size(yData))];

            lineHndl1=MFHndlMat(numRules+1,varIndex);
            set(lineHndl1, ...
                'XData',xData(:),'YData',yData(:));

            % Now reposition the output index line
            lineHndl2=get(lineHndl1,'UserData');
            xData2=v(varIndex-numInputs)*[1 1];
            set(lineHndl2,'XData',xData2);
        end
    end

elseif strcmp(action,'#patchclick'),
    %====================================
    patchHndl=gco;
    figNumber=gcf;
    axHndl=get(patchHndl,'Parent');
    lineHndl=findobj(axHndl,'Type','line');
    set(figNumber,'CurrentObject',lineHndl);
    ruleview #clickline

elseif strcmp(action,'#input'),
    %====================================
    inputHndl=gco;
    figNumber=gcf;

elseif strcmp(action,'#disprule'),
    %====================================
    % Display the rule that the user has clicked on
    txtHndl=gco;
    figNumber=gcf;
    selectColor=[1 0 0];

    % Find and reset any previously highlighted rules
    oldTxtHndl=findobj(figNumber,'Type','text','Tag','rulelabel','FontSize',14);
    if length(oldTxtHndl)>0,
        set(oldTxtHndl,'Color','black','FontSize',8,'FontWeight','normal');
    end
    set(txtHndl,'Color',selectColor,'FontSize',14,'FontWeight','bold');

    % Find out what display format is preferred
    formatHndl=findobj(figNumber,'Type','uimenu','Tag','dispformat');
    dispFormat=get(findobj(formatHndl,'Checked','on'),'Tag');
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
    ruleIndexStr=get(txtHndl,'String');
    ruleIndex=str2double(ruleIndexStr);
    if strcmp(dispFormat,'indexed'),
        ruleStr=['Rule ' num2str(ruleIndex) '. ' showrule(fis,ruleIndex,'indexed')];
    else
        ruleStr=['Rule ' showrule(fis,ruleIndex,dispFormat)];
    end
    % The next line is a workaround to make sure that the "|" character will display
    % properly in a text uicontrol
    ruleStr=str2mat(ruleStr,' ');
    statmsg(figNumber,ruleStr);

elseif strcmp(action,'#dispformat');
    %====================================
    figNumber=watchon;
    currHndl=gcbo;
    verHndl=findobj(figNumber,'Type','uimenu','Tag','verbose');
    symHndl=findobj(figNumber,'Type','uimenu','Tag','symbolic');
    indHndl=findobj(figNumber,'Type','uimenu','Tag','indexed');
    set([verHndl symHndl indHndl],'Checked','off');
    set(currHndl,'Checked','on');
    watchoff(figNumber)
elseif strcmp(action, '#shiftleft')
    axesHndl=findobj(gcbf, 'Type','axes');
    pos=get(axesHndl, 'Position');
    for i=1:length(pos)
     set(axesHndl(i), 'Position', pos{i}-[.05 0 0 0]);
    end
elseif strcmp(action, '#shiftright')
    axesHndl=findobj(gcbf, 'Type','axes');
    pos=get(axesHndl, 'Position');
    for i=1:length(pos)
     set(axesHndl(i), 'Position', pos{i}+[.05 0 0 0]);
    end
elseif strcmp(action, '#shiftup')
    axesHndl=findobj(gcbf, 'Type','axes');
    pos=get(axesHndl, 'Position');
    for i=1:length(pos)
     set(axesHndl(i), 'Position', pos{i}+[0 0.05 0 0]);
    end
elseif strcmp(action, '#shiftdown')
    axesHndl=findobj(gcbf, 'Type','axes');
    pos=get(axesHndl, 'Position');
    for i=1:length(pos)
     set(axesHndl(i), 'Position', pos{i}-[0 .05 0 0]);
    end
elseif strcmp(action, '#slidehori')
    Hndl=gcbo;
    value=get(gcbo, 'Value');
    axesHndl=findobj(gcbf, 'Type','axes');
    pos=get(axesHndl, 'Position');
    for i=1:length(pos)
     newpos=pos{i};
     newpos(1)=value;
     set(axesHndl(i), 'Position', newpos);
    end

elseif strcmp(action,'#help');
    figNumber=watchon;
     helpwin(mfilename);
    watchoff(figNumber)
elseif strcmp(action,'#simulink');
%    figNumber=gcf;
    oldfis=get(figNumber,'UserData');
    fis=oldfis{1};
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

        % We're here because the input vector text field has been changed

        % Error-checking
        % The backupInputVector is the previous (or safety) value
        % Use try-catch eval statement to keep out ASCII trash

        inputVector=input;

        for i=1:numInputs
         inRange(i, 1:2)=fis.input(i).range;
        end
        
        for count=1:numInputs,
            % Find the appropriate index line
            indexLineHndl=findobj(figNumber, ...
                'Type','line','Tag','indexline','UserData',count);
            textHndl=get(get(indexLineHndl,'Parent'),'title');
            xLims=inRange(count,:);

            % Check to make sure each input is within its limits
            if (inputVector(count) < xLims(1)),
                inputVector(count)=xLims(1);
            elseif (inputVector(count) > xLims(2)),
                inputVector(count)=xLims(2);
            end
            set(indexLineHndl,'XData',inputVector(count)*[1 1]);
            oldtext=get(textHndl,'String');
            textn=find(oldtext=='=');
            set(textHndl,'String',[oldtext(1:textn), ' ', num2str(inputVector(count),3)]);

            set(indexLineHndl,'XData',inputVector(count)*[1 1]);
%            set(textHndl,'String',num2str(inputVector(count),3), 'Visible', 'on');
        end
        inputDispHndl=findobj(figNumber, 'Tag', 'inputdisp');
        set(inputDispHndl,'Value',inputVector);
        set(inputDispHndl,'String',[' ' mat2str(inputVector,4)]);

   
    % Get handles to axes for plotting
    frameName='dataframe';
    dataFrmHndl=findobj(figNumber,'Type','uicontrol', ...
        'Style','frame','Tag',frameName);
    MFHndlMat=get(dataFrmHndl,'UserData');

    % Remove the button motion and button up functions
    set(figNumber,'WindowButtonMotionFcn',' ');
    set(figNumber,'WindowButtonUpFcn',' ');
    numPts=101;
    pthndl=findobj(gcf, 'Tag', 'numdisp');
    tempstr=get(pthndl, 'String');
    temp=[];
    if ~isempty(tempstr)
     temp=str2double(get(pthndl, 'String'));
    end
    if ~isempty(temp) & temp>=101
      numPts=temp;
    end
    [v,IRR,ORR,ARR]=evalfis(inputVector,fis, numPts);
    numRules=length(fis.rule);
    fisType=fis.type;
   %====================================
    % Update INPUTS (we only need to update ONE of the inputs)
    for ruleIndex=1:numRules,
        for varIndex=1:numInputs,
            % If the handle is zero, then the plot doesn't exist, so
            % don't mess with anything
            if MFHndlMat(ruleIndex,varIndex),
                axHndl=get(MFHndlMat(ruleIndex,varIndex),'Parent');
                lineHndl=findobj(axHndl,'Type','line');
                yData=get(lineHndl,'YData');
                yData=min(yData,IRR(ruleIndex,varIndex));
                yData=[0 yData 0];

                set(MFHndlMat(ruleIndex,varIndex), ...
                    'YData',yData);
            end
        end
    end

    %====================================
    % Update OUTPUTS
    if strcmp(fisType,'mamdani'),
        % MAMDANI system
        % Update individual rule output displays (implication)
        for ruleIndex=1:numRules
            for varIndex=(1:numOutputs)+numInputs,
                yData=ORR(:,ruleIndex+(varIndex-numInputs-1)*numRules);
                yData=[0 yData' 0];
                lineHndl=MFHndlMat(ruleIndex,varIndex);
                if ruleIndex==1
                  axHndl=get(lineHndl,'Parent');
                  titleHndl=get(axHndl,'Title');
                  oldtext=get(titleHndl,'String');
                  textn=find(oldtext=='=');
                  set(titleHndl, 'String',[oldtext(1:textn), ' ', num2str(v(varIndex-numInputs),3)], 'fontSize', 8);
                end
                if lineHndl,
                    % Don't update it if it doesn't exist
                    set(lineHndl,'YData',yData);
                end
            end
        end

        % Update aggregate output display
        for varIndex=(1:numOutputs)+numInputs,
            patchHndl=MFHndlMat(numRules+1,varIndex);
            axHndl=get(patchHndl,'Parent');
            yData=ARR(:,varIndex-numInputs);
            yData=[0 yData' 0];
            set(patchHndl, ...
                'YData',yData);
            lineHndl=findobj(axHndl,'Type','line');
            set(lineHndl,'XData',v(varIndex-numInputs)*[1 1]);
        end
    else
        % SUGENO system
        for ruleIndex=1:numRules
            for varIndex=(1:numOutputs)+numInputs,
                thickLineHndl=MFHndlMat(ruleIndex,varIndex);
                % Don't update it if it doesn't exist
                if thickLineHndl,
                    thinLineHndl=get(MFHndlMat(ruleIndex,varIndex),'UserData');
                    xData2=[1 1]*ORR(ruleIndex,varIndex-numInputs);
                    set(thinLineHndl,'XData',xData2);
                    yData=[0 1]*ARR(ruleIndex,varIndex-numInputs);
                    set(MFHndlMat(ruleIndex,varIndex), ...
                        'XData',xData2,'YData',yData);
                end
                if ruleIndex==1
                  axHndl=get(thickLineHndl,'Parent');
                  titleHndl=get(axHndl,'Title');
                  oldtext=get(titleHndl,'String');
                  textn=find(oldtext=='=');
                  set(titleHndl, 'String',[oldtext(1:textn), ' ', num2str(v(varIndex-numInputs),3)], 'fontSize', 8);
                end
            end
        end

        % Update aggregate output display
        for varIndex=(1:numOutputs)+numInputs,
            xData=ORR(:,varIndex-numInputs)';
            xData=[xData; xData; NaN*ones(size(xData))];
            yData=ARR(:,varIndex-numInputs)';
            yData=[zeros(size(yData)); yData; NaN*ones(size(yData))];

            lineHndl1=MFHndlMat(numRules+1,varIndex);
            set(lineHndl1, ...
                'XData',xData(:),'YData',yData(:));

            % Now reposition the output index line
            lineHndl2=get(lineHndl1,'UserData');
            xData2=v(varIndex-numInputs)*[1 1];
            set(lineHndl2,'XData',xData2);
        end
    end
       
end;    % if strcmp(action, ...
