function [hhelpmenu, hhelpmenuitems] = render_vqhelpmenu(hfig, position)
%RENDER_VQHELPMENU Render a VQ DESIGN TOOL specific "Help" menu.
% 
%   Inputs:
%     hfig     - Handle to the figure
%     position - Position of new menu.
%
%   Output:
%     hhelpmenu      - Handle to the "Help" menu on the menubar. 
%     hhelpmenuitems - Vector containing handles to all the help menu items.

%    Copyright 1988-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:05:25 $ 

% List menu item strings
strs = {xlate('&Help'),...
        xlate('VQ Design &Tool Help'),...
        xlate('VQ Encoder Block Help'),...
        xlate('VQ Decoder Block Help'),...
        xlate('Signal Processing Blockset &Demos'),...
        xlate('&About Signal Processing Blockset')};

tags = {'help',...
        'vqdtoolhelp',...
        'vqencblockhelp',...
        'vqdecblockhelp',...
        'demos',...
        'about'};

% Separators
sep = {'Off','Off','Off','Off','On','On'};

% CallBacks
cbs = {'',...
        @vqdtoolhelp_cb,...
        @vqencblockhelp_cb,...
        @vqdecblockhelp_cb,...
        @demos_cb,...
        @about_cb};

% Render the Help menu 
hhelpmenus     = addmenu(hfig,position,strs,cbs,tags,sep);
hhelpmenu      = hhelpmenus(1);
hhelpmenuitems = hhelpmenus(2:end);

% --------------------------------------------------------------
function vqdtoolhelp_cb(hco,eventStruct)

helpwin vqdtool;

% --------------------------------------------------------------
function vqencblockhelp_cb(hco,eventStruct)

doc vectorquantizerencoder;

% --------------------------------------------------------------
function vqdecblockhelp_cb(hco,eventStruct)

doc vectorquantizerdecoder;

% --------------------------------------------------------------
function demos_cb(hco,eventStruct)

demo blockset 'signal processing'

%--------------------------------------------------------------
function about_cb(hco,eventStruct)

aboutdspblks

% [EOF]
