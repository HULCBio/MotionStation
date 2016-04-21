function TabInfo = buildtab(this,TabInfo,NewContents)
%BUILDTAB  Builds Property Editor tabs from group boxes.

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:38 $

% RE: varargin contains the list of group boxes to be shown in the tab 
Tab = TabInfo.Tab;
Contents = TabInfo.Contents;
if isequal(Contents,NewContents)
   return
end

% Init
import com.mathworks.mwt.*

% Clear tab
if length(Contents)
   Tab.remove(Contents(1).Panel);
end
   
% Populate tab with new content
Ngroups = length(NewContents);
for n=1:Ngroups
   if n<Ngroups
      %---Not last element, leave 5-pixel spacing
      Panel = MWPanel(MWBorderLayout(0,5));
   else
      %---Last element, leave 0-pixel spacing
      Panel = MWPanel(MWBorderLayout(0,0));
   end
   %---Pack towards top
   Panel.add(NewContents(n).GroupBox,MWBorderLayout.NORTH);
   if n==1
      %---Add first panel to Tab
      Tab.add(Panel,MWBorderLayout.CENTER);
   else
      %---Nest other panels
      NewContents(n-1).Panel.add(Panel,MWBorderLayout.CENTER);
   end
   set(NewContents(n),'Panel',Panel);
end

% Update tab info
TabInfo.Contents = NewContents(:);
