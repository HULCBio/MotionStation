function pdeellip(xc,yc,radiusx,radiusy,angle,label)
%PDEELLIP Draw ellipse, update Geometry Description matrix.
%
%       PDEELLIP(XC,YC,RADIUSX,RADIUSY,ANGLE,LABEL)
%       draws an ellipse with center in (XC,YC),
%       x- and y-axis radius (RADIUSX,RADIUSY),
%       rotated counter-clockwise by ANGLE
%       radians. The ellipse is labeled using
%       label (name) LABEL. LABEL and ANGLE are optional.
%
%       See also: PDECIRC PDERECT PDEPOLY

%       Magnus Ringh 09-21-94, MR 11-14-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:15 $

if nargin<4,
  error('PDE:pdeellip:nargin', 'Too few input arguments.')
end
if nargin==4,
  angle=0;
end

if ~(all(size(xc)==1) && all(size(yc)==1) && ...
    all(size(radiusx)==1) && all(size(radiusy)==1) && all(size(angle)==1))
  error('PDE:pdeellip:InputsNotScalar', 'Input data must be scalars.')
end

if ~(isreal(xc) && isreal(yc) && isreal(radiusx) && isreal(radiusy) && isreal(angle))
  error('PDE:pdeellip:ComplexInput', 'Input data must be real.')
end

if ~((radiusx>0) && (radiusy>0))
  error('PDE:pdeellip:RadiusNotPos', 'Radius must be > 0.')
end

if nargin>5
  if ~ischar(label)
    error('PDE:pdeellip:LabelNotString', 'Label must be a string.')
  end
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
% If PDETOOL not started, create PDETOOL interface
if isempty(pde_fig),
  pdetool
  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
end

if nargin>5
  if pdeisusd(label)
    error('PDE:pdeellip:LabelNotUnique', 'Label must be unique.')
  end
end

if nargin==5 || nargin==4,
  % add label:
  numellip=1;
  label='E1';
  while pdeisusd(label),                % ensure unique labels
    numellip=numellip+1;
    label=['E' int2str(numellip)];
  end
end

pde_ellip=4;

h=findobj(allchild(pde_fig),'flat','Tag','PDEMeshMenu');
pdegd=get(h,'UserData');
% update PDEGD matrix
m=size(pdegd,2)+1;
pdegd(1,m)=pde_ellip;
pdegd(2,m)=xc;
pdegd(3,m)=yc;
pdegd(4,m)=radiusx;
pdegd(5,m)=radiusy;
pdegd(6,m)=angle;

% Check data before proceeding:
stat=csgchk(pdegd);
err=0;
if stat(m)==1,
  pdetool('error','  Ellipse must have positive semiaxes')
  err=1;
elseif stat(m)==2,
  pdetool('error','  Ellipses must be unique')
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

