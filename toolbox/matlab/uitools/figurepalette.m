function comp = figurepalette (varargin)
% FIGUREPALETTE  Show or hide the palette for a figure.
%    FIGUREPALETTE ON shows the palette for the current figure.
%    FIGUREPALETTE OFF hides the palette.
%    FIGUREPALETTE TOGGLE toggles the visibility of the palette.
%    FIGUREPALETTE with no arguments is the same as ON.
%
% The first argument may be the handle to a figure, like so:
%    FIGUREPALETTE (h, 'on')
% 
% See also PLOTBROWSER, PROPERTYEDITOR, and PLOTTOOLS.

%   Copyright 1984-2003 The MathWorks, Inc.

error (nargchk (0,2,nargin))
compTmp = showplottool (varargin{:}, 'figurepalette');
if (nargout > 0)
    comp = compTmp;
end
