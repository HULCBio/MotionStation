function cshelpengine(hco, eventStruct, toolname, tag)
%CSHELPENGINE Context sensitive help engine used to launch the help browser.
%   CSHELPENGINE(HCO, EVENTSTRUCT, TOOLNAME, TAG) when called from a callback
%   brings up the TOOLNAME help corresponding to the TAG string.
%
%   Optionally, the context-sensitive help engine allows you to intercept
%   general tags and map them to specific tags in the documentation by 
%   evaluating the local "tag_mapping" function of TOOLNAME_help.m
%   (see fdatool_help.m)
%
%   See also CSHELPCONTEXTMENU, CSHELPGENERAL_CB, RENDER_CSHELPBTN

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:52:46 $

hFig = gcbf;
hco  = gcbo;

% Get tag (of the context menu) if it was not passed in directly:
if nargin<4, tag=get(hco,'tag'); end

% Check for legal tag string:
if ~ischar(tag),
   helpError(hFig,'Invalid context-sensitive help tag.',toolname);
   return
end

% Remove 'WT?' prefix;
if strncmp(tag,'WT?',3),
    tag(1:3) = '';
else
    msg = 'Context-sensitive help Tag string must begin with the "WT?" prefix.';
    helpError(hFig,msg,toolname);
    return
end

% Intercept general tags and map them to specific tags in the doc.
try
    help_handles = feval([lower(toolname) '_help']);
    doclink = feval(help_handles.tag_mapping,hFig,tag);
catch
    doclink = tag;
end
bring_up_help_window(hFig,doclink, toolname);

% --------------------------------------------------------------
function bring_up_help_window(hFig,tag, toolname);
% Attempt to bring up helpview
% Provide appropriate error messages on failure

launchfv(hFig, tag, toolname);

% --------------------------------------------------------------
function helpError(hFig,msg,toolname)
% Generate a modal dialog box to display errors while trying to obtain help

hmsg = errordlg(msg,[toolname ' Help Error'],'modal');
centerfigonfig(hFig, hmsg);

% [EOF]
