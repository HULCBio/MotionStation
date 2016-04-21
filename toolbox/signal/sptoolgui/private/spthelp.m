function varargout = spthelp(varargin)
%SPTHELP  Context sensitive Help facility for SPTool and clients.
% This function has three main modes.  The first two are a pair:
%  an 'enter' mode, and an 'exit' mode which is usually called 
%  by this function automatically
% The third mode takes a tag and a help file and displays the help
%  for that tag in helpwin.
% ----------------------------------------------------------------
% spthelp('enter',fig,saveEnableControls,ax,titleStr,helpFcn,useHandle)
% Enter context sensitive help mode.
%  Clears windowbuttonmotionfcn
%  sets enable of all uicontrols to inactive
%  sets buttondownfcn of all uicontrols and selected axes and their children
%   to spthelp('exit',get(gcbo,'tag'))
%  sets callback of all uimenus at the bottom level (no children) to 
%   spthelp('exit',get(gcbo,'tag'))
%  sets ud.pointer to 2 (stands for help mode)
%  saves all this in the userdata structure of the input figure
% Inputs:
%    fig - figure handle
%    saveEnableControls - list of handles of uicontrols, uitoggletools, and
%       uipushtools whose enable property needs to be restored after help mode.
%    ax - list of non-btngroup axes handles.  All lines, patches, and text
%       children of these axes are temporarily set to call spthelp for their
%       buttondownfcns.  Note that btngroups must handle help on their own
%       by detecting when ud.pointer == 2 and calling spthelp('exit',tag)
%       if so (see ruler and zoom functions for examples).
%    titleStr - this will be used as the title for the helpwin
%    helpFcn - function name.  This function will be called with the
%       tag1 (or tag1:tag2) parameters and must return a cell array
%       of strings as per the multi-topic input of 'helpwin'
%    useHandle - optional, defaults to 0
%       if non-zero, helpFcn will be called with helpFcn(tag,fig,gcbo)
%       so the handle of the clicked object will be passed to helpFcn
% ---------------------------------------------------------------
% spthelp('exit',tag1,tag2)
% Display help for object with tag1 (or tag1:tag2) in helpwin
% then leave context sensitive help mode, restoring figure to original condition.
% Inputs:
%    tag1 - string, tag of object clicked on; optional; defaults to 'help'
%    tag2 - optional; if present, helpFcn will be called with 'tag1:tag2' tag.
% ---------------------------------------------------------------
% spthelp('tag',fig,titleStr,helpFcn,tag1,tag2)
% Takes a tag and a help file and displays the help
%  for that tag in helpwin.
% Inputs:
%    fig - figure handle of calling tool
%    titleStr - this will be used as the title for the helpwin
%    helpFcn - function name.  This function will be called with the
%       tag1 (or tag1:tag2) parameters and must return a cell array
%       of strings as per the multi-topic input of 'helpwin'

%  This function has a modal behavior depending on the value of
%  ud.pointer.
%  On entry: 
%     ud.pointer == 2  --> sphelp displays help and sets ud.pointer 
%                          to 0 (leave help mode).
%     ud.pointer ~= 2  --> set ud.pointer to 2 (enter help mode).

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.13 $

action = varargin{1};

switch action
case 'enter'
% Enter help mode
   fig = varargin{2};
   saveEnableControls = varargin{3};
   ax = varargin{4};
   titleStr = varargin{5};
   helpFcn = varargin{6};
   if nargin > 6
       useHandle = varargin{7};
   else
       useHandle = 0;
   end
   
   ud = get(fig,'userdata');
   
   ud.help.helpFcn = helpFcn;
   ud.help.titleStr = titleStr;
   ud.help.oldwbdf = get(fig,'windowbuttondownfcn');
   ud.help.saveEnableControls = saveEnableControls;
   ud.help.ax = ax;
   
   set(fig,'windowbuttondownfcn','')

   saveEnable = get(saveEnableControls,'enable');
