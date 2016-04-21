function bH=layoutbarht(p)
%LAYOUTBARHT returns the height (in points) for a single line uicontrol
%   BARHT=LAYOUTBARHT(RPTPARENT)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:18 $

persistent RPTGEN_LAYOUT_UICONTROL_BARHT

if isempty(RPTGEN_LAYOUT_UICONTROL_BARHT)
   %create a temporary uicontrol in the invisible clipboard
   clip=rptsp('clipboard');
   h=uicontrol('Parent',clip.h,...
      'Units','points',...
      'String','ABCDEFGHIJKLMNOPQRSTUVWXYZ');
   ext=get(h,'Extent');
   
   RPTGEN_LAYOUT_UICONTROL_BARHT=ext(4)*1.2;
   %allow for 10% padding on both sides of the text
   
   delete(h);
end

bH=RPTGEN_LAYOUT_UICONTROL_BARHT;