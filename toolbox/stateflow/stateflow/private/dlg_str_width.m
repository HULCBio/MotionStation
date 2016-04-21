function extent = dlg_str_width( str, fig, varargin )
%EXTENT = DLG_STR_WIDTH( STR, FIG, VARARGIN )  calculates the string width extent of a UI string
%  given a string it will return the appropritate
%  value.

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.14.2.1 $  $Date: 2004/04/15 00:57:13 $

if nargin<3
	tmp = uicontrol('Parent',fig,'Style','text','String',xlate(str),'Visible','off');
else
	tmp = uicontrol('Parent',fig,'Style','text','String',xlate(str),'Visible','off',varargin{:});
end
extent = get(tmp,'extent');
delete(tmp);
extent = extent(3);