%   if length(saveEnableControls)==1
%       set(saveEnableControls,'userdata',saveEnable)
%   else
%       set(saveEnableControls,{'userdata'},saveEnable)
%   end
   
   if useHandle
       shelpButtonDownFcn = ...
          'sbswitch(''spthelp'',''exit'',get(gcbo,''tag''),'''',gcbo)';
   else
       shelpButtonDownFcn = 'sbswitch(''spthelp'',''exit'',get(gcbo,''tag''))';
   end
   uiControls = findobj(fig,'type','uicontrol');
   % Set enable to inactive for all uicontrols:
   set(uiControls,'enable','inactive')
   % Set enable to ON for all uipushtools and uitoggletools:
   %  Note that uipushtools and uitoggletools need to police
   %  themselves; if they are clicked and ud.pointer==2, then
   %  they must call spthelp('exit',helptag) themselves
   uipushtools = findobj(fig,'type','uipushtool');
   set(uipushtools,'enable','on')
   uitoggletools = findobj(fig,'type','uitoggletool');
   set(uitoggletools,'enable','on')
   % Set buttondownfcn of uiControls; since they are inactive, this
   % will send a callback to the appropriate help function:
   set(uiControls,'buttondownfcn',shelpButtonDownFcn)
   saveAxesButtonDownFcns = get(ax,'buttondownfcn');
   set(ax,'buttondownfcn',shelpButtonDownFcn)
   lines = findobj(ax,'type','line');
   saveLineButtonDownFcns = get(lines,'buttondownfcn');
%   set(lines,{'userdata'},saveLineButtonDownFcns);
   set(lines,'buttondownfcn',shelpButtonDownFcn)
   texts = findobj(ax,'type','text');
   set(texts,'buttondownfcn',shelpButtonDownFcn)

   % find all uimenus with no children:
   uiMenus = findobj(fig,'type','uimenu','children',zeros(0,1));
   ind = findcstr(get(uiMenus,{'tag'}),'winmenu');
   uiMenus(ind) = [];
   for i=length(uiMenus):-1:1
      p = get(uiMenus(i),'parent');
      if ishandle(p) & strcmp(get(p,'tag'),'winmenu')
         uiMenus(i) = [];
      end
   end 
   % temporarily enable the 'Markers' menu if present
   markersMenu = findobj(fig,'type','uimenu','label','&Markers','tag','markersmenu');
   if ~isempty(markersMenu)
      uiMenus(end+1) = markersMenu;
   end
   saveUiMenuCallbacks = get(uiMenus,'callback');
   saveUiMenuEnable = get(uiMenus,'enable');
   set(uiMenus, 'callback', shelpButtonDownFcn,'enable','on')
   if ~isempty(markersMenu)  % but DON'T set the markers menu callback
      set(markersMenu,'callback','')
   end
   if length(uiMenus)==1
      saveUiMenuCallbacks = {saveUiMenuCallbacks};
      saveUiMenuEnable = {saveUiMenuEnable };
   end
   set(uiMenus, {'userdata'}, saveUiMenuCallbacks)

   ud.help.savePointer = ud.pointer;   
   ud.pointer = 2;
   ud.help.saveEnable = saveEnable;
   ud.help.saveUiMenuEnable = saveUiMenuEnable;
   ud.help.saveAxesButtonDownFcns = saveAxesButtonDownFcns;
   ud.help.saveLineButtonDownFcns = saveLineButtonDownFcns;
   set(fig,'userdata',ud)
   setptr(fig,'help')
   
   % Check what's this uimenu:
   um=findobj(fig,'tag','whatsthismenu');
   set(um,'checked','on')
   
   if isfield(ud,'toolbar'),
	   toolbarBlanks = findobj(get(ud.toolbar.mousezoom,'parent'),'type','uipushtool','tag','blank');
	   set(toolbarBlanks,'enable','off');
   end
   
case 'exit'
% We are coming out of help mode - figure out where from and display help
   fig = gcf;
   if ~isequal(gcbf, fig) & ishandle(gcbf)
      figure(gcbf);
      fig = gcbf;
   end
   ud = get(fig,'userdata');
   set(fig,'windowbuttondownfcn',ud.help.oldwbdf)
  
   if isfield(ud,'toolbar'),
       set(ud.toolbar.whatsthis,'state','off')  % restore help button to up state
   end
   uiControls = findobj(fig,'type','uicontrol');
   set(uiControls,'enable','on')
   set(uiControls,'buttondownfcn','')

   ax = ud.help.ax;
   set(ax,'buttondownfcn','')
   lines = findobj(ax,'type','line');
   set(lines,'buttondownfcn','')
   texts = findobj(ax,'type','text');
   set(texts,'buttondownfcn','')

   if nargin > 2 & ~isempty(varargin{3})
       s=sprintf([varargin{2} ':' varargin{3}]);
   elseif nargin > 1
       s=sprintf(varargin{2});
   else
       s=sprintf('help');
   end
   
   if nargin <= 3
       str = feval(ud.help.helpFcn,s,fig);
   else 
       str = feval(ud.help.helpFcn,s,fig,varargin{4});
   end
   
   if strcmp(computer,'MAC2')
      crchar = 13;
   else
      crchar = 10;
   end

   for i=1:size(str,1)
      str{i,2} = char(str{i,2});
      str{i,2} = [str{i,2},crchar*ones(size(str{i,2},1),1)]';
      str{i,2} = str{i,2}(:)';
   end

   helpwin(str,str{1,1},ud.help.titleStr)

   % ASSUMPTION:  ORDER OF FINDOBJ RESULTS IS THE SAME NOW AS
   %  WHEN CALLBACKS / BUTTONDOWNFCNS WERE SAVED
   restoreEnableControls = ud.help.saveEnableControls;
   restoreEnable = ud.help.saveEnable;
   if length(restoreEnableControls)==1
       set(restoreEnableControls,'enable',restoreEnable)
   else
       set(restoreEnableControls,{'enable'},restoreEnable)
   end
   restoreLineButtonDownFcns = ud.help.saveLineButtonDownFcns;
   if length(lines)==1
       set(lines,'buttondownfcn',restoreLineButtonDownFcns);
   else
       set(lines,{'buttondownfcn'},restoreLineButtonDownFcns);
   end
   restoreAxesButtonDownFcns = ud.help.saveAxesButtonDownFcns;
   if length(ax)==1
       set(ax,'buttondownfcn',restoreAxesButtonDownFcns);
   else
       set(ax,{'buttondownfcn'},restoreAxesButtonDownFcns);
   end

   % find all uimenus with no children:
   uiMenus = findobj(fig,'type','uimenu','children',zeros(0,1));
   ind = findcstr(get(uiMenus,{'tag'}),'winmenu');
   uiMenus(ind) = [];
   for i=length(uiMenus):-1:1
      p = get(uiMenus(i),'parent');
      if ishandle(p) & strcmp(get(p,'tag'),'winmenu')
         uiMenus(i) = [];
      end
   end 
   % also restore 'Markers' menu if present
   markersMenu = findobj(fig,'type','uimenu','label','&Markers','tag','markersmenu');
   if ~isempty(markersMenu)
      uiMenus(end+1) = markersMenu;
   end
   restoreUiMenuCallbacks = get(uiMenus,'userdata');
   restoreUiMenuEnable = ud.help.saveUiMenuEnable;
   if length(uiMenus)==1
      restoreUiMenuCallbacks = {restoreUiMenuCallbacks};
   end
   set(uiMenus, {'callback'}, restoreUiMenuCallbacks)
   set(uiMenus,{'enable'},restoreUiMenuEnable)

   ud.pointer = ud.help.savePointer;
   ud.pointer = 0;
   ud.help.saveEnable = [];
   ud.help.saveUiMenuEnable = [];
   ud.help.saveLineButtonDownFcns = [];
   set(fig,'userdata',ud)
   setptr(fig,'arrow')
   
   % Uncheck what's this uimenu:
   um=findobj(fig,'tag','whatsthismenu');
   set(um,'checked','off')
   
case 'tag'
   fig = varargin{2};
   titleStr = varargin{3};
   helpFcn = varargin{4};
   if nargin > 5
       s=sprintf([varargin{5} ':' varargin{6}]);
   elseif nargin > 4
       s=sprintf(varargin{5});
   else
       s=sprintf('help');
   end
   
   str = feval(helpFcn,s,fig);
   
   if strcmp(computer,'MAC2')
      crchar = 13;
   else
      crchar = 10;
   end

   for i=1:size(str,1)
      str{i,2} = char(str{i,2});
      str{i,2} = [str{i,2},crchar*ones(size(str{i,2},1),1)]';
      str{i,2} = str{i,2}(:)';
   end

   helpwin(str,str{1,1},titleStr)
end

%function helpwin(str,str1,titleStr)
%disp('+++++++++++++++++++ HELPWIN +++++++++++++++++++++++')
%disp(titleStr)
%for k=1:size(str,1)
% for l=1:size(str,2)
%  disp(str{k,l})
% end
%end
