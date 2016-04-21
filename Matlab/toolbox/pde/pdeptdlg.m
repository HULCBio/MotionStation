function pdeptdlg(action,flag,applstr)
%PDEPTDLG Manages the plot dialog box for the PDE Toolbox.
%   PDEPTDLG(ACTION,FLAG,APPLSTR).
%
%   APPLSTR is a string matrix containing two strings describing
%   the application specific scalar and vector properties.
%
%   Called from PDETOOL when clicking on the
%   'plot'-button.
%
%   See also PDETOOL.

%   Magnus Ringh 9-06-94, MR 10-04-95.
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2003/11/18 03:11:46 $

if nargin<1
  error('PDE:pdeptdlg:nargin', 'Too few input arguments.');
  return;
end

%
% case: initialize and open plot dialog box

if strcmp(action,'initialize')

  % Stored in UserData array:
  % 1-6:   handles plot type checkboxes
  % 7-10:  handles to visualization property popup-menus
  % 11:    handle to pushbutton for animation options dialog box
  % 12-15: handles to user entry edit boxes
  % 16-18: handles to plot style selection popup-menus
  % 19-20: handles to mesh options (x-y, off) checkboxes
  % 21:    handle to 'Plot solution automatically'-checkbox
  % 22:    handle to color selection popup menu
  % 23-24: handles to the time(eigenvalue) text ui control and its popup
  %        ui control
  % 25:    handle to contour level edit box
  % 26:    application mode

  % A flag value is sent to indicate 'no dialog'.
  if ~flag,
    pdeinfo('Specify plot property and plot type.',0);
  end
  
  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');

  % Check if equation has changed and has not been solved (flag5=1)
  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData');
  solflag=flags(6);
  changeflag=flags(7);

  appl=getappdata(pde_fig,'application');

  DlgName='Plot Selection';
  fig=findobj(allchild(0),'flat','Name',DlgName);

  if isempty(fig),
    % Set up the plot selection dialog box

    set(pde_fig,'Pointer','watch')
    drawnow

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

    numoflines=10;
    FigWH = [61*mCharacterWidth numoflines*(BWH(2)+Voff)] ...
        +[2*(mEdgeToFrame+mFrameToText)+2*(BWH(1)+mFrameToText) ...
            mLineHeight+BWH(2)+2*Voff];
    Position = [(ScreenPos(3:4)-FigWH)/2 FigWH];

    % Make the figure
    DefUIBgColor = get(0,'DefaultUIControlBackgroundColor');
    fig = figure('NumberTitle','off',...
        'Name',DlgName,...
        'Units','pixels',...
        'Position',Position,...
        'IntegerHandle','off',...
        'HandleVisibility','off',...
        'MenuBar','none',...
        'Colormap',zeros(1,3),...
        'Color',DefUIBgColor,...
        'Visible','off',...
        'Tag','PDEPlotFig');

    % Make the 3 frame uicontrols
    UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
    uicontrol(fig,'Style','frame','Position',UIPos);
    UIPos = [UIPos(1:3)+[0 UIPos(4)+mEdgeToFrame 0] ...
            2.5*(BWH(2)+Voff-mEdgeToFrame)];
    uicontrol(fig,'Style','frame','Position',UIPos);
    UIPos = [UIPos(1:3)+...
            [0 UIPos(4)+mEdgeToFrame 0] 8.5*(BWH(2)+Voff-2*mEdgeToFrame)];
    uicontrol(fig,'Style','frame','Position',UIPos);

    % Make the text, and edit check uicontrol(s)
    UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
            19*mCharacterWidth mLineHeight];

    UIPos = UIPos - [0 BWH(2) 0 0];
    uicontrol(fig,'Style','text','HorizontalAlignment','left',...
        'Position',UIPos,'String','Plot type:');
    UIPos = UIPos - [0 2*Voff 0 0];

    StrMtx=str2mat('Color','Contour','Arrows','Deformed mesh',...
      'Height (3-D plot)','Animation');
    type_hndl=zeros(6,1);
    for i=1:6,
      UIPos = UIPos - [0 BWH(2) 0 0];
      type_hndl(i)=uicontrol(fig,'Style','checkbox',...
          'HorizontalAlignment','left','Position',UIPos,...
          'String',StrMtx(i,:),'Enable','on');
      UIPos = UIPos - [0 Voff 0 0];
    end

    UIPos = [mEdgeToFrame+mFrameToText+21*mCharacterWidth ...
            FigWH(2)-mEdgeToFrame-Voff 24*mCharacterWidth ...
            mLineHeight];

    UIPos = UIPos - [0 BWH(2) 0 0];
    uicontrol(fig,'Style','text','HorizontalAlignment','left',...
        'Position',UIPos,'String','Property:');
    UIPos = UIPos - [0 Voff 0 0];

    str1='u|abs(grad(u))|abs(c*grad(u))|user entry';
    str2=' -grad(u)| -c*grad(u)| user entry';
    str3=str2;
    str4=str1;
    StrMtx=str2mat(str1,str2,str3,str4);
    property_hndl=zeros(4,1);
    UIPos = UIPos - [0 0.5*Voff+1.5*BWH(2) 0 0];
    property_hndl(1)=uicontrol(fig,'Style','popupmenu',...
        'HorizontalAlignment','left','Position',UIPos,...
        'String',StrMtx(1,:),'Callback','pdeptdlg(''prop_cb'',1)');
    UIPos = UIPos - [0 2.5*Voff+0.5*BWH(2) 0 0];
    for i=2:4,
      UIPos = UIPos - [0 BWH(2) 0 0];
      cb=sprintf('pdeptdlg(''prop_cb'',%i)',i);
      property_hndl(i)=uicontrol(fig,'Style','popupmenu',...
          'HorizontalAlignment','left','Position',UIPos,...
          'String',StrMtx(i,:),'Callback',cb);
      UIPos = UIPos - [0 Voff 0 0];
    end

    UIPos = UIPos - [0 BWH(2) 0 0];
    animopt_hndl=uicontrol(fig,'Style','pushbutton',...
        'HorizontalAlignment','center','Position',UIPos,...
        'String','Options...','Callback','pdemvdlg');

    UIPos = [mEdgeToFrame+mFrameToText+47*mCharacterWidth ...
            FigWH(2)-mEdgeToFrame-Voff 20*mCharacterWidth ...
            mLineHeight];

    UIPos = UIPos - [0 BWH(2) 0 0];
    uicontrol(fig,'Style','text','HorizontalAlignment','left',...
        'Position',UIPos,'String','User entry:');
    UIPos = UIPos - [0 Voff 0 0];

    StrMtx=str2mat(getappdata(pde_fig,'colstring'),...
                   getappdata(pde_fig,'arrowstring'),...
                   getappdata(pde_fig,'deformstring'),...
                   getappdata(pde_fig,'heightstring'));
    user_hndl=zeros(4,1);
    UIPos = UIPos - [0 0.5*Voff+1.5*BWH(2) 0 0];
    user_hndl(1)=uicontrol(fig,'Style','edit','Enable','off',...
          'HorizontalAlignment','left','Position',UIPos,...
          'BackgroundColor','w','String',deblank(StrMtx(1,:)));
    UIPos = UIPos - [0 2.5*Voff+0.5*BWH(2) 0 0];
    for i=2:4,
      UIPos = UIPos - [0 BWH(2) 0 0];
      user_hndl(i)=uicontrol(fig,'Style','edit','Enable','off',...
          'HorizontalAlignment','left','Position',UIPos,...
          'BackgroundColor','w','String',deblank(StrMtx(i,:)));
      UIPos = UIPos - [0 Voff 0 0];
    end

    UIPos = [mEdgeToFrame+mFrameToText+69*mCharacterWidth ...
            FigWH(2)-mEdgeToFrame-Voff 22*mCharacterWidth ...
            mLineHeight];

    UIPos = UIPos - [0 BWH(2) 0 0];
    uicontrol(fig,'Style','text','HorizontalAlignment','left',...
        'Position',UIPos,'String','Plot style:');
    UIPos = UIPos - [0 Voff 0 0];

    str1='interpolated shad.|flat shading';
    str2='proportional|normalized';
    str3='continuous|discontinuous';
    StrMtx=str2mat(str1,str2,str3);
    style_hndl=zeros(3,1);
    UIPos = UIPos - [0 0.5*Voff+1.5*BWH(2) 0 0];
    style_hndl(1)=uicontrol(fig,'Style','popupmenu',...
        'HorizontalAlignment','left','Position',UIPos,...
        'String',StrMtx(1,:));
    UIPos = UIPos - [0 2.5*Voff 0 0];
    UIPos = UIPos - [0 1.5*BWH(2) 0 0];
    style_hndl(2)=uicontrol(fig,'Style','popupmenu',...
        'HorizontalAlignment','left','Position',UIPos,...
        'String',StrMtx(2,:));
    UIPos = UIPos - [0 2*(BWH(2)+Voff) 0 0];
    style_hndl(3)=uicontrol(fig,'Style','popupmenu',...
        'HorizontalAlignment','left','Position',UIPos,...
        'String',StrMtx(3,:));

    UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
            19*mCharacterWidth mLineHeight];
    UIPos = UIPos - [0 8*(BWH(2)+Voff) 0 0];

    StrMtx=str2mat('Plot in x-y grid','Show mesh');

    mesh_hndl=zeros(2,1);
    for i=1:2,
      UIPos = UIPos - [0 BWH(2) 0 0];
      mesh_hndl(i)=uicontrol(fig,'Style','Checkbox',...
          'HorizontalAlignment','left','Position',UIPos,...
          'String',StrMtx(i,:));
      UIPos = UIPos - [0 Voff 0 0];
    end

    UIPos = UIPos + ...
        [21*mCharacterWidth BWH(2)+2*Voff ...
        9*mCharacterWidth 0];

    uicontrol(fig,'Style','Text','Position',UIPos,...
        'HorizontalAlignment','left',...
        'String','Contour plot levels:');
 
    UIPos = UIPos + [20*mCharacterWidth 0 -12*mCharacterWidth 0];

    lvl_hndl=uicontrol(fig,'Style','Edit','Position',UIPos,...
        'Backgroundcolor','w','HorizontalAlignment','left',...
        'String','20');

    UIPos = UIPos + [18*mCharacterWidth 0 16*mCharacterWidth 0];

    doStr = 'Plot solution automatically';
 
    do_hndl=uicontrol(fig,'Style','Checkbox','Position',UIPos,...
        'HorizontalAlignment','left','String',doStr);

    UIPos = UIPos + [-38*mCharacterWidth -BWH(2)-Voff -17*mCharacterWidth 0];
    uicontrol(fig,'Style','text','Position',UIPos,...
        'HorizontalAlignment','left','String','Colormap:');
    UIPos = UIPos + [15*mCharacterWidth 0 6*mCharacterWidth 0];
    col_hndl=uicontrol(fig,'Style','popup','Position',UIPos,...
        'String','cool|gray|bone|pink|copper|hot|jet|hsv|prism');

    UIPos = UIPos + [23*mCharacterWidth 0 -7*mCharacterWidth 0];
    time_hndl=uicontrol(fig,'Style','text',...
        'Position',UIPos,'HorizontalAlignment','left','Visible','on',...
        'String','Time for plot:');
    UIPos = UIPos + [UIPos(3)+mFrameToText 0 0 0];
    popup_hndl=uicontrol(fig,'Style','popup','Visible','on',...
        'Position',UIPos,'String',' ');

    % Make the pushbuttons
    Hspace = (FigWH(1)-3*BWH(1))/4;

    PlotFcn = 'pdeptdlg(''done''), pdeptdlg(''plot'')';
    uicontrol(fig,'Style','push','String','Plot','Callback',PlotFcn, ...
        'Position',[Hspace mLineHeight/2 BWH]);
    DoneFcn = ['set(findobj(get(0,''Children''),''flat'',',...
      '''Tag'',''PDEPlotFig''),''Visible'',''off'');',...
      'figure(findobj(get(0,''Children''),''flat'',''Tag'',''PDETool''));',...
      'pdeptdlg(''done'');pdeinfo'];
    uicontrol(fig,'Style','push','String','Done',...
        'Callback',DoneFcn,'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);
    CancelFcn = 'pdeptdlg(''cancel'')';
    uicontrol(fig,'Style','push','String','Cancel',...
        'Callback',CancelFcn,'Position',[3*Hspace+2*BWH(1) mLineHeight/2 BWH]);

    hndls=[type_hndl' property_hndl' animopt_hndl user_hndl' style_hndl' ...
            mesh_hndl' do_hndl col_hndl time_hndl popup_hndl ...
            lvl_hndl appl];

    % Finally, make all the uicontrols normalized
    set(get(fig,'Children'),'Unit','norm');
    set(fig,'UserData',hndls)

  else

    fig=fig(1);
    hndls=get(fig,'UserData');

  end

  plotflags=getappdata(pde_fig,'plotflags');
  % [colvar colstyle heightvar heightstyle vectorvar vectorstyle
  % colval doplot xyplot showmesh animationflag popupvalue  
  % colflag contflag heightflag vectorflag deformflag deformvar] 
  
  set(hndls(7),'Value',plotflags(1))
  set(hndls(16),'Value',plotflags(2))
  set(hndls(1),'Value',plotflags(13))
  set(hndls(2),'Value',plotflags(14))
  set(hndls(10),'Value',plotflags(3))
  set(hndls(18),'Value',plotflags(4))
  set(hndls(8),'Value',plotflags(5))
  set(hndls(3),'Value',plotflags(16))
  set(hndls(17),'Value',plotflags(6))
  set(hndls(4),'Value',plotflags(17))  
  set(hndls(22),'Value',plotflags(7))
  set(hndls(21),'Value',plotflags(8))
  set(hndls(19),'Value',plotflags(9))
  set(hndls(5),'Value',plotflags(15))  
  set(hndls(20),'Value',plotflags(10))
  set(hndls(6),'Value',plotflags(11))
  set(hndls(9),'Value',plotflags(18))

  % Set edit fields:
  colstr = getappdata(pde_fig,'colstring');
  arrstr = getappdata(pde_fig,'arrowstring');
  defstr = getappdata(pde_fig,'deformstring');
  htstr = getappdata(pde_fig,'heightstring');
  set(hndls(12),'String',colstr,'UserData',colstr)
  set(hndls(13),'String',arrstr,'UserData',arrstr)
  set(hndls(14),'String',defstr,'UserData',defstr)
  set(hndls(15),'String',htstr,'UserData',htstr)

  hndls(26) = appl;
  set(fig,'UserData',hndls)

  pde_type=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEHelpMenu'),'UserData');
  timeeigparam=getappdata(pde_fig,'timeeigparam');
  if pde_type==2 || pde_type==3,
    % parabolic or hyperbolic PDE
    set(hndls(23),'Visible','on','String','Time for plot:')
    times=eval(timeeigparam(1,:));
    str=sprintf(' %.4g|',times);
    str=str(1:length(str)-1);
    if ~solflag || changeflag,
      set(hndls(24),'Enable','off','Visible','on','String',str,...
        'Value',plotflags(12))
    else
      set(hndls(24),'Enable','on','Visible','on','String',str,...
        'Value',plotflags(12))
    end
    set([hndls(6), hndls(11)],'Enable','on');
  elseif pde_type==4,
    % PDE eigenvalue problem
    set(hndls(23),'Visible','on','String','Eigenvalue:')
    winhndl=findobj(get(pde_fig,'Children'),'flat','Tag','winmenu');
    eigvals=get(winhndl,'UserData');
    str=sprintf(' %.4g|',eigvals);
    str=str(1:length(str)-1);
    if ~solflag || changeflag,
      set(hndls(24),'Visible','on','String',str,'Enable','off')
    else
      set(hndls(24),'Visible','on','String',str,'Enable','on')
    end
    set([hndls(6), hndls(11)],'Enable','off');
    set(hndls(6),'Value',0); plotflags(11)=0;
  else
    set([hndls(6), hndls(11)],'Enable','off');
    set(hndls(6),'Value',0); plotflags(11)=0;
    set(hndls(23:24),'Visible','off')
  end

  setappdata(pde_fig,'plotflags',plotflags)

  % Update the list of properties according to the current application mode:
  if flag~=2,
    scalarstring=deblank(applstr(1,:));
    vectorstring=deblank(applstr(2,:));
    set([hndls(7), hndls(10)],'String',scalarstring)
    set(hndls(7),'Value',plotflags(1))
    set(hndls(10),'Value',plotflags(3))
    set(hndls(8:9),'String',vectorstring)
    set(hndls(8),'Value',plotflags(5))
    set(hndls(9),'Value',plotflags(18))

    % Enable user entries if selected:
    if strcmp(popupstr(hndls(7)),'user entry'),
      set(hndls(12),'Enable','on')
    end
    if strcmp(popupstr(hndls(8)),' user entry'),
      set(hndls(13),'Enable','on')
    end
    if strcmp(popupstr(hndls(9)),' user entry'),
      set(hndls(14),'Enable','on')
    end
    if strcmp(popupstr(hndls(10)),'user entry'),
      set(hndls(15),'Enable','on')
    end
  end

  if ~flag,     % if ~'no dialog'
    figure(fig)
  end

  set(pde_fig,'Pointer','arrow')
  drawnow

%
%
% case: property popup menu callback

elseif strcmp(action,'prop_cb'),

  hndls=get(gcbf,'UserData');
  popstr=fliplr(deblank(fliplr(popupstr(gcbo))));
  if strcmp(popstr,'user entry'),
    set(hndls(11+flag),'enable','on')
  else
    set(hndls(11+flag),'enable','off')
  end

%
%
% case: plot

elseif strcmp(action,'plot')

  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
  set(pde_fig,'Pointer','watch')
  drawnow

  fig=findobj(allchild(0),'flat','Tag','PDEPlotFig');
  if isempty(fig),
    pdeptdlg('initialize',2)
    fig=findobj(allchild(0),'flat','Tag','PDEPlotFig');
  end
  
  fig=fig(1);
  hndls=get(fig,'UserData');

  if get(hndls(6),'Value'),
  % Animate solution:
    animparams=getappdata(pde_fig,'animparam');
    replay=animparams(3);
    if replay==1,
      animate=0;
    else
      replay=0;
      animate=1;
    end
  else
    animate=0;
    replay=0;
  end

  lvl=eval(get(hndls(25),'String'),'20');

  if ~replay
    pdegd=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu'),...
        'UserData');
    if isempty(pdegd), pdetool('membrane'), end

    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(h,'UserData');
    flag1=flags(3);
    if flag1,
      flags(2)=0;       % mode_flag=0
      pdetool('changemode',0)
    elseif ~flags(2),
      flags(2)=1;       % set mode_flag if we entered w/o passing 'changemode'
      set(h,'UserData',flags);
      pdetool('cleanup')
    end
    flags=get(h,'UserData');
    flag2=flags(4);
    if flag2,
      pdetool('initmesh')
    end
    flags=get(h,'UserData');
    flag3=flags(5); flag5=flags(7);
    if (flag3 || flag5), pdetool('solve',1), end
  end

  set(pde_fig,'Pointer','watch')
  drawnow
  pdeinfo('Plotting solution...',0);

  plotflags=getappdata(pde_fig,'plotflags');
  % [colvar colstyle heightvar heightstyle vectorvar vectorstyle
  % colval doplot xyplot showmesh animationflag popupvalue  
  % colflag contflag heightflag vectorflag deformflag deformvar]

  doplot=plotflags(8);
  colstyle=plotflags(2);
  heightstyle=plotflags(4);
  vectorstyle=plotflags(6);
  colval=plotflags(7);
  xy=plotflags(9);
  showmesh=plotflags(10);
  animate=plotflags(11);
  colflag=plotflags(13);
  contflag=plotflags(14);
  heightflag=plotflags(15);
  vectorflag=plotflags(16);
  deformflag=plotflags(17);

  % Get all the necessary data:
  uu=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEPlotMenu'),...
      'UserData');
  if isempty(uu),
    set(pde_fig,'Pointer','arrow')
    drawnow
    return
  end
  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
  he=findobj(get(h,'Children'),'flat','Tag','PDERefine');
  ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
  p=get(hp,'UserData'); e=get(he,'UserData'); t=get(ht,'UserData');
  params=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEPDEMenu'),...
      'UserData');
  ns=getappdata(pde_fig,'ncafd');
  nc=ns(1);
  c=params(1:nc,:);

  appl=getappdata(pde_fig,'application');
  if appl==1 || appl>4,
    syst=0;
  else
    syst=1;
  end
 
  currparams=getappdata(pde_fig,'currparam');

  pde_type=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEHelpMenu'),'UserData');

  if pde_type==2 || pde_type==3 || pde_type==4,
    n=plotflags(12);
    u=uu(:,n);
  else
    u=uu;
  end

  timeeigparam=getappdata(pde_fig,'timeeigparam');
  if pde_type==2 || pde_type==3,
    % parabolic or hyperbolic PDE
    time=eval(timeeigparam(1,:));
    time=time(n);
  else
    time=[];
  end

  baddata=0;
  xydata=[];
  zdata=[];
  flowdata=[];
  deformdata=[];

  % xydata:
  if colflag || (contflag && ~heightflag),
    [xydata,xystr]=pdeptdata(plotflags(1),1,p,e,t,c,u,appl,...
    currparams,hndls,time);
    if isnan(xydata),
      baddata=1;
    end
  elseif contflag && heightflag
    [xydata,xystr]=pdeptdata(plotflags(3),2,p,e,t,c,u,appl,...
    currparams,hndls,time);
    if isnan(xydata),
      baddata=1;
    end
  end
  if colflag,
    if colstyle==1,
      % interpolated shading
      xystyle='interp';
    elseif colstyle==2,
      % flat shading
      xystyle='flat';
    end
  else
    xystyle='off';
  end
  if contflag,
    cont='on';
  else
    cont='off';
  end

  if heightflag && ~baddata,
    [zdata,zstr]=pdeptdata(plotflags(3),2,p,e,t,c,u,appl,...
    currparams,hndls,time);
    if isnan(zdata),
      baddata=1;
    end
    if heightstyle==1,
      % continuous surface
      zstyle='continuous';
    elseif heightstyle==2,
      % discontinuous surface
      zstyle='discontinuous';
    end
  else
    zstyle='off';
  end

  if vectorflag && ~baddata,
    [flowdata,flowstr]=...
      pdeptdata(plotflags(5),3,p,e,t,c,u,appl,currparams,hndls,time);
    if isnan(flowdata),
      baddata=1;
    end
    if vectorstyle==1,
      % arrow
      flowstyle='arrow';
    elseif vectorstyle==2,
      % normalized arrow
      if ~isempty(flowdata),
        xcomp=flowdata(1,:);
        ycomp=flowdata(2,:);
        denom=sqrt(xcomp.^2+ycomp.^2);
        flowdata=[xcomp./denom; ycomp./denom];
      end
      flowstyle='arrow';
    end
  else
    flowstyle='off';
  end

  if deformflag && ~baddata,
  % deformed plot (displacements)
    [deformdata,deformstr]=...
      pdeptdata(plotflags(18),4,p,e,t,c,u,appl,currparams,hndls,time);
    if isnan(deformdata),
      baddata=1;
    else
      deformdata=reshape(deformdata,size(p,2),2);
      if all(deformdata==0),
        uvfact=0;
      else
        uvfact=max(max(p(1,:))-min(p(1,:)),max(p(2,:))-min(p(2,:)))*...
          0.1/max(max(abs(deformdata(:,1)),abs(deformdata(:,2))));
      end
      xadd=deformdata(:,1)*uvfact;
      yadd=deformdata(:,2)*uvfact;
      p=p+[xadd';yadd'];
      setappdata(pde_fig,'meshdef',[xadd';yadd']);
    end
  end

  if (strcmp(xystyle,'off') && strcmp(zstyle,'off') && strcmp(flowstyle,'off')...
    && strcmp(cont,'off') && ~deformflag) || baddata,
    % No plotting needed
    pdeinfo
    set(pde_fig,'Pointer','arrow')
    drawnow
    return
  end

  if colval==1,
    colormap='cool(64)';
  elseif colval==2,
    colormap='gray(64)';
  elseif colval==3,
    colormap='bone(64)';
  elseif colval==4,
    colormap='pink(64)';
  elseif colval==5,
    colormap='copper(64)';
  elseif colval==6,
    colormap='hot(64)';
  elseif colval==7,
    colormap='jet(64)';
  elseif colval==8,
    colormap='hsv(64)';
  elseif colval==9,
    colormap='prism(64)';
  end

  if xy,
    xygrid='on';
  else
    xygrid='off';
  end

  if showmesh,
    mesh='on';
  else
    mesh='off';
  end

  complexsol=0;
  if (~isreal(xydata) && ~isempty(xydata)),
    complexsol=1;
    xydata=real(xydata);
  end
  if (~isreal(zdata) && ~isempty(zdata)),
    complexsol=1;
    zdata=real(zdata);
  end
  if (~isreal(flowdata) && ~isempty(flowdata)),
    complexsol=1;
    flowdata=real(flowdata);
  end
  if (~isreal(deformdata) && ~isempty(deformdata)),
    complexsol=1;
    deformdata=real(deformdata);
  end

  err = 0;
  if animate && ~replay && (pde_type==2 || pde_type==3)
    % Animate solution

    infostring='Animation recording in progress.';
    pdeinfo(infostring,0)

    cmap=eval(colormap);

    % Find a figure to play the movie in:
    figs=findobj(get(0,'Children'),'flat','HandleVisibility','on');
    moviefig=[];
    for i=1:length(figs)
      npl=get(figs(i),'Nextplot');
      if npl(1)=='a',
        if isempty(findobj(get(figs(i),'Children'))),
          moviefig=figs(i);
          figure(moviefig)
          set(moviefig,'Colormap',cmap,'Nextplot','replace')
          break;
        end
      elseif npl(1)=='r',
        moviefig=figs(i);
        figure(moviefig)
        clf reset
        set(moviefig,'Colormap',cmap) 
        break;
     end
    end
    if isempty(moviefig),
      moviefig=figure('Colormap',cmap,'Nextplot','replace');
    end

    n=size(uu,2);
 
    trx=0; trz=0;
    % Preallocate plotdata matrices:
    if ~strcmp(xystyle,'off')
      [xydtst,xystr]=...
         pdeptdata(plotflags(1),1,p,e,t,c,uu(:,1),appl,currparams,hndls,time);
      if size(xydtst,2)>1
        xydata=zeros(size(xydtst,2),size(uu,2));
        trx=1;
      else
        xydata=zeros(size(uu));
      end
    elseif contflag,
      [xydtst,xystr]=...
         pdeptdata(plotflags(3),2,p,e,t,c,uu(:,1),appl,currparams,hndls,time);
      if size(xydtst,2)>1
        xydata=zeros(size(xydtst,2),size(uu,2));
        trx=1;
      else
        xydata=zeros(size(uu));
      end
    else
      xydata=zeros(1,n);
    end
    if ~strcmp(zstyle,'off')
      [zdtst,zstr]=...
         pdeptdata(plotflags(3),2,p,e,t,c,uu(:,1),appl,currparams,hndls,time);
      if size(zdtst,2)>1
        zdata=zeros(size(zdtst,2),size(uu,2));
        trz=1;
      else
        zdata=zeros(size(uu));
      end
    else
      zdata=zeros(1,n);
    end

    for j=1:n,
      u=uu(:,j);
      if ~strcmp(xystyle,'off'),
        if trx,
          xydata(:,j)=...
            pdeptdata(plotflags(1),1,p,e,t,c,u,appl,currparams,hndls,time)';
        else
          xydata(:,j)=...
            pdeptdata(plotflags(1),1,p,e,t,c,u,appl,currparams,hndls,time);
        end
      elseif contflag,
        if trx,
          xydata(:,j)=...
            pdeptdata(plotflags(3),2,p,e,t,c,u,appl,currparams,hndls,time)';
        else
          xydata(:,j)=...
            pdeptdata(plotflags(3),2,p,e,t,c,u,appl,currparams,hndls,time);
        end
      end
      if (~isreal(xydata) && ~isempty(xydata)),
        complexsol=1;
        xydata=real(xydata);
      end
      if ~strcmp(zstyle,'off'),
        if trz,
          zdata(:,j)=...
            pdeptdata(plotflags(3),2,p,e,t,c,u,appl,currparams,hndls,time)';
        else
          zdata(:,j)=...
            pdeptdata(plotflags(3),2,p,e,t,c,u,appl,currparams,hndls,time);
        end
        if (~isreal(zdata) && ~isempty(zdata)),
          complexsol=1;
          zata=real(zdata);
        end
      end
    end
   
    if ~strcmp(zstyle,'off'),
      maxu=max(max(zdata)); minu=min(min(zdata));
    elseif ~strcmp(xystyle,'off') || contflag,
      maxu=max(max(xydata)); minu=min(min(xydata));
    else
      maxu=max(max(uu)); minu=min(min(uu));
    end
    if ~isreal(maxu), maxu=real(maxu); end
    if ~isreal(minu), minu=real(minu); end
    if maxu==minu, maxu=minu+1; end
    maxx=max(p(1,:)); maxy=max(p(2,:));
    minx=min(p(1,:)); miny=min(p(2,:));

    axes('XLimMode','manual','XLim',[minx maxx],'YLimMode','manual',...
      'Ylim',[miny maxy],'ZLimMode','manual','ZLim',[minu maxu])
    axis equal

    if xy,
      % Call tri2grid once to get triangle list and interpolation params:

      xmin=min(p(1,t)); xmax=max(p(1,t));
      ymin=min(p(2,t)); ymax=max(p(2,t));

      nt=size(t,2);
      nxy=ceil(sqrt(nt/2))+1;
      x=linspace(xmin,xmax,nxy);
      y=linspace(ymin,ymax,nxy);

      tstarray=zeros(size(p,2),1);
      [unused,tn,a2,a3]=tri2grid(p,t,tstarray,x,y);
      gridparam=[tn; a2; a3];
    end

    if strcmp(zstyle,'off'),
      view(2)
    else
      view(3)
    end

    if ~strcmp(xystyle,'off')
      maxu=max(max(xydata)); minu=min(min(xydata));
    elseif contflag && ~strcmp(zstyle,'off')
      maxu=max(max(zdata)); minu=min(min(zdata));
    else
      maxu=max(max(uu)); minu=min(min(uu));
    end
    caxis([minu maxu]);
    if ~strcmp(xystyle,'off') || contflag,
      hc = colorbar;
      set(hc,'HandleVisibility','off');
      gothc = 1;
    else
      gothc = 0;
    end

    M=moviein(n,moviefig);

    for j=1:n,
      u=uu(:,j);
      if ~strcmp(flowstyle,'off'),
        [flowdata,flowstr]=...
          pdeptdata(plotflags(5),3,p,e,t,c,u,appl,currparams,hndls,time);
        if (~isreal(flowdata) && ~isempty(flowdata)),
          complexsol=1;
          flowdata=real(flowdata);
        end
      end
      
      hold on;
      caxis([minu maxu]);
      if xy,
        try
            h=pdeplot(p,e,t,'xydata',xydata(:,j),'xystyle',xystyle,...
              'zdata',zdata(:,j),'zstyle',zstyle,...
              'flowdata',flowdata,'flowstyle',flowstyle,...
              'colormap',colormap,'intool','off',...
              'xygrid',xygrid,'mesh',mesh,...
              'contour',cont,'colorbar','off','levels',lvl,...
              'gridparam',gridparam);
        catch
            err=1;
        end
      else
          try
              h=pdeplot(p,e,t,'xydata',xydata(:,j),'xystyle',xystyle,...
              'zdata',zdata(:,j),'zstyle',zstyle,...
              'flowdata',flowdata,'flowstyle',flowstyle,...
              'colormap',colormap,'intool','off',...
              'xygrid',xygrid,'mesh',mesh,...
              'contour',cont,'colorbar','off','levels',lvl);
          catch
              err=1;
          end
      end

      if err
        pdetool('error',lasterr);

        pdeinfo
        set(pde_fig,'Pointer','arrow')
        drawnow
        close(moviefig)
        return
      end
        
      axis equal
      hold off;

      M(:,j)=getframe(moviefig);
      infostring=[infostring, '.'];
      pdeinfo(infostring,0);
      delete(h);
    end

    set(moviefig,'NextPlot','replace')

    pdeinfo('Movie playing...',0);

    movie(moviefig,M,animparams(2),animparams(1));

    % enable export
    setappdata(pde_fig,'movie',M)
    plothndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEPlotMenu');
    set(findobj(get(plothndl,'Children'),'flat','Tag','PDEExpMovie'),...
        'Enable','on')

    if gothc
      set(hc,'HandleVisibility','on');
    end
    
  elseif replay && (pde_type==2 || pde_type==3)

    % replay the movie

    cmap=eval(colormap);

    % Find a figure to play the movie in:
    moviefig=[];
    figs=findobj(get(0,'Children'),'flat','HandleVisibility','on');
    for i=1:length(figs)
      npl=get(figs(i),'Nextplot');
      if npl(1)=='a',
        if isempty(findobj(get(figs(i),'Children'))),
          moviefig=figs(i);
          figure(moviefig)
          set(moviefig,'Colormap',cmap,'Nextplot','replace')
          break;
        end
      elseif npl(1)=='r',
        moviefig=figs(i);
        figure(moviefig)
        clf reset
        set(moviefig,'Colormap',cmap) 
        break;
     end
    end
    if isempty(moviefig),
      moviefig=figure('Colormap',cmap,'Nextplot','replace');
    end

    M=getappdata(pde_fig,'movie');
    set(moviefig,'NextPlot','replace')

    pdeinfo('Movie playing....',0);

    movie(moviefig,M,animparams(2),animparams(1));

  else
    % just plot the solution:

    % set applicable plot title
    if pde_type==1,
      namestr='';
    elseif pde_type==2 || pde_type==3,
      timepar=getappdata(pde_fig,'timeeigparam');
      tlist=str2num(deblank(timepar(1,:)));
      namestr=['Time=', num2str(time)];
    elseif pde_type==4,
      winhndl=findobj(get(pde_fig,'Children'),'flat',...
          'Tag','winmenu');
      eigvals=get(winhndl,'UserData');
      namestr=['Lambda(', int2str(n), ')=', num2str(eigvals(n))];
    end
    
    title=[namestr, ' '];
    if ~strcmp(xystyle,'off'),
      title=[title, '  Color: ', xystr];
    elseif strcmp(cont,'on'),
      if strcmp(zstyle,'off'),
        title=[title, '  Contour: ', xystr];
      else
        title=[title, '  Contour: ', zstr];
      end
    end

    if strcmp(zstyle,'off')
      % turn off Select all if plotting in PDE Toolbox axes and
      % make sure that the main axes are current
      edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
      set([edithndl ...
           findobj(get(edithndl,'Children'),'flat','Tag','PDESelall')],...
          'Enable','off')
      ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
      set(pde_fig,'CurrentAxes',ax)
      flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
      flags=get(flg_hndl,'UserData');
      flags(2)=3;                               % mode_flag=3
      set(flg_hndl,'UserData',flags)
      setappdata(pde_fig,'xydata',xydata);
      setappdata(pde_fig,'xystr',xystr);

      % Enable clicking on solution plot to get info:
      set(pde_fig,'WindowButtonDownFcn','pdeinfclk(2)',...
      'WindowButtonUpFcn','if pdeonax, pdeinfo; end')
    else
      title=[title, '  Height: ', zstr];
    end

    if vectorflag,
      title=[title, '  Vector field: ', flowstr];
    end
    if deformflag,
      title=[title, '  Displacement: ', deformstr];     
    end
    try
        pdeplot(p,e,t,'xydata',xydata,'xystyle',xystyle,...
          'zdata',zdata,'zstyle',zstyle,'flowdata',flowdata,...
          'flowstyle',flowstyle,'colormap',colormap,...
          'intool','on','xygrid',xygrid,'mesh',mesh,...
          'title',title,'contour',cont,'levels',lvl);
    catch
         err=1;
    end

  end
  
  if err
    pdetool('error',lasterr);
  end

  if complexsol,
    warnmsg = ...
    '  Warning: Imaginary part of complex property was ignored when plotting.';
    h=warndlg(warnmsg,'PDE Toolbox Warning');
    set(h,'Tag','PDEWarnDlg')
  end

  pdeinfo

  set(pde_fig,'Pointer','arrow')
  drawnow

%
% case: done (update parameters, don't plot)

elseif strcmp(action,'done')

  fig=findobj(allchild(0),'flat','Tag','PDEPlotFig');
  hndls=get(fig(1),'UserData');
  % Stored in UserData array:
  % 1-6:   handles plot type checkboxes
  % 7-10:  handles to visualization property popup-menus
  % 11:    handle to pushbutton for animation options dialog box
  % 12-15: handles to user entry edit boxes
  % 16-18: handles to plot style selection popup-menus
  % 19-20: handles to mesh options (x-y, off) checkboxes
  % 21:    handle to 'Plot solution automatically'-checkbox
  % 22:    handle to color selection popup menu
  % 23-24: handles to the time(eigenvalue) text ui control and its popup
  %        ui control
  % 25:    handle to contour level edit box
  % 26:    application mode

  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');

  str=get(hndls(22),'String');
  colval=get(hndls(22),'Value');
  cmap=eval([deblank(str(colval,:)), '(64)']);
  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  set(get(ax,'YLabel'),'UserData',cmap)

  % Collect information to update plotflags:
  doplot=get(hndls(21),'Value');
  colflag=get(hndls(1),'Value');
  contflag=get(hndls(2),'Value');
  vectorflag=get(hndls(3),'Value');
  deformflag=get(hndls(4),'Value');
  heightflag=get(hndls(5),'Value');
  colvar=get(hndls(7),'Value');
  vectorvar=get(hndls(8),'Value');
  deformvar=get(hndls(9),'Value');
  heightvar=get(hndls(10),'Value');
  colstyle=get(hndls(16),'Value');
  vectorstyle=get(hndls(17),'Value');
  heightstyle=get(hndls(18),'Value');
  xyplot=get(hndls(19),'Value');
  showmesh=get(hndls(20),'Value');
  animate=get(hndls(6),'Value');
  popval=get(hndls(24),'Value');

  setappdata(pde_fig,'plotflags',[colvar colstyle heightvar heightstyle ...
    vectorvar vectorstyle colval doplot xyplot showmesh animate popval ...
    colflag contflag heightflag vectorflag deformflag deformvar]);
  % [colvar colstyle heightvar heightstyle vectorvar vectorstyle
  % colval doplot xyplot showmesh animationflag popupvalue  
  % colflag contflag heightflag vectorflag deformflag deformvar] 
  setappdata(pde_fig,'colstring',get(hndls(12),'string'))
  setappdata(pde_fig,'arrowstring',get(hndls(13),'string'))
  setappdata(pde_fig,'deformstring',get(hndls(14),'string'))
  setappdata(pde_fig,'heightstring',get(hndls(15),'string'))

  pdeinfo

%
% case: cancel

elseif strcmp(action,'cancel')

  set(gcbf,'Visible','off')

  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
  set(0,'CurrentFigure',pde_fig)
  pdeinfo

end
