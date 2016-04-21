function subhandle=xpcmngrTree(varargin)
%XPCMNGRTREE xPC Target GUI
%   XPCMNGRTREE manages the Tree in the xPC Target Manager GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $

Action = varargin{1};
args   = varargin(2:end);

switch Action,

case 'getLocalhandles'
    tree=args{1};
    treeapih=[];
    treeapih.populateTreeAppNode=@i_populateTGAppNode;
    treeapih.popscopeNodes=@i_createChildrenScopeNodes;
    treeapih.populateTargetNode=@i_AddTargetNode;
    treeapih.renameTargetNode=@i_RenameTargetNode;
    treeapih.removeTargetNode=@i_RemoveTargetNode;
    treeapih.disconnetTargetNode=@i_DisConnectTargetNode;
    
    tree.addproperty('api');
    tree.api=treeapih;
    subhandle=[];
case 'InitTree'
    subhandle=@i_populatexpcMngrTree;
    return
case 'AddTargetNode'
    subhandle=@i_AddTargetNode;
    return
case 'ConnectTargetPC'
    subhandle=@i_ConnectTargetNode;
    return
case 'RemTargetPC'
    subhandle=@i_RemoveTargetNode;
    return
case 'RenameTargetPC'
    subhandle=@i_RenameTargetNode; 
    return
case 'Download2Target'
    subhandle=@i_populateTGAppNode;
    return
case 'UnloadApp'
    subhandle=@i_RemovetgAppNode;
    return
case 'Disconnect'
    subhandle=@i_DisConnectTargetNode;
    return
case 'AddScope'
    subhandle=@i_AddScopeNode;
    return
case 'RemoveScopeeIdNode'
    subhandle=@i_RemoveScopeIdNode;
    return
case 'AddSig2ScopeIdNode'
    subhandle=@i_addSignalNode2ScopeTree;
    return
case 'searchTreeforTgIndex'
    %subhandle=@treeNodeIdxofTG;
otherwise,
    error(['Invalid action: ' Action]);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_populatexpcMngrTree(tree)

xpcmngrTree('getLocalhandles',tree);

ne=invoke(tree.nodes,'Add');  %root
tree.SelectedItem=ne;
%tree.DropHighlight=ne;
ne.Text='Host PC Root';
%ne.Tag='Inst';
ne.expanded=1;
ne.Image=1;
ne.Key='HostPC';
Count=tree.nodes.Count;

ne=invoke(tree.nodes,'Add',Count,4);  %root
ne.Text='Compiler(s) Configuration';
%ne.Tag='Inst';
ne.expanded=0;
ne.Image=17;
ne.Key='HostConf';
Count=tree.nodes.Count;

%ne=invoke(tree.nodes,'Add',Count,4);  %root
%ne.Text='Compiler(s)';
%ne.Tag='Inst';
%ne.expanded=0;
%ne.Image=2;
%ne.Key='HostConf123';
%Count=tree.nodes.Count;

% ne=invoke(tree.nodes,'Add',1,4);  %root
% ne.Text='DLM(s)';
% %ne.Tag='Inst';
% ne.expanded=1;
% ne.Image=6;
% ne.Key=':-)';
% Count=tree.nodes.Count;

ne=invoke(tree.nodes,'Add',1,4);  %root
ne.Text=['DLM(s): ',pwd];
%ne.Tag='Inst';
ne.expanded=1;
ne.Image=5;
ne.Key='pwdDLM';
%Count=xpcmngrUserData.treeCtrl.nodes.Count;
i_populateCDDLMnode(tree.Nodes)

% ne=invoke(tree.nodes,'Add',Count,4);  %root
% ne.Text='MATLAB Path';
% %ne.Tag='Inst';
% %ne.expanded=1;
% ne.Image=5;
% ne.Key='MLPathDLM';
% Count=tree.nodes.Count;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_populateCDDLMnode(Nodes)
d=dir('*.dlm');
if isempty(d)
   return 
