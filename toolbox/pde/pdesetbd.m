function pdesetbd(bounds,type,mode,cond,cond2,cond3,cond4)
%PDESETBD Set boundary condition for PDE Toolbox boundaries.
%
%       pdesetbd(BOUNDS,TYPE,MODE,COND,COND2,COND3,COND4)
%
%       pdesetbd(BOUNDS,TYPE,MODE,COND,COND2) sets the boundaries BOUNDS to
%       the a boundary condition of type TYPE and specified by COND and
%       COND2. MODE is 1 for scalar problems and 2 for system
%       (2-dimensional) problems.
%       BOUNDS corresponds to column number(s) in the boundary
%       condition matrix and the decomposed list. BOUNDS must contain
%       outer boundaries only.
%       TYPE='neu' for (generalized) Neumann conditions,
%       TYPE='dir' for Dirichlet conditions, and TYPE='mix'
%       for Mixed boundary conditions.
%       NOTE: Mixed condition available for system case only.
%       COND, COND2,... are strings containing the boundary condition,
%       which could be a function of x and y or a function of the curvature.
%       For generalized Neumann conditions,
%       n*(c*grad(u))+q*u=g,
%       COND contains the q part, and COND2 contains the g part.
%       For Dirichlet conditions,
%       h*u=r,
%       COND contains the h part, and COND2 contains the r part.
%       For Mixed condition,
%       n*(c*grad(u))+q*u=g; hu=r,
%       COND contains the q part, COND2 contains the g part, COND3
%       contains the h part, and COND4 contains the r part.

%       Magnus Ringh 11-01-94, MR 12-23-94
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:55 $

if nargin<5
  error('PDE:pdesetbd:nargin', 'Too few input arguments.'),
  return;
end

type=lower(type);
if strcmp(type,'mix')
  if nargin<7
    error('PDE:pdesetbd:nargin', 'Too few input arguments.'),
  end
end

% set color and update boundary condition matrix

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
pde_kids = allchild(pde_fig);
ax=findobj(pde_kids,'flat','Tag','PDEAxes');
menuhndl=findobj(pde_kids,'flat','Tag','PDEBoundMenu');
if isempty(menuhndl) 
    error('PDE:pdesetbd:PdetoolInactive', 'PDETOOL not active.')
end
hbound=findobj(get(menuhndl,'Children'),'flat','Tag','PDEBoundMode');
pdebound=get(hbound,'UserData');

n=length(bounds);
bndlines=findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine');
bls=length(bndlines);
for i=1:bls,
  udata=get(bndlines(i),'UserData');
  bndcol(i)=udata(1);
end
for i=1:n,
  lineno=find(bndcol==bounds(i));
  if isempty(lineno);
    error('PDE:pdesetbd:InvalidOuterBound',...
         'Boundary no %i is not an outer boundary', bounds(i));
  end
  pde_bound(i)=bndlines(lineno);
  if isempty(pde_bound(i)),
    error('PDE:pdesetbd:BoundNotFound', 'Boundary not found.');
  end
end

