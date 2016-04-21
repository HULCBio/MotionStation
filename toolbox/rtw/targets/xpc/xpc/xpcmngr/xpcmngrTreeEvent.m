function xpcmngrTreeEvent(varargin)
%XPCMNGRTREEEVENT xPC Target GUI
%   XPCMNGRTREEEVENT manages the Tree Events in the xPC Target Manager GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $

tree=varargin{1};
Event=varargin{end};
figH=tree.FigHandle;
xpcmngrUserData=get(figH,'UserData');

if (strcmp(Event,'NodeClick'))
    timerStatus=strmatch(xpcmngrUserData.timerObj.running,{'off','on'},'exact') - 1;        
    stop(xpcmngrUserData.timerObj)
    try
        e_treenodeClick(varargin)
    catch       
        errordlg(lasterr)
    end    
    timerreset(timerStatus,xpcmngrUserData.timerObj)
end

if (strcmp(Event,'KeyDown'))
    e_treeKeyDown(varargin)
    %return
end

if (strcmp(Event,'KeyUp'))
    e_treeKeyUp(varargin)
    %return
end
if (strcmp(Event,'MouseDown'))    
    e_treemouseDown(varargin)
    %return
end
if (strcmp(Event,'MouseUp'))
    e_treemouseUp(varargin)
    %return
end
if (strcmp(Event,'MouseMove'))
    e_treemouseMove(varargin)
    %return
end
if (strcmp(Event,'RightClick'))
    e_treeRightClick(varargin)
    %return
end
if (strcmp(Event,'Click'))
    e_treeClick(varargin)
    %return
end
if (strcmp(Event,'DblClick'))
    e_treeDblClick(varargin)
    %return
end
if (strcmp(Event,'BeforeLabelEdit'))
    e_treeBeforeLabelEdit(varargin)
    %return
end
if (strcmp(Event,'AfterLabelEdit'))
    e_treeAfterLabelEdit(varargin)
    %return
end
if (strcmp(Event,'OLEStartDrag'))
    e_treeOLEStartDrag(varargin)
end
if (strcmp(Event,'OLEDragDrop'))
    e_treeOLEDragDrop(varargin)
end
if (strcmp(Event,'OLEGiveFeedback'))
    e_treeOLEGiveFeedback(varargin)
end
if (strcmp(Event,'OLEDragOver'))
    e_treeOLEDragOver(varargin)
end
if (strcmp(Event,'TrDragMouseDown'))
    e_TrDragMouseDown(varargin)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeExpand(EventInfo)
Node=EventInfo{3};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeKeyPress(EventInfo)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeKeyDown(EventInfo)
tree=EventInfo{1};
KeyAscii=EventInfo{3};
keyletter=char(KeyAscii);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeKeyUp(EventInfo)
tree=EventInfo{1};
figH=tree.FigHandle;
xpcmngrUserData=get(figH,'UserData');
KeyAscii=EventInfo{3};
keyletter=char(KeyAscii);
nodeItem=tree.selectedItem;
searckKey=nodeItem.key;
treeKeyMap(keyletter,xpcmngrUserData,searckKey)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_TrDragMouseDown(EventInfo)
Node=EventInfo{3}.Text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treeRightClick(EventInfo)
tree=EventInfo{1};
figH=tree.FigHandle;
xpcmngrUserData=get(figH,'UserData');
xPos=EventInfo{3};
yPos=EventInfo{4};
xTree=EventInfo{5};
yTree=EventInfo{6};
evt.x=xPos;
evt.y=yPos;
node=tree.HitTest(xTree,yTree);
%disp rightclick
if isempty(node)%click on tree Background)
%     try
%         tree.SelectedItem=[];
%         tree.DropHighLight=[];
%     catch
%     end
%     xpcmngrTreePopUp('TreePopUp',tree,evt)
else 
    %i_showmenu(tree,evt)
    tree.selectedItem=node;
    %tree.DropHighLight
    xpcmngrTreePopUp('NodePopUp',tree,evt)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treemouseDown(EventInfo)
tree=EventInfo{1};
% registerevent(tree,{'RightClick','xpcmngrTreeEvent'});
% registerevent(tree,{'NodeClick','xpcmngrTreeEvent'});
msButton=EventInfo{3}; %1=left,2=right
xPos=EventInfo{5};
yPos=EventInfo{6};
% tree.x=xPos
% tree.y=yPos
xpcmngrUserData=get(tree.FigHandle,'UserData');
set(xpcmngrUserData.uipopUp,'Position',[0 0])
%updateTree_GUI(tree)
node=tree.HitTest(xPos,yPos);
if ~isempty(node)
    tree.selectedItem=node; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treemouseUp(EventInfo)
