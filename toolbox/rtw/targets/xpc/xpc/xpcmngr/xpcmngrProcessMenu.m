function xpcmngrUserData=xpcmngrProcessMenu(varargin)
%XPCMNGRPROCESSMENU xPC Target GUI Menus
%   XPCMNGRPROCESSMENU manages the User Interface Menus and toolbar for the
%   xPC Manager GUI.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $


Action = varargin{1};
%args   = varargin(3:end);

switch Action,

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Fig Menus----------%
case 'CreateMainMenu'
    xpcmngrUserData = varargin{2};
    i_createMainFigMenu(xpcmngrUserData)
%Fig Menus Event----%    
case 'MenuClick'    
    menuObj = varargin{2};
    i_processMenuClick(menuObj);     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Fig Toolbar--------%    
case 'CreateTB'
     xpcmngrUserData = varargin{2};
     xpcmngrUserData=i_createtoolbar(xpcmngrUserData);
%Fig Toolbar Click Events-------%         
case 'MenuTBClick'
     menuObj = varargin{2};
     i_processMenuTBClick(menuObj);
otherwise
    errordlg('No Action Item')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_createMainFigMenu(xpcmngrUserData)
%File Menus.............
filemH=uimenu(xpcmngrUserData.figure,...
    'Label','File',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},...
    'Tag','file');
xpcmngrUserData.uimenu.file.fileH=filemH;

xpcmngrUserData.uimenu.file.addxPCTG=uimenu(filemH,...
    'Label','Add Target',...
    'Accelerator','A',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},...
    'Tag','Add Target','Separator','on');
xpcmngrUserData.uimenu.file.remxPCTG=uimenu(filemH,...
    'Label','Remove Target',...
    'enable','off',...
    'Accelerator','R',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},...
    'Tag','Remove Target');
xpcmngrUserData.uimenu.file.cd=uimenu(filemH,...
    'Label','Change current directory...',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','cd','Separator','on');
xpcmngrUserData.uimenu.file.cd=uimenu(filemH,...
    'Label','Close',...
    'Accelerator','W',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','cd','Separator','on');

%%%%%%%%%%
%Target Menus..........                                                 
targetmH=uimenu(xpcmngrUserData.figure,...
    'Label','Target',...
    'enable','off',...    
    'Callback',{@i_menuClick,xpcmngrUserData.figure},...
    'Tag','edit');
xpcmngrUserData.uimenu.target.targetH=targetmH;
xpcmngrUserData.uimenu.target.start=uimenu(targetmH,...
    'Label','Start Application',...    
    'Accelerator','T',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},...
    'Tag','Start');
xpcmngrUserData.uimenu.target.stop=uimenu(targetmH,...
    'Label','Stop Application',...
    'Accelerator','T',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},...
    'Tag','Stop');
xpcmngrUserData.uimenu.target.addscope.scH=uimenu(targetmH,...
    'Label','Add a scope',...
    'Callback','',... 
    'Tag','save','Separator','on');

