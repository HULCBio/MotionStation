function result = RMIQuickNav(method, source, objH, reqs, varargin)

% Copyright 2004 The MathWorks, Inc.

	persistent DIALOG_USERDATA;

	result = -1;

	% Cache variable arguement size
	nvarargin = length(varargin);

	% Assume user data and dialog not created
	userData = [];
	dialogH  = [];
	udIndex  = -1;

	% Check if dialog already created
	if ~isempty(DIALOG_USERDATA)
		i = 1;
		while (i <= length(DIALOG_USERDATA)) && (udIndex == -1)
			if (length(DIALOG_USERDATA(i).objH) == length(objH)) && all(DIALOG_USERDATA(i).objH == objH) && strcmp({DIALOG_USERDATA(i).source}, source)
				udIndex = i;
			end;
			i = i + 1;
		end;
		if ~isempty(udIndex) && (udIndex ~= -1)
			userData = DIALOG_USERDATA(udIndex);
			dialogH  = userData.dialogH;
		end;
	end;

	switch lower(method)
	case 'create'

		% If dialog doesn't exist, create it
		if isempty(userData)
			udLength = length(DIALOG_USERDATA);
			udIndex  = udLength + 1;

			% Process args
			switch nvarargin
			case 0
				activeIndex = [];
				baseIndex   = -1;
				count       = -1;
			case 1
				activeIndex = varargin{1};
				baseIndex   = -1;
				count       = -1;
			case 3
				activeIndex = varargin{1};
				baseIndex   = varargin{2};
				count       = varargin{3};
			otherwise
				error('Invalid number of arguments ');
			end;

			DIALOG_USERDATA(udIndex).objH    = objH;
			DIALOG_USERDATA(udIndex).source  = source;
			DIALOG_USERDATA(udIndex).dialogH = createRMIDialog(source, objH, reqs, activeIndex, baseIndex, count);

			dialogH = DIALOG_USERDATA(udIndex).dialogH;
		end;

		% Display dialog
		set(dialogH, 'visible', 'on');
		drawnow;

		result = dialogH;

	case 'delete_from_userdata'

		% Delete from user data
		if udIndex ~= -1
			DIALOG_USERDATA(udIndex) = [];
		end;

	case 'destroy'

		% Call destroy callback
		if udIndex ~= -1
			doDestroy(dialogH, []);
		end;

	end;


