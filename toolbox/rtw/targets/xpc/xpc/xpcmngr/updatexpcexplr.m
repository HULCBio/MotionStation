function updatexpcexplr(varargin)
% UPDATEEXPCEXPLR - xPC Target Manager GUI
%    UPDATEEXPCEXPLR Timer function Callback to update the xPC Target Manager
%    GUI.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $

timerObj=varargin{1};



set(0,'showhiddenhandles','on');
xpcmngrfigH=findobj(0,'Type','Figure','Tag','xpcmngr');
set(0,'showhiddenhandles','off');

if isempty(xpcmngrfigH)
    stop(timerObj)    
    return
end
xpcmngrUserData=get(xpcmngrfigH,'Userdata');    
tree=xpcmngrUserData.treeCtrl;

%disp mag
%tree.timerflag=1;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    updateCurWorkDir(tree);
    %%%%%%%%%%%%%%%%%%%%%%%%
    %Here we syncronise Connected tree(Target Nodes) with its targets
    updateTargetNodes(tree);
    
    %update current seleted Item
    updateTreeSelectedItem(xpcmngrUserData,tree)
    %timercc6callback(xpcmngrUserData,tree)
%timercc6callback(xpcmngrUserData,tree)
%EOF%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Update Target Nodes***
function updateTargetNodes(tree)
alltgNames=tree.GetAllNames;
targetkeysIdx=strmatch('TGPC',tree.GetAllKeys);
targets_str=alltgNames(targetkeysIdx);
targetpcMap=tree.TargetPCMap;

for i=1:length(targets_str)%for each target Node we get its truth and render
    %%BEGIN FOR i%%
    tgpcTreeIdx=targetkeysIdx(i);
    tgpcNameStr=targets_str{i};
    targetpcMap=tree.TargetPCMap;
    idxfound=strmatch(tgpcNameStr,targetpcMap(:,2),'exact');
    treetgpcstr=targetpcMap{idxfound,1};    
    evalstr=['get(tree,','''',treetgpcstr,'''',');'];
    tg=eval(evalstr);
    if ~isempty(tg) %never be inialtized, dont do anything
        %check to see if is handle or not
        if ~isa(tg,'xpctarget.xpc') %if is handle
            feval(xpcmngrTree('Disconnect'),tree)
            set(tree,treetgpcstr,[])                        
            %reinitalize  tree.targetPC=[]
        else
            %check comm
            if strcmpi(tg.connected,'No')
                %must reset the tree and data structure to its d/c state
                set(tree,treetgpcstr,[])
                tree.api.disconnetTargetNode(tree,[],[],tgpcTreeIdx)                
%                feval(xpcmngrTree('Disconnect'),tree)
            else
                updateIndivTarget(tree,tgpcTreeIdx,tg)
            end
        end
    end%~isempty(tg)
end %%END FOR i%%
%%%EOF------------------
function updateIndivTarget(tree,tgpcTreeIdx,tg)
%we first check if we have a node available
if ~isempty(tree.Node.Item(tgpcTreeIdx).child.next)
    %we have a app node. Sync this node
    tgAppNodeLabel=tree.Node.Item(tgpcTreeIdx).child.next.text;
    if ~strcmp(tgAppNodeLabel,tg.application)
       % feval(xpcmngrTree('Download2Target'),tree,tg,tg,tgpcTreeIdx)
        tree.api.populateTreeAppNode(tree,tg,tg,tgpcTreeIdx)
        tree.selectedItem=tree.Nodes.Item(1);
        i_HidePanelChildObj(tree.figHandle);
        xpcmngrUserData=get(tree.figHandle,'Userdata');
        tree.SelectedItem=tree.Node.Item(tgpcTreeIdx);
        rendertgAppNode(xpcmngrUserData,tg);
        
        %xpcmngrUserData=feval(xpcmngrUserData.drawPanelapi.root,xpcmngrUserData);
        %set(xpcmngrUserData.subbarCtrl.Panels.Item(1),'text',['DLM(s) ',pwd])
        %set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData)  
        tree.sigInfo=[];
    end
    xpcScopeNodeIdx=tree.Node.Item(tgpcTreeIdx).child.next.child.next.Index;
    updatexPCScopeNodes(tree,xpcScopeNodeIdx,tg)