tree=EventInfo{1};
xPos=EventInfo{5};
yPos=EventInfo{6};
tree.x=xPos;
tree.y=yPos;
%node=tree.HitTest(xPos,yPos);
% if isempty(node)
%     try
%        tree.SelectedItem=[]; 
%     catch        
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treemouseMove(EventInfo)
tree=EventInfo{1};
figH=tree.FigHandle;
xpcmngrUserData=get(figH,'UserData');
% if (timerstatus==0)
%        xpcmngrUserData.timerObj.enabled=1;
% end
if ~isempty(tree.SelectedItem)
    %tg=gettg(tree);
    if findstr('TGPC',tree.SelectedItem.key)
        tree.Expandedflag=tree.SelectedItem.Expanded;
    end
end
timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;  

if (timerStatus==0)
   set(xpcmngrUserData.sbarTree.Panels.Item(1),'text','Refresh Disabled');
else
   set(xpcmngrUserData.sbarTree.Panels.Item(1),'text','Refresh Enabled'); 
end

% if isempty(tree.SelectedItem)
%     return
% end
% fullpath=tree.SelectedItem.Fullpath;
% if findstr(fullpath,'Host PC')
%     return
% end
% if (findstr('TGPC',tree.SelectedItem.key))
%    targetNameStr = tree.SelectedItem.Text;
% else
%     sepIdx=findstr('\', tree.SelectedItem.Fullpath);
%     targetNameStr=fullpath(1:sepIdx-1);
% end
% tg=gettg(tree);
% if isempty(tg)
%     return
% end
% %to do: revist what happend when loader
% if strcmp(tg.application,'loader')
%     return
% end
% targettridx=strmatch(targetNameStr,tree.GetAllNames,'exact');
% if ~isempty(tree.Node.Item(targettridx).child.next)
%     if ~strcmp(tree.Node.Item(targettridx).child.next.text,tg.application)
%         feval(xpcmngrTree('Download2Target'),tree,tg,tg,targettridx)     
%     end
% end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeDblClick(EventInfo)
tree=EventInfo{1};
node=tree.HitTest(tree.x,tree.y);
if ~isempty(node)
    if findstr('TGPC',tree.SelectedItem.Key)
         tree.StartLabelEdit;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeClick(EventInfo)
 tree=EventInfo{1};
% if ~isempty(tree.SelectedItem)
%     if findstr('TGPC',tree.SelectedItem.Key)
%          tree.StartLabelEdit;
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treeOLEStartDrag(EventInfo)
tree=EventInfo{1};
% figH=tree.FigHandle;
% xpcmngrUserData=get(figH,'UserData');
% stop(xpcmngrUserData.timerObj)
dataObj=EventInfo{3};
if isempty(tree.selecteditem)
    return
end
dataformat=[tree.selectedItem.key,'_key_',tree.SelectedItem.text,...
    '_tag_',tree.SelectedItem.Tag];
dataObj.SetData(dataformat,1)
% aeffects=EventInfo{4};
% aeffects=1;
% EventInfo{4}=1;
% EventInfo{end-1}.AllowedEffects=1;
%disp startdrag


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treeOLEDragDrop(EventInfo)
%return
tree=EventInfo{1};
xpcmngrUserData=get(tree.figHandle,'UserData');
timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;  
                 
stop(xpcmngrUserData.timerObj)
dao=EventInfo{3};
dragSrc='IntenralDrag';
try
   datatext=dao.GetData(1);
catch
   dragSrc='ExternalDrag'; 
   dao.Files;
   datatext=dao.Files.Item(1);
end    
if strcmp(dragSrc,'IntenralDrag')
    idx=findstr('_key_',datatext);
    idx_end=idx+5;
    idx1=findstr('_tag_',datatext);
    idx1_end=idx1+5;
    srckey=datatext(1:idx-1);
    srcText=datatext(idx_end:idx1-1);
    try
        srcTag=datatext(idx1_end:end);
    catch
        %lasterr='';
    end
end
if strcmp(dragSrc,'ExternalDrag')
    if isempty(findstr(datatext,'.dlm'))
        errordlg('Only dlm file format are allowed to be dropped')
        timerreset(timerStatus,xpcmngrUserData.timerObj)
        return
    end
    tempstr=fliplr(datatext);
    idx=findstr(tempstr,'\');
    srcText=fliplr(tempstr(1:idx-1));    
    srckey='.dlm';
end
targetNode=tree.DropHighlight;
if isempty(targetNode)
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return 
end

tree.SelectedItem=targetNode;
tree.DropHighlight=[];
targetkey=targetNode.key;
targetText=targetNode.Text;

try
    %dao.Clear;
    if (findstr('.dlm',srckey) &  findstr('TGPC',targetkey))    
        %handle drag&drop dlm->target
        dropdlm2target(tree,xpcmngrUserData,srcText,targetNode)    
        %i_HidePanelChildObj(xpcmngrUserData.figure)
    elseif findstr('Scid',targetkey) & findstr('xPCSIG',srckey) 
        dropSig2xpcSc(tree,xpcmngrUserData,srcTag,targetNode)
    end
catch
    timerreset(timerStatus,xpcmngrUserData.timerObj)
end
timerreset(timerStatus,xpcmngrUserData.timerObj)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeOLEGiveFeedback(EventInfo)
tree=EventInfo{1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeOLESetData(EventInfo)
EventInfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treeOLEDragOver(EventInfo)
tree=EventInfo{1};
% figH=tree.FigHandle;
% xpcmngrUserData=get(figH,'UserData');
% stop(xpcmngrUserData.timerObj)

xPos=EventInfo{7};
yPos=EventInfo{8};
node=tree.HitTest(xPos,yPos);
if ~isempty(node)
   tree.drophighlight=node; 
end
EventInfo{4};
%start(xpcmngrUserData.timerObj)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  e_treenodeClick(EventInfo)
tree=EventInfo{1};
nodeItem=EventInfo{3};
figH=tree.FigHandle;
xpcmngrUserData=get(figH,'UserData');
Key=nodeItem.Key;

updateMenus(xpcmngrUserData.figure,'View host scopes','off')
updateMenus(xpcmngrUserData.figure,'Delete scope','off')   
updateToolbar(xpcmngrUserData.toolbar,'DelTGPC','off')
updateToolbar(xpcmngrUserData.toolbar,'Connect','off')
updateToolbar(xpcmngrUserData.toolbar,'ScopeViewer','off')
updateToolbar(xpcmngrUserData.toolbar,'Go2SLMDL','off')

tg=gettg(tree);

if isempty(tg)
    updateMenus(xpcmngrUserData.figure,'Target','Off')
    updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
    updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')    
else
    updateMenus(xpcmngrUserData.figure,'Target','On')
    %updateToolbar(xpcmngrUserData.toolbar,'Connect','on')
    if strcmp(tg.Status,'stopped')
        updateToolbar(xpcmngrUserData.toolbar,'startapp','on')
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')
    else
        updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','on')
    end

end
set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text','')

% if findstr('TGPC',Key)
% return   
% end
%-----Update Tree and GUI
updateTree_GUI(tree)
%---------------
%i_HidePanelChildObj(figH)

if isempty(findstr('Host PC Root',nodeItem.Fullpath))
    tgEnv=xpcGetTarget(tree);
    savexpceplrEnv(tgEnv)
end


if findstr('HostPC',Key)
    i_HidePanelChildObj(figH);
    xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.root,xpcmngrUserData);
    %set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',['DLM(s) ',pwd])
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)    
end

if findstr('pwdDLM',Key)
    i_HidePanelChildObj(figH);
    xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.dlmH,xpcmngrUserData);
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)   
end

