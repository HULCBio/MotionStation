function error=pdepatch(dl,bt,msb,flag,label,col)
%PDEPATCH Plot minimal regions or subdomains.
%
%       PDEPATCH(DL,BT,MSB,FLAG)
%       With FLAG=0 (the default), plots minimal regions with a shade
%       of gray corresponding to the number of intersecting original
%       geometry objects making up the minimal region.
%       The decomposition of the original geometry is performed by
%       calling DECSG: [DL,BT,DL1,BT1,MSB]=DECSG(...)
%       If FLAG=1, plots subdomains.
%
%       See also: DECSG

%       M. Ringh and L. Langemyr 8-30-94
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:38 $

sn=size(dl,2);

if nargin==5,
  col=label;
  label=flag;
  flag=0;
end
if nargin==3,
  flag=0;
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');

err=0;
if ~flag && sn,
    p = []; e = []; tt = [];
    try [p,e,tt]=initmesh(dl,'hmax',Inf,'init','on');
    catch
        % If error: Remove last column from geometry description and alert
        % user
        h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
        pdegd=get(h,'UserData');
        set(h,'UserData',pdegd(:,1:size(pdegd,2)-1))
        pdetool('error',lasterr);
        return;
    end
    setappdata(pde_fig,'pinit',p);
    setappdata(pde_fig,'tinit',tt);
    if nargin>4,
    % add label to objnames matrix and eval string:
      pdesetlb(label,col)
    end
end

ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
set(pde_fig,'CurrentAxes',ax)

% delete old subdomains / old minimal regions and labels
if flag,
  axkids = get(ax,'Children');
  sd=findobj(axkids,'flat','Tag','PDESubDom');
  set(sd,'Erasemode','xor');
  delete(sd)