else %here we have a connection but no app Node.
    feval(xpcmngrTree('Download2Target'),tree,tg,tg,tgpcTreeIdx)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function updatexPCScopeNodes(tree,xpcScopeNodeIdx,tg)
% Need to check for each scope Type individually 
% and sync accrodingly

%--
sc=tg.getscope;
allTypes=get(sc,'Type');
%--

%Here we sync All Host scopes Nodes with target
hostscid=strmatch('Host',allTypes,'exact');
hostScNodeIdx=tree.Nodes.Item(xpcScopeNodeIdx).Child.Index;
hsc_ch=tree.Nodes.Item(xpcScopeNodeIdx).Child.Children;%num of host sc in node
updateScopeIdNodeTree(tree,hostscid,hostScNodeIdx,hsc_ch,sc,15)

%Here we sync All target scopes Nodes with target
tgscid=strmatch('Target',allTypes,'exact');
tgScNodeIdx=tree.Nodes.Item(xpcScopeNodeIdx).Child.next.Index;
tsc_ch=tree.Nodes.Item(xpcScopeNodeIdx).Child.next.Children;
updateScopeIdNodeTree(tree,tgscid,tgScNodeIdx,tsc_ch,sc,14)

%Here we sync All File scopes Nodes with target
filescid=strmatch('File',allTypes,'exact');
fileScNodeIdx=tree.Nodes.Item(xpcScopeNodeIdx).Child.next.next.Index;
fsc_ch=tree.Nodes.Item(xpcScopeNodeIdx).Child.next.next.children;
updateScopeIdNodeTree(tree,filescid,fileScNodeIdx,fsc_ch,sc,13)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScopeIdNodeTree(tree,scid,scNodeIdx,sc_ch,sc,ico)

if ~(length(scid) == sc_ch)
    for j=1:sc_ch
        tree.Nodes.Remove(tree.Nodes.Item(scNodeIdx).child.Index);
    end
    for jj=1:length(scid)
            scObj=sc(scid(jj));
            ne=tree.Nodes.Add(scNodeIdx,4);
            ne.Text=['Scope: ',sprintf('%d',scObj.Scopeid)];    
            ne.Key=['HScid',sprintf('%d',rand)];
            ne.Image=ico;
            scidIndex=ne.index;        
    end
else %scopes are in sync, now we must make sure each indiv scope sigs are in sync
    scidNode=tree.Nodes.Item(scNodeIdx).child;
    while ~isempty(scidNode)
        scopeid=eval(scidNode.text(8:end));
        scObj=sc(1).up.getscope(scopeid);
        scsigs=xpcgate(scObj.port,'getscsignals',scObj.scopeId);
        sciNode_ch=scidNode.children;%num of signal under each Host Sp id
        if sciNode_ch ~= length(scsigs)
            %childidx=tree.Nodes.Item(hostScNodeIdx).child.child.Index;
            %if ~isempty(scidNode.child)
                while~(scidNode.Children==0)
                     tree.Nodes.Remove(scidNode.child.Index);
                end
            %end
            for ii_s=1:length(scsigs)
                scidNode.expanded=1;
                sigid2Add=scsigs(ii_s);
                ne=tree.Nodes.Add(scidNode.Index,4);
                ne.Text=xpcgate(scObj.port,'getsignalname',sigid2Add);
                
                ne.Image=9;
                ne.key=['xPCSigScope',sprintf('%d',rand)];
            end            
        end        
        scidNode=scidNode.Next;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function updateCurWorkDir(tree);
