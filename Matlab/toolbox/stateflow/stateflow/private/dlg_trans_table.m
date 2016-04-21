function varargout = dlg_trans_table( varargin )
% DLG_TRANS_TABLE( varargin ) is going to implement the table translation
% edior. *** TBD ***

%   E. Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 00:57:15 $

	% Check is this is being called from targetdlg.apply.transTable method
	if nargin==1 & nargout==1 & isstr(varargin{1})
		% Need to return a string called 'local' when the input string starts with '{' character
		% otherwise we assume an external table and just return the input string hoping for a correct
		% file name.
		if ~isempty(varargin{1}) & (varargin{1}(1)=='{' | isequal(varargin{1},'local'))
			varargout{1} = 'local';
		else
			varargout{1} = varargin{1};
		end
		return
	end

	% Getting here means the function is called from targetdlg.gotoTransTable
	if nargin==1 & isnumeric(varargin{1})
		objectId = varargin{1};
		disp('EDIT TRANSLATION TABLE');
	end

