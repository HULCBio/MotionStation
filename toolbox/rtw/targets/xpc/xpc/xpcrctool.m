function varargout = xpcrctool(varargin)
% XPCRCTOOL Launches the xPC Target remote control Tool GUI.
%
%   XPCRCTOOL is a graphical-user interface (GUI) that allows
%   you to interface with the xPC target PC remotely from
%   MATLAB running on your host PC to control, tune parameters
%   and monitor signals of the Real-Time application running on
%   the xPC Target PC. It provides a graphical interface with
%   exact funcionality as the xPC Target and Scopes objects.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/08 21:05:08 $

if nargin == 0  % LAUNCH GUI
  fvisibiltystat=get(0,'showhiddenhandles');
  set(0,'showhiddenhandles','on')
  fighandle=findobj(0,'type','figure','tag','xPCCtrlPanel');
  set(0,'showhiddenhandles',fvisibiltystat);
  if fighandle %if instance of xPCTool already exist
    figure(fighandle)
    return  
  end
  javaFstate=feature('JavaFigures');
  feature('JavaFigures',0);
  fig = openfig(mfilename,'reuse');    %center figure**********************************
  % Use system color scheme for figure:
  set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
  set(fig,'units','pixels');  %must reset
  figPos=get(fig,'Position');
  curUnit=get(0,'units');
  set(0,'units','pixels'); %must reset
  screenrect=get(0,'screensize');
  scrWidth=screenrect(3);scrHeight=screenrect(4);
  figWidth=figPos(3);figHeight=figPos(4);
  figPosition=[(scrWidth/2-figWidth/2)...
               (scrHeight/2-figHeight/2)...
               figWidth  figHeight];
  set(fig,'Position',figPosition);
  set(0,'units',curUnit); %set to orig
  set(fig,'units','characters');  %must reset
                                  %center figure**********************************
                                  %create toolbar items**************************
  load  xpcimages
  t = uitoolbar(fig,'HandleVisibility','off');
  a(1) = uitoggletool('Parent', t,...
                      'Tooltip','Build/Download application',...
                      'Cdata',stvbmp.build_btn,...
                      'tag','buildandldlmIC',...
                      'Oncallback',@bldandload);
  b(1) = uitoggletool('Parent',t,...
                      'Separator','On',...
                      'Tooltip','Go to Simulink Diagram',...
                      'tag','go2slIC',...
                      'Cdata',go2sl);
  b(2) = uitoggletool('Parent',t,...
                      'Tooltip','Open Simulink Library Browser',...
                      'Oncallback','set(gcbo,''State'',''off''); simulink',...
                      'tag','slbrowseIC',...
                      'Cdata',stvbmp.simulink_btn);
  b(3) = uitoggletool('Parent',t,...
                      'Tooltip','Open xPC Target Block Library',...
                      'tag','xpclibIC',...
                      'Oncallback','set(gcbo,''State'',''off''); xpclib',...
                      'Cdata',xpcicon);
  b(4) = uitoggletool('Parent',t,...
                      'Separator','On',...
                      'tag','updateIC',...
                      'Tooltip','Reconnect',...
                      'Oncallback',@updatexpctool,...
                      'Cdata',reconn);
  b(5) = uitoggletool('Parent',t,...
                      'Separator','On',...
                      'tag','xpctuneptIC',...
                      'Tooltip','Tune parameters',...
                      'enable','off',...
                      'Cdata',tunex);
  b(6) = uitoggletool('Parent',t,...
                      'Tooltip','View signals',...
                      'tag','addviewsigIC',...
                      'enable','off',...
                      'Cdata',probet);
  b(7) = uitoggletool('Parent',t,...
                      'Separator','On',...
                      'tag','startappIC',...
                      'Cdata',stvbmp.start_btn,...
                      'enable','off',...
                      'Tooltip','Start target application',...
                      'OnCallback',@startappxpc);
  b(8) = uitoggletool('Parent',t,...
                      'Tooltip','Stop target application',...
                      'tag','stopappIC',...
                      'enable','off',...
                      'Cdata',stvbmp.stop_btn,...
                      'OnCallback',@stopappxpc);
  %create toolbar items**************************
  handles = guihandles(fig);
  guidata(fig, handles);
  definecolors(handles)
  t=timer;
  t.Period=0.25;
  t.timerfcn='refreshxpcpanel';
  t.ExecutionMode='FixedRate';
  set(fig,'UserData',t)
  feature('JavaFigures',javaFstate);    
  if  strcmp(xpctargetping,'success')
    set(handles.xpcstatST,'String',xpcdispstat);
    start(t);
    %defxpctimer(4,100,'refreshxpcpanel');
    set(b(4),'enable','off');
  else
    ButtonName=questdlg('Communication to xPC Target Failed. Check xPC Setup.', ...
                        'Setup', 'Setup','Cancel','Cancel');
    switch ButtonName,
     case 'Setup',
      xpcsetup
     case 'Cancel'
      delete(fig);
    end % ButtonName
  end
  if nargout > 0
    varargout{1} = fig;
  end