idx=tree.Nodes.Item(1).child.next.Index;
dirStr=tree.Nodes.Item(idx).Text;
dirStr=dirStr(9:end);
chcksum=[];
if ~strcmp(dirStr,pwd)
    set(tree.Nodes.Item(idx),'Text',['DLM(s): ',pwd]);
    %tree.Nodes.Item(idx).Text=['DLM(s):',pwd];
    chcksum=1;
    dlmChildren=tree.Nodes.Item(idx).Children;
    try
        dlmstree=cellstr(strvcat(tree.GetAllNames ...
            {find(cellfun('isempty',regexp(tree.GetAllKeys,'.dlm'))==0)}));
    catch%%case when there is no dlms in tree
        dlmstree=[];
    end
    dlmNames=checkdirdlm;
    for j=1:dlmChildren
       tree.Nodes.Remove(tree.Nodes.Item(tree.Nodes.Item(idx).Child.Index).Index)
    end   %add new ones
    for i=1:length(dlmNames)
        ne=tree.Nodes.Add(idx,4);
        ne.Text=dlmNames{i};
        ne.Image=4;
        ne.Key=['dlmtgapp',dlmNames{i}];    
        %ne.Key=dlmNames{i};    
    end        
else
    
end
pwdIdx=idx;
dlmChildren=tree.Nodes.Item(idx).Children;
%dlmIds=find(cellfun('isempty',regexp(tree.GetAllKeys,'.dlm'))==0);
try
    dlmstree=cellstr(strvcat(tree.GetAllNames ...
        {find(cellfun('isempty',regexp(tree.GetAllKeys,'.dlm'))==0)}));
catch%%case when there is no dlms in tree
    dlmstree=[];
end
dlmNames=checkdirdlm;
if isempty(dlmNames)
    for j=1:dlmChildren
        tree.Nodes.Remove(tree.Nodes.Item(idx).Child.Index)        
    end
    %return
elseif ~isempty(setdiff(dlmNames,dlmstree)) | (length(dlmNames) ~= length(dlmstree))    
        %remove dlm node
    for j=1:dlmChildren
       tree.Nodes.Remove(tree.Nodes.Item(tree.Nodes.Item(idx).Child.Index).Index)
    end   %add new ones
    for i=1:length(dlmNames)
        ne=tree.Nodes.Add(idx,4);
        ne.Text=dlmNames{i};
        ne.Image=4;
        ne.Key=['dlmtgapp',dlmNames{i}];    
        %ne.Key=dlmNames{i};    
    end        
end
%%%%-------------------------------
function dlmNames=checkdirdlm
d=dir('*.dlm');
if isempty(d)
   dlmNames=[];
   return 
end
dlmNames=cellstr(strvcat(d.name));
%%%%-------------------------------


function updateTreeSelectedItem(xpcmngrUserData,tree)

if ~isempty(xpcmngrUserData.scfigure)
    scUserData=get(xpcmngrUserData.scfigure,'userdata');
    refreshscopes(xpcmngrUserData.scfigure,scUserData.tg)
end

if ~isempty(tree.SelectedItem)
    %tg=gettg(tree);
    %tg.application;
    %updateSigTable
    if findstr(tree.SelectedItem.Key,'xPCSIG')
        sigInfo=tree.sigInfo;
        xpcmngrUserData.sigViewer;
        updatesigViewer(xpcmngrUserData.sigViewer,gettg(tree),sigInfo)
    end
    %updateSigTable
    if findstr(tree.SelectedItem.Key,'tgAppNode')
        tg=gettg(tree);
        if ~strcmp(tg.application,'loader')
            if isa(xpcmngrUserData.tgapplistCtrl,'COM.MWXPCControls_listviewctrl')
                list=xpcmngrUserData.tgapplistCtrl;
                list.Font.Size=11;
                set(list.ListItems.Item(3).listsubItems.Item(1),'Text',sprintf('%0.4f',tg.ExecTime))
            end
        end
    end
    %------------------------
    if findstr(tree.SelectedItem.Key,'TGPC')
        tg=gettg(tree);
        if ~isempty(tg)
            if ~strcmp(tg.application,'loader')
                if isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
                    list=xpcmngrUserData.listCtrl;
                    list.Font.Size=11;
                    set(list.ListItems.Item(5).listsubItems.Item(1),'Text',sprintf('%0.6g',tg.SampleTime))
                    set(list.ListItems.Item(6).listsubItems.Item(1),'Text',sprintf('%0.6f',tg.AvgTeT))
                    set(list.ListItems.Item(7).listsubItems.Item(1),'Text',sprintf('%0.6f',tg.ExecTime))
                end%isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
            end %~strcmp(tg.application,'loader')
        end%~isempty(tg)
    end%findstr(tree.SelectedItem.Key,'TGPC')
    %------------------------
    if findstr(tree.SelectedItem.Key,'Scid')
        tg=gettg(tree);
        if ~isempty(tg)
            scIdx=eval(tree.SelectedItem.Text(7:end));
            sc=tg.getscope(scIdx);
            updateScPanel(sc,xpcmngrUserData)
        end%~isempty(tg)
    end%findstr(tree.SelectedItem.Key,'TGPC')
    %------------------------

