function xpcmngrGUI(varargin)
%XPCMNGRGUI xPC Target GUI
%   XPCMNGRGUI creates the user interface components for the xPC Manager
%   GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $

Action = varargin{1};
args   = varargin(2:end);
Action;

switch Action,
   
case 'InitGUI'    
     set(0,'showhiddenhandles','on');
     xpcmngrfigH=findobj(0,'Type','Figure','Tag','xpcmngr');
     xpcmngrUserData=get(xpcmngrfigH,'UserData');
     set(0,'showhiddenhandles','off');
     if ~isempty(xpcmngrfigH)
         figure(xpcmngrfigH)
         return
     end     
     xpcmngrUserData=createxPXMngrUsrData;
     xpcmngrUserData=i_createMainFrame(xpcmngrUserData);
     set(xpcmngrUserData.figure,'Resizefcn',@i_resizeMainFrame)
     openxpcmngrTargetConfig(xpcmngrUserData.treeCtrl)
     xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.root,xpcmngrUserData);
     %set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',['DLM(s) ',pwd])
     set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)    
     start(xpcmngrUserData.timerObj)
     
case 'ResizeGUI'
     figH=args{1};
     i_resizeMainFrame(figH,[]);
     return
case 'CloseGUI'
    figH=args{1};
    xpcmngrUserData=get(figH,'UserData');
    savexpcmngrTargetConfig(xpcmngrUserData.treeCtrl)
   % stop(xpcmngrUserData.timerObj)
    if isappdata(0,'scmenupref')
        rmappdata(0,'scmenupref')
    end
    if isappdata(0,'xpcTargetexplrEnv')
        rmappdata(0,'xpcTargetexplrEnv')  
    end
    stop(xpcmngrUserData.timerObj)
    delete(xpcmngrUserData.timerObj)
    delete(figH);
    set(0,'showhiddenhandles','on');
    xpcmngrfigScH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
    %xpcmngrUserData=get(xpcmngrfigH,'UserData');
    set(0,'showhiddenhandles','off');
    if ~isempty(xpcmngrfigScH)
        delete(xpcmngrfigScH)
    end
    
    clear all
    %this is a work around to geck
    
    return    
%case 'NodeContextMenu'

otherwise,
    error(['Invalid action: ' Action]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                     *
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xpcmngrUserData]=i_createMainFrame(xpcmngrUserData)
%feature('Javafigures',1)
rootUnits=get(0,'Units');
set(0,'Units','Pixels')
scSize=get(0,'ScreenSize');
figPos=[scSize(3)*0.2 ...
        scSize(4)*0.25 ...
        scSize(3)*0.75 ...
        scSize(4)*0.6];
%figPos=[ 520   590   960   420];            
set(0,'Units',rootUnits);
xpcmngrUserData.figure = figure(  ...
    'Name','xPC Target Explorer Beta Version 1', ...
    'NumberTitle','off', ...
    'IntegerHandle', 'off', ...
    'MenuBar', 'none', ...
    'CloseRequestFcn', 'xpcmngrGUI(''CloseGUI'',gcbf);', ...
    'Resize','On',...
    'KeyPressFcn',@xpcmngrShortcuts,...
    'Renderer','painters',...
    'Tag','xpcmngr',...
    'Renderer','Zbuffer',...
    'HandleVisibility','callback',...
    'Visible','off',...
    'Position',figPos,...
    'Color', get(0,'DefaultUicontrolBackgroundColor'));

