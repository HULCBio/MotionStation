function [varargout] = uisetcolor(varargin)
%UISETCOLOR Color selection dialog box.
%   C = UISETCOLOR displays a color selection dialog appropriate to
%   the windowing system, and returns the color selected by the
%   user.  The dialog is initialized to white.
%   C = UISETCOLOR([R G B]) displays a dialog initialized to the
%   specified color, and returns the color selected by the user.
%   R, G, and B must be values between 0 and 1. 
%   C = UISETCOLOR(H) displays a dialog initialized to the color of
%   the object specified by handle H, returns the color selected by
%   the user, and applies it to the object.  H must be the handle
%   to an object containing a color property.
%   C = UISETCOLOR(...,'dialogTitle') displays a dialog with the
%   specified title.
%
%   If the user presses Cancel from the dialog box, or if any error 
%   occurs, the output value is set to the input RGB triple, if provided; 
%   otherwise, it is set to 0.
%
%   Example:
%           hText = text(.5,.5,'Hello World');
%           C = uisetcolor(hText, 'Set Text Color')
%
%
%   See also INSPECT, PROPEDIT, UISETFONT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.3 $  $Date: 2004/04/10 23:34:37 $
%   Built-in function.


if nargout == 0
  builtin('uisetcolor', varargin{:});
else
  [varargout{1:nargout}] = builtin('uisetcolor', varargin{:});
end