else
  axkids = get(ax,'Children');
  mr=findobj(axkids,'flat','Tag','PDEMinReg');
  set(mr,'Erasemode','normal'); set(mr,'Erasemode','xor');
  delete(mr)

  axkids = get(ax,'Children');
  lbl=[findobj(axkids,'flat','Tag','PDELabel')',...
       findobj(axkids,'flat','Tag','PDELblSel')'];
  set(lbl,'Erasemode','normal'); set(lbl,'Erasemode','xor');
  delete(lbl)
  axkids = get(ax,'Children');
  frames=findobj(axkids,'flat','Tag','PDESelFrame');
  set(frames,'Erasemode','normal'); set(frames,'Erasemode','xor');
  delete(frames)
end

if sn==0,
  if nargout,
    error=0;
  end
  return
end

% initialize variables
CIRC=1;
POLY=2;
ELLI=4;

if flag,
  color=[.8421 .8421 .8421];
else
  col_array=get(pde_fig,'Colormap');
end

j=1;
for i=msb
  n=i(1);
  l=i(2:n+1);
  l2=zeros(size(l));
  x=zeros(1,n);
  y=zeros(1,n);
  t=zeros(1,n);
  k1=find(l<=sn);
  x(k1)=dl(2,l(k1));
  y(k1)=dl(4,l(k1));
  t(k1)=dl(1,l(k1));
  l2(k1)=l(k1);
  k2=find(l>sn);
  l2(k2)=l(k2)-sn;
  x(k2)=dl(3,l(k2)-sn);
  y(k2)=dl(5,l(k2)-sn);
  t(k2)=dl(1,l(k2)-sn);

  rn=ones(1,n);                         % general mechanism for
  rx=sparse([],[],[],1,n);              % adding points to patch
  ry=sparse([],[],[],1,n);

  c1=find(t==CIRC);                     % add circles
  if ~isempty(c1);
    delta=2*pi/100;
    th1=atan2(y(c1)-dl(9,l2(c1)),x(c1)-dl(8,l2(c1)));
    c2=rem(c1,n)+1;
    th2=atan2(y(c2)-dl(9,l2(c1)),x(c2)-dl(8,l2(c1)));
    i1=0;
    i3=1;
    for i2=c1
      if l(i2)>sn &th1(i3)<th2(i3)
        th2(i3)=th2(i3)-2*pi;
      elseif l(i2)<=sn &th1(i3)>th2(i3)
        th2(i3)=th2(i3)+2*pi;
      end
      dth=abs(th2(i3)-th1(i3));
      ns=max(2,ceil(dth/delta));
      th=linspace(th1(i3),th2(i3),ns);
      rn(i2)=ns-1;
      rx(1:ns,i2)=(dl(8,l2(i2))+dl(10,l2(i2))*cos(th))';
      ry(1:ns,i2)=(dl(9,l2(i2))+dl(10,l2(i2))*sin(th))';
      i3=i3+1;
    end
  end

  c1=find(t==ELLI);                     % add ellipses
  if ~isempty(c1);
    delta=2*pi/100;
    k=l2(c1);
    ca=cos(dl(12,k)); sa=sin(dl(12,k));
    xd=x(c1)-dl(8,k); yd=y(c1)-dl(9,k);
    x1=ca.*xd+sa.*yd;
    y1=-sa.*xd+ca.*yd;
    th1=atan2(y1./dl(11,k),x1./dl(10,k));
    c2=rem(c1,n)+1;
    xd=x(c2)-dl(8,k); yd=y(c2)-dl(9,k);
    x1=ca.*xd+sa.*yd;
    y1=-sa.*xd+ca.*yd;
    th2=atan2(y1./dl(11,k),x1./dl(10,k));
    i1=0;
    i3=1;
    for i2=c1
      k=l2(i2);
      if l(i2)>sn &th1(i3)<th2(i3)
        th2(i3)=th2(i3)-2*pi;
      elseif l(i2)<=sn &th1(i3)>th2(i3)
        th2(i3)=th2(i3)+2*pi;
      end
      dth=abs(th2(i3)-th1(i3));
      ns=max(2,ceil(dth/delta));
      th=linspace(th1(i3),th2(i3),ns);
      rn(i2)=ns-1;
      x1=dl(10,k).*cos(th)'; y1=dl(11,k).*sin(th)';
      rx(1:ns,i2)=dl(8,k)+ca(i3).*x1-sa(i3).*y1;
      ry(1:ns,i2)=dl(9,k)+sa(i3).*x1+ca(i3).*y1;
      i3=i3+1;
    end
  end

  i4=find(t~=CIRC&t~=ELLI);
  if ~isempty(i4);
    rx(1,i4)=x(i4);
    ry(1,i4)=y(i4);
  end

  x=[]; y=[];
  for i2=1:n
    x=[x,full(rx(1:rn(i2),i2))'];
    y=[y,full(ry(1:rn(i2),i2))'];
  end

  if flag,
    % plot the subdomain:
    h(j)=patch(x,y,color,'EraseMode','none','Parent',ax,...
               'Tag','PDESubDom','EdgeColor','none','UserData',j);
  else
    % plot the minimal region:
    % color for plot = 18-sum(bt(j,:))
    n=18-sum(bt(j,:));
    if n<1, n=1; end
    h(j)=patch(x,y,col_array(n,:),'EraseMode','none',...
        'Parent',ax,...
        'Tag','PDEMinReg','EdgeColor','none','UserData',j);
  end

  j=j+1;
end

if flag, return; end

% label each original region using a unique letter
A=pdetrg(p,tt);
label=getappdata(pde_fig,'objnames'); label=char(label');
m=size(bt,2);
for i=1:m,
  k=find(bt(:,i));                      %find minimal regions for this object

  %find the minimum region with the fewest overlaps
  l=find(sum(bt(k,:)')==min(sum(bt(k,:)')));
  n=length(l);
  tri=[];
  for j=1:n,
    tri=[tri find(tt(4,:)==k(l(j)))];
  end
  Amax=find(A(tri)==max(A(tri))); Amax=Amax(1);
  xm=mean(p(1,tt(1:3,tri(Amax))));
  ym=mean(p(2,tt(1:3,tri(Amax))));

  text('String',label(i,:),'Units','data','Clipping','on',...
       'EraseMode','background','UserData',i,'Tag','PDELabel',...
       'Parent',ax,...
       'HorizontalAlignment','center',...
       'pos',[xm ym 1],'color','k');
end

% save boolean table in PDE Toolbox axes title's UserData
set(get(ax,'Title'),'UserData',bt)

% set flags to indicate that geometry has changed and needs to be saved
h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
flags=get(h,'UserData');
flags(1)=1;                             %need_save=1
flags(3)=1;                             %flag1=1
setappdata(pde_fig,'meshstat',[]);
setappdata(pde_fig,'bl',[]);
set(h,'UserData',flags)

% enable edit menu items:
edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
editkids = get(edithndl,'Children');
hndl=[findobj(editkids,'flat','Tag','PDECut')...
      findobj(editkids,'flat','Tag','PDECopy')...
      findobj(editkids,'flat','Tag','PDEClear')];
drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
hndl=[hndl findobj(get(drawhndl,'Children'),'flat','Tag','PDEExpGD')];
set(hndl,'Enable','on');

if nargout,
  error=err;
end