%set(xpcmngrUserData.figure,'WindowButtonMotionFcn','xpcmngr(''WinMouseMove'',gcbf);');  
%set(xpcmngrUserData.figure,'Resizefcn','xpcmngrGUI(''ResizeGUI'',gcbf)');
xpcmngrUserData = i_createMainFrameComponets(xpcmngrUserData);
set(xpcmngrUserData.figure,'UserData',xpcmngrUserData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createMainFrameComponets(xpcmngrUserData)
figH=xpcmngrUserData.figure;
%xpcmngrUserData=get(figH,'UserData');
fpos=get(figH,'Position');
xpcmngrUserData=xpcmngrProcessMenu('CreateMainMenu',xpcmngrUserData);
xpcmngrUserData=i_createSubBarAppCtrl(xpcmngrUserData);
xpcmngrUserData=i_createMngrMdlHierBarCtrl(xpcmngrUserData);
%i_createtoolbar(xpcmngrUserData.figure);
xpcmngrUserData=i_createMngrTreeCtrl(xpcmngrUserData);
%xpcmngrUserData.timerObj=actxserver('ccrpTimers6.ccrpTimer');
%registerevent(xpcmngrUserData.timerObj,'updatexpcexplr');
%xpcmngrUserData.timerObj.interval=500;
%xpcmngrUserData.timerObj.enabled=1;
% %----
xpcmngrUserData.timerObj=timer; %xpcmngrUserData.timerObj.busyMode;'queue';
xpcmngrUserData.timerObj.Period=0.5;
xpcmngrUserData.timerObj.ExecutionMode='fixedRate';
xpcmngrUserData.timerObj.BusyMode='drop';
xpcmngrUserData.timerObj.TimerFcn={@updatexpcexplr,xpcmngrUserData.treeCtrl};
%start(xpcmngrUserData.timerObj)

%----




%xpcmngrUserData=xpcmngrTree('CreateTree',xpcmngrUserData);
%xpcmngrUserData=i_createScrollPaenl(xpcmngrUserData);
%xpcmngrUserData=i_createScrollPanel(xpcmngrUserData);
xpcmngrUserData=i_createSplitter(xpcmngrUserData);
xpcmngrUserData=i_createMngrStatBarCtrl(xpcmngrUserData);
xpcmngrUserData=xpcmngrDrawPanelAPI(xpcmngrUserData);
xpcmngrUserData=xpcmngrProcessMenu('CreateTB',xpcmngrUserData);
%xpcmngrUserData.xpcmngrAPI=xpcmngrAPI;
%xpcmngrUserData = xpcmngrScopeViewer('getLocalHandles');
%xpcmngrUserData.xpcmngrAPI
%xpcmngrUserData=i_createBlockIOCtrls(xpcmngrUserData);
%set(xpcmngrUserData.figure,'UserData',xpcmngrUserData);
%here we put default frame -> Target Application Manager -> Application
%xpcmngrUserData=i_createTargetSubAppWin(xpcmngrUserData);
%set(xpcmngrUserData.figure,'UserData',xpcmngrUserData);
set(xpcmngrUserData.figure,'Visible','on')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createMngrTreeCtrl(xpcmngrUserData)
%create TreeView ctrl
fpos=get(xpcmngrUserData.figure,'Position');
scopeFigrect=get(xpcmngrUserData.figure,'Position');%fpos(4)-50-5+5
treeCtrl_rect=[0,20,(fpos(3)/3) - 5,fpos(4)-50-5+5+5];
treeh=actxcontrol('MWXPCControls.treeviewctrl',treeCtrl_rect,xpcmngrUserData.figure);
set(treeh,'OleDragMode','vbOLEDragAutomatic')%vbOLEDragAutomatic,vbOLEDragManual
set(treeh,'OleDropMode','vbOLEDropManual')
treeh.addproperty('FigHandle');
treeh.addproperty('Targets');
treeh.addproperty('TargetPCMap');
treeh.TargetPCMap={};
treeh.addproperty('xpcTgConfigUI');
treeh.addproperty('dragSourceItem');
treeh.addproperty('Expandedflag');
treeh.addproperty('LastSelectedTarget');
treeh.addproperty('timerflag');
treeh.addproperty('currentenv');
treeh.timerflag=1;
treeh.addproperty('x');
treeh.addproperty('sigInfo');
treeh.addproperty('scopeIdNodeIdx');
treeh.addproperty('y');
treeh.HideSelection=0;
treeh.UserData='mdlH';
treeh.FigHandle=xpcmngrUserData.figure;
%imListCtrl=i_createImageListCtrl;
imListCtrl=i_createxpcMngrImageListCtrl;
treeh.InsertImagelist(imListCtrl);
treeh.LabelEdit=1;
treeh.LineStyle=1;
treeh.Indentation=25;
xpcmngrUserData.treeCtrl=treeh;
xpcmngrUserData=i_createTreeNodeUIContextMenu(xpcmngrUserData);
feval(xpcmngrTree('InitTree'),xpcmngrUserData.treeCtrl)
%i_populatexpcMngrTree(xpcmngrUserData)
%create Imagelist control 
registerevent(treeh,'xpcmngrTreeEvent');    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imListCtrl=i_createxpcMngrImageListCtrl;
imListCtrl=actxcontrol('MWXPCControls.ImageListCtrl',...
                                       [0 0 1 1], 'command');
%RootSysImage=[xpcroot,'\xpc\xpcmngr\simulink.bmp']; %index 1
%D:\work\sbR14\toolbox\rtw\targets\xpc\xpc\xpcmng\simulink.bmp
%SusSysImage=[xpcroot,'\xpc\xpcmngr\subsystems.bmp'];%index 2
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\cpu_host.bmp']);%1  Hoat PC Icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\ConfigurationComponent.bmp']);%2 Config Icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\cpu_connected.bmp']);%3 Target PC Icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\dlm.bmp']);%4 Target APP Icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\directory_dlm.bmp']);%5 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\dlm.bmp']);%6 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\SubsystemIcon.bmp']);%7 Sub sys Icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\simulinkicon.bmp']);%8
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\SimulinkSignal.bmp']);%9 signal icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\BlockIcon.bmp']);%10 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\cpu_configuration.bmp']);%11 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\directory_scope.bmp']);%12 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\scope_file.bmp']);%13 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\scope_target.bmp']);%14 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\scope_cpu.bmp']);%15 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\scope.bmp']);%16 Block icon
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\cpu_configuration.bmp']);%17 Block icon     
imListCtrl.Add([xpcroot,'\xpc\xpcmngr\Resources\cpu_disconnected.bmp']);%18 Block icon     
IL.MaskColor=uint32(256*256*255+255);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createSubBarAppCtrl(xpcmngrUserData)
%create sub  bar label ctrl
fpos=get(xpcmngrUserData.figure,'Position');
xpcmngrUserData.subbarCtrl=actxcontrol('MSCOMctlLib.sbarCtrl.2',...
                                       [fpos(3)/3 fpos(4)-45+20 fpos(3)-fpos(3)/3 25],...
                                       xpcmngrUserData.figure);
