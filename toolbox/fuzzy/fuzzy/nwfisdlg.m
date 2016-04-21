function mfdlg(action)
%MFDLG Create dialog for generating new fis with data.
%   MFDLG(action,fisMatrix,varType,varIndex) will open a dialog
%   box for fisMatrix using the default MF type 'trimf'.
%   varType and varIndex indicate exactly which variable you
%   want to add membership functions to.

%   Kelly Liu 1-2-97
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/14 22:22:41 $

if ~isstr(action),
    % For initialization, the fis matrix is passed in as the parameter
    oldFigNumber=action;
    action='#initialize';
end;

if strcmp(action,'#initialize'),
    fisType=fis.type;
    labelStr='Add membership functions';
    popupLabel1='MF type';
    popupLabel2='Number of MFs';

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    border=6;
    spacing=6;
    figPos=get(0,'DefaultFigurePosition');
    figPos(3:4)=[360 160];
    maxRight=figPos(3);
    maxTop=figPos(4);
    btnWid=160;
    btnHt=23;
 
    %====================================
    % The FIGURE
    figNumber=figure( ...
        'NumberTitle','off', ...
        'Color',[0.9 0.9 0.9], ...
        'Visible','off', ...
        'MenuBar','none', ...
        'UserData',fis, ...
        'Units','pixels', ...
        'Position',figPos, ...
        'BackingStore','off');
    figPos=get(figNumber,'position');

    %====================================
    % The MAIN frame 
    top=maxTop-border;
    bottom=border; 
    right=maxRight-border;
    left=border;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
    right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 1 1 1];
    mainFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %====================================
    % The UPPER frame 
    top=maxTop-spacing-border;
    bottom=border+8*spacing+3*btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
    right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    varFrmHndl=uicontrol( ...
        'Units','pixel', ...
        'Style','frame', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    varSpacing=(top-bottom-2*btnHt);
    %------------------------------------
    % The STRING text field
    n=1;
    labelStr=labelStr;
    pos=[left top-btnHt*n-varSpacing*(n-1) right-left btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'BackgroundColor',frmColor, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'String',labelStr);

    %====================================
    % The POPUP frame 
    bottom=border+4*spacing+btnHt;
    top=bottom+2*btnHt+spacing;
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
    % The POPUP text field
    labelStr=popupLabel1;
    pos=[left top-btnHt btnWid btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'String',labelStr);

    %------------------------------------
    % The POPUP field
    if strcmp(fisType,'sugeno') & strcmp(varType,'output'),
        menuTxt=str2mat(' constant',' linear');
    else
        menuTxt=str2mat(' trimf',' trapmf',' gbellmf',' gaussmf',' gauss2mf',' pimf');
        menuTxt=str2mat(menuTxt,' dsigmf',' psigmf');
    end
    pos=[right-btnWid top-btnHt btnWid btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','popupmenu', ...
        'String',menuTxt, ...
        'UserData',varType, ...
        'Tag','mftype', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',popupColor);

    %------------------------------------
    % The POPUP text field
    labelStr=popupLabel2;
    pos=[left top-2*btnHt-spacing btnWid btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'String',labelStr);

    %------------------------------------
    % The POPUP field
    menuTxt=str2mat(' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9');
    pos=[right-btnWid top-2*btnHt-spacing btnWid btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','popupmenu', ...
        'String',menuTxt, ...
        'Tag','mfnumber', ...
        'UserData',varIndex, ...
        'Value',3, ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',popupColor);

    %====================================
    % The CLOSE frame 
    bottom=border+spacing;
    top=bottom+btnHt;
    right=maxRight-border-spacing;
    left=border+spacing;
    frmBorder=spacing;
    frmPos=[left-frmBorder bottom-frmBorder ...
    right-left+frmBorder*2 top-bottom+frmBorder*2]+[1 0 1 0];
    clsFrmHndl=uicontrol( ...
        'Style','frame', ...
        'Units','pixel', ...
        'Position',frmPos, ...
        'BackgroundColor',frmColor);

    %------------------------------------
    % The CANCEL button
    labelStr='Cancel';
    callbackStr='close(gcf)';
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Position',[left bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'Callback',callbackStr);

    %------------------------------------
    % The OKAY button
    labelStr='OK';
    callbackStr='mfdlg #okay';

    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position',[right-btnWid bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String',labelStr, ...
        'UserData',oldFigNumber, ...
        'Callback',callbackStr);

    % Normalize all coordinates
    hndlList=findobj(figNumber,'Units','pixels');
    set(hndlList,'Units','normalized');

    % Uncover the figure
    set(figNumber, ...
        'Visible','on');

elseif strcmp(action,'#okay'),
    figNumber=gcf;
    oldFigNumber=get(gco,'UserData');

    mfTypeHndl=findobj(figNumber,'Tag','mftype');
    mfNumHndl=findobj(figNumber,'Tag','mfnumber');
    mfTypeList=get(mfTypeHndl,'String');
    mfTypeVal=get(mfTypeHndl,'Value');
    varType=get(mfTypeHndl,'UserData');
    mfType=deblank(mfTypeList(mfTypeVal,:));
    mfType=fliplr(deblank(fliplr(mfType)));
    mfNum=get(mfNumHndl,'Value');
    varIndex=get(mfNumHndl,'UserData');

    fis=get(figNumber,'UserData');
    fisType=fis.type;
    varRange=eval(['fis.' varType '(' num2str(varIndex) ').range']);
    if strcmp(fisType,'sugeno') & strcmp(varType,'output'),
        % Handle sugeno case
        if mfNum==1,
            mfParams=mean(varRange);
            mfName='mf1';
            if strcmp(mfType, 'constant')
               fis=addmf(fis,varType,varIndex,mfName,'constant',mfParams);
            elseif strcmp(mfType,'linear'),
                in_n=length(fis.input);
                mfParams1(1:in_n)=0;
                mfParams1(in_n+1)=mfParams;
                fis=addmf(fis,varType,varIndex,mfName,'linear',mfParams1);
            end
        else
            halfWidth=diff(varRange)/(mfNum-1);
            for count=1:mfNum,
                a=(count-1)*halfWidth+varRange(1);
                mfParams=a;
                mfName=['mf' num2str(count)];
                if strcmp(mfType, 'constant')
                  fis=addmf(fis,varType,varIndex,mfName,'constant',mfParams);
                elseif strcmp(mfType,'linear'),
                  in_n=length(fis.input);
                  mfParams1(1:in_n)=0;
                  mfParams1(in_n+1)=mfParams;
                  fis=addmf(fis,varType,varIndex,mfName,'linear',mfParams1);
                end
            end
        end
    else
        % This is an input or a mamdani output
        if mfNum==1,
            tol=1e-3*(varRange(2)-varRange(1));
            mfParams=mf2mf([varRange(1) mean(varRange) varRange(2)],'trimf',mfType,tol);
            mfName='mf1';
            fis=addmf(fis,varType,varIndex,mfName,mfType,mfParams);
        else
            halfWidth=diff(varRange)/(mfNum-1);
            for count=1:mfNum,
                b=(count-1)*halfWidth+varRange(1);
                a=b-halfWidth;
                c=b+halfWidth;
                tol=1e-3*(varRange(2)-varRange(1));
                mfParams=mf2mf([a b c],'trimf',mfType,tol);
                mfName=['mf' num2str(count)];
                fis=addmf(fis,varType,varIndex,mfName,mfType,mfParams);
            end
        end
    end

    close(figNumber);
    figure(oldFigNumber);

    % Push the change onto the undo stack and update all related GUI tools
    pushundo(oldFigNumber,fis);
    updtfis(oldFigNumber,fis,[]);

    mfedit('#update',varType,varIndex)
end
