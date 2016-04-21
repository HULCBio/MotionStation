function xpcmngrUserData = xpcmngrScopeViewer(varargin)
%XPCMNGRSCOPEVIEWER xPC Target Host Scopes Viewer  
%   XPCMNGRSCOPEVIEWER creates the Host Scope Viewer from the xPC Manager
%   GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision:


Action = varargin{1};
args = varargin(2:end);

switch Action,

case 'getLocalHandles'
        xpcmngrUserData.api.scViewer.createWindow=@i_createScopeWindow;
        xpcmngrUserData.api.scViewer.createAllScAxes=@i_createScopeAxes;
        xpcmngrUserData.api.scViewer.delAllScAxes=@i_deletechScopes;
        
case 'createScViewer'        
        xpcmngrUserData=args{1};
        tg=args{2};
        xpcmngrUserData=i_createScopeWindow(xpcmngrUserData);
        scViewerUserData=i_createScopeAxes(xpcmngrUserData.scfigure,tg);
        scViewerUserData.tg=tg;
        set(xpcmngrUserData.scfigure,'Userdata',scViewerUserData);
        xpcmngrUserData.api.scViewer.createWindow=@i_createScopeWindow;
        xpcmngrUserData.api.scViewer.createAllScAxes=@i_createScopeAxes;
        xpcmngrUserData.api.scViewer.delAllScAxes=@i_deletechScopes;
        xpcmngrUserData.api.scViewer.closeScViewer=@closeScViewer;
        set(xpcmngrUserData.figure,'Userdata',xpcmngrUserData);
            
otherwise,        
    error('Invalid Action');
end

function xpcmngrUserData = i_createScopeWindow(xpcmngrUserData)
% timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
%                      {'off','on'},'exact') - 1;  
% if strcmp('on',timerStatus)
%     stop(xpcmngrUserData.timerObj)
% end

set(0,'showhiddenhandles','on');
xpcmngrfigScH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
%xpcmngrUserData=get(xpcmngrfigH,'UserData');
set(0,'showhiddenhandles','off');
if ~isempty(xpcmngrfigScH)
   delete(xpcmngrfigScH)
end

rootUnits=get(0,'Units');
set(0,'Units','Pixels')
scSize=get(0,'ScreenSize');
figPos=[scSize(3)*0.2 ...
        scSize(4)*0.25 ...
        scSize(3)*0.75 ...
        scSize(4)*0.6];
%figPos=[ 520   590   960   420];            
set(0,'Units',rootUnits);
xpcmngrUserData.scfigure = figure(  ...
     'Name','xPC Target Host Scope Viewer', ...
     'NumberTitle','off', ...
     'IntegerHandle', 'off', ...
     'MenuBar', 'none', ...
     'CloseRequestFcn', {@closeScViewer xpcmngrUserData.timerObj}, ...
     'Resize','On',...
     'Resizefcn',@resizeScFigure,...
     'Renderer','zbuffer',...
     'Tag','HostScopeViewer',...
     'HandleVisibility','callback',...
     'Visible','on',...
     'Position',figPos,...
     'Color', get(0,'DefaultUicontrolBackgroundColor'), ...%xpcmngrUserData.figColor
     'DefaultAxesColor',  xpcmngrUserData.scmngr.axesColor,...
     'DefaultAxesXColor', xpcmngrUserData.scmngr.ticColor, ...
     'DefaultAxesYColor', xpcmngrUserData.scmngr.ticColor, ...
     'DefaultAxesZColor', xpcmngrUserData.scmngr.ticColor, ...
     'DefaultTextColor',  xpcmngrUserData.scmngr.ticColor);
% if strcmp('on',timerStatus)
%     start(xpcmngrUserData.timerObj)
% end 

 %function scViewerUserData=i_createScopeAxes(xpcmngrUserData,tg,args)                              
function scViewerUserData=i_createScopeAxes(figH,tg,args)
%figH=xpcmngrUserData.scfigure;