if strcmp(type,'neu');
  % case: Neumann conditions
  for j=1:n,
    set(pde_bound(j),'Color','b','UserData',[bounds(j) 0 0 1])
  end
  if mode==1,
    pdebound(1,bounds)=ones(1,n);
    pdebound(2,bounds)=zeros(1,n);
    qstr=kron(cond,ones(n,1))';
    qlength=size(qstr,1)*ones(1,n);
    gstr=kron(cond2,ones(n,1))';
    glength=size(gstr,1)*ones(1,n);
    nq=qlength(1); ng=glength(1);
    pdebound(3,bounds)=qlength;
    pdebound(4,bounds)=glength;
    pdebound(5:5+nq-1,bounds)=qstr;
    pdebound(5+nq:5+nq+ng-1,bounds)=gstr;
  elseif mode==2,
    pdebound(1,bounds)=2*ones(1,n);
    pdebound(2,bounds)=zeros(1,n);
    if size(cond,1)~=4,
      [q,errstr]=matqparse(cond);
    else
      q=cond; errstr='';
    end
    if size(q,1)~=4,
      error('PDE:pdesetbd:CondSize', 'System entry COND must have four rows.')
    elseif ~isempty(errstr),
      error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
    end
    qstr1=kron(deblank(q(1,:)),ones(n,1))';
    qlength1=size(qstr1,1)*ones(1,n);
    qstr2=kron(deblank(q(2,:)),ones(n,1))';
    qlength2=size(qstr2,1)*ones(1,n);
    qstr3=kron(deblank(q(3,:)),ones(n,1))';
    qlength3=size(qstr3,1)*ones(1,n);
    qstr4=kron(deblank(q(4,:)),ones(n,1))';
    qlength4=size(qstr4,1)*ones(1,n);
    if size(cond2,1)~=2,
      [g,errstr]=matqparse(cond2);
    else
      g=cond2; errstr='';
    end
    if size(g,1)~=2,
      error('PDE:pdesetbd:Cond2Size', 'System entry COND2 must have two rows.')
    elseif ~isempty(errstr),
      error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
    end
    gstr1=kron(deblank(g(1,:)),ones(n,1))';
    glength1=size(gstr1,1)*ones(1,n);
    gstr2=kron(deblank(g(2,:)),ones(n,1))';
    glength2=size(gstr2,1)*ones(1,n);
    nq1=qlength1(1); ng1=glength1(1);
    nq2=qlength2(1); ng2=glength2(1);
    nq3=qlength3(1);
    nq4=qlength4(1);
    pdebound(3,bounds)=qlength1;
    pdebound(4,bounds)=qlength2;
    pdebound(5,bounds)=qlength3;
    pdebound(6,bounds)=qlength4;
    pdebound(7,bounds)=glength1;
    pdebound(8,bounds)=glength2;
    pos=9;
    pdebound(pos:pos+nq1-1,bounds)=qstr1;
    pos=pos+nq1;
    pdebound(pos:pos+nq2-1,bounds)=qstr2;
    pos=pos+nq2;
    pdebound(pos:pos+nq3-1,bounds)=qstr3;
    pos=pos+nq3;
    pdebound(pos:pos+nq4-1,bounds)=qstr4;
    pos=pos+nq4;
    pdebound(pos:pos+ng1-1,bounds)=gstr1;
    pos=pos+ng1;
    pdebound(pos:pos+ng2-1,bounds)=gstr2;
  end
