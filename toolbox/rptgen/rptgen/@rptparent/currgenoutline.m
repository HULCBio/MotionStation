function h=currgenoutline(p,h)
%CURRGENOUTLINE returns handle of currently generating outline listbox
%   H=CURRGENOUTLINE(RPTPARENT)
%     returns the handle of the currently generating outline listbox
%     returns -1 if there is not currently generating outline listbox
%   CURRGENOUTLINE(RPTPARENT,H)
%     forces uicontrol H to be the currently generating outline listbox
% 

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:13 $

olTag='RpTgEn&CuRrEnTlY!GeNeRaTiNg*OuTlInE~UiCoNtRoL';

if nargin>1
   allOutlines=findall(allchild(0),'style','listbox','tag',olTag);
   if ~isempty(allOutlines)
      set(allOutlines,'tag','OutlineListbox');
   end
   set(h,'style','listbox','tag',olTag);
else
   allOutlines=findall(allchild(0),'style','listbox','tag',olTag);
   if length(allOutlines)>0
      h=allOutlines(1);
   else
      h=-1;
   end
end