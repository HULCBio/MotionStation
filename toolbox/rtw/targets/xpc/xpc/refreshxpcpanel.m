function refreshxpcpanel(flag)
% REFRESHXPCPANEL updates the xPC Remote Control Tool GUI
%
%   This function should not be called directly.
%
%   See Also XPCRCTOOL.


%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.16.6.3 $  $Date: 2004/04/08 21:04:19 $

timedef=1; %Tune rate limter.. 0 is fast

fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandle=findobj(0,'type','figure','tag','xPCCtrlPanel');
handles=guidata(fighandle);
set(0,'showhiddenhandles',fvisibiltystat);
try   
    modelname = xpcgate('getname');
catch
    error(xpcgate('xpcerrorhandler'));
end
% if Application is not loaded........

set(handles.xpcstatST,'String',xpcdispstat);
set(handles.go2slIC,'Oncallback',{@openslmdl get(handles.appnameST,'String')})
set(handles.xpctuneptIC,'Oncallback',{@openslview get(handles.appnameST,'String')})
set(handles.addviewsigIC,'Oncallback',{@openslview get(handles.appnameST,'String')})
% if timedef
%   stopxpctimer(4)
% end

if strcmp(modelname,'loader')
  xpcisloader(handles)
 % stopxpctimer(4)
  return
end
% if Application is loaded........
xpcisapp(handles,modelname)
% if timedef
%   defxpctimer(4,100,'refreshxpcpanel');
% end
%--------------------------------------------------------------------------
function xpcisapp(handles,modelname,status)

%Target has application Loaded.........................
set(handles.loaddlmMENU,   'enable', 'on')
set(handles.unloaddlmMenu, 'enable', 'on')
set(handles.viewmodePM,    'enable', 'on')
set(handles.updateIC,      'enable', 'off')

set(handles.stopappIC,     'enable', 'on')
set(handles.startappIC,    'enable', 'on')
set(handles.addviewsigIC,  'enable', 'on')
set(handles.xpctuneptIC,   'enable', 'on')