function result = createRMIDialog(source, objH, reqs, activeIndex, baseIndex, count)

	% Cache source and handle
	userData.source = source;
	userData.objH   = objH;

	% Cache requirements on user data
	userData.reqs = reqs;

	% Get geometric constants
	geoConst = RMIQuickNavGeoConst();

	% Get string constants
	strConst = RMIQuickNavStrConst();

	% compute dialog title
	dialogTitle = getDialogTitle(source, objH);

	% Compute label strings
	docLabelString = strConst.othersDoc;
	idLabelString  = strConst.othersID;

	% Compute dialog position
	screenSize   = get(0, 'ScreenSize');
	RMIdlgPos(1) = (screenSize(3) - geoConst.dialogWidth) / 2;
	RMIdlgPos(2) = (screenSize(4) - geoConst.dialogHeight) / 2;
	RMIdlgPos(3) = geoConst.dialogWidth;
	RMIdlgPos(4) = geoConst.dialogHeight;

	% Compute location of graphics
	thisFile = which('RMIQuickNav');
	[thisFilePath, thisFileName, thisFileExt] = fileparts(thisFile);
	addIcon  = fullfile(thisFilePath, 'rmi_add.gif');
	copyIcon = fullfile(thisFilePath, 'rmi_copy.gif');
	delIcon  = fullfile(thisFilePath, 'rmi_del.gif');
	upIcon   = fullfile(thisFilePath, 'rmi_up.gif');
	downIcon = fullfile(thisFilePath, 'rmi_down.gif');
	openIcon = fullfile(thisFilePath, 'rmi_open.gif');

	% Create dialog
	userData.RMIdlg = dialog('Name',        dialogTitle,...
							 'Resize',      'on',...
							 'WindowStyle', 'normal',...
							 'ResizeFcn',   {@doResize},...
							 'DeleteFcn',   {@doDestroy},...
							 'Visible',     'off'...
							 );
	userData.lb = uicontrol(userData.RMIdlg,...
							'Callback', {@doLBChange, userData.RMIdlg},...
							'Units',    'points',...
							'Style',    'listbox',...
							'Tag',      num2str(1)...
							);
	userData.addButton = uicontrol(userData.RMIdlg,...
								   'FontWeight', 'bold',...
								   'Units',      'points',...
								   'Style',      'pushbutton',...
								   'Callback',   {@doAdd, userData.RMIdlg},...
								   'CData',      i_LoadGifIcon(addIcon),...
								   'Tag',        num2str(12)...
								   );
	userData.copyButton = uicontrol(userData.RMIdlg,...
								   'FontWeight', 'bold',...
								   'Units',      'points',...
								   'Style',      'pushbutton',...
								   'Callback',   {@doCopy, userData.RMIdlg},...
								   'CData',      i_LoadGifIcon(copyIcon),...
								   'Tag',        num2str(13)...
								   );
	userData.delButton = uicontrol(userData.RMIdlg,...
								   'FontWeight', 'bold',...
								   'Units',      'points',...
								   'Style',      'pushbutton',...
								   'Callback',   {@doDelete, userData.RMIdlg},...
								   'CData',      i_LoadGifIcon(delIcon),...
								   'Tag',        num2str(14)...
								   );
	userData.upButton = uicontrol(userData.RMIdlg,...
								  'FontWeight', 'bold',...
								  'Units',      'points',...
								  'Style',      'pushbutton',...
								  'Callback',   {@doUp, userData.RMIdlg},...
								   'CData',     i_LoadGifIcon(upIcon),...
								  'Tag',        num2str(15)...
								  );
	userData.downButton = uicontrol(userData.RMIdlg,...
								   'FontWeight', 'bold',...
								   'Units',      'points',...
								   'Style',      'pushbutton',...
								   'Callback',   {@doDown, userData.RMIdlg},...
								   'CData',      i_LoadGifIcon(downIcon),...
								   'Tag',        num2str(18)...
								   );
	userData.navButton = uicontrol(userData.RMIdlg,...
								   'FontWeight', 'bold',...
								   'Units',      'points',...
								   'Style',      'pushbutton',...
								   'String',     strConst.navButton,...
								   'Callback',   {@doNavigate, userData.RMIdlg},...
								   'Tag',        num2str(17)...
								   );
	userData.descLabel = uicontrol(userData.RMIdlg,...
								   'FontWeight',          'bold',...
								   'Style',               'text',...
								   'HorizontalAlignment', 'left',...
								   'String',              strConst.description,...
								   'Units',               'points',...
								   'Tag',                 num2str(2)...
								  );
	userData.descEdit = uicontrol(userData.RMIdlg,...
								 'Style',               'edit',...
								 'HorizontalAlignment', 'left',...
								 'Units',               'points',...
								 'Callback',            {@doEditChange},...
								 'Tag',                 num2str(3)...
								 );
	userData.docLabel = uicontrol(userData.RMIdlg,...
								  'FontWeight',          'bold',...
								  'Style',               'text',...
								  'HorizontalAlignment', 'left',...
								  'String',              docLabelString,...
								  'Units',               'points',...
								  'Tag',                 num2str(4)...
								  );
	userData.docEdit = uicontrol(userData.RMIdlg,...
								 'Style',               'edit',...
								 'HorizontalAlignment', 'left',...
								 'Units',               'points',...
								 'Callback',            {@doEditChange},...
								 'Tag',                 num2str(5)...
								 );
	userData.openButton = uicontrol(userData.RMIdlg,...
									'FontWeight', 'bold',...
									'Units',      'points',...
									'Style',      'pushbutton',...
									'Callback',   {@doOpen, userData.RMIdlg},...
									'CData',      i_LoadGifIcon(openIcon),...
									'Tag',        num2str(6)...
									);
	userData.idLabel = uicontrol(userData.RMIdlg,...
								 'FontWeight',          'bold',...
								 'Style',               'text',...
								 'HorizontalAlignment', 'left',...
								 'String',              idLabelString,...
								 'Units',               'points',...
								 'Tag',                 num2str(8)...
								 );
	userData.idEdit = uicontrol(userData.RMIdlg,...
								'Style',               'edit',...
								'HorizontalAlignment', 'left',...
								'Units',               'points',...
								'Callback',            {@doEditChange},...
								'Tag',                 num2str(9)...
								);
	userData.keywordLabel = uicontrol(userData.RMIdlg,...
									  'FontWeight',          'bold',...
									  'Style',               'text',...
									  'HorizontalAlignment', 'left',...
									  'String',              strConst.keyword,...
									  'Units',               'points',...
									  'Tag',                 num2str(10)...
									  );
	userData.keywordEdit = uicontrol(userData.RMIdlg,...
									 'Style',               'edit',...
									 'HorizontalAlignment', 'left',...
									 'Units',               'points',...
									 'Callback',            {@doEditChange},...
									 'Tag',                 num2str(11)...
									 );
	userData.applyButton = uicontrol(userData.RMIdlg,...
									 'Style',    'pushbutton',...
									 'String',   strConst.applyButton,...
									 'Units',    'points',...
									 'Callback', {@doApply},...
									 'Tag',      num2str(21)...
									 );
	userData.helpButton = uicontrol(userData.RMIdlg,...
									'Style',  'pushbutton',...
									'String', strConst.helpButton,...
									'Units',  'points',...
									'Callback', {@doHelp},...
									'Tag',    num2str(20)...
									);
	userData.cancelButton = uicontrol(userData.RMIdlg,...
									  'Style',    'pushbutton',...
									  'String',   strConst.cancelButton,...
									  'Units',    'points',...
									  'Callback', {@doCancel},...
									  'Tag',      num2str(19)...
									  );
	userData.okButton = uicontrol(userData.RMIdlg,...
								  'Style',    'pushbutton',...
								  'String',   strConst.okButton,...
								  'Units',    'points',...
								  'Callback', {@doOk},...
								  'Tag',      num2str(18)...
								  );

	% Listbox context menu
	userData.contextMenu = uicontextmenu('Parent', userData.RMIdlg, 'Tag', num2str(21));
	userData.ctxMenuAdd  = uimenu(userData.contextMenu, 'Label', 'Add',    'Callback', {@doAdd, userData.RMIdlg});
	userData.ctxMenuCopy = uimenu(userData.contextMenu, 'Label', 'Copy',   'Callback', {@doCopy, userData.RMIdlg});
	userData.ctxMenuDel  = uimenu(userData.contextMenu, 'Label', 'Delete', 'Callback', {@doDelete, userData.RMIdlg});
	userData.ctxMenuUp   = uimenu(userData.contextMenu, 'Label', 'Up',     'Callback', {@doUp, userData.RMIdlg});
	userData.ctxMenuDown = uimenu(userData.contextMenu, 'Label', 'Down',   'Callback', {@doDown, userData.RMIdlg});
	set(userData.lb, 'UIContextMenu', userData.contextMenu);

	% History context menu
	userData.histMenu  = uicontextmenu('Parent', userData.RMIdlg, 'Tag', num2str(21));
	set(userData.docEdit,  'UIContextMenu', userData.histMenu);
	set(userData.docLabel, 'UIContextMenu', userData.histMenu);

	% Contents context menu
	userData.contentsMenu  = uicontextmenu('Parent', userData.RMIdlg,'Tag', num2str(22), 'Callback', {@doContentsMenuCreate, userData.RMIdlg});
	set(userData.idLabel,  'UIContextMenu', userData.contentsMenu);
	set(userData.idEdit, 'UIContextMenu', userData.contentsMenu);
	
	% Set tab order
	children = get(userData.RMIdlg, 'Children');
	tags     = get(children, 'Tag');
	tags     = strvcat(tags);
	tags     = str2num(tags);
	[sortedTags, indexVector]= sort(tags, 'descend');
	children = children(indexVector);
	set(userData.RMIdlg, 'Children', children);

	% Set active requirement
	if activeIndex ~= -1
		userData.activeReq = activeIndex;
	elseif ~isempty(userData.reqs) && ~isempty(userData.reqs.docs)
		userData.activeReq = 1;
	else
		userData.activeReq = 0;
	end;

	% Cache base index and count
	userData.baseIndex = baseIndex;
	userData.count     = count;

	% Cache dialog on user data
	userData.dialogH = userData.RMIdlg;

	% Cache complete user data on dialog
	set(userData.RMIdlg, 'UserData', userData);

	% Position dialog
	set(userData.RMIdlg, 'Units', 'pixels');
	set(userData.RMIdlg, 'Position', RMIdlgPos);
	set(userData.RMIdlg, 'Units', 'points');

	% Position controls
	doResize(userData.RMIdlg, []);

	% Update UI fields
	doUpdateFields(userData.RMIdlg, []);

	result = userData.RMIdlg;