%set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'Text','Application Manager');
xpcmngrUserData.subbarCtrl.Panels.Item(1).MinWidth=fpos(3)+800;
xpcmngrUserData.subbarCtrl.Font.bold=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createMngrMdlHierBarCtrl(xpcmngrUserData)
%create sub  bar label ctrl
fpos=get(xpcmngrUserData.figure,'Position');
%%%create sbar%%%%%%%%%%%%%%%%%%%%%%%
%x[0 fig_rect(4)-45+20 (fig_rect(3)/3)-5 25]
xpcmngrUserData.mdlHierachCtl=actxcontrol(...
    'MSCOMctlLib.sbarCtrl.2',...
    [0 fpos(4)-45+20 (fpos(3)/3)-5 25],...
    xpcmngrUserData.figure);
xpcmngrUserData.mdlHierachCtl.Panels.Item(1).MinWidth=fpos(3)/3+800;
%xpcmngrUserData.mdlHierachCtl.Panels.Item(1).Text='Model Heirachy';
set(xpcmngrUserData.mdlHierachCtl.Panels.Item(1),'Text','xPC Target Hierachy')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createMngrxpcInstrBarCtrl(xpcmngrUserData)
%create sub  bar label ctrl
fpos=get(xpcmngrUserData.figure,'Position');
%%%create sbar%%%%%%%%%%%%%%%%%%%%%%%
xpcmngrUserData.xpcInsbarCtl=actxcontrol('MSCOMctlLib.sbarCtrl.2',...
                                           [0, (fpos(4)/2)-20-25,...
                                           (fpos(3)/3) - 5, 25],...
                                           xpcmngrUserData.figure);
