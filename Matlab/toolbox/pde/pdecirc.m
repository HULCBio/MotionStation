function pdecirc(xc,yc,radius,label)
%PDECIRC Draw circle, update Geometry Description matrix.
%
%       PDECIRC(XC,YC,RADIUS,LABEL) draws a circle
%       with center in (XC,YC), RADIUS radius,
%       and label LABEL. Label is optional. If omitted,
%       a default label will be used.
%
%       See also: PDEELLIP PDERECT PDEPOLY

%       Magnus Ringh 9-21-94, MR 7-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:10 $

if nargin<3
  error('PDE:pdecirc:nargin', 'Too few input arguments.')
  return
end

if ~(all(size(xc)==1) && all(size(yc)==1) && all(size(radius)==1))
  error('PDE:pdecirc:InputsNotScalar', 'Input data must be scalars.')
end

if ~(isreal(xc) && isreal(yc) && isreal(radius))
  error('PDE:pdecirc:ComplexInput', 'Input data must be real.')
end

if radius<=0
  error('PDE:pdecirc:RadiusNotPos', 'Radius must be > 0.')
end

if nargin>3
  if ~ischar(label)
    error('PDE:pdecirc:LabelNotString', 'Label must be a string.')
  end
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');

% If PDETOOL not started, create PDETOOL interface
if isempty(pde_fig),
  pdetool
  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
end

if nargin>3
  if pdeisusd(label)
    error('PDE:pdecirc:LabelNotUnique', 'Label must be unique.')
  end
end

if nargin==3
  % add label:
  numcirc=1;
  label='C1';
  while pdeisusd(label),                % ensure unique labels
    numcirc=numcirc+1;
    label=['C' int2str(numcirc)];
  end
end

pde_circ=1;

h=findobj(allchild(pde_fig),'flat','Tag','PDEMeshMenu');
pdegd=get(h,'UserData');
% update PDEGD matrix
m=size(pdegd,2)+1;
pdegd(1,m)=pde_circ;
pdegd(2,m)=xc;
pdegd(3,m)=yc;
pdegd(4,m)=radius;

% Check data before proceeding:
stat=csgchk(pdegd);
err=0;
if stat(m)==1,
  pdetool('error','  Circle must have positive radius.')
  err=1;
elseif stat(m)==2,
  pdetool('error','  Circles must be unique.')
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

