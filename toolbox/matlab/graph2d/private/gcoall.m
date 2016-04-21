function [h, hb] = gcoall(fig)
%GCOALL  Get Figure CurrentObject, including hidden handle objects

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 04:05:41 $

shh = get(0,'ShowHiddenHandles');
try
   if nargin==0
      fig = get(0,'CurrentFigure');
   end
   set(0,'ShowHiddenHandles','on');
   h = get(fig,'CurrentObject');
   if nargout==2
      hb = h;
   end
   % redirect to handler for grouped objects
   primaryObject = getappdata(h,'ScribeButtonDownHGObj');
   if ~isempty(primaryObject)
      h = primaryObject;
   end
   set(0,'ShowHiddenHandles',shh);
catch
   set(0,'ShowHiddenHandles',shh);
   h = [];
   if nargout==2
      hb = [];
   end
end