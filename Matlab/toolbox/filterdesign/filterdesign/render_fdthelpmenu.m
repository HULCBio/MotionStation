function [hhelpmenu, hhelpmenuitems] = render_fdthelpmenu(hfig, position)
%RENDER_FDTHELPMENU Render a Filter Design Toolbox specific "Help" menu and sub-menus.
% 
%   Inputs:
%     hfig     - Handle to the figure.
%     position - Position of new menu.
%
%   Outputs:
%     hhelpmenu      - Handle to the "Help" menu on the menubar. 
%     hhelpmenuitems - Vector containing handles to all the help menu items.

%    Author(s): P. Pacheco
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/13 23:10:53 $ 

% List menu item strings
strs = {'&Help',...
        'Filter Design &Toolbox Help',...
        'Filter Design &Demos',...
        '&About Filter Design Toolbox'};

tags = {'help',...
        'producthelp',...
        'demos',...
        'about'};

% Separators
sep = {'Off','Off','On','On'};

% CallBacks
cbs = {'',...
        @producthelp_cb,...
        @demos_cb,...
        @about_cb};

% Render the Help menu 
hhelpmenus     = addmenu(hfig,position,strs,cbs,tags,sep);
hhelpmenu      = hhelpmenus(1);
hhelpmenuitems = hhelpmenus(2:end);

% --------------------------------------------------------------
function producthelp_cb(hco,eventStruct)
% producthelp_cb Opens the Help window with the online doc Roadmap
%                page (a.k.a. "product page") displayed.

doc filterdesign/

% --------------------------------------------------------------
function demos_cb(hco,eventStruct)
% demos_cb Starts Demo window, with the appropriate product's
%                demo highlighted in the Demo window contents pane.

demo toolbox filter

%--------------------------------------------------------------
function about_cb(hco,eventStruct)
% about_cb Displays version number of product, and copyright.

aboutfilterdesigntbx;

% [EOF]
