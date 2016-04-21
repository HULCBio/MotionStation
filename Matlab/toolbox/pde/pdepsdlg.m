function pdepsdlg(action,flag)
%PDEPSDLG Creates and manages the Paste...dialog box.
%       PDESPDLG is not stand-alone but is called from PDETOOL

%       Magnus Ringh 11-17-94, MR 8-17-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/18 03:11:44 $

if nargin==0,
  action='Paste';
end

% Check if figure is already on screen
if  figflag(action),
  % No need to create new dialog
  return

elseif strcmp(action,'EditCallback'),
  % Check to make sure spacings are admissible
  Edit = gco;
  EditStr = get(Edit,'String');
  ok=1;
  num=str2num(EditStr);
  if isempty(num),
    error_str='Entry must be a number';
    ok=0;
  end
  [n,m]=size(num);
  if n*m>1,
    error_str='Entry must be a scalar';
    ok=0;
  end
  if flag==3,
    % check no of repetitions
    if num<0
      error_str='Entry must be a positive integer';
      ok=0;
    elseif (num-fix(num))>100*eps,
      error_str='Entry must be an integer number';
      ok=0;
    end
  end
  if ~ok,
    pdetool('error',error_str);
    set(Edit,'String',get(Edit,'UserData'))
  end
  return

elseif strcmp(action,'OKCallback'),

  pde_circ=1; pde_poly=2; pde_rect=3; pde_ellip=4;

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

  ud=get(gcf,'UserData');
  xdisp=str2num(get(ud(1),'String'));
  ydisp=str2num(get(ud(2),'String'));
  mult=round(str2num(get(ud(3),'String')));

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  pdegd=get(h,'UserData');
  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  clipboard=get(findobj(get(edithndl,'Children'),'flat','Tag','PDECut'),...
      'UserData');

  % return to main PDE Toolbox figure:
  delete(gcf)
  drawnow
  set(0,'CurrentFigure',pde_fig)

  set(pde_fig,'Pointer','watch');
  drawnow

  % Alter clipboard contents according to dialog box contents:
  [m,n]=size(clipboard);
  pd=zeros(m,mult*n);
  start=size(pdegd,2);

  evalhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
  evalstr=get(evalhndl,'String');

  for i=1:mult,
    for j=1:n
      type=clipboard(1,j);
      pd(:,(i-1)*n+j)=clipboard(:,j);
      if type==pde_rect
        small=100*eps*(min(diff(get(ax,'Xlim')),diff(get(ax,'Ylim'))));
        if (abs(abs(diff(pd(3:4,j)))-abs(diff(pd([7 9]))))<small),
          % square
          label='SQ1';
          k=1;
          while pdeisusd(label),
            k=k+1;
            label=['SQ', int2str(k)];
          end
        else
          % rectangle
          label='R1';
          k=1;
          while pdeisusd(label),
            k=k+1;
            label=['R', int2str(k)];
          end
        end
        pd(3:6,(i-1)*n+j)=...
            pd(3:6,(i-1)*n+j)+i*xdisp;
        pd(7:10,(i-1)*n+j)=...
            pd(7:10,(i-1)*n+j)+i*ydisp;
      elseif type==pde_poly
        label='P1';
        k=1;
        while pdeisusd(label),
          k=k+1;
          label=['P', int2str(k)];
        end
        nn=clipboard(2,j);
        pd(3:3+nn-1,(i-1)*n+j)=...
            pd(3:3+nn-1,(i-1)*n+j)+i*xdisp;
        pd(3+nn:3+2*nn-1,(i-1)*n+j)=...
            pd(3+nn:3+2*nn-1,(i-1)*n+j)+i*ydisp;
      elseif type==pde_circ
        label='C1';
        k=1;
        while pdeisusd(label),
          k=k+1;
          label=['C', int2str(k)];
        end
        ctr=clipboard(2:3,j);
        pd(2:3,(i-1)*n+j)=...
            [ctr(1)+i*xdisp ctr(2)+i*ydisp]';
      elseif type==pde_ellip
        label='E1';
        k=1;
        while pdeisusd(label),
          k=k+1;
          label=['E', int2str(k)];
        end
        ctr=clipboard(2:3,j);
        pd(2:3,(i-1)*n+j)=...
            [ctr(1)+i*xdisp ctr(2)+i*ydisp]';
      end
      pdesetlb(label,start+(i-1)*n+j)
    end
  end

  if isempty(pdegd),
    pdegd=pd;
    l=0; n=size(pd,2);
  else
    l=size(pdegd,2);
    [m,n]=size(pd);
    pdegd(1:m,l+1:l+n)=pd;
  end

  stat=csgchk(pdegd);
  err=0;
  if any(stat==2),
    set(evalhndl,'String',evalstr)
    pdetool('error','  Objects must be unique.')
    set(pde_fig,'Pointer','arrow');
    drawnow
    return;
  end

  set(h,'UserData',pdegd);

  % First call DECSG to decompose geometry;

  [dl1,bt1,pdedl,bt,msb]=decsg(pdegd);

  pdepatch(pdedl,bt,msb);
  set(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEBoundMenu'),'UserData',pdedl);

  setappdata(pde_fig,'dl1',dl1)
  setappdata(pde_fig,'bt1',bt1)

  set(pde_fig,'Pointer','arrow');
  drawnow

  pdeframe(pdegd,l+1:l+n)

  h=[];
  for i=l+1:l+n,
    h=[h; findobj(get(ax,'Children'),'flat',...
            'Tag','PDELabel','UserData',i)];
  end
  set(h,'Tag','PDELblSel');

  hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEClear');
  drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
  hndl=[hndl; findobj(get(drawhndl,'Children'),'flat','Tag','PDEExpGD')];
  set(hndl,'Enable','on');

  pdeinfo

  return

end

pdeinfo('Paste clipboard contents. X- and y-axis displacements can be applied repeatedly.',0)

DlgName = 'Paste';
PromptString = str2mat('X-axis displacement:',...
    'Y-axis displacement:','Number of repeats:');

EditStr=str2mat('0','0','1');
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
FigWH = fliplr(TextSize).*[mCharacterWidth 2*(BWH(2)+Voff)] ...
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
    'Visible','off');

