function pdedlg(action,flag,type,typerange,equstr,parstr,valstr,descrstr)
%PDEDLG Manages the PDE specification dialog box for the PDE Toolbox
%
%       Called from PDETOOL when clicking on the
%       'specify PDE'-button or selecting PDE Specification...
%       from the PDE Menu.
%
%       PDEDLG(ACTION,FLAG,TYPE,TYPERANGE,EQUSTR,PARSTR,VALSTR,DESCRSTR)
%
%       ACTION and FLAG are used to control the figure events.
%       TYPE is the type of PDE; TYPERANGE is a vector of
%       admissible PDE types for the current PDE Toolbox application.
%       EQUSTR, PARSTR, VALSTR, and DESCRSTR are string matrices containing
%       equation, coefficient names, current values, and coefficient
%       descriptions, respectively.
%
%       See also: PDETOOL

%       Magnus Ringh 7-29-94, MR 9-14-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.2 $  $Date: 2003/11/01 04:28:11 $

if nargin<1
  error('PDE:pdedlg:nargin', 'Too few input arguments.');
end

%
% case: bring up PDE specification dialog box, initialize

if strcmp(action,'initialize')

  % Stored in UserData array:
  % 1: n = number of coefficient rows
  % 2: handle to equation text
  % 3..6:handles to the PDE Type radio buttons (elliptic, parabolic,
  % hyperbolic,eigenmodes)
  % 7..6+n: handles to coefficient strings
  % 7+n..6+2*n: handles to the coefficient value edit fields
  % 7+2*n..6+3*n: handles to coefficient description text

  pdeinfo('Specify type of PDE and applicable coefficients.');

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  appl=getappdata(pde_fig,'application');

  % set up the PDE specification dialog box
  DlgName='PDE Specification';
  if figflag(DlgName),
    drawnow
    return
  end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  bt1=getappdata(pde_fig,'bt1');
  nbt1=size(bt1,1);
  boundh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');

  subs=getappdata(ax,'subsel');
  flagh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flagh,'UserData'); mode_flag=flags(2);
  if isempty(subs) || mode_flag<4,
    hndl=findobj(get(ax,'Children'),'flat','Tag','PDESelRegion');
    set(hndl,'color','k')
    setappdata(ax,'subsel',1:nbt1)
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

  n=size(parstr,1);
  numoflines=3+max(n,4);
  FigWH = [(72-smallScreen*17)*mCharacterWidth ...
          numoflines*(BWH(2)+Voff)-Voff] ...
          +[2*(mEdgeToFrame+mFrameToText)+2*(BWH(1)+mFrameToText) ...
          mLineHeight+BWH(2)+Voff+6*mEdgeToFrame];
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
      'Tag','PDESpecFig');

  % Make the 4 frame uicontrols
  UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 0 FigWH(1) BWH(2)+mLineHeight];
  uicontrol(fig,'Style','frame','Position',UIPos);
  UIPos = [UIPos(1:2)+[0 UIPos(4)+mEdgeToFrame] ...
          0.26*FigWH(1)-2*mEdgeToFrame ...
          (numoflines-1)*(BWH(2)+Voff-mEdgeToFrame)];
  uicontrol(fig,'Style','frame','Position',UIPos);
  UIPos = [UIPos(1)+UIPos(3)+2*mEdgeToFrame UIPos(2) ...
          0.74*FigWH(1)-2*mEdgeToFrame UIPos(4)];
  uicontrol(fig,'Style','frame','Position',UIPos);
  UIPos = mEdgeToFrame*[1 1 -2 -2] + [0 UIPos(2)+UIPos(4) FigWH(1)...
          BWH(2)+mLineHeight-2*mEdgeToFrame];
  uicontrol(fig,'Style','frame','Position',UIPos);

  % Make the text, checkbox, and edit check uicontrol(s)
  UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-2*Voff ...
          FigWH(1)*0.15-2*mEdgeToFrame-2*mFrameToText mLineHeight];
  UIPos = UIPos - [0 BWH(2) 0 0];
  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Equation:');
  UIPos = UIPos + ...
      [FigWH(1)*0.15 0 FigWH(1)*0.75-2*mEdgeToFrame-2*mFrameToText 0];
  eq_hndl=uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String',equstr);

  UIPos = [mEdgeToFrame+mFrameToText FigWH(2)-mEdgeToFrame-Voff ...
          (22-5*smallScreen)*mCharacterWidth mLineHeight];
  UIPos = UIPos - [0 2*BWH(2)+Voff+mFrameToText 0 0];
  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Type of PDE:');

  StrMtx=str2mat('Elliptic','Parabolic','Hyperbolic','Eigenmodes');
  UIPos = UIPos - [0 Voff 0 0];

  pde_type=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEHelpMenu'),...
      'Userdata');
  type_hndl=zeros(4,1);

  for i=1:4,
    if any(find(i==typerange)),
      enab='on';
    else
      enab='off';
    end
    UIPos = UIPos - [0 BWH(2) 0 0];
    type_hndl(i)=uicontrol(fig,'Style','Radio','Value',i==pde_type,...
        'HorizontalAlignment','left','Position',UIPos,...
        'Enable',enab,'String',StrMtx(i,:));
    UIPos = UIPos - [0 Voff 0 0];
  end
  call=['me=gco;','if(get(me,''Value'')==1),',...
        'set(get(me,''UserData''),''Value'',0),',...
        'else,',...
        'set(me,''Value'',1),',...
        'end; clear me'];
  for i=1:4,
    set(type_hndl(i),...
        'CallBack',[call, '; pdedlg(''type_cb'',', int2str(i),')'],...
        'UserData',type_hndl([1:(i-1),(i+1):4]))
  end

  UIPos = [UIPos(1)+0.26*FigWH(1)+2*mEdgeToFrame ...
          FigWH(2)-mEdgeToFrame-2*(BWH(2)+Voff)-mFrameToText ...
          10*mCharacterWidth UIPos(4)];
  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Coefficient');

  UIPos = UIPos - [0 Voff 0 0];
  param_hndl=zeros(n,1);

  for i=1:n,
    UIPos = UIPos - [0 BWH(2) 0 0];
    param_hndl(i)=uicontrol(fig,'Style','text',...
        'HorizontalAlignment','left','Position',UIPos',...
        'String',deblank(parstr(i,:)));
    UIPos = UIPos - [0 Voff 0 0];
  end

  UIPos = [UIPos(1)+0.15*FigWH(1)+2*mEdgeToFrame ...
          FigWH(2)-mEdgeToFrame-2*(BWH(2)+Voff)-mFrameToText ...
          (20-5*smallScreen)*mCharacterWidth UIPos(4)];
  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String','Value');

  UIPos = UIPos - [0 Voff 0 0];
  edit_hndl=zeros(n,1);

  for i=1:n,
    UIPos = UIPos - [0 BWH(2) 0 0];
    edit_hndl(i)=uicontrol(fig,'Style','edit',...
        'HorizontalAlignment','left','Position',UIPos',...
        'Backgroundcolor','w','String',deblank(valstr(i,:)),...
        'UserData',i,'Tag',deblank(valstr(i,:)));
    UIPos = UIPos - [0 Voff 0 0];
  end

  style_str='text';
  field_length=(28-5*smallScreen)*mCharacterWidth;
  backgr_col=DefUIBgColor;
  cb='';
  uistr=descrstr;
  if isempty(descrstr),
    if n==7                             %This must be 'Generic system case'
      str='Value';
      style_str='edit';
      field_length=(20-5*smallScreen)*mCharacterWidth;
      backgr_col='w';
      uistr=valstr(n+1:2*n,:);
      cb='pdedlg(''paramchk'')';
    else
      str='';
    end
  else
    str='Description';
  end
  UIPos = [UIPos(1)+0.25*FigWH(1)+2*mEdgeToFrame ...
          FigWH(2)-mEdgeToFrame-2*(BWH(2)+Voff)-mFrameToText ...
          field_length UIPos(4)];
  uicontrol(fig,'Style','text','Position',UIPos,...
      'HorizontalAlignment','left','String',str)

  UIPos = UIPos - [0 Voff 0 0];
  descr_hndl=zeros(n,1);

  for i=1:n,
    UIPos = UIPos - [0 BWH(2) 0 0];
    descr_hndl(i)=uicontrol(fig,'Style',style_str,...
        'HorizontalAlignment','left','Position',UIPos',...
        'Backgroundcolor',backgr_col,...
        'String',deblank(uistr(i,:)),...
        'Callback',cb);
    UIPos = UIPos - [0 Voff 0 0];
  end

  % Make the pushbuttons
  Hspace = (FigWH(1)-2*BWH(1))/3;
  if appl==2,
    flagval=14;
  else
    flagval=n;
  end
  OKFcn = sprintf('pdedlg(''ok'',%i)',flagval);
  uicontrol(fig,'Style','push','String','OK',...
      'Callback',OKFcn,'Position',[Hspace mLineHeight/2 BWH]);
  CancelFcn = 'pdedlg(''cancel'')';
  uicontrol(fig,'Style','push','String','Cancel',...
      'Callback',CancelFcn,'Position',[2*Hspace+BWH(1) mLineHeight/2 BWH]);

  hndls=[n eq_hndl type_hndl' param_hndl' edit_hndl' descr_hndl'];
  set(fig,'UserData',hndls)

  % Set enable statuses according to current PDE type:
  pdedlg('type_cb',pde_type)

  % Finally, make all the uicontrols normalized and the figure visible
  set(get(fig,'Children'),'Unit','norm')
  set(fig,'Visible','on')

  drawnow