xpcmngrUserData.xpcInsbarCtl.Panels.Item(1).MinWidth=fpos(3)/3+800;
xpcmngrUserData.xpcInsbarCtl.Panels.Item(1).Text='xPC Target%Instrumentation';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createMngrStatBarCtrl(xpcmngrUserData)
%create mngr Status ctrl
fpos=get(xpcmngrUserData.figure,'Position');
pos=[fpos(3)/3 0 fpos(3)-fpos(3)/3 20];
pos=[0,0,fpos(3),20];
xpcmngrUserData.sbarTree=actxcontrol( ...
    'MSCOMctlLib.sbarCtrl.2',...
     pos,...
     xpcmngrUserData.figure);
set(xpcmngrUserData.sbarTree.Panels.Item(1),'MinWidth',fpos(3)+400);
set(xpcmngrUserData.sbarTree.Panels.Item(1),'text','Refresh Enabled');
%xpcmngrUserData.sbarTree.Panels.Add;                                  
%xpcmngrUserData.sbarTree.Panels.Add;  
%%%create sbar%%%%%%%%put in a function
% xpcmngrUserData.sbarPanel=actxcontrol(...
%     'MSCOMctlLib.sbarCtrl.2',...
%     [0 0 fpos(3)/3 20],...
%     xpcmngrUserData.figure);
% %for i=1:7
%     %xpcmngrUserData.sbarPanel.Panels.Add;
% %end
% set(xpcmngrUserData.sbarPanel.Panels.Item(1),'MinWidth',fpos(3));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function xpcmngrUserData=i_createSplitter(xpcmngrUserData)
figH=xpcmngrUserData.figure;
fig_rect=get(figH,'Position');
splitPos=[(fig_rect(3)/3)-5 20 6 fig_rect(4)];

xpcmngrUserData.Splitter=actxcontrol('MSCOMctlLib.sbarCtrl.2',...
                                     splitPos,...
                                     xpcmngrUserData.figure);
