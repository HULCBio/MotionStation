function pdeseteq(type,c1,a1,f1,d1,tlist1,u01,ut01,range1)
%PDESETEQ Set the PDE equation coefficients in the PDE Toolbox.
%
%       PDESETEQ(TYPE,C,A,F,D,TLIST,U0,UT0,RANGE)
%
%       The PDE is defined by TYPE: 1 = Elliptic, 2 = Parabolic,
%       3 = Hyperbolic, 4 = Eigenvalue PDE problem.
%       The parameters C, A, F, D are defined on the 2-D area of the
%       PDE problem. Coefficients may be given as strings or as real
%       (complex) numbers.
%       TLIST is a list of times at which to compute the solutions for
%       dynamic PDEs.  U0 and UT0 are initial values u(t0) and
%       du(t0)/dt. RANGE is a two element vector defining
%       a search range on the real axis for the eigenvalue algorithm.
%       Enter as strings.
%
%       Non-applicable coefficients may be entered as empty matrices.
%
%       Example: pdeseteq(2,0,0,'2*sin(pi*x)','logspace(-2,0,20)',0,[],[])
%       defines a parabolic PDE.

%       Magnus Ringh 11-01-94, MR 05-23-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:56 $

err=0;
if nargin<4,
  err=1;
end

if type>1,
  if nargin<7
    err=1;
  end
  if type>2,
    if nargin<8,
      err=1;
    end
    if type==4,
      if nargin<9,
        err=1;
      end
    end
  end
end

if err,
  error('PDE:pdeseteq:nargin', 'Too few input arguments.');
end

if type<1 || type>4,
  error('PDE:pdeseteq:InvalidPDEType', 'PDE type number incorrect.');
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
if isempty(pde_fig),
  error('PDE:pdeseteq:pdetoolInactive', 'PDETool not active.');
end

pde_kids = allchild(pde_fig);
% Save type of PDE:
set(findobj(pde_kids,'flat','Tag','PDEHelpMenu'),...
    'UserData',type);

h=findobj(pde_kids,'flat','Tag','PDEPDEMenu');
params=get(h,'UserData');
% Unpack old coefficients and replace unless empty matrix
ncafd=getappdata(pde_fig,'ncafd');
nc=ncafd(1); na=ncafd(2); nf=ncafd(3); nd=ncafd(4);
c=params(1:nc,:); a=params(nc+1:nc+na,:);
f=params(nc+na+1:nc+na+nf,:);
d=params(nc+na+nf+1:nc+na+nf+nd,:);
timeparams=getappdata(pde_fig,'timeeigparam');
tlist=deblank(timeparams(1,:));
u0=deblank(timeparams(2,:));
ut0=deblank(timeparams(3,:));
range=deblank(timeparams(4,:));
rtol=deblank(timeparams(5,:));
atol=deblank(timeparams(6,:));
if ~isempty(c1), c=num2str(c1); end
if ~isempty(a1), a=num2str(a1); end
if ~isempty(f1), f=num2str(f1); end
if nargin>4,
  if ~isempty(d1), d=num2str(d1); end
end
if nargin>5,
  if ~isempty(tlist1), tlist=num2str(tlist1); end
end
if nargin>6,
  if ~isempty(u01), u0=num2str(u01); end
end
if nargin>7,
  if ~isempty(ut01), ut0=num2str(ut01); end
end
if nargin>8,
  if ~isempty(range1), range=num2str(range1); end
end

% Pack and save coefficient values:
nc=size(c,1); na=size(a,1); nf=size(f,1); nd=size(d,1);
setappdata(pde_fig,'ncafd',[nc, na, nf, nd])
params=str2mat(c,a,f,d);
set(h,'UserData',params);
setappdata(pde_fig,'timeeigparam',str2mat(tlist,u0,ut0,range,...
    rtol,atol));
% alert PDETOOL that PDE equation has changed
flg_hndl=findobj(pde_kids,'flat','Tag','PDEFileMenu');
flags=get(flg_hndl,'UserData');
flags(7)=1;                             % flag5=1
set(flg_hndl,'UserData',flags)

