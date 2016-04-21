function dlg_set_string( handle, str )
% DLG_SET_STRING( HANDLE, STR )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:57:11 $
	set( handle, 'String', cellstr(strlines(str)));


