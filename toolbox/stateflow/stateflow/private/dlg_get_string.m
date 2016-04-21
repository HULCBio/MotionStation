function str = dlg_get_string( handle )
%STR = DLG_GET_STRING( HG_HANDLE )

%   E.Mehran Mestchian January 1997
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:56:55 $

	str = strlong(despace(char(get(handle,'String'))));


