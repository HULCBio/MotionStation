function pdesldlg(action)
%PDESLDLG Creates and manages the solve parameter dialog box.
%       PDESLDLG is not a stand-alone function but is called from PDETOOL.

%       Magnus Ringh 12-12-94, MR 11-02-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/18 03:11:58 $

if nargin==0,
  action='Solve Parameters';
end

% Check if figure is already on screen
if  figflag(action),
  % No need to create new dialog
  return

elseif strcmp(action,'OKCallback'),

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');

  fig=gcf;
  ud=get(fig,'UserData');

  oldparam=getappdata(pde_fig,'solveparam');
  solveparams=int2str(get(ud(1),'Value'));
  parnames=str2mat('Adaptive mode',...
    'Maximum number of triangles','Maximum number of refinements',...
    'Triangle selection method','Function parameter','Refinement method',...
    'Use nonlinear solver','Nonlinear tolerance','Initial solution',...
    'Jacobian','Norm');

  % Check the entered values before saving them:
  for i=2:11,
    tmps=lower(deblank(get(ud(i),'String')));
    if i<4 || i==8,
      tmpr=str2num(tmps);
      if (~isreal(tmpr) || tmpr<0 || numel(tmpr)>1)
        if i==8
          pdetool('error',...
              sprintf(' %s parameter must be a positive real scalar.',...
              deblank(parnames(i,:))))
        else
          pdetool('error',...
              sprintf(' %s parameter must be a positive integer scalar.',...
              deblank(parnames(i,:))))
        end
        set(ud(i),'String',get(ud(i),'UserData'))
        return;
      end
      if (tmpr-fix(tmpr)>100*eps && (i==2 || i==3))
        pdetool('error',...
            sprintf(' %s parameter must be a positive integer.',...
            deblank(parnames(i,:))))
        set(ud(i),'String',get(ud(i),'UserData'))
        return;
      end
      if isempty(tmpr)
        pdetool('error',...
            sprintf(' Unable to evaluate %s parameter value.',...
            deblank(parnames(i,:))))
        set(ud(i),'String',get(ud(i),'UserData'))
        return;
      end
      set(ud(i),'UserData',tmps)
    elseif i==4,
      if get(ud(21),'Value')==1,
        tmps='pdeadworst';
      elseif get(ud(22),'Value')==1,
        tmps='pdeadgsc';
      elseif get(ud(23),'Value')==1,
        tmps=deblank(lower(get(ud(i),'String')));
        if isempty(tmps),
          pdetool('error',...
            sprintf(' Enter triangle selection function name.'))
            return;
        elseif exist(tmps)<2,
          pdetool('error',...
            sprintf(' Unable to locate the triangle selection function %s.',...
              tmps))
          set(ud(i),'String',get(ud(i),'UserData'))
          return;
        end
        set(ud(i),'UserData',tmps)
      end
    elseif i==5,
      tmpr=str2num(tmps);
      if (~isreal(tmpr) || tmpr<0)
        pdetool('error',...
            sprintf(' %s parameter must be real and  > 0.',...
            deblank(parnames(i,:))))
        set(ud(i),'String',get(ud(i),'UserData'))
        return;
      end
      if isempty(tmpr)
        pdetool('error',...
            sprintf(' Unable to evaluate %s parameter value.',...
            deblank(parnames(i,:))))
        set(ud(i),'String',get(ud(i),'UserData'))
        return;
      end
      set(ud(i),'UserData',tmps)
      if get(ud(21),'Value')==1,
        if tmpr>=1,
          pdetool('error',...
            sprintf(' Worst triangle fraction must be < 1.'))
          set(ud(i),'String',get(ud(i),'UserData'))
          return;
        end
      end
    elseif i==6,
      if get(ud(i),'Value')==1,
        tmps='regular';
      elseif get(ud(i),'Value')==2,
        tmps='longest';
      end
    elseif i==10,
      if get(ud(i),'Value')==1,
        tmps='fixed';
      elseif get(ud(i),'Value')==2,
        tmps='lumped';
      elseif get(ud(i),'Value')==3,
        tmps='full';
      end
    elseif i==11,
      if ~strcmp(tmps,'energy'),
        tmpr=str2num(tmps);
        if isempty(tmpr) || ~isreal(tmpr) || numel(tmpr)>1,
          pdetool('error',...
            sprintf(' %s parameter must be a real scalar or ''energy''.',...
            deblank(parnames(i,:))))
          set(ud(i),'String',get(ud(i),'UserData'))
          return;
        end
      end
    end

    if i==7,
      solveparams=str2mat(solveparams,int2str(get(ud(7),'Value')));
    else
      solveparams=str2mat(solveparams,tmps);
    end
  end

  % Compare new and old parameters and type; if any change, set flag5 and
  % need_save-flag
  if all(size(solveparams)==size(oldparam)),
    if all(solveparams==oldparam),
      change=0;
    else
      change=1;
    end
  else
    change=1;
  end

  if change,
    setappdata(pde_fig,'solveparam',solveparams)
    flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(flg_hndl,'UserData');
    flags(1)=1; flags(7)=1;     % need_save=1, flag5=1
    set(flg_hndl,'UserData',flags)
  end

  delete(fig)
  drawnow

  pdeinfo

  return

