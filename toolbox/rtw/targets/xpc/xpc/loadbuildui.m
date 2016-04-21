function varargout = loadbuildui(varargin)
% LOADBUILDUI Dialog options to build and download application
%
%   This function should not be called directly.
%
%   See Also XPCRCTOOL.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/08 21:04:17 $


if nargin == 0
    javaFstate=feature('JavaFigures');
    feature('JavaFigures',0);
    fvisibiltystat=get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on')
    fighandle=findobj(0,'type','figure','tag','xpcloadUI');
    set(0,'showhiddenhandles',fvisibiltystat);
    if fighandle %if instance of xPCTool already exist
        figure(fighandle)
        return
    end
    origHidStat=get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');
    xpctoolfigH=findobj(0,'Type','figure','Tag','xPCCtrlPanel');
    set(0,'showhiddenhandles',origHidStat);
    posxpctool=get(xpctoolfigH,'position');
	fig = openfig(mfilename,'reuse');
    feature('JavaFigures',javaFstate);
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    posfig=get(fig,'position');
    newpos=[posxpctool(1) posxpctool(2)+(posxpctool(4)-posfig(4)) posfig(3) posfig(4)];
    set(fig,'position',newpos);
	handles = guihandles(fig);
	guidata(fig, handles);
    defcol=get(0,'defaultuicontrolbackgroundcolor');
    set(handles.framelb,'Backgroundcolor',defcol)
    set(handles.sellbST,'Backgroundcolor',defcol)
    set(handles.xpcbrowsePB,'Backgroundcolor',defcol)
    set(handles.okPB,'Backgroundcolor',defcol)
    set(handles.cancelPB,'Backgroundcolor',defcol)
    set(handles.systemselST,'Backgroundcolor',defcol)    
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
% --------------------------------------------------------------------
function varargout = popupmenu2_Callback(h, eventdata, handles, varargin)
str=get(h,'String');
val=get(h,'value');
if ~strcmp(str,' ') & ~(val==1)
    sys=str{val};
    set(handles.selectedsysST,'string',sys);
    set(handles.okPB,'enable','on');
end
if (val ==1)
    set(handles.selectedsysST,'string','');
    set(handles.okPB,'enable','off');
end
    
% --------------------------------------------------------------------
function varargout = okPB_Callback(h, eventdata, handles, varargin)
sysname=get(handles.selectedsysST,'string');
processxpcbuild(sysname,handles);
delete(handles.xpcloadUI);
% --------------------------------------------------------------------
function varargout = cancelPB_Callback(h, eventdata, handles, varargin)
delete(handles.xpcloadUI);
% --------------------------------------------------------------------
function varargout = popupmenu2_CreateFcn(h, eventdata, handles, varargin)
opnsys=find_system('type','block_diagram','BlockDiagramType','model');
if ~isempty(opnsys)
    discellsys=[{'Select system ...'};opnsys];
    set(h,'string',discellsys)
else
    set(h,'string',{'No open systems'})
end
% --------------------------------------------------------------------
function varargout = xpcbrowsePB_Callback(h, eventdata, handles,varargin)
filestr={'*.mdl' 'Simulink Model(*.mdl)';'*.dlm' 'xPC Target Application(*.dlm)'};
[filename, pathname] = uigetfile(filestr);
if (filename)
    appname=filename(1:end-4);
    set(handles.selectedsysST,'string',appname);
    set(handles.okPB,'enable','on');
end
% --------------------------------------------------------------------
function processxpcbuild(sysname,handles)
fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
fighandle=findobj(0,'type','figure','tag','xPCCtrlPanel');
set(0,'showhiddenhandles',fvisibiltystat);


t = get(fighandle,'Userdata');
filepathmdl=which([sysname,'.mdl']);
ismdl=~isempty(filepathmdl);
filepathdlm=which([sysname,'.dlm']);
isdlm=~isempty(filepathdlm);
[isdirty,isopen]=ismdlopen(sysname);

