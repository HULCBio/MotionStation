function xpcmngrPopUpCallback(src,evt,xpcmngrUserData)
%XPCMNGRPOPUPCALLBACK xpc Target Manager GUI
%   XPCMNGRPOPUPCALLBACK Manages the callbacks from the Nodes
%   UIContextmenus of the Tree Nodes Menus in the GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $

menuLabel=get(src,'Label');
timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;  
tree=xpcmngrUserData.treeCtrl;

% if strcmp('on',timerStatus)
%     stop(xpcmngrUserData.timerObj)
% end
%---------------*
if strcmp(menuLabel,'Add Target')
    
%    disp('Added Target')
    %_AddTargetNode(xpcmngrUserData.treeCtrl) 
    feval(xpcmngrTree('AddTargetNode'),tree);
    %tree.api.populateTreeAppNode(tree,menuLabel)
    %feval(xpcmngr('AddTarget'),tree)
end
%---------------*
if strcmp(get(src,'Tag'),'ConnectTargetPC')
    %xpcmngrUserData.timerObj.enabled = 0;
    stop(xpcmngrUserData.timerObj)
    xpcmngrfigScH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
    %xpcmngrUserData=get(xpcmngrfigH,'UserData');
    set(0,'showhiddenhandles','off');
    if ~isempty(xpcmngrfigScH)
        delete(xpcmngrfigScH)
    end
    try
        connect(xpcmngrUserData)
    catch
        errordlg(lasterr)
    end  
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return
end
%---------------*
if strcmp(get(src,'Tag'),'RenTargetPC')
    %feval(xpcmngrTree('RenameTargetPC'),tree) 
    tree.api.renameTargetNode(tree)
    %To do: create call fcn to for update of tree.target str    
end
%---------------*
if strcmp(get(src,'Tag'),'RemTargetPC')
      tree.api.removeTargetNode(tree)
     %To do: create call fcn to for update of tree.target str    
end
%---------------*
if strcmp(menuLabel,'Disconnect')
    stop(xpcmngrUserData.timerObj)
    tg=gettg(tree);
    feval(xpcmngr('DisconnectTargetPC'),tree,tg)  
    tree.api.disconnetTargetNode(tree);
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return
end
%---------------*
if strfind(menuLabel,'Download to Target')
   %donwload tg app to target
   %if download success populate tg app Node
   stop(xpcmngrUserData.timerObj)
   set(0,'showhiddenhandles','on');
   
   xpcmngrfigScH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
   %xpcmngrUserData=get(xpcmngrfigH,'UserData');
   set(0,'showhiddenhandles','off');
   if ~isempty(xpcmngrfigScH)
       xpcmngrUserData.api.scViewer.closeScViewer(xpcmngrfigScH,[],[])
       %delete(xpcmngrfigScH)
   end

   try
      downloadtg(src,menuLabel,xpcmngrUserData)
   catch
      errordlg(lasterr)
   end   
   timerreset(timerStatus,xpcmngrUserData.timerObj)
   return
end
%---------------*
if strcmp(get(src,'Tag'),'TgStop')
    stop(xpcmngrUserData.timerObj)
    try
        tg=gettg(tree);
        stop(tg);
        updateToolbar(xpcmngrUserData.toolbar,'startapp','on')
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')
    catch
        errordlg(lasterr)
    end    
    timerreset(timerStatus,xpcmngrUserData.timerObj)
   return       
end

