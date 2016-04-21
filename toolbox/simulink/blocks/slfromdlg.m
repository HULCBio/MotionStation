function varargout = slfromdlg(varargin)
% FROM block  Creates block dialog for FROM block.
% 
%   It provides the following functionalities for user:
%   1) specify the TAG name for this FROM block;
%   2) list the source of the GOTO block which feeds this FROM block
%   3) locate selected GOTO block.
%
%   This is an internal Simulink function used to create the dialog
%   for the FROM block.
%
%   See also slgotodlg.
  
%   Jun Wu, 10/12/2001
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2004/04/15 00:32:34 $

hdl = -1;
switch(nargin) 
  
 case 1,
  %------------------------------------------%
  % Simulink is asking us to open the dialog %
  %------------------------------------------%
  blkHdl = varargin{1};
  hdl    = openDialog(blkHdl);
  
 case 2,
  %--------------------------------------------------------------%
  % Simulink is telling us the block changed name or was deleted %
  %--------------------------------------------------------------%
  blkHdl = varargin{2};
  switch lower(varargin{1})
   case 'delete'
    doClose(blkHdl);
   case 'namechange'
    doUpdateName(blkHdl);
   otherwise
    error('Simulink:Dialog', ...
          sprintf(['Invalid command "' varargin{1} ...
                   '" for From block parameter dialog.']));
  end
  
 case 3,
  if strcmp(varargin{1}, 'get')
    blkHdl = varargin{2};
    hdl    = get_param(blkHdl, 'Figure');
    ud     = get(hdl, 'UserData');
    varargout = {};
    switch varargin{3}
     case 0 % GotoTag
      varargout{1} = sl('deblankall', get(ud.gotoTagEdit, 'String'));
    end
    return;
  end
  
 case 4
  if strcmp(varargin{1}, 'set')
    blkHdl = varargin{2};
    hdl    = get_param(blkHdl, 'Figure');
    ud     = get(hdl, 'UserData');
    switch varargin{4}
     case 0 % GotoTag
      set(ud.gotoTagEdit, 'String', sl('deblankall', varargin{3}));
      doGotoTag(ud.gotoTagEdit, []);
    end
    return;
  end
  
 otherwise,
  error(['Invalid number of arguments ', num2str(nargin)]);
end

if nargout
  varargout{1} = hdl;			% output bogus handle
end

% end slfromdlg


% Function: createDialog =======================================================
% Abstract:
%   This function constructs the graphical objects for the dialog.
%
function hdl = createDialog(blkHdl)

% keep the background color consistent for each uicontrol objects
objBGColor = get(0,'defaultuicontrolbackgroundcolor');

%
% create the figure for the block dialog
%
dialogPos = [1 1 400 300];

hdl = figure( ...
    'numbertitle',      'off',...
    'name',             ['Block Parameters: ' get_param(blkHdl, 'name')], ...
    'menubar',          'none', ...
    'visible',          'off', ...
    'HandleVisibility', 'callback', ...
    'IntegerHandle',    'off', ...
    'color',            objBGColor, ...
    'Units',            'pixels', ...
    'Position',         dialogPos, ...
    'Resize',           'on' ...
    );

tmpText = uicontrol(hdl, 'style', 'text', ...
                    'fontunit', 'pixel', ...
		    'visible', 'off', ...
		    'string', 'www');
strExt = get(tmpText, 'extent');
pixelRatio = get(tmpText, 'fontsize')/10.667;
delete(tmpText);
dialogPos(3:4) = dialogPos(3:4)*pixelRatio;
set(hdl, 'Position', dialogPos);

% 'Enter' key will be same as clicking on 'OK' button
set(hdl, 'KeyPressFcn', {@returnKeyOK});
set(hdl, 'DeleteFcn',   {@deleteFcn});

% register block handle and this figure handle in figure handle's UserData
ud.blkHdl = blkHdl;
ud.hdl = hdl;

% create description frame
ud.desc = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'enable',          'inactive', ...
    'backgroundcolor', objBGColor, ...
    'foregroundcolor', [255 251 240]/255);

ud.descTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'From');

descStr = ['Receive signals from the Goto block with the specified tag. '...
           'If the tag is defined as ''scoped'' in the Goto block, '...
           'then a Goto Tag Visibility block must be used to define ' ...
           'the visibility of the tag.  After ''Update Diagram'', ' ...
           'the block icon displays the selected tag name (local tags ' ...
           'are enclosed in brackets, [], and scoped tag names are ' ...
           'enclosed in braces, {}).'];