allstr={'All'};
try
  scs=xpcgate('getscopes','target');
  if ~isempty(scs)
    alltgscs=cellstr(strcat(num2str(sort(xpcgate('getscopes','target')'))));
    vmstr=[allstr;alltgscs];
    if (length(scs) == 1)
      sval = get(handles.viewmodePM,'Value');
      set(handles.viewmodePM,'Value',2)
    end
    set(handles.viewmodePM,'String',vmstr)
  else
    set(handles.viewmodePM,'Value',1)
    set(handles.viewmodePM,'String',allstr)
  end %~isempty(scs)

  switch xpcgate('getsimmode')
   case 0
    Modestr = 'Target not ready';
   case 1
    Modestr = 'RT, Single';
   case 2
    Modestr = 'RT, Multi';
   case 3
    Modestr = 'Freerun';
  end
  scopemanager(handles,modelname)

  %Logging status info----------------------------------
  status=xpcgate('getlogstatus');
  logstatusstr={'Off','Acquiring'};
  if status(5)
    avetetval=num2str(xpcgate('avgtet'), '%.6f');
    set(handles.averagetetST,'String', avetetval)
  else
    set(handles.averagetetST,'String', num2str(NaN))
  end
  if status(1) %if logging is turned on
    set(handles.loggingFR,                             ...
        'ToolTipstring', ['MaxLogSamples: ',           ...
                        num2str(xpcgate('maxsamp')),   ...
                        sprintf('\n'),'NumLogWraps: ', ...
                        num2str(xpcgate('waround'))])
    logtimecellstr={'','t '};logstatecellstr={'','x '};
    logopcellstr={'','y '};logtetcellstr={'','tet'};
    logstrst=[logtimecellstr{status(2)+1},logstatecellstr{status(3)+1}, ...
              logopcellstr{status(4)+1}, logtetcellstr{status(5)+1}];
    set(handles.logST,'String',logstrst);
  else %otherwise logging is turned off
    set(handles.loggingFR,'ToolTipstring',['MaxLogDamples: ',...
                        '0',sprintf('\n'),'NumLogWraps: ','0'])
    set(handles.logST,'String','off');
  end

  sampletimestr=num2str(xpcgate('getts'), '%.6f');
  tmp = xpcgate('gettfin');
  if tmp < 0
    tmp = inf;
  end
  stoptimestr=num2str(tmp, '%.2f');
  set(handles.appnameST,    'String', modelname);
  set(handles.sampletimeST, 'String', sampletimestr);
  set(handles.stoptimeST,   'String', stoptimestr);
  set(handles.stoptimeET,   'String', stoptimestr);
  set(handles.sampletimeET, 'String', sampletimestr);
  set(handles.modeST,       'String', Modestr);
  numofsigs=num2str(xpcgate('getnsig', get(handles.appnameST,'String')));
  numofpars=num2str(xpcgate('getnpar', get(handles.appnameST,'String')));
  if ~xpcgate('isrun') % stopped (not running)
    xpcstopaction(handles,status);
  else % if ~xpcgate('isrun')     (running)
    xpcrunaction(handles,status)
  end
catch
   if strcmpi(lasterr,'TCP/IP Read Error')
      if strcmp(xpctargetping,'success')
         defxpctimer(4,100,'refreshxpcpanel')
      end
   else
      stopxpctimer(4);
      set(handles.updateIC,'enable','on')
      error(xpcgate('xpcerrorhandler'));
   end
end
% set handles when app is in stop mode
%-------------------------------------------------------------------------
function xpcstopaction(handles,status)
set(handles.execST, 'String', 'stopped', 'foregroundcolor', 'yellow')
set(handles.stoptimeET,   'enable', 'on')
set(handles.sampletimeET, 'enable', 'on')
set(handles.plotlogPB,    'enable', 'on')
set(handles.startappIC,   'enable', 'on')
set(handles.stopappIC,    'enable', 'off')
xpclogaction(handles,status)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function xpcrunaction(handles,status)
set(handles.execST,'String',[num2str(xpcgate('getsimtime'), '%.2f'),' s'],...
                  'foregroundcolor','green');
logstatusstr={'Off','Acquiring'};
set(handles.startappIC,   'enable',        'off');
set(handles.stopappIC,    'enable',        'on');
set(handles.sampletimeET, 'enable',        'off')
set(handles.timelogCB,    'ToolTipString', logstatusstr{status(2)+1})
set(handles.statelogCB,   'ToolTipString', logstatusstr{status(3)+1})
set(handles.outputlogCB,  'ToolTipString', logstatusstr{status(4)+1})
set(handles.tetlogCB,     'ToolTipString', logstatusstr{status(5)+1})
set(handles.plotlogPB,    'enable',        'off')
set(handles.mintetST,     'String',        'NaN');
set(handles.maxtetST,     'String',        'NaN');
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
ttiph=findobj(0,'type','text','tag','sigtooltip');
set(0,'showhiddenhandles',fvisibiltystat)
if ~isempty(ttiph)
  sigstr=get(ttiph,'String');
  idx=findstr(sigstr,':');
  signame=sigstr(1:idx-1);
  tempName=signame;
  tempName(tempName == '_') = ' ';
  try
    id = xpcgate('getsignalid', tempName,get(handles.appnameST,'String'));
    if ~isempty(id)
        stringval = sprintf('%g', xpcgate('getmonsignals',id));
        sigtipstr=[signame,': ',stringval];
        set(ttiph,'String',sigtipstr);
    end
  catch
   if strcmpi(lasterr,'TCP/IP Read Error')
      if strcmp(xpctargetping,'success')
         defxpctimer(4,100,'refreshxpcpanel')
      end
   else
      stopxpctimer(4);
      set(handles.updateIC,'enable','on')
      error(xpcgate('xpcerrorhandler'));
   end
 end
end
%--------------------------------------------------------------------------
function xpcisloader(handles)
set(handles.scopesidLB,'String',{' '});
set(handles.appnameST,'String','loader')
set(handles.sampletimeST,'String','-')
set(handles.stoptimeST,'String','-')
set(handles.modeST,'String','-')
set(handles.stoptimeET,'enable','off')
set(handles.sampletimeET,'enable','off')
set(handles.execST,'String','-')
set(handles.scopesidLB,'String',' ')
set(handles.averagetetST,'String','-')
set(handles.mintetST,'String','')
set(handles.maxtetST,'String','')
set(handles.loaddlmMENU,'enable','on')
set(handles.unloaddlmMenu,'enable','off')
set(handles.viewmodePM,'String',{' '},'value',1)
%set(handles.viewmodePM,'enable','off')
set(handles.timelogCB,'enable','off')
set(handles.statelogCB,'enable','off')
set(handles.outputlogCB,'enable','off')
set(handles.tetlogCB,'enable','off')
set(handles.stopappIC,'enable','off')
set(handles.startappIC,'enable','off')
set(handles.addviewsigIC,'enable','off')
set(handles.xpctuneptIC,'enable','off')
set(handles.logST,'string','-')
set(handles.updateIC,'enable','on')
set(handles.scopesidLB,'string','')
set(handles.scopesidLB,'Value',0)
set(handles.vsTimeRB,'Value',0)
set(handles.vsSamplesRB,'Value',1)

%--------------------------------------------------------------------------
function xpclogaction(handles,status)
logstatusstr={'Off','Acquiring'};
try
  if status(2)
    %           timelogstr=sprintf('Vector(%d)', xpcgate('numsamp'));
    %           set(handles.timelogCB,'enable','on','ToolTipString',timelogstr)
    set(handles.vsTimeRB,'enable','on')
  else
    %           set(handles.timelogCB,'enable','off','ToolTipString',logstatusstr{status(2)+1})
    set(handles.vsTimeRB,'Value',0)
    set(handles.vsTimeRB,'enable','off')
    set(handles.vsSamplesRB,'enable','on')
    set(handles.vsSamplesRB,'value',1)
  end
  if status(3)
    statelogstr=sprintf('Matrix(%dx%d)', xpcgate('numsamp'), xpcgate('getnumst'));
    set(handles.statelogCB,'enable','on','ToolTipString',statelogstr)
  else
    set(handles.statelogCB,'enable','off','ToolTipString',logstatusstr{status(3)+1})
  end
  if status(4)
    outputlogstr=sprintf('Matrix(%dx%d)', xpcgate('numsamp'), xpcgate('getnumop'));
    set(handles.outputlogCB,'enable','on','ToolTipString',outputlogstr)
  else
    set(handles.outputlogCB,'enable','off','ToolTipString',logstatusstr{status(4)+1})
  end
  if status(5)
    set(handles.mintetST,'String',[num2str(xpcgate('mintet'), '%.6f')]);
    set(handles.maxtetST,'String',[num2str(xpcgate('maxtet'), '%.6f')]);
    set(handles.tetlogCB,'enable','on','ToolTipString',[sprintf('Vector(%d)', xpcgate('numsamp'))]);
  else
    set(handles.mintetST,'String','NaN');
    set(handles.maxtetST,'String','NaN');
    set(handles.tetlogCB,'enable','off','ToolTipString',logstatusstr{status(5)+1})
  end % status(5)
catch
   if strcmpi(lasterr,'TCP/IP Read Error')
      if strcmp(xpctargetping,'success')
         defxpctimer(4,100,'refreshxpcpanel')
      end
   else
      stopxpctimer(4);
      set(handles.updateIC,'enable','on')
      error(xpcgate('xpcerrorhandler'));
   end
end
%--------------------------------------------------------------------------
function openslview(h,eventdata,appname)
set(h,'state','off')
if strcmp('xpctuneptIC',get(h,'Tag'))
  commstr=['Scroll over a block and click to tune xPC parameters.'];
end
if strcmp('addviewsigIC',get(h,'Tag'))
  commstr=['Scroll over signal lines to view its signal value '];
end
try
  xpcsimview(appname,1)
catch
  errordlg(lasterr)
end
%--------------------------------------------------------------------------
function openslmdl(h,eventdata,appname)
set(h,'state','off')
if strcmp('loader',appname)
  return
end
try
  open_system(appname)
catch
  errordlg(lasterr)
end
%--------------------------------------------------------------------------
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

%--------------------------------------------------------------------------
function scopemanager(handles,modelname)
scs=sort(xpcgate('getscopes'));
if isempty(scs)
  scidSelVal=get(handles.scopesidLB,'Value');
  scidcell=get(handles.scopesidLB,'String');
  if (~isempty(scidcell) &  scidSelVal == length(scidcell) )
    set(handles.scopesidLB,'Value',length(scidcell)-1)
  end
  set(handles.scopesidLB,'String','');
  set(handles.rmscopePB,'enable','off');
  set(handles.scopesidLB,'tooltipstring','No scopes exist');
else % scope exisits
  scidSelVal=get(handles.scopesidLB,'Value');
  scidcell=get(handles.scopesidLB,'String');
  scopestr=cellstr(strcat(num2str(scs')));
  if (length(scs) < length(scidcell) & scidSelVal == length(scidcell))
    set(handles.scopesidLB,'Value',length(scidcell)-1)
  end
  if isempty(scidcell)
    set(handles.scopesidLB,'Value',1)
  end

  set(handles.rmscopePB,'enable','on');
  for ii=1:length(scopestr)
    scopetype=xpcgate('getsctype',str2num(scopestr{ii}));
    if (scopetype == 1)
      scopestr{ii}=[scopestr{ii},' (Host)'];
      xpcscoper
    elseif (scopetype == 2)
      scopestr{ii}=[scopestr{ii},' (Target)'];
    elseif (scopetype==3)
      scopestr{ii}=[scopestr{ii},' (File)'];
    end
  end %ii=1:length(scopestr)
  set(handles.scopesidLB,'String',scopestr);
  scidSelVal=get(handles.scopesidLB,'Value');
  scidcell=get(handles.scopesidLB,'String');
  if ~strcmp(' ',scidcell{scidSelVal});
    scopeIdstr=scidcell{scidSelVal};
    scopeIdstr=scopeIdstr(1:findstr(' ',scopeIdstr));
    xpcscs = xpcgate('getscsignals', str2num(scopeIdstr));
    if isempty(xpcscs)
      set(handles.scopesidLB,'tooltipstring',['No signals defined']);
    else
      begstr=1;
      for i = 1 : length(xpcscs)
        signal = xpcgate('getsignalname',xpcscs(i));
        %signal = getsigname(xpcscs(i),modelname);
        sigdDispStr=sprintf('%-3d: %s\n', xpcscs(i), signal);
        indstr=length(sigdDispStr);
        indstr=begstr+indstr-1;
        signalstring(begstr:indstr)=sigdDispStr;
        begstr=indstr+1;
      end
      set(handles.scopesidLB,'tooltipstring',signalstring);
    end
  end %~strcmp(' ',scidcell{scidSelVal});
end %isempty(scs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xpcscoper
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandle=findobj(0,'type','figure','tag','xPCTargetHostScopeManager');
set(0,'showhiddenhandles',fvisibiltystat);
if ~isempty(fighandle)
  xpcgate('stopxpctimer',3);
  feval(getappdata(fighandle, 'RefreshFunction'), fighandle);
  defxpctimer(4,100,'refreshxpcpanel')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
