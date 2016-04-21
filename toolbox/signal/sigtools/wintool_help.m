function y = wintool_help
%WINTOOL_HELP Help system functions for WinTool GUI.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:52:52 $

% Return structure of public function handles:
y.toolhelp    = @toolhelp_cb;
% y.tag_mapping = @tag_mapping;

% General Context Sensitive Help (CSH) system rules:
%  - context menus that launch the "What's This?" item have their
%    tag set to 'WT?...', where the '...' is the "keyword" for the
%    help lookup system.

% --------------------------------------------------------------
% function tag = tag_mapping(hFig,tag);
% % Intercept general tags to differentiate as appropriate, if 
% % necessary, otherwise, return the input tag string.
% 
% Not used.

% --------------------------------------------------------------
function toolhelp_cb(hco,eventStruct, hFig)
% toolhelp_cb Overview of the tool (reference-page help).

tag = 'wintool_overview';
launchfv(hFig, tag, 'WinTool');

% [EOF]