%
% case: type selection callback action

elseif strcmp(action,'type_cb')

  fig=gcf;
  hndls=get(fig,'UserData');
  n=hndls(1);

  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
  appl=getappdata(pde_fig,'application');

  if appl==1,
    fi1=9;
    fi2=13;
    di1=10;
    di2=14;
  elseif appl==2,
    fi1=11;
    fi2=[18, 25];
    di1=12:13;
    di2=[19:20, 26:27];
  elseif appl==9,
    fi1=10:12;
    fi2=[16:18, 22:24];
    di1=7:8;
    di2=[13:14, 19:20];
  elseif appl==10,
    fi1=8;
    fi2=[10, 12];
    di1=[];
    di2=[];
  else
    return;
  end

  if flag==1,
    % case: elliptic PDE
    if appl==1 | appl==2,
      equ='-div(c*grad(u))+a*u=f';
    elseif appl==9,
      equ='-div(k*grad(T))=Q+h*(Text-T), T=temperature';
    elseif appl==10,
      equ='-div(D*grad(c))=Q, c=concentration';
    end
    setappdata(pde_fig,'equation',equ)
    set(hndls(2),'String',equ)
    set(hndls(fi1),'Enable','on')
    set(hndls(di1),'Enable','off')
    set(hndls(fi2),'Enable','on')
    set(hndls(di2),'Enable','off')
  elseif flag==2,
    % case: parabolic PDE
    if appl==1 | appl==2,
      equ='d*u''-div(c*grad(u))+a*u=f';
    elseif appl==9,
      equ='rho*C*T''-div(k*grad(T))=Q+h*(Text-T), T=temperature';
    elseif appl==10,
      equ='c''-div(D*grad(c))=Q, c=concentration';
    end
    setappdata(pde_fig,'equation',equ)
    set(hndls(2),'String',equ);
    set(hndls(fi1),'Enable','on')
    set(hndls(di1),'Enable','on')
    set(hndls(fi2),'Enable','on')
    set(hndls(di2),'Enable','on')
  elseif flag==3,
    % case: hyperbolic PDE
    equ='d*u''''-div(c*grad(u))+a*u=f';
    setappdata(pde_fig,'equation',equ)
    set(hndls(2),'String',equ);
    set(hndls(fi1),'Enable','on')
    set(hndls(di1),'Enable','on')
    set(hndls(fi2),'Enable','on')
    set(hndls(di2),'Enable','on')
  elseif flag==4,
    % case: PDE eigenvalue problem
    equ='-div(c*grad(u))+a*u=lambda*d*u';
    setappdata(pde_fig,'equation',equ)
    set(hndls(2),'String','-div(c*grad(u))+a*u=lambda*d*u');
    set(hndls(fi1),'Enable','off')
    set(hndls(di1),'Enable','on')
    set(hndls(fi2),'Enable','off')
    set(hndls(di2),'Enable','on')
  end

%
% case: OK

elseif strcmp(action,'ok')

  fig=gcf;
  pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');

  hndls=get(fig,'UserData');
  % Stored in UserData array:
  % 1: n = number of coefficient rows
  % 2: handle to equation text
  % 3..6:handles to the PDE Type radio buttons (elliptic, parabolic,
  % hyperbolic,eigenmodes)
  % 7..6+n: handles to coefficient strings
  % 7+n..6+2*n: handles to the coefficient value edit fields
  % 7+2*n..6+3*n: handles to coefficient description text

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  bt1=getappdata(pde_fig,'bt1');
  nbt1=size(bt1,1);
  boundh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  dl=get(boundh,'UserData');

  subs=getappdata(ax,'subsel');
  if isempty(subs),
    % If no subdomain selected, apply to all subdomains
    nsub=nbt1;
    subs=1:nsub;
  else
    nsub=length(subs);
  end

  n=hndls(1);

  if get(hndls(3),'Value')==1,
    pde_type=1;
  elseif get(hndls(4),'Value')==1,
    pde_type=2;
  elseif get(hndls(5),'Value')==1,
    pde_type=3;
  elseif get(hndls(6),'Value')==1,
    pde_type=4;
  end

  % Compare new and old type; if any change, set flag5
  typeh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEHelpMenu');
  oldtype=get(typeh,'UserData');
  if pde_type~=oldtype,
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(h,'UserData'); flags(1)=1; flags(6)=0; flags(7)=1;
    set(h,'UserData',flags)
    set(typeh,'UserData',pde_type)
  end

  paramh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEPDEMenu');
  oldpar=get(paramh,'UserData');

  params=getappdata(pde_fig,'currparam');
  if ~isempty(findstr(params(1,:),'!')),
    % For comparison, get one selected subdomain's values
    k=subs(1);
    for i=1:size(params,1),
      str=params(i,:);
      for j=1:k,
        [tmps,str]=strtok(str,'!');
      end
      if i==1,
        extrpar=tmps;
      else
        extrpar=str2mat(extrpar,tmps);
      end
    end
  else
    extrpar=params;
  end

  newparams=get(hndls(7+n),'String');
  if ~isempty(newparams)
    if find(newparams=='!'),
      pdetool('error','  Coefficient values including ''!'' are not allowed.')
      set(hndls(7+n),'String',get(hndls(7+n),'Tag'))
      return
    end
  else
    pdetool('error','  Coefficient value must not be an empty string.')
    set(hndls(7+n),'String',get(hndls(7+n),'Tag'))
    return
  end
  for i=2:flag
    tmps=get(hndls(6+n+i),'String');
    if ~isempty(tmps)
      if find(tmps=='!'),
        pdetool('error','  Coefficient values including ''!'' are not allowed.')
        set(hndls(6+n+i),'String',get(hndls(6+n+i),'Tag'))
        return
      end
      newparams=str2mat(newparams,tmps);
    else
      pdetool('error','  Coefficient value must not be an empty string.')
      set(hndls(6+n+i),'String',get(hndls(6+n+i),'Tag'))
      return
    end
  end

  % Compare new and old coefficients and type; if any change, set flag5
  typeh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEHelpMenu');
  oldtype=get(typeh,'UserData');
  if pde_type==oldtype,
    if all(size(newparams)==size(extrpar)),
      if all(newparams==extrpar),
        change=0;
      else
        change=1;
      end
    else
      change=1;
    end
  else
    change=1;
  end
  if ~change
    % Check if moving from subdomain oriented to homogeneous or back
    if nsub<nbt1,
      if isempty(findstr(params(1,:),'!')),
        change=1;
      end
    else
      if ~isempty(findstr(params(1,:),'!')),
        change=1;
      end
    end
  end

  % convert to standard pde coefficients (c,a,f,d)
  oldnc=getappdata(pde_fig,'ncafd'); oldnc=oldnc(1);
  appl=getappdata(pde_fig,'application');
  try
    convparams=pdetrans(newparams,appl);
  catch
    pdetool('error',lasterr);
    return
  end
  ncafd=getappdata(pde_fig,'ncafd'); nc=ncafd(1);
  n=size(convparams,1);

  % Check size of c coefficient and adjust to max(oldnc,nc) (scalar case only)
  if oldnc~=nc & max(nc,oldnc)>4 & nsub<nbt1,
    pdetool('error',' For system cases, subdomains must have consistent c matrices')
    ncafd=getappdata(pde_fig,'ncafd'); ncafd(1)=oldnc;
    setappdata(pde_fig,'ncafd',ncafd)
    return;
  end

  % If this is for subdomains only, arrange accordingly:
  if nsub<nbt1,
    mm=size(oldpar,1);
    zerostr='0';
    if oldnc==1,
      nbangs=length(find(oldpar(1,:)=='!'));
      for i=1:nbangs,
        zerostr=[zerostr, '!0'];
      end
      if nc==2,
        oldpar=[oldpar(1,:); oldpar(1,:); oldpar(2:mm,:)];
      elseif nc==3,
        oldpar=str2mat(oldpar(1,:),zerostr,oldpar(1:mm,:));
      elseif nc==4
        oldpar=str2mat(oldpar(1,:),zerostr,zerostr,oldpar(1:mm,:));
      end
    elseif oldnc==2,
      if nc==1,
        nbangs=length(find(convparams(1,:)=='!'));
        for i=1:nbangs,
          zerostr=[zerostr, '!0'];
        end
        convparams=[convparams(1,:); convparams(1:n,:)];
      elseif nc==3,
        nbangs=length(find(oldpar(1,:)=='!'));
        for i=1:nbangs,
          zerostr=[zerostr, '!0'];
        end
        oldpar=str2mat(oldpar(1,:),zerostr,oldpar(2:mm,:));
      elseif nc==4,
        nbangs=length(find(oldpar(1,:)=='!'));
        for i=1:nbangs,
          zerostr=[zerostr, '!0'];
        end
        oldpar=str2mat(oldpar(1,:),zerostr,zerostr,oldpar(2:mm,:));
      end
    elseif oldnc==3,
      if nc==1,
        nbangs=length(find(convparams(1,:)=='!'));
        for i=1:nbangs,
          zerostr=[zerostr, '!0'];
        end
        convparams=str2mat(convparams(1,:),zerostr,convparams(1:n,:));
      elseif nc==2,
        nbangs=length(find(convparams(1,:)=='!'));
        for i=1:nbangs,
          zerostr=[zerostr, '!0'];
        end
        convparams=str2mat(convparams(1,:),zerostr,convparams(2:n,:));
      elseif nc==4,
        nbangs=length(find(oldpar(1,:)=='!'));
        for i=1:nbangs,
          zerostr=[zerostr, '!0'];
        end
        oldpar=[oldpar(1,:); oldpar(2,:); oldpar(2:mm,:)];
      end
    elseif oldnc==4,
      nbangs=length(find(convparams(1,:)=='!'));
      for i=1:nbangs,
        zerostr=[zerostr, '!0'];
      end
      if nc==1,
        convparams=str2mat(convparams(1,:),zerostr,zerostr,convparams(1:n,:));
      elseif nc==2,
        convparams=str2mat(convparams(1,:),zerostr,zerostr,convparams(2:n,:));
      elseif nc==3,
        convparams=[convparams(1,:); convparams(2,:); convparams(2:n,:)];
      end
    end

    n=size(convparams,1); m=size(params,1);

    if max(nc,oldnc)<=4,
      setappdata(pde_fig,'ncafd',[max(nc,oldnc), ncafd(2:4)])
    end

    % Are current coefficients subdomain-oriented?
    if isempty(findstr(params(1,:),'!'))
      for j=1:m,
        % Initialize bang-separated string
        tmps=[];
        for i=1:nbt1,
          tmps=[tmps, deblank(params(j,:)), '!'];
        end
        tmps=tmps(1:length(tmps)-1);
        if j==1,
          bangparam=tmps;
        else
          bangparam=str2mat(bangparam,tmps);
        end
      end
      for j=1:n,
        % Initialize bang-separated string
        tmps=[];
        for i=1:nbt1,
          tmps=[tmps, deblank(oldpar(j,:)), '!'];
        end
        tmps=tmps(1:length(tmps)-1);
        if j==1,
          bangparam2=tmps;
        else
          bangparam2=str2mat(bangparam2,tmps);
        end
      end
    else
      bangparam=params;
      bangparam2=oldpar;
    end
    for j=1:size(newparams,1),
      tmps=bangparam(j,:);
      for i=1:nsub,
        k=subs(i);
        bangs=findstr(tmps,'!');
        if k==1,
          tmps=[deblank(newparams(j,:)),...
                  tmps(bangs(1):length(tmps))];
        elseif k==nbt1,
          tmps=[tmps(1:bangs(k-1)),...
                  deblank(newparams(j,:))];
        else
          tmps=[tmps(1:bangs(k-1)),...
                  deblank(newparams(j,:)),...
                  tmps(bangs(k):length(tmps))];
        end
      end
      if j==1,
        finalparams=tmps;
      else
        finalparams=str2mat(finalparams,tmps);
      end
    end
    for j=1:n,
      tmps=bangparam2(j,:);
      for i=1:nsub,
        k=subs(i);
        bangs=findstr(tmps,'!');
        if k==1,
          tmps=[deblank(convparams(j,:)),...
                  tmps(bangs(1):length(tmps))];
        elseif k==nbt1,
          tmps=[tmps(1:bangs(k-1)),...
                  deblank(convparams(j,:))];
        else
          tmps=[tmps(1:bangs(k-1)),...
                  deblank(convparams(j,:)),...
                  tmps(bangs(k):length(tmps))];
        end
      end
      if j==1,
        stdparams=tmps;
      else
        stdparams=str2mat(stdparams,tmps);
      end
    end
  else
    finalparams=newparams;
    stdparams=convparams;
  end

  delete(fig)
  drawnow

  if change,
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(h,'UserData'); flags(1)=1; flags(6)=0; flags(7)=1;
    set(h,'UserData',flags)
  end

  % save new coefficients:
  setappdata(pde_fig,'currparam',finalparams)
  set(paramh,'UserData',stdparams)
  set(typeh,'UserData',pde_type)

  pdeinfo

%
% case: cancel

elseif strcmp(action,'cancel')

  delete(gcf);
  drawnow
  pdeinfo

end