set(0,'showhiddenhandles','on');
xpcmngrfigH=findobj(0,'Type','Figure','Tag','xpcmngr');
xpcmngrUserData=get(xpcmngrfigH,'UserData');
set(0,'showhiddenhandles','off');
%xpcmngrUserData = get(figH,'UserData');
xpcschostobjs=sort(xpc_getAllschost(tg));
%nsc=get(xpcschostobjs,'Scopeid');
if length(xpcschostobjs) > 1
    [a,b]=sort(cell2mat(get(xpcschostobjs,'Scopeid')));
    xpcschostobjs=xpcschostobjs(flipud(b));
end
    
nAxes=length(xpcschostobjs);
%nAxes=4;
if ~nAxes
    scViewerUserData=get(figH,'Userdata');
    return    
end

viewPanelArea=get(figH,'Position');
deltaX_ax=50;
deltaY_ax=40;
%leftb=fpos(3)/3 + fpos(3)/5;
leftb=viewPanelArea(1);
buttomb=25;
%heightwin=fpos(4)-80-buttomb;
heightwin=viewPanelArea(4)-50;
%widthwin=fpos(3) - leftb;
widthwin=viewPanelArea(3);
AxDelta=(heightwin/nAxes);
VertDelta=50;
xpos=leftb+deltaX_ax;
xpos=50;
% for j=1:length(xpcmngrUserData.scmngr.Scope.allH)
%     if isa(xpcmngrUserData.scmngr.Scope.allH{j},'double')
%         xpcmngrUserData.scmngr.Scope.allH{j}=[];
%     end
% end


for i=1:nAxes%%%Add Axes per scope-----------------
    %xpcschostobjs(i);
    scAxhostdata.scopeobj=xpcschostobjs(i);
    scViewerUserData.scmngr.Scope.scObj(i)=xpcschostobjs(i);
    %%%Add the Scope UI interface------------------
    %hAxes=subplot(nAxes,1,i);%xpcmngrUserData.figure,xpcmngrUserData.hScrollable
    hAxes=axes('visible','on','parent',figH);
    scViewerUserData.scmngr.Scope.scaxes(i)=hAxes;   
    %hAxesUnits=get(hAxes,'Units');
   % set(hAxes,'units','pixels');
    ypos=(i-1)*AxDelta+(VertDelta);
    adjhAxespos=[xpos,ypos,widthwin-deltaX_ax-50,AxDelta-50];
   % set(hAxes,'Position',adjhAxespos);
    %%%%%%here we add Hilite behind the axes
    scViewerUserData.scmngr.Scope.ScHilite(i)=rectangle('Parent',hAxes,...
                                                        'LineWidth',5,...
                                                        'EdgeColor','none');
    set(hAxes,...
       'NextPlot','add', ...
       'XGrid',            'on', ...
       'YGrid',            'on', ...
       'Color',            xpcmngrUserData.scmngr.axesColor, ...
       'ColorOrder',       xpcmngrUserData.scmngr.axesColorOrder, ...
       'XColor',           xpcmngrUserData.scmngr.ticColor, ...
       'YColor',           xpcmngrUserData.scmngr.ticColor, ...
       'Box',              'on', ...
       'Units',             'Pixels',...
       'XLimMode','manual',...
       'YLimMode','auto',...
       'Visible',          'on',...
       'Position',         adjhAxespos,...
       'ButtonDownFcn',    '',...
       'fontsize',         7,...
       'Tag',              'Hostxpcsc',...
       'View',             [0 90]);
   
   %%To do'ButtonDownFcn',  xpcmngrViewPanel(''AxisClick'',gcbo)
    %create contextmenu   
    
    %add signals of scope as lines to the axes to trace
    %scAxhostdata.scopeobj%hack around udd accessing this prop
    %sigonScope=length(scAxhostdata.scopeobj.SignalVec);
    %sigonScope=xpcgate('getscsignals',scAxhostdata.scopeobj.ScopeId);
    set(hAxes,'Userdata',scAxhostdata);
    set(hAxes,'Units','Normalized')
    args={'ScOnCreate',[]}; 
    title(hAxes,['Scope: ',sprintf('%d',scAxhostdata.scopeobj.scopeid)],...
        'FontSize',10);
    scAxhostdata=i_AddSignal2TraceonScopeAx(hAxes,scAxhostdata,tg,xpcmngrUserData,args);%Event:ScOnCreate,ScAddManual,[]
    %if ~isempty(sigonScope)
    hAxesConextMenu=i_createAxContextMenu(figH,hAxes);
    
    scAxhostdata.mode.graph='on'; 
    scAxhostdata.legends='on'; 
    scAxhostdata.grid='on'; 
    scAxhostdata.export='off';
    strd=[scAxhostdata.scopeobj.up.Application,'_scope',...
          num2str(scAxhostdata.scopeobj.scopeid),'_data'];
    strt=[scAxhostdata.scopeobj.up.Application,'_scope',...
          num2str(scAxhostdata.scopeobj.scopeid),'_time'];      
    scAxhostdata.exportNames={strd,strt};        
    scAxhostdata.cmenu=hAxesConextMenu;
        %end
    set(hAxes,'Userdata',scAxhostdata);
    setScopesSettings(hAxes)
    
    scAxhostdata=[];
    %schostdata=get(hAxes,'Userdata');
    %%%-------------------------------------
    %set(hAxes,'Userdata',scAxhostdata)