if strcmp(get(src,'Tag'),'TgStart')
    stop(xpcmngrUserData.timerObj)
    try
        tg=getTG(tree);
        start(tg);
        updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
        updateToolbar(xpcmngrUserData.toolbar,'stopapp','on')
    catch
        errordlg(lasterr)
    end       
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return           
end
%---------------*
if strcmp(get(src,'Tag'),'TgUnload')
    stop(xpcmngrUserData.timerObj)
    %xpc_unloadTGapp
    try
        tg=gettg(tree);
        feval(xpcmngr('UnloadApp'),tg);
        feval(xpcmngrTree('UnloadApp'),tree);
    catch
        errordlg(lasterr);
    end
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return           
end
%---------------*
if (strcmp(menuLabel,'Add host scope') | ...
    strcmp(menuLabel,'Add target scope') | ...
    strcmp(menuLabel,'Add file scope') )
    stop(xpcmngrUserData.timerObj)
    try
        tg = gettg(tree);         
        scopeid=feval(xpcmngr('AddxPCScope'),tg,tree);        
        feval(xpcmngrTree('AddScope'),tree,scopeid);
        set(0,'showhiddenhandles','on');        
        scfigH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
        set(0,'showhiddenhandles','off');
        %if dealing with host scopes and the viewer is up and running
        if (findstr('Host',tree.SelectedItem.Text)) & ~isempty(scfigH)
            %stop(xpcmngrUserData.timerObj)
            fcnh1=xpcmngrUserData.api.scViewer.delAllScAxes;
            fcnh=xpcmngrUserData.api.scViewer.createAllScAxes;
            scViewerUserData=feval(fcnh1,xpcmngrUserData.scfigure);
            set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
            scViewerUserData=feval(fcnh,xpcmngrUserData.scfigure,tg);            
            set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
            %start(xpcmngrUserData.timerObj)        
        end
    %i_AddScopeNode(menuLabel,xpcmngrUserData.treeCtrl,scopeid);
        %xpcmngrUserData=feval(@xpcmngrViewPanel,'HostSc',xpcmngrUserData);
    catch
        errordlg(lasterr)
    end
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return           
end
%---------------*
if strcmp(get(src,'Tag'),'HostScopeView')
   stop(xpcmngrUserData.timerObj)
   tg = gettg(tree); 
   xpcmngrUserData=xpcmngrScopeViewer('createScViewer',xpcmngrUserData,tg);    
   set(xpcmngrUserData.figure,'userdata',xpcmngrUserData)
   timerreset(timerStatus,xpcmngrUserData.timerObj)
   return           
end        
%---------------*    
if strcmp(get(src,'Tag'),'DelScopes')
    stop(xpcmngrUserData.timerObj)
    try
        tg = gettg(tree); 
        sc=tg.getscope;
        scopids=xpcgate(tg.port,'getscopes',lower(tree.SelectedItem.Text(1:end-9)));
        xpcgate(tg.Port, 'delscope', scopids);
        scIndex=tree.SelectedItem.Index;
        scch=tree.SelectedItem.Children;
        for i=1:scch
            tree.Nodes.Remove(tree.SelectedItem.child.Index);
        end
    catch
       errordlg(lasterr)       
    end
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return       
end  
%---------------*    
if (strcmp(menuLabel,'Delete') & strcmp(get(src,'Tag'),'RemSc'))            
    stop(xpcmngrUserData.timerObj)
    scopeidstr=xpcmngrUserData.treeCtrl.SelectedItem.Text;
    scopeid=scopeidstr(8:end);
    scopeid=eval(scopeid);
    try
        tg = gettg(tree);
        sc = tg.getscope(scopeid);
        scType=sc.Type;
        feval(xpcmngr('RemoveScopeid'),tg,scopeid);%remove from tg
        feval(xpcmngrTree('RemoveScopeeIdNode'),tree)
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
%---------------*Start Sc---------
if (strcmp(menuLabel,'Start') & strcmp(get(src,'Tag'),'StartSc'))
    stop(xpcmngrUserData.timerObj)
    try
        tg = gettg(tree);
        scopeidstr=xpcmngrUserData.treeCtrl.SelectedItem.Text;
        scopeid=scopeidstr(8:end);
        scopeid=eval(scopeid);
        feval(xpcmngr('StartScopeid'),tg,scopeid,tree);
    catch
        errordlg(lasterr);
    end
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return       
end
%---------------*Stop Sc-------------
if (strcmp(menuLabel,'Stop') & strcmp(get(src,'Tag'),'StopSc'))            
    stop(xpcmngrUserData.timerObj)
    try
        tg = gettg(tree);
        scopeidstr=xpcmngrUserData.treeCtrl.SelectedItem.Text;
        scopeid=scopeidstr(8:end);
        scopeid=eval(scopeid);
        feval(xpcmngr('StopScopeid'),tg,scopeid,tree);        
        %xpc_stopScid(scopeid,xpcmngrUserData.treeCtrl)
    catch
        errordlg(lasterr);
    end
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return       
end
%---------------*
if (strcmp(get(src,'Tag'),'AddScopeMenu'))
    stop(xpcmngrUserData.timerObj)
    sigName=xpcmngrUserData.treeCtrl.SelectedItem.Tag;    
    scopeId=eval(menuLabel(7:findstr('(',menuLabel)-1)); 
    tg=gettg(xpcmngrUserData.treeCtrl);
    sigInfo=findbio(tree,sigName);
    if (sigInfo.sigWidth > 1)
       dims=sigInfo.dim;
       answer=xpcmngrsigSelect(get(xpcmngrUserData.figure,'Position'),sigInfo);
       if isempty(answer)
            timerreset(timerStatus,xpcmngrUserData.timerObj)
            return       
       end
       rowIdx=answer.rows;
       colIdx=answer.cols;
       numofSig2Add=length(rowIdx)*length(colIdx);
       idxVec=1:sigInfo.sigWidth;
       idxVec=reshape(idxVec,dims(1),dims(2));
       if (numofSig2Add > 10)
          errordlg('To many signals selected to add.')
          timerreset(timerStatus,xpcmngrUserData.timerObj)
          return       
       end 
       sigOnSc=xpcgate(tg.Port, 'getscsignals', scopeId);
       if ((length(sigOnSc) + numofSig2Add) > 10)
          errordlg('To many signals selected')
          timerreset(timerStatus,xpcmngrUserData.timerObj)
          return       
       end 
          
       try
          idxVecIdx=idxVec(rowIdx,colIdx);
       catch
          timerreset(timerStatus,xpcmngrUserData.timerObj)
          return       
       end
       if (isempty(colIdx) | isempty(rowIdx)) 
           timerreset(timerStatus,xpcmngrUserData.timerObj)
           return
       end
       for i=1:length(idxVecIdx)
            str=['/s',sprintf('%d',idxVecIdx(i))];
            siglist{i}=[xpcmngrUserData.treeCtrl.SelectedItem.Tag,str];           
       end
    else
        siglist={sigName};
    end
    for k=1:length(siglist);
        try
            sigName=siglist{k};
            %sigsonSc=xpcgate('getscsignals',axscopeusrdata.scopeobj.ScopeId)
            sigcheck=feval(xpcmngr('AddSigId2ScId'),tg,sigName,scopeId);
            %sigcheck=xpc_AddSignal2Scope(sigName,scopeId,xpcmngrUserData.treeCtrl);
            if (sigcheck)
                feval(xpcmngrTree('AddSig2ScopeIdNode'),tree,get(src,'Label'),sigName);
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
        end
    end%for
    timerreset(timerStatus,xpcmngrUserData.timerObj)
    return       
