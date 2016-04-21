function out = winmenu(in)
%WINMENU Create submenu for "Window" menu item.
%  WINMENU(H) constructs a submenu under the menu specified by H.
%
%  WINMENU(F) looks for the uimenu child of figure F with the Tag
%  'winmenu' and initializes it.
%
%  cb = WINMENU('callback') returns the proper callback string for the
%  menu item under which the submenu is to be constructed (for
%  backwards compatibility).  The callback is always
%  'winmenu(gcbo)'.
%
%  Example:
%
%  fig_handle = figure;
%  uimenu(fig_handle, 'Label', 'Window', ...
%      'Callback', winmenu('callback'), 'Tag', 'winmenu');
%  winmenu(fig_handle);  % Initialize the submenu


%  WINMENU constructs a submenu under the "Window" menu item
%  of the current figure.  The submenu can then be used to
%  change the current figure.  To use WINMENU, the "Window"
%  menu item must have its 'Tag' property set to 'winmenu'.
%
%  WINMENU(FIG) constructs the "Window" submenu for figure
%  FIG.
%
%  WINMENU('callback') returns the callback string to use in
%  the top-level uimenu item.
%
    
%  Steven L. Eddins, 6 June 1994
%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 1.36.4.6 $  $Date: 2004/05/01 14:36:33 $


% We can be called with 0 or 1 input args:
error(nargchk(0, 1, nargin));

if (nargout > 0)
    out = []; % preinitialize out
end

if(nargin == 1)
  if isstr(in)
    %
    % The only legal string arg is 'callback'
    %
    if strcmp(in, 'callback')
      out = 'winmenu(gcbo)';
    elseif strcmp(in,'morewindowsdlg')
      morewindowsdlg;
    elseif strcmp(in,'morewindowscb')
      morewindowscb;
    else
      error(['unrecognized string argument: ''',in,'''']);
    end
    return;
    
  elseif length(in) == 1 & ishandle(in)
    %
    % The only other legal arg is a single figure or uimenu handle:
    %
    t = get(in,'type');
    if(strcmp(t,'uimenu'))
      h = in;
    elseif(strcmp(t,'figure'))
      h = findwinmenu(in);
    else
      error('handle argument must be figure or uimenu handle');
    end
  else
    error('input argument must be a figure or uimenu handle, or ''callback''');
  end
else
  h = findwinmenu(gcf);
end

% By this point, we must have the handle to a uimenu item:
if length(h) ~= 1 | ~ishandle(h) | ~strcmp(get(h,'type'), 'uimenu')
  error('unable to find window menu');
end

% The strategy:
%
% 1) there will be no more than 11 items on the window menu,
% allowing us to use the Mnemonics 0 through 9 for windows, plus an
% additional More Windows... item when necessary.  We will reuse
% menus, and whenever fewer than 10 are required, we will hide the
% ones not currently in use.  Let's minimize creation and deletion
% of uimenus during the posting of this submenu!
%
% 2) The command window will always be listed first, with the
% mnemonic 0.
%
% 3) There will be a separator, and then up to nine figures, using
% mnemonics 1 through the number of figures.  A figure will be
% listed on the menu using its titlebar string, which is a function
% of the Numbertitle property, its handle, and its Name property.
% The listing will be in sorted order by titlebar string.
%
% 4) If there are fewer than 9 figures, the remaining slots will
% list Simulink block diagram windows, using the remaning mnemonics
% through 9.  Simulink block diagram windows will be listed by
% their titlebar contents.  There will be a separator between the
% figures and the simulink items.
%
% 5) If there are any windows not listed due to space constraints,
% there will be one more separator, followed by an item labeled
% 'More windows', with the mnemonic 'M'.

% 1) make sure there are 11 items:
menus = allchild(h);
len = length(menus);
need_more_item = 0;
if len > 11
  delete(menus(12:end));
  menus(12:end) = [];
else
  for i=(len+1):11
    menus(i) = uimenu(h);
  end
end

menus = flipud(menus);
set(menus,'handlevisibility','off','serializable','off',...
    'separator','off','visible','on');
    

% 2) list the command window
if (~isdeployed)
  set(menus(1),'label','&0 MATLAB Command Window',...
  'callback', {@showCommandWindow, gcbf});
end
set(menus(11),'label','&More Windows...','separator','on',...
    'callback','winmenu morewindowsdlg');
more_item = menus(11);

if isdeployed
  menus(11) = [];
else 
 menus([1,11]) = [];
