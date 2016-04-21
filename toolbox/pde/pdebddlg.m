function pdebddlg(action,flag,scalarflag,typerange,equmtx,entrymtx,descrmtx)
%PDEBDDLG Manages the boundary condition dialog box for
%       the PDE Toolbox.
%
%       Called from PDETOOL when double-clicking on a
%       boundary or selecting Specify Boundary Conditions...
%       from the Boundary menu.
%
%       See also: PDETOOL

%       Magnus G. Ringh 7-27-94, MR 04-11-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/01 04:28:07 $


% Eventually stored in UserData array:
% 1: scalarflag: 1 if scalar, 0 if system
% 2: handle to the selected boundary
% 3: text handle for equation
% 4-6: handles to boundary condition type selecting radiobuttons
% If scalarflag
  % 7-10: handles to edit fields for g, q, h, and r functions
  % 11-14: handles to entry field description texts
  % 15-18: handles to description texts for g, q, h, and r.
% else
  % 7-18: handles to edit fields for g, q, and h functions
  % 19-26: handles to entry field description texts
  % 27-34: handles to description texts for g, q, h, and r.
% end

if nargin<1
  error('PDE:pdebddlg:nargin', 'Too few input arguments.')
end

%
% case: bring up and initialize dialog box

if strcmp(action,'initialize'),

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  lines=findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine',...
      'Color',[0 0 0]);
  if isempty(lines),
    % No boundary segments selected - use all boundary segments as default
    lines=findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine');
    set(lines,'color','k');
    menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
    h=findobj(get(menuhndl,'Children'),'flat','Tag','PDEBoundSpec');
    % set pde_bound_sel to all line handles
    set(h,'UserData',lines)
  end
  if ~isempty(gco) && ~isempty(find(gco==lines)),
    linehndl=gco;
  elseif isempty(lines),
    pdetool('error',' Enter boundary mode to define boundary conditions');
    return;
  else
    linehndl=lines(1);
  end

  pdeinfo('Enter boundary condition for this segment.');

  % set up the boundary condition dialog box
  DlgName='Boundary Condition';
  if figflag(DlgName),
    drawnow
    return
  end

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
    smallScreen = 1;
  else
    smallScreen = 0;
  end
  set(0,'Unit',ScreenUnits);

  mCharacterWidth = 7;
  Voff = 5;

  if scalarflag,
    n=4;
  else
    n=8;
  end
  numoflines=3+n;
  FigWH = [(74-20*smallScreen)*mCharacterWidth numoflines*(BWH(2)+Voff)] ...
      +[2*(mEdgeToFrame+2*mFrameToText+BWH(1)) mLineHeight+...
          BWH(2)+4*mEdgeToFrame+scalarflag*4*mEdgeToFrame];
  Position = [(ScreenPos(3:4)-FigWH)/2 FigWH];

  % Make the figure
  DefUIBgColor = get(0,'DefaultUIControlBackgroundColor');
  fig = figure('NumberTitle','off',...
      'Name',DlgName,...
      'Units','pixels', ...
      'Position',Position,...
      'IntegerHandle','off',...
      'HandleVisibility','callback',...
      'MenuBar','none',...
      'Colormap',zeros(1,3),...
      'Color',DefUIBgColor,...
      'Visible','off',...
      'Tag','PDEBoundFig');

  % Fetch current boundary condition data, stored in pdebound matrix:
  menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  pdebound=get(findobj(get(menuhndl,'Children'),'flat',...
      'Tag','PDEBoundMode'),'UserData');

  column=get(linehndl,'UserData');
  column=column(1);

  % Dissect pdebound:
  % type 1 = Neumann, type 2 = Dirichlet, type 3 = Mixed
  if pdebound(1,column)==1,
    if pdebound(2,column),
      type=2;
    else
      type=1;
    end
  elseif pdebound(1,column)==2,
    if pdebound(2,column)==0,
      type=1;
    elseif pdebound(2,column)==1,
      type=3;
    elseif pdebound(2,column)==2,
      type=2;
    end
  end
  if scalarflag && type==1,
    nq=pdebound(3,column);
    ng=pdebound(4,column);
    qstr=char(pdebound(5:5+nq-1,column))';
    gstr=char(pdebound(5+nq:5+nq+ng-1,column))';
    bstrmtx=str2mat(gstr,qstr,'1','0');
  elseif scalarflag && type==2,
    nq=pdebound(3,column);
    ng=pdebound(4,column);
    nh=pdebound(5,column);
    nr=pdebound(6,column);
    qstr=char(pdebound(7:7+nq-1,column))';
    gstr=char(pdebound(7+nq:7+nq+ng-1,column))';
    hstr=char(pdebound(7+nq+ng:7+nq+ng+nh-1,column))';
    rstr=char(pdebound(7+nq+ng+nh:7+nq+ng+nh+nr-1,column))';
    bstrmtx=str2mat(gstr,qstr,hstr,rstr);
  elseif ~scalarflag && type==1
    nq1=pdebound(3,column);
    nq2=pdebound(4,column);
    nq3=pdebound(5,column);
    nq4=pdebound(6,column);
    ng1=pdebound(7,column);
    ng2=pdebound(8,column);
    pos=9;
    qstr1=char(pdebound(pos:pos+nq1-1,column))';
    pos=pos+nq1;
    qstr2=char(pdebound(pos:pos+nq2-1,column))';
    pos=pos+nq2;
    qstr3=char(pdebound(pos:pos+nq3-1,column))';
    pos=pos+nq3;
    qstr4=char(pdebound(pos:pos+nq4-1,column))';
    pos=pos+nq4;
    gstr1=char(pdebound(pos:pos+ng1-1,column))';
    pos=pos+ng1;
    gstr2=char(pdebound(pos:pos+ng2-1,column))';
    tmpstr=str2mat(gstr1,gstr2,qstr1,qstr3,qstr2,qstr4);
    bstrmtx=str2mat(tmpstr,'1','0','0','1','0','0');
  elseif ~scalarflag && type==2
    nq1=pdebound(3,column);
    nq2=pdebound(4,column);
    nq3=pdebound(5,column);
    nq4=pdebound(6,column);
    ng1=pdebound(7,column);
    ng2=pdebound(8,column);
    nh1=pdebound(9,column);
    nh2=pdebound(10,column);
    nh3=pdebound(11,column);
    nh4=pdebound(12,column);
    nr1=pdebound(13,column);
    nr2=pdebound(14,column);
    pos=15;
    qstr1=char(pdebound(pos:pos+nq1-1,column))';
    pos=pos+nq1;
    qstr2=char(pdebound(pos:pos+nq2-1,column))';
    pos=pos+nq2;
    qstr3=char(pdebound(pos:pos+nq3-1,column))';
    pos=pos+nq3;
    qstr4=char(pdebound(pos:pos+nq4-1,column))';
    pos=pos+nq4;
    gstr1=char(pdebound(pos:pos+ng1-1,column))';
    pos=pos+ng1;
    gstr2=char(pdebound(pos:pos+ng2-1,column))';
    pos=pos+ng2;
    hstr1=char(pdebound(pos:pos+nh1-1,column))';
    pos=pos+nh1;
    hstr2=char(pdebound(pos:pos+nh2-1,column))';
    pos=pos+nh2;
    hstr3=char(pdebound(pos:pos+nh3-1,column))';
    pos=pos+nh3;
    hstr4=char(pdebound(pos:pos+nh4-1,column))';
    pos=pos+nh4;
    rstr1=char(pdebound(pos:pos+nr1-1,column))';
    pos=pos+nr1;
    rstr2=char(pdebound(pos:pos+nr2-1,column))';
    tmpstr=str2mat(gstr1,gstr2,qstr1,qstr3,qstr2,qstr4);
    bstrmtx=str2mat(tmpstr,hstr1,hstr3,hstr2,hstr4,rstr1,rstr2);
  elseif ~scalarflag && type==3
    nq1=pdebound(3,column);
    nq2=pdebound(4,column);
    nq3=pdebound(5,column);
    nq4=pdebound(6,column);
    ng1=pdebound(7,column);
    ng2=pdebound(8,column);
    nh1=pdebound(9,column);
    nh2=pdebound(10,column);
    nr1=pdebound(11,column);
    pos=12;
    qstr1=char(pdebound(pos:pos+nq1-1,column))';
    pos=pos+nq1;
    qstr2=char(pdebound(pos:pos+nq2-1,column))';
    pos=pos+nq2;
    qstr3=char(pdebound(pos:pos+nq3-1,column))';
    pos=pos+nq3;
    qstr4=char(pdebound(pos:pos+nq4-1,column))';
    pos=pos+nq4;
    gstr1=char(pdebound(pos:pos+ng1-1,column))';
    pos=pos+ng1;
    gstr2=char(pdebound(pos:pos+ng2-1,column))';
    pos=pos+ng2;
    hstr1=char(pdebound(pos:pos+nh1-1,column))';
    pos=pos+nh1;
    hstr2=char(pdebound(pos:pos+nh2-1,column))';
    pos=pos+nh2;
    rstr1=char(pdebound(pos:pos+nr1-1,column))';
    tmpstr=str2mat(gstr1,gstr2,qstr1,qstr3,qstr2,qstr4);
    bstrmtx=str2mat(tmpstr,hstr1,hstr2,'0','1',rstr1,'0');
  end

  % Make the 5 frame uicontrols
  UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
  uicontrol(fig,'Style','frame','Position',UIPos);
  UIPos = [UIPos(1) UIPos(2)+UIPos(4) ...
          0.22*FigWH(1)-2*mEdgeToFrame (n+2)*(BWH(2)+Voff-mEdgeToFrame)];
  uicontrol(fig,'Style','frame','Position',UIPos);
  UIPos = [UIPos(1)+UIPos(3)+2*mEdgeToFrame UIPos(2) ...
          0.78*FigWH(1)-2*mEdgeToFrame UIPos(4)];
  uicontrol(fig,'Style','frame','Position',UIPos);
  UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 UIPos(2)+UIPos(4) FigWH(1)...
          BWH(2)+mLineHeight-2*mEdgeToFrame];
  uicontrol(fig,'Style','frame','Position',UIPos);

  % Make the text, checkbox, and edit check uicontrol(s)
  UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
          FigWH(1)*0.3-2*mEdgeToFrame mLineHeight];
  UIPos = UIPos - [0 BWH(2) 0 0];
  if smallScreen,
    BCstr='Boundary cond. equation:';
  else
    BCstr='Boundary condition equation:';
  end
  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String',BCstr);
  UIPos = UIPos + ...
      [FigWH(1)*0.3 0 FigWH(1)*0.4-2*mEdgeToFrame-2*mFrameToText 0];
  eq_hndl=uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String',equmtx(type,:),'UserData',equmtx);

  UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame ...
          (18-4*smallScreen)*mCharacterWidth mLineHeight];
  UIPos = UIPos - [0 2*(BWH(2)+Voff)+mFrameToText 0 0];
  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Condition type:');

  StrMtx=str2mat('Neumann','Dirichlet','Mixed');
  UIPos = UIPos - [0 Voff 0 0];

  type_hndl=zeros(3,1);
  for i=1:3,
    if any(find(i==typerange)),
      vis='on';
    else
      vis='off';
    end
    UIPos = UIPos - [0 BWH(2) 0 0];
    type_hndl(i)=uicontrol(fig,'Style','Radio','Value',i==type,...
        'HorizontalAlignment','left','Position',UIPos,...
        'CallBack','pdebddlg(''boundtype'',i)',...
        'Visible',vis,'String',StrMtx(i,:));
    UIPos = UIPos - [0 Voff 0 0];
  end
  call=['me=gco;','if(get(me,''Value'')==1),',...
            'set(get(me,''UserData''),''Value'',0),',...
            'else,',...
              'set(me,''Value'',1),',...
              'end; clear me'];
  for i=1:3,
    set(type_hndl(i),...
        'CallBack',[call, '; pdebddlg(''type_cb'',', int2str(i),')'],...
        'UserData',type_hndl([1:(i-1),(i+1):3]))
  end

  UIPos = [UIPos(1)+0.22*FigWH(1)+2*mEdgeToFrame ...
          FigWH(2)-mEdgeToFrame-2*BWH(2)-2*Voff-mFrameToText ...
          10*mCharacterWidth UIPos(4)];

  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Coefficient');

  UIPos = [UIPos(1)+0.12*FigWH(1)+2*mEdgeToFrame ...
          UIPos(2) (36-14*smallScreen)*mCharacterWidth UIPos(4)];

  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Value')

  UIPos = [UIPos(1)+0.35*FigWH(1)+2*mEdgeToFrame ...
          FigWH(2)-mEdgeToFrame-2*BWH(2)-2*Voff-mFrameToText ...
          (24-2*smallScreen)*mCharacterWidth UIPos(4)];

  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Description')

  UIPos = UIPos - [0.47*FigWH(1)+2*mEdgeToFrame Voff 13*mCharacterWidth 0];
  entry_hndl=zeros(n,1);
  for i=1:n,
    UIPos = UIPos - [0 BWH(2) 0 0];
    entry_hndl(i)=uicontrol(fig,'Style','text',...
        'HorizontalAlignment','left','Position',UIPos',...
        'String',deblank(entrymtx(i,:)));
    UIPos = UIPos - [0 Voff 0 0];
  end

  UIPos = [UIPos(1)+0.12*FigWH(1)+2*mEdgeToFrame ...
          FigWH(2)-mEdgeToFrame-3*BWH(2)-5*Voff...
          (36-10*smallScreen)*mCharacterWidth UIPos(4)];

  if scalarflag,
    edit_hndl=zeros(4,1);
    for i=1:4,
      UIPos = UIPos - [0 Voff 0 0];
      edit_hndl(i)=uicontrol(fig,'Style','edit',...
          'HorizontalAlignment','left','Position',UIPos',...
          'Backgroundcolor','w','String',deblank(bstrmtx(i,:)),...
          'UserData',deblank(bstrmtx(i,:)));

      UIPos = UIPos - [0 BWH(2) 0 0];
    end
  else
    edit_hndl=zeros(12,1);
    UIPos(3)=(15-2*smallScreen)*mCharacterWidth;
    for i=1:2,
      UIPos = UIPos - [0 Voff 0 0];
      edit_hndl(i)=uicontrol(fig,'Style','edit',...
          'HorizontalAlignment','left','Position',UIPos',...
          'Backgroundcolor','w','String',deblank(bstrmtx(i,:)),...
          'UserData',deblank(bstrmtx(i,:)));
      UIPos = UIPos - [0 BWH(2) 0 0];
    end
    for i=3:2:9,
      UIPos = UIPos - [0 Voff 0 0];
      edit_hndl(i)=uicontrol(fig,'Style','edit',...
          'HorizontalAlignment','left','Position',UIPos',...
          'Backgroundcolor','w','String',deblank(bstrmtx(i,:)),...
          'UserData',deblank(bstrmtx(i,:)));
      i=i+1;
      UIPos(1)=UIPos(1)+(17-2*smallScreen)*mCharacterWidth;
      edit_hndl(i)=uicontrol(fig,'Style','edit',...
          'HorizontalAlignment','left','Position',UIPos',...
          'Backgroundcolor','w','String',deblank(bstrmtx(i,:)),...
          'UserData',deblank(bstrmtx(i,:)));
      UIPos = UIPos - [(17-2*smallScreen)*mCharacterWidth BWH(2) 0 0];
    end
    for i=11:12,
      UIPos = UIPos - [0 Voff 0 0];
      edit_hndl(i)=uicontrol(fig,'Style','edit',...
          'HorizontalAlignment','left','Position',UIPos',...
          'Backgroundcolor','w','String',deblank(bstrmtx(i,:)),...
          'UserData',deblank(bstrmtx(i,:)));
      UIPos = UIPos - [0 BWH(2) 0 0];
    end
  end

  UIPos = [UIPos(1)+0.35*FigWH(1)+2*mEdgeToFrame ...
          FigWH(2)-mEdgeToFrame-3*BWH(2)-5*Voff...
          (24-2*smallScreen)*mCharacterWidth UIPos(4)];
  for i=1:n,
    UIPos = UIPos - [0 Voff 0 0];
    descr_hndl(i)=uicontrol(fig,'Style','text',...
        'HorizontalAlignment','left','Position',UIPos',...
        'String',deblank(descrmtx(i,:)));
    UIPos = UIPos - [0 BWH(2) 0 0];
  end

  % Make the pushbuttons
  Hspace = (FigWH(1)-2*BWH(1))/3;
  OKFcn = 'pdebddlg(''ok'')';
  uicontrol(fig,'Style','push','String','OK',...
      'Callback',OKFcn,'Position',[Hspace mLineHeight/2 BWH]);
  CancelFcn = 'pdebddlg(''cancel'')';
  uicontrol(fig,'Style','push','String','Cancel',...
      'Callback',CancelFcn,'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

  hndls=[scalarflag linehndl eq_hndl type_hndl' edit_hndl' ...
          entry_hndl' descr_hndl];
  set(fig,'UserData',hndls)

  % Display current conditions:
  pdebddlg('type_cb',type)

  % Finally, make all the uicontrols normalized and the figure visible
  set(get(fig,'Children'),'Unit','norm');
  set(fig,'Visible','on')

  drawnow

%
% case: Type of boundary cond. callback

elseif strcmp(action,'type_cb')

  fig=gcf;
  hndls=get(fig,'UserData');
  equmtx=get(hndls(3),'UserData');
  descrmtx=get(hndls(7),'UserData');
  scalarflag=hndls(1);

  if flag==1,                           % Neumann conditions
    set(hndls(3),'String',equmtx(1,:));

    if scalarflag,
      set(hndls(7:8),'Enable','on')
      set(hndls(9:10),'Enable','off')
      set(hndls(11:12),'Enable','on');
      set(hndls(13:14),'Enable','off');
      set(hndls(15:16),'Enable','on');
      set(hndls(17:18),'Enable','off');
    else
      set(hndls(7:12),'Enable','on');
      set(hndls(13:18),'Enable','off');
      set(hndls(19:22),'Enable','on')
      set(hndls(23:26),'Enable','off');
      set(hndls(27:30),'Enable','on')
      set(hndls(31:34),'Enable','off');
    end
  elseif flag==2,                       % Dirichlet conditions
    set(hndls(3),'String',equmtx(2,:));

    if scalarflag,
      set(hndls(7:8),'Enable','off')
      set(hndls(9:10),'Enable','on');
      set(hndls(11:12),'Enable','off');
      set(hndls(13:14),'Enable','on');
      set(hndls(15:16),'Enable','off');
      set(hndls(17:18),'Enable','on');
    else
      set(hndls(7:12),'Enable','off');
      set(hndls(13:18),'Enable','on');
      set(hndls(19:22),'Enable','off');
      set(hndls(23:26),'Enable','on');
      set(hndls(27:30),'Enable','off')
      set(hndls(31:34),'Enable','on');
    end
  elseif flag==3,                       % Mixed conditions
    set(hndls(3),'String',equmtx(3,:));

    set(hndls([7:14, 17, 19:23, 25, 27:31, 33]),'Enable','on');
    set(hndls([15:16, 18]),'String','0','Enable','off')
    set(hndls([24, 26, 32, 34]),'Enable','off')
  end

%
% case: boundary OK

elseif strcmp(action,'ok')

  fig=gcf;
  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');

  set(fig,'Visible','off')
  figure(pde_fig)

  hndls=get(fig,'UserData');
  scalarflag=hndls(1);
  % in UserData array:
  % 1: scalarflag: 1 if scalar, 0 if system
  % 2: handle to the selected boundary
  % 3: text handle for equation
  % 4-6: handles to boundaty condition type selecting radiobuttons
  % If scalarflag
  % 7-10: handles to edit fields for g, q, h, and r functions
  % 11-14: handles to entry field description texts
  % 15-18: handles to description texts for g, q, h, and r.
  % else
  % 7-18: handles to edit fields for g, q, and h functions
  % 19-26: handles to entry field description texts
  % 27-34: handles to description texts for g, q, h, and r.
  % end

  % set color and update boundary condition matrix
  menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  h=findobj(get(menuhndl,'Children'),'flat','Tag','PDEBoundSpec');
  hbound=findobj(get(menuhndl,'Children'),'flat','Tag','PDEBoundMode');
  pdebound=get(hbound,'UserData');

  pde_bound_sel=get(h,'UserData');

  n=length(pde_bound_sel);
  column=[];
  for j=1:n,
    tmp=get(pde_bound_sel(j),'UserData');
    column=[column tmp(1)];
  end

  if get(hndls(4),'Value')==1
    % case: Neumann conditions
    set(pde_bound_sel,'Color','b')
    for j=1:n,
      set(pde_bound_sel(j),'UserData',[column(j) 0 0 1])
    end
    type=1;
  elseif get(hndls(5),'Value')==1
    % case: Dirichlet conditions
    set(pde_bound_sel,'Color','r')
    for j=1:n,
      set(pde_bound_sel(j),'UserData',[column(j) 1 0 0])
    end
    type=2;
  elseif get(hndls(6),'Value')==1
    % case: mixed boundary conditions
    set(pde_bound_sel,'Color','g')
    for j=1:n,
      set(pde_bound_sel(j),'UserData',[column(j) 0 1 0])
    end
    type=3;
  end
  if scalarflag,
    pdebound(1,column)=ones(1,n);
  else
    pdebound(1,column)=2*ones(1,n);
  end

  if type==1,
    % Neumann
    m=0;
    if scalarflag,
      qstr=kron(get(hndls(8),'String'),ones(n,1))';
      qlength=size(qstr,1)*ones(1,n);
      gstr=kron(get(hndls(7),'String'),ones(n,1))';
      glength=size(gstr,1)*ones(1,n);
    else
      qstr1=kron(get(hndls(9),'String'),ones(n,1))';
      qlength1=size(qstr1,1)*ones(1,n);
      qstr2=kron(get(hndls(11),'String'),ones(n,1))';
      qlength2=size(qstr2,1)*ones(1,n);
      qstr3=kron(get(hndls(10),'String'),ones(n,1))';
      qlength3=size(qstr3,1)*ones(1,n);
      qstr4=kron(get(hndls(12),'String'),ones(n,1))';
      qlength4=size(qstr4,1)*ones(1,n);
      gstr1=kron(get(hndls(7),'String'),ones(n,1))';
      glength1=size(gstr1,1)*ones(1,n);
      gstr2=kron(get(hndls(8),'String'),ones(n,1))';
      glength2=size(gstr2,1)*ones(1,n);
    end
  elseif type==2,
    % Dirichlet
    if scalarflag,
      m=1;
      qstr='0'*ones(1,n); qlength=ones(1,n);
      gstr='0'*ones(1,n); glength=ones(1,n);
      hstr=kron(get(hndls(9),'String'),ones(n,1))';
      hlength=size(hstr,1)*ones(1,n);
      rstr=kron(get(hndls(10),'String'),ones(n,1))';
      rlength=size(rstr,1)*ones(1,n);
    else
      m=2;
      qstr1='0'*ones(1,n); qlength1=ones(1,n);
      qstr2='0'*ones(1,n); qlength2=ones(1,n);
      qstr3='0'*ones(1,n); qlength3=ones(1,n);
      qstr4='0'*ones(1,n); qlength4=ones(1,n);
      gstr1='0'*ones(1,n); glength1=ones(1,n);
      gstr2='0'*ones(1,n); glength2=ones(1,n);
      hstr1=kron(get(hndls(13),'String'),ones(n,1))';
      hlength1=size(hstr1,1)*ones(1,n);
      hstr2=kron(get(hndls(15),'String'),ones(n,1))';
      hlength2=size(hstr2,1)*ones(1,n);
      hstr3=kron(get(hndls(14),'String'),ones(n,1))';
      hlength3=size(hstr3,1)*ones(1,n);
      hstr4=kron(get(hndls(16),'String'),ones(n,1))';
      hlength4=size(hstr4,1)*ones(1,n);
      rstr1=kron(get(hndls(17),'String'),ones(n,1))';
      rlength1=size(rstr1,1)*ones(1,n);
      rstr2=kron(get(hndls(18),'String'),ones(n,1))';
      rlength2=size(rstr2,1)*ones(1,n);
    end
  elseif type==3,
    % Mixed
    % Must be system case
    m=1;
    qstr1=kron(get(hndls(9),'String'),ones(n,1))';
    qlength1=size(qstr1,1)*ones(1,n);
    qstr2=kron(get(hndls(11),'String'),ones(n,1))';
    qlength2=size(qstr2,1)*ones(1,n);
    qstr3=kron(get(hndls(10),'String'),ones(n,1))';
    qlength3=size(qstr3,1)*ones(1,n);
    qstr4=kron(get(hndls(12),'String'),ones(n,1))';
    qlength4=size(qstr4,1)*ones(1,n);
    gstr1=kron(get(hndls(7),'String'),ones(n,1))';
    glength1=size(gstr1,1)*ones(1,n);
    gstr2=kron(get(hndls(8),'String'),ones(n,1))';
    glength2=size(gstr2,1)*ones(1,n);
    hstr1=kron(get(hndls(13),'String'),ones(n,1))';
    hlength1=size(hstr1,1)*ones(1,n);
    hstr2=kron(get(hndls(14),'String'),ones(n,1))';
    hlength2=size(hstr2,1)*ones(1,n);
    rstr1=kron(get(hndls(17),'String'),ones(n,1))';
    rlength1=size(rstr1,1)*ones(1,n);
  end

  % Reassemble pdebound
  if scalarflag,
    nq=qlength(1); ng=glength(1);
    pdebound(2,column)=m*ones(size(column));
    pdebound(3,column)=qlength;
    pdebound(4,column)=glength;
    if m,
      nh=hlength(1); nr=rlength(1);
      pdebound(5,column)=hlength;
      pdebound(6,column)=rlength;
      pdebound(7:7+nq-1,column)=qstr;
      pdebound(7+nq:7+nq+ng-1,column)=gstr;
      pdebound(7+nq+ng:7+nq+ng+nh-1,column)=hstr;
      pdebound(7+nq+ng+nh:7+nq+ng+nh+nr-1,column)=rstr;
    else
      pdebound(5:5+nq-1,column)=qstr;
      pdebound(5+nq:5+nq+ng-1,column)=gstr;
    end
  else
    nq1=qlength1(1); ng1=glength1(1);
    nq2=qlength2(1); ng2=glength2(1);
    nq3=qlength3(1);
    nq4=qlength4(1);
    pdebound(2,column)=m*ones(size(column));
    pdebound(3,column)=qlength1;
    pdebound(4,column)=qlength2;
    pdebound(5,column)=qlength3;
    pdebound(6,column)=qlength4;
    pdebound(7,column)=glength1;
    pdebound(8,column)=glength2;
    if m==2,
      nh1=hlength1(1); nr1=rlength1(1);
      nh2=hlength2(1); nr2=rlength2(1);
      nh3=hlength3(1);
      nh4=hlength4(1);
      pdebound(9,column)=hlength1;
      pdebound(10,column)=hlength2;
      pdebound(11,column)=hlength3;
      pdebound(12,column)=hlength4;
      pdebound(13,column)=rlength1;
      pdebound(14,column)=rlength2;
      pos=15;
      pdebound(pos:pos+nq1-1,column)=qstr1;
      pos=pos+nq1;
      pdebound(pos:pos+nq2-1,column)=qstr2;
      pos=pos+nq2;
      pdebound(pos:pos+nq3-1,column)=qstr3;
      pos=pos+nq3;
      pdebound(pos:pos+nq4-1,column)=qstr4;
      pos=pos+nq4;
      pdebound(pos:pos+ng1-1,column)=gstr1;
      pos=pos+ng1;
      pdebound(pos:pos+ng2-1,column)=gstr2;
      pos=pos+ng2;
      pdebound(pos:pos+nh1-1,column)=hstr1;
      pos=pos+nh1;
      pdebound(pos:pos+nh2-1,column)=hstr2;
      pos=pos+nh2;
      pdebound(pos:pos+nh3-1,column)=hstr3;
      pos=pos+nh3;
      pdebound(pos:pos+nh4-1,column)=hstr4;
      pos=pos+nh4;
      pdebound(pos:pos+nr1-1,column)=rstr1;
      pos=pos+nr1;
      pdebound(pos:pos+nr2-1,column)=rstr2;
    elseif m==1,
      nh1=hlength1(1); nr1=rlength1(1);
      nh2=hlength2(1);
      pdebound(9,column)=hlength1;
      pdebound(10,column)=hlength2;
      pdebound(11,column)=rlength1;
      pos=12;
      pdebound(pos:pos+nq1-1,column)=qstr1;
      pos=pos+nq1;
      pdebound(pos:pos+nq2-1,column)=qstr2;
      pos=pos+nq2;
      pdebound(pos:pos+nq3-1,column)=qstr3;
      pos=pos+nq3;
      pdebound(pos:pos+nq4-1,column)=qstr4;
      pos=pos+nq4;
      pdebound(pos:pos+ng1-1,column)=gstr1;
      pos=pos+ng1;
      pdebound(pos:pos+ng2-1,column)=gstr2;
      pos=pos+ng2;
      pdebound(pos:pos+nh1-1,column)=hstr1;
      pos=pos+nh1;
      pdebound(pos:pos+nh2-1,column)=hstr2;
      pos=pos+nh2;
      pdebound(pos:pos+nr1-1,column)=rstr1;
    elseif m==0,
      pos=9;
      pdebound(pos:pos+nq1-1,column)=qstr1;
      pos=pos+nq1;
      pdebound(pos:pos+nq2-1,column)=qstr2;
      pos=pos+nq2;
      pdebound(pos:pos+nq3-1,column)=qstr3;
      pos=pos+nq3;
      pdebound(pos:pos+nq4-1,column)=qstr4;
      pos=pos+nq4;
      pdebound(pos:pos+ng1-1,column)=gstr1;
      pos=pos+ng1;
      pdebound(pos:pos+ng2-1,column)=gstr2;
    end
  end

  set(hbound,'UserData',pdebound)

  % alert PDETOOL that boundary conditions have changed
  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flags(5)=1;                           % flag3=1
  flags(6)=0;                           % flag4=0
  set(flg_hndl,'UserData',flags)

  % deselect the boundary
  bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  set(findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundSpec'),...
      'UserData',[])

  delete(fig)
  drawnow

  pdeinfo



%
% case: cancel

elseif strcmp(action,'cancel')

  delete(gcf)
  drawnow

  pdeinfo

end

