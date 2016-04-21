function updateTree(src,evt,tree)
% UPDATETREE - xPC Target Manager GUI
%    UPDATETREE Timer function Callback to update the xPC Target Manager
%    GUI.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $


idx=updateCurWorkDir(tree);
updateDLMNode(tree,idx);
xpcmngrUserData=get(tree.figHandle,'Userdata');
% end
if isempty(xpcmngrUserData)
    return
end
%---- refresh scope Viewer   
if ~isempty(xpcmngrUserData.scfigure)
    scUserData=get(xpcmngrUserData.scfigure,'userdata');
    refreshscopes(xpcmngrUserData.scfigure,scUserData.tg)
end
%------
%updatexPCScopeNode(tree)

updateNodes(tree)

if ~isempty(tree.SelectedItem)    
    %updateNodes(tree)
    if findstr(tree.SelectedItem.Key,'xPCSIG')    
        sigInfo=tree.sigInfo;
        xpcmngrUserData.sigViewer;
        updatesigViewer(xpcmngrUserData.sigViewer,gettg(tree),sigInfo)  
    end
    %updateSigTable
    if findstr(tree.SelectedItem.Key,'tgAppNode')    
        tg=gettg(tree);
        if isempty(tg)
            return
        end
        if ~strcmp(tg.application,'loader')
            if isa(xpcmngrUserData.tgapplistCtrl,'COM.MWXPCControls_listviewctrl')
                 list=xpcmngrUserData.tgapplistCtrl;
                 list.Font.Size=11;
                 set(list.ListItems.Item(3).listsubItems.Item(1),'Text',sprintf('%0.5f',tg.ExecTime))                 
            end
        end
    end
    %------------------------
    if findstr(tree.SelectedItem.Key,'TGPC')    
        tg=gettg(tree);
        if ~isempty(tg)
            if ~strcmp(tg.application,'loader')
%                  if ~strcmp(tree.selectedItem.Child.Next.text,tg.application)
%                     feval(xpcmngrTree('Download2Target'),tree,tg,tg)     
%                  end
            if isa(xpcmngrUserData.listCtrl,'COM.MWXPCControls_listviewctrl')
                     list=xpcmngrUserData.listCtrl;
                     list.Font.Size=11;
                     %set(list.ListItems.Item(5).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.SampleTime))
                     set(list.ListItems.Item(6).listsubItems.Item(1),'Text',sprintf('%0.7f',tg.AvgTeT))
                     set(list.ListItems.Item(7).listsubItems.Item(1),'Text',sprintf('%0.5f',tg.ExecTime))    
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
%tree.timerflag=0;
%updatexPCScopeNode(tree)
%allkeys=tree.GetAllKeys;
%tgpcidx=strmatch('TGPC',allkeys);
% for i=length(tgpcidx)
%     targetNamestr=tree.Nodes.Item(tgpcidx(i)).Text;
%     targetNamestr=strrep(targetNamestr,' ','')
% end    
%updatexPCScopeNode(tree)
%updateTGNode(tree);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx=updateCurWorkDir(tree);
idx=getPWDDirIndex(tree);
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function updateDLMNode(tree,idx)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dlmNames=checkdirdlm
d=dir('*.dlm');
if isempty(d)
   dlmNames=[];
   return 
end
dlmNames=cellstr(strvcat(d.name));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updatexPCScopeNode(tree)

alltargets=tree.GetAllKeys;
allNames=tree.GetAllNames;
targedidx=strmatch('TGPC',alltargets);
% allNames=tree.GetAllNames;
% allScopedNodeIndex=strmatch('HostSc',allKeys);

