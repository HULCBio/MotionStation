function hnewmenu = addmenu(hFig,varargin)
%ADDMENU Add a menu to figure.
%   ADDMENU(HFIG,POS,STRING) creates a menu, named STRING, at position POS
%   on the menu bar at the top of a figure and returns a handle to it.  
%
%   ADDMENU(H,POS,STRING,CALLBACKS,TAGS,SEPARATORS,ACCELERATORS) creates
%   the menu and sets it properties. 
%
%   To add both a top-level menu and several submenus, STRING must be a cell 
%   array.  ADDMENU will use the first element of STRING as the top-level 
%   menu name and use the first element of the corresponding inputs (MENUCB, TAG, 
%   SEPFLAG, and ACCEL) as the properties for that menu.  See example #2.  To add 
%   submenus (menus parented by menus), POS must be a vector. ADDMENU will use 
%   the element(s) of POS to find the parent menu to which STRING will be added, 
%   see example #3.  
%
%   Inputs:
%     hFig    - Handle to a figure.
%     pos     - Scalar or vector representing the position of new menu.
%     string  - String or cell array containing the menu labels.
%     menucb  - String or cell array containing the menu callbacks. 
%     tag     - (Optional) String or cell array containing the menu tag.
%     sepflag - (Optional) String or cell array indicating whether or not 
%               to include a separator before the menu item. 'Off' means do not
%               include a separator whereas a 'On' means include it. 
%               If omitted, sepflag defaults to 'Off'.
%     accel   - (Optional) String or cell array specifying the keyboard equivalent 
%               for the menu item.
%
%   Output:
%     hnewmenu - Handle or vector of handles to the new menu(s).
%
%   EXAMPLES:
%   % #1 Add a "Custom" menu to the menubar (top-level)
%   hndl = addmenu(fig,6,'Custom');
%
%   % #2 Add both top-level and submenu.
%   strs  = {'Tool&s','My Tool','Another Tool'};
%   cbs   = {'','disp(''Launch tool'');',''};
%   tags  = {'tools','mytool','anothertool'}; 
%   sep   = {'Off','Off','On'};
%   accel = {'','A',''};
%   hndl  = addmenu(fig,6,strs,cbs,tags,sep,accel);
%
%   % #3 Add a submenu "My Export" (6) to the "File"(1) menu
%   hndl = addmenu(fig,[1 6],'My Export','disp(''Launch my export tool'');',...
%                    'myexport','On','A');

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 23:52:34 $ 

% Parse inputs
[pos,strs,cbs,tags,sep,accel] = parse_inputs(varargin{:});

% Adding both top-level and submenu(s)
if length(pos) == 1 & iscell(strs),
    hnewmenu = render_topNsubmenus(hFig,strs,tags,cbs,sep,accel,pos);
    
% Adding a submenu 
elseif length(pos) > 1,
    
    % Get the handles to the top-level menus
    hFigMenus = findChildMenus(hFig);
    
    if length(pos) == 2,
        % Adding a submenu to a top-level menu
        hparent = hFigMenus(pos(1));
    else
        % Adding a submenu to another menu - get the submenu parent
        hparent = getParent(hFigMenus, pos);
    end
    hnewmenu = createCellNrenderMenu(hparent,strs,tags,cbs,sep,accel,pos);
    
else
    % Adding a top-level menu.
    hparent = hFig;
    hnewmenu = createCellNrenderMenu(hparent,strs,tags,cbs,sep,accel,pos);
end


%----------------------------------------------------------------------
function [pos,strs,cbs,tags,sep,accel] = parse_inputs(pos,strs,varargin)
%PARSE_INPUTS Parse the inputs to ADDMENU
%
%   Outputs:
%      pos   - Scalar or vector
%      strs  - String or cell array
%      cbs   - Callbacks 
%      tags  - Tags 
%      sep   - Separators 
%      accel - Accelerators 

