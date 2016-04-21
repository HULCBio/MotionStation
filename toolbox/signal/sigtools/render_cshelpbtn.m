function hcshelpbtn = render_cshelpbtn(hFig, varargin)
%RENDER_CSHELPBTN Render the "What's This?" toolbar button.
%   HCSHELPBTN = RENDER_CSHELPBTN(HFIG, TOOLNAME) return the handle to the button.
%   TOOLNAME defines which TOOLNAME_help.m file could be used in determining
%   the documentation mapping.
%
%   See also CSHELPCONTEXTMENU, CSHELPENGINE, CSHELPGENERAL_CB

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:32:40 $

hut = findall(hFig,'Type','uitoolbar');
tags = analysistags;

% Load the MAT-file with the icon
icons = load('filtdes_icons');

% Structure of all local callback functions
if nargin ==2,
    toolname = varargin{1};
    cb = {@cshelpgeneral_cb, toolname};
else
    help_handles = fdatool_help;
    cb = help_handles.HelpWhatsThis_cb;
end

% Render the pushbutton
hcshelpbtn = uipushtool('Cdata',icons.bmp.whatsthis,...
    'Parent',          hut,...
    'ClickedCallback', cb,...
    'Tag',             tags{end},...
    'Separator',       'On',...
    'Tooltipstring',   '"What''s this?"');

% [EOF]