end
%---------------*
%---------------*
if strcmp(get(src,'Tag'),'RemSigFromScId')
   stop(xpcmngrUserData.timerObj)
   tg=gettg(tree);
   sigName=tree.SelectedItem.Text;
   scopeid=eval(tree.SelectedItem.Parent.Text(8:end));       
   try       
       scType=feval(xpcmngr('RemSigIdfromScId'),tg,sigName,scopeid);
       tree.Nodes.Remove(tree.SelectedItem.Index);
       set(0,'showhiddenhandles','on');        
       scfigH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
       set(0,'showhiddenhandles','off');    
            
       if strcmp(scType,'Host') & ~isempty(scfigH)       %redraw scope Ax
           % stop(xpcmngrUserData.timerObj)
            %xxx To do check is scope view is open
            fcnh1=xpcmngrUserData.api.scViewer.delAllScAxes;
            fcnh=xpcmngrUserData.api.scViewer.createAllScAxes;
            scViewerUserData=feval(fcnh1,xpcmngrUserData.scfigure);
            set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
            scViewerUserData=feval(fcnh,xpcmngrUserData.scfigure,tg);            
            set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
         %   start(xpcmngrUserData.timerObj)                       
       end
        %xpcmngrUserData.treeCtrl.SelectedItem.Tag
    catch
       errordlg(lasterr); 
   end
   timerreset(timerStatus,xpcmngrUserData.timerObj)
   return       
end
%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(get(src,'Tag'),'TriggerSc')
    stop(xpcmngrUserData.timerObj)
    defCol=2147483656;    
    trigCol=2111111;
    check=tree.SelectedItem.Parent.Child;
    while ~isempty(check)
        check.ForeColor=defCol;
        check=check.Next;
    end
    scopeid=eval(tree.SelectedItem.Parent.Text(8:end));     
    sc=tg.getscope(scopeid);
    sigName=tree.SelectedItem.Text;
    try
        sigId=xpcgate(tg.Port,'getsigindex',sigName);
        sc.TriggerSignal=sigId;
        tree.SelectedItem.ForeColor=trigCol;
    catch
        errordlg(lasterr)
    end
   timerreset(timerStatus,xpcmngrUserData.timerObj)
   return        