for i=1:length(targedidx)
    tgnodeIdx=targedidx(i);
    targetName=tree.Nodes.Item(tgnodeIdx).text;
    targetstruct=tree.targets;
    tg=eval(['tree.',targetName,';']);
    if isempty(tg) | strcmp(tg.application,'loader')
        return
    end
    
    sc=tg.getscope;
    allScNodeIdx=tree.Nodes.Item(tgnodeIdx).Child.Next.Child.Next.Index;
    hostScIdx=tree.Nodes.Item(tgnodeIdx).Child.Next.Child.Next.Child.Index;
    numhostScidNodes=tree.Nodes.Item(tgnodeIdx).Child.Next.Child.Next.Child.children;
    tgScIdx=tree.Nodes.Item(tgnodeIdx).Child.Next.Child.Next.Child.Next.Index;
    numtgScidNodes=tree.Nodes.Item(tgnodeIdx).Child.Next.Child.Next.Child.Next.children;
    fileScIdx=tree.Nodes.Item(tgnodeIdx).Child.Next.Child.Next.Child.Next.Next.Index;
    numfileScidNodes=tree.Nodes.Item(tgnodeIdx).Child.Next.Child.Next.Child.Next.Next.children;

    HscIdx=strmatch('Host',get(sc,'Type'));
    numoftgHostsc=length(HscIdx);

    TscIdx=strmatch('Target',get(sc,'Type'));
    numoftgtgsc=length(TscIdx);

    FscIdx=strmatch('File',get(sc,'Type'));
    numoftgfilesc=length(FscIdx);
    %-------
    if (numhostScidNodes ~= numoftgHostsc)
        while ~(tree.Nodes.Item(hostScIdx).children == 0)
            tree.Nodes.Remove(tree.Nodes.Item(hostScIdx).Child.Index)
        end

        for ih=1:length(HscIdx)
            ne=tree.Nodes.Add(hostScIdx,4);
            ne.Text=['Scope: ',sprintf('%d',sc(HscIdx(ih)).scopeId)];
            ne.Key=['HScid',sprintf('%d',rand)];
            ne.Image=15;
            sigNodeIndex=ne.Key;
            signals=xpcgate(tg.port,'getscsignals',sc(HscIdx(ih)).scopeId);
            for iih=1:length(signals)
                sigIdx=signals(iih);
                sigName=xpcgate(tg.port,'getsignalname',sigIdx);
                ne=tree.Nodes.Add(sigNodeIndex,4);
                ne.Text=sigName;
                ne.Image=9;
                ne.key=['xPCSigScope',sprintf('%d',ne.Index),sprintf('%d',rand)];
            end
        end
    else%check for signals update signals node when neccassary
       % return
        scNode=tree.Nodes.Item(hostScIdx);
        scNodech=scNode.child;
        while (~isempty(scNodech))            
            scopdeidstr=scNodech.text;
            scid=eval(scopdeidstr(8:end));
            sigOnSc=xpcgate(tg.Port, 'getscsignals', scid);            
            sigNodes=scNodech.children;
            if length(sigOnSc) ~= sigNodes
                while ~(scNodech.children == 0)
                    tree.Nodes.Remove(scNodech.child.Index)
                end
                for jj=1:length(sigOnSc)
                    sigIdx=sigOnSc(jj);
                    sigName=xpcgate(tg.port,'getsignalname',sigIdx);
                    ne=tree.Nodes.Add(scNodech.Index,4);
                    ne.Text=sigName;
                    ne.Image=9;
                    ne.key=['xPCSigScope',sprintf('%d',ne.Index),sprintf('%d',rand)];
                end
            end            
             scNodech=scNodech.Next;
        end%while

    end
    %-------

    %-------
    if (numtgScidNodes ~= numoftgtgsc)
        while ~(tree.Nodes.Item(tgScIdx).children == 0)
            tree.Nodes.Remove(tree.Nodes.Item(tgScIdx).Child.Index)
        end

        for itg=1:length(TscIdx)
            ne=tree.Nodes.Add(tgScIdx,4);
            ne.Text=['Scope: ',sprintf('%d',sc(TscIdx(itg)).scopeId)];
            ne.Key=['HScid',sprintf('%d',rand)];
            ne.Image=15;
            sigNodeIndex=ne.Key;
            signals=xpcgate(tg.port,'getscsignals',sc(TscIdx(itg)).scopeId);
            for iitg=1:length(signals)
                sigIdx=signals(iitg);
                sigName=xpcgate(tg.port,'getsignalname',sigIdx);
                ne=tree.Nodes.Add(sigNodeIndex,4);
                ne.Text=sigName;
                ne.Image=9;
                ne.key=['xPCSigScope',sprintf('%d',ne.Index),sprintf('%d',rand)];
            end
        end
    else
        return
    %-----
        scNode=tree.Nodes.Item(tgScIdx);
        scNodech=scNode.child;
        while (~isempty(scNodech))                                    
            scopdeidstr=scNodech.text;
            scid=eval(scopdeidstr(8:end));
            sigOnSc=xpcgate(tg.Port, 'getscsignals', scid);            
            sigNodes=scNodech.children;
            if length(sigOnSc) ~= sigNodes
                while ~(scNodech.children == 0)
                    tree.Nodes.Remove(scNodech.child.Index)
                end
                for jj=1:length(sigOnSc)
                    sigIdx=sigOnSc(jj);
                    sigName=xpcgate(tg.port,'getsignalname',sigIdx);
                    ne=tree.Nodes.Add(scNodech.Index,4);
                    ne.Text=sigName;
                    ne.Image=9;
                    ne.key=['xPCSigScope',sprintf('%d',ne.Index),sprintf('%d',rand)];
                end
            end            
             scNodech=scNodech.Next;
        end%while
    %-----
        
    end
    %-------

    %-------
    if (numfileScidNodes ~= numoftgfilesc)
        while ~(tree.Nodes.Item(fileScIdx).children == 0)
            tree.Nodes.Remove(tree.Nodes.Item(fileScIdx).Child.Index)
        end

        for iff=1:length(FscIdx)
            ne=tree.Nodes.Add(fileScIdx,4);
            ne.Text=['Scope: ',sprintf('%d',sc(FscIdx(iff)).scopeId)];
            ne.Key=['HScid',sprintf('%d',rand)];
            ne.Image=15;
            sigNodeIndex=ne.Key;
            signals=xpcgate(tg.port,'getscsignals',sc(FscIdx(iff)).scopeId);
            for iiff=1:length(signals)
                sigIdx=signals(iiff);
                sigName=xpcgate(tg.port,'getsignalname',sigIdx);
                ne=tree.Nodes.Add(sigNodeIndex,4);
                ne.Text=sigName;
                ne.Image=9;
                ne.key=['xPCSigScope',sprintf('%d',ne.Index),sprintf('%d',rand)];
            end
        end
    else
        return
        %-----
        scNode=tree.Nodes.Item(fileScIdx);
        scNodech=scNode.child;
        while (~isempty(scNodech))
            scopdeidstr=scNodech.text;
            scid=eval(scopdeidstr(8:end));
            sigOnSc=xpcgate(tg.Port, 'getscsignals', scid);
            sigNodes=scNodech.children;
            if length(sigOnSc) ~= sigNodes
                while ~(scNodech.children == 0)
                    tree.Nodes.Remove(scNodech.child.Index)
                end
                for jj=1:length(sigOnSc)
                    sigIdx=sigOnSc(jj);
                    sigName=xpcgate(tg.port,'getsignalname',sigIdx);
                    ne=tree.Nodes.Add(scNodech.Index,4);
                    ne.Text=sigName;
                    ne.Image=9;
                    ne.key=['xPCSigScope',sprintf('%d',ne.Index),sprintf('%d',rand)];
                end
            end
            scNodech=scNodech.Next;
        end%while
        %-----


    end
    %-------
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx=getPWDDirIndex(tree)    
idx=strmatch('pwdDLM',tree.GetAllKeys);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
           yexport=zeros(scObj.numSamples,length(line_plot));
           texport=tdata';
           
           %disp hello
               for ii=1:length(line_plot)
                   color=get(line_plot(ii),'color');
                   yexport(:,ii)=ydata(:,ii);
                   if strcmp(get(axscopeusrdata.cmenu.root.export.exTrigger,'checked'),'on')
                      assignin('base', axscopeusrdata.exportNames{1}, yexport');
                      assignin('base', axscopeusrdata.exportNames{2}, texport);
                   end

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
        table.Text=sprintf('%.5f',sigVals(r,c));
     %   table.CellFontWidth =3;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScPanel(sc,xpcmngrUserData)
if strcmp(sc.Status,'Acquiring') 
    updateMenus(xpcmngrUserData.figure,'NumSamples','off')
    updateMenus(xpcmngrUserData.figure,'Decimation','off')
    updateMenus(xpcmngrUserData.figure,'TriggerMode','off')
    updateMenus(xpcmngrUserData.figure,'TriggerLevel','off')
    updateMenus(xpcmngrUserData.figure,'TriggerSlope','off')
    updateMenus(xpcmngrUserData.figure,'NumPrePostSamples','off')  
    if strcmp(sc.Type,'File')
        updateMenus(xpcmngrUserData.figure,'Filename','off')            
        updateMenus(xpcmngrUserData.figure,'Mode','off')
        updateMenus(xpcmngrUserData.figure,'AutoRestart','off')
        updateMenus(xpcmngrUserData.figure,'WriteSize','off')        
    end    
elseif (strcmp(sc.Status,'Finished') | strcmp(sc.Status,'Interrupted') )
    updateMenus(xpcmngrUserData.figure,'NumSamples','on')
    updateMenus(xpcmngrUserData.figure,'Decimation','on')
    updateMenus(xpcmngrUserData.figure,'TriggerMode','on')
    updateMenus(xpcmngrUserData.figure,'TriggerLevel','on')
    updateMenus(xpcmngrUserData.figure,'TriggerSlope','on')
    updateMenus(xpcmngrUserData.figure,'NumPrePostSamples','on')     
    if strcmp(sc.Type,'File')
        updateMenus(xpcmngrUserData.figure,'Filename','on')            
        updateMenus(xpcmngrUserData.figure,'Mode','on')
        updateMenus(xpcmngrUserData.figure,'AutoRestart','on')
        updateMenus(xpcmngrUserData.figure,'WriteSize','on')        
    end       
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
%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateToolbar(uitoolH,toolItem,state)
toolH=findobj(uitoolH,'Type','UIToggletool','Tag',toolItem);
if ~isempty(toolH)
    set(toolH,'enable',state);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateNodes(tree)
if isempty(tree.selectedItem)
   return
end
fullpath=tree.SelectedItem.Fullpath;
if findstr(fullpath,'Host PC Root')
    return
end
%disp first
if (findstr('TGPC',tree.SelectedItem.key))
   targetNameStr = tree.SelectedItem.Text;
else
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
   % disp sec
    targetNameStr=fullpath(1:sepIdx-1);
  %  disp third
end

tg=gettg(tree);
    %disp fourth
if isempty(tg)
    return
end

%if strcmp(tg.application,'Loader')
    
%disp five
%to do: revist what happend when loader
% if strcmp(tg.application,'loader')
%     return
% end
targettridx=strmatch(targetNameStr,tree.GetAllNames,'exact');
if ~isempty(tree.Node.Item(targettridx).child.next) 
    if ~strcmp(tree.Node.Item(targettridx).child.next.text,tg.application)
       % stop(xpcmngrUserData.timerObj)
        feval(xpcmngrTree('Download2Target'),tree,tg,tg,targettridx) 
        %tree.Refresh;
    end
else %no target node available
    if ~strcmp(tg.application,'loader')
        feval(xpcmngrTree('Download2Target'),tree,tg,tg,targettridx) 
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%








