xpcmngrUserData.uimenu.target.addscope.host=uimenu(xpcmngrUserData.uimenu.target.addscope.scH,...
    'Label','Host scope',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','save');
xpcmngrUserData.uimenu.target.addscope.target=uimenu(xpcmngrUserData.uimenu.target.addscope.scH,...
    'Label','Target scope',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','save');
xpcmngrUserData.uimenu.target.addscope.file=uimenu(xpcmngrUserData.uimenu.target.addscope.scH,...
    'Label','File scope',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','save');
xpcmngrUserData.uimenu.target.remscope.scH=uimenu(targetmH,...
    'Label','Delete scope',...
    'enable','off',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','DelScope');

xpcmngrUserData.uimenu.target.remscope.scH=uimenu(targetmH,...
    'Label','View host scopes',...
    'enable','off',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','ViewScope');

%%---------Tools-----
toolsmH=uimenu(xpcmngrUserData.figure,'Label','Tools','Tag','tools',...
    'callback',{@i_menuClick,xpcmngrUserData.figure});
xpcmngrUserData.uimenu.tools.uimenuTools=toolsmH;

xpcmngrUserData.uimenu.tools.uimenuTools.tH=uimenu(toolsmH,...
    'Label','Disable Refresh',...
    'enable','on',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','RefreshExplr');
xpcmngrUserData.uimenu.tools.uimenuTools.tH=uimenu(toolsmH,...
    'Label','Ping Target',...
    'Accelerator','P',...'
    'enable','on',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','ping');

xpcmngrUserData.uimenu.tools.uimenuTools.tH=uimenu(toolsmH,...
    'Label','Go to Simulink Model',...
    'enable','on',...
    'Callback',{@i_menuClick,xpcmngrUserData.figure},... 
    'Tag','go2sl');

%help menus..........
xpcmngrUserData.uimenu.help.uimenuHelp=uimenu(xpcmngrUserData.figure,'Label','Help');
str=['helpview(fullfile(docroot, ''mapfiles'', ''xpc.map''), ''xPCTutorial'')'];
xpcmngrUserData.uimenu.help.sub.UxPC=uimenu(xpcmngrUserData.uimenu.help.uimenuHelp,...  
                                                'Label','Using xPC Target','callback',...
                                                str,'Tag','usingxpc');
str=['helpview(fullfile(docroot, ''mapfiles'', ''xpc.map''), ''xPCExplrTutorial'')'];                                            
xpcmngrUserData.uimenu.help.sub.UxPCmngr=uimenu(xpcmngrUserData.uimenu.help.uimenuHelp,...  
                                                'Label','xPC Target Explorer Help','callback',...
                                                 str,'Tag','uxpcmngr');                                            
                                                
xpcmngrUserData.uimenu.help.sub.about=uimenu(xpcmngrUserData.uimenu.help.uimenuHelp,...  
                                                'Label','About xPC Target','callback',...
                                                {@aboutxPC},'Tag','about');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function xpcmngrUserData=i_createtoolbar(xpcmngrUserData)
fig=xpcmngrUserData.figure;
load([xpcroot,'\xpc\xpcmngr\Resources\xpcimages']);
load([xpcroot,'\xpc\xpcmngr\Resources\sigbuilder_images']);
stvbmp2=stvbmp;
[x,map]=imread([xpcroot,'\xpc\xpcmngr\Resources\target_add.gif']);
rgb=ind2rgb(x,map);
idx=(find(rgb(:,:,1)==1));
rgb(idx)=NaN;
t = uitoolbar(fig,'HandleVisibility','off');
xpcmngrUserData.toolbar=t;
a(1) = uitoggletool('Parent', t,...
                    'Tooltip','Add target',...
                    'tag','AddTGPC',...  
                    'CData',rgb,...%stvbmp.open
                    'Oncallback',{@i_processMenuTBClick, fig}); 
                
[x,map,al]=imread([xpcroot,'\xpc\xpcmngr\Resources\delete.gif']);                
rgb=ind2rgb(x,map);
idx=(find(rgb(:,:,2)==1));
rgb(idx)=NaN;
b(1) = uitoggletool('Parent',t,...
                    'CData',rgb,...%stvbmp.save
                    'Tooltip','Delete target',...
                    'tag','DelTGPC',...
                    'Oncallback',{@i_processMenuTBClick, fig});                    
                
[x,map]=imread([xpcroot,'\xpc\xpcmngr\Resources\target_connect.gif']);
rgb=ind2rgb(x,map);
idx=(find(rgb(:,:,1)==1));
rgb(idx)=NaN;
b(2) = uitoggletool('Parent',t,...
                    'Tooltip','Connect to target',...   
                    'enable','off',...
                    'Cdata',rgb,...
                    'Oncallback',{@i_processMenuTBClick, fig},...
                    'tag','Connect');
b(3) = uitoggletool('Parent',t,...
                    'Separator','On',...
                    'tag','startapp',...
                    'Cdata',stvbmp.start_btn,...
                    'enable','off',...
                    'Tooltip','Start application',...
                    'OnCallback',{@i_processMenuTBClick, fig});
b(4) = uitoggletool('Parent',t,...
                    'Tooltip','Stop application',...
                    'tag','stopapp',...
                    'Cdata',stvbmp.stop_btn,...
                    'enable','off',...
                    'OnCallback',{@i_processMenuTBClick, fig});
               
[x,map]=imread([xpcroot,'\xpc\xpcmngr\Resources\scopeviewer_open.gif']);   
rgb=ind2rgb(x,map);

b(9) = uitoggletool('Parent',t,...
                    'Separator','On',...
                    'Tooltip','Scope Viewer',...
                    'tag','ScopeViewer',...
                    'Cdata',rgb,...
                    'enable','off',...
                    'OnCallback',{@i_processMenuTBClick, fig});                
b(10) = uitoggletool('Parent',t,...
                    'Separator','On',...
                    'enable','off',...
                    'tag','Go2SLMDL',...
                    'Tooltip','Go to Simulink model',...
                    'Cdata',go2sl,...
                    'Oncallback',{@i_processMenuTBClick, fig});
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_processMenuTBClick(menuObj,evt,figH)
set(menuObj,'state','off');
MenuType=get(menuObj,'Tag');
xpcmngrUserData=get(figH,'UserData');
tree=xpcmngrUserData.treeCtrl;
try    
  switch MenuType
      
  case 'AddTGPC'
      feval(xpcmngrTree('AddTargetNode'),tree);
  case 'DelTGPC'
      feval(xpcmngrTree('RemTargetPC'),tree);
  case 'Connect'
      try
          %tree.Freeze;
          ne=tree.selectedItem;
          tg=feval(xpcmngr('ConnectTargetPC'),xpcGetTarget(tree),tree);
          if isempty(tg)
              tree.UnFreeze;
              return
          end

          if strcmp(tg.Connected,'Yes') & ~strcmp(tg.application,'loader')
              %updateMenuLabes(figH,'Target','on')
              feval(xpcmngrUserData.drawPanelapi.menufcn,...
                  xpcmngrUserData.figure,'Target','on');
          end

          if strcmpi('No',tg.Connected)
              errordlg(lasterr,'xPC Target Error')
              return
          end
          feval(xpcmngrTree('ConnectTargetPC'),tree);
          %tg=xpcGETTG(tree);
          if strcmp(tg.application,'loader')
              % return
          else%poulate tg app node
              system=tg.Application;
              feval(tree.Api.populateTreeAppNode,tree,system,tg);
          end
          tree.selectedItem=ne;
          %tree.UnFreeze;
          %To do: create call fcn to for update of tree.targetd str
          %start timer here
      catch
          error(lasterr)
      end

  case 'starttimer'
      srart(xpcmngrUserData.timerObj)
      %xpcmngrUserData.timerObj.enabled=1;
%      start(xpcmngrUserData.timerObj);
      %defxpctimer(4,100,'updateTree1')
  case 'stoptimer'
       %xpcmngrUserData.timerObj.enabled=0;
      stop(xpcmngrUserData.timerObj);
      %stopxpctimer(4)
  case 'startapp'
      tg=gettg(tree);
      start(tg);
      updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
      updateToolbar(xpcmngrUserData.toolbar,'stopapp','on')
  case 'stopapp'      
      tg=gettg(tree);
      stop(tg);
      updateToolbar(xpcmngrUserData.toolbar,'startapp','on')
      updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')
      
  case 'startsc'
      scAxHostData=get(get(figH,'CurrentAxes'),'UserData');
      start(scAxHostData.scopeobj);
      %set(menuObj,'enable','off');       
  case 'stopsc'
      scAxHostData=get(get(figH,'CurrentAxes'),'UserData');
      stop(scAxHostData.scopeobj);
      %set(menuObj,'enable','off');  
  case 'addscope'
      if strcmp(xpcmngrUserData.subtabCtrl.SelectedItem.Caption,'Host Scopes')
          xpcmngr('AddScHost',figH);
      end
      
      if strcmp(xpcmngrUserData.subtabCtrl.SelectedItem.Caption,'Target Scopes')
          xpcmngr('AddScTarget',xpcmngrUserData);
      end
      
      if strcmp(xpcmngrUserData.subtabCtrl.SelectedItem.Caption,'File Scopes')
         xpcmngr('AddScFile',xpcmngrUserData);
      end
  case 'delscope'
      if strcmp(xpcmngrUserData.subtabCtrl.SelectedItem.Caption,'Host Scopes')
          xpcmngr('DelHostSc',gcbf);
      end
      
      if strcmp(xpcmngrUserData.subtabCtrl.SelectedItem.Caption,'Target Scopes')
          xpcmngr('DelScTarget',figH);
      end
      
      if strcmp(xpcmngrUserData.subtabCtrl.SelectedItem.Caption,'File Scopes')
         xpcmngr('DelScFile',figH);
      end
  case 'RemTrNode'
      Remove(xpcmngrUserData.treeCtrl.Nodes,xpcmngrUserData.treeCtrl.SelectedItem.Index);
  case 'allsysNode'
      sys=xpcmngrUserData.treeCtrl.SelectedItem.Root.Text;
      Clear(xpcmngrUserData.treeCtrl.Nodes);
      
      sys=get(xpc,'Application');
      load_system(sys);
      i_populateMdlHeirTree(sys,xpcmngrUserData,0)
   case 'Delete scope'      
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
           error(lasterr);
       end
    case 'ScopeViewer'
        tg = getTG(tree); 
        xpcmngrUserData=xpcmngrScopeViewer('createScViewer',xpcmngrUserData,tg);    
        set(xpcmngrUserData.figure,'userdata',xpcmngrUserData)
    case 'Go2SLMDL'
          try
            open_system(tree.selectedItem.text)
          catch
              errordlg(lasterr)
          end
          
  otherwise
      errordlg('No Menu Item')
  end
catch
    errordlg(lasterr)    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
function i_menuClick(src,evt,figH)
xpcmngrUserData=get(figH,'Userdata');
tree=xpcmngrUserData.treeCtrl;
menuItem=get(src,'Label');
timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;      
timerflag=[];
switch menuItem,
    
    case 'File'        
        if isempty(tree.selectedItem)
           feval(xpcmngrUserData.drawPanelapi.menufcn,...
               xpcmngrUserData.figure,'Remove Target','off');    
        elseif (findstr(tree.SelectedItem.key,'TGPC'))
            feval(xpcmngrUserData.drawPanelapi.menufcn,...
               xpcmngrUserData.figure,'Remove Target','on');
        else
            feval(xpcmngrUserData.drawPanelapi.menufcn,...
               xpcmngrUserData.figure,'Remove Target','off');            
        end
    case 'Open a session...'        
    case 'Save session'
    case 'Change current directory...'
        dirName=uigetdir(pwd,'Change your Current Working Directory');
        if (dirName==0)
            return 
        end
        cd(dirName)        
    case 'Add Target'
         stop(xpcmngrUserData.timerObj)
         feval(xpcmngrTree('AddTargetNode'),tree);
         timerreset(timerStatus,xpcmngrUserData.timerObj)
         
    case 'Remove Target'  
         stop(xpcmngrUserData.timerObj)
         feval(xpcmngrTree('RemTargetPC'),tree);
         timerreset(timerStatus,xpcmngrUserData.timerObj)
    case 'Target'
        stop(xpcmngrUserData.timerObj)
        if strcmp(get(src,'enable'),'off')
            timerreset(timerStatus,xpcmngrUserData.timerObj)
            return
        end
        tg=gettg(tree);
        if strcmp(tg.status,'running')
            feval(xpcmngrUserData.drawPanelapi.menufcn,...
               xpcmngrUserData.figure,'Stop Application','on');
            feval(xpcmngrUserData.drawPanelapi.menufcn,...
               xpcmngrUserData.figure,'Start Application','off');
        else
            feval(xpcmngrUserData.drawPanelapi.menufcn,...
               xpcmngrUserData.figure,'Stop Application','off');
            feval(xpcmngrUserData.drawPanelapi.menufcn,...
               xpcmngrUserData.figure,'Start Application','on');
        end
        timerreset(timerStatus,xpcmngrUserData.timerObj)
    case 'Stop Application'
         updateToolbar(xpcmngrUserData.toolbar,'startapp','on')
         updateToolbar(xpcmngrUserData.toolbar,'stopapp','off')         
    case 'Start Application'         
         updateToolbar(xpcmngrUserData.toolbar,'startapp','off')
         updateToolbar(xpcmngrUserData.toolbar,'stopapp','on')
    case 'Host scope'    
        
        timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                             {'off','on'},'exact') - 1;
        stop(xpcmngrUserData.timerObj)                         
        nodeIdx=treeNodeIdxofTG(tree,'Host Scope(s)');
        if isempty(nodeIdx)
            errordlg('Could not find node');
            timerreset(timerStatus,xpcmngrUserData.timerObj)
            return
        end
        try
            tg=gettg(tree);
            scopeid=feval(xpcmngr('AddxPCScope'),tg,tree,'Host');
            feval(xpcmngrTree('AddScope'),tree,scopeid,nodeIdx);
            set(0,'showhiddenhandles','on');        
            scfigH=findobj(0,'Type','Figure','Tag','HostScopeViewer');
            set(0,'showhiddenhandles','off');    
            if ~isempty(scfigH)
                %stop(xpcmngrUserData.timerObj)
                fcnh1=xpcmngrUserData.api.scViewer.delAllScAxes;
                fcnh=xpcmngrUserData.api.scViewer.createAllScAxes;
                scViewerUserData=feval(fcnh1,xpcmngrUserData.scfigure);
                set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
                scViewerUserData=feval(fcnh,xpcmngrUserData.scfigure,tg);            
                set(xpcmngrUserData.scfigure,'userdata',scViewerUserData);
                %start(xpcmngrUserData.timerObj)        
            end   
            timerreset(timerStatus,xpcmngrUserData.timerObj)
        catch
           errordlg(lasterr) 
           timerreset(timerStatus,xpcmngrUserData.timerObj)
        end
		%hostidx=tree.nodes.Item(tgxpcIdx).child.next.child.next.child.inde
		%x;
        %%%to do: finish implementing the addsing soopes from menu
    case 'Target scope'
        timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;          
        stop(xpcmngrUserData.timerObj);
        nodeIdx=treeNodeIdxofTG(tree,'Target Scope(s)');
        if isempty(nodeIdx)
            error('Could not find node');
            timerreset(timerStatus,xpcmngrUserData.timerObj) 
            return
        end
        try
            tg=gettg(tree);
            scopeid=feval(xpcmngr('AddxPCScope'),tg,tree,'Target');
            feval(xpcmngrTree('AddScope'),tree,scopeid,nodeIdx);          
        catch
            errordlg(lasterr)
            timerreset(timerStatus,xpcmngrUserData.timerObj) 
            return
        end
        timerreset(timerStatus,xpcmngrUserData.timerObj)
    case 'File scope'
        timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;          
        stop(xpcmngrUserData.timerObj);
        nodeIdx=treeNodeIdxofTG(tree,'File Scope(s)');
        if isempty(nodeIdx)
           if timerStatus == 0
                start(xpcmngrUserData.timerObj)
           end
           errordlg('Could not find node');           
           timerreset(timerStatus,xpcmngrUserData.timerObj)
           return
       end
        try
            tg=gettg(tree);
            scopeid=feval(xpcmngr('AddxPCScope'),tg,tree,'File');
            feval(xpcmngrTree('AddScope'),tree,scopeid,nodeIdx);          
        catch
            errordlg(lasterr)
            timerreset(timerStatus,xpcmngrUserData.timerObj)        
            return
        end
        timerreset(timerStatus,xpcmngrUserData.timerObj)        
   case 'Delete scope'      
       timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;          
       stop(xpcmngrUserData.timerObj);
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
           timerreset(timerStatus,xpcmngrUserData.timerObj)        
           return
       end
       timerreset(timerStatus,xpcmngrUserData.timerObj)        
       return
    case 'Close'
       xpcmngrGUI('CloseGUI',xpcmngrUserData.figure);
    case 'Ping Target'
        xPCEnv=xpcGetTarget(tree);
        commType=xPCEnv.HostTargetComm;
        if strcmp(commType,'TcpIp')
            arg1= 'TcpIp';
            arg2= xPCEnv.TcpIpTargetAddress;
            arg3= xPCEnv.TcpIpTargetPort;
        else%rs232
            arg1= 'RS232';
            arg2= xPCEnv.RS232HostPort;
            arg3= eval(xPCEnv.RS232Baudrate);
        end           
        try
            msgbox(xpctargetping(arg1,arg2,arg3),[tree.selectedItem.text,' Ping Result']);
        catch
            errordlg(lasterr)
        end
    case 'Tools'
        reshmenuh=findobj(src,'Tag','RefreshExplr');
        timerStatus=strmatch(xpcmngrUserData.timerObj.running,...
                     {'off','on'},'exact') - 1;  
        if timerStatus == 0
            set(reshmenuh,'Label','Refresh Enable')            
        else
            set(reshmenuh,'Label','Refresh Disable')            
        end
    case 'Refresh Enable' 
        start(xpcmngrUserData.timerObj)
        set(xpcmngrUserData.sbarTree.Panels.Item(1),'text','Refresh Enabled');
    case 'Refresh Disable'
          stop(xpcmngrUserData.timerObj)
          %xpcmngrUserData.timerObj.enabled = 0;
          set(xpcmngrUserData.sbarTree.Panels.Item(1),'text','Refresh Disabled');
          
    case 'Go to Simulink Model'
          try
              open_system(tree.selecteditem.text)
          catch
              errordlg(lasterr)
          end
    otherwise
        error('Invalid Aciton');
    end


    









%%%%%%%%%%%
function nodeIdx=treeNodeIdxofTG(tree,search)
if findstr(tree.selectedItem.key,'TGPC')
    targetNameStr=tree.selectedItem.Text;
else
    %%%find the root target node
    fullpath=tree.SelectedItem.Fullpath;
    sepIdx=findstr('\', tree.SelectedItem.Fullpath);
    targetNameStr=fullpath(1:sepIdx-1);
end

allNames=tree.GetAllNames;
HostndIdx=strmatch(search,allNames);
listScName={};
nodeIdx=[];
for i=1:length(HostndIdx)
    if findstr(targetNameStr,tree.Nodes.Item(HostndIdx(i)).Fullpath)
        nodeIdx=HostndIdx(i);
        break
    end
%listScName{end+1}=tree.Nodes.Item(HostndIdx(i)).Fullpath
end
%%%%%%%%%%%%%%%%%%%
function savexpcmngrTargetConfig(tree,fileName,pathName)
allKeys=tree.GetAllKeys;
allNames=tree.GetAllNames;
tgpcidx=strmatch('TGPC',allKeys);
numofTargets=length(tgpcidx);
tgNames=allNames(tgpcidx);
targets=tree.targets
tgfieldNames=fieldnames(targets)
for i=1:numofTargets
    estr=['targets.',tgfieldNames{i},'=rmfield(targets.',tgfieldNames{i},',''tg''',')'];
    eval(estr);
    %estr=['targets.',tgfieldNames{i},'=rmfield(targets.',tgfieldNames{i},',''bio''',')'];
    %eval(estr);
    %estr=['targets.',tgfieldNames{i},'=rmfield(targets.',tgfieldNames{i},',''pt''',')'];
    %eval(estr);
end
srcfileName=[pathName,fileName];
save(srcfileName,'tgNames','tgfieldNames','targets','-MAT')
    


%%%%%%%%%%%%%%%%%%%
function openxpcmngrTargetConfig(tree,fileName,pathName)
tree.Targets=[];
next=tree.Nodes.Item(1).next;
while ~isempty(next)
   if isprop(tree,next.text)
       tree.deleteproperty(next.text);
   end     
   tree.Nodes.Remove(next.Index)
   next=tree.Nodes.Item(1).next;
end

srcfileName=[pathName,fileName];
load(srcfileName,'tgNames','tgfieldNames','targets','-MAT')

for i=1:length(tgNames)    
   if isprop(tree,tgNames{i})
       tree.deleteproperty(tgNames{i});
   end 
   [nametgpc,tgtreeIdx] = feval(xpcmngrTree('AddTargetNode'),tree);
   set(tree.Nodes.Item(tgtreeIdx),'Text',tgNames{i})
   tree.deleteproperty(nametgpc);
   tree.addproperty(tgNames{i});
end
tree.Targets=targets;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateToolbar(uitoolH,toolItem,state)
toolH=findobj(uitoolH,'Type','UIToggletool','Tag',toolItem);
if ~isempty(toolH)
    set(toolH,'enable',state);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aboutxPC(obj,evt)
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandle=findobj(0,'type','figure','tag','Msgbox_xPC Target About');
set(0,'showhiddenhandles',fvisibiltystat);
if fighandle %if instance of xPCTool already exist
  figure(fighandle)
  return
end
verxpc=ver('xpc');
nline=sprintf('\n');
copystr=['Copyright (c) 1996-2004',nline,...
         'The MathWorks. All Rights Reserved.'];
abxpcstr=['xPC Target',nline,nline,...
          'Version ',verxpc.Version,' ',...
          verxpc.Release,' ',verxpc.Date,nline,nline,nline,copystr];
abouth=msgbox(abxpcstr,'xPC Target About');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timerreset(chksum,timerObj)
if chksum==1
   start(timerObj)
else
   stop(timerObj)
end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