elseif ischar(varargin{1})
  try
    if (nargout)
      [varargout{1:nargout}] = feval(varargin{:});
    else
      feval(varargin{:});
    end
  catch
    disp(lasterr);
  end
end
% CALLBACKS:
% --------------------------------------------------------------------
function varargout = hostscPB_Callback(h, eventdata, handles, varargin)
stopxpctimer(3)%stop the xpcscope timer callback
xpcscope

% --------------------------------------------------------------------
function varargout = targetscPB_Callback(h, eventdata, handles, varargin)
xpctgscope
% --------------------------------------------------------------------
function varargout = exitPB_Callback(h, eventdata, handles, varargin)
stop(get(h,'UserData'))
close(handles.xPCCtrlPanel)

% --------------------------------------------------------------------
function varargout = xPCCtrlPanel_CloseRequestFcn(h, eventdata, handles, varargin)
%stopxpctimer(4)
t=get(h,'Userdata');
stop(t)
delete(h)
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandle=findobj(0,'type','figure','tag','xPCSLViewFigure');
Hfig = findobj('Type','Figure','Tag','xPCFiglogdata2');
Hfig1 = findobj('Type','Figure','Tag','xPCFiglogdata1');

set(0,'showhiddenhandles',fvisibiltystat);
if fighandle %if instance of xPCTool already exist
  close(fighandle)
end
if Hfig
  delete(Hfig)
end
if Hfig1
  delete(Hfig1)
end

%check for host scopes to switch to xpcsxope timer
fvisibiltystat = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandle   = findobj(0,'type','figure','tag','xPCTargetHostScopeManager');
fighandletg = findobj(0,'type','figure','Name','xPC Target: Target Manager');
set(0,'showhiddenhandles',fvisibiltystat);
if ~isempty(fighandle)
  defxpctimer(3, 100, 'xpcscope');
end
if ~isempty(fighandletg)
  xpctgscope(-8)
end

% --------------------------------------------------------------------
function varargout = spyPB_Callback(h, eventdata, handles, varargin)
xpctargetspy
% --------------------------------------------------------------------
function varargout = unloadPB_Callback(h, eventdata, handles, varargin)
try
  if strcmpi(get(h,'enable'),'Unload','on')
    stopxpctimer(4)
    xpcgate('stopsess')
    %  set(h,'string','Load');
    defxpctimer(4,100,'refreshxpcpanel');
  else
    stopxpctimer(4)
  end
catch
  errordlg(lasterr,'xPC Target Error');
end