% Make the 2 frame uicontrols
UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
uicontrol(fig,'Style','frame','Position',UIPos);
UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] FigWH(2)-UIPos(4)-2*mEdgeToFrame];
uicontrol(fig,'Style','frame','Position',UIPos);

% Make the text, and edit check uicontrol(s)
UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
        FigWH(1)-2*mEdgeToFrame-2*mFrameToText mLineHeight];
ud = zeros(TextSize(1),1);
for i=1:TextSize(1),
  UIPos = UIPos - [0 BWH(2) 0 0];
  uicontrol(fig,'Style','text','String',PromptString(i,:),...
      'Position',UIPos,'HorizontalAlignment','left');
  UIPos = UIPos - [0 BWH(2)+Voff 0 0];
  ud(i) = uicontrol(fig,'Style','edit','String',EditStr(i,:),...
      'BackgroundColor','white','Position',UIPos,...
      'HorizontalAlignment','left','UserData',EditStr(i,:),...
      'Callback',sprintf('pdepsdlg(''EditCallback'',%i)',i));
  UIPos = UIPos -[0 Voff 0 0];
end

% Make the pushbuttons
Hspace = (FigWH(1)-2*BWH(1))/3;
OKFcn = 'pdepsdlg(''OKCallback'')';
uicontrol(fig,'Style','push','String','OK','Callback',OKFcn, ...
    'Position',[Hspace mLineHeight/2 BWH]);
uicontrol(fig,'Style','push','String','Cancel',...
    'Callback','pdeinfo; delete(gcf); drawnow', ...
    'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

% Finally, make all the uicontrols normalized and the figure visible
set(get(fig,'Children'),'Unit','norm');
set(fig,'Visible','on','UserData',ud)
drawnow

% end pdepsdlg

