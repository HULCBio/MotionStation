function mlscript_ui(varargin)
%MLSCRIPT_UI - Internal Simulink function for MATLAB scripting block
% 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.4 $

  switch(nargin) 
   case 2,
    %--------------------------------------------------------------%
    % Simulink is telling us the block changed name or was deleted %
    %--------------------------------------------------------------%
    blkHdl = varargin{2};
    switch varargin{1}
     case 'delete'
      deleteDialog(blkHdl);
     case 'nameChange'
      updateDialogName(blkHdl);
     case 'open'
      openDialog(blkHdl);
     otherwise
      if isstr(varargin{2})
	error(['Invalid Simulink action: "', varargin{2},'"']);
      else
	error(['Invalid Simulink action: ', num2str(varargin{2})]);
      end
    end
   
   otherwise,
    error(['Invalid number of arguments ', num2str(nargin)]);
  end
    
%endfunction skeleton



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
  dialogPos = [1 1 350 400];
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

  % 'Enter' key will be same as clicking on 'OK' button
  set(hdl, 'KeyPressFcn', {@returnKeyOK});

  % register block handle and this figure handle in figure handle's UserData
  ud.blkHdl = blkHdl;
  ud.hdl    = hdl;

  % create description frame
  ud.desc = uicontrol(...
      hdl, ...
      'style',           'frame', ...
      'backgroundcolor', objBGColor);
  
  ud.descTitle = uicontrol(...
      hdl, ...
      'style',           'text', ...
      'backgroundcolor', objBGColor, ...
      'string',          [get_param(blkHdl,'blocktype')]);

  descStr = sprintf(['MATLAB scripting block prototype.\n' ...
		     'Computes y = f(u).']);
  
  ud.descText = uicontrol(...
      hdl, ...
      'style',               'text', ...
      'backgroundcolor',     objBGColor, ...
      'max',                 2, ...
      'min',                 0, ...
      'horizontalalignment', 'left', ...
      'value',               [], ...
      'string',              descStr);
  
  % create Parameters frame and the tile
  ud.param = uicontrol(...
      hdl, ...
      'style',           'frame', ...
      'backgroundcolor', objBGColor);
  
  ud.paramTitle = uicontrol(...
      hdl, ...
      'style',           'text', ...
      'backgroundcolor', objBGColor, ...
      'string',          'Parameters');

  % create UI items starting from here

  ud.outputScirpt = uicontrol(...
      hdl, ...
      'style',           'text', ...
      'backgroundcolor', objBGColor, ...
      'horizontalalignment', 'left', ...
      'string',          'Output script: ');

  % create edit field
  ud.outputScriptEdit = uicontrol(...
      hdl, ...
      'style',               'edit', ...
      'backgroundcolor',     [1 1 1], ...
      'horizontalalignment', 'left', ...
      'Max',                 2, ...
      'string',              [get_param(blkHdl,'OutputScript')], ...
      'callback',            {@doOutputScript});
  
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
  set(hdl, 'UserData', ud);
  
  % setting up the proper size for this dialog
  doResize(hdl, []);
  
  % adjust the dialog's position according to block's position
  set(hdl, 'Units', 'pixels');
  dialogPos = get(hdl,'Position');
  bdPos     = get_param(bdroot(blkHdl),'Location');

  hgPos        = rectconv(bdPos,'hg');
  dialogPos(1) = hgPos(1)+(hgPos(3)-dialogPos(3));
  dialogPos(2) = hgPos(2)+(hgPos(4)-dialogPos(4));

  ud.origSize=dialogPos(3:4);
  set(hdl, ...
      'Position',  dialogPos, ...
      'Units',     'normalized', ...
      'UserData',  ud, ...
      'ResizeFcn', {@doResize});
  
  setappdata(0, 'HGSkeletonDialog', ud);
  
%end createDialog


% Function: doApply ============================================================
% Abstract:
%   This function will apply all the current settings appeared on the dialog.
%
function doApply(applyButton, evd)

  hdl = get(applyButton, 'Parent');
  ud  = get(hdl, 'UserData');

  % switch applyButton
  toggleApply(applyButton, 'off');
  set_param(ud.blkHdl,'OutputScript',get(ud.outputScriptEdit, 'String'));
  
%endfunction doApply


% Function: doCancel ===========================================================
% Abstract:
%   This function will close the dialog without saving any change on it.
%
function doCancel(cancelButton, evd)

  hdl = get(cancelButton, 'Parent');
  ud  = get(hdl, 'UserData');

  set(hdl, 'Visible', 'off');
  set(hdl, 'UserData', ud);

%endfunction doCancel


% Function: doHelp =============================================================
% Abstract:
%   This fucntion will load online documentation for the MATLAB Scripting block.
%
function doHelp(helpButton, evd)

  disp('debug info: doc loaded');

%endfunction doHelp



% Function: doOutputScript =====================================================
% Abstract:
%   Called when 'Output Script' input field is modified.
%
function doOutputScript(outputScriptEdit, evd)

  hdl = get(outputScriptEdit, 'Parent');
  ud  = get(hdl, 'UserData');
  
  % switch applyButton
  toggleApply(ud.applyButton);

  %input = get(outputScriptEdit, 'String');

%endfunction doOutputScript


% Function: doOK ===============================================================
% Abstract:
%   This function is the callback function for OK button. It will apply all
%   current selection and close the dialog.
%
function doOK(okButton, evd)

  hdl = get(okButton, 'Parent');
  ud  = get(hdl, 'UserData');
  
  doApply(ud.applyButton, evd);

  doCancel(ud.cancelButton, []);

%end doOK



