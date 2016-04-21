function h = uicontainer
%UICONTAINER   Uicontainer container object.
%   UICONTAINER adds a uicontainer container object to the current figure.
%   If no figure exits, one will be created. Uicontainer objects can have
%   the same child objects as figure, excepting toolbars and menus. 
%   In addition, uicontainer objects can have
%   additional instances of uicontainers as children. This allows a multiple 
%   nested tree of objects rooted at the figure.
%
%   Execute GET(H), where H is a uicontainer handle, to see a list of uicontainer
%   object properties and their current values. Execute SET(H) to see a
%   list of uicontainer object properties and legal property values.
%
%   See also UIPANEL, HGTRANSFORM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:34:30 $
%   Built-in function.
