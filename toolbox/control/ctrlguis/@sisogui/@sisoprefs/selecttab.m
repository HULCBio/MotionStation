function h = selecttab(h,tab)
%SELECTTAB  Switch 'h.EditorFrame' to tab number 'tab'

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:07:02 $

if ~isempty(h.EditorFrame)
  s = get(h.EditorFrame,'UserData');
  tab = max(1,min(tab,3))-1;
  s.TabPanel.selectPanel(tab);
end
