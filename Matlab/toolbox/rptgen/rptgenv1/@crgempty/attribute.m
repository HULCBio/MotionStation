function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:10 $

switch lower(action)
case 'start'
   c=LocStartGUI(c);
case 'resize'
   c=LocResize(c);
case 'refresh'
   c=refresh(c);
otherwise
   %nothing much...
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocStartGUI(c)

%dstring='This component acts as an empty container';

if isempty(c.att.DescString)
   helpString=help('crgempty');
else
   helpString={
      sprintf('Error while loading "%s"', c.att.DescString );
      '  This component appears in the setup file outline'
      '  because there was an error loading a component '
      sprintf('  of type "%s".  Errors sometimes occur',c.att.DescString)
      '  when loading components that have been manually'
      '  edited or when loading a setup file from an older'
      '  version of the Report Generator.'
      ''
      '  To correct this problem, replace this placeholder '
      '  component with the desired component from the '
      '  "Add Components" list.'
   };
end   

c.x.desc=uicontrol(c.x.all,...
   'HorizontalAlignment','left',...
   'style','text',...
   'String',helpString);

c=LocResize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=LocResize(c)

pad=10;
%set(c.x.desc,'Position',[c.x.xzero+pad c.x.yorig+pad...
%      c.x.xext-c.x.xzero-2*pad c.x.ylim-c.x.yorig-2*pad]);

set(c.x.desc,'Position',normalized(c,[0 0 1 1]));