if findstr('dlmtgapp',Key)
    i_HidePanelChildObj(figH);    
    xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.dlmH,xpcmngrUserData);
    set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',tree.selecteditem.Text);
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)       
end
if findstr('MDLH',Key)
    i_HidePanelChildObj(figH);
    xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.mdlH,xpcmngrUserData);
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)
end

if findstr('SubSystem',Key)
    i_HidePanelChildObj(figH);
    %xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.mdlH,xpcmngrUserData);
    %set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)
end

if findstr('xPCScopesNode',nodeItem.Tag)
    i_HidePanelChildObj(figH);
    xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.scopeDir,xpcmngrUserData);
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)    
end
if findstr('slsys',Key)
    i_HidePanelChildObj(figH);
    %here we update the right side viewer   
    %disp('Object is a SubSys')
end
if findstr('xPCPT',Key)
    i_HidePanelChildObj(figH);
    %here we update the right side viewer            
    try
    xpcblockptinfo=xpc_GetBlockinfo(tree);
       % set(pcmngrUserData.subbarCtrl.Panels.Item(1),['BlockPath
        if ~isempty(xpcblockptinfo)
            fcnH=xpcmngrUserData.drawPanelapi.tgxpcPTNode;            
            feval(fcnH,xpcblockptinfo,tree.SelectedItem.Tag,xpcmngrUserData,tg);            
        else
            pos=get(tree.figHandle,'Position');
            set(tree.figHandle,'Position',[pos(1),pos(2),pos(3)+1,pos(4)+0.5]);
            set(tree.figHandle,'Position',[pos(1),pos(2),pos(3)-1,pos(4)-0.5]);
            set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text','Not an xPC Parameter')
            set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',...
            ['Block Parameters: ',tree.SelectedItem.key(findstr(':SlBlock:',tree.SelectedItem.key)+10:end)])
        end
    catch
       errordlg(lasterr)
       return
    end    
    %disp('Object is a parameter')
end

if findstr('TGPC',Key)
%     feval(xpcmngrUserData.drawPanelapi.menufcn,...
%           xpcmngrUserData.figure,'remove Target','on');
   updateToolbar(xpcmngrUserData.toolbar,'DelTGPC','on')
   updateToolbar(xpcmngrUserData.toolbar,'Connect','on')
   i_HidePanelChildObj(figH)
   tg=gettg(tree);
   if (isempty(tg) | strcmp(tg.application,'loader'))
      updateMenus(xpcmngrUserData.figure,'Target','Off')
      updateMenus(xpcmngrUserData.figure,'Ping Target','On')
      updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
      updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')
   else
      updateMenus(xpcmngrUserData.figure,'Target','On')
      updateMenus(xpcmngrUserData.figure,'Ping Target','On')
      if strcmp(tg.Status,'stopped')
        updateToolbar(xpcmngrUserData.toolbar,'startapp','on')
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')
      else
        updateToolbar(xpcmngrUserData.toolbar,'startapp','off')  
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','on')  
      end
      
   end
   xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.targetPC,xpcmngrUserData);
   set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)
