function h = uipanel
%UIPANEL   Uipanel container object.
%   UIPANEL adds a uipanel container object to the current figure.
%   If no figure exits, one will be created. Uipanel objects can have
%   the same child objects as figure, excepting toolbars and menus. 
%   In addition, uipanel objects can have
%   additional instances of uipanels as children. This allows a multiple 
%   nested tree of objects rooted at the figure.
%
%   Uipanels have properties to control the appearance of borders
%   and titles.
%
%   Execute GET(H), where H is a uipanel handle, to see a list of uipanel
%   object properties and their current values. Execute SET(H) to see a
%   list of uipanel object properties and legal property values.
%
%   See also UICONTAINER, HGTRANSFORM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:34:35 $
%   Built-in function.
