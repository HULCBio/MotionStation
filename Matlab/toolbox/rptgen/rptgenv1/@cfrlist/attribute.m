function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:32 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)


numFrame=controlsframe(c,'Numeration Options');
formatFrame=controlsframe(c,'Formatting Options');

c.att.isSourceFromWorkspace=logical(1);

c=controlsmake(c,{'SourceVariableName',...
      'ListTitle',...
      'Spacing',...
      'ListStyle',...
      'NumerationType',...
      'NumInherit',...
      'NumContinue'});
set(c.x.SourceVariableNameTitle,...
   'HorizontalAlignment','left')

if numsubcomps(c)>0
   set(c.x.SourceVariableNameTitle,'String',...
      'Create list from subcomponents.');
   set(c.x.SourceVariableName,'Enable','off');
else
   set(c.x.SourceVariableNameTitle,'String',...
      'Create list from cell array with workspace variable name:');
   set(c.x.SourceVariableName,'Enable','on');
end


numFrame.FrameContent={...
      [5]
   {c.x.NumerationTypeTitle c.x.NumerationType}
   [5]
   c.x.NumInherit(1)
   c.x.NumInherit(2)
   [5]
   c.x.NumContinue(1)
   c.x.NumContinue(2)};

formatFrame.FrameContent={c.x.ListTitleTitle c.x.ListTitle
   [5] [5]
      c.x.SpacingTitle c.x.Spacing
      c.x.ListStyleTitle c.x.ListStyle};


c.x.LayoutManager={...
      c.x.SourceVariableNameTitle
   {'indent' c.x.SourceVariableName}
   [5]
   formatFrame
   [5]
   numFrame};

LocDisable(c);
c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

%controlsresize returns the lowest Y position
%reached by any uicontrols in c.x.lowLimit

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);

%Update callbacks are called individually from
%each uicontrol with a whichControl value of
%the attribute name.  c.att.Foo calls from 
%c.x.Foo with whichControl=='Foo'

if strcmp(whichControl,'SourceVariableName')
   [c.att.SourceVariableName,errMsg]=rptgenutil(...
      'VariableNameCheck',c.x.SourceVariableName,...
      c.att.SourceVariableName,logical(1));
   statbar(c,errMsg,~isempty(errMsg));
else
   c=controlsupdate(c,whichControl,varargin{:});
   switch whichControl
   case 'ListStyle'
      LocDisable(c);
   end
end

   
if numsubcomps(c)>0
   set(c.x.SourceVariableNameTitle,'String',...
      'Create list from subcomponents.');
   set(c.x.SourceVariableName,'Enable','off');
else
   set(c.x.SourceVariableNameTitle,'String',...
      'Create list from cell array with workspace variable name:');
   set(c.x.SourceVariableName,'Enable','on');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocDisable(c)

if strcmp(c.att.ListStyle,'OrderedList')
   numenable='on';
else
   numenable='off';
end

set([c.x.NumerationType c.x.NumInherit c.x.NumContinue],...
   'Enable',numenable);