elseif strcmp(action,'check_cb'),

  fig=gcf;
  ud=get(fig,'UserData');

  if get(ud(1),'Value')==1,
    set(ud(2:6),'Enable','on');
    set(ud(12:16),'Enable','on');
    set(ud(21:23),'Enable','on');
  elseif get(ud(1),'Value')==0,
    set(ud(2:6),'Enable','off');
    set(ud(12:16),'Enable','off');
    set(ud(21:23),'Enable','off');
  end

  if get(ud(7),'Value')==1,
    set(ud(8:11),'Enable','on');
    set(ud(17:20),'Enable','on');
  elseif get(ud(7),'Value')==0,
    set(ud(8:11),'Enable','off');
    set(ud(17:20),'Enable','off');
  end

  return

elseif strcmp(action,'radio_cb'),

  fig=gcf;
  ud=get(fig,'UserData');

  if get(ud(21),'Value')==1,
    set(ud(15),'String','Worst triangle fraction:');
    set(ud(5),'String','0.5');
  elseif get(ud(22),'Value')==1,
    set(ud(15),'String','Relative tolerance:');
    set(ud(5),'String','1E-3');
  elseif get(ud(23),'Value')==1,
    set(ud(15),'String','Function parameter:');
    set(ud(5),'String','1');
  end

  return

end

pdeinfo('Check adaptive mode for adaptive mesh refinement. Check nonlinear solver for nonlinear problems.')

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
set(pde_fig,'Pointer','watch');
drawnow

solveparams=getappdata(pde_fig,'solveparam');

DlgName = 'Solve Parameters';
PromptString = str2mat('Adaptive mode',...
  'Maximum number of triangles:','Maximum number of refinements:',...
  'Triangle selection method:','Worst triangle fraction:',...
  'Refinement method:','Use nonlinear solver','Nonlinear tolerance:');
PromptString=str2mat(PromptString,'Initial solution:','Jacobian:','Norm:');

% Get layout parameters
layout
mLineHeight = mLineHeight+8;
BWH = [mStdButtonWidth mStdButtonHeight+3];

% Define default position
ScreenUnits = get(0,'Units');
set(0,'Unit','pixels');
ScreenPos = get(0,'ScreenSize');
% Check for small screens - need to adjust the dialog box size
if (ScreenPos(3) <= 800) || (ScreenPos(4) <= 600),
 BWH(2)=BWH(2)-3;
end
set(0,'Unit',ScreenUnits);

mCharacterWidth = 7;
Voff = 5;
numoflines=15;
FigWH = [40*mCharacterWidth numoflines*(BWH(2)+Voff)] ...
        +[2*(2*mEdgeToFrame+2*mFrameToText+BWH(1)) ...
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
    'DefaultUIControlHorizontalAlignment','left',...
    'Tag','PDESolveDlg');