ud.descText = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'value',               [], ...
    'string',              sprintf(descStr));

% create Parameters frame and the title
ud.param = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'enable',          'inactive',...
    'foregroundcolor', [255 251 240]/255);

ud.paramTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Parameters');

% create "Goto tag" field
ud.gotoTagPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Goto tag: ');

gotoTag = get_param(blkHdl, 'GotoTag');
ud.gotoTagEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'string',              gotoTag, ...
    'callback',            {@doGotoTag});

% "Select tag >>" button
ud.cmenu = uicontextmenu( ...
    'Parent',          hdl, ...
    'Callback',        {@doContextMenu});
ud.browseButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Select tag >>', ...
    'Visible',         'on', ...
    'Uicontextmenu',   ud.cmenu, ...
    'Callback',        {@doBrowse});

% Create a text field to hold the corresponding Goto Block name
ud.gotoSrcPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Goto source: ');

gotoSrc = get_param(blkHdl, 'GotoBlock');
gotoSrcName = gotoSrc.name;
if ~isempty(gotoSrc.name)
  gotoSrcName = strrep(gotoSrc.name, sprintf('\n'), ' ');
end
ud.gotoSrcEdit = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'horizontalalignment', 'left', ...
    'Tooltip',             'Click to locate the block', ...
    'Foregroundcolor',     'Blue', ...
    'Enable',              'inactive', ...
    'string',              gotoSrcName);
if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set(ud.gotoSrcEdit,  'ButtonDownFcn',       {@doFind});
end

% Create the "standard" dialog buttons 
ud.okButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'String',          'OK', ...
    'Callback',        {@doOK});

ud.cancelButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'Backgroundcolor', objBGColor, ...
    'String',          'Cancel', ...
    'Callback',        {@doCancel});

ud.helpButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'Backgroundcolor', objBGColor, ...
    'Enable',          'on', ...
    'String',          'Help', ...
    'Callback',        {@doHelp});

ud.applyButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'Enable',          'off', ...
    'String',          'Apply', ...
    'Callback',        {@doApply});

% store these objects information in dialog handle's userdata
ud.origSize   = [0 0];
ud.hilitedBlk.blkHdl = -1;              % block handle of hilited block
ud.hilitedBlk.origHL = 'none';          % cache its hilited theme
set(hdl, 'UserData', ud);

% setting up the proper size for this dialog
doResize(hdl, []);

% adjust the dialog's position according to block's position
set(hdl, 'Units', 'pixels');
dialogPos = get(hdl,'Position');
bdPos     = get_param(get_param(blkHdl, 'Parent'), 'Location');
blkPos    = get_param(blkHdl, 'Position');
bdPos     = [bdPos(1:2)+blkPos(1:2) bdPos(1:2)+blkPos(1:2)+blkPos(3:4)];

hgPos        = sl('rectconv', bdPos,'hg');
dialogPos(1) = hgPos(1)+(hgPos(3)-dialogPos(3));
dialogPos(2) = hgPos(2)+(hgPos(4)-dialogPos(4));

% make sure the dialog is not off the screen
units = get(0, 'Units');
set(0, 'Units', 'pixel');
screenSize = get(0, 'ScreenSize');
set(0, 'Units', units);
if dialogPos(1)<0
  dialogPos(1) = 1;
elseif dialogPos(1)> screenSize(3)-dialogPos(3) 
  dialogPos(1) = screenSize(3)-dialogPos(3);
end
if dialogPos(2)<0
  dialogPos(2) = 1;
elseif dialogPos(2)> screenSize(4)-dialogPos(4) 
  dialogPos(2) = screenSize(4)-dialogPos(4);
end

ud.origSize=dialogPos(3:4);
set(hdl, ...
    'Position',  dialogPos, ...
    'Units',     'normalized', ...
    'UserData',  ud, ...
    'ResizeFcn', {@doResize});

%
% Update the userdata only if it is a changeable block
% else show a disabled version of the gui.
%
UiControls = [ud.gotoTagPrompt; ud.gotoTagEdit; ud.gotoSrcPrompt; ...
              ud.browseButton; ud.gotoSrcEdit; ud.okButton; ud.applyButton];