function result = getDialogTitle(source, objH)

	% Assume no title
	result = '';

	% Get string constants
	strConst = RMIQuickNavStrConst();

	% Is this a vector dialog?
	len = length(objH);

	if len > 1
		result = sprintf('Add requirements: %d objects selected', len);
	else
		switch source
		case 'simulink'
			result = get_param(objH, 'name');
		case 'stateflow'
			transitionIsa = sf('get', 'default', 'transition.isa');
			objIsa        = sf('get', objH, '.isa');
			if objIsa == transitionIsa
				result = sf('get', objH, '.labelString');
			else
				result = sf('get', objH, '.name');
			end;
		end;
		result = [strConst.dialogTitle result];
	end;


function doResize(rmiDialogHandle, evd)

	% Get dialog position
	RMIdlgPos = get(rmiDialogHandle, 'Position');

	% Get dialog user data
	userData = get(rmiDialogHandle, 'UserData');

	% Get geometric constants
	geoConst = RMIQuickNavGeoConst();

	% Compute text height
	textExtent = uicontrol(rmiDialogHandle,...
						   'Units',   'points',...
						   'Visible', 'off',...
						   'Style',   'text',...
						   'String',  'WWW'...
						   );
	vTextExtent = get(textExtent, 'Extent');
	vTextExtent = vTextExtent(4);

	% Compute height of all buttons
	buttonHeight = geoConst.buttonHeightMul * vTextExtent;

	% Compute metrics of add/delete/up/down buttons
	adudButtonX = geoConst.hWindowMargin;
	adudButtonW = geoConst.lbButtonWidth;
	adudButtonH = buttonHeight;
	
	% Compute metrics of ok/cancel/help/apply
	ochaButtonY = geoConst.vWindowMargin;
	ochaButtonW = geoConst.dlgButtonWidth;
	ochaButtonH = buttonHeight;

	% Compute height of edit fields
	editH = geoConst.editHeightMul * vTextExtent;

	% Compute add button position
	addButtonY   = RMIdlgPos(4) - geoConst.vWindowMargin - adudButtonH;
	addButtonPos = [adudButtonX, addButtonY, adudButtonW, adudButtonH];

	% Compute copy button position
	copyButtonY   = addButtonPos(2) - adudButtonH - geoConst.vButtonMargin;
	copyButtonPos = [adudButtonX, copyButtonY, adudButtonW, adudButtonH];

	% Compute delete button position
	delButtonY   = copyButtonPos(2) - adudButtonH - geoConst.vButtonMargin;
	delButtonPos = [adudButtonX, delButtonY, adudButtonW, adudButtonH];

	% Compute up button position
	upButtonY   = delButtonPos(2) - adudButtonH - geoConst.vButtonMargin;
	upButtonPos = [adudButtonX, upButtonY, adudButtonW, adudButtonH];

	% Compute up button position
	downButtonY   = upButtonPos(2) - adudButtonH - geoConst.vButtonMargin;
	downButtonPos = [adudButtonX, downButtonY, adudButtonW, adudButtonH];

	% Compute apply button position
	applyButtonX   = RMIdlgPos(3) - geoConst.hWindowMargin - geoConst.dlgButtonWidth;
	applyButtonPos = [applyButtonX, ochaButtonY, ochaButtonW, ochaButtonH];

	% Compute help button position
	helpButtonX   = applyButtonX - geoConst.hButtonMargin - geoConst.dlgButtonWidth;
	helpButtonPos = [helpButtonX, ochaButtonY, ochaButtonW, ochaButtonH];

	% Compute cancel button position
	cancelButtonX   = helpButtonX - geoConst.hButtonMargin - geoConst.dlgButtonWidth;
	cancelButtonPos = [cancelButtonX, ochaButtonY, ochaButtonW, ochaButtonH];

	% Compute OK button position
	okButtonX   = cancelButtonX - geoConst.hButtonMargin - geoConst.dlgButtonWidth;
	okButtonPos = [okButtonX, ochaButtonY, ochaButtonW, ochaButtonH];

	% Compute navigation button position
	navButtonX   = addButtonPos(1) + addButtonPos(4) + geoConst.hSplitMargin1;
	navButtonY   = ochaButtonY + ochaButtonH + geoConst.vSplitMargin1;
	navButtonW   = geoConst.lbWidthMul * RMIdlgPos(3);
	navButtonPos = [navButtonX, navButtonY, navButtonW, adudButtonH];

	% Compute listbox position
	lbY   = navButtonY + ochaButtonH + geoConst.vButtonMargin;
	lbH   = RMIdlgPos(4) - lbY - geoConst.vWindowMargin;
	lbPos = [navButtonX, lbY, navButtonW, lbH];

	% Compute description label position
	descLabelH   = geoConst.labelHeightMul * vTextExtent;
	descLabelX   = lbPos(1) + lbPos(3) + geoConst.hSplitMargin2;
	descLabelY   = RMIdlgPos(4) - geoConst.vWindowMargin - descLabelH;
	descLabelW   = RMIdlgPos(3) - geoConst.hWindowMargin - descLabelX;
	descLabelPos = [descLabelX, descLabelY, descLabelW, descLabelH];

	% Compute description edit position
	descEditY   = descLabelY - editH;
	descEditPos = [descLabelX, descEditY, descLabelW, editH];

	% Compute document label position
	docLabelY   = descEditY - geoConst.vEditMargin;
	docLabelPos = [descLabelX, docLabelY, descLabelW, descLabelH];

	% Compute document edit position
	docEditY   = docLabelY - editH;
	docEditW   = descLabelW - adudButtonW;
	docEditPos = [descLabelX, docEditY, docEditW, editH];

	% Compute open button position
	openButtonX   = descLabelX + descLabelW - adudButtonW;
	openButtonY   = docLabelY - editH;
	openButtonPos = [openButtonX, openButtonY, adudButtonW, editH];

	% Compute ID label position
	idLabelY   = docEditY - geoConst.vEditMargin;
	idLabelPos = [descLabelX, idLabelY, descLabelW, descLabelH];

	% Compute ID edit position
	idEditY   = idLabelY - editH;
	idEditPos = [descLabelX, idEditY, descLabelW, editH];

	% Compute keyword label position
	keywordLabelY   = idEditY - geoConst.vEditMargin;
	keywordLabelPos = [descLabelX, keywordLabelY, descLabelW, descLabelH];

	% Compute keyword edit position
	keywordEditY   = keywordLabelY - editH;
	keywordEditPos = [descLabelX, keywordEditY, descLabelW, editH];

	% Update control positions
	set(userData.lb,           'Position', lbPos);
	set(userData.addButton,    'Position', addButtonPos);
	set(userData.copyButton,   'Position', copyButtonPos);
	set(userData.delButton,    'Position', delButtonPos);
	set(userData.upButton,     'Position', upButtonPos);
	set(userData.downButton,   'Position', downButtonPos);
	set(userData.navButton,    'Position', navButtonPos);
	set(userData.descLabel,    'Position', descLabelPos);
	set(userData.descEdit,     'Position', descEditPos);
	set(userData.docLabel,     'Position', docLabelPos);
	set(userData.docEdit,      'Position', docEditPos);
	set(userData.openButton,   'Position', openButtonPos);
	set(userData.idLabel,      'Position', idLabelPos);
	set(userData.idEdit,       'Position', idEditPos);
	set(userData.keywordLabel, 'Position', keywordLabelPos);
	set(userData.keywordEdit,  'Position', keywordEditPos);
	set(userData.applyButton,  'Position', applyButtonPos);
	set(userData.helpButton,   'Position', helpButtonPos);
	set(userData.cancelButton, 'Position', cancelButtonPos);
	set(userData.okButton,     'Position', okButtonPos);