if ~(ismdl | ismdl) %file does not exist
    errordlg(['Can''t find ',sysname])
    return
end

if ~(isdlm) 
    if (isopen)
        ButtonName1=questdlg(['"',sysname,'"',' is curently open. '...
                             'Click ''Build'' to build and download the target application.'],...
                             'xPC Target Build Options','Build','Cancel','Cancel');                         
        switch ButtonName1,
            case 'Build' 
                  %stopxpctimer(4)
                  stop(t)
                  rtwbuild(sysname);
                  %defxpctimer(4,100,'refreshxpcpanel');
                  start(t);
                  return
            case 'Cancel'
                  return
        end%switch ButtonName1,
    end%if model is open
     %stopxpctimer(4)
     stop(t);
     rtwbuild(sysname);
     start(t);
    % defxpctimer(4,100,'refreshxpcpanel');
     return    
    end % if dlm does not exist

if (ismdl & isdlm) %files exist
    mdlinfostruct=dir(filepathmdl);
    mdltimestamp=datenum(mdlinfostruct.date);
    dlminfostruct=dir(filepathdlm);
    dlmtimestamp=datenum(dlminfostruct.date);
    if (isopen)  %if model is open 
        ButtonName1=questdlg(['"',sysname,'"',' is curently open. An existing target application was found. ',sprintf('\n'),...
                              'Click ''Build'' to build and download a new target application',sprintf('\n'),...
                              'Click ''Download'' to download existing target application.'],...
                              'xPC Target Build and Download Options', 'Build','Download','Cancel','Cancel');                    
        switch ButtonName1,
            case 'Build' 
                  stop(t);
                  %stopxpctimer(4)
                  rtwbuild(sysname);
                  %defxpctimer(4,100,'refreshxpcpanel');
                  start(t);
                  return
            case 'Download'
                  %stopxpctimer(4)
                  stop(t);
                  xpcload(sysname);
                  %defxpctimer(4,100,'refreshxpcpanel');
                  start(t);
                  return
            case 'Cancel'
                  return
        end%switch ButtonName1,
    end%if model is open 
    %if model is not open   
    if (mdltimestamp-dlmtimestamp > 0) %if mdl is newer than dlm
        ButtonName=questdlg(['''',sysname,''' model is newer than target application.', sprintf('\n'),...
                            'Click ''Rebuild'' to rebuild and download the new target application',sprintf('\n'),...
                            'Click ''Download'' to load the last built target application.'],'xPC Target Build and Download Options',...
                            'Rebuild','Download','Cancel','Cancel');
        switch ButtonName,
             case 'Rebuild', 
                     %stopxpctimer(4)
                     stop(t);
                     rtwbuild(sysname);
                     %defxpctimer(4,100,'refreshxpcpanel');
                     start(t);
                     return
              case 'Download',
                  %stopxpctimer(4)
                  stop(t);
                  tp=xpcload(sysname);
                  %defxpctimer(4,100,'refreshxpcpanel');
                  start(t);
                  
                  return
             case 'Cancel',
                  return
        end % switch      
    else  
          %stopxpctimer(4)
          stop(t);
          ll=xpcload(sysname);
          %defxpctimer(4,100,'refreshxpcpanel');
          start(t);
          return
    end %if mdl is newer than dlm
end%if (ismdl & isdlm) 
%------------------------------------------------------------------------------------

%function ismdlopen checks if model is open-----------------------
function [isdirty,isopen]=ismdlopen(sysname)
opnsys=find_system('type','block_diagram','BlockDiagramType','model');
if isempty(opnsys)
   isopen=0;isdirty=0;
   return
end
if (strmatch(sysname,opnsys))
   isopen=1;
   if strcmp('on',get_param(sysname,'dirty'))
       isdirty=1;
   else
       isdirty=0;
   end
else
    isopen=0;isdirty=0;
end
%end of ismdlopen----------------------


    