end
%---------------------
if strcmp(get(src,'Tag'),'GoToSLBlk')
    tree.SelectedItem.Tag;
    idx=findstr(tree.SelectedItem.FullPath,'\');
    mdlsys=tree.SelectedItem.FullPath(idx(1)+1:idx(2)-1);
    open_system(mdlsys);
    blkidx=findstr(':SlBlock:',tree.SelectedItem.key);
    blk=tree.SelectedItem.key(blkidx+10:end);
    set_param(blk,'Selected','on');
    open_system(blk)
    
end
%---------------------
if strcmp(get(src,'Tag'),'Go2SLmdl')
    try
        open_system(tree.selectedItem.Tag);    
    catch
        errordlg(lasterr,'xPC Target Error')
    end
end
%---------------------

if strcmp(get(src,'Tag'),'softTtiggerSc')
   tg = gettg(tree);
   scopeidstr=xpcmngrUserData.treeCtrl.SelectedItem.Text;
   scopeid=scopeidstr(8:end);
   scopeid=eval(scopeid);
   sc=tg.getscope(scopeid);
   sc.trigger;
end

% if xpcmngrUserData.timerObj.enabled==0
%    xpcmngrUserData.timerObj.enabled=1;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function applySettings(src,evt,figH)
allChildrenObj=findobj(figH,'Type','uicontrol');
statTxtH=findobj(allChildrenObj,'Style','text');
pbH=findobj(allChildrenObj,'Style','pushButton');
comH=setdiff(allChildrenObj,[statTxtH;pbH]);
%oldstr=get(comH,'String');
%oldVal=get(comH,'Value');
xpcmngrUserData=get(figH,'Userdata');
tree=xpcmngrUserData.treeCtrl;
tgEnv=xpcGetTarget(xpcmngrUserData.treeCtrl);
%%%
fullpath=tree.SelectedItem.Fullpath;
sepIdx=findstr('\', tree.SelectedItem.Fullpath);
tgNameStr=fullpath(1:sepIdx-1);
tgNameStr=strrep(tgNameStr,' ','');
targetNameStr=tgNameStr;
%%%

for i=1:length(comH)
    comFieldTag=get(comH(i),'Tag');
    comFieldVal=get(comH(i),'Value');
    comFieldString=get(comH(i),'String');
    if ~isempty(comFieldVal)%parameter is a popmenufield
        comFieldString=get(comH(i),'String');
        oldpar=eval(['tgEnv.',comFieldTag]);
        newpar=comFieldString{comFieldVal};
    else
        oldpar=eval(['tgEnv.',comFieldTag]);
        newpar=comFieldString;
    end
   
    if ~strcmp(oldpar,newpar)%changes made apply them
         evalstr=['tree.Targets.',targetNameStr,'.',comFieldTag,' = newpar;'];
         eval(evalstr);
    end  
end

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateToolbar(uitoolH,toolItem,state)
toolH=findobj(uitoolH,'Type','UIToggletool','Tag',toolItem);
if ~isempty(toolH)
    set(toolH,'enable',state);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function connect(xpcmngrUserData)
tree=xpcmngrUserData.treeCtrl;
tree.Freeze;
tg=feval(xpcmngr('ConnectTargetPC'),xpcGetTarget(tree),tree);
if isempty(tg)
    tree.UnFreeze;
    return
end

if strcmpi('No',tg.Connected)
    tree.UnFreeze;
    return
end
if strcmp(tg.Connected,'Yes') & ~strcmp(tg.application,'loader')
    %updateMenuLabes(figH,'Target','on')
    feval(xpcmngrUserData.drawPanelapi.menufcn,...
        xpcmngrUserData.figure,'Target','on');
end
feval(xpcmngrTree('ConnectTargetPC'),tree);
%tg=xpcGETTG(tree);
if strcmp(tg.application,'loader')
    tree.UnFreeze;
    return
else%poulate tg app node
    system=tg.Application;
    %feval(tree.Api.populateTreeAppNode,tree,system,tg);
    tree.Api.populateTreeAppNode(tree,system,tg)
end
tree.UnFreeze;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function downloadtg(src,menuLabel,xpcmngrUserData)
tree=xpcmngrUserData.treeCtrl;
tgPCstring=strrep(menuLabel(20:end),' ','');
dlmName=tree.SelectedItem.Text;
%tg = xpcGetTG(tree,tgPCstring);
tg=gettg(tree,tgPCstring);
feval(xpcmngr('Download2Target'),tg,dlmName)
feval(xpcmngrTree('Download2Target'),tree,src,tg)
%To do update any lists that may be in panel
if isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
    list=xpcmngrUserData.listCtrl;
    list.Font.Size=11;
    set(list.ListItems.Item(5).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.SampleTime))
    set(list.ListItems.Item(6).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.AvgTeT))
    set(list.ListItems.Item(7).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.ExecTime))
end%isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timerreset(chksum,timerObj)
if chksum==1
   start(timerObj)
else
   stop(timerObj)
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

