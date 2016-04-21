function boo = isVisible(h)
%ISVISIBLE  Returns 1 if editor is visible.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 05:06:52 $

if isempty(h.Handles)
  % UI does not exist yet
  boo = 0;
else
  boo = strcmp(get(h.Handles.Frame, 'Visible'), 'on');
end