% xpcmngrUserData.Splitter=uicontrol('Style','Frame',...
%     'enable','on',...
%     'Position',splitPos,'Parent',figH);
%     
xpcmngrUserData.Splitter;
addproperty(xpcmngrUserData.Splitter,'figH');
addproperty(xpcmngrUserData.Splitter,'mouseDownOn');
addproperty(xpcmngrUserData.Splitter,'mouseDownUp');
addproperty(xpcmngrUserData.Splitter,'spFrame');
addproperty(xpcmngrUserData.Splitter,'spFrPos');
xpcmngrUserData.Splitter.figH=xpcmngrUserData.figure;
registerevent(xpcmngrUserData.Splitter,...
    {'MouseMove' 'xpcmngrsplitter';...
    'MouseDown' 'xpcmngrsplitter';...
    'MouseUp' 'xpcmngrsplitter'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tabCtrl_rect=i_calcTabctrlrect(scopeFigrect)
%%%respect to the Screen
leftfig_pos  = scopeFigrect(1);
butfig_pos   = scopeFigrect(2);
widfig_pos   = scopeFigrect(3);
hgtfig_pos   = scopeFigrect(4);
%%%
tabCtrl_rect=[0,hgtfig_pos-20,widfig_pos,20];%%%tab Control Position respect to fig
%%%--------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig_rect=i_calcFigurerect(root,figH)
curUnit=get(0,'units');
set(0,'units','pixels'); %must reset
screenrect=get(0,'screensize');
scrWidth=screenrect(3);scrHeight=screenrect(4);
figPos=get(figH,'Position');
figWidth=figPos(3);figHeight=figPos(4);
fig_rect =  [(scrWidth/2  -  figWidth/2)...
             (scrHeight/2 -  figHeight/2)...
              figWidth  figHeight];
set(0,'units',curUnit); %set to orig
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function viewPanelArea=i_calcPanelViewableArea(figH,tree)
%[x1(starting poing from left of tree),
% y1(starting point ftom buttom of fig),
% x2(width remaining in the figure of viewable area to draw in)
% y2)height of viewable area in the figure to draw in)
fH=handle(figH);
figHPos=fH.Position;
treePos=move(tree);
buttomYLen=25;
topYlen=80;
viewPanelArea=[treePos(3), buttomYLen,figHPos(3)-treePos(3), figHPos(4)-(buttomYLen+topYlen)];
%uicontrol('style','Listbox','position',[viewPanelArea(1) viewPanelArea(2)+50 200 100],'parent',figH)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_resizeMainFrame(figH,evt)
%%%Resize all Componens part of Main Frame


%%%%&&&&&&&&&&&&&%%%%%%%%%%%%%%%%%%%%
fpos=get(figH,'Position');
xpcmngrUserData=get(figH,'Userdata');
tree=xpcmngrUserData.treeCtrl;
treePos=move(tree);

splitPos=move(xpcmngrUserData.Splitter);%splitter
trbarPos=move(xpcmngrUserData.mdlHierachCtl);%treeBar
subbarCtrlPos=move(xpcmngrUserData.subbarCtrl);%Panel top bar
sbarfPos=move(xpcmngrUserData.sbarTree);
resObj=findobj(xpcmngrUserData.figure,'Type','Uicontrol');
%fliplr(resObj);
%resize according to fig pos
set(resObj,'Units','Normalized');
treePos=[treePos(1),20,treePos(3),fpos(4)-50-5+5];
move(tree,treePos);
trbarPos=[trbarPos(1),fpos(4)-45+20,trbarPos(3),25];
move(xpcmngrUserData.mdlHierachCtl,trbarPos);
splitPos=[splitPos(1),20,splitPos(3),fpos(4)];
move(xpcmngrUserData.Splitter,splitPos);
sbarfPos=[sbarfPos(1),0,fpos(3),20];
move(xpcmngrUserData.sbarTree,sbarfPos);
subbarCtrlPos=[splitPos(1)+5,fpos(4)-45+20,fpos(3)-treePos(3)-5,25];
move(xpcmngrUserData.subbarCtrl,subbarCtrlPos);
splitPos=move(xpcmngrUserData.Splitter);


%Hosriz stretch
if fpos(3) < treePos(3) 
   treePos(3)=fpos(3);
   move(tree,treePos);
end

if fpos(3) > treePos(3)+5;
   treePos(3)=splitPos(1)-5;
   move(tree,treePos);
   trbarPos(3)=treePos(3);
   move(xpcmngrUserData.mdlHierachCtl,trbarPos);
end

viewPanelArea=i_calcPanelViewableArea(figH,tree);
left=viewPanelArea(1);
buttom=viewPanelArea(2);
allowdWidth=viewPanelArea(3);
allowdHeight=viewPanelArea(4);    

%%ui
chUI=findobj(figH,'Type','UIControl');
set(chUI,'Units','Pixels');
oldchUIpos=get(chUI,'Position');
tempPos=cell2mat(oldchUIpos);
left=left+10;
if findstr(tree.selecteditem.key,'HostPC')
   move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);   
end
if findstr(tree.selectedItem.key,'TGPC')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.listCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end
if ~isempty(findstr(tree.selecteditem.key,'pwdDLM')) | findstr(tree.selecteditem.key,'.dlm')
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selecteditem.key,'MDLH')
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selecteditem.key,'xPCSIG')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.sigViewer,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selectedItem.key,'TgSc')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selectedItem.key,'FileSc')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selectedItem.key,'HostSc')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end
if findstr(tree.selectedItem.Tag,'xPCScopesNode')
    %sigViewPos=[left+10 20 allowdWidth fpos(4)-50];
    move(xpcmngrUserData.rtfCtrl,[left 20 allowdWidth fpos(4)-50]);
    return
end



lwidth=splitPos(1)+splitPos(3);
delta=fpos(3)-lwidth;
verResize=(delta == getappdata(0,'delta')); 
setappdata(0,'delta',delta);
if delta < 70
    set(chUI,'Visible','off')
    return
