function varargout = wfighelp(option,varargin)
%WFIGHELP Wavelet Toolbox Utilities for Help system functions and menus
%   VARARGOUT = WFIGHELP(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Dec-2000.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $ $Date: 2004/03/15 22:42:47 $

% Flags used in next version to update the Toolbox.
%--------------------------------------------------
AddItemflag = 1;

switch option
	case 'set'
        hdl_HelpMenu = varargin{1};
        win_type = varargin{2};
		switch win_type
		  case {'ExtFig_Demos'}
            WhatIsflag = 0; Demosflag = 0;
              
          otherwise
            WhatIsflag = 1; Demosflag = 1;
        end       
		setMenu(hdl_HelpMenu,WhatIsflag,Demosflag);
		
	case 'addHelpTool'
        fig  = varargin{1};
		label   = varargin{2};
		idxHelp = varargin{3};
		ud.idxHelp = idxHelp;
		m_help = wfigmngr('getmenus',fig,'help');
		uimenu(m_help, ...
			'Label',label, ...
			'Position',1,  ...
			'Callback',@cb_Help_Tool, ...
			'Userdata',ud ...
			);
		
	case 'addHelpItem'
		if ~AddItemflag  , return; end;		
        fig  = varargin{1};
		label   = varargin{2};
		idxHelp = varargin{3};
		ud.idxHelp = idxHelp;
		m_help = wfigmngr('getmenus',fig,'help');
		m_child = findall(m_help,'type','uimenu','Parent',m_help);
		m_item  = findobj(m_child,'Tag','Item_Help');
		if isempty(m_item)
			m_wtbx  = findobj(m_child,'Tag','WTBX_Help');
			m_wthis = findobj(m_child,'Tag','WhatThis_Help');
			if ~isempty(m_wthis)
				pos = get(m_wthis,'Position')+1;
			else
				pos = get(m_wtbx,'Position')+1;			
			end
			sep = 'On';
		else
			pos = get(m_item,'Position');
			if iscell(pos) , pos = cat(1,pos{:}); end
			pos = max(pos)+1;
			sep = 'Off';			
		end
		uimenu(m_help,...
			'Label',label,'Position',pos, ...
			'Separator',sep,'Tag','Item_Help', ...
			'Callback',@cb_Help_Tool,'Userdata',ud);

	case 'add_ContextMenu'
		add_ContextMenu(varargin{:});
end


%=======================================================================%
% This Internal function is built the "uiContextMenus" associated to
% several handle grahics in the Wavelet Toolbox GUI. 
% ------------------------------------------------------------------
% Here is where all the handle-to-help relationships are constructed
% ==================================================================
% Each relationship is set up as follows:
%
%      add_ContextMenu(hFig,[vector_of_UI_handles],tagString);
%
% where tagStr corresponds to the link used in the doc map file.
% ------------------------------------------------------------------
function add_ContextMenu(hFig,hItem,tagStr)
% Add a "What's This?" context menu.

hc = uicontextmenu('parent',hFig);
uimenu('Label','What''s This?',...
	'Callback',@HelpGeneral,...
	'Parent',hc,...
	'Tag',['WT?' tagStr]);
hItem = hItem(ishandle(hItem));
if ~isempty(hItem) , set(hItem,'uicontextmenu',hc); end
% ------------------------------------------------------------------
%=======================================================================%


%=======================================================================%
%---------------------------------------------------------------------%
function setMenu(h,WhatIsflag,Demosflag)

sub = findall(h,'type','uimenu','Parent',h);
delete(sub); sub = [];

idx = 1;
sub(idx) = uimenu(h, ...
	'Label', 'Wavelet &Toolbox Help', ...
	'Position',idx, ...
	'Tag','WTBX_Help', ...
	'CallBack',@cb_Help_Product ...
	);

if WhatIsflag
	idx = idx+1;
	sub(idx)= uimenu(h, ...
		'Label', '&What''s This?', ...
		'Position',idx, ...		
		'Separator','On', ...
	    'Tag','WhatThis_Help', ...
		'CallBack',@cb_HelpWhatsThis ...
		);
end
if Demosflag
	idx = idx+1;
	sub(idx)= uimenu(h, ...
		'Label', '&Demos', ...
		'Position',idx, ...		
		'Separator','On', ...
		'CallBack',@cb_Help_Demos ...
		);
end
idx = idx+1;
sub(idx)= uimenu(h, ...
	'Label', '&About Wavelet Toolbox ...', ...
	'Position',idx, ...		
	'Separator','On', ...
	'CallBack',@cb_Help_About ...
	);
%---------------------------------------------------------------------%
function cb_Help_Tool(hco,eventStruct)

ud = get(hco,'Userdata');
helpItem = ud.idxHelp;
bring_up_help_window(gcbf, helpItem);

%---------------------------------------------------------------------%
function cb_Help_Product(hco,eventStruct)

doc wavelet;  % Or helpview([docroot '\toolbox\wavelet'])
%---------------------------------------------------------------------%
function cb_HelpWhatsThis(hco,eventStruct)
% HelpWhatsThis_cb Get "What's This?" help
%   This mimics the context-menu help selection, but allows
%   cursor-selection of the help topic

hFig = gcbf;
cshelp(hFig);
set(handle(hFig),'cshelpmode','on');
set(hFig,'HelpFcn',@figHelpFcn);
%---------------------------------------------------------------------%
% --------------------------------------------------------------
% General Context Sensitive Help (CSH) system rules:
%  - context menus that launch the "What's This?" item have their
%    tag set to 'WT?...', where the '...' is the "keyword" for the
%    help lookup system.
% --------------------------------------------------------------
function figHelpFcn(hco,eventStruct)
% figHelpFcn Figure Help function called from either
% the menu-based "What's This?" function, or the toolbar icon.

hFig  = gcbf;
hOver = gco;  % handle to object under pointer

% Dispatch to context help.
hc = get(hOver,'uicontextmenu');
hm = get(hc,'children');  % menu(s) pointed to by context menu

% Multiple entries (children) of context-menu may be present
% Tag is a string, but we may get a cell-array of strings if
% multiple context menus are present:
% Find 'What's This?' help entry
tag = get(hm,'tag');
helpIdx = find(strncmp(tag,'WT?',3));
if ~isempty(helpIdx),
    % in case there were accidentally multiple 'WT?' entries,
    % take the first (and hopefully, the only) index.
    if iscell(tag),
	    tag = tag{helpIdx(1)};
    end
	HelpGeneral([],[],tag);
end

set(handle(hFig),'cshelpmode','off');
%---------------------------------------------------------------------%
function cb_Help_Demos(hco,eventStruct)

demo toolbox wavelet
%---------------------------------------------------------------------%
function cb_Help_About(hco,eventStruct)

tlbx = ver('wavelet');
s1 = sprintf('%s version %s', tlbx.Name, tlbx.Version);
s2 = sprintf('Copyright 1995-%s The MathWorks, Inc.', datestr(tlbx.Date, 10));
str_vers = strvcat(s1,s2);
CreateStruct.WindowStyle = 'replace';
CreateStruct.Interpreter = 'tex';
Title    = 'Wavelet Toolbox';
NB       = 64;
IconData = ([1:NB]'*[1:NB])/NB;
IconCMap = jet(NB);
try
  load('wtbxicon.mat')
  IconData = IconData+11*X;
end
msgbox(str_vers,Title,'custom',IconData,IconCMap,CreateStruct);
%---------------------------------------------------------------------%
function HelpGeneral(hco,eventStruct,tag)
% HelpGeneral Bring up the help corresponding to the tag string.

hFig = gcbf;
hco  = gcbo;
if nargin<3, tag = get(hco,'tag'); end

% Check for legal tag string
if ~ischar(tag),
   helpError(hFig,'Invalid context-sensitive help tag.');
   return
end

% Remove 'WT?' prefix;
if strncmp(tag,'WT?',3),
    tag(1:3) = '';
else
    msg = 'Context-sensitive help Tag string must begin with the "WT?" prefix.';
    helpError(hFig,msg);
    return
end

% Intercept general tags and map them to specific tags in the doc.
doclink = tag_mapping(hFig,tag);
bring_up_help_window(hFig,doclink);
%---------------------------------------------------------------------%
function tag = tag_mapping(hFig,tag);
% Intercept general tags to differentiate as appropriate, if 
% necessary, otherwise, return the input tag string.

switch tag
	case 'dummy'   % tag = FONCTION(hFig,tag);
end
%---------------------------------------------------------------------%
function bring_up_help_window(hFig,tag);
% Attempt to bring up helpview
% Provide appropriate error messages on failure

try, callHelpViewer(tag);
    
catch,
    % Help failed
    % Do some basic debugging of the help system:
    msg = {'';
        'Failed to find on-line help entry:';
        ['   "' tag '"'];
        ''};
    
    if isempty(docroot),
        msg = [msg; ...
			{'The "docroot" command is used to identify the on-line documentation';
            'path, and it has returned an empty string.  This usually indicates';
            'that you have not installed on-line help, or you have not properly';
            'set up the MATLAB Preferences.';
            ''}];
    else
        msg = [msg; ...
			{'The "docroot" command is used to identify the on-line documentation';
            'path, and it has returned a non-empty string.  This generally indicates';
            'that you have installed on-line help, but the specified directory path';
            'may be incorrect.';
            ''}];
    end

    msg = [msg;
		{'To modify your preference settings for the documentation path, go';
		'to the File menu in the Command Window, and choose "Preferences".';
		'Select "Help Browser", then check the "Documentation Location"';
		'directory path to ensure it points the location of your on-line';
		'help.'}];

    % Produce the error message:
    helpError(hFig,msg);
end
%---------------------------------------------------------------------%
function helpError(hFig,msg)
% Generate a modal dialog box to display errors while trying to 
% obtain help

h = errordlg(msg,'Wavelet Toolbox Help Error','modal');
%---------------------------------------------------------------------%
function callHelpViewer(helpItem)

helpview(fullfile(docroot,'toolbox','wavelet','wavelet.map'),helpItem);
%---------------------------------------------------------------------%
%=======================================================================%