% Function: doResize ===========================================================
% Abstract:
%   This function will set/reset the sizes and positions for each object and
%   the main frame. This is a hand-made HG layout manager.
%   When the size is bigger than default size, extend the edit field's width and
%   height and frame's size; keep rest of  items' size unchanged (buttons, etc).
%   When it's smaller than its default size, resize everything.
%
function doResize(hdl, evd)

% retrieve userdata from this figure handle
  ud = get(hdl, 'UserData');

  set(hdl, 'Units', 'pixels');
  figPos = get(hdl, 'Position');
  % if the figure size is smaller than its default size, set the figure to be
  % 'normalized' resize units
  if figPos(3) < ud.origSize(1) | figPos(4) < 250
    set(hdl, 'Units', 'normalized');
    return;
  end

  allHdls = [hdl ud.desc ud.descTitle ud.descText ud.param ud.paramTitle ...
	     ud.outputScirpt ud.outputScriptEdit ...
	     ud.okButton ud.cancelButton ...
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
  posHelp(1)   = [posApply(1)-2*offset-btnWidth]; 
  posCancel    = posHelp;
  posCancel(1) = [posHelp(1)-2*offset-btnWidth]; 
  posOK        = posCancel;
  posOK(1)     = [posCancel(1)-2*offset-btnWidth]; 

  % description frame
  posDesc      = [offset figPos(4)-6*offset ...
		  figPos(3)-2*offset 5*offset];
  strExt       = get(ud.descTitle, 'extent');
  posDescTitle = [3*offset posDesc(2)+posDesc(4)-1.5*txtMove ...
		  strExt(3:4)];
  posDescText  = [posDesc(1)+txtMove posDesc(2)+txtMove ...
		  posDesc(3)-offset posDesc(4)-offset];

  % Parameters frame
  posParam      = [offset posOK(2)+posOK(4)+offset ...
		   figPos(3)-2*offset ...
		   posDesc(2)-posOK(4)-3*offset];
  strExt        = get(ud.paramTitle, 'extent');
  posParamTitle = [3*offset posParam(2)+posParam(4)-1.5*txtMove ...
		   strExt(3:4)];

  % input prompt
  strExt = get(ud.outputScirpt, 'extent');
  posOutputScript = [2*offset ...
		    posParam(4)+posParam(2)-offset-strExt(4) ...
		    figPos(3)-4*offset strExt(4)];

  % Edit field
  posOutputScriptEdit = [posOutputScript(1) ...
		    posParam(2)+txtMove ...
		    posParam(3)-2*offset ...
		    posParam(4)-posOutputScript(4)-1.5*offset];

  % set objects' positions
  set(ud.desc,            'Position', posDesc);
  set(ud.descTitle,       'Position', posDescTitle);
  set(ud.descText,        'Position', posDescText); 
  set(ud.param,           'Position', posParam);
  set(ud.paramTitle,      'Position', posParamTitle);
  set(ud.outputScirpt,    'Position', posOutputScript);
  set(ud.outputScriptEdit,'Position', posOutputScriptEdit);
  set(ud.okButton,        'Position', posOK);
  set(ud.cancelButton,    'Position', posCancel);
  set(ud.helpButton,      'Position', posHelp);
  set(ud.applyButton,     'Position', posApply);

  set(allHdls, 'Units', 'normalized');

%endfunction doResize


% Function: openDialog =========================================================
% Abstract:
%   Open the dialog create if needed, else make hidden dialog visible.
%
function openDialog(blkHdl)

  hdl = get_param(blkHdl,'UserData');
  if ~isempty(hdl) & ishandle(hdl)
    updateDataOnly = 1;
  else
    updateDataOnly = 0;
  end

  %
  % If it is update only, then we don't have to create the dialog again.
  %
  if ~updateDataOnly
    hdl = createDialog(blkHdl);
    set_param(blkHdl, 'UserData', hdl)
  end

  % Show the dialog
  set(hdl, 'visible', 'on');

%endfunction openDialog


% Function: deleteDialog =======================================================
% Abstract:
%   This function will be called when the block corresponding to the
%   MATLAB script block is being deleted.
%
function deleteDialog(blkHdl)

  if ~isempty(get_param(blkHdl, 'userdata'))

    hdl = get_param(blkHdl, 'userdata');
    if ~isempty(hdl) & ishandle(hdl)
      close(hdl);
    end
    if strcmp(get_param(blkHdl, 'LinkStatus'), 'none')
      set_param(blkHdl, 'userdata', []);
    end
  end

%endfunction deleteDialog



% Function: updateDialogName ===================================================
% Abstract:
%   This function will update block dialog's title name according to block's
%   name change.
%
function updateDialogName(blkHdl)

  hdl = get_param(blkHdl, 'userdata');

  set(hdl, 'Name', ['Block Parameters: ' get_param(blkHdl, 'name')]);
  ud.blkHdl = blkHdl;
  set(hdl, 'UserData', ud);
  if strcmp(get_param(blkHdl, 'LinkStatus'), 'none')
    set_param(blkHdl, 'UserData', hdl);
  end

%endfunction updateDialogName



% Function: returnKeyOK ========================================================
% Abstract:
%   This function will be called when user use keyboard to enter command. Now
%   it only does one thing: when it's from Enter key, call doOK function.
%
function returnKeyOK(fig, evd)

  ud = get(fig, 'UserData');

  if ~isempty(get(fig, 'CurrentChar')) 	% unix keyboard has an empty key
    if (abs(get(fig, 'CurrentChar')) == 13)
      doOK(ud.okButton, []);
    end
  end

%endfunction returnKeyOK


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
%endfunction toggleApply

% [EOF] 
