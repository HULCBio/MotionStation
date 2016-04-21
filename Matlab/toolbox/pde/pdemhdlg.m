function pdemhdlg(action)
%PDEMHDLG creates and manages the mesh parameter dialog box.
%       PDEMHDLG is not a stand-alone function but is called from PDETOOL.

%       Magnus Ringh 11-21-94, MR 08-24-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/01 04:28:23 $

if nargin==0,
  action='Mesh Parameters';
end

% Check if figure is already on screen
if  figflag(action),
  % No need to create new dialog
  return

elseif strcmp(action,'OKCallback'),

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  fig=gcf;

  ud=get(fig,'UserData');

  tristr=get(ud(1),'String');
  trisize=str2num(tristr);
  if isempty(tristr)
    setappdata(pde_fig,'trisize',[])
  elseif ~all(size(trisize)==[1 1])
    pdetool('error',' Maximum edge size must be a scalar.')
    set(ud(1),'String',get(ud(1),'UserData'))
    return
  elseif (~isreal(trisize) || trisize<=0 || isempty(trisize))
    pdetool('error',' Maximum edge size must be a positive real number.')
    set(ud(1),'String',get(ud(1),'UserData'))
    return
  else
    setappdata(pde_fig,'trisize',trisize)
    set(ud(1),'UserData',get(ud(1),'String'))
  end

  Hgrad=str2num(get(ud(2),'String'));
  if isempty(Hgrad)
    pdetool('error',' Mesh growth rate must be a real number between 1 and 2.')
    set(ud(2),'String',get(ud(2),'UserData'))
    return
  elseif ~all(size(Hgrad)==[1 1])
    pdetool('error',' Mesh growth rate must be a scalar.')
    set(ud(2),'String',get(ud(2),'UserData'))
    return
  elseif (~isreal(Hgrad) || Hgrad<=1 || Hgrad>=2)
    pdetool('error',' Mesh growth rate must be a real number between 1 and 2.')
    set(ud(2),'String',get(ud(2),'UserData'))
    return
  else
    setappdata(pde_fig,'Hgrad',Hgrad)
    set(ud(2),'UserData',get(ud(2),'String'))
  end

  if get(ud(3),'Value'),
    jiggle='on';
  else
    jiggle='off';
  end

  mode=get(ud(4),'Value');
  if mode==1,
    jigglemode='on';
  elseif mode==2,
    jigglemode='minimum';
  elseif mode==3,
    jigglemode='mean';
  end

  str=deblank(get(ud(5),'String'));
  if isempty(str),
    jiggleiter=str;
  else
    iter=str2num(str);
    jiggleiter=int2str(iter);
    if isempty(jiggleiter),
      pdetool('error',' Entry must be a number > 0 and <= 20');
      set(ud(5),'String',get(ud(5),'UserData'))
      return;
    elseif iter<0 || iter>20
      pdetool('error',' Entry must be a number > 0 and <= 20');
      set(ud(5),'String',get(ud(5),'UserData'))
      return;
    else
      set(ud(5),'UserData',jiggleiter)
    end
  end

  setappdata(pde_fig,'jiggle',str2mat(jiggle,jigglemode,jiggleiter))

  refval=get(ud(6),'Value');
  if refval==1,
    refmet='regular';
  elseif refval==2,
    refmet='longest';
  end
  setappdata(pde_fig,'refinemethod',refmet);

  delete(fig)
  drawnow

  pdeinfo

  return

end

pdeinfo('Set options for jiggling and refinement of mesh.');

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
set(pde_fig,'Pointer','watch')
drawnow

ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

DlgName = 'Mesh Parameters';
PromptString = str2mat('Initmesh parameters','Maximum edge size:',...
    'Mesh growth rate:','Jiggle mesh','Jigglemesh parameters',...
    'Jiggle mode:','Number of jiggle iterations:','Refinement method:');
TextSize = size(PromptString);

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
numoflines=13;
FigWH = [TextSize(2) numoflines].*[mCharacterWidth BWH(2)+Voff] + [0 3*Voff]...
    +[2*(mEdgeToFrame+mFrameToText)+BWH(1)+mFrameToText mLineHeight+BWH(2)+Voff];
MinFigW = 2*(BWH(1) +mFrameToText + mEdgeToFrame);
FigWH(1) = max([FigWH(1) MinFigW]);
FigWH = min(FigWH,ScreenPos(3:4)-50);

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
    'Tag','PDEMeshDlg');

% Make the 4 frame uicontrols
UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] 2*(BWH(2)+Voff)+8*mEdgeToFrame];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] 5*(BWH(2)+Voff)+6*mEdgeToFrame];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] 6*(BWH(2)+Voff)+4*mEdgeToFrame];
uicontrol(fig,'Style','frame','Position',UIPos);

