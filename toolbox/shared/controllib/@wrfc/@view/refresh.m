function refresh(this, Mask)
%REFRESH  Adjusts visibility of low-level HG objects.
%
%  REFRESH(VIEW,MASK) adjusts the visibility of VIEW's HG 
%  objects taking into account external factors such as 
%    * data visibility and axes grouping (see REFRESHMASK)
%    * visibility of @dataview parent
%  These external factors are summarized by MASK. 
%  
%  REFRESH does not alter the VIEW's Visible state.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:39 $

% RE: MASK is a logical array of the same size as the axes grid
gobj = ghandles(this);
Mask = Mask(:);
if any(Mask) & strcmp(this.Visible, 'on')
   nax = length(Mask);
   if nax==1
      set(gobj(ishandle(gobj)), 'Visible', 'on')
   else
      gobj = reshape(gobj,[nax prod(size(gobj))/nax]);
      VisibleObj = gobj(Mask,:);
      set(VisibleObj(ishandle(VisibleObj)),'Visible','on')
      HiddenObj = gobj(~Mask,:);
      set(HiddenObj(ishandle(HiddenObj)),'Visible','off')
   end
else
   set(gobj(ishandle(gobj)), 'Visible', 'off')
end