% Make the 3 frame uicontrols
UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
uicontrol(fig,'Style','frame','Position',UIPos);
rem=FigWH(2)-UIPos(4)-4*mEdgeToFrame;
UIPos = [UIPos(1:2)+[0 UIPos(4)+mEdgeToFrame] FigWH(1)/2-2*mEdgeToFrame rem];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[FigWH(1)/2 0 0] rem];
uicontrol(fig,'Style','frame','Position',UIPos);

% Make the check, text, radio, and edit uicontrol(s)
UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];

ud=zeros(11,1);
udt=zeros(9,1);

val=str2num(solveparams(1,:));
if val,
  enbl='on';
else
  enbl='off';
end
val2=str2num(solveparams(7,:));
if val2,
  enbl2='on';
else
  enbl2='off';
end

popupstr=deblank(solveparams(6,:));
if strcmp(popupstr,'regular'),
  popupval=1;
elseif strcmp(popupstr,'longest'),
  popupval=2;
end
popupstr=deblank(solveparams(10,:));
if strcmp(popupstr,'fixed'),
  popupval2=1;
elseif strcmp(popupstr,'lumped'),
  popupval2=2;
elseif strcmp(popupstr,'full'),
  popupval2=3;
end

UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)/2-2*mEdgeToFrame-2*mFrameToText mLineHeight];
UIlength=UIPos(3);

UIPos = UIPos - [0 BWH(2)+mEdgeToFrame 0 0];
UIPos(3)=UIlength-8*mCharacterWidth;
ud(1)=uicontrol(fig,'Style','check','String',PromptString(1,:),...
  'Value',val,'Position',UIPos,...
  'Callback','pdesldlg(''check_cb'')');
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength;
udt(1)=uicontrol(fig,'Style','text','String',...
  PromptString(2,:),'Position',UIPos,...
  'Enable',enbl);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength-8*mCharacterWidth;
ud(2)=uicontrol(fig,'Style','edit',...
  'String',deblank(solveparams(2,:)),...
  'UserData',deblank(solveparams(2,:)),...
  'Enable',enbl,'BackgroundColor','w','Position',UIPos);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength;
udt(2)=uicontrol(fig,'Style','text','String',...
  PromptString(3,:),'Position',UIPos,...
  'Enable',enbl);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength-8*mCharacterWidth;
ud(3)=uicontrol(fig,'Style','edit',...
  'String',deblank(solveparams(3,:)),...
  'UserData',deblank(solveparams(3,:)),...
  'Enable',enbl,'BackgroundColor','w','Position',UIPos);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength;
udt(3)=uicontrol(fig,'Style','text','String',...
  PromptString(4,:),'Position',UIPos,...
  'Enable',enbl);
UIPos = UIPos - [0 Voff 0 0];
UIPos(3)=UIlength-8*mCharacterWidth;
udr=zeros(3,1);
call=['me=gco;','if(get(me,''Value'')==1),',...
  'set(get(me,''UserData''),''Value'',0),',...
  'else,',...
  'set(me,''Value'',1),',...
  'end; clear me;'];
RadioPromptStr=str2mat('Worst triangles','Relative tolerance',...
    'User-defined function:');
for i=1:3,
  UIPos = UIPos - [0 BWH(2) 0 0];
  udr(i)=uicontrol(fig,'Style','Radio',...
    'Enable',enbl,'HorizontalAlignment','left',...
    'Position',UIPos,'String',RadioPromptStr(i,:));
  UIPos = UIPos - [0 Voff 0 0];
end
for i=1:3,
  set(udr(i),'CallBack',[call, 'pdesldlg radio_cb'],...
  'UserData',udr([1:(i-1),(i+1):3]));
end
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength-8*mCharacterWidth;
ud(4)=uicontrol(fig,'Style','edit',...
  'Enable',enbl,'BackgroundColor','w','Position',UIPos);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength;