elseif strcmp(type,'dir')
  % case: Dirichlet conditions
  for j=1:n,
    set(pde_bound(j),'Color','r','UserData',[bounds(j) 1 0 0])
  end
  if mode==1,
    pdebound(1:2,bounds)=ones(2,n);
    gstr='0'*ones(1,n); glength=ones(1,n);
    qstr='0'*ones(1,n); qlength=ones(1,n);
    hstr=kron(cond,ones(n,1))';
    hlength=size(hstr,1)*ones(1,n);
    rstr=kron(cond2,ones(n,1))';
    rlength=size(rstr,1)*ones(1,n);
    nh=hlength(1); nr=rlength(1);
    pdebound(5,bounds)=hlength;
    pdebound(6,bounds)=rlength;
    pdebound(9:9+nh-1,bounds)=hstr;
    pdebound(9+nh:9+nh+nr-1,bounds)=rstr;
  elseif mode==2,
    pdebound(1,bounds)=2*ones(1,n);
    pdebound(2,bounds)=2*ones(1,n);
    qstr1='0'*ones(1,n); qlength1=ones(1,n);
    qstr2='0'*ones(1,n); qlength2=ones(1,n);
    qstr3='0'*ones(1,n); qlength3=ones(1,n);
    qstr4='0'*ones(1,n); qlength4=ones(1,n);
    gstr1='0'*ones(1,n); glength1=ones(1,n);
    gstr2='0'*ones(1,n); glength2=ones(1,n);
    if size(cond,1)~=4,
      [h,errstr]=matqparse(cond);
    else
      h=cond; errstr='';
    end
    if size(h,1)~=4,
      error('PDE:pdesetbd:CondSize', 'System entry COND must have four rows.')
    elseif ~isempty(errstr),
      error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
    end
    hstr1=kron(deblank(h(1,:)),ones(n,1))';
    hlength1=size(hstr1,1)*ones(1,n);
    hstr2=kron(deblank(h(2,:)),ones(n,1))';
    hlength2=size(hstr2,1)*ones(1,n);
    hstr3=kron(deblank(h(3,:)),ones(n,1))';
    hlength3=size(hstr3,1)*ones(1,n);
    hstr4=kron(deblank(h(4,:)),ones(n,1))';
    hlength4=size(hstr4,1)*ones(1,n);
    if size(cond2,1)~=2,
      [r,errstr]=matqparse(cond2);
    else
      r=cond2; errstr='';
    end
    if size(r,1)~=2,
      error('PDE:pdesetbd:Cond2Size', 'System entry COND2 must have two rows.')
    elseif ~isempty(errstr),
      error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
    end
    rstr1=kron(deblank(r(1,:)),ones(n,1))';
    rlength1=size(rstr1,1)*ones(1,n);
    rstr2=kron(deblank(r(2,:)),ones(n,1))';
    rlength2=size(rstr2,1)*ones(1,n);
    nq1=qlength1(1); ng1=glength1(1);
    nq2=qlength2(1); ng2=glength2(1);
    nq3=qlength3(1);
    nq4=qlength4(1);
    nh1=hlength1(1); nr1=rlength1(1);
    nh2=hlength2(1); nr2=rlength2(1);
    nh3=hlength3(1);
    nh4=hlength4(1);
    pdebound(3,bounds)=qlength1;
    pdebound(4,bounds)=qlength2;
    pdebound(5,bounds)=qlength3;
    pdebound(6,bounds)=qlength4;
    pdebound(7,bounds)=glength1;
    pdebound(8,bounds)=glength2;
    pdebound(9,bounds)=hlength1;
    pdebound(10,bounds)=hlength2;
    pdebound(11,bounds)=hlength3;
    pdebound(12,bounds)=hlength4;
    pdebound(13,bounds)=rlength1;
    pdebound(14,bounds)=rlength2;
    pos=15;
    pdebound(pos:pos+nq1-1,bounds)=qstr1;
    pos=pos+nq1;
    pdebound(pos:pos+nq2-1,bounds)=qstr2;
    pos=pos+nq2;
    pdebound(pos:pos+nq3-1,bounds)=qstr3;
    pos=pos+nq3;
    pdebound(pos:pos+nq4-1,bounds)=qstr4;
    pos=pos+nq4;
    pdebound(pos:pos+ng1-1,bounds)=gstr1;
    pos=pos+ng1;
    pdebound(pos:pos+ng2-1,bounds)=gstr2;
    pos=pos+ng2;
    pdebound(pos:pos+nh1-1,bounds)=hstr1;
    pos=pos+nh1;
    pdebound(pos:pos+nh2-1,bounds)=hstr2;
    pos=pos+nh2;
    pdebound(pos:pos+nh3-1,bounds)=hstr3;
    pos=pos+nh3;
    pdebound(pos:pos+nh4-1,bounds)=hstr4;
    pos=pos+nh4;
    pdebound(pos:pos+nr1-1,bounds)=rstr1;
    pos=pos+nr1;
    pdebound(pos:pos+nr2-1,bounds)=rstr2;
  end