end
dlmNames=cellstr(strvcat(d.name));
count=Nodes.Count;
for i=1:length(dlmNames)
    ne=Nodes.Add(count,4);
    ne.Text=dlmNames{i};
    ne.Image=4;
    ne.Key=['dlmtgapp',dlmNames{i}];    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [targetName,targetIdx]=i_AddTargetNode(tree)


env=getxpcenv;
S=cell2struct(env.actpropval,env.propname,2);
tgs=tree.Targets;
targetpcs=tree.TargetPCMap;


S.tg=[];
if isempty(tgs)
   tgStruct=[]; 
   tree.Targets=tgStruct;
end
%tgName=maketgname(tree)
alltgNames=tree.GetAllNames;
tgNameIdx=strmatch('TGPC',tree.GetAllKeys);
allidxtgNames=alltgNames(tgNameIdx);
tgpcNodes=length(strmatch('TGPC',tree.GetAllKeys));
thistgName=['TargetPC',sprintf('%d',tgpcNodes+1)];
kk=tgpcNodes;
while 1
    if isempty(strmatch(thistgName,allidxtgNames,'exact'))
        break
    end    
    kk=kk+1;
    thistgName=['TargetPC',sprintf('%d',kk)];
end

%ne=tree.nodes.Add(1,4);
ne=tree.nodes.Add;
ne.Text=thistgName;

ne.Key=['TGPC',sprintf('%d',rand)];
ne.Image=18;

targetName = ne.Text;
targetIdx = ne.Index;
str=['tree.Targets.',strrep(ne.Text,' ',''),'= S;'];
tree.addproperty(ne.Text);
eval(str);
targetpcs(end+1,:)={ne.Text, ne.Text};%{'tree prop','map Name'}
tree.TargetPCMap=targetpcs;
% evalstr=['get(tree,','''',tree.SelectedItem.Text,'''',')'];


%Add Target Configuretion Node
Count=tree.nodes.Count;
ne=tree.nodes.Add(Count,4);
ne.Text='Configuration';
ne.Key=['TGconfig',sprintf('%d',tree.nodes.Count),sprintf('%d',rand)];
ne.Image=17;
ne.Expanded=1;

Count=tree.nodes.Count;
ne=tree.nodes.Add(Count,4);
ne.Text='Communication';
ne.Key=['TGconfigCOMM',sprintf('%d',tree.nodes.Count),sprintf('%d',rand)];
ne.Image=2;
ne.Expanded=1;

%Count=tree.nodes.Count;
ne=tree.nodes.Add(Count,4);
ne.Text='Settings';
ne.Key=['TGconfigSets',sprintf('%d',tree.nodes.Count),sprintf('%d',rand)];
ne.Image=2;
ne.Expanded=1;

ne=tree.nodes.Add(Count,4);
ne.Text='Appearance';
ne.Key=['TGconfigDisp',sprintf('%d',tree.nodes.Count),sprintf('%d',rand)];
ne.Image=2;
ne.Expanded=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_ConnectTargetNode(tree)
tree.SelectedItem.Image=3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_DisConnectTargetNode(tree,tgName,evt,targetNodeIdx)
if (nargin == 1)
    if ~isempty(tree.selectedItem.Child.Next)
    	tree.Nodes.Remove(tree.selectedItem.Child.Next.Index);
    end
    tree.SelectedItem.Image=18;
end