udt(4)=uicontrol(fig,'Style','text','String',...
  PromptString(5,:),'Position',UIPos,...
  'Enable',enbl);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength-8*mCharacterWidth;
ud(5)=uicontrol(fig,'Style','edit',...
  'String',deblank(solveparams(5,:)),...
  'UserData',deblank(solveparams(5,:)),...
  'Enable',enbl,'BackgroundColor','w','Position',UIPos);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength;
udt(5)=uicontrol(fig,'Style','text','String',...
  PromptString(6,:),'Position',UIPos,...
  'Enable',enbl);
UIPos = UIPos - [0 BWH(2)+Voff 0 0];
UIPos(3)=UIlength-8*mCharacterWidth;
ud(6)=uicontrol(fig,'Style','popup',...
  'String','regular|longest','Value',popupval,...
  'Enable',enbl,'Position',UIPos);

UIPos = [FigWH(1)/2+(mEdgeToFrame+mFrameToText) ...
         FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)/2-2*mEdgeToFrame-2*mFrameToText mLineHeight];

if strcmp(deblank(solveparams(4,:)),'pdeadworst'),
  set(udr(1),'Value',1)
  set(udt(4),'String','Worst triangle fraction:')
elseif strcmp(deblank(solveparams(4,:)),'pdeadgsc'),
  set(udr(2),'Value',1)
  set(udt(4),'String','Relative tolerance:')
else
  set(udr(3),'Value',1)
  set(udt(4),'String','Function parameter:')
  set(ud(4),'String',deblank(solveparams(4,:)),...
  'UserData',deblank(solveparams(4,:)))
end

for i=7:11,
  UIPos = UIPos - [0 BWH(2)+mEdgeToFrame 0 0];
  if i==7,
    UIPos(3)=UIlength-8*mCharacterWidth;
    ud(i)=uicontrol(fig,'Style','check','String',PromptString(i,:),...
        'Value',val2,'Position',UIPos,...
        'Callback','pdesldlg(''check_cb'')');
  elseif i==10,
    UIPos(3)=UIlength;
    udt(i-2)=uicontrol(fig,'Style','text','String',...
      PromptString(i,:),'Position',UIPos,...
        'Enable',enbl2);
    UIPos = UIPos - [0 BWH(2)+Voff 0 0];
    UIPos(3)=UIlength-8*mCharacterWidth;
    ud(i)=uicontrol(fig,'Style','popup',...
      'String','fixed|lumped|full','Value',popupval2,...
      'Enable',enbl2,'Position',UIPos);
  else
    UIPos(3)=UIlength;
    udt(i-2)=uicontrol(fig,'Style','text','String',...
      PromptString(i,:),'Position',UIPos,...
      'Enable',enbl2);
    UIPos = UIPos - [0 BWH(2)+Voff 0 0];
    UIPos(3)=UIlength-8*mCharacterWidth;
    ud(i)=uicontrol(fig,'Style','edit',...
      'String',deblank(solveparams(i,:)),...
      'Enable',enbl2,'BackgroundColor','w','Position',UIPos,...
      'UserData',deblank(solveparams(i,:)));
  end
  UIPos = UIPos - [0 Voff 0 0];
end

% Make the pushbuttons
Hspace = (FigWH(1)-2*BWH(1))/3;
OKFcn = 'pdesldlg(''OKCallback'')';
uicontrol(fig,'Style','push','String','OK','Callback',OKFcn, ...
    'HorizontalAlignment','center','Position',[Hspace mLineHeight/2 BWH]);
uicontrol(fig,'Style','push','String','Cancel',...
    'Callback','pdeinfo; delete(gcf); drawnow',...
    'HorizontalAlignment','center',...
    'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

set(pde_fig,'Pointer','arrow')
% Finally, make all the uicontrols normalized and the figure visible
set(get(fig,'Children'),'Unit','norm');
set(fig,'Visible','on','UserData',[ud; udt; udr])
drawnow

% end pdesldlg