if strcmp(get_param(blkHdl, 'LinkStatus'), 'none') && ...
   ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')   
  set_param(blkHdl, 'Figure', hdl);
else
  set(UiControls, 'enable', 'off');
end

% end createDialog


% Function: doApply ============================================================
% Abstract:
%   This function will apply all the current settings appeared on the dialog.
%
function applyNoError = doApply(applyButton, evd)

hdl = get(applyButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
ud.hilitedBlk  = doUnHiliteBlocks(ud.hilitedBlk);
errmsg = '';
lasterr('');

applyNoError = 1;
set_param(ud.blkHdl, 'Figure', -1);
prevTag = get_param(ud.blkHdl, 'GotoTag');
try
  set_param(ud.blkHdl, 'GotoTag', sl('deblankall', get(ud.gotoTagEdit, 'String')));
  % update Goto source edit field after this
  ud = doRefresh(ud);
catch
  applyNoError = 0;
  try
    % recover the parameter
    set_param(ud.blkHdl, 'GotoTag', prevTag);
  catch
  end
  errmsg = [errmsg; {lasterr}];
end
set_param(ud.blkHdl, 'Figure', hdl);

if applyNoError
  % switch applyButton
  toggleApply(applyButton, 'off');
end

set(hdl, 'UserData', ud);
if ~isempty(errmsg)
  errordlg(errmsg, 'Error message: Data Store Block', 'modal');
end

% end doApply


% Function: doBrowse ===========================================================
% Abstract:
%   Callback for Browse button. Will open a modal dialog with the list of
%   abailable GOTO tags in the whole system.
%
function doBrowse(browseButton, evd)

hdl = get(browseButton, 'Parent');
ud  = get(hdl, 'UserData');

doContextMenu(ud.cmenu, []);

% end doBrowse


% Function: doContextMenu ======================================================
% Abstract:
%   Bring up the context menu dialog for Goto tag list.
%
function doContextMenu(cmenu, evd)
  
hdl = get(cmenu, 'Parent');
ud  = get(hdl, 'UserData');

% clean-up the uimenu list first
delete(get(ud.cmenu, 'Children'));

if strcmp(get_param(ud.blkHdl, 'LinkStatus'), 'none') && ...
      ~strcmp(get_param(bdroot(ud.blkHdl),'Lock'), 'on')
  enableState = 'on';
  % find all unique GotoTags that are available in the system and add them in
  % the context menu ud.cmenu
  gotoBlks = find_system(bdroot(ud.blkHdl), 'LookUnderMasks', 'on', ...
                         'FollowLinks', 'on', 'BlockType', 'Goto');
  currentGotoTag = get_param(ud.blkHdl, 'GotoTag');
   
  for i=1:length(gotoBlks)
    gotoTag = get_param(gotoBlks(i), 'GotoTag');
    if isempty(findobj(ud.cmenu, 'Label', ['   ' gotoTag]))
       item = uimenu(ud.cmenu, ...
                   'Label',   ['   ' gotoTag], ...
                     'Enable',    enableState, ...
                     'callback',  {@doSelectTag});
      if strcmp(currentGotoTag, gotoTag)
        set(item, 'Checked', 'on');
      end
    end
  end

  menuChildren = get(ud.cmenu,'children');
  if length(menuChildren) > 1
    [s, idx] = sort(get(menuChildren, 'Label'));
    set(ud.cmenu, 'children', menuChildren(flipud(idx)));
  else
    set(ud.cmenu, 'children', menuChildren);
  end
  
  % Adjust the position so it will always appear on the side of Browse button.
  prevUnit = get(ud.browseButton, 'Units');
  set(ud.browseButton, 'Units', 'pixels');
  browseButtonPos = get(ud.browseButton, 'Position');
  set(ud.cmenu, 'Position', browseButtonPos(1:2)+browseButtonPos(3:4));
  set(ud.cmenu, 'Visible', 'on');
  set(ud.browseButton, 'Units', prevUnit);
end

% end doContextMenu


% Function: doCancel ===========================================================
% Abstract:
%   This function will close the dialog without saving any change on it.
%
function doCancel(cancelButton, evd)

hdl = get(cancelButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
ud.hilitedBlk  = doUnHiliteBlocks(ud.hilitedBlk);

set(hdl, 'Visible', 'off');
set(hdl, 'UserData', ud);

if ~strcmp(get_param(bdroot(ud.blkHdl),'Lock'), 'on')
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  set_param(ud.blkHdl, 'Figure', -1);
  set(ud.gotoTagEdit, 'String', get_param(ud.blkHdl, 'GotoTag'));
  set_param(ud.blkHdl, 'Figure', hdl);
  warning(warningState);
end

% end doCancel


% Function: doClose ============================================================
% Abstract:
%   This function will be called when the FROM block is vanished.
%
function doClose(blkHdl)

if get_param(blkHdl, 'Figure') ~= -1
  hdl = get_param(blkHdl, 'Figure');
  if ~isempty(hdl) && ishandle(hdl)
    ud  = get(hdl, 'UserData');
    
    % un-hilite_system
    ud.hilitedBlk  = doUnHiliteBlocks(ud.hilitedBlk);
    
    if ~strcmp(get_param(bdroot(blkHdl), 'Lock'), 'on')
      delete(hdl);
      set_param(blkHdl, 'Figure', -1);
    end
  end
end
  
% end doClose


% Function: doFind =============================================================
% Abstract:
%   This function will find the listed Goto block by using hilite_system.
%
function doFind(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

if strcmp(get(hdl, 'SelectionType'), 'alt')
  % do nothing for right mouse click.
  return;
end

ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk);

gotoSrc = get(ud.gotoSrcEdit, 'String');
if ~isempty(deblank(gotoSrc))
  try
    % use 'find' scheme in hilite_system
    ud.hilitedBlk.origHL = get_param(gotoSrc, 'HiliteAncestors');
    hilite_system(gotoSrc, 'find');
    ud.hilitedBlk.blkHdl = gotoSrc;
  catch
    msg = ['Unable to find Goto block named: "' gotoSrc '". ' lasterr];
    msgbox(msg, 'Goto Source Locating Message', 'modal');
  end
end

set(hdl, 'UserData', ud);

% end doFind


% Function: doGotoTag ==========================================================
% Abstract:
%   Callback function for Goto tag edit field.
%
function doGotoTag(gotoTag, evd)
  
hdl = get(gotoTag, 'Parent');
ud  = get(hdl, 'UserData');

% refresh goto source field according to new goto tag
if strcmp(get(ud.gotoTagEdit, 'String'), get_param(ud.blkHdl, 'GotoTag'))
  doRefresh(ud);
end

% switch apply button
toggleApply(ud.applyButton);

% end doGotoTag


% Function: doHelp =============================================================
% Abstract:
%   This fucntion will load online documentation for From block.
%
function doHelp(helpButton, evd)

hdl = get(helpButton, 'Parent');
ud  = get(hdl, 'UserData');
slhelp(ud.blkHdl);

% end doHelp


% Function: doOK ===============================================================
% Abstract:
%   This function is the callback function for OK button. It will apply all
%   current selection and close the dialog.
%
function doOK(okButton, evd)

hdl = get(okButton, 'Parent');
ud  = get(hdl, 'UserData');

if doApply(ud.applyButton, evd);
  % un-hilite_system
  ud.hilitedBlk  = doUnHiliteBlocks(ud.hilitedBlk);
  
  set(hdl, 'Visible', 'off');
  set(hdl, 'UserData', ud);
end

% end doOK


% Function: doRefresh ==========================================================
% Abstract:
%   Refresh goto tag and source.
%
function ud = doRefresh(ud)

% refresh goto tag field
set(ud.gotoTagEdit, 'String', get_param(ud.blkHdl, 'GotoTag'));

% refresh goto source field according to new goto tag
gotoSrc = get_param(ud.blkHdl, 'GotoBlock');
gotoSrcName = gotoSrc.name;
if ~isempty(gotoSrc.name)
  gotoSrcName = strrep(gotoSrc.name, sprintf('\n'), ' ');
end
set(ud.gotoSrcEdit, 'String', gotoSrcName);

% end doRefresh


% Function: doResize ===========================================================
% Abstract:
%   This function will set/reset the sizes and positions for each object and
%   the main frame. This is a hand-made HG layout manager.
%   When the size is bigger than default size, extend the listbox's width and
%   height, popup menu and edit field's width, and frame's size; keep rest of
%   items' size unchanged (buttons, etc).
%   When it's smaller than its default size, resize everything.
%
function doResize(hdl, evd)

% retrieve userdata from this figure handle
ud = get(hdl, 'UserData');

set(hdl, 'Units', 'pixels');
figPos = get(hdl, 'Position');
% if the figure size is smaller than its default size, set the figure to be
% 'normalized' resize units
tmpText = uicontrol(hdl, 'style', 'text', 'visible', 'off',...
                    'fontunit', 'pixel', 'string', 'www');
strExt = get(tmpText, 'extent');
pixelRatio = get(tmpText, 'fontsize')/10.667;
delete(tmpText);
if ud.origSize ~= [0 0]
  if figPos(3) < ud.origSize(1) || figPos(4) < 300*pixelRatio
    set(hdl, 'Units', 'normalized');
    return;
  end
end

allHdls = [hdl ud.desc ud.descTitle ud.descText ud.param ud.paramTitle ...
	   ud.gotoTagPrompt ud.gotoTagEdit ud.browseButton ud.gotoSrcPrompt ...
	   ud.gotoSrcEdit ud.okButton ud.cancelButton ...
	   ud.helpButton ud.applyButton];
set(allHdls, 'Units', 'characters');

offset    = 1;
btnWidth  = 12;
btnHeight = 1.75;
txtMove   = .5;

figPos=get(hdl, 'Position');

% start from bottom row to top
posApply     = [figPos(3)-offset-btnWidth offset btnWidth btnHeight];
posHelp      = posApply;
posHelp(1)   = posApply(1)-2*offset-btnWidth; 
posCancel    = posHelp;
posCancel(1) = posHelp(1)-2*offset-btnWidth; 
posOK        = posCancel;
posOK(1)     = posCancel(1)-2*offset-btnWidth; 

% description frame
posDesc      = [offset figPos(4)-8*offset figPos(3)-2*offset 7*offset];
strExt       = get(ud.descTitle, 'extent');
posDescTitle = [3*offset posDesc(2)+posDesc(4)-strExt(4)/2 ...
		strExt(3:4)];
posDescText  = [posDesc(1)+offset posDesc(2)+.2 ...
		posDesc(3)-2*offset posDesc(4)-offset];

% Parameters frame
posParam      = [offset posOK(2)+posOK(4)+offset ...
		 figPos(3)-2*offset ...
		 posDesc(2)-posOK(4)-3*offset];
strExt        = get(ud.paramTitle, 'extent');
posParamTitle = [3*offset posParam(2)+posParam(4)-strExt(4)/2 ...
		 strExt(3:4)];

% goto Tag prompt and edit field
strExt = get(ud.gotoTagPrompt, 'extent');
posGotoTagPrompt = [posParam(1)+offset ...
                    posParam(4)+posParam(2)-txtMove-strExt(4) ...
                    strExt(3:4)];

strExt = get(ud.gotoTagEdit, 'extent');
posGotoTagEdit = [posGotoTagPrompt(1) ...
                  posGotoTagPrompt(2)-btnHeight ...
		  posParam(3)-3*offset btnHeight];
		 
% browse button 
strExt = get(ud.browseButton, 'extent');
posBrowseButton = [posGotoTagEdit(1)+posGotoTagEdit(3)+offset ...
		   posGotoTagEdit(2) strExt(3) btnHeight];
posGotoTagEdit(3)  = posGotoTagEdit(3)-strExt(3);
posBrowseButton(1) = posBrowseButton(1)-strExt(3);

% goto source prompt
strExt = get(ud.gotoSrcPrompt, 'extent');
posGotoSrcPrompt = [posGotoTagEdit(1) posGotoTagEdit(2)-strExt(4)-txtMove ...
                    strExt(3:4)];

% goto source edit field
strExt = get(ud.gotoSrcEdit, 'extent');
posGotoSrcEdit = [posGotoSrcPrompt(1)+posGotoSrcPrompt(3) ...
                  posGotoSrcPrompt(2) ...
                  figPos(3)-5*offset-posGotoSrcPrompt(3) posGotoSrcPrompt(4)];

% set objects' positions
set(ud.desc,          'Position', posDesc);
set(ud.descTitle,     'Position', posDescTitle);
set(ud.descText,      'Position', posDescText); 
set(ud.param,         'Position', posParam);
set(ud.paramTitle,    'Position', posParamTitle);
set(ud.gotoTagPrompt, 'Position', posGotoTagPrompt);
set(ud.gotoTagEdit,   'Position', posGotoTagEdit);
set(ud.browseButton,  'Position', posBrowseButton);
set(ud.gotoSrcPrompt, 'Position', posGotoSrcPrompt);
set(ud.gotoSrcEdit,   'Position', posGotoSrcEdit);
set(ud.okButton,      'Position', posOK);
set(ud.cancelButton,  'Position', posCancel);
set(ud.helpButton,    'Position', posHelp);
set(ud.applyButton,   'Position', posApply);

set(allHdls, 'Units', 'normalized');

% end doResize


% Function: doUpdateName =======================================================
% Abstract:
%   This function will update block dialog's title name according to block's
%   name change.
%
function doUpdateName(blkHdl)

hdl = get_param(blkHdl, 'Figure');

if hdl ~= -1
  ud  = get(hdl, 'UserData');
  set(hdl, 'Name', ['Block Parameters: ' get_param(blkHdl, 'name')]);
  ud.blkHdl = blkHdl;
  set(hdl, 'UserData', ud);
  if strcmp(get_param(blkHdl, 'LinkStatus'), 'none')
    set_param(blkHdl, 'Figure', hdl);
  end
end

% end doUpdateName


% Function: doUnHiliteBlocks ===================================================
% Abstract:
%   Set hilited block to its previous hilite_system theme.
%
function hilitedBlk = doUnHiliteBlocks(hilitedBlk)
  
% un-hilite_system
if hilitedBlk.blkHdl ~= -1
  try
    set_param(hilitedBlk.blkHdl, 'HiliteAncestors', hilitedBlk.origHL);
  catch
    % do nothing is pre-hilited block has already gone
  end
  hilitedBlk.blkHdl = -1;
  hilitedBlk.origHL = 'none';
end
  
% end doUnHiliteBlocks
  
  
% Function doSelectTag =========================================================
% Abstract: 
%   Callback functions for items on GotoTags list menu.
% 
function doSelectTag(item, evd)
  
hdl = get(get(item, 'Parent'), 'Parent');
ud  = get(hdl, 'UserData');

set(ud.gotoTagEdit, 'String', sl('deblankall', get(item, 'Label')));

% refresh goto source field according to new goto tag
if strcmp(get(ud.gotoTagEdit, 'String'), get_param(ud.blkHdl, 'GotoTag'))
  doRefresh(ud);
else
  set(ud.gotoSrcEdit, 'String', '');
end

% toggle Apply button
toggleApply(ud.applyButton);

% end doSelectTag


% Function: openDialog =========================================================
% Abstract:
%   Function to create the block dialog for the selected From block if
%   it doesn't have one, or refresh the associated block dialog and make it
%   visible if it does.
%
function hdl = openDialog(blkHdl)

% Check to see if block has a dialog
updateDataOnly = 0;
hdl = get_param(blkHdl, 'Figure');
if ~isempty(hdl) && ishandle(hdl) && hdl ~= -1
  updateDataOnly = 1;
end

%
% If there is no dialog associated with this block, we have to create one
%
if ~updateDataOnly
  hdl = createDialog(blkHdl);
end

ud = get(hdl, 'UserData');
if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  % Update the goto tag list
  ud = doRefresh(ud);
end
set(hdl, 'UserData', ud);

% Show the dialog
set(hdl, 'visible', 'on');

% end openDialog


% Function: deleteFcn ==========================================================
% Abstract: 
%   Get called when the dialog figure is deleted.
%
function deleteFcn(fig, evd)

ud = get(fig, 'UserData');

doClose(ud.blkHdl);

% end deleteFcn


% Function: returnKeyOK ========================================================
% Abstract:
%   This function will be called when user use keyboard to enter command. Now
%   it only does one thing: when it's from Enter key, call doOK function.
%
function returnKeyOK(fig, evd)

ud = get(fig, 'UserData');

if ~isempty(get(fig, 'CurrentChar')) 	% unix keyboard has an empty key
  if (abs(get(fig, 'CurrentChar')) == 13)
    if strcmp(get(ud.okButton, 'Enable'), 'on')
      doOK(ud.okButton, []);
    end
  end
end

% end returnKeyOK


% Function: toggleApply ========================================================
% Abstract:
%   This function toggles the Apply button between ENABLE ON/OFF.
%
function toggleApply(varargin)

if nargin == 1
  set(varargin{1}, 'Enable', 'on');
elseif nargin == 2
  set(varargin{1}, 'Enable', varargin{2});
end
  
% end toggleApply


% end validate


% [EOF]