if (nargin > 1) & (nargin < 4)
     fullpath=tree.SelectedItem.Fullpath;
     sepIdx=findstr('\', tree.SelectedItem.Fullpath);
     targetNameStr=fullpath(1:sepIdx-1);
     allNames=tree.GetAllNames;
     tgtreeIdx=strmatch(targetNameStr,allNames,'exact')    
     tree.Nodes.Remove(tree.selectedItem.Child.Next.Index);
     tree.Nodes.Item(tgtreeIdx).Image=18;
end

if (nargin == 4)
    tree.Nodes.Remove(tree.Nodes.Item(targetNodeIdx).Child.Next.Index);
    tree.SelectedItem.Image=18;
end
xpcmngrUserData=get(tree.figHandle,'UserData');
tree.sigInfo=[];
% if isa(xpcmngrUserData.tgapplistCtrl,'COM.MWXPCControls_listviewctrl')
%     list=xpcmngrUserData.tgapplistCtrl;
%     list.Font.Size=11;
%     set(list.ListItems.Item(3).listsubItems.Item(1),'Text',sprintf('%0.4f',tg.ExecTime))
% end
if isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
   list=xpcmngrUserData.listCtrl;
   set(list.ListItems.Item(1).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(2).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(3).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(4).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(5).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(6).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(7).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(9).listsubItems.Item(1),'Text','')
   set(list.ListItems.Item(8).listsubItems.Item(1),'Text',tree.SelectedItem.Text)
   set(list.ListItems.Item(9).listsubItems.Item(1),'Text','No')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_RemoveTargetNode(tree)
if isempty(findstr(tree.SelectedItem.Key,'TGPC'))
    errordlg('Selecte a Target PC Node to delete','xPC Error')
    return
end

targetpcMap=tree.TargetPCMap;
tgName=tree.SelectedItem.Text;
idxfound=strmatch(tgName,targetpcMap(:,2),'exact');
tgpcstr=targetpcMap{idxfound,1};

temptrstr=tree.targets;
temptrstr=rmfield(temptrstr,tgpcstr);
tree.deleteproperty(tgpcstr);
tree.Nodes.Remove(tree.SelectedItem.Index);
tree.targets=temptrstr;
targetpcMap(idxfound,:)=[];
tree.TargetPCMap=targetpcMap;
tree.sigInfo=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_RenameTargetNode(tree) 
tree.StartLabelEdit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_populateTGAppNode(tree,menuLabel,tg,nodeIdx)
%here we need to do some work to find 
%the node index of the Target Node we 
%wish to download the app and then populate it
%with app data
%stop(xpcmngrUserData.timerObj)
xpcmngrUserData=get(tree.figHandle,'UserData');
% stop(xpcmngrUserData.timerObj)
tree.sigInfo=[];
if (ishandle(menuLabel) & ~isa(menuLabel,'xpctarget.xpc')) 
    labeltgstr=get(menuLabel,'label');
    tgstr=labeltgstr(20:end);
    dlmName=tree.SelectedItem.Text;
    system=dlmName(1:end-4);
else
    tgstr=tree.SelectedItem.Text;
    system=tg.application;
end

allNodesStr=tree.GetAllNames;
if nargin < 4    
    nodeIdx=strmatch(tgstr,allNodesStr);%
    tgNameStr=tgstr;
    tgNameStr=strrep(tgNameStr,' ','');
end
if nargin == 4
    tgNameStr=allNodesStr{nodeIdx};
    tg.application;
end

%env=tree.Targets;
% env=eval(['tree.Targets.',tgNameStr]);
% 
% commType=env.HostTargetComm;
% if strcmp(commType,'TcpIp')
%    arg1= 'TcpIp';
%    arg2= env.TcpIpTargetAddress;
%    arg3= env.TcpIpTargetPort;
%    % arg3= xPCtargetPC.xPCtargetPC;
% else%rs232
%    arg1= 'RS232';
%    arg2= env.RS232HostPort;
%    arg3= eval(env.RS232Baudrate);
% end
% tg=xpc(arg1,arg2,arg3);

targetpcMap=tree.TargetPCMap;
idxfound=strmatch(tgNameStr,targetpcMap(:,2),'exact');
tgpcstr=targetpcMap{idxfound,1};

if ~strcmp(tg.Application,'loader')
    evalstr=['get(tree,','''',tgpcstr,'''',');'];
    %evalstr=['tree.Targets.',tgpcstr,'.tg=tg;'];
    eval(evalstr);
    try
        bio=eval([tg.Application,'bio;']);
        pt=eval([tg.Application,'pt;']);
    catch
        errordlg('Target application files are missing','xPC Target Error')
        return
    end
    evalstr=['tree.Targets.',tgpcstr,'.bio=bio;'];
    eval(evalstr);
    evalstr=['tree.Targets.',tgpcstr,'.pt=pt;'];
    eval(evalstr);
end

%%%check for any app Nodes to delete
if ~isempty(tree.Nodes.Item(nodeIdx).Child.Next)
    tree.Nodes.Remove(tree.Nodes.Item(nodeIdx).Child.Next.Index);
end

if strcmp(tg.Application,'loader')
  return
end
try 
    load_system(system)
catch    
    %xpcmngrUserData.timerObj.enabled=1;
    errordlg(lasterr)
    return    
end
ne=tree.nodes.Add(nodeIdx,4);
%tree.selectedItem=ne;
ne.Text=system;
ne.Tag=system;
ne.expanded=1;
ne.Image=4;
ne.Key=['tgAppNode',system,sprintf('%d',nodeIdx)];

tgAppNodeIdx=ne.Index;
Count=tree.Nodes.Count;

% ne=tree.nodes.Add(Count,4);
% ne.Text='Configuration';
% ne.Tag=system;
% ne.expanded=1;
% ne.Image=2;
% ne.Key=['tgAppConfig',sprintf('%d',ne.Index)];

ne=tree.nodes.Add(Count,4);
ne.Text='Model Hierarchy';
ne.Tag=system;
ne.Key=['MDLH',sprintf('%d',rand)];
%ne.expanded=1;
ne.Image=8;
Count=tree.Nodes.Count;


%adds the Model Hierachy/
%bio=eval([system,'bio']);
getsyschild(system,Count,tree.nodes,system,bio);
getsysblkchildren(tree.nodes,system,Count,system,bio);
%here we need to know the index of the Target PC1(menulabel str) node
%to then populate it with the tg application:
i_createChildrenScopeNodes(tree,tgAppNodeIdx,tg)
tree.selectedItem=tree.Nodes.Item(nodeIdx);
% if xpcmngrUserData.timerObj.enabled==0
%     xpcmngrUserData.timerObj.enabled=1;
% %    start(xpcmngrUserData.timerObj)
% end
%save tree mode Indexes need to update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_RemovetgAppNode(tree) 
tree.Nodes.Remove(tree.SelectedItem.Index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_AddScopeNode(tree,scopeId,index)
if nargin == 2
    currNodeIdx=tree.SelectedItem.Index;
end

if nargin == 3
    currNodeIdx=index;
end

if (tree.Selecteditem.Expanded==0)
    tree.Selecteditem.Expanded=1;
end

figH=tree.figHandle;
xpcmngrUserData=get(figH,'UserData');

sckey={'HScid','TScid','FScid'};

ne=tree.Nodes.Add(currNodeIdx,4);
ne.Text=['Scope: ',sprintf('%d',scopeId)];
ne.Key=['HScid',sprintf('%d',rand)];
%ne.Image=16;
tg=gettg(tree);
sc=tg.getscope(scopeId);

if strcmp(sc.Type,'Host')
%if findstr('HostSc',tree.SelectedItem.Key)
   ne.Key=['HScid',sprintf('%d',rand)];    
   ne.Image=15;
elseif strcmp(sc.Type,'Target')
    ne.Key=['TScid',sprintf('%d',rand)];
    ne.Image=14;
elseif strcmp(sc.Type,'File')
     ne.Key=['FScid',sprintf('%d',rand)];
     ne.Image=13;
end

% 
% 
% 
% ne=tree.Nodes.Add(currNodeIdx,4);
% ne.Text=['Scope: ',sprintf('%d',scopeId)];    
% ne.Key=['HScid',sprintf('%d',rand)];
% ne.Image=16;
% 
% if findstr('HostSc',tree.SelectedItem.Key)
%      
% if findstr('TgSc',tree.SelectedItem.Key)
%      
%if findstr('FileSc',tree.SelectedItem.Key)
     
% if findstr('HostSc',tree.SelectedItem.Key)
%     ne=tree.Nodes.Add(currNodeIdx,4);
%     ne.Text=['Scope: ',sprintf('%d',scopeId)];    
%     ne.Key=['HScid',sprintf('%d',rand)];
%     ne.Image=16;    
%     xpcmngrUserData=feval(@xpcmngrViewPanel,'HostSc',xpcmngrUserData);     
% end
% 
% if findstr('TgSc',tree.SelectedItem.Key)
%     ne=tree.Nodes.Add(currNodeIdx,4);
%     ne.Text=['Scope: ',sprintf('%d',scopeId)];
%     ne.Key=['TScid',sprintf('%d',rand)];
%     ne.Image=16;    
% end
% 
% if findstr('FileSc',tree.SelectedItem.Key)
%     ne=tree.Nodes.Add(currNodeIdx,4);
%     ne.Text=['Scope: ',sprintf('%d',scopeId)];
%     ne.Key=['FScid',sprintf('%d',rand)];
%     ne.Image=16;
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function i_RemoveScopeIdNode(tree)
% tree.Nodes.Remove(tree.SelectedItem.Index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getsyschild(system,nodeindex,nodes,sysname,bio)
subsystems=find_system(system,'blocktype','SubSystem','Parent',system);
for i=1:length(subsystems)
    ne=invoke(nodes,'Add',nodeindex,4);  %root
    ne.Image=7;
    ne.key=['SubSystem',sprintf('%d',rand(1))];
    key=nodes.count;
    ne.addproperty('Prop1');
    %ne.Text=subsystems{i};
    ne.Tag=subsystems{i};
    tempstr=strrep(subsystems{i},[system,'/'],'');
    %getsysblkchildren(nodes,subsystems{i},nodes.count)
    %ne.sigLabel=tempstr;
    ne.Text=strrep(tempstr,sprintf('\n'),' ');    
    idx=regexp(get_param(subsystems{i},'Description'),'xPCTag;');
    if ~isempty(idx)
        ne.Bold=1;
    end
    getsyschild(subsystems{i},key,nodes,sysname,bio);
    getsysblkchildren(nodes,subsystems{i},key,sysname,bio)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getsysblkchildren(nodes,subsystem,count,systemname,bio)
SLallblksinsys=find_system('followlinks','on','lookundermasks','all',...
                           'Type','block','parent',subsystem);
blkTypes=get_param(SLallblksinsys,'blockType');
SubSysIdx=strmatch('SubSystem',blkTypes,'exact');
AllblksIdx=1:length(blkTypes);
blksIdx=setdiff(AllblksIdx,SubSysIdx);
SLblocksinsys=SLallblksinsys(blksIdx);
sysname=strrep(subsystem,[systemname,'/'],'');
sysname=strrep(sysname,sprintf('\n'),' ');
xpcblksinsys=strrep(SLblocksinsys,[subsystem,'/'],'');
xpcblksinsys=strrep(xpcblksinsys,sprintf('\n'),' ');
if ~(strcmp(sysname,systemname))
    xpcSigs=strcat([sysname,'/'],xpcblksinsys);
    xpcSigsblks=xpcblksinsys;
else
    xpcSigs=xpcblksinsys;
    xpcSigsblks=xpcSigs;
end
%bio=eval([systemname,'bio']);
pt=eval([systemname,'pt']);
sigsinbiocell=cellstr(strvcat(bio.blkName));
sigs=[];
%blocks
if ~isempty(pt)
    for i=1:length(xpcSigs)
        idx=strmatch(xpcSigs{i},sigsinbiocell);
        if ~isempty(idx)
            xpcbiosiginfo=bio(idx);
            ne=invoke(nodes,'Add',count,4);
            ne.image=10;
            ne.Text=xpcSigsblks{i};
            ne.Tag=xpcSigs{i};
            ne.Key=['xPCPT',xpcSigs{i},sprintf('%d',rand),' :SlBlock: ',SLblocksinsys{i}];%to do:make this unique
        end
        if isempty(idx)
            idx=strmatch(xpcSigs{i},cellstr(strvcat(pt.blockname)));
            if ~isempty(idx)
                xpcbiosiginfo=pt(idx);
                ne=invoke(nodes,'Add',count,4);
                ne.image=10;
                ne.Text=xpcSigsblks{i};
                ne.Tag=xpcSigs{i};
                ne.Key=['xPCPT',xpcSigs{i},sprintf('%d',rand),' :SlBlock: ',SLblocksinsys{i}];%to do:make this unique
            end

        end
    end
end
%signals
for i=1:length(xpcSigs)
    if isempty(SLblocksinsys)
        break
    end
     slblk=SLblocksinsys{i};
     ports=get_param(slblk,'Ports');
     ports=ports(2);
     if (ports > 1)         
         for p=1:ports  
             if findstr(get_param(slblk,'Tag'),'Stateflow')
                 pp=p+1;
                 idx=strmatch([xpcSigs{i},'/p',sprintf('%d',p+1)],sigsinbiocell,'exact');
             else
                 pp=p;
                 idx=strmatch([xpcSigs{i},'/p',sprintf('%d',p)],sigsinbiocell,'exact');
             end
             if isempty(idx)
                break 
             end
             if ~isempty(idx)
                 xpcbiosiginfo=bio(idx);
                 ne=invoke(nodes,'Add',count,4);
                 ne.image=9;
                 ne.Text=[xpcSigsblks{i},'/p',sprintf('%d',pp)];
                 ne.Tag=[xpcSigs{i},'/p',sprintf('%d',pp)];
                 ne.Key=['xPCSIG',xpcSigs{i},sprintf('%d',rand),' :SlBlock: ',SLblocksinsys{i}];%to do:make this unique
             end
         end
     else   
        idx=strmatch(xpcSigs{i},sigsinbiocell,'exact');
        if ~isempty(idx)
             xpcbiosiginfo=bio(idx);
             ne=invoke(nodes,'Add',count,4);
             ne.image=9;
             ne.Text=xpcSigsblks{i};
             ne.Tag=xpcSigs{i};
             ne.Key=['xPCSIG',xpcSigs{i},sprintf('%d',rand),' :SlBlock: ',SLblocksinsys{i}];%to do:make this unique
%          if (xpcbiosiginfo.sigWidth > 1)
%              sigNodeIndex=ne.Index;             
%              for ik=1:xpcbiosiginfo.sigWidth
%                  ne=invoke(nodes,'Add',sigNodeIndex,4);
%                  ne.image=9;
%                  ne.Text=['S',sprintf('%d',ik)];
%                  ne.Tag=[xpcSigs{i},'\',ne.Text];
%                  ne.Key=['xPCPT',xpcSigs{i},sprintf('%d',rand)];%to do:make this unique 
%              end
%          end
         
        end
     end
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getsyschildFromTag(system,nodeindex,nodes)
subsystems=find_system(system,'RegExp','On','followlinks','on',...
                       'lookundermasks','all','BlockType',...
                       'SubSystem','Description','xPCTag;');
for i=1:length(subsystems)
    ne=invoke(nodes,'Add',nodeindex,4);  %root
    ne.Image=2;
    %ne.Text=subsystems{i};
    ne.Tag=subsystems{i};
    tempstr=strrep(subsystems{i},[system,'/'],'');
    %ne.sigLabel=tempstr;
    ne.Text=strrep(tempstr,sprintf('\n'),' ');    
    getsyschild(subsystems{i},nodes.count,nodes);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_updateTargetenvStruct(Event_info)
tree=Event_info{1};
oldstr=tree.SelectedItem.Text;
newStr=Event_info{4};

tgsavedNames=fieldnames(tree.Targets);
oldfieldName=strrep(oldstr,' ','');
currfieldVal=getfield(tree.Targets,oldfieldName);
tree.Targets=rmfield(tree.Targets,oldfieldName);
str=['tree.Targets.',strrep(newStr,' ',''),'= currfieldVal;'];
eval(str);
%tree.Targets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_createChildrenScopeNodes(tree,tgAppNodeIdx,tg)
tree.SelectedItem=tree.Nodes.Item(tgAppNodeIdx);
%tgxpc=xpc_get_TargetPC(tree);
%tg=tgxpc.tg;
sc=tg.getscope;
scType=get(sc,'Type');
hostScIdx=strmatch('Host',scType);
tgScIdx=strmatch('Target',scType);
fileScIdx=strmatch('File',scType);
%now we Add the Scope Nodes, Host,target, files
ne=tree.nodes.Add(tgAppNodeIdx,4);
ne.Text='xPC Scopes';
ne.Tag='xPCScopesNode';
%ne.expanded=1;
ne.Image=12;
scopesNodeIdx=ne.Index;
Count=tree.Nodes.Count;
%now we Add the Scope Nodes, Host,target, files

%Add Host Scope Node
ne=tree.nodes.Add(scopesNodeIdx,4);
ne.Text='Host Scope(s)';
%ne.Tag=system;
ne.expanded=1;
ne.Image=15;
ne.Key=['HostSc',sprintf('%d',rand)];
hostNodeIndex=ne.Index;

for i=1:length(hostScIdx)
    ne=tree.Nodes.Add(hostNodeIndex,4);
    ne.Text=['Scope: ',sprintf('%d',sc(hostScIdx(i)).scopeId)];    
    ne.Key=['HScid',sprintf('%d',rand)];
    ne.Image=15;        
    sigNodeIndex=ne.Key;
    signals=xpcgate(tg.port,'getscsignals',sc(hostScIdx(i)).scopeId);
    for ii=1:length(signals)
        sigIdx=signals(ii);
        sigName=xpcgate(tg.port,'getsignalname',sigIdx);
        ne=tree.Nodes.Add(sigNodeIndex,4);
        ne.Text=sigName;
        ne.Image=9;
        ne.key=['xPCSigScope',sprintf('%d',ne.Index)];
    end  
end

Count=tree.Nodes.Count;

%Add Target Scope Node
ne=tree.nodes.Add(scopesNodeIdx,4);
ne.Text='Target Scope(s)';
%ne.Tag=system;
ne.expanded=1;
ne.Image=14;
ne.Key=['TgSc',sprintf('%d',rand)];
tgNodeIndex=ne.Index;
for j=1:length(tgScIdx)
    ne=tree.Nodes.Add(tgNodeIndex,4);
    ne.Text=['Scope: ',sprintf('%d',sc(tgScIdx(j)).scopeId)];    
    ne.Key=['TScid',sprintf('%d',rand)];
    ne.Image=14;        
    sigNodeIndex=ne.Key;
    signals=xpcgate(tg.port,'getscsignals',sc(tgScIdx(j)).scopeId);
    for jj=1:length(signals)
        sigIdx=signals(jj);
        sigName=xpcgate(tg.port,'getsignalname',sigIdx);
        ne=tree.Nodes.Add(sigNodeIndex,4);
        ne.Text=sigName;
        ne.Image=9;
        ne.key=['xPCSigScope',sprintf('%d',ne.Index)];
    end   
end

%Add File Scope Node
ne=tree.nodes.Add(scopesNodeIdx,4);
ne.Text='File Scope(s)';
%ne.Tag=system;
ne.expanded=1;
ne.Image=13;
ne.Key=['FileSc',sprintf('%d',rand)];
fileNodeIndex=ne.Index;
for k=1:length(fileScIdx)
    ne=tree.Nodes.Add(fileNodeIndex,4);
    ne.Text=['Scope: ',sprintf('%d',sc(fileScIdx(k)).scopeId)];    
    ne.Key=['FScid',sprintf('%d',rand)];
    ne.Image=13;        
    sigNodeIndex=ne.Key;
    signals=xpcgate(tg.port,'getscsignals',sc(fileScIdx(k)).scopeId);
    for kk=1:length(signals)
        sigIdx=signals(kk);
        sigName=xpcgate(sc.port,'getsignalname',sigIdx);
        ne=tree.Nodes.Add(sigNodeIndex,4);
        ne.Text=sigName;
        ne.Image=9;
        ne.Tag=sigName;
        ne.key=['xPCSigScope',sprintf('%d',rand)];
    end    
end

%Count=tree.Nodes.Count;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_addSignalNode2ScopeTree(tree,scIdxStr,SigNode,scNodeId)%adds new leaf signal node to Scope Nodes
if nargin == 3
   SigNode=SigNode;   
elseif nargin == 2
    SigNode=tree.SelectedItem;
end

if (nargin == 3 | nargin == 2)
    allNames=tree.GetAllNames;
    if ~isempty(findstr('(',scIdxStr))
        scNodeIndex=strmatch(scIdxStr(1:findstr('(',scIdxStr)-1),allNames);
    else
        scNodeIndex=strmatch(scIdxStr,allNames);
    end
    
    %determing which target to chose from
    if length(scNodeIndex) > 1
        allkeys=tree.GetAllKeys;
        alltgxpcIdx=strmatch('TGPC',allkeys); 
        for i=1:length(alltgxpcIdx)
            if (tree.Nodes.Item(alltgxpcIdx(i)).Bold == 1)
                %index=i;
                break
            end
        end
        scNodeIndex=scNodeIndex(i);
    end
end

if nargin == 4
         scNodeIndex=scNodeId;
end
   
 %scopeId=eval(menuLabel(7:findstr('(',menuLabel)-1));
%scIdx=eval(scIdxStr(1:findstr('(',scIdxStr)-1));
%scNodeIndex=strmatch(scIdxStr(1:findstr('(',scIdxStr)-1),allNames);
if (tree.Nodes.Item(scNodeIndex).Expanded == 0)
    tree.Nodes.Item(scNodeIndex).Expanded=1;
end
ne=tree.Nodes.Add(tree.Nodes.Item(scNodeIndex).Index,4);
ne.Text=SigNode;
ne.Image=9;
ne.key=['xPCSigScope',sprintf('%d',rand(1))];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_RemoveScopeIdNode(tree)
tree.Nodes.Remove(tree.SelectedItem.Index)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_Add_DLMsNode(tree,idx)


%Name Seerch to match the index with respect to its Target root
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nodeIdx=treeNodeIdxofTG(tree,search)
        
if findstr(tree.tree.selectedItem.key,'TGPC')
    targetNameStr=tree.selectedItem.Text;
else
    %%%find the root target node
    fullpath=tree.SelectedItem.Fullpath;
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
    targetNameStr=fullpath(1:sepIdx-1);
end

allNames=tree.GetAllNames;
HostndIdx=strmatch(search,allNames)
listScName={};
for i=1:length(HostndIdx)
    if findstr(targetNameStr,tree.Nodes.Item(HostndIdx(i)).Fullpath)
        nodeidx=HostndIdx(i);
        break
    end
    nodeidx=[]
    %listScName{end+1}=tree.Nodes.Item(HostndIdx(i)).Fullpath
end
