function pdemvdlg(action)
%PDEMVLG Manages the PDE movie options dialog box for
%        the PDE Toolbox.
%
%       PDEMVDLG(ACTION).
%
%       Called from PDEPTDLG when clicking on the
%       'Options...'-button for animation of the solution.
%
%       See also: PDEPTDLG

%       Magnus Ringh 7-19-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/01 04:28:24 $

if nargin==0,
  action='Animation Options';
end

% Check if figure is already on screen
if  figflag(action),
  % No need to create new dialog
  return

elseif strcmp(action,'OKCallback'),

  fig=gcf;
  ud=get(fig,'UserData');

  % First, check validity of animation rate and no of repeats, if applicable:
  ratestr=get(ud(1),'String');
  repeatstr=get(ud(2),'String');
  fps=str2num(ratestr);
  repeats=str2num(repeatstr);
  if isempty(fps),
    err=1;
  elseif fps<0 || (fps-fix(fps))>100*eps,
    err=1;
  else
    err=0;
  end
  if err,
    set(ud(1),'String',get(ud(1),'UserData'))
    pdetool('error',...
      'Rate (frames/second) must be a positive integer')
    return;
  end
  if isempty(repeats),
    err=1;
  elseif repeats<0 || (repeats-fix(repeats))>100*eps,
    err=1;
  else
    err=0;
  end
  if err,
    set(ud(2),'String',get(ud(2),'UserData'))
    pdetool('error',...
      'Number of movie repeats must be a positive integer')
    return;
  end

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  setappdata(pde_fig,'animparam',[fps,repeats,get(ud(3),'Value')]);

  delete(fig)
  drawnow

  pdeinfo

  return

end

pdeinfo('Options for animation of PDE solution.',0)

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
set(pde_fig,'Pointer','watch');
drawnow

animparams=getappdata(pde_fig,'animparam');

DlgName = 'Animation Options';
PromptString = str2mat('Animation rate (fps):',...
  'Number of repeats:','Replay movie');

% Get layout parameters
layout
mLineHeight = mLineHeight+8;
BWH = [mStdButtonWidth mStdButtonHeight+3];

% Define default position
ScreenUnits = get(0,'Units');
set(0,'Unit','pixels');
ScreenPos = get(0,'ScreenSize');
set(0,'Unit',ScreenUnits);

mCharacterWidth = 7;
Voff = 5;
numoflines=6;
FigWH = [12*mCharacterWidth numoflines*(BWH(2)+Voff)] ...
        +[(2*mEdgeToFrame+2*mFrameToText+BWH(1)) ...
        mLineHeight+BWH(2)+4*mEdgeToFrame];
Position = [(ScreenPos(3:4)-FigWH)/2 FigWH];

% Make the figure
DefUIBgColor = get(0,'DefaultUIControlBackgroundColor');
fig = figure('NumberTitle','off',...
    'Name',DlgName,...
    'Units','pixels',...
    'Position',Position,...
    'IntegerHandle','off',...
    'HandleVisibility','callback',...
    'MenuBar','none',...
    'Colormap',zeros(1,3),...
    'Color',DefUIBgColor,...
    'Visible','off',...
    'DefaultUIControlHorizontalAlignment','left');

% Make the 2 frame uicontrols
UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
uicontrol(fig,'Style','frame','Position',UIPos);
rem=FigWH(2)-UIPos(4)-4*mEdgeToFrame;
UIPos = [UIPos(1:2)+[0 UIPos(4)+mEdgeToFrame] FigWH(1)-2*mEdgeToFrame rem];
uicontrol(fig,'Style','frame','Position',UIPos);

% Make the check, text, and edit uicontrol(s)
UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];

UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
UIlength=UIPos(3);

UIPos = UIPos - [0 BWH(2)+mEdgeToFrame 0 0];
UIPos(3)=UIlength-2*mCharacterWidth;
uicontrol(fig,'Style','text',...
  'String',PromptString(1,:),...
  'Position',UIPos);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength-2*mCharacterWidth;
ud(1)=uicontrol(fig,'Style','edit',...
  'String',num2str(animparams(1)),...
  'UserData',num2str(animparams(1)),...
  'BackgroundColor','w','Position',UIPos);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength;
uicontrol(fig,'Style','text',...
  'String',PromptString(2,:),...
  'Position',UIPos);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength-2*mCharacterWidth;
ud(2)=uicontrol(fig,'Style','edit',...
  'String',num2str(animparams(2)),...
  'UserData',num2str(animparams(2)),...
  'BackgroundColor','w','Position',UIPos);
UIPos = UIPos - [0 BWH(2)+3*Voff 0 0];
UIPos(3)=UIlength;
UIPos(3)=UIlength-2*mCharacterWidth;
M=getappdata(pde_fig,'movie');
if ~isempty(M)
  enbl='on';
  val=animparams(3);
else
  enbl='off';
  val=0;
end
ud(3)=uicontrol(fig,'Style','checkbox',...
  'String',PromptString(3,:),'Value',val,...
  'Enable',enbl,'Position',UIPos);

% Make the pushbuttons
Hspace = (FigWH(1)-2*BWH(1))/3;
OKFcn = 'pdemvdlg(''OKCallback'')';
uicontrol(fig,'Style','push','String','OK','Callback',OKFcn, ...
    'HorizontalAlignment','center','Position',[Hspace mLineHeight/2 BWH]);
uicontrol(fig,'Style','push','String','Cancel',...
    'Callback','pdeinfo; delete(gcf); drawnow',...
    'HorizontalAlignment','center',...
    'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

set(pde_fig,'Pointer','arrow')
% Finally, make all the uicontrols normalized and the figure visible
set(get(fig,'Children'),'Unit','norm');
set(fig,'Visible','on','UserData',ud)
drawnow

% end pdemvdlg

