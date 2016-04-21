function editmenufcn(hfig, cmd)
%EDITMENUFCN Implements part of the figure edit menu.
%  EDITMENUFCN(CMD) invokes edit menu command CMD on figure GCBF.
%  EDITMENUFCN(H, CMD) invokes edit menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    EditUndo
%    EditCut
%    EditCopy
%    EditPaste
%    EditClear
%    EditSelectAll
%    EditPinning
%    EditCopyOptions
%    EditCopyFigure
%    EditFigureProperties
%    EditAxesProperties
%    EditObjectProperties
%    EditColormap

%    EditPost - internal use only

%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 1.7.4.10 $  $Date: 2004/04/10 23:33:33 $

error(nargchk(1,2,nargin))

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

switch cmd
    case 'EditPost'
        localPost(hfig);
    case 'EditUndo'
        uimenufcn(hfig, 'EditUndo');
    case 'EditCut'
        plotedit(hfig,'Cut');
    case 'EditCopy'
        plotedit(hfig,'Copy');
    case 'EditPaste'
        plotedit(hfig,'Paste');
    case 'EditClear'
        plotedit(hfig,'Clear');
    case 'EditSelectAll'
        plotedit(hfig,'SelectAll');
    case 'EditCopyOptions'
        preferences(xlate('Figure Copy Template.Copy Options'))
    case 'EditCopyFigure'
        uimenufcn(hfig, 'EditCopyFigure')
    case 'EditFigureProperties'
        % domymenu menubar figureprop
        propedit(hfig);
    case 'EditAxesProperties'
        % domymenu menubar axesprop
        ax = get(hfig,'currentaxes');
        if ~isempty(ax)
           propedit(ax);
        end
    case 'EditObjectProperties'
        obj = get(hfig,'CurrentObject');
        if isempty(obj) || ~ishandle(obj)
            % use scribe current object if one exists and if scribe is on
            if strcmpi(getappdata(hfig,'scribeActive'),'on')
                scribeax = handle(findall(hfig,'Tag','scribeOverlay'));
                if ~isempty(scribeax) && ~isempty(scribeax.CurrentShape)
                    obj = double(scribeax.CurrentShape);
                end
            end
            % if still empty use figure
            if isempty(obj) || ~ishandle(obj)
                obj = hfig;
            end
        end
        if strcmpi(get(obj,'Type'),'figure') || ~isappdata(obj,'ScribeGroup')
            propedit(obj);
        elseif isappdata(obj,'ScribeGroup')
            scribeobj = getappdata(obj,'ScribeGroup');
            propedit(scribeobj);
        end
    case 'EditColormap'
        colormapeditor(hfig);        
    case 'EditFindFiles'
        com.mathworks.mde.find.FindFiles.invoke;
    case 'EditClearFigure'
        clf(hfig);
    case 'EditClearCommandWindow'
        clc;
    case 'EditClearCommandHistory'
        localEditClearCommandHistory(hfig);     
    case 'EditClearWorkspace'
        localEditClearWorkspace(hfig);    
end

% --------------------------------------------------------------------
function  [jframe] = localGetJavaFrame(hfig)
% Get java frame for figure window

jframe = [];
jpeer = get(hfig,'JavaFrame');
if ~isempty(jpeer)
   jcanvas = jpeer.getAxisComponent; 
   jframe = javax.swing.SwingUtilities.getWindowAncestor(jcanvas);
end

%--------------------------------------------------------%
function localEditClearWorkspace(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getClearWorkspaceAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

%--------------------------------------------------------%
function localEditClearCommandHistory(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getClearHistoryAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

%--------------------------------------------------------%
function localPost(hfig)

% The first time the EditPost callback is called, hide any
% non-functional items on Unix.
% Also, if necessary, enable or disable any items on the editmenu
% based on their context.
        
edit = findall(allchild(hfig),'type','uimenu','Tag','figMenuFile');

if ~ispc
    set(findall(edit,'label','Copy &Figure'),'visible','off');
    set(findall(edit,'label','Copy &Options...'),'visible','off');
    set(findall(edit,'label','Cu&t'),'separator','off');
    % hide non-functional unix items
end
        
if ~usejava('mwt')
    %There are no r11 property editors for figure and most axes children,
    %so disable the figure and current object edit options on the figure
    %menu
    set(findall(edit,'tag','figMenuEditGCA'),'separator','on');
    set(findall(edit,'tag','figMenuEditGCO'),'visible','off');
end
        
% Hide callbacks that require a java frame
if isempty(get(hfig,'JavaFrame'))
    set(findall(edit,'tag','figMenuEditClearCmdWindow'),'visible','off');
    set(findall(edit,'tag','figMenuEditClearCmdHistory'),'visible','off');      
end

plotedit({'update_edit_menu',hfig,false});        
drawnow;