end

if findstr('tgAppNode',Key)
    %here we update the right side viewer    
    i_HidePanelChildObj(figH);
    updateMenus(xpcmngrUserData.figure,'Go to Simulink Model','On')
    updateToolbar(xpcmngrUserData.toolbar,'Go2SLMDL','on')
    fcnh=xpcmngrUserData.drawPanelapi.tgAppConfigNodes;
    xpcmngrUserData=feval(fcnh,xpcmngrUserData, tg);
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData);
end



if findstr('xPCSIG',Key)
    %unregisterevent(tree,{'NodeClick','xpcmngrTreeEvent'});
    %here we update the right side viewer    
    i_HidePanelChildObj(figH);
    signal=tree.SelectedItem.Tag;
    targetStruct=xpcGetTarget(tree);
    bio=targetStruct.bio;
    sigsbio={bio(:).blkName};
    sigIdx=strmatch(signal,sigsbio,'exact');
    if ~isempty(sigIdx)
        sigInfo=bio(sigIdx);
    else
        sigInfo=[];
        return
    end    
    tree.sigInfo=sigInfo;
    fcnh=xpcmngrUserData.drawPanelapi.sigNode;
    xpcmngrUserData=feval(fcnh,xpcmngrUserData, tg, sigInfo);
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData);
    %tree.sigInfo=[];
    %xpcmngrDrawPanel('xPCSIG',xpcmngrUserData);
    %disp('Object is a signal')
