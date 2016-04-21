function varargout = dlg_sub_dialog( method, objectId, subDialogName, value )
%DLG_SUB_DIALOG  Gets/Sets the sub-dialog handle from/on the main dialog
%                This fcn used to be in targetdlg.m but moved out since
%                we need to access this fcn in our brand new gui tests.
%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/04/15 00:57:14 $

	fig = sf('get',objectId,'.dialog');
	if ~ishandle(fig) | isequal(fig,0)
		if nargout>0
			varargout{1} = [];
		end
		return;
	end
	figData = get(fig,'UserData');
	if ~isfield(figData,subDialogName)
		if nargout>0
			varargout{1} = [];
		end
		return;
	end
	switch method
	case 'get'
		dlgH = getfield(figData,subDialogName);
		if isequal(dlgH,0) | ~ishandle(dlgH)
			varargout{1} = [];
		else
			varargout{1} = dlgH;
		end
	case 'set'
		figData = setfield(figData,subDialogName,value);
		set(fig,'UserData',figData);
	otherwise
		warning('Bad method passed to dlg_sub_dialog function.');
	end
