function [hhelpmenu, hhelpmenuitems] = render_sqhelpmenu(hfig, position)
%RENDER_SQHELPMENU Render a SQ DESIGN TOOL specific "Help" menu.
% 
%   Inputs:
%     hfig     - Handle to the figure
%     position - Position of new menu.
%
%   Output:
%     hhelpmenu      - Handle to the "Help" menu on the menubar. 
%     hhelpmenuitems - Vector containing handles to all the help menu items.

%    Copyright 1988-2004 The MathWorks, Inc.
%    $Revision: 1.1.4.5 $  $Date: 2004/04/12 23:05:24 $ 

% List menu item strings
strs = {xlate('&Help'),...
        xlate('SQ Design &Tool Help'),...
        xlate('SQ Encoder Block Help'),...
        xlate('SQ Decoder Block Help'),...
        xlate('Signal Processing Blockset &Demos'),...
        xlate('&About Signal Processing Blockset')};

tags = {'help',...
        'sqdtoolhelp',...
        'sqencblockhelp',...
        'sqdecblockhelp',...
        'demos',...
        'about'};

% Separators
sep = {'Off','Off','Off','Off','On','On'};

% CallBacks
cbs = {'',...
        @sqdtoolhelp_cb,...
        @sqencblockhelp_cb,...
        @sqdecblockhelp_cb,...
        @demos_cb,...
        @about_cb};

% Render the Help menu 
hhelpmenus     = addmenu(hfig,position,strs,cbs,tags,sep);
hhelpmenu      = hhelpmenus(1);
hhelpmenuitems = hhelpmenus(2:end);

% --------------------------------------------------------------
function sqdtoolhelp_cb(hco,eventStruct)

helpwin sqdtool;

% --------------------------------------------------------------
function sqencblockhelp_cb(hco,eventStruct)

doc scalarquantizerencoder;

% --------------------------------------------------------------
function sqdecblockhelp_cb(hco,eventStruct)

doc scalarquantizerdecoder;

% --------------------------------------------------------------
function demos_cb(hco,eventStruct)

demo blockset 'signal processing'

%--------------------------------------------------------------
function about_cb(hco,eventStruct)

aboutdspblks

% [EOF]