end
if isempty(findstr(tree.SelectedItem.Fullpath,'Host PC Root'))
    fpath=tree.selectedItem.FullPath;
	idx=findstr(fpath,'\');
    if ~isempty(idx)
        tgName=fpath(1:idx-1);
    else %must be target Node 
        tgName=fpath;
    end
    targetpcMap=tree.TargetPCMap;
    idxfound=strmatch(tgName,targetpcMap(:,2),'exact');
    treetgpcstr=targetpcMap{idxfound,2};
    tree.LastSelectedTarget=treetgpcstr;
%    tree.currentenv=xpcGetTarget(tree);
 end


% if isempty(findstr(tree.SelectedItem.Fullpath,'Host PC Root'))
%    tree.currentenv=xpcGetTarget(tree);
% end

if findstr('TGconfig',Key) 
   % tree.currentenv=xpcGetTarget(tree);
    i_HidePanelChildObj(figH);
    %here we update the right side viewer    
    fcnh=xpcmngrUserData.drawPanelapi.commConfigNodes;
    xpcmngrUserData1=feval(fcnh,xpcmngrUserData);
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData1);
    %disp('Object is a Target PC Config')
end

if findstr('HostConf',Key)
    i_HidePanelChildObj(figH);
    fcnh=xpcmngrUserData.drawPanelapi.hostConfigNode;
    feval(fcnh,xpcmngrUserData);
    %here we update the right side viewer    
    %pcmngrDrawPanel('HostConf',xpcmngrUserData);
  %  disp('Object is a Host PC Config')
end

if findstr('HostSc',Key)
    updateToolbar(xpcmngrUserData.toolbar,'ScopeViewer','on')
    i_HidePanelChildObj(figH);        
    fcnh=xpcmngrUserData.drawPanelapi.scopeTypeDir;
    xpcmngrUserData1=feval(fcnh,xpcmngrUserData,'hostSc');
    if (tree.selectedItem.children > 0)
        updateMenus(xpcmngrUserData.figure,'View host scopes','on')   
    else
        updateMenus(xpcmngrUserData.figure,'View host scopes','off')   
    end

    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData1)
end
if findstr('TgSc',Key)
    i_HidePanelChildObj(figH);
    fcnh=xpcmngrUserData.drawPanelapi.scopeTypeDir;
    xpcmngrUserData1=feval(fcnh,xpcmngrUserData,'tgSc');
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData1)
    
end
if findstr('FileSc',Key)
    i_HidePanelChildObj(figH);
    fcnh=xpcmngrUserData.drawPanelapi.scopeTypeDir;
    xpcmngrUserData1=feval(fcnh,xpcmngrUserData,'fileSc');
    set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData1)
end

if findstr('Scid',Key)%individual scope
     updateMenus(xpcmngrUserData.figure,'Delete scope','on')   
     tg=gettg(tree);
     scopeidstr=tree.selectedItem.Text;
     scopeid=eval(scopeidstr(7:end));
     sc=tg.getscope(scopeid);

     if (tree.MousePointer ~= 99)
        i_HidePanelChildObj(figH)
        fcnh=xpcmngrUserData.drawPanelapi.scopeid;
        xpcmngrUserData=feval(fcnh,xpcmngrUserData,sc);
        set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData);
     end
  % xpcmngrUserData=xpcmngrDrawPanel('HScid',xpcmngrUserData);
end


