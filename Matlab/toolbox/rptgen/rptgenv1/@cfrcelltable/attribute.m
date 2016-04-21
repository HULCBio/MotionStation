function c=attribute(c,action,varargin)
%ATTRIBUTE launches the setup file editor options page

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:05 $

c=feval(action,c,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=start(c)

%since we are using this component from the GUI,
%assume we're taking the cell table from the workspace
c.att.isArrayFromWorkspace=logical(1);

formatFrame=controlsframe(c,'Formatting Options');
headerFrame=controlsframe(c,'Header/Footer Options');

controlList={'TableTitle'
   'WorkspaceVariableName'
   'allAlign'
   'isBorder'
   'isPgwide'
   'isInverted'
   'numHeaderRows'
   'Footer'
   'ColumnWidths'
   'numFooterRows'};
c=controlsmake(c,controlList);

set(c.x.WorkspaceVariableNameTitle,'HorizontalAlignment','left');

set(c.x.numFooterRows,'enable',...
   LocOnOff(strcmp(c.att.Footer,'LASTROWS')));

formatFrame.FrameContent={{c.x.TableTitleTitle c.x.TableTitle
      c.x.allAlignTitle c.x.allAlign
      c.x.ColumnWidthsTitle c.x.ColumnWidths}
   c.x.isBorder
   c.x.isPgwide
   c.x.isInverted};

headerFrame.FrameContent={{c.x.numHeaderRowsTitle c.x.numHeaderRows}
   [3]
   c.x.Footer(1)
   c.x.Footer(2) 
   {c.x.Footer(3) c.x.numFooterRows}};

c.x.LayoutManager={c.x.WorkspaceVariableNameTitle
   {'indent' c.x.WorkspaceVariableName}
   [5]
   formatFrame
   headerFrame};

c=resize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=refresh(c);
%Update component when switching tabs, moving
%deactivating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=resize(c)

c=controlsresize(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=Update(c,whichControl,varargin);


switch whichControl
case 'WorkspaceVariableName'
   [c.att.WorkspaceVariableName,errMsg]=rptgenutil(...
      'VariableNameCheck',c.x.WorkspaceVariableName,...
      c.att.WorkspaceVariableName,logical(1));
   statbar(c,errMsg,~isempty(errMsg));
case 'Footer'
   c=controlsupdate(c,whichControl,varargin{:});
   set(c.x.numFooterRows,'enable',...
      LocOnOff(strcmp(c.att.Footer,'LASTROWS')));
otherwise
   c=controlsupdate(c,whichControl,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strOnOff=LocOnOff(logOnOff)

if logOnOff
   strOnOff='on';
else
   strOnOff='off';
end
