function pdepoly(x,y,label)
%PDEPOLY  Draw polygon, update Geometry Description matrix.
%
%       PDEPOLY(X,Y,LABEL) adds a polygon with vertices
%       determined by vectors X and Y and a label (name) LABEL.
%       Label is optional. A label will be assigned automatically
%       if omitted.
%
%       See also: PDECIRC PDEELLIP PDERECT

%       Magnus Ringh 9-21-94, MR 7-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:40 $

if nargin<2
  error('PDE:pdepoly:nargin', 'Too few input arguments.')
end

if ~(any(size(x)==1) && any(size(y)==1))
  error('PDE:pdepoly:InputSize', 'Input data must be vectors.')
end

if ~(isreal(x) && isreal(y))
  error('PDE:pdepoly:ComplexInput', 'Input data must be real.')
end

n=length(x);

if length(y)~=n,
  error('PDE:pdepoly:InputSizeMismatch', 'Input data dimensions are inconsistent.')
end

if nargin>2
  if ~ischar(label)
    error('PDE:pdepoly:LabelNotString', 'Label must be a string.')
  end
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
% If PDETOOL not started, create PDETOOL interface
if isempty(pde_fig),
  pdetool
  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
end

if nargin>2,
  if pdeisusd(label)
    error('PDE:pdepoly:LabelNotUnique', 'Label must be unique.')
  end
end

if nargin==2,
  % set label to default
  numpoly=1;
  label='P1';
  while pdeisusd(label)
    numpoly=numpoly+1;
    label=['P' int2str(numpoly)];
  end
end

pde_poly=2;

h=findobj(allchild(pde_fig),'flat','Tag','PDEMeshMenu');
pdegd=get(h,'UserData');
% update PDEGD matrix
m=size(pdegd,2)+1;
pdegd(1,m)=pde_poly;
pdegd(2,m)=n;
pdegd(3:2+n,m)=x';
pdegd(3+n:2*n+2,m)=y';

% Check data before proceeding:
stat=csgchk(pdegd);
err=0;
if stat(m)==1,
  pdetool('error','  Polygon not complete')
  err=1;
elseif stat(m)>1,
  pdetool('error','  Polygon lines must not overlap or intersect')
  err=1;
end
if err
  set(pde_fig,'Pointer','arrow');
  return;
end

set(h,'UserData',pdegd)

set(pde_fig,'Pointer','watch');

% First call DECSG to decompose geometry;
try
    [dl1,bt1,pdedl,bt,msb]=decsg(pdegd);
catch
  set(h,'UserData',pdegd(:,1:m-1))
  pdetool('error',lasterr)
  set(pde_fig,'Pointer','arrow');
  return;
end

pdepatch(pdedl,bt,msb,label,m);
set(findobj(allchild(pde_fig),'flat',...
    'Tag','PDEBoundMenu'),'UserData',pdedl);

setappdata(pde_fig,'dl1',dl1)
setappdata(pde_fig,'bt1',bt1)

ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
h=findobj(allchild(ax),'flat','Tag','PDELabel','UserData',m);
set(h,'Tag','PDELblSel')

pdeframe(pdegd,m)

set(pde_fig,'Pointer','arrow');

