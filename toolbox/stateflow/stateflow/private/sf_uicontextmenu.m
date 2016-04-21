function objH = sf_uicontextmenu(varargin),
%
% Use native conext menus
%

%	Copyright 1995-2003 The MathWorks, Inc.

if sf('Feature','javaphigs')
	objH = uicontextmenu(varargin{:});
else
	jFigFeature = feature('JavaFigures');
	feature('JavaFigures', 0);
	objH = uicontextmenu(varargin{:});
	feature('JavaFigures', jFigFeature);
end