end
set(chUI,'Visible','on')
if ~isempty(chUI)
    tempPos(:,1)=left+15;
    tempPos(:,3)=allowdWidth-40;    
    
    newchUIpos=mat2cell(tempPos,ones(size(tempPos,1),1),4);
    
   % set(chUI,'Visible','off')
    %xpos=left + ((fpos(3)-left)/2) + 10;
    if (~isempty(findstr(tree.selecteditem.key,'tgAppNode')) | ...
        ~isempty(findstr(tree.selecteditem.key,'HScid')) | ...
        ~isempty(findstr(tree.selecteditem.key,'TScid')) | ...
        ~isempty(findstr(tree.selecteditem.key,'FScid')))
         if isempty(xpcmngrUserData.scidlistCtrl)
             xpcmngrUserData.scidlistCtrl=handle(5);
         end
         if isempty(xpcmngrUserData.scidlistCtrl)
             xpcmngrUserData.tgapplistCtrl=handle(5);
         end         
        
        tempax=[xpcmngrUserData.scidlistCtrl xpcmngrUserData.tgapplistCtrl];
        ax=tempax([isa(tempax(1),'COM.MWXPCControls_listviewctrl') ...
                    isa(tempax(2),'COM.MWXPCControls_listviewctrl')]);
        
        x=move(ax,[left 20 (fpos(3)-left)/2 fpos(4)-50]);        
        left2=left+ x(3);
        tempPos(:,1)=left2 + 10;
        framidx=find(chUI==findobj(chUI,'style','Frame'));
        tempPos(framidx,1)=left2 + 5;
        
        if ~isempty(findobj(chUI,'string','Grid:'))
             grIdx=find(chUI==findobj(chUI,'string','Grid:'));
             tempPos(grIdx,1)=left2+30;
             tempPos(grIdx,3)=20;
        end
        if ~isempty(findobj(chUI,'string','Auto restart:'))
            auIdx=find(chUI==findobj(chUI,'string','Auto restart:'));        
            tempPos(auIdx,1)=left2+30;
            tempPos(auIdx,3)=80;
        end
        
        if ~isempty(findobj(chUI,'style','checkbox'))
            cbidx=find(chUI==findobj(chUI,'style','checkbox'));
            tempPos(cbidx,3)=10;
        end
        
        
        %newchUIpos=mat2cell(tempPos,ones(length(tempPos),1),4);
    end
    
    if findstr(tree.SelectedItem.key,'HostConf')
        bridx=find(chUI==findobj(chUI,'style','PushButton'));
        tempPos(bridx,1)=left+15 + allowdWidth-100 + 5;
        tempPos(bridx,3)= oldchUIpos{bridx}(3);
        ccidx=find(chUI==findobj(chUI,'Style','Edit','Tag','CompilerPath'));
        tempPos(ccidx,3)= tempPos(ccidx,3)-40;
    end
    
    if  ~isempty(findstr(tree.selectedItem.key,'TGconfig'))
        if ~isempty(findstr(tree.selectedItem.text,'Configuration'))
            fridx1=find(chUI==findobj(chUI,'style','Frame','Tag','uiFrame1'));
            fridx2=find(chUI==findobj(chUI,'style','Frame','Tag','uiFrame2'));        
            fr1pos=[left+10 23 (fpos(3)-left)/2 fpos(4)-50];
            tempPos(:,1)=fr1pos(1)+fr1pos(3)+20;  
            tempPos(:,3)= fpos(3) - (fr1pos(1)+fr1pos(3)+20);
            tempPos(fridx1,:)=fr1pos;
            edidx1=find(chUI==findobj(chUI,'style','text','Tag','Edit1'));
            %w=fpos(3) - (fr1pos(1)+fr1pos(3)+10);
            tempPos(edidx1,:) = [fr1pos(1)+5 fr1pos(2)+5 fr1pos(3)-10 fr1pos(4)-10];%w
            tempPos(fridx2,1)=fr1pos(1)+fr1pos(3)+10;        
            tempPos(fridx2,3)= fpos(3) - (fr1pos(1)+fr1pos(3)+10);
            cbdidx=find(chUI==findobj(chUI,'style','pushbutton'));
            tempPos(cbdidx,1)= fr1pos(1)+fr1pos(3)+20+ fr1pos(3)-120;
            tempPos(cbdidx,3)= (fpos(3)-(tempPos(cbdidx,1)));
        end
       % fpos(3) - (fr1pos(1)+fr1pos(3)+10);
        %fr1pos(1)+fr1pos(3)+(fpos(3) - (fr1pos(1)+fr1pos(3)+20))-120;
        
    end
    try
    %if ~(verResize)
        newchUIpos=mat2cell(tempPos,ones(size(tempPos,1),1),4);
        set(chUI,{'Position'},newchUIpos);
        set(chUI,{'Units'},{'Normalized'});
    %end
    catch
        return
    end
