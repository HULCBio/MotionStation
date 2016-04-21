function cmthdlg(action,fis,methodType)
%CMTHDLG Create dialog for adding customized inference methods.
%   CMTHDLG(action,fis,methodType) opens a dialog box that 
%   allows you to add your own inference method to a fuzzy 
%   inference system.

%   Ned Gulley, 9-15-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/14 22:20:17 $

if ~isstr(action),
    % For initialization, the fis matrix is passed in as the parameter
    oldFigNumber=action;
    action='#initialize';
end;

if strcmp(action,'#initialize'),
    methodType2=strrep(methodType,'method',' method');
    labelStr=['Add customized ' methodType2];
    editLabel='Method name';
    editText=' newmethod';

    %===================================
    % Information for all objects
    frmColor=192/255*[1 1 1];
    btnColor=192/255*[1 1 1];
    popupColor=192/255*[1 1 1];
    editColor=255/255*[1 1 1];
    border=6;
    spacing=6;
    figPos=get(0,'DefaultFigurePosition');
    figPos(3:4)=[360 130];
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
        'Tag','gui2ws', ...
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
    bottom=border+7*spacing+2*btnHt;
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
    % The EDIT FIELD frame 
    bottom=border+4*spacing+btnHt;
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
    % The EDIT text field
    labelStr=editLabel;
    pos=[left top-btnHt btnWid btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','text', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',frmColor, ...
        'String',labelStr);

    %------------------------------------
    % The EDIT field
    callbackStr='cmthdlg #methodname';
    pos=[right-btnWid top-btnHt btnWid btnHt];
    uicontrol( ...
        'Units','pixel', ...
        'Style','edit', ...
        'String',editText, ...
        'UserData',methodType, ...
        'Callback',callbackStr, ...
        'Tag','edit', ...
        'HorizontalAlignment','left', ...
        'Position',pos, ...
        'BackgroundColor',editColor);

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
    callbackStr='cmthdlg #okay';

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
    editHndl=findobj(gcf,'Tag','edit');
    methodName=get(editHndl,'String');
    methodName=deblank(methodName);
    methodName=fliplr(deblank(fliplr(methodName)));
    methodType=get(editHndl,'UserData');
    oldFigNumber=get(gco,'UserData');
    fis=get(figNumber,'UserData');
    fis = setfield(fis,methodType,methodName);
    close(figNumber);

    % Push the change onto the undo stack and update all related GUI tools
    pushundo(oldFigNumber,fis);
    updtfis(oldFigNumber,fis,[1 4 5]);

elseif strcmp(action,'#methodname'),

    % Every time the edit field is changed,
    % the new string is automatically deblanked front and back, replaced with 'null'
    % if it's empty, and reinserted.
    s=get(gco,'String');
    s=deblank(s);
    s=fliplr(deblank(fliplr(s)));
    if isempty(s), 
        s='null'; 
    end;
    s(find(s==32))=95*ones(size(find(s==32)));
    set(gco,'String',[' ' s]);

end
