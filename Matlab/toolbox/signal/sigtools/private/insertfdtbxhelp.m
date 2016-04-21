function h = insertfdtbxhelp(hFDA,indx)
%INSERTFDTBXHELP Insert Filter Design Toolbox help
%   INSERTFDTBXHELP(HFDA, INDX) creates three help menu items under
%   the Help menu on a figure specified by HFDA at the positions 
%   defined in INDX and returns handles to these menus.
%   
%   Inputs:
%     HFDA - Handle to the figure
%     INDX - Vector of positions for the menu items.
%
%   Output:
%     H - Handles to the help menu items.

%   Author(s): J. Schickler, P. Costa
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:32:37 $ 

% Get FDATool's handles and flags
hndls = gethandles(hFDA);

% Get the position of the "Help" menu
h_helpmenu = findall(hndls.menus.main,'Type','uimenu','tag','help');

pos = get(h_helpmenu,'Position');

% Add 3 additional menu items to the help pulldown menu
h(1) = addmenu(hFDA,[pos indx(1)],'Filter Design Toolbox Help',@fdproducthelp_cb,'fdhelp');
h(2) = addmenu(hFDA,[pos indx(2)],'Filter Design Demos',@fddemos_cb,'fddemos');
h(3) = addmenu(hFDA,[pos indx(3)],'About Filter Design Toolbox',@fdabout_cb,'fdabout');

% --------------------------------------------------------------
function fdproducthelp_cb(hcbo,eventStruct)
% Opens the Help window with the online doc Roadmap
% page (a.k.a. "product page") displayed.

doc filterdesign/

% --------------------------------------------------------------
function fddemos_cb(hco,eventStruct)
% Starts the Demo window, with the appropriate product's
% demo highlighted in the Demo window contents pane.

demo toolbox filter

% --------------------------------------------------------------
function fdabout_cb(hco,eventStruct)
% Displays version number of product, and copyright.

aboutfilterdesigntbx;

% [EOF]

