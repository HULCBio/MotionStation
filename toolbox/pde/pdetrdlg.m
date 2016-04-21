function pdetrdlg(action)
%PDETRDLG creates and manages the solve parameter dialog box for the
%       parabolic, hyperbolic and eigenvalue PDEs.
%
%       PDETRDLG('parabolic') gives dialog box for parabolic PDE
%       PDETRDLG('hyperbolic') gives dialog box for hyperbolic PDE
%       PDETRDLG('eigenvalue') gives dialog box for eigenvalue PDE

%       PDETRDLG is not a stand-alone function but is called from PDETOOL.

%       Magnus Ringh 12-12-94, MR 1-03-95
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:10:12 $

if nargin==0,
  action='Solve Parameters';
end

% Check if figure is already on screen
if figflag(action),
  % No need to create new dialog
  return

elseif strcmp(action,'OKCallback'),

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');

  fig=gcf;
  ud=get(fig,'UserData');
  n=length(ud);
  oldparams=getappdata(pde_fig,'timeeigparam');

  if n==1,                              % Eigenvalue range
    tmps=lower(deblank(get(ud(1),'String')));
    params=str2mat(oldparams(1:3,:),tmps,oldparams(5:6,:));
  elseif n==4,                          % Parabolic PDE params
    tmps1=lower(deblank(get(ud(1),'String')));
    tmps2=lower(deblank(get(ud(2),'String')));
    tmps3=lower(deblank(get(ud(3),'String')));
    tmps4=lower(deblank(get(ud(4),'String')));
    params=str2mat(tmps1,tmps2,oldparams(3:4,:),tmps3,tmps4);
  elseif n==5,                          % Hyperbolic PDE params
    tmps1=lower(deblank(get(ud(1),'String')));
    tmps2=lower(deblank(get(ud(2),'String')));
    tmps3=lower(deblank(get(ud(3),'String')));
    tmps4=lower(deblank(get(ud(4),'String')));
    tmps5=lower(deblank(get(ud(5),'String')));
    params=str2mat(tmps1,tmps2,tmps3,oldparams(4,:),tmps4,tmps5);
  end

  parnames=str2mat('Time','u(t0)','u''(t0)','Range','Relative tolerance',...
      'Absolute tolerance');

  if n>1,
    % parabolic and hyperbolic cases:
    ok=1;
    tmpr=eval(params(1,:),'NaN');
    if isnan(tmpr),
      ok=0;
    end
    if ~all(tmpr>=0) || ~isreal(tmpr) || ~ok,
      pdetool('error',...
        sprintf(' %s parameter must be real and  >= 0.',...
        deblank(parnames(1,:))))
      set(ud(1),'String',get(ud(1),'Tag'))
      return;
    end
    set(ud(1),'Tag',deblank(params(1,:)))
    % No check of u(0) or ut(0) parameters implemented.
    if n==4,
    % parabolic
      kk=3:4;
    elseif n==5,
    % hyperbolic
      kk=4:5;
    end
    for k=1:2,
      ok=1;
      tmpr=eval(params(k+4,:),'NaN');
      if isnan(tmpr),
        ok=0;
      end
      if numel(tmpr)~=1 || ~isreal(tmpr) || ~ok || ~all(tmpr>0),
        pdetool('error',...
          sprintf(' %s parameter must be a real positive scalar.',...
          deblank(parnames(k+4,:))))
        set(ud(kk(k)),'String',get(ud(kk(k)),'Tag'))
        return;
      end
      set(ud(kk(k)),'Tag',deblank(params(k+4,:)))
    end
  else
    % eigenvalue case:
    ok=1;
    tmpr=eval(params(4,:),'NaN');
    if isnan(tmpr),
      ok=0;
    end
    if length(tmpr)==2 && ok,
      if tmpr(2)<=tmpr(1),
        ok=0;
      end
    end
    if length(tmpr)~=2 || ~ok,
      pdetool('error',...
          sprintf(' %s parameter must a vector [rangemin, rangemax].',...
          deblank(parnames(4,:))))
      set(ud(1),'String',get(ud(1),'Tag'))
      return;
    end
    set(ud(1),'Tag',deblank(params(4,:)))
  end

  % Compare new and old parameters and type; if any change, set need_save-flag and flag5
  if all(size(params)==size(oldparams)),
    if all(params==oldparams),
      change=0;
    else
      change=1;
    end
  else
    change=1;
  end

  if change,
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(h,'UserData');
    flags(1)=1; flags(6)=0; flags(7)=1;
    set(h,'UserData',flags)
    setappdata(pde_fig,'timeeigparam',params)
  end

  delete(fig)
  drawnow

  pdeinfo

  return