end %%%Add Axes per scope----------------------
%set(figH,'Userdata',xpcmngrUserData)
%%%%%%%%%%%%%
axch=findobj(figH,'Type','Axes','tag','Hostxpcsc');
axch=flipud(axch);
saveScopeSettings(axch);
%%%%%%%%%%%%%%%%%%%
scViewerUserData.tg=tg;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scAxhostdata = i_AddSignal2TraceonScopeAx(currentax,scAxhostdata,tg,xpcmngrUserData,args)
nargs=length(args);
figH=get(currentax,'Parent');
%xpcmngrUserData=get(figH,'UserData');
%scAxhostdata=get(currentax,'Userdata');


if strcmp(args{1},'ScOnCreate')%here event came from existing scope
    %get signal from scope    
    sigs2Add2Sc=xpcgate(tg.port,'getscsignals',scAxhostdata.scopeobj.ScopeId);
    nSigs=length(sigs2Add2Sc);
    if (nSigs)
        for i=1:nSigs
            sigName{i}=xpcgate(tg.port,'getsignalname',sigs2Add2Sc(i));
            scAxhostdata.line_plot(i)=line(0,0,'parent',currentax);
            scAxhostdata.txt_numerical(i) = ...
            text('Parent',currentax, ...
             'Units','normalized', ...
             'HorizontalAlignment','right', ...
             'Position',[0.2 0.3 0], ...
             'String','0.0000000', ...
             'Visible','off',...
             'FontSize',12,...
             'Tag','txt_numerical');
            color=xpcmngrUserData.scmngr.axesColorOrder(i,:);
            set(scAxhostdata.line_plot(i),'Color',color);
            %set(schostdata.line_plot(i),'Userdata',color);
        end
    else
        scAxhostdata.line_plot=[];
        scAxhostdata.txt_numerical=[];
        sigName='';
    end
end
if (nSigs)
    l=legend(currentax,sigName,'location','NorthEast');
    set(l,'TextColor',[1 1 1]);
    scAxhostdata.legend=l;
end
%here we add sig
try
  if strcmp(args{1},'ScAddSig')
     sigs2Add2Sc=args{2}; %str
     Sigid=xpcgate(tg.port,'getsignalid',sigs2Add2Sc,xpcmngrUserData.treeCtrl.SelectedItem.Root.Text);
     %add the sig to scope on target.
     xpcscsigs=xpcgate(tg.port,'getscsignals',scAxhostdata.scopeobj.ScopeId);
     sigidx=find(Sigid==xpcscsigs);
     if isempty(sigidx) %sig does not exist so add 
         xpcgate(tg.port,'addsig', scAxhostdata.scopeobj.ScopeId,Sigid);
         sigLine=line(0,0,'parent',currentax);
         numlines=length(scAxhostdata.line_plot);
         color=xpcmngrUserData.scmngr.axesColorOrder(numlines+1,:);
         set(sigLine,'Color',color);
         scAxhostdata.line_plot(end+1)=sigLine;
     end

  end