end%~isempty(tree.SelectedItem)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refreshscopes(figH,tg)    
%disp mag
%xpcmngrUserData=get(figH,'UserData');
%stop(xpcmngrUserData.timerObj)
%Common Controls that require refreshing%%%%%%%%%%%%
%tg=xpc;
   % refreshHostmngr(xpcmngrUserData)
   %figH=xpcmngrUserData.scfigure;
   scopemngrUserdata=get(figH,'Userdata');
   %AllAxesScopes=scopemngrUserdata.scopeAxes;%from gui
   AllAxesScopes=scopemngrUserdata.scmngr.Scope.scaxes;
   xpcscopes=xpc_getAllschost(tg); %from target
   if isempty(AllAxesScopes)
      return
   end
   nscopes=length(AllAxesScopes);
   if (nscopes == xpcscopes)
      error('axes does not match scopes on target')
      return
   end
   
   for i=1:nscopes
       %disp sam
       axscopeusrdata=get(AllAxesScopes(i),'Userdata');       
       scObj=axscopeusrdata.scopeobj;
       %scObj.Status;
       xpcscsigs=xpcgate(tg.port,'getscsignals',axscopeusrdata.scopeobj.ScopeId);
       line_plot=axscopeusrdata.line_plot;
       text_plot=axscopeusrdata.txt_numerical;
       %-scObj;
       %scObj.Status
       if strcmp(scObj.Status,'Finished')
           ydata=scObj.Data;
           tdata=scObj.Time;
           %disp hello
               for ii=1:length(line_plot)
                   color=get(line_plot(ii),'color');
                   if strcmp(get(axscopeusrdata.cmenu.root.viewmode.GraphItem,'checked'),'on')
                       set(text_plot,'visible','off')
                       set(line_plot,'visible','on') 
                       set(AllAxesScopes(i), 'XLim',[tdata(1), tdata(end)]);
                       %color=get(line_plot(ii),'Userdata');
                       %disp hello
                       line_plot(ii);
                       get(line_plot(ii),'xData');
                       set(line_plot(ii), 'XData',  tdata','YData',  ydata(:,ii)');
                   else
                      set(text_plot,'visible','on') 
                      set(line_plot,'visible','off') 
                      len=get(AllAxesScopes(i),'position');
                      len=len(4);
                      
                      set(text_plot(ii), ...
                        'Position', [0.25 1.2-len-(ii*0.09) 0], ...
                        'Visible',  'on',            ...
                        'String',   num2str(ydata(1,ii)),   ...
                        'Color',    color);                       
                   end               
          end               
           +scObj;
       end
   end%for i=1:nscopes
       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allschostObjs=xpc_getAllschost(tg)

allsc=getscope(tg);
 if ~isempty(allsc)
     scTypescell=get(allsc,'Type');
     if ~isempty(scTypescell)
         HostscIdx=strmatch('Host',scTypescell,'exact');
         allschostObjs=allsc(HostscIdx);
     end
 else
     allschostObjs=[];
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function targetStr=getTargetString(tree)

if findstr(tree.SelectedItem.Key,'TGPC')    
    targetStr=tree.SelectedItem.Text;