end

%getappdata(0,'fheight',fpos(4))


% if (verResize)
%     prevuiposcell=getappdata(0,'uipos');    
%     if isempty(prevuiposcell)
%         disp save
%         setappdata(0,'uipos',get(chUI,'Position'));
%         prevuimat=cell2mat(prevuiposcell);
%         uiposcell=get(chUI,'Position');
%         uiposmat=cell2mat(uiposcell); 
%         comp=[uiposmat(:,3) prevuimat(:,3)]    
%         return
%     end    
  
% end
% setappdata(0,'uipos',get(chUI,'Position'));
%%%%Here we resize according to the Panel we are in
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_createTreeNodeUIContextMenu(xpcmngrUserData)
xpcmngrUserData.uipopUp=uicontextmenu('parent',xpcmngrUserData.figure,...
     'Tag','TreePopupMenu');
%Listen to Right-click event on tree
% xpcmngrUserData.Listener = handle.listener(xpcmngrUserData.treeCtrl, 'RightClick',...
%                             {@i_showmenu, xpcmngrUserData.treeNode.uiContextMenu});
% % xpcmngrUserData.Listener1 = handle.listener(xpcmngrUserData.treeCtrl, 'MouseDown',...
% %                             'disp down');                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p_createNodePopUp(tree,evt)
xpcmngrUserData=get(tree.FigHandle,'Userdata');
objpos = move(src);
conpos = [double(evt.x)+objpos(1),  double(evt.y)+objpos(2)];
popUp = actxcontrol('Internet.PopupMenu',...
    [0 0 0 0],xpcmngrUserData.figure,...
    {'click','xpcmngrTreePopup'});
popUp.addproperty('xpcmngrUserData');
popUp.xpcmngrUserData=xpcmngrUserData;
popUp.addproperty('NodeClicked');
popUp.addproperty('NodeAction');
popUp.NodeClicked=tree.selectedItem;

%%%
%tg=get_targetxpc;
%%%
%%%%%%Node Menu for:----------
%--Host PC---------------
if strcmp(src.SelectedItem.Text,'Host PC')
   p_HostPC_Node_Menu(tree,popUp)
end
%--TargetPC---------------
if findstr('TGPC',src.SelectedItem.Key)
   p_TargetPC_Node_Menu(tree,popUp)
end    

if findstr('.dlm',src.SelectedItem.Key)
   p_Dlm_Node_Menu(tree,popUp)
end
if findstr('tgAppNode',src.SelectedItem.Key)
   p_TgApp_Node_Menu(tree,popUp)
end
if findstr('HostSc',src.SelectedItem.Key)
   p_Host_Scs_Node_Menu(tree,popUp)
end
if findstr('TgSc',src.SelectedItem.Key)
   p_Target_Scs_Node_Menu(tree,popUp)
end
if findstr('FileSc',src.SelectedItem.Key)
   p_File_Scs_Node_Menu(tree,popUp)