end
len = length(menus);

% 2.5) enumerate the other desktop windows
[desktopOwners, ownerNames] = getDesktopTitles;
num_dtmenus = min(length(desktopOwners), len);

if num_dtmenus < length(desktopOwners)
  need_more_item = 1;
end
if num_dtmenus
  for i = 1:num_dtmenus
    ownerNames{i} = sprintf('&%d %s',i,char(ownerNames{i}));
  end
  set(menus(1:(num_dtmenus)),{'label'},ownerNames(1:num_dtmenus)',...
      'callback','activate(get(gcbo,''userdata''));',...
      {'userdata'},desktopOwners(1:num_dtmenus)');
  if (~isdeployed)  
    set(menus(1),'separator','on');
  end
  menus(1:num_dtmenus) = [];
  len = length(menus);
end

% 3) enumerate the figures
[figs, fignames] = getfigtitles;

num_figmenus = min(length(figs), len);
if num_figmenus < length(figs)
  need_more_item = 1;
end
if num_figmenus
  for i = 1:num_figmenus
    fignames{i} = sprintf('&%d %s',i+num_dtmenus,fignames{i});
    fighandles{i} = figs(i);
  end
  set(menus(1:(num_figmenus)),{'label'},fignames(1:num_figmenus)',...
      'callback','figure(get(gcbo,''userdata''))',...
      {'userdata'},fighandles');
  if (~isdeployed)  
    set(menus(1),'separator','on');
  end
  menus(1:num_figmenus) = [];
  len = length(menus);
end

%********************* Begin Simulink Model Support *********************
% This piece of code is commented out to remove the performance hit of
% possibly loading Simulink. 

% % 4) enumerate the models:
% models = getmodeltitles;
% if len < length(models)
%   need_more_item = 1;
% end
% 
% num_modelmenus = min(length(models), len);
% if num_modelmenus
%   models = sort(models);
%   for i=1:num_modelmenus
%     modelnames{i} = sprintf('&%d %s',i+num_dtmenus+num_figmenus, models{i});
%   end
%  set(menus(1:num_modelmenus),{'label'},modelnames(1:num_modelmenus)',...
%      'callback','open_system(get(gcbo,''userdata''))',...
%      {'userdata'},models(1:num_modelmenus));
%   if (~isdeployed) 
%     set(menus(1),'separator','on');
%   end
%   menus(1:num_modelmenus) = [];
%   len = length(menus);
% end
%********************* End Simulink Model Support *********************

set(menus,'visible','off');
if ~need_more_item
  set(more_item,'visible','off');
end

drawnow
%%% end main winmenu function %%%


function h = findwinmenu(fig)
%
% Look for the specially tagged menu:
% INPUT ARG MUST BE A FIGURE
%
if ~strcmp(get(fig,'type'),'figure')
  error('Assert: findwinmenu requires a figure handle');
end
h = findall(fig,'type','uimenu','tag','winmenu');
%%% end function findwinmenu

function [owners, ownerTitles] = getDesktopTitles

% NOTE: This function uses undocumented java objects whose behavior will
%       change in future releases.  When using this function as an example,
%       use java objects from the java.awt or javax.swing packages to ensure
%       forward compatibility.

owners = {};
ownerTitles = {};
if usejava('desktop')
  import com.mathworks.mwswing.desk.DTWindowRegistry;
  reg = DTWindowRegistry.getInstance;
  owners = reg.getActivators.toArray;
  j = 1;
  for i=1:length(owners)
    if ~isempty(owners(i))
      % Exclude Figures and Simulink diagrams since they are obtained through other paths
      group = owners(i).getGroupName;
      if strcmp(group, 'Figures') | strcmp(group, 'Simulink')
        owners(i) = [];
      else
        ownerTitles{j} = owners(i).getShortTitle;
        j=j+1;
      end
    end
  end
  owners = cell(owners)';
  i = cellfun('isempty', owners);
  i = ~i;
  owners = owners(find(i));
end

%%% end function getDesktopTitles


function [figs, titles] = getfigtitles
%
% returns titles of all passed-in figures in a cell array
%

figs = findobj(allchild(0),'flat','type','figure','visible','on');
titles = {};
for i=1:length(figs)
  name = get(figs(i),'name');
  if ~isempty(name)
	name = strrep(name,char(10),' ');
	name = strrep(name,char(13),' ');
  end
  t = '';
  if strcmp(get(figs(i),'numbertitle'),'on')
    t = sprintf('Figure %.8g',figs(i));
    if ~isempty(name)
      t = [t, ': '];
    end
  end
  
  titles{i} = [t, name];