% Defaults (of the right size) for optional input parameters
if iscell(strs),
    cellsz   = cell(size(strs));
    defaults = {cellsz,cellsz,cellsz,cellsz};
    for n = 1:length(defaults),
        if n == 3,
            s = 'Off'; % Separator flag default 
        else
            s = '';    % All other defaults
        end
        [defaults{n}{:}]   = deal(s);    
    end
else
    defaults = {...
            '',...    % Callbacks
            '',...    % Tags
            'Off',... % Separator flag
            ''};      % Acclerator
end

% Creates defaults only when not specified in varargin
[cbs, tags, sep, accel] = deal(varargin{:},defaults{length(varargin)+1:end});


%----------------------------------------------------------------------
function hnewmenu = render_topNsubmenus(hFig,strs,tags,cbs,sep,accel,pos)
%RENDER_TOPNSUBMENUS Render both a top-level and submenu(s).

% New top-level menu
hparent = hFig;
tlstr = strs(1);
tltag = tags(1);
tlcb  = cbs(1);
tlsep  = sep(1);
tlaccel = accel(1);
hnewtlmenu = render_newmenu(hparent,tlstr,tltag,tlcb,tlsep,tlaccel,pos);

% New submenus
hparent = hnewtlmenu;
strs = strs(2:end);
tags = tags(2:end);
cbs  = cbs(2:end);
sep  = sep(2:end);
accel = accel(2:end);
hnewsubmenus = render_newmenu(hparent,strs,tags,cbs,sep,accel);

% Return handles to all new menus
hnewmenu = [hnewtlmenu hnewsubmenus];


%----------------------------------------------------------------------
function hMenus = findChildMenus(hparent)
%FINDCHILDMENUS Find handles to children of menus.

hMenus = findall(hparent,'Type','uimenu','Parent',hparent);
hMenus = flipud(hMenus);


%----------------------------------------------------------------------
function hparent = getParent(hFigMenus,menupath)
%GETPARENT Get the handles to parent menus.

% Get the handle to the top-level menu (e.g., File, Edit)
hmenu = hFigMenus(menupath(1));

% Adding a submenu (e.g., Open, Close)
hchild =  findChildMenus(hmenu);

% Adding cascaded menus (e.g., Tools, Camera Motion)
if length(menupath) == 3,
    hparent = hchild(menupath(2));
elseif length(menupath) == 4,
    hsecondparent = findChildMenus(hchild(menupath(2)));
    hparent = hsecondparent(menupath(3));
end


%----------------------------------------------------------------------
function hnewmenu = createCellNrenderMenu(hparent,strs,cbs,tags,sep,accel,pos)
%CREATECELLNRENDERMENU Create a cell array and render the new menu.  
%
%   If needed, create a cell array of parameters so that all syntaxes can 
%   share the render_newmenu local function.
if ~iscell(strs),
    strs  = {strs};
    cbs   = {cbs};
    tags  = {tags};
    sep   = {sep};
    accel = {accel};
end
hnewmenu = render_newmenu(hparent,strs,cbs,tags,sep,accel,pos);


%----------------------------------------------------------------------
function hnewmenu = render_newmenu(hparent,strs,tags,cbs,sep,accel,pos)
%RENDER_NEWMENU Render the new menu item.

count = 0;

for n = 1:length(strs),
    
    % Get the position
    if nargin < 7, 
        position = n; % Used when rendering top-level and submenus items.
    else
       [position, count] = getPosition(pos,count);
    end
    
    % Render the menu
    hnewmenu(n) = uimenu(hparent,'Label',strs{n},...
        'Tag',tags{n}, ...
        'Callback',cbs{n},...
        'Separator',sep{n},...
        'Accelerator',accel{n},...
        'Position',position);
end


%----------------------------------------------------------------------
function [position, count] = getPosition(pos, count)
% Get the uimenu position for the cases when adding a
% single menu item or a group of menu items (without a top-level
% menu).

if count == 0,
    position = pos(end); % Adding a single menu item
else                     
    % Starting position for adding group of menu items. 
    position = pos(end) + count;
end

% Increment the counter
count = count + 1;

% [EOF]
