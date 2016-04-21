function wsdlg(action,varName,dlgOption,figNumber)
%WSDLG Create dialog for loading/saving FIS in workspace.
%   WSDLG(action,varName,dlgOption) creates a dialog box for either
%   saving to or reading from the workspace.
%
%   The FIS matrix is given the default workspace variable name varName.
%   The last input argument dlgOption defines whether or not you're passing
%   data into the workspace or out of it.

%   Ned Gulley, 9-15-94,  P. Gahinet 6/2000
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.25 $  $Date: 2002/04/14 22:23:13 $

if ~isstr(action),
    % For initialization, the fis matrix is passed in as the parameter
    fis=action;
    action='#initialize';
end;

switch action
case '#initialize'
    if strcmp(dlgOption,'gui2ws'), 
        labelStr='Save current FIS to workspace';
    else
        labelStr='Load FIS from workspace';
    end
    editLabel='Workspace variable';

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
    figHandle=figure( ...
        'NumberTitle','off', ...
        'Color',[0.9 0.9 0.9], ...
        'Visible','off', ...
        'MenuBar','none', ...
        'UserData',fis, ...
        'Units','pixels', ...
        'Position',figPos, ...
        'Tag','gui2ws', ...
        'IntegerHandle','off',...
        'HandleVisibility','callback',...
        'BackingStore','off');
    figPos=get(figHandle,'position');
    centerfig(figHandle,figNumber); 

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
    varName=deblank(varName);
    varName=fliplr(deblank(fliplr(varName)));
    varName(find(varName==32))=95*ones(size(find(varName==32)));
    varName=[' ' varName];
    pos=[right-btnWid top-btnHt btnWid btnHt];
    inputVarNameHndl=uicontrol( ...
        'Units','pixel', ...
        'Style','edit', ...
        'String',varName, ...
        'Callback','wsdlg #varname', ...
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
    infoHndl=uicontrol( ...
        'Style','push', ...
        'Position', [right-btnWid bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String','Cancel', ...
        'Callback','close(gcf)');

    %------------------------------------
    % The OKAY button
    if strcmp(dlgOption,'gui2ws'), 
        % Write FIS to workspace
        Callback = {@LocalWriteFIS figHandle inputVarNameHndl};
    else
        % Read FIS from workspace
        Callback = {@LocalReadFIS figHandle inputVarNameHndl};
    end

    closeHndl=uicontrol( ...
        'Style','push', ...
        'Position', [left bottom btnWid btnHt], ...
        'BackgroundColor',btnColor, ...
        'String','OK', ...
        'Callback',Callback);

    % Normalize all coordinates
    hndlList=findobj(figHandle,'Units','pixels');
    set(hndlList,'Units','normalized');

    % Uncover the figure
    set(figHandle,'Visible','on');

case '#varname'
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


%------------------- Local functions

function LocalReadFIS(hSrc,event,figHandle,editHandle)
% Opens a new FIS Editor initialized with specified FIS

fisName = get(editHandle,'String');
fis = evalin('base',fisName,'[]');
if ~isfis(fis)
    errordlg(sprintf('Expression "%s" does not evaluate to a valid FIS',fisName),...
        'FIS Editor Error','modal')
else
    % Close dialog
    close(figHandle)
    % Open a new FIS Editor initialize with specified FIS
    fuzzy(fis);
end

%%%%%%%%%%%%%%%%%%%%

function LocalWriteFIS(hSrc,event,figHandle,editHandle)
% Write FIS variable in workspace
NewName = fliplr(deblank(fliplr(deblank(get(editHandle,'String')))));

if ~isvarname(NewName)
    errordlg(sprintf('Invalid variable name "%s"',NewName),...
        'FIS Editor Error','modal')
else
    % Assign in workspace
    fis = get(figHandle,'UserData');
    OldName = fis.name;
    fis.name = NewName;
    assignin('base',NewName,fis);
    % Update FIS Editor name
	fisgui('#fisname',OldName,NewName);
    % Close dialog
    close(figHandle)
end