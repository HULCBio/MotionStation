function h=pdeplot(p,e,t,p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7,p8,v8,p9,v9,p10,v10,p11,v11,p12,v12,p13,v13,p14,v14)
%PDEPLOT Generic PDE Toolbox plot function.
%
%       H=PDEPLOT(P,E,T,P1,V1,...) displays a function of a solution to a PDE
%       defined on a mesh described by the point matrix P, edge matrix E, and
%       triangle matrix T. Handles to the drawn axes objects are returned in
%       the optional output argument H.
%
%       Valid property/value pairs include:
%
%       Property        Value/{Default}
%       ----------------------------------------------------------------
%       xydata          data (e.g., u, abs(c*grad u))
%       xystyle         off | flat | {interp} |
%       contour         {off} | on
%       zdata           data
%       zstyle          off | {continuous} | discontinuous
%       flowdata        data
%       flowstyle       off | {arrow}
%       colormap        name of valid colormap {'cool'} or color matrix
%       xygrid          {off} | on
%       gridparam       [tn; a2; a3] triangle index and interpolation params
%                       from earlier call to tri2grid
%       mesh            {off} | on
%       colorbar        off | {on}
%       title           string {''}
%       levels          no of contour levels or a vector specifying levels {10}
%
%       See also: PDECONT, PDEGPLOT, PDEMESH, PDESURF

%       Magnus Ringh 3-01-95, MR 16-08-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.14.4.3 $  $Date: 2003/11/18 03:11:39 $

% Error checks
nargs = nargin;
if nargs<3,
  error('PDE:pdeplot:nargin', 'Too few input arguments.')
elseif rem(nargs,2)~=1,
  error('PDE:pdeplot:NoParamPairs', 'Param value pairs expected.')
end

% Default values
xydata=[];
xystyle='interp';
zdata=[];
zstyle='continuous';
flowdata=[];
flowstyle='arrow';
cmap='cool';
intool='off';
xygrid='off';
mh='off';
cbar='on';
title='';
levels=10;
tn=[]; a2=[]; a3=[];
znodedata=0;
cont='off';