end
%---Host Scope(s)
if findstr('HScid',src.SelectedItem.Key)
   p_HostScId_Node_Menu(tree,popUp)
   %i_HostScIdNodeMenuItem(xpcmngrUserData)
   %i_HostScIdNodeMenuItem(xpcmngrUserData.treeNode.uiContextMenu,xpcmngrUs%erData)
end
%---Target Scope(s)
if findstr('TScid',src.SelectedItem.Key)
   i_TgScIdNodeMenuItem(xpcmngrUserData)
end
%---File Scope(s)
if findstr('FScid',src.SelectedItem.Key)
   i_FileIdScNodeMenuItem(xpcmngrUserData)  
end
%---Signal node(Mdl Heirachy)
if findstr('xPCSIG',src.SelectedItem.Key)
   i_AddSig2ScNodeMenuItem(xpcmngrUserData)
end
%---Signal on Scope: id
if findstr('xPCSigScope',src.SelectedItem.Key)
    i_AddSigofScopeIdNodeMenuItem(xpcmngrUserData)
end
%---block parameter node
if findstr('xPCPT',src.SelectedItem.Key)
    %figure
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function applySettings(xpcmngrUserData)
figH=xpcmngrUserData.figure;
allChildrenObj=findobj(figH,'Type','uicontrol');
statTxtH=findobj(allChildrenObj,'Style','text');
pbH=findobj(allChildrenObj,'Style','pushButton');
comH=setdiff(allChildrenObj,[statTxtH;pbH]);
oldstr=get(comH,'String');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savexpcmngrTargetConfig(tree)
d = fullfile(prefdir, 'xPCTargetPrefs');
srcfileName=[d,'\xpcmngrpref.mat'];
%srcfileName=[tempdir,'xpcmngrpref.xpc'];
allKeys=tree.GetAllKeys;
allNames=tree.GetAllNames;
tgpcidx=strmatch('TGPC',allKeys);
if isempty(tgpcidx)
    delete(srcfileName)
    return
end
numofTargets=length(tgpcidx);
tgNames=allNames(tgpcidx);
targets=tree.targets;
targetpcMap=tree.TargetPCMap;
%targets=rmfield(targets,{'tg','bio','pt'})
tgfieldNames=fieldnames(targets);
for i=1:numofTargets
    estr=['targets.',tgfieldNames{i},'.tg=[];'];
    eval(estr);
    
    %estr=['targets.',tgfieldNames{i},'=rmfield(targets.',tgfieldNames{i},'
    %,''bio''',')'];
    %eval(estr);
    %estr=['targets.',tgfieldNames{i},'=rmfield(targets.',tgfieldNames{i},'
    %,''pt''',')'];
    %eval(estr);
end

save(srcfileName,'tgNames','tgfieldNames','targets','targetpcMap');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function openxpcmngrTargetConfig(tree)
tree.Targets=[];
next=tree.Nodes.Item(1).next;
while ~isempty(next)
   if isprop(tree,next.text)
       tree.deleteproperty(next.text);
   end     
   tree.Nodes.Remove(next.Index)
   next=tree.Nodes.Item(1).next;
end

d = fullfile(prefdir, 'xPCTargetPrefs');
if ~exist(d)
  [status, msg, msgId] = mkdir(d);
  if ~status
    error(msgId, msg);
  end
end
srcfileName=[d,'\xpcmngrpref.mat'];

if ~exist(srcfileName,'file')
    return
end

load(srcfileName,'tgNames','tgfieldNames','targets','targetpcMap','-MAT');
%tree.targetPCMap=targetpcMap;
[r,c]=size(targetpcMap);
for i=1:r
   if isprop(tree,targetpcMap{i,1})
       tree.deleteproperty(targetpcMap{i,1});
   end 
   [nametgpc,tgtreeIdx] = feval(xpcmngrTree('AddTargetNode'),tree);
   set(tree.Nodes.Item(tgtreeIdx),'Text',targetpcMap{i,2});
   tree.deleteproperty(nametgpc);
   tree.addproperty(targetpcMap{i,1});
end
tree.targetPCMap=targetpcMap;
tree.Targets=targets;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrShortcuts(src,evt)
%implement shortcuts

