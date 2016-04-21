function objH = sf_uicontrol(varargin),
%
% Use Native uicontrol
%

%	Copyright 1995-2003 The MathWorks, Inc.


if sf('Feature','javaphigs')
	objH = uicontrol(varargin{:});
else
	jFigFeature = feature('JavaFigures');
	feature('JavaFigures', 0);
	objH = uicontrol(varargin{:});
	feature('JavaFigures', jFigFeature);
end