% --------------------------------------------------------------------
function varargout = unloaddlmMenu_Callback(h, eventdata, handles, varargin)
try
  %stopxpctimer(4);
  t= get(handles.xPCCtrlPanel,'Userdata');
  stop(t);
  xpcgate('stopsess')
  fvisibiltystat = get(0,'showhiddenhandles');
  set(0, 'showhiddenhandles', 'on')
  fighandle=findobj(0, 'type', 'figure', 'tag', 'xPCSLViewFigure');
  Hfig = findobj('Type','Figure','Tag','xPCFiglogdata2');
  Hfig1 = findobj('Type','Figure','Tag','xPCFiglogdata1');
  set(0,'showhiddenhandles',fvisibiltystat);
  if fighandle %if instance of xPCTool already exist
    close(fighandle)
  end
  if Hfig
    delete(Hfig)
  end
  if Hfig1
    delete(Hfig1)
  end
  start(t);
  %defxpctimer(4,100,'refreshxpcpanel');
catch
  errordlg(lasterr,'xPC Target Error');
end
% --------------------------------------------------------------------
function varargout = closeMenu_Callback(h, eventdata, handles, varargin)

%stopxpctimer(4)
t= get(handles.xPCCtrlPanel,'Userdata');
stop(t);
close(handles.xPCCtrlPanel)

%check for host scopes to switch to xpcsxope timer
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
scopeMgr = findobj('type','figure','tag','xPCTargetHostScopeManager');
set(0,'showhiddenhandles',fvisibiltystat);
scopemanager.handles.scopestart=fighandle;
if isempty(fighandle1) & isempty(fighandle1)
  return
end
%defxpctimer(3,100,'xpcscope');
start(t);



% --------------------------------------------------------------------
function varargout =xpcsimviewMenu_Callback(h, eventdata, handles, varargin)
try
  xpcsimview(get(handles.appnameST,'String'))
catch
  errordlg(lasterr)
end
% --------------------------------------------------------------------
function varargout = slmdlopen_Callback(h, eventdata, handles, varargin)
try
  open_system(get(handles.appnameST,'string'));
catch
  errordlg(lasterr)
end

% --------------------------------------------------------------------
function varargout = pushbutton10_Callback(h, eventdata, handles, varargin)
t = get(handles.xPCCtrlPanel,'Userdata');
stop(t);


% --------------------------------------------------------------------
function varargout = stoptimeET_Callback(h, eventdata, handles, varargin)
if strcmpi('inf',get(h,'string'))
  stoptimeval=-1;
  xpcgate('settfin',-1);
  return
end
stoptimeval=str2num(get(h,'string'));
if ~isempty(stoptimeval) | stoptimeval < 0
  try
    xpcgate('settfin',stoptimeval);
  catch
    errordlg(lasterr)
  end
else
  errordlg(['"',get(h,'string'),'" ','is not a valid stop time value.'],'xPC Target Error');
end
% --------------------------------------------------------------------
function varargout = viewmodePM_Callback(h, eventdata, handles, varargin)
selval=get(h,'Value'); selstr=get(h,'String');
try
  if strcmp('All',selstr{selval})      % it's char, must be 'all'
    xpcgate('settgscviewmode', 0);
    set(handles.viewmodePM,'Value',1)
  else                            % double: must be a legal scopeid
    xpcgate('settgscviewmode', str2num(selstr{selval}));
  end
catch
  errordlg(lasterr)
end
% --------------------------------------------------------------------
function sampletimeET_Callback(hObject, eventdata, handles)
sampletimeval=str2num(get(hObject,'string'));
if ~isempty(sampletimeval)
  try
    xpcgate('setts', sampletimeval);
  catch
    errordlg(lasterr)
  end
else
  errordlg(['"',get(hObject,'string'),'" ','is not a valid sample time value.'],'xPC Target Error');
end
% --------------------------------------------------------------------
function DisText=xpcdispstat
xpcver=ver('xpc');
env=getxpcenv;
comtype=env.actpropval{11};
mode=env.actpropval{22};
if strcmp('Enabled',mode)
  modestr='';
else
  modestr='Text Mode';