catch
  errordlg(lasterr)   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function axContxMenuH=i_createAxContextMenu(figH,ax)
axContxMenuH.rootax = uicontextmenu('parent',figH);
set(ax,'UIcontextMenu',axContxMenuH.rootax)
%xxx To do:  need to come up with a way to add signals to a scope.
%hmenu=uimenu(axContxMenuH.rootax,'Label','Scope
%Properties','callback','xpcmngr(''ScopePropInspect'',gcbf)' );
%axContxMenuH.root.signalselecitem=uimenu(axContxMenuH.rootax,'Label','Sign
%al Selecttion','callback','disp(''not available'')');
hm=uimenu(axContxMenuH.rootax,'Label','View Mode');
axContxMenuH.root.viewmode.GraphItem=uimenu(hm,'Label','Graphical',...
    'checked','on',...
    'callback',{@scopeVMenuscb, ax});
axContxMenuH.root.viewmode.NumItem=uimenu(hm,'Label','Numerical',...
    'checked','off',...
    'callback',{@scopeVMenuscb, ax});
axContxMenuH.root.legendItem=uimenu(axContxMenuH.rootax,'Label','Legends',...
    'checked','on',...    
    'Callback',{@scopeVMenuscb, ax});
axContxMenuH.root.GridItem=uimenu(axContxMenuH.rootax,'Label','Grid',...
    'checked','on',...    
    'Callback',{@scopeVMenuscb, ax});
hm2=uimenu(axContxMenuH.rootax,'Label','Y-Axis');
axContxMenuH.root.yaxis.root=hm2;
axContxMenuH.root.yaxis.auto=uimenu(hm2,'Label','Auto',...
    'checked','on',...
    'callback',{@scopeVMenuscb, ax});
axContxMenuH.root.yaxis.manual=uimenu(hm2,'Label','Manual',...
    'checked','off',...
    'callback',{@scopeVMenuscb, ax});
axContxMenuH.root.export.root=uimenu(axContxMenuH.rootax,'Label','Export',...
    'checked','off',...
    'callback',{@scopeVMenuscb, ax});
axContxMenuH.root.export.exNames=uimenu(axContxMenuH.root.export.root,'Label','Export Variable Names',...
    'checked','off',...
    'callback',{@scopeVMenuscb, ax});
axContxMenuH.root.export.exTrigger=uimenu(axContxMenuH.root.export.root,'Label','Export Scope Data',...
    'checked','off',...
    'callback',{@scopeVMenuscb, ax});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scopeVMenuscb(src,evt,ax)

scUserData=get(ax,'UserData');
mnuLabel=get(src,'Label');

switch mnuLabel,
    
case 'Graphical'
      set(scUserData.cmenu.root.viewmode.NumItem,'checked','off')  
      set(scUserData.cmenu.root.viewmode.GraphItem,'checked','on')
      set(scUserData.cmenu.root.yaxis.root,'enable','on');
      set(scUserData.cmenu.root.GridItem,'enable','on');            
      if strcmp(get(scUserData.cmenu.root.GridItem,'Checked'),'on')
           set(ax,'XGrid','on','Ygrid','on')
      else
           set(ax,'XGrid','off','Ygrid','off')
      end
       line_plot=scUserData.line_plot;
       text_plot=scUserData.txt_numerical;      
       set(line_plot,'Visible','on')
       %set(text_plot,'Visible','off')
      
case 'Numerical'
      set(scUserData.cmenu.root.viewmode.NumItem,'checked','on') 
      set(scUserData.cmenu.root.viewmode.GraphItem,'checked','off')   
      set(scUserData.cmenu.root.yaxis.root,'enable','off');
      set(scUserData.cmenu.root.GridItem,'enable','off');      
      set(ax,'XGrid','off','Ygrid','off')
      set(ax,'Box','off')
      line_plot=scUserData.line_plot;
      text_plot=scUserData.txt_numerical;      
      set(line_plot,'Visible','off')
      %set(text_plot,'Visible','on')      
      
case 'Legends'
    if strcmp(get(src,'checked'),'on')
        
        set(src,'checked','off')
        if isfield(scUserData,'legend')
            set(scUserData.legend,'visible','off')
        end
    else
        set(src,'checked','on')
        if isfield(scUserData,'legend')
            set(scUserData.legend,'visible','on')
        end
    end
case 'Grid'
    if strcmp(get(src,'checked'),'on')
        set(src,'checked','off')
        set(ax,'XGrid','off','Ygrid','off')
        
    else
        set(src,'checked','on')        
        set(ax,'XGrid','on','Ygrid','on')
    end    
case 'Auto'
    set(scUserData.cmenu.root.yaxis.manual,'checked','off')  
    set(scUserData.cmenu.root.yaxis.auto,'checked','on') 
    set(ax,'YLimMode','auto')
case 'Manual'
    set(scUserData.cmenu.root.yaxis.manual,'checked','on')  
    set(scUserData.cmenu.root.yaxis.auto,'checked','off') 
    prompt={'Enter Y maximum limit:','Enter Y minimum limit:'};
    name='Input for Y-Axis limits';
    numlines=1;
    ylim=get(ax,'Ylim');
    defaultanswer={num2str(ylim(2)),num2str(ylim(1))};
    answer=inputdlg(prompt,name,numlines,defaultanswer);      
    if (isempty(answer))        
        return
    end
    
    ymaxL=str2num(answer{1});
    yminL=str2num(answer{2}); 
    if (ymaxL <= yminL);
      errordlg('Y max must be greater then Y min');
      return;
    end;
    
    set(ax,'YLimMode','manual');    
    set(ax,'YLim',[yminL,ymaxL]);

case 'Export Variable Names'   
    prompt={'Data Variable Name:','Time Variable Name:'};
    name='Export Scope Data Names';
    numlines=1;
    ylim=get(ax,'Ylim');
    defaultanswer={scUserData.exportNames{1}, scUserData.exportNames{2}};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    if isempty(answer)
        return
    end
    dataName=answer{1};
    timeName=answer{2};
    scUserData.exportNames{1}=dataName;
    scUserData.exportNames{2}=timeName;
    set(ax,'userdata',scUserData)
case 'Export Scope Data'
    if strcmp(get(scUserData.cmenu.root.export.exTrigger,'checked'),'off')
        set(scUserData.cmenu.root.export.exTrigger,'checked','On')
    else
        set(scUserData.cmenu.root.export.exTrigger,'checked','Off')
    end
otherwise
    
end
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeScViewer(src,evt,timerObj)
%stop(timerObj)
axch=findobj(src,'Type','Axes','tag','Hostxpcsc');
%stopxpctimer(4);
saveScopeSettings(axch)
delete(src)
set(0,'showhiddenhandles','on');
figH=findobj(0,'Type','Figure','Tag','xpcmngr');
%scfigH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
xpcmngrUserData=get(figH,'userdata');
xpcmngrUserData.scfigure=[];
set(figH,'userdata',xpcmngrUserData);
%setappdata(0,'scmenupref',[])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resizeScFigure(src,evt)
%set(src,'Units','Normalized')
%axch=findobj(src,'Type','Axes','Tag','Hostxpcsc');
%set(axch,'Units','Normalized')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcmngrUserData=i_deleteHostScIdAxes(scViewerUserData,scopeId)
figH=xpcmngrUserData.figure;
allHostscIdcell=get(scViewerUserData.scmngr.Scope.scObj,'ScopeId');
if ~iscell(allHostscIdcell)
    allHostscIdcell={allHostscIdcell};
end
scIdVec=cat(1,allHostscIdcell{:});
scIdx=find(scopeId==scIdVec);%index to delete scope
axIdx2keep=scIdx;
delete(xpcmngrUserData.scmngr.Scope.scaxes(scIdx))
xpcmngrUserData.scmngr.Scope.scaxes(scIdx)=[];
xpcmngrUserData.scmngr.Scope.scObj(scIdx)=[];
xpcmngrUserData.scmngr.Scope.ScHilite=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scViewerUserData=i_deletechScopes(scfigH)
axch=findobj(scfigH,'Type','Axes','tag','Hostxpcsc');
axch=flipud(axch);
scViewerUserData=get(scfigH,'Userdata');
saveScopeSettings(axch)
if ~isempty(axch)
    scViewerUserData=get(scfigH,'Userdata');
	delete(scViewerUserData.scmngr.Scope.scaxes);
	scViewerUserData.scmngr.Scope.scaxes=[];
	%delete(xpcmngrUserData.scmngr.Scope.ScHilite);
	scViewerUserData.scmngr.Scope.ScHilite=[];                 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveScopeSettings(axch)

for i=1:length(axch)
    scUserdata=get(axch(i),'userdata');
    scmenu=scUserdata.cmenu;
    h=handle(scmenu.root.GridItem);
    scmenupref(i).gridchecked=h.checked;
    h=handle(scmenu.root.viewmode.GraphItem);
    scmenupref(i).Viewgraphchecked=h.checked;
    h=handle(scmenu.root.yaxis.auto);
    scmenupref(i).yaxAutochecked=h.checked;
    h=handle(scmenu.root.legendItem);
    scmenupref(i).legendchecked=h.checked;
    %store the scope id 
    scidtilestr=get(get(axch(i),'Title'),'string');     
    scmenupref(i).scopeid=eval(scidtilestr(8:end));
    %scmenupref(i).l
end
setappdata(0,'scmenupref',scmenupref)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setScopesSettings(ax)
scUserData=get(ax,'UserData');
scid=scUserData.scopeobj.scopeId;
scmenupref=getappdata(0,'scmenupref');
if ~isempty(scmenupref)
    allscids=cell2mat({scmenupref(:).scopeid});
    idx=find(allscids== scid);
    if isempty(idx)
        return
    end
    defme=scmenupref(idx);    
else
    return
end

%-----
if strcmp(defme.gridchecked,'on')
   set(scUserData.cmenu.root.GridItem,'checked','on')        
   set(ax,'XGrid','on','Ygrid','on')
else
    set(scUserData.cmenu.root.GridItem,'checked','off')
    set(ax,'XGrid','off','Ygrid','off')    
end
%-----

%-----
if strcmp(defme.Viewgraphchecked,'on')
    set(scUserData.cmenu.root.viewmode.GraphItem,'checked','on')
    set(scUserData.cmenu.root.viewmode.NumItem,'checked','off') 
    set(scUserData.cmenu.root.GridItem,'enable','on');
    set(scUserData.cmenu.root.yaxis.root,'enable','on');
    if strcmp(get(scUserData.cmenu.root.GridItem,'Checked'),'on')
       set(ax,'XGrid','on','Ygrid','on')
    else
       set(ax,'XGrid','off','Ygrid','off')
    end
    line_plot=scUserData.line_plot;
    text_plot=scUserData.txt_numerical;      
    set(line_plot,'Visible','on')
else%numerical on
    set(scUserData.cmenu.root.viewmode.NumItem,'checked','on') 
    set(scUserData.cmenu.root.viewmode.GraphItem,'checked','off')
    set(scUserData.cmenu.root.yaxis.root,'enable','off');
    set(ax,'XGrid','off','Ygrid','off')
    set(scUserData.cmenu.root.GridItem,'enable','off');
end
%-----

%-----
if strcmp(defme.legendchecked,'on')
   set(scUserData.cmenu.root.legendItem,'checked','on')
   if isfield(scUserData,'legend')
    set(scUserData.legend,'visible','on')
   end
else
   set(scUserData.cmenu.root.legendItem,'checked','off')
   if isfield(scUserData,'legend')
    set(scUserData.legend,'visible','off')    
   end
end
%-----


    
    





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 xPC Target Helper functions           *
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