% fposh=get(figH,'Position');
% set(figH,'Position',[fposh(1),fposh(2),fposh(3),fposh(4)+0.5])
% set(figH,'Position',[fposh(1),fposh(2),fposh(3),fposh(4)-0.5])
%set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeAfterLabelEdit(Event_info)
    i_updateTargetenvStruct(Event_info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e_treeBeforeLabelEdit(Event_info)
tree=Event_info{1};
tree.SelectedItem.Expanded=tree.Expandedflag;
%tree.selectedItem.Expanded
% if tree.selectedItem.Expanded
%    tree.selectedItem.Expanded=1; 
% else
%     tree.selectedItem.Expanded=0
% end
% if state
% %    tree.SelectedItem.Expanded
% % end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_updateTargetenvStruct(Event_info)
tree=Event_info{1};
targetpcMap=tree.TargetPCMap;
oldstr=tree.SelectedItem.Text;
newStr=Event_info{4};

idxfound=strmatch(oldstr,targetpcMap(:,2),'exact');

tgpcstr=targetpcMap{idxfound,1};
targetpcMap(idxfound,2)={newStr};
tree.TargetPCMap=targetpcMap;
%tgsavedNames=fieldnames(tree.Targets);
%oldfieldName=strrep(oldstr,' ','');
%currfieldVal=getfield(tree.Targets,tgpcstr);
%tree.Targets=rmfield(tree.Targets,oldfieldName);
%str=['tree.Targets.',tgpcstr,'= currfieldVal;'];
%eval(str);

%evalstr=['get(tree,','''',tree.SelectedItem.Text,'''',')'];
%tg=eval(evalstr);
%%rename tree prop
%tree.deleteproperty(tree.SelectedItem.Text);
%tree.addproperty(newStr)
%evalstr=['set(tree,','''',newStr,'''',',tg)'];
%eval(evalstr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcblockptinfo=xpc_GetBlockinfo(tree);
sysName=get_systemNamefromNode(tree);
pt=eval([sysName,'pt']);
allblksptcell=cellstr(strvcat(pt.blockname));
ptidx=strmatch(tree.SelectedItem.Tag,allblksptcell,'exact');
xpcblockptinfo=pt(ptidx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sysName=get_systemNamefromNode(tree)
fullpath=tree.SelectedItem.FullPath;
idx=findstr('\',fullpath);
sysName=fullpath(idx(1)+1:idx(2)-1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function i_HidePanelChildObj(figH)
%children=get(xpcmngrUserData.figure,'Children');
children=findobj(figH,'Type','uicontrol');
if ~isempty(children)
    delete(children)
end
xpcmngrUserData=get(figH,'Userdata');
if isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
    delete(xpcmngrUserData.listCtrl)
    xpcmngrUserData.listCtrl=[];
end
if isa(xpcmngrUserData.tgapplistCtrl,'COM.MWXPCControls_listviewctrl')
    delete(xpcmngrUserData.tgapplistCtrl)
    xpcmngrUserData.tgapplistCtrl=[];
end

if isa(xpcmngrUserData.scidlistCtrl,'COM.MWXPCControls_listviewctrl')
    delete(xpcmngrUserData.scidlistCtrl)
    xpcmngrUserData.scidlistCtrl=[];
end

if isa(xpcmngrUserData.sigViewer,'COM.MWXPCControls_mshflexgridCtrl')
    delete(xpcmngrUserData.sigViewer)
    xpcmngrUserData.sigViewer=[];
end

if isa(xpcmngrUserData.rtfCtrl,'COM.MWXPCControls_richtextboxctrl')
    delete(xpcmngrUserData.rtfCtrl)
    xpcmngrUserData.sigViewer=[];    
end

if isa(xpcmngrUserData.scTypertfCtrl,'COM.MWXPCControls_richtextboxctrl')
    delete(xpcmngrUserData.scTypertfCtrl)
    xpcmngrUserData.scTypertfCtrl=[];    
end






set(figH,'UserData',xpcmngrUserData)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function updateTree_GUI(tree)
%%%%Update on Node Click
xpcmngrUserData=get(tree.figHandle,'Userdata');
fullpath=tree.SelectedItem.Fullpath;
if findstr('TGPC',tree.SelectedItem.Key)
    tgNameStr=tree.SelectedItem.Text;    
elseif findstr('Host PC',fullpath)
    set(tree.Nodes.Item(1),'Bold',1);
    tgNameStr='Host PC';
    feval(xpcmngrUserData.drawPanelapi.menufcn,...
          xpcmngrUserData.figure,'Target','off');
else
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
    tgNameStr=fullpath(1:sepIdx-1);
    tg=gettg(tree);
    if isempty(tg) | strcmp(tg.application,'loader')
               feval(xpcmngrUserData.drawPanelapi.menufcn,...
           xpcmngrUserData.figure,'Target','off');
    elseif strcmp(tg.Connected,'Yes') & ~strcmp(tg.application,'loader')
       %updateMenuLabes(figH,'Target','on') 
       feval(xpcmngrUserData.drawPanelapi.menufcn,...
           xpcmngrUserData.figure,'Target','on');
    end
    
    
end
allNames=tree.GetAllNames;
allkeys=tree.GetAllKeys;
alltgxpcIdx=strmatch('TGPC',allkeys); 
tgxpcIdx=strmatch(tgNameStr,allNames); 
remtgxpc=setxor(tgxpcIdx,alltgxpcIdx);
set(tree.Nodes.Item(tgxpcIdx),'Bold',1);

for ij=1:length(remtgxpc)    
    set(tree.Nodes.Item(remtgxpc(ij)),'Bold',0);
    %set(tree.Nodes.Item(1),'Bold',0);
end

%%%To do: Update menus Items here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateMenus(figH,menuItem,state)
menuH=findobj(figH,'Type','UIMenu','Label',menuItem);
if ~isempty(menuH)
    set(menuH,'enable',state);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateToolbar(uitoolH,toolItem,state)
toolH=findobj(uitoolH,'Type','UIToggletool','Tag',toolItem);
if ~isempty(toolH)
    set(toolH,'enable',state);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigInfo=findbio(tree,sigName)
tgEnv=xpcGetTarget(tree);
bio=tgEnv.bio;
siglist={bio(:).blkName};
idx=strmatch(sigName,siglist,'exact');
if ~isempty(idx)
   sigInfo=bio(idx); 
else
   sigInfo=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savexpceplrEnv(tgEnv)
fldcell={'tg','bio','pt'};
idx=[isfield(tgEnv,'tg') isfield(tgEnv,'bio') isfield(tgEnv,'pt')];
fields=fldcell(idx);
tgEnv=rmfield(tgEnv,fields);
setappdata(0,'xpcTargetexplrEnv',tgEnv);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dropdlm2target(tree,xpcmngrUserData,srcText,targetNode)
%handle drag&drop dlm->target
%dropdlm2target(tree,xpcmngrUserData,srcText,TargetNode)
timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;      
stop(xpcmngrUserData.timerObj)
set(0,'showhiddenhandles','on');
xpcmngrfigScH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
%xpcmngrUserData=get(xpcmngrfigH,'UserData');
set(0,'showhiddenhandles','off');
if ~isempty(xpcmngrfigScH)
    xpcmngrUserData.api.scViewer.closeScViewer(xpcmngrfigScH,[],[])
   %delete(xpcmngrfigScH)
end

%treedropdlm(srckey,targetkey,targetNode)    
try
   tree.MousePointer=11;
   %tgPCstring=strrep(menuLabel(20:end),' ','');
   dlmName=srcText;
   tg = gettg(tree,targetNode.Text);
   if isempty(tg)
       tree.MousePointer=0;
       tree.DropHighlight=[];
       errordlg(['Connection to ',targetNode.Text,' is not open.'],'xPC Target Error')
       timerreset(timerStatus,xpcmngrUserData.timerObj)
       return
   end
   feval(xpcmngr('Download2Target'),tg,dlmName)
   feval(xpcmngrTree('Download2Target'),tree,tg,tg)
   tree.MousePointer=0;
   tree.DropHighlight=[];
   %i_populatetgScopesNode
   %start(xpcmngrUserData.timerTreeObj);
   %return
   %To do: Remove any children existing in panel from
   %before.
   
catch
    errordlg(lasterr)
    tree.MousePointer=0;
    tree.DropHighlight=[];
    timerreset(timerStatus,xpcmngrUserData.timerObj)
end
%%%%%rendercall(make global)
updateToolbar(xpcmngrUserData.toolbar,'DelTGPC','on')
updateToolbar(xpcmngrUserData.toolbar,'Connect','on')
i_HidePanelChildObj(xpcmngrUserData.figure)
tg=gettg(tree);
if (isempty(tg) | strcmp(tg.application,'loader'))
    updateMenus(xpcmngrUserData.figure,'Target','Off')
    updateMenus(xpcmngrUserData.figure,'Ping Target','On')
    updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
    updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')
else
    updateMenus(xpcmngrUserData.figure,'Target','On')
    updateMenus(xpcmngrUserData.figure,'Ping Target','On')
    if strcmp(tg.Status,'stopped')
        updateToolbar(xpcmngrUserData.toolbar,'startapp','on')
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')
    else
        updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','on')
    end

end
xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.targetPC,xpcmngrUserData);
set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)
%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dropSig2xpcSc(tree,xpcmngrUserData,srcTag,targetNode)
sigName=srcTag;
scopeText=targetNode.Text;
scopeId=eval(scopeText(7:end));
sigInfo=findbio(tree,sigName);
tg=gettg(tree);
if (sigInfo.sigWidth > 1)
    dims=sigInfo.dim;
    answer=xpcmngrsigSelect(get(xpcmngrUserData.figure,'Position'),sigInfo);
    if isempty(answer)
       return
    end
    rowIdx=answer.rows;
    colIdx=answer.cols;
    numofSig2Add=length(rowIdx)*length(colIdx);

    idxVec=1:sigInfo.sigWidth;
    idxVec=reshape(idxVec,dims(1),dims(2));
    if (numofSig2Add > 10)
        errordlg('To many signals selected to add.')
        return
    end

    
    %sc=tg.getscope(scopeId);
    %sigOnSc=sc.signals;
    sigOnSc=xpcgate(tg.Port, 'getscsignals', scopeId);

    if ((length(sigOnSc) + numofSig2Add) > 10)
        errordlg('To many signals selected')
        return
    end

    try
        idxVecIdx=idxVec(rowIdx,colIdx);
    catch
        return
    end
    if (isempty(colIdx) | isempty(rowIdx))
        return
    end

    for i=1:length(idxVecIdx)
        idxVecIdx=idxVec(rowIdx(i),colIdx(i));
        str=['/s',sprintf('%d',idxVecIdx(i))];
        siglist{i}=[srcTag,str];
    end
else
    siglist={sigName};
end
for k=1:length(siglist);
    sigName=siglist{k};
    try
        %tg = gettg(tree);
        %         bio=eval([tg.application,'bio']);
        %         idx=strmatch(sigName,cellstr(strvcat(bio(:).blkName)),'exact')
        %         if bio(idx).sigWidth > 1
        %
        %         end
        %sigsonSc=xpcgate('getscsignals',axscopeusrdata.scopeobj.ScopeId)
        sigcheck=feval(xpcmngr('AddSigId2ScId'),tg,sigName,scopeId);
        %sigcheck=xpc_AddSignal2Scope(sigName,scopeId,xpcmngrUserData.treeC
        %trl);
        if (sigcheck)
            feval(xpcmngrTree('AddSig2ScopeIdNode'),tree,scopeText,sigName,targetNode.Index);
            %i_addSignalNode2ScopeTree(xpcmngrUserData.treeCtrl,menuLabel);
            %redraw scopes
            set(0,'showhiddenhandles','on');
            scfigH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
            set(0,'showhiddenhandles','off');

            if ~isempty(scfigH)
                % stop(xpcmngrUserData.timerObj)
                fcnh1=xpcmngrUserData.api.scViewer.delAllScAxes;
                fcnh=xpcmngrUserData.api.scViewer.createAllScAxes;
                scViewerUserData=feval(fcnh1,xpcmngrUserData.scfigure);
                set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
                scViewerUserData=feval(fcnh,xpcmngrUserData.scfigure,tg);
                set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
                % start(xpcmngrUserData.timerObj)
            end
        end
    catch
        errordlg(lasterr);
        return
    end
    %disp dragsignal2scope
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timerreset(chksum,timerObj)
if chksum==1
   start(timerObj)
else
   stop(timerObj)
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function treeKeyMap(keyletter,xpcmngrUserData,searckKey)

if keyletter~='.'
    return
end

%%%To do: make this function accessable globally

if findstr(searckKey,'Scid')    
    timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;  
    stop(xpcmngrUserData.timerObj)
    scopeidstr=xpcmngrUserData.treeCtrl.SelectedItem.Text;
    scopeid=scopeidstr(8:end);
    scopeid=eval(scopeid);
    try
        tg = gettg(xpcmngrUserData.treeCtrl);
        sc = tg.getscope(scopeid);
        scType=sc.Type;
        feval(xpcmngr('RemoveScopeid'),tg,scopeid);%remove from tg
        feval(xpcmngrTree('RemoveScopeeIdNode'),xpcmngrUserData.treeCtrl)
        %%%%
        set(0,'showhiddenhandles','on');        
        scfigH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
        set(0,'showhiddenhandles','off');
        %Remove from viewer if nescaary
        if strcmp(scType,'Host') & ~isempty(scfigH)
            %stop(xpcmngrUserData.timerObj)
            fcnH = xpcmngrScopeViewer('getLocalHandles');
            fcnh1=fcnH.api.scViewer.delAllScAxes;
            fcnh=fcnH.api.scViewer.createAllScAxes;
            scViewerUserData=feval(fcnh1,xpcmngrUserData.scfigure);
            set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
            scViewerUserData=feval(fcnh,xpcmngrUserData.scfigure,tg);            
            set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
           % start(xpcmngrUserData.timerObj)        
        end
    catch
        errordlg(lasterr);
    end
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return
end

if findstr(searckKey,'TGPC')    
    timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;  
     stop(xpcmngrUserData.timerObj)
     xpcmngrUserData.treeCtrl.api.removeTargetNode(xpcmngrUserData.treeCtrl)
     timerreset(timerStatus,xpcmngrUserData.timerObj)
     return
end