jiggleparam=getappdata(pde_fig,'jiggle');
jiggle=strcmp(deblank(jiggleparam(1,:)),'on');
jigglemode=deblank(jiggleparam(2,:));
if strcmp(jigglemode,'on'),
  popupval1=1;
elseif strcmp(jigglemode,'minimum'),
  popupval1=2;
elseif strcmp(jigglemode,'mean'),
  popupval1=3;
end
jiggleiter=deblank(jiggleparam(3,:));

editstr1=num2str(getappdata(pde_fig,'trisize'));
editstr2=num2str(getappdata(pde_fig,'Hgrad'));
popupstr=getappdata(pde_fig,'refinemethod');
if strcmp(popupstr,'regular'),
  popupval2=1;
elseif strcmp(popupstr,'longest'),
  popupval2=2;
end

% Make the check, text, and edit uicontrol(s)
UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-3*mEdgeToFrame  ...
        FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
ud = zeros(6,1);
for i=1:TextSize(1),
  UIPos = UIPos - [0 BWH(2) 0 0];
  if i==1 || i==5,
    uicontrol(fig,'Style','text','String',PromptString(i,:),...
        'Position',UIPos,'HorizontalAlignment','left');
  elseif i==2,
    uicontrol(fig,'Style','text','String',PromptString(i,:),...
        'Position',UIPos,'HorizontalAlignment','left','Tag',int2str(i));
    UIPos = UIPos -[0 BWH(2)+Voff 0 0];
    ud(1)=uicontrol(fig,'Style','edit',...
        'Backgroundcolor','w','String',editstr1,'Position',UIPos,...
        'UserData',editstr1,'HorizontalAlignment','left');
  elseif i==3,
    uicontrol(fig,'Style','text','String',PromptString(i,:),...
        'Position',UIPos,'HorizontalAlignment','left','Tag',int2str(i));
    UIPos = UIPos -[0 BWH(2)+Voff 0 0];
    ud(2)=uicontrol(fig,'Style','edit',...
        'Backgroundcolor','w','String',editstr2,'Position',UIPos,...
        'UserData',editstr2,'HorizontalAlignment','left');
  elseif i==4,
    ud(3)=uicontrol(fig,'Style','checkbox',...
        'String',PromptString(i,:),...
        'Position',UIPos,'Value',jiggle,...
        'HorizontalAlignment','left');
    UIPos = UIPos -[0 Voff+2*mEdgeToFrame 0 0];
  elseif i==6,
    uicontrol(fig,'Style','text','String',PromptString(i,:),...
        'Position',UIPos,'HorizontalAlignment','left','Tag',int2str(i));
    UIPos = UIPos -[0 BWH(2)+Voff 0 0];
    ud(4)=uicontrol(fig,'Style','popup',...
        'String','on|optimize minimum|optimize mean','Value',popupval1,...
        'Position',UIPos,'HorizontalAlignment','left');
  elseif i==7,
    uicontrol(fig,'Style','text','String',PromptString(i,:),...
        'Position',UIPos,'HorizontalAlignment','left','Tag',int2str(i));
    UIPos = UIPos -[0 BWH(2)+Voff 0 0];
    ud(5)=uicontrol(fig,'Style','edit',...
        'Backgroundcolor','w','String',jiggleiter,'Position',UIPos,...
        'UserData',jiggleiter,'HorizontalAlignment','left');
  elseif i==8,
    UIPos = UIPos -[0 Voff+2*mEdgeToFrame 0 0];
    uicontrol(fig,'Style','text','String',PromptString(i,:),...
        'Position',UIPos,'HorizontalAlignment','left','Tag',int2str(i));
    UIPos = UIPos -[0 BWH(2)+Voff 0 0];
    ud(6)=uicontrol(fig,'Style','popup',...
        'String','regular|longest','Value',popupval2,...
        'Position',UIPos,'HorizontalAlignment','left');
  end
  UIPos = UIPos -[0 Voff 0 0];
end

% Make the pushbuttons
Hspace = (FigWH(1)-2*BWH(1))/3;
OKFcn = 'pdemhdlg(''OKCallback'')';
uicontrol(fig,'Style','push','String','OK','Callback',OKFcn, ...
    'Position',[Hspace mLineHeight/2 BWH]);
uicontrol(fig,'Style','push','String','Cancel',...
    'Callback','pdeinfo; delete(gcf); drawnow',...
    'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

% Finally, make all the uicontrols normalized and the figure visible
set(pde_fig,'Pointer','arrow')
set(get(fig,'Children'),'Unit','norm');
set(fig,'Visible','on','UserData',ud)
drawnow

% end pdemhdlg

