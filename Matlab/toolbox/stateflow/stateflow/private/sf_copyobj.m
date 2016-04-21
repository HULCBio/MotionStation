function objH = sf_copyobj(varargin)
%
% Do a native copy
%

%	Copyright 1995-2003 The MathWorks, Inc.

if sf('Feature','javaphigs')
	objH = copyobj(varargin{:});
else
	jFigFeature = feature('JavaFigures');
	feature('JavaFigures', 0);
	objH = copyobj(varargin{:});
	feature('JavaFigures', jFigFeature);
end