elseif strcmp(type,'mix')
  % case: mixed boundary conditions
  for j=1:n,
    set(pde_bound(j),'Color','g','UserData',[bounds(j) 0 1 0])
  end
  pdebound(1,bounds)=2*ones(1,n);
  pdebound(2,bounds)=ones(1,n);
  if size(cond,1)~=4,
    [q,errstr]=matqparse(cond);
  else
    q=cond; errstr='';
  end
  if size(q,1)~=4,
    error('PDE:pdesetbd:CondSize', 'System entry COND must have four rows.')
  elseif ~isempty(errstr),
    error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
  end
  qstr1=kron(deblank(q(1,:)),ones(n,1))';
  qlength1=size(qstr1,1)*ones(1,n);
  qstr2=kron(deblank(q(2,:)),ones(n,1))';
  qlength2=size(qstr2,1)*ones(1,n);
  qstr3=kron(deblank(q(3,:)),ones(n,1))';
  qlength3=size(qstr3,1)*ones(1,n);
  qstr4=kron(deblank(q(4,:)),ones(n,1))';
  qlength4=size(qstr4,1)*ones(1,n);
  if size(cond2,1)~=2,
    [g,errstr]=matqparse(cond2);
  else
    g=cond2; errstr='';
  end
  if size(g,1)~=2,
    error('PDE:pdesetbd:Cond2Size', 'System entry COND2 must have two rows.')
  elseif ~isempty(errstr),
    error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
  end
  gstr1=kron(deblank(g(1,:)),ones(n,1))';
  glength1=size(gstr1,1)*ones(1,n);
  gstr2=kron(deblank(g(2,:)),ones(n,1))';
  glength2=size(gstr2,1)*ones(1,n);
  if size(cond3,1)~=2,
    [h,errstr]=matqparse(cond3);
  else
    h=cond3; errstr='';
  end
  if size(h,1)~=2,
    error('PDE:pdesetbd:Cond3Size', 'System entry COND3 must have two rows.')
  elseif ~isempty(errstr),
    error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
  end
  hstr1=kron(deblank(h(1,:)),ones(n,1))';
  hlength1=size(hstr1,1)*ones(1,n);
  hstr2=kron(deblank(h(2,:)),ones(n,1))';
  hlength2=size(hstr2,1)*ones(1,n);
  [r,errstr]=matqparse(cond4);
  if size(r,1)~=1,
    error('PDE:pdesetbd:Cond4Size', 'System entry COND4 must have one row.')
  elseif ~isempty(errstr),
    error('PDE:pdesetbd:ErrorFromMatqparse', errstr)
  end
  rstr1=kron(deblank(r),ones(n,1))';
  rlength1=size(rstr1,1)*ones(1,n);
  nq1=qlength1(1); ng1=glength1(1);
  nq2=qlength2(1); ng2=glength2(1);
  nq3=qlength3(1);
  nq4=qlength4(1);
  nh1=hlength1(1); nr1=rlength1(1);
  nh2=hlength2(1);
  pdebound(3,bounds)=qlength1;
  pdebound(4,bounds)=qlength2;
  pdebound(5,bounds)=qlength3;
  pdebound(6,bounds)=qlength4;
  pdebound(7,bounds)=glength1;
  pdebound(8,bounds)=glength2;
  pdebound(9,bounds)=hlength1;
  pdebound(10,bounds)=hlength2;
  pdebound(11,bounds)=rlength1;
  pos=12;
  pdebound(pos:pos+nq1-1,bounds)=qstr1;
  pos=pos+nq1;
  pdebound(pos:pos+nq2-1,bounds)=qstr2;
  pos=pos+nq2;
  pdebound(pos:pos+nq3-1,bounds)=qstr3;
  pos=pos+nq3;
  pdebound(pos:pos+nq4-1,bounds)=qstr4;
  pos=pos+nq4;
  pdebound(pos:pos+ng1-1,bounds)=gstr1;
  pos=pos+ng1;
  pdebound(pos:pos+ng2-1,bounds)=gstr2;
  pos=pos+ng2;
  pdebound(pos:pos+nh1-1,bounds)=hstr1;
  pos=pos+nh1;
  pdebound(pos:pos+nh2-1,bounds)=hstr2;
  pos=pos+nh2;
  pdebound(pos:pos+nr1-1,bounds)=rstr1;
end

set(hbound,'UserData',pdebound)

refresh(pde_fig);

% alert PDETOOL that boundary conditions have changed
flg_hndl=findobj(pde_kids,'flat','Tag','PDEFileMenu');
flags=get(flg_hndl,'UserData');
flags(5)=1;                             % flag3=1
set(flg_hndl,'UserData',flags)