else
    fullpath=tree.selectedItem.Fullpath;
    sepIdx=findstr('\', tree.selectedItem.Fullpath);
    targetStr=fullpath(1:sepIdx-1);    
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updatesigViewer(table,tg,sigInfo)
if ~isa(table,'COM.MWXPCControls_mshflexgridCtrl')
   return 
end
sigName=sigInfo.blkName;
dims=sigInfo.dim;
rows=dims(1);
cols=dims(2);
sigWidth=sigInfo.sigWidth;
% sigAx.FixedRows=0;          
% sigAx.FixedCols=0;
sigAx.Rows=rows+1;
sigAx.Cols=cols+1;
sigName=sigInfo.blkName;

if (sigInfo.sigWidth == 1)
    sigid=tg.getsignalid(sigName);
    sigVals=tg.getsignal(sigid); 
else 
    for i=1:sigInfo.sigWidth        
        sigid=tg.getsignalid([sigName,'/s',sprintf('%d',i)]);
        sigVals(i)=tg.getsignal(sigid);    
    end
end

if (sigInfo.sigWidth == 1)
    sigid=tg.getsignalid(sigName);
    sigVals=tg.getsignal(sigid); 
else 
    for i=1:sigInfo.sigWidth        
        sigid=tg.getsignalid([sigName,'/s',sprintf('%d',i)]);
        sigVals(i)=tg.getsignal(sigid);    
    end
end
sigVals=reshape(sigVals,rows,cols);
[m,n]=size(sigVals);

table.col=0;
for ii=1:rows
    table.row=ii;
    table.Text=sprintf('%d',ii);    
end

table.row=0;
for jj=1:cols
    table.col=jj;
    table.Text=sprintf('%d',jj);    
end        
        

for r=1:m
    table.row=r;
    for c=1:n        
        table.col=c;
        table.Text=sprintf('%0.3f',sigVals(r,c));
        %table.CellFontWidth =3;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScPanel(sc,xpcmngrUserData)
if ~strcmp(sc.Status,'Interrupted') 
    updateMenus(xpcmngrUserData.figure,'NumSamples','off')
    updateMenus(xpcmngrUserData.figure,'Decimation','off')
    updateMenus(xpcmngrUserData.figure,'TriggerMode','off')
    updateMenus(xpcmngrUserData.figure,'TriggerLevel','off')
    updateMenus(xpcmngrUserData.figure,'TriggerSlope','off')
    updateMenus(xpcmngrUserData.figure,'NumPrePostSamples','off')            
elseif (strcmp(sc.Status,'Finished') | strcmp(sc.Status,'Interrupted') )
    updateMenus(xpcmngrUserData.figure,'NumSamples','on')
    updateMenus(xpcmngrUserData.figure,'Decimation','on')
    updateMenus(xpcmngrUserData.figure,'TriggerMode','on')
    updateMenus(xpcmngrUserData.figure,'TriggerLevel','on')
    updateMenus(xpcmngrUserData.figure,'TriggerSlope','on')
    updateMenus(xpcmngrUserData.figure,'NumPrePostSamples','on')     
end

if isa(xpcmngrUserData.scidlistCtrl,'COM.MWXPCControls_listviewctrl')
    list=xpcmngrUserData.scidlistCtrl;
    list.Font.Size=11;
    set(list.ListItems.Item(3).listsubItems.Item(1),'Text',sc.Status)
end%isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')

%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateMenus(figH,menuItem,state)
menuH=findobj(figH,'Type','UIControl','Tag',menuItem);
if ~isempty(menuH)
    set(menuH,'enable',state);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateToolbar(uitoolH,toolItem,state)
toolH=findobj(uitoolH,'Type','UIToggletool','Tag',toolItem);
if ~isempty(toolH)
    set(toolH,'enable',state);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Make Global
function rendertgAppNode(xpcmngrUserData,tg)
figH=xpcmngrUserData.figure;

updateToolbar(xpcmngrUserData.toolbar,'DelTGPC','on')
updateToolbar(xpcmngrUserData.toolbar,'Connect','on')
i_HidePanelChildObj(figH)
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