% Recover Param/Value pairs from argument list
for i=1:2:nargs-4,
  Param = eval(['p' int2str((i-1)/2 +1)]);
  Value = eval(['v' int2str((i-1)/2 +1)]);
  if ~ischar(Param),
    error('PDE:pdeplot:ParamNotString', 'Parameter must be a string.')
  elseif size(Param,1)~=1,
    error('PDE:pdeplot:ParamNumRowsOrEmpty',...
        'Parameter must be a non-empty single row string.')
  end
  switch lower(Param)
  case 'xydata'
    xydata = Value;
    if ischar(xydata),
      error('PDE:pdeplot:xydataNotVector', 'xydata must be a vector.')
    end
  case 'xystyle'
    xystyle=lower(Value);
    if ~ischar(xystyle),
      error('PDE:pdeplot:xystyleNotString', 'xystyle must be a string.')
    elseif ~(strcmp(xystyle,'off') || strcmp(xystyle,'flat') || ...
          strcmp(xystyle,'interp')),
      error('PDE:pdeplot:xystyleInvalidOption', 'xystyle must be off | flat | interp')
    end
  case 'zdata'
    zdata = Value;
    if ischar(zdata),
      error('PDE:pdeplot:ZdataNotVector', 'zdata must be a vector.')
    end
  case 'zstyle'
    zstyle=lower(Value);
    if ~ischar(zstyle),
      error('PDE:pdeplot:ZstyleNotString', 'zstyle must be a string.')
    elseif ~(strcmp(zstyle,'off') || strcmp(zstyle,'continuous') || ...
          strcmp(zstyle,'discontinuous')),
      error('PDE:pdeplot:ZstyleInvalidOption',...
          'zstyle must be off | continuous | discontinuous')
    end
  case 'flowdata'
    flowdata = Value;
    if ischar(flowdata),
      error('PDE:pdeplot:FlowdataNotMatrix', 'flowdata must be a matrix.')
    end
  case 'flowstyle'
    flowstyle=lower(Value);
    if ~ischar(flowstyle),
      error('PDE:pdeplot:FlowstyleNotString', 'flowstyle must be a string.')
    elseif ~(strcmp(flowstyle,'off') || strcmp(flowstyle,'arrow'))
      error('PDE:pdeplot:FlowstyleInvalidOption', 'flowstyle must be off | arrow')
    end
  case 'colormap'
    if ischar(Value),
      cmap = lower(Value);
    elseif size(Value,2)~=3,
      error('PDE:pdeplot:ColormapSizeOrNotString',...
          'colormap must be a string or have exactly three columns.')
    else
      cmap=Value;
    end
  case 'intool'
    intool = lower(Value);
    if ~ischar(intool),
      error('PDE:pdeplot:IntoolNotString', 'intool must be a string.')
    elseif ~(strcmp(intool,'off') || strcmp(intool,'on'))
      error('PDE:pdeplot:IntoolInvalidOption', 'intool must be off | on')
    end
  case 'xygrid'
    xygrid = lower(Value);
    if ~ischar(xygrid),
      error('PDE:pdeplot:xygridNotString', 'xygrid must be a string.')
    elseif ~(strcmp(xygrid,'off') || strcmp(xygrid,'on'))
      error('PDE:pdeplot:xygridInvalidOption', 'xygrid must be off | on')
    end
  case 'mesh'
    mh = lower(Value);
    if ~ischar(mh),
      error('PDE:pdeplot:MeshNotString', 'mesh must be a string.')
    elseif ~(strcmp(mh,'off') || strcmp(mh,'on'))
      error('PDE:pdeplot:MeshInvalidOption', 'mesh must be off | on')
    end
  case 'colorbar'
    cbar = lower(Value);
    if ~ischar(cbar),
      error('PDE:pdeplot:ColorbarNotString', 'colorbar must be a string.')
    elseif ~(strcmp(cbar,'off') || strcmp(cbar,'on'))
      error('PDE:pdeplot:ColorbarInvalidOption', 'colorbar must be off | on')
    end
  case 'title'
    title = Value;
    if ~ischar(title),
      error('PDE:pdeplot:TitleNotString', 'title must be a string.')
    end
  case 'levels'
    levels = Value;
    if isempty(levels),
      levels=10;
    end
  case 'gridparam'
    gridparam = Value;
    if ischar(gridparam),
      error('PDE:pdeplot:GridparamChar', 'gridparam must be a matrix [tn; a2; a3].')
    elseif rem(size(gridparam,1),3),
      error('PDE:pdeplot:InvalidGridparam', 'gridparam must be a matrix [tn; a2; a3].')
    end
    n=size(gridparam,1)/3;
    tn=gridparam(1:n,:);
    a2=gridparam(n+1:2*n,:);
    a3=gridparam(2*n+1:3*n,:);
  case 'contour'
    cont = lower(Value);
    if ~ischar(cont),
      error('PDE:pdeplot:ContourNotString', 'contour must be a string.')
    elseif ~(strcmp(cont,'off') || strcmp(cont,'on'))
      error('PDE:pdeplot:ContourInvalidOption', 'contour must be off | on')
    end
  otherwise
    error('PDE:pdeplot:InvalidParam', ['Unknown parameter: ' Param])
  end
end

% A few more checks
if isempty(xydata) || (strcmp(xystyle,'off') && strcmp(cont,'off')),
  plotxy=0;
else
  plotxy=1;
end
if isempty(zdata) || strcmp(zstyle,'off'),
  plotz=0;
else
  plotz=1;
end
if isempty(flowdata) || strcmp(flowstyle,'off'),
  plotflow=0;
else
  plotflow=1;
end

if strcmp(intool,'on'),
  intool=1;
