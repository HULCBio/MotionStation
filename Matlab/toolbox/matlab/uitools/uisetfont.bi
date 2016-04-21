function [varargout] = uisetfont(varargin)
%UISETFONT Font selection dialog box.
%   S = UISETFONT(FIN, 'dialogTitle') displays a dialog box for the 
%   user to fill in, and applies the selected font to the input 
%   graphics object.
%
%   All the parameters are optional.
%
%   If parameter FIN is used, it must either specify a handle to a
%   font related text, uicontrol, axes object, or it must be a
%   font structure.
%
%   If FIN is a handle to an object, the font properties currently
%   assigned to this object are used to initialize the font dialog box.
%
%   If FIN is a structure, its fields must be some subset of
%   FontName, FontUnits, FontSize, FontWeight, or FontAngle, and must
%   have values appropriate for any object with font properties.
%
%   If parameter 'dialogTitle' is used, it is a string containing the 
%   title of the dialog box.
%
%   The output S is a structure.  The structure S is returned with the
%   font property names as fields.  The fields are FontName,
%   FontUnits, FontSize, FontWeight, and FontAngle.
%
%   If the user presses Cancel from the dialog box, or if any error 
%   occurs, the output value is set to 0.
%
%   Example:
%         Text1 = uicontrol('style','text','string','XxYyZz');
%         Text2 = uicontrol('style','text','string','AxBbCc',...
%                 'position', [200 20 60 20]);
%         s = uisetfont(Text1, 'Update Font');
%         if isstruct(s)           % Check for cancel
%            set(Text2, s);
%         end
%
%   See also INSPECT, LISTFONTS, PROPEDIT, UISETFONT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.14.4.3 $  $Date: 2004/04/10 23:34:38 $
%   Built-in function.


if nargout == 0
  builtin('uisetfont', varargin{:});
else
  [varargout{1:nargout}] = builtin('uisetfont', varargin{:});
end