end

DlgName = 'Solve Parameters';

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
set(pde_fig,'Pointer','watch')
drawnow

params=getappdata(pde_fig,'timeeigparam');

if strcmp(lower(action),'parabolic'),
  pdeinfo('Enter vector of times at which to solve PDE and initial value u(t0).')
  PromptString = str2mat('Time:','u(t0):','Relative tolerance:',...
      'Absolute tolerance:');
  params=params([1:2, 5:6],:);
elseif strcmp(lower(action),'hyperbolic'),
  pdeinfo('Enter vector of times at which to solve PDE and initial values u(t0) and u''(t0).')
  PromptString = str2mat('Time:','u(t0):','u''(t0):','Relative tolerance:',...
      'Absolute tolerance:');
  params=params([1:3, 5:6],:);
elseif strcmp(lower(action),'eigenvalue'),
  pdeinfo('Enter search range for eigenvalues as a two-element vector.')
  PromptString = 'Eigenvalue search range:';
  params=params(4,:);
else
  error('PDE:pdetrdlg:InvalidAction', 'Unknown action string ''%s''', action)
end

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
FigWH = fliplr(TextSize).*[mCharacterWidth 2*(BWH(2)+Voff)] + [0 Voff]...
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
    'IntegerHandle','off',...
    'HandleVisibility','callback',...
    'Position',Position,...
    'MenuBar','none',...
    'Colormap',zeros(1,3),...
    'Color',DefUIBgColor,...
    'Visible','off','Tag','PDESolveDlg2');

% Make the 2 frame uicontrols
UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] FigWH(2)-UIPos(4)-2*mEdgeToFrame];
uicontrol(fig,'Style','frame','Position',UIPos);

% Make the check, text, and edit uicontrol(s)
UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
ud = zeros(TextSize(1),1);

for i=1:TextSize(1),
  UIPos = UIPos - [0 BWH(2) 0 0];
  uicontrol(fig,'Style','text','String',PromptString(i,:),...
      'Position',UIPos,'HorizontalAlignment','left');
  UIPos = UIPos - [0 BWH(2)+Voff 0 0];
  ud(i)=uicontrol(fig,'Style','edit',...
      'String',deblank(params(i,:)),...
      'BackgroundColor','w','Position',UIPos,...
      'HorizontalAlignment','left','Tag',deblank(params(i,:)));
  UIPos = UIPos -[0 Voff 0 0];
end

% Make the pushbuttons
Hspace = (FigWH(1)-2*BWH(1))/3;
OKFcn = 'pdetrdlg(''OKCallback'')';
uicontrol(fig,'Style','push','String','OK','Callback',OKFcn, ...
    'Position',[Hspace mLineHeight/2 BWH]);
uicontrol(fig,'Style','push','String','Cancel',...
    'Callback','pdeinfo; delete(gcf); drawnow', ...
    'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

set(pde_fig,'Pointer','arrow')

% Finally, make all the uicontrols normalized and the figure visible
set(get(fig,'Children'),'Unit','norm');
set(fig,'Visible','on','UserData',ud)
drawnow

% end pdetrdlg