end

[titles, order] = sort(titles);
figs = figs(order);

%%% end function getfigtitle

%********************* Begin Simulink Model Support *********************
% This piece of code is commented out to remove the performance hit of
% possibly loading Simulink. 

% function out = getmodeltitles
% %
% % return titles of all models:
% %
% 
% out = {};
% 
% % check to see whether simulink is in use in this MATLAB session
% tic
% inuse = license('inuse');
% if ~isempty(inuse) && any(strcmp({inuse.feature},'simulink'))
% 	out = find_system('open','on');
% end
% toc
% 
% % replace newlines and carriage returns in multiline titles with
% % spaces:
% out = strrep(out,char(10),' ');
% out = strrep(out,char(13),' ');
% 
% %%% end function getmodeltitles

%********************* End Simulink Model Support ***********************

function morewindowsdlg
%
% Construct a platform-independent modal dialog containing a
% listbox and an OK and CANCEL button, for browing the list of all
% figures
%
% make the dialog 200 x 300 pixels, to the left of the figure whose
% window menu invoked it, but make sure to keep it on the screen:
figpos = get(gcbf,'position');
figtop = figpos(2) + figpos(4);
dlgw = 200;
dlgh = 300;
dlgl = max(figpos(1) - dlgw - 10, 0);
dlgb = max(figtop - dlgh, 0);

[owners, ownernames]=getDesktopTitles;
for i = 1:length(ownernames)
    ownernames{i} = char(ownernames{i});
end
[figs, fignames] = getfigtitles;
% exclude = find(figs == f);
% figs(exclude) = [];
% fignames(exclude) = [];

n_dts = length(owners);
n_figs = length(figs);
for i=1:n_dts
  ud{i,1}='activate';
  ud{i,2}=owners{i};
end
for i=1:n_figs
  ud{i+n_dts,1} = 'figure';
  ud{i+n_dts,2} = figs(i);
end

%********************* Begin Simulink Model Support *********************
% This piece of code is commented out to remove the performance hit of
% possibly loading Simulink. 

%modelnames = getmodeltitles;
%n_models = length(modelnames);
%for i = 1:n_models
%  ud{i+n_dts+n_figs, 1} = 'open_system';
%  ud{i+n_dts+n_figs, 2} = modelnames{i};
%end

%str =  [ownernames fignames modelnames'];

%********************* End Simulink Model Support ***********************

str =  [ownernames fignames];

f = figure('numbertitle','off',...
    'name','Choose a window',...
    'integerhandle','off',...
    'windowstyle','modal',...
    'resize','off',...
    'color',get(0,'FactoryUicontrolBackgroundColor'),...
    'position',[dlgl, dlgb, dlgw, dlgh]);

l = uicontrol('style','listbox','pos',[10 50 180 240]);

set(l,'string',str','UserData',ud,'callback',...
    'winmenu morewindowscb');

uicontrol('string','OK','pos',[10 10 85 30],...
    'callback','winmenu morewindowscb','userdata',l);
uicontrol('string','Cancel','pos',[105 10 85 30],...
    'callback','delete(gcbf)');
%%% end function morewindowsdlg

function morewindowscb
%
% Select the window, and close the dialog.
%
l = gcbo;
l_type = get(l,'style');

switch l_type
  case 'listbox'
    if ~strcmp(get(gcbf,'selectiontype'),'open')
      return;
    end
  case 'pushbutton'
    l = get(l,'UserData');
  otherwise
    error(sprintf('unexpected object type in morewindowscb: %s',l_type));
end

ud=get(l,'UserData');
val=get(l,'value');

% delete the modal dialog figure BEFORE raising the selected model or
% figure, because on some platforms (PC) some window types (Models)
% will not be raised sucessfully while a modal window is up. -DTP
delete(gcbf);

% now call the raise command stored in userdata for this type of
% window
feval(ud{val,1},ud{val,2});


function showCommandWindow(src, evd, gcbf)
% USEJAVA only checks if MATLAB was started with the
% -nodesktop flag. It doesn't guarantee a correct result if
% the desktop is started from MATLAB after MATLAB is started
% with no desktop.
if usejava('desktop')
    com.mathworks.mde.desk.MLDesktop.getInstance.showCommandWindow
else
    uimenufcn(gcbf,'WindowCommandWindow');
end
