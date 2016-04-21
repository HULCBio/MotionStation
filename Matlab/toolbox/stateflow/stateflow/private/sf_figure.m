function figH = sf_figure(varargin),
%
% Use native figures.
%

%	Copyright 1995-2003 The MathWorks, Inc.
if sf('Feature','javaphigs')
	figH = figure(varargin{:});
else
	jFigFeature = feature('JavaFigures');
	feature('JavaFigures', 0);
	figH = figure(varargin{:});
	feature('JavaFigures', jFigFeature);
end