end
if strcmp('RS232',comtype)
  tempstr1=env.actpropval{12};
  tempstr2=env.actpropval{13};
  DisText=[xpcver.Name,' ',xpcver.Version,sprintf('\t\t'),comtype,...
           '\',tempstr1,'\',tempstr2,'  ',modestr];
end
if strcmpi('TcpIP',comtype)
  tempstr1=env.actpropval{14};
  tempstr2=env.actpropval{15};
  DisText=[xpcver.Name,' ',xpcver.Version,sprintf('\t'),comtype,...
           '\',tempstr1,':',tempstr2,'  ',modestr];
end
% --------------------------------------------------------------------

function plotlogPB_Callback(hObject, eventdata, handles)

CBhds=[handles.timelogCB handles.statelogCB ...
       handles.outputlogCB handles.tetlogCB];
CbHisen=CBhds(strmatch('on',get(CBhds,'enable'))');
CBisSelcell=get(CbHisen,'Value');
if ~iscell(CBisSelcell)
  CBisSelcell={CBisSelcell};
end
CBisSel=cat(1,CBisSelcell{:});
CBisSelH=CbHisen(find(CBisSel==1));
CBisSelH=num2cell(CBisSelH');
val = get(handles.viewlogmodePM,'Value');
if ~(length(CBisSelH))
  errordlg('Select which log(s) to plot.','xPC Target Error')
  return
end
%stopxpctimer(4)
t= get(handles.xPCCtrlPanel,'Userdata');
stop(t);

if (get(handles.vsTimeRB,'Value'))
  Time=xpcgate('gettime');
  plotflag=1;  %vs Time
else
  plotflag=0;  %vs Samples
end
%set(0,'showhiddenhandles','off')
for i=1:length(CBisSelH)
  %    subplot(length(CBisSelH),1,i)
  logtype=get(CBisSelH{i},'Tag');
  try
    switch logtype
     case  'tetlogCB'
      result=xpcgate('gettet');
      logtypestr=['TET log'];
      ylab=['TET data'];
     case  'statelogCB'
      result=xpcgate('getstate');
      logtypestr=['State log'];
      ylab=['State data'];
     case  'outputlogCB'
      result=xpcgate('getoutp');
      logtypestr=['Output log'];
      ylab=['Output data'];
    end
  catch
    errordlg(xpcgate('xpcerrorhandler'),'xPC Target Error');
    return
  end
  if(val==1)
    if(i==1)
      fvisibiltystat=get(0,'showhiddenhandles');
      set(0,'showhiddenhandles','on')
      logfigH=findobj(0,'Type','figure','tag','xPCFiglogdata1');
      set(0,'showhiddenhandles',fvisibiltystat);

      if ~isempty(logfigH)
        delete(logfigH)
        figh=figure('visible','off','NumberTitle','off',...
                    'Name',['xPC Target Log data plot: ',...
                            get(handles.appnameST,'String')],...
                    'tag','xPCFiglogdata1');
      else
        figh=figure('visible','off','NumberTitle','off',...
                    'Name',['xPC Target Log data plot: ',...
                            get(handles.appnameST,'String')],...
                    'tag','xPCFiglogdata1');
      end
    end
    subplot(length(CBisSelH),1,i);
  end
  if(val==2)
    fvisibiltystat=get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on')
    logfigH=findobj(0,'Type','figure','tag','xPCFiglogdata2');
    set(0,'showhiddenhandles',fvisibiltystat);
    if ~isempty(logfigH)
      delete(logfigH)
      f=figure('visible','off','NumberTitle','off',...
               'Name',['xPC Target Log data plot: ',...
                       get(handles.appnameST,'String')],...
               'Tag','xPCFigtemp');
    else
      f=figure('visible','off','NumberTitle','off',...
               'Name',['xPC Target Log data plot: ',...
                       get(handles.appnameST,'String')],...
               'Tag','xPCFigtemp');
    end
  end
  if ~(plotflag) %  vs sample
    plot(result);ylabel(ylab);title(logtypestr);
    xlstr='Number of samples';
  else % vs Time
    plot(Time,result);ylabel(ylab);title(logtypestr);
    xlstr='Time';
  end

  if(val==2)
    xlabel(xlstr);
    set(gcf,'Visible','On');
  end
  if(val==1)
    xdata=get(gca,'XTick');set(gca,'XTick',[]);
    if (i==length(CBisSelH))
      xlabel(xlstr);
      set(gca,'XTick',xdata)
      set(gcf,'Visible','On');
      set(gcf,'handleVisibility','off');
    end
  end
end %for loop
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
logfigH=findobj(0,'Type','figure','tag','xPCFigtemp');
set(0,'showhiddenhandles',fvisibiltystat);
screenrect=get(0,'screensize');
curUnit=get(0,'units');
scrWidth=screenrect(3);scrHeight=screenrect(4);
numfig=length(logfigH);
for i=1:numfig
  set(logfigH,'Tag','xPCFiglogdata2');
  set(logfigH,'units','pixels');  %must reset
end
if(val==2)
  maxpos=get (0,'screensize');
  maxpos(4)=maxpos(4) - 50;
  logfigsH=findobj(0,'type','figure','Tag','xPCFiglogdata2');
  logfigsH=sort(logfigsH);
  figs=size(logfigsH,1);
  maxfactor = sqrt(10);
  sq = [2:maxfactor].^2;
  sq = sq(find(sq>=figs));
  gridsize = sq(1);
  nrows = sqrt(gridsize);
  ncols = nrows;
  border = 0;
  xlength = fix(maxpos(3)/ncols) - 30;
  ylength = fix(maxpos(4)/nrows) - 45;
  pnum=0;
  for iy = 1:nrows
    ypos = maxpos(4) - fix((iy)*maxpos(4)/nrows) + border +25;
    for ix = 1:ncols
      xpos = fix((ix-1)*maxpos(3)/ncols + 1) + border+7;
      pnum = pnum+1;
      if (pnum>figs)
        break
      else
        figure(logfigsH(pnum))
        set(logfigsH(pnum),'Position',[ xpos ypos xlength ylength ]);
      end
    end
  end
end
%defxpctimer(4,100,'refreshxpcpanel');
t= get(handles.xPCCtrlPanel,'Userdata');
start(t);
% --------------------------------------------------------------------------------
function addscPB_Callback(hObject, eventdata, handles)

fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandlehost=findobj(0,'type','figure','tag','xPCTargetHostScopeManager');
fighandletg=findobj(0,'type','figure','Name','xPC Target: Target Manager');
set(0,'showhiddenhandles',fvisibiltystat);

scTypeVal=get(handles.sctypePM,'Value');
validTypes = {'target','host','file'};

switch validTypes{scTypeVal}
 case 'host'
  if isempty(fighandlehost)
    existingScopes = xpcgate('getscopes');
    numofScDef=length(existingScopes);
    try
        xpcgate('defscope',validTypes{scTypeVal})
    catch
        errordlg(xpcgate('xpcerrorhandler'));
    end
  else
    feval(@xpcscope,-1);
    return
  end
 case 'target'
  if isempty(fighandletg)
    existingScopes = xpcgate('getscopes');
    numofScDef=length(existingScopes);
    try
        xpcgate('defscope',validTypes{scTypeVal})
    catch
        errordlg(xpcgate('xpcerrorhandler'));
    end    
else
    feval(@xpctgscope,-7);
    return
  end
case 'file'
  if isempty(fighandlehost)
     existingScopes = xpcgate('getscopes');
     numofScDef=length(existingScopes);
  try
     xpcgate('defscope',validTypes{scTypeVal})
  catch
    errordlg(xpcgate('xpcerrorhandler'));
  end
  else
    feval(@xpcscope,-1);
    return
  end
end
% --------------------------------------------------------------------------------
function rmscopePB_Callback(hObject, eventdata, handles)
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandlehost=findobj(0,'type','figure','tag','xPCTargetHostScopeManager');
fighandle=findobj(0,'type','figure','tag','xPCHostScopeFigure');
fighandletg=findobj(0,'type','figure','Name','xPC Target: Target Manager');
set(0,'showhiddenhandles',fvisibiltystat);

set(handles.rmscopePB,'userdata',handles.scopesidLB)
set(handles.scopesidLB,'userdata',get(handles.scopesidLB,'String'))
scIdSelval=get(handles.scopesidLB,'Value');
scIdcell=get(handles.scopesidLB,'String');
lenofcell=length(scIdcell);
if  strcmp(' ',scIdcell{scIdSelval})
  errordlg('No scopes exist to be deleted.','xPC Target error');
end
scopeidstr=scIdcell{scIdSelval};
scopestrdel=scopeidstr;
idx=findstr(scopeidstr,' ');
if (length(idx) > 1)
  idx=idx(2);
end
scopeidstr=scopeidstr(1:idx);
scopeId=str2num(scopeidstr);
scType=scopestrdel(idx+1:end);
scType=scType(2:end-1);

if(scIdSelval==length(scIdcell) & scIdSelval~=1)
  set(handles.scopesidLB,'Value',length(scIdcell)-1)
end
% if isempty(fighandle1) & isempty(fighandle) & isempty(fighandletg)
%     xpcgate('delscope', scopeId)
% else
%     switch scType
%         case 'Host'
%             feval(@xpcscwin,-3,1);
%         case 'Target'
%             feval(@xpctgscope,-6);
%         end
%     return
% end
switch scType
 case 'Host'
  if isempty(fighandlehost)
    xpcgate('delscope', scopeId)
  else
    feval(@xpcscwin,-3,1);
  end
 case 'Target'
  if isempty(fighandletg)
    xpcgate('delscope', scopeId)
  else
    feval(@xpctgscope,-6);
    return
  end
case 'File'
if isempty(fighandletg)
    xpcgate('delscope', scopeId)
 end    
end
% --- Executes on selection change in sctypePM.
function sctypePM_Callback(hObject, eventdata, handles)
sctypeselval=get(hObject,'Value');
if (sctypeselval==1)
  set(handles.addscPB,'ToolTipString','Add scope to target');
elseif (sctypeselval==2)
  set(handles.addscPB,'ToolTipString','Add scope to host');
end

% --------------------------------------------------------------------
function addsigPB_Callback(hObject, eventdata, handles)
try
  % addsigstr=['Right click on signal to add it to a scope'];
  xpcsimview(get(handles.appnameST,'String'),1);
catch
  error(lasterr)
end
% --------------------------------------------------------------------
function bldandload(h,eventdata)
set(h,'state','off')
loadbuildui
% --------------------------------------------------------------------
function startappxpc(h,eventdata)
set(h,'state','off')
try
  if strcmpi(get(h,'enable'),'on')
    xpcgate('rlstart',1);
    set(h,'enable','off');
    %    set(handles.startPB,'enable','off')
    %    set(handles.stopPB,'enable','on')
  end
catch
  errordlg(lasterr)
end
% --------------------------------------------------------------------
function varargout = stopappxpc(h, eventdata)
set(h,'state','off')
if strcmpi(get(h,'enable'),'on')
  try
    xpcgate('rlstop');
    set(h,'enable','off');
  catch
    errordlg(lasterr)
  end
end
% --------------------------------------------------------------------
function updatexpctool(h,eventdata)
set(h,'state','off')
t=get(get(get(h,'Parent'),'Parent'),'UserData');
stop(t)
tempstr=xpctargetping;
if ~strcmp(tempstr,'success')
  errordlg('Connection Failed','xPC Target Error');
end
start(get(get(get(h,'Parent'),'Parent'),'UserData'));
%xdefxpctimer(4,100,'refreshxpcpanel');
% --------------------------------------------------------------------
function contentsMenu_Callback(h,eventdata,handles)
htmlFile = [docroot '/toolbox/xpc/xpc_product_page.html'];
web(htmlFile,'-helpbrowser');

% --------------------------------------------------------------------
function varargout = aboutxpcMenu_Callback(h, eventdata, handles, varargin)

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
copystr=['Copyright (c) 1996-2002',nline,...
         'The MathWorks. All Rights Reserved.'];
abxpcstr=['xPC Target',nline,nline,...
          'Version ',verxpc.Version,' ',...
          verxpc.Release,' ',verxpc.Date,nline,nline,nline,copystr];
abouth=msgbox(abxpcstr,'xPC Target About');
% --------------------------------------------------------------------
function definecolors(allH)
defcol=get(0,'defaultuicontrolbackgroundcolor');
set(allH.frame10,'Backgroundcolor',defcol)
set(allH.frame3,'Backgroundcolor',defcol)
set(allH.loggingFR,'Backgroundcolor',defcol)
set(allH.appparlabelST,'Backgroundcolor',defcol)
set(allH.stoplbST,'Backgroundcolor',defcol)
set(allH.samplelbST,'Backgroundcolor',defcol)
set(allH.minlbST,'Backgroundcolor',defcol)
set(allH.maxlbST,'Backgroundcolor',defcol)
set(allH.mintetST,'Backgroundcolor',defcol)
set(allH.maxtetST,'Backgroundcolor',defcol)
set(allH.sigtraceST,'Backgroundcolor',defcol)
set(allH.hosttgST,'Backgroundcolor',defcol)
set(allH.addscPB,'Backgroundcolor',defcol)
set(allH.sclbST,'Backgroundcolor',defcol)
set(allH.addsigPB,'Backgroundcolor',defcol)
set(allH.rmscopePB,'Backgroundcolor',defcol)
set(allH.viewtglbST,'Backgroundcolor',defcol)
set(allH.timelogCB,'Backgroundcolor',defcol)
set(allH.tetlogCB,'Backgroundcolor',defcol)
set(allH.statelogCB,'Backgroundcolor',defcol)
set(allH.outputlogCB,'Backgroundcolor',defcol)
set(allH.logdisST,'Backgroundcolor',defcol)
set(allH.plotlogPB,'Backgroundcolor',defcol)

% --------------------------------------------------------------------
function xpcrctoolMenu_Callback(hObject, eventdata, handles)
helpview(fullfile(docroot, 'mapfiles', 'xpc.map'), 'xpc_target_remote_control_tool')
% --------------------------------------------------------------------
function scopesidLB_ButtonDownFcn(hObject, eventdata, handles)
selscopeVal=get(handles.scopesidLB,'Value');
if ~selscopeVal
   return
end
cellstr=get(handles.scopesidLB,'string');
scopefullstr=cellstr{selscopeVal};
cmenu = uicontextmenu;
set(hObject,'UIcontextMenu',cmenu)
idx=findstr(scopefullstr,' ');
scopestr=scopefullstr(idx+1:end);
scopeidstr=scopefullstr(1:idx);
if strcmp('(Target)',scopestr);
   item1=uimenu(cmenu,'Label','Scope Properties','callback',{@setscprop handles scopeidstr} );
end
if strcmp('(Host)',scopestr)
   item1=uimenu(cmenu,'Label','Scope Properties','callback',{@setscprop handles scopeidstr} );
   item2=uimenu(cmenu,'Label','View Scope','callback','xpcscope');   
end
if strcmp('(File)',scopestr);
   item1=uimenu(cmenu,'Label','Scope Properties','callback',{@setscprop handles scopeidstr} );
end


% --------------------------------------------------------------------

% --------------------------------------------------------------------
function vsTimeRB_Callback(hObject, eventdata, handles)
vsTimeval=get(hObject,'Value');
vsSampleval=get(handles.vsSamplesRB,'Value');
if vsTimeval
  set(handles.vsSamplesRB,'Value',0)
else
  set(handles.vsSamplesRB,'Value',1)
end
% --------------------------------------------------------------------
function vsSamplesRB_Callback(hObject, eventdata, handles)
vsSampleval=get(hObject,'Value');
if strcmp('off',get(handles.vsTimeRB,'enable'))
  set(hObject,'Value',1);
  return
end
if vsSampleval
  set(handles.vsTimeRB,'Value',0)
else
  set(handles.vsTimeRB,'Value',1)
end

% --------------------------------------------------------------------
function setscprop(hObject,eventdata,handles,scopeidstr)
tg=xpc;
sc=tg.getscope(str2num(scopeidstr));
inspect(sc);
scopeidstr;

