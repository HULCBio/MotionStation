function comp = propertyeditor (varargin)
% PROPERTYEDITOR  Show or hide the property editor for a figure.
%    PROPERTYEDITOR ON shows the editor for the current figure.
%    PROPERTYEDITOR OFF hides the editor.
%    PROPERTYEDITOR TOGGLE toggles the visibility of the editor.
%    PROPERTYEDITOR with no arguments is the same as ON.
%
% The first argument may be the handle to a figure, like so:
%    PROPERTYEDITOR (h, 'on')
% 
% See also PLOTBROWSER, FIGUREPALETTE, and PLOTTOOLS.

%   Copyright 1984-2003 The MathWorks, Inc.

error (nargchk (0,2,nargin))
compTmp = showplottool (varargin{:}, 'propertyeditor');
if (nargout > 0)
    comp = compTmp;
end