elseif strcmp(intool,'off'),
  intool=0;
end

if intool,
  showhidd = get(0,'ShowHiddenHandles');
  set(0,'ShowHiddenHandles','on')
  solutionpos =[0.13 0.1 0.8 0.75];
  pde_fig = findobj(get(0,'Children'),'flat','Tag','PDETool');
  ax = findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  if isempty(ax),
    error('PDE:pdeplot:IntoolNoAxes',...
        'Intool plot option on. Couldn''t find PDETool axes.')
  end
  hfile=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(hfile,'UserData');
  if flags(2)==3,
    solvemode=1;
  else
    solvemode=0;
  end
end

if ~plotxy && ~plotz && ~plotflow,

  if ~isempty(t)
    it1=t(1,:);
    it2=t(2,:);
    it3=t(3,:);

    np=size(p,2);
    T=sparse(t([1 2 3],:),t([2 3 1],:),1,np,np);
    if ~isempty(e)
      E=sparse(e(1,:),e(2,:),1,np,np);
      T=T>(E|E');
    end
    [I,J]=find(T|T');
    K=find(I>=J);
    I=I(K);
    J=J(K);
    X=[p(1,I); p(1,J); NaN*ones(length(I),1)'];
    Y=[p(2,I); p(2,J); NaN*ones(length(I),1)'];

    X=X(:);
    Y=Y(:);
  else
    X=[];
    Y=[];
  end

  if ~isempty(e)
    ik1=e(1,:);
    ik2=e(2,:);

    XX=[p(1,ik1)' p(1,ik2)' NaN*ones(size(ik1'))]';
    YY=[p(2,ik1)' p(2,ik2)' NaN*ones(size(ik1'))]';
    XX=XX(:);
    YY=YY(:);
  else
    XX=[];
    YY=[];
  end

  if intool,
    if solvemode && ~isempty(t),
      figure(pde_fig);
      % Clean up axes:
      hndls=get(ax,'UserData');
      if ~isempty(hndls),
        delete(hndls)
        set(ax,'UserData',[]);
      end
      set(get(ax,'Children'),'Visible','off')
      pos=get(ax,'Pos');
      if any(abs(pos(1:2)-solutionpos(1:2))>100*eps),
        set(ax,'Pos',solutionpos);
      end
      set(get(ax,'Title'),...
          'Erasemode','normal',...
          'Color','k',...
          'String',title,...
          'Visible','on')
    else
      set(0,'CurrentFigure',pde_fig)
    end
    set(pde_fig,'CurrentAxes',ax)
    hh=line(X,Y,'Color','b','Parent',ax);
    hh=[hh;line(XX,YY,'Color','r','Parent',ax)];
    if ~nargout,
      % Save line handles as this is a solution plot
      set(ax,'UserData',hh)
    end
  else
    hh=plot(X,Y,'b',XX,YY,'r');
  end
  if nargout==1,
    h=hh;
  end
  if intool
    set(0,'ShowHiddenHandles',showhidd)
  end
  return
end

ntri=size(t,2); nnode=size(p,2);
if plotxy,
  xys=size(xydata);
  if xys(1)==nnode,
    xynodedata=1;
    xydata=xydata(:,1);
  elseif xys(2)==ntri,
    xynodedata=0;
    xydata=xydata(1,:);
  elseif xys(2)==nnode,
    xydata=xydata';
    xynodedata=1;
    xydata=xydata(:,1);
  elseif xys(1)==ntri
    xydata=xydata';
    xynodedata=0;
    xydata=xydata(1,:);
  else
    error('PDE:pdeplot:xydataLength',...
        'length of xydata must equal number of nodes or number of triangles.')
  end
end
if plotz,
  zs=size(zdata);
  if zs(1)==nnode,
    znodedata=1;
    zdata=zdata(:,1);
  elseif zs(2)==ntri,
    znodedata=0;
    zdata=zdata(1,:);
  elseif zs(2)==nnode,
    zdata=zdata';
    znodedata=1;
    zdata=zdata(:,1);
  elseif zs(1)==ntri
    zdata=zdata';
    znodedata=0;
    zdata=zdata(1,:);
  else
    error('PDE:pdeplot:ZdataLength',...
        'length of zdata must equal number of nodes or number of triangles.')
  end
end
if plotflow,
  flows=size(flowdata);
  if flows(2)==ntri,
    if flows(1)<2,
      error('PDE:pdeplot:FlowdataSize',...
          'flowdata must be a matrix with two rows (columns).')
    else
      flowdata=flowdata(1:2,:);
    end
  elseif flows(1)==ntri,
    flowdata=flowdata';
    if flows(2)<2,
      error('PDE:pdeplot:FlowdataSize',...
          'flowdata must be a matrix with two rows (columns).')
    else
      flowdata=flowdata(1:2,:);
    end
  elseif flows(1)==nnode,
    if flows(2)<2,
      error('PDE:pdeplot:FlowdataNumCols',...
          'flowdata must be a matrix with two columns.')
    else
      flowdata=flowdata(:,1:2);
    end
  else
    error('PDE:pdeplot:FlowdataSize',...
        'flowdata must be of size 2-by-no of triangles or no of nodes-by-2.')
  end
end

if intool,
  if ~plotz,
    figure(pde_fig);
    %
    %Clean up axes
    hndls=get(ax,'UserData');
    if ~isempty(hndls),
      delete(hndls)
      set(ax,'UserData',[]);
    end
    set(get(ax,'Children'),'Visible','off')
    pos=get(ax,'Pos');
    if any(abs(pos(1:2)-solutionpos(1:2))>100*eps),
      set(ax,'Pos',solutionpos);
    end
  else
    % Find a figure to play the movie in:
    figs=findobj(get(0,'Children'),'flat','HandleVisibility','on');
    pfig=[];
    for i=1:length(figs)
      npl=get(figs(i),'Nextplot');
      if npl(1)=='a'
        if isempty(findobj(get(figs(i),'Children'))),
          pfig=figure(figs(i));
          break;
        end
      elseif npl(1)=='r'
        pfig=figure(figs(i));
        clf reset
        break;
      end
    end
    if isempty(pfig)
      figure
    end
    ax = newplot;
    view(3);
  end
else
  % not called from pdetool
  ax = newplot;
  hold on
  if plotz
    view(3)
  else
    view(2)
  end
end

if strcmp(xygrid,'on')
  % Use x-y grid:
  if plotxy,
    if ~xynodedata,
      % convert triangle data to node data
      xydata=pdeprtni(p,t,xydata);
      xynodedata=1;
    end
  end
  if plotz,
    % must be nodedata if tri2grid is to be used:
    if ~znodedata
      % convert triangle data to node data
      zdata=pdeprtni(p,t,zdata);
      znodedata=1;
    end
  end

  if isempty(tn),
    % Determine xy-grid from geometry:
    xmin=min(p(1,t)); xmax=max(p(1,t));
    ymin=min(p(2,t)); ymax=max(p(2,t));

    nt=size(t,2);
    nxy=ceil(sqrt(nt/2))+1;
    x=linspace(xmin,xmax,nxy);
    y=linspace(ymin,ymax,nxy);

    if plotxy,
      xydata=tri2grid(p,t,xydata,x,y);
    end
    if plotz,
      zdata=tri2grid(p,t,zdata,x,y);
    end
  else
    % We have interpolation parameters
    if plotxy,
      xydata=tri2grid(p,t,xydata,tn,a2,a3);
    end
    if plotz,
      zdata=tri2grid(p,t,zdata,tn,a2,a3);
    end

    % Determine xy-grid from triangle geometry:
    xmin=min(p(1,t)); xmax=max(p(1,t));
    ymin=min(p(2,t)); ymax=max(p(2,t));

    x=linspace(xmin,xmax,size(tn,2));
    y=linspace(ymin,ymax,size(tn,1));

  end
end

colormap(cmap)
hh=[];

% OK, now sort out all the plot cases:

% case: mesh plot (3-d only)
if ~plotxy && plotz

  if strcmp(xygrid,'on'),
    % use x-y grid
    [xx,yy]=meshgrid(x,y);
    colormap([1 1 0]);
    hh=mesh(xx,yy,zdata);
  else
    % use triangular grid
    if ~znodedata,
      % convert triangle data to node data
      zdata=pdeprtni(p,t,zdata);
      znodedata=1;
    end

    it1=t(1,:);
    it2=t(2,:);
    it3=t(3,:);

    X=[p(1,it1)' p(1,it2)' p(1,it3)' p(1,it1)' NaN*ones(size(it1'))]';
    Y=[p(2,it1)' p(2,it2)' p(2,it3)' p(2,it1)' NaN*ones(size(it1'))]';
    Z=[zdata(it1) zdata(it2) zdata(it3) zdata(it1) NaN*ones(size(it1'))]';
    X=X(:);
    Y=Y(:);
    Z=Z(:);

    hh=plot3(X,Y,Z);
  end

  % case: flat or interpolated plots
elseif (strcmp(xystyle,'flat') || strcmp(xystyle,'interp')) && plotxy,

  if strcmp(xygrid,'on'),

    if ~plotz,
      if intool,
        set(pde_fig,'CurrentAxes',ax)
      end
      zdata = zeros(size(xydata));
    end
    if strcmp(xystyle,'interp'),
      if intool && ~plotz,
        hold on
      end
      if strcmp(mh,'on'),
        hh=surf(x,y,zdata,xydata);
        set(hh,'Facecolor','interp','Edgecolor','k')
      elseif strcmp(mh,'off')
        hh=surf(x,y,zdata,xydata);
        set(hh,'Facecolor','interp','Edgecolor','none')
      end
    elseif strcmp(xystyle,'flat'),
      if intool && ~plotz,
        hold on
      end
      if strcmp(mh,'on'),
        hh=surf(x,y,zdata,xydata);
      elseif strcmp(mh,'off')
        hh=surf(x,y,zdata,xydata);
        set(hh,'Facecolor','flat','Edgecolor','none')
      end
    end

  else

    if plotxy,
      if ~xynodedata && strcmp(xystyle,'interp'),
        % convert triangle data to node data
        xydata=pdeprtni(p,t,xydata);
        xynodedata=1;
      end
    end
    if plotz,
      if znodedata && strcmp(zstyle,'discontinuous'),
        % convert node data to triangle data
        zdata=pdeintrp(p,t,zdata);
        znodedata=0;
      elseif ~znodedata && strcmp(zstyle,'continuous'),
        % convert triangle data to node data
        zdata=pdeprtni(p,t,zdata);
        znodedata=1;
      end
    else
      zdata=zeros(size(xydata));
      znodedata=xynodedata;
    end

    it1=t(1,:);
    it2=t(2,:);
    it3=t(3,:);

    X=[p(1,it1); p(1,it2); p(1,it3)];
    Y=[p(2,it1); p(2,it2); p(2,it3)];
    if ~znodedata,
      Z=[zdata; zdata; zdata];
    else
      Z=[zdata(it1)'; zdata(it2)'; zdata(it3)'];
    end
    if ~xynodedata,
      C=[xydata; xydata; xydata];
    else
      C=[xydata(it1)'; xydata(it2)'; xydata(it3)'];
    end

    if intool && ~plotz,
      set(pde_fig,'CurrentAxes',ax)
    end
    if strcmp(xystyle,'interp')
      if strcmp(mh,'on')
        hh=patch(X,Y,Z,C,'Parent',ax,'Erasemode','normal');
      elseif strcmp(mh,'off')
        hh=patch(X,Y,Z,C,'Parent',ax,'Erasemode','normal',...
            'Edgecolor','none');
      end
    elseif strcmp(xystyle,'flat')
      if strcmp(mh,'on')
        hh=patch(X,Y,Z,mean(C),'Parent',ax,'Erasemode','normal');
      elseif strcmp(mh,'off')
        hh=patch(X,Y,Z,mean(C),'Parent',ax,'Erasemode','normal',...
            'Edgecolor','none');
      end
    end

  end
end

% case: contour plot
if strcmp(cont,'on') && plotxy,

  if ~xynodedata,
    % convert triangle data to node data
    xydata=pdeprtni(p,t,xydata);
    xynodedata=1;
  end

  if ~plotz,
    zdata=xydata;
  elseif ~znodedata,
    % convert triangle data to node data
    zdata=pdeprtni(p,t,zdata);
  end

  xymin=min(min(xydata));
  xymax=max(max(xydata));
  zmin=min(min(zdata));
  zmax=max(max(zdata));
  if xymax==xymin, xymax=xymin+1; end
  if zmax==zmin, zmax=zmin+1; end
  if numel(levels)==1,
    n=levels;
    if plotz,
      lmin=(n*zmin+zmax)/(n+1);
      lmax=(zmin+n*zmax)/(n+1);
      levmin=zmin; levmax=zmax;
    else
      lmin=(n*xymin+xymax)/(n+1);
      lmax=(xymin+n*xymax)/(n+1);
      levmin=xymin; levmax=xymax;
    end
    zlmin=(n*zmin+zmax)/(n+1);
    zlmax=(zmin+n*zmax)/(n+1);
    lev=linspace(lmin,lmax,n);
    zlev=linspace(zlmin,zlmax,n);
  else
    levels=sort(levels);
    n=length(levels);
    lmin=levels(1);
    lmax=levels(n);
    zlmin=lmin;
    zlman=lmax;
    lev=levels;
    zlev=levels;
    if plotz,    
      levmin=zmin; levmax=zmax;
    else
      levmin=xymin; levmax=xymax;
    end
  end

  cm=colormap;
  ncm=size(cm,1);
  icm=floor(((lev-levmin)/(levmax-levmin))*(ncm-1)+0.5)+1;
  if max(icm)>ncm || min(icm)<1,
    icmindx=find(icm<=ncm & icm>=1);
    icm=icm(icmindx);
  end
  ccm=cm(icm,:);

  % Ensure that overlayed contour is drawn on top of surface plot
  if ~strcmp(xystyle,'off') && ~plotz,
    set(gca,'DrawMode','fast')
  end

  if strcmp(xygrid,'on'),
    [xx,yy]=meshgrid(x,y);
    %if ~plotz
      %zdata = zeros(size(xx));
    %end
    if ~intool || plotz,
      hold on      
      [unused,hhc]=contour3(xx,yy,zdata,levels);
      if ~strcmp(xystyle,'off'),
      % Plot overlayed contours in the plane z=0
        for i=1:length(hhc),
          set(hhc(i),'zdata',zeros(size(get(hhc(i),'zdata'))));
        end
      end
      % plot geometry boundaries:
      h1=pdeplot(p,e,[]);
    else
      set(pde_fig,'CurrentAxes',ax)
      hold on
      [unused,hhc] = contour(xx,yy,zdata,levels);
      % plot geometry boundaries:
      h1=pdeplot(p,e,[],'intool','on');
    end
    set(h1,'color','k');
    d=[];
 
    if strcmp(xystyle,'off'),

%      n=length(hhc);
%      for i=1:n,
%        set(hhc(i),'color',ccm(i,:))
%      end
      hhc=[hhc(:);h1(:)];

    else

      % Black overlayed contours:
      set(hhc,'EdgeColor','k')
      hhc=[hhc(:); h1];
    end
  else
    nt=size(t,2);
    zt=reshape(zdata(t(1:3,:)),3,nt);
    xyt=reshape(xydata(t(1:3,:)),3,nt);
    ztmax=max(zt); ztmin=min(zt);
    if plotz,
      levt=zt;
    else
      levt=xyt;
    end

    XX=[]; YY=[]; ZZ=[];
    for j=1:length(lev),
      jlev=zlev(j);
      it=find(ztmin<=jlev & ztmax>=jlev);
      if size(it),

        z1=zt(1,it);
        z2=zt(2,it);
        z3=zt(3,it);

        a21=zeros(1,length(it));
        itt=find(z2~=z3);       % This kludge is to avoid the warning message
        a21(itt)=(jlev-z3(itt))./(z2(itt)-z3(itt));
        itt=find(z2==z3);
        a21(itt)=NaN*ones(size(itt));
        a32=zeros(1,length(it));
        itt=find(z3~=z1);
        a32(itt)=(jlev-z1(itt))./(z3(itt)-z1(itt));
        itt=find(z3==z1);
        a32(itt)=NaN*ones(size(itt));
        a13=zeros(1,length(it));
        itt=find(z1~=z2);
        a13(itt)=(jlev-z2(itt))./(z1(itt)-z2(itt));
        itt=find(z1==z2);
        a13(itt)=NaN*ones(size(itt));

        a2=NaN*ones(2,length(it));
        a3=NaN*ones(2,length(it));
        ii=ones(1,length(it));          % 1+the number of points found so far

        itt=find(a21>=0 & a21<=1);      % On side 1
        a2(ii(itt)+2*(itt-1))=a21(itt);
        a3(ii(itt)+2*(itt-1))=1-a21(itt);
        ii(itt)=ii(itt)+ones(size(itt));
        itt=find(a32>=0 & a32<=1);      % On side 2
        a2(ii(itt)+2*(itt-1))=zeros(size(itt));
        a3(ii(itt)+2*(itt-1))=a32(itt);
        %  ii(itt)=ii(itt)+ones(size(itt));
        itt=find(a13>=0 & a13<=1);      % On side 3
        % This must be the second endpoint
        a2(2,itt)=1-a13(itt);
        a3(2,itt)=zeros(size(itt));

        X=[(1-a2(1,:)-a3(1,:)).*p(1,t(1,it))+ ...
                a2(1,:).*p(1,t(2,it))+a3(1,:).*p(1,t(3,it)); ...
            (1-a2(2,:)-a3(2,:)).*p(1,t(1,it))+ ...
                a2(2,:).*p(1,t(2,it))+a3(2,:).*p(1,t(3,it)); ...
            NaN*ones(size(it))];
        Y=[(1-a2(1,:)-a3(1,:)).*p(2,t(1,it))+ ...
                a2(1,:).*p(2,t(2,it))+a3(1,:).*p(2,t(3,it)); ...
            (1-a2(2,:)-a3(2,:)).*p(2,t(1,it))+ ...
                a2(2,:).*p(2,t(2,it))+a3(2,:).*p(2,t(3,it)); ...
            NaN*ones(size(it))];
        Z=[jlev*ones(size(it)); jlev*ones(size(it)); NaN*ones(size(it))];
        X=X(:);
        Y=Y(:);
        Z=Z(:);

        nxx=size(XX,1);
        nx=size(X,1);
        if nxx>nx
          nn=NaN*ones(nxx-nx,1);
          X=[X; nn];
          Y=[Y; nn];
          Z=[Z; nn];
        elseif nxx<nx
          nn=NaN*ones(nx-nxx,size(XX,2));
          XX=[XX; nn];
          YY=[YY; nn];
          ZZ=[ZZ; nn];
        end
        XX=[XX, X];
        YY=[YY, Y];
        ZZ=[ZZ, Z];
      end                               % size(it)
    end

    % plot geometry boundaries:
    
    if intool && ~plotz,
      set(pde_fig,'CurrentAxes',ax)
    end
    hold on

    if ~plotz
      ZZ = zeros(size(XX));
    end
    hndl = zeros(size(XX,2),1);
    for i=1:size(XX,2)
      if strcmp(xystyle,'off'),
      % Colored contours:
        hndl(i)=line(XX(:,i),YY(:,i),ZZ(:,i),...
            'Parent',ax,...
            'color',ccm(i,:),'Erasemode','normal');
      else
      % Overlayed black contours:
        contc='k';
        hndl(i)=line(XX(:,i),YY(:,i),zeros(size(XX(:,i))),...
            'Parent',ax,...
            'color',contc,'Erasemode','normal');
      end
    end

    if intool && ~plotz,
      h1=pdeplot(p,e,[],'intool','on');
    else
      h1=pdeplot(p,e,[]);
    end
    set(h1,'color','k')

    hold off

    hhc=[hndl(:);h1(:)];
  end

  hh=[hh; hhc];

end


% case: add vector arrows to plot
if plotflow,
  % convert triangle data to node data
  if size(flowdata,2)==ntri
    flowdata=pdeprtni(p,t,flowdata);
  end

  % Determine xy-grid from geometry:
  xmin=min(p(1,t)); xmax=max(p(1,t));
  ymin=min(p(2,t)); ymax=max(p(2,t));

  % We hope 21 arrows per row looks good
  na=21;
  x=linspace(xmin,xmax,na);
  y=linspace(ymin,ymax,na);

  u=tri2grid(p,t,flowdata(:,1),x,y);
  v=tri2grid(p,t,flowdata(:,2),x,y);
  [msg,x,y]=xyzchk(x,y,u,v);
  if ~isempty(msg),
 %   if ischaruct(msg)
 %       msg = msg.message;
 %   end      
    pdetool('error',msg)
    if intool
      set(0,'ShowHiddenHandles',showhidd)
    end
    return
  end

  if plotxy && ~plotz,
    % Setting the drawmode of the current axes to 'fast' will
    % ensure that the arrows are drawn on top. Not performed for
    % 3-D, though, since the disabled back to front ordering
    % destroys the appearance.
    set(gca,'Drawmode','fast')
  end
  hold on
  oks=find(~isnan(u));
  hq=quiver(x(oks),y(oks),u(oks),v(oks),'r-');
  hh=[hh; hq];
  hold off
end

if intool && ~plotz,
  set(pde_fig,'nextplot','add')
  set(ax,'UserData',hh)
end

% Finally, if there are no patches, plot an invisible patch to avoid
% problems with colorbar scaling:
if isempty(findobj(hh,'flat','Type','patch')) && plotz
  patch(0,0,0,'Parent',ax,'Visible','off')
end

% Turn on colorbar
if plotxy && strcmp(cbar,'on'),
  if strcmp(xystyle,'off') && strcmp(cont,'off')
    cmax=max(max(zdata));
    cmin=min(min(zdata));
  else
    cmax=max(max(xydata));
    cmin=min(min(xydata));
  end
  if cmin==cmax, cmax=cmax+1; end
  caxis([cmin cmax]);
  hc=colorbar;
  hh=[hh; hc];
  set(hc,'Tag','PDESolBar')
end

% turn on mouse-based 3-D rotation:
if plotz,
  rotate3d on
  set(get(ax,'parent'),'currentaxes',ax)
end

% Finally, set the axes title
col = 'k';

set(get(ax,'Title'),...
    'EraseMode','normal',...
    'Color',col,...
    'String',title,...
    'Visible','on')

if intool,
  set(ax,'Nextplot','replace')
  set(pde_fig,'Nextplot','replace')
  if gcf~=pde_fig, set(gcf,'NextPlot','replace'), end
  set(0,'ShowHiddenHandles',showhidd)
else
  hold off
end

if nargout==1,
  h=hh;
end