function doDestroy(rmiDialogHandle, evd)

	% Get dialog user data
	userData = get(rmiDialogHandle, 'UserData');

	% Delete from user data
	RMIQuickNav('delete_from_userdata', userData.source, userData.objH);

	% Delete dialog
	delete(rmiDialogHandle);


function doUpdateFields(rmiDialogHandle, evd)

	% Color constants
	colorConst.whiteRGB = [1 1 1];
	colorConst.bgColor  = get(0, 'defaultuicontrolbackgroundcolor');

	% Get dialog user data
	userData = get(rmiDialogHandle, 'UserData');

	% Get listbox strings
	lbString = ListboxStrings(userData.reqs);

	% Assign field values
	set(userData.lb, 'String', lbString);
	if userData.activeReq > 0
		set(userData.descEdit,    'String', userData.reqs.descriptions{userData.activeReq});
		set(userData.docEdit,     'String', userData.reqs.docs{userData.activeReq});
		set(userData.idEdit,      'String', userData.reqs.ids{userData.activeReq});
		set(userData.keywordEdit, 'String', userData.reqs.keywords{userData.activeReq});
	else
		set(userData.descEdit,    'String', '');
		set(userData.docEdit,     'String', '');
		set(userData.idEdit,      'String', '');
		set(userData.keywordEdit, 'String', '');
	end;

	% Update listbox index
	set(userData.lb, 'Value', userData.activeReq);

	% Any requirements?
	numReqs = 0;
	if ~isempty(userData.reqs)
		numReqs = length(userData.reqs.docs);
	end;
	anyReqs = numReqs > 0;

	% Compute control background color
	if anyReqs
		colorUsed = colorConst.whiteRGB;
	else
		colorUsed = colorConst.bgColor;
	end;

	% Populate history
	children = get(userData.histMenu, 'Children');
	delete(children);
	histData = RMIHist('get');
	for i = 1 : length(histData)
		uimenu(userData.histMenu, 'Label', histData{i}, 'Callback', {@doHist, userData.RMIdlg});
	end;

	% Set history enable - doesn't work if set parent visible
	children = get(userData.histMenu, 'Children');
	for i = 1 : length(children)
		set(children(i), 'Visible', Bool2OnOff(anyReqs));
	end;

	% Update button enable
	set(userData.applyButton, 'Visible', Bool2OnOff(length(userData.objH) == 1));
	set(userData.copyButton,  'Enable',  Bool2OnOff(anyReqs));
	set(userData.delButton,   'Enable',  Bool2OnOff(anyReqs));
	set(userData.navButton,   'Enable',  Bool2OnOff(anyReqs));
	set(userData.descEdit,    'Enable',  Bool2OnOff(anyReqs));
	set(userData.docEdit,     'Enable',  Bool2OnOff(anyReqs));
	set(userData.openButton,  'Enable',  Bool2OnOff(anyReqs));
	set(userData.idEdit,      'Enable',  Bool2OnOff(anyReqs));
	set(userData.keywordEdit, 'Enable',  Bool2OnOff(anyReqs));
	set(userData.upButton,    'Enable',  Bool2OnOff(userData.activeReq > 1));
	set(userData.downButton,  'Enable',  Bool2OnOff(userData.activeReq < numReqs));
	set(userData.ctxMenuDel,  'Enable',  Bool2OnOff(anyReqs));
	set(userData.ctxMenuUp,   'Enable',  Bool2OnOff(userData.activeReq > 1));
	set(userData.ctxMenuDown, 'Enable',  Bool2OnOff(userData.activeReq < numReqs));

	% Update edit background colors
	set(userData.lb,          'backgroundcolor', colorUsed);
	set(userData.descEdit,    'backgroundcolor', colorUsed);
	set(userData.docEdit,     'backgroundcolor', colorUsed);
	set(userData.idEdit,      'backgroundcolor', colorUsed);
	set(userData.keywordEdit, 'backgroundcolor', colorUsed);

	drawnow;


