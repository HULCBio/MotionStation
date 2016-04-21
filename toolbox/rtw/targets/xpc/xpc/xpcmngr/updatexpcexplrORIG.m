function updatexpcexplr(varargin)
% UPDATEEXPCEXPLR - xPC Target Manager GUI
%    UPDATEEXPCEXPLR Timer function Callback to update the xPC Target Manager
%    GUI.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

timer=varargin{1};
timer.enabled=1;
set(0,'showhiddenhandles','on');
xpcmngrfigH=findobj(0,'Type','Figure','Tag','xpcmngr');
xpcmngrUserData=get(xpcmngrfigH,'UserData');
set(0,'showhiddenhandles','off');
tree=xpcmngrUserData.treeCtrl;
%%%%%%%%%%%%%%%%%%%%%%%%%
idx=updateCurWorkDir(tree);
updateDLMNode(tree,idx);
%%%%%%%%%%%%%%%%%%%%%%%%

xpcmngrUserData=get(tree.figHandle,'Userdata');
try
    timercc6callback(xpcmngrUserData,tree)
catch
    timer.enabled=0;
    errordlg(lasterr)
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function timercc6callback(xpcmngrUserData,tree)
    % end
    if isempty(xpcmngrUserData)
        return
    end
    if ~isempty(xpcmngrUserData.scfigure)
        scUserData=get(xpcmngrUserData.scfigure,'userdata');
        refreshscopes(xpcmngrUserData.scfigure,scUserData.tg)
    end
    updateNodes(tree)

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
                         set(list.ListItems.Item(5).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.SampleTime))
                         set(list.ListItems.Item(6).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.AvgTeT))
                         set(list.ListItems.Item(7).listsubItems.Item(1),'Text',sprintf('%0.2f',tg.ExecTime))    
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
    timer.enabled=1;
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
allKeys=tree.GetAllKeys;
allHostScNodeIndex=strmatch('HostSc',allKeys);


%Update for each target
for i=1:length(allHostScNodeIndex)
    targetPCStr=tree.Nodes.Item(allHostScNodeIndex(i)).Parent.Parent.Parent.Text;    
    targetPCStr=strrep(targetPCStr,' ','');
    %tg=xpcGetTg(tree,targetPCStr);
    
    xpcScids=xpcgate(tg.port,'getscopes','host');
    scNodeCh=tree.Nodes.Item(allHostScNodeIndex(i)).Children;
    if ~(length(xpcScids) == scNodeCh)
        for j=1:scNodeCh
            tree.Nodes.Remove(tree.Nodes.Item(allHostScNodeIndex(i)).child.Index);            
        end 
        
        for k=1:length(xpcScids)
            ne=tree.Nodes.Add(allHostScNodeIndex(i),4);
            ne.Text=['Scope: ',sprintf('%d',xpcScids(k))];    
            ne.Key=['HScid',sprintf('%d',rand)];
            ne.Image=16;
            scidIndex=ne.index;
            %sigIds=getsignalformscope
%             for iii=1:length(sigIds)
%                 ne=tree.Nodes.Add(scidIndex,4);
%                 %ne.Text=tg.getsignalname
%                 ne.Image=9;
%                 ne.key=['xPCSigScope',sprintf('%d',ne.Index)];
%             end
        end
    end  
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
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
        table.Text=sprintf('%0.2f',sigVals(r,c));
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