function doLBChange(listbox, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Get type of mouse click
	selectionType = get(dialogH, 'SelectionType');

	switch selectionType
	case 'normal'
		% Cache selected index
		userData.activeReq = get(listbox, 'Value');

		% Update user data
		set(dialogH, 'UserData', userData);

		% Update UI
		doUpdateFields(dialogH, evd);
	case 'open'
		doNavigate(userData.navButton, evd, dialogH);
	end;


function doEditChange(editField, evd)

	% Get dialog handle
	parent = get(editField, 'Parent');

	% Get dialog user data
	userData = get(parent, 'UserData');

	% Get entry field values
	descStr    = get(userData.descEdit,    'String');
	docStr     = get(userData.docEdit,     'String');
	idStr      = get(userData.idEdit,      'String');
	keywordStr = get(userData.keywordEdit, 'String');
	
	% Set description to ID if description is empty and ID is not
	if (userData.idEdit == editField) && isempty(descStr) && ~isempty(idStr)
		descStr = idStr;
	end;

	% Update user data
	userData.reqs.descriptions{userData.activeReq} = descStr;
	userData.reqs.docs{userData.activeReq}         = docStr;
	userData.reqs.ids{userData.activeReq}          = idStr;
	userData.reqs.linked{userData.activeReq}       = 1;
	userData.reqs.keywords{userData.activeReq}     = keywordStr;
	userData.reqs.reqsys{userData.activeReq}       = 'other';

	if editField == userData.docEdit
		RMIHist('add', docStr);
	end;

	% Update user data
	set(parent, 'UserData', userData);

	% Update UI
	doUpdateFields(parent, evd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to obtain the contents of a file
% that are suitable as targets of the RMI

function doContentsMenuCreate(contentsMenu, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');
    fileName = get(userData.docEdit,'String');

    % Delete existing contents entries
	children = get(userData.contentsMenu, 'Children');
	delete(children);

    if isempty(fileName)
        return;
    end

	% Use 1st object as basis for forming path
    filePath = locate_file(fileName, rmi('getmodelh', userData.objH(1)));

    if isempty(filePath)
        return;
    end
    
    set(dialogH,'Pointer','watch');

    [headings,levels] = file_headings(filePath);
    for i=1:length(headings)
		uimenu(userData.contentsMenu, 'Label', headings{i}, 'Callback', {@doContentsMenuApply, userData.RMIdlg});
	end

    set(dialogH,'Pointer','arrow');

    

function doContentsMenuApply(contentsMenu, evd, dialogH)

	userData = get(dialogH, 'UserData');
	str = get(contentsMenu, 'Label');
	set(userData.idEdit,'String',str);

	% Update UI
	doEditChange(userData.idEdit, evd);


function doHist(histMenu, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Get menu item string
	filename = get(histMenu, 'Label');

	% Add to history
	RMIHist('add', filename);

	% Set field data
	userData.reqs.docs{userData.activeReq} = filename;

	% Update user data
	set(dialogH, 'UserData', userData);

	% Update UI
	doUpdateFields(dialogH, evd);


function doAdd(addButton, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Get string constants
	strConst = RMIQuickNavStrConst();

	% Ensure fields exist
	if isempty(userData.reqs)
		userData.reqs.descriptions = {};
		userData.reqs.docs         = {};
		userData.reqs.ids          = {};
		userData.reqs.linked       = {};
		userData.reqs.keywords     = {};
		userData.reqs.reqsys       = {};
	end;

	% Add requirement
	userData.reqs.descriptions{end + 1} = strConst.newDesc;
	userData.reqs.docs{end + 1}         = strConst.newDoc;
	userData.reqs.ids{end + 1}          = strConst.newID;
	userData.reqs.linked{end + 1}       = 0;
	userData.reqs.keywords{end + 1}     = '';
	userData.reqs.reqsys{end + 1}       = 'other';

	% Cache index of active requirement
	userData.activeReq = length(userData.reqs.docs);

	% Update user data
	set(dialogH, 'UserData', userData);

	% Update UI
	doUpdateFields(dialogH, evd);


function doCopy(copyButton, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Add requirement
	userData.reqs.descriptions{end + 1} = userData.reqs.descriptions{userData.activeReq};
	userData.reqs.docs{end + 1}         = userData.reqs.docs{userData.activeReq};
	userData.reqs.ids{end + 1}          = userData.reqs.ids{userData.activeReq};
	userData.reqs.linked{end + 1}       = userData.reqs.linked{userData.activeReq};
	userData.reqs.keywords{end + 1}     = userData.reqs.keywords{userData.activeReq};
	userData.reqs.reqsys{end + 1}       = userData.reqs.reqsys{userData.activeReq};

	% Set active requirement
	userData.activeReq = length(userData.reqs.docs);

	% Update user data
	set(dialogH, 'UserData', userData);

	% Update UI
	doUpdateFields(dialogH, evd);


function doDelete(deleteButton, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Delete requirement
	userData.reqs.docs(userData.activeReq)         = [];
	userData.reqs.ids(userData.activeReq)          = [];
	userData.reqs.linked(userData.activeReq)       = [];
	userData.reqs.descriptions(userData.activeReq) = [];
	userData.reqs.keywords(userData.activeReq)     = [];
	userData.reqs.reqsys(userData.activeReq)       = [];

	% Validate active requirement index
	userData.activeReq = min(userData.activeReq, length(userData.reqs.docs));

	% Update user data
	set(dialogH, 'UserData', userData);

	% Update UI
	doUpdateFields(dialogH, evd);


function doUp(upButton, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Swap requirement
	tempDoc         = userData.reqs.docs(userData.activeReq);
	tempID          = userData.reqs.ids(userData.activeReq);
	tempLinked      = userData.reqs.linked(userData.activeReq);
	tempDescription = userData.reqs.descriptions(userData.activeReq);
	tempKeyword     = userData.reqs.keywords(userData.activeReq);
	tempReqsys      = userData.reqs.reqsys(userData.activeReq);
	userData.reqs.docs(userData.activeReq)         = userData.reqs.docs(userData.activeReq - 1);
	userData.reqs.ids(userData.activeReq)          = userData.reqs.ids(userData.activeReq - 1);
	userData.reqs.linked(userData.activeReq)       = userData.reqs.linked(userData.activeReq - 1);
	userData.reqs.descriptions(userData.activeReq) = userData.reqs.descriptions(userData.activeReq - 1);
	userData.reqs.keywords(userData.activeReq)     = userData.reqs.keywords(userData.activeReq - 1);
	userData.reqs.reqsys(userData.activeReq)       = userData.reqs.reqsys(userData.activeReq - 1);
	userData.reqs.docs(userData.activeReq - 1)         = tempDoc;
	userData.reqs.ids(userData.activeReq - 1)          = tempID;
	userData.reqs.linked(userData.activeReq - 1)       = tempLinked;
	userData.reqs.descriptions(userData.activeReq - 1) = tempDescription;
	userData.reqs.keywords(userData.activeReq - 1)     = tempKeyword;
	userData.reqs.reqsys(userData.activeReq - 1)       = tempReqsys;

	% Update active requirement
	userData.activeReq = userData.activeReq - 1;

	% Update user data
	set(dialogH, 'UserData', userData);

	% Update UI
	doUpdateFields(dialogH, evd);


function doDown(downButton, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Not done
	% Swap requirement
	tempDoc         = userData.reqs.docs(userData.activeReq);
	tempID          = userData.reqs.ids(userData.activeReq);
	tempLinked      = userData.reqs.linked(userData.activeReq);
	tempDescription = userData.reqs.descriptions(userData.activeReq);
	tempKeyword     = userData.reqs.keywords(userData.activeReq);
	tempReqsys      = userData.reqs.reqsys(userData.activeReq);
	userData.reqs.docs(userData.activeReq)         = userData.reqs.docs(userData.activeReq + 1);
	userData.reqs.ids(userData.activeReq)          = userData.reqs.ids(userData.activeReq + 1);
	userData.reqs.linked(userData.activeReq)       = userData.reqs.linked(userData.activeReq + 1);
	userData.reqs.descriptions(userData.activeReq) = userData.reqs.descriptions(userData.activeReq + 1);
	userData.reqs.keywords(userData.activeReq)     = userData.reqs.keywords(userData.activeReq + 1);
	userData.reqs.reqsys(userData.activeReq)       = userData.reqs.reqsys(userData.activeReq + 1);
	userData.reqs.docs(userData.activeReq + 1)         = tempDoc;
	userData.reqs.ids(userData.activeReq + 1)          = tempID;
	userData.reqs.linked(userData.activeReq + 1)       = tempLinked;
	userData.reqs.descriptions(userData.activeReq + 1) = tempDescription;
	userData.reqs.keywords(userData.activeReq + 1)     = tempKeyword;
	userData.reqs.reqsys(userData.activeReq + 1)       = tempReqsys;

	% Update active requirement
	userData.activeReq = userData.activeReq + 1;

	% Update user data
	set(dialogH, 'UserData', userData);

	% Update UI
	doUpdateFields(dialogH, evd);


function doOpen(openButton, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Get file name
	[fileName, pathName] = uigetfile({'*.doc;*.xls;*.html;*.txt',...
									  'Requirement documents (*.doc, *.xls, *.html, *.txt)';...
									  '*.*',...
									  'All Files (*.*)'},...
									  'Select requirements document');

	if ischar(fileName) && ischar(pathName)
		fullFileName = fullfile(pathName, fileName);

		% Update doc
			userData.reqs.docs(userData.activeReq) = {fullFileName};
		
		% Add to history
		RMIHist('add', fullFileName);

		% Update user data
		set(dialogH, 'UserData', userData);

		% Update UI
		doUpdateFields(dialogH, evd);
	end;


function doNavigate(navButton, evd, dialogH)

	% Get dialog user data
	userData = get(dialogH, 'UserData');

	% Get model handle based on 1st object
	modelH = rmi('getmodelh', userData.objH(1));

	% Fetch doc and ID
	doc = userData.reqs.docs{userData.activeReq};
	id  = userData.reqs.ids{userData.activeReq};

	% Navigate to requirement
	RMINavigateTo(modelH, doc, id);


function doApply(applyButton, evd)

	% Get dialog handle
	parent = get(applyButton, 'Parent');

	% Get dialog user data
	userData = get(parent, 'UserData');

	% Is this a vector operation?
	len = length(userData.objH);

	% If scalar object, then set requirements
	if (len == 1) && rmi('ishandlevalid', userData.objH(1))
		% Commit
		rmi('set', userData.objH(1), userData.reqs, userData.baseIndex, userData.count);

		% Post apply notify the vnv verification panel
		if (strcmp(userData.source, 'simulink') && is_signal_builder_block(userData.objH(1)))
			count = length(userData.reqs.descriptions);
			vnv_panel_mgr('sbUpdateReq', userData.objH(1), userData.baseIndex, count);
		end;

	% If vector object, then cat requirements
	else
		% Only warn once if signal builder selected
		sigbfound = 0;

		for i = 1 : len
			obj = userData.objH(i);

			% Don't save if doesn't exist
			if rmi('ishandlevalid', obj)
				if strcmp(userData.source, 'simulink') && is_signal_builder_block(obj)
					sigbfound = 1;
				else
					rmi('cat', obj, userData.reqs);
				end;
			end;
		end;

		% Signal builder does not respect multicat
		if sigbfound
			msgbox('Requirements were not added to signal builder blocks.  Requirements can only be added from within signal builder.','Requirements');
		end;
	end;


function doOk(okButton, evd)

	% Get dialog handle
	parent = get(okButton, 'Parent');

	% Get dialog user data
	userData = get(parent, 'UserData');

	% Apply
	doApply(userData.applyButton, evd)

	% Destroy
	doDestroy(parent, evd);


function doCancel(cancelButton, evd)

	parent = get(cancelButton, 'Parent');
	doDestroy(parent, evd);


function doHelp(helpButton, evd)

	parent = get(helpButton, 'Parent');
	helpview([docroot '/toolbox/slvnv/slvnv.map'], 'requirements_dialog');


function result = ListboxStrings(reqs)

	result = {};

	if ~isempty(reqs)
		for i = 1 : length(reqs.descriptions)
			if ~isempty(reqs.descriptions{i})
				result(i) = reqs.descriptions(i)';
			else
				result(i) = {'<No description entered>'};
			end;
		end;
	end;


function result = Bool2OnOff(bool)

	if bool
		result = 'on';
	else
		result = 'off';
	end;


function result = RMIQuickNavGeoConst()

	% Geometric constants
	result.dialogWidth     = 650; % Dialog width
	result.dialogHeight    = 285; % Dialog height
	result.hWindowMargin   = 5;   % Horizontal window margin
	result.vWindowMargin   = 5;   % Vertical window margin
	result.lbWidthMul      = 0.4; % Listbox width
	result.lbButtonWidth   = 30;  % Add/delete button width
	result.dlgButtonWidth  = 40;  % Dialog button width
	result.hButtonMargin   = 5;   % Horizontal button margin
	result.vButtonMargin   = 5;   % Horizontal button margin
	result.hSplitMargin1   = 20;  % Margin between add/delete/up/down/nav buttons and listbox
	result.hSplitMargin2   = 20;  % Margin between listbox and edit fields
	result.vSplitMargin1   = 18;  % Margin between ok/cancel/help/apply and Navigate button
	result.labelHeightMul  = 1.1; % Label height = v. text extent * labelHeightMul
	result.editHeightMul   = 1.2; % Edit height = v. text extent * editHeightMul
	result.buttonHeightMul = 1.3; % Button height = v. text extent * buttonHeightMul
	result.vEditMargin     = 30;  % Vertical margin between edit fields


function result = RMIQuickNavStrConst()

	result.newDesc      = '';
	result.newDoc       = '';
	result.newID        = '';
	result.addButton    = '+';
	result.delButton    = '-';
	result.upButton     = '^';
	result.downButton   = 'v';
	result.navButton    = 'View Selected';
	result.description  = 'Requirement description:';
	result.doorsDoc     = 'Document:';
	result.doorsID      = 'ID:';
	result.othersDoc    = 'Document: (right-click for previous entries)';
	result.othersID     = 'Location in document (right-click for list):';
	result.keyword      = 'Custom tag:';
	result.okButton     = 'OK';
	result.cancelButton = 'Cancel';
	result.helpButton   = 'Help';
	result.applyButton  = 'Apply';
	result.dialogTitle  = 'Requirements: ';


% Lifted from toolbox\simulink\simulink\watchsigsdlg.m
function icon = i_LoadGifIcon(fileName)
    
    bgNew = get(0, 'defaultuicontrolbackgroundcolor');
    [img,cm] = imread(fileName,'gif');
    
    % Convert Add
    img = double(img)+1;
    
    % Overwrite the background color with the UI Background color.
    % (Assume the top, left corner is a background color.)
    cm(img(1,1),:) = bgNew;
    
    % This converts the gif to rgb.  It does not use ind2rgb, because 
    % the user may not have purchased the Image Processing Toolbox.
    icon = reshape(cm(img,:),[size(img) 3]);
    
%end i_LoadGifIcon(fileName)


