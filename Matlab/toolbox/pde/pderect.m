function pderect(dim,label)
%PDERECT Draw rectangle, update Geometry Description matrix.
%
%       PDERECT([xmin xmax ymin ymax],LABEL) draws a rectangle
%       with dimensions defined by the x and y values and labeled
%       with the string LABEL. The label is optional. If omitted,
%       a label will be automatically assigned.
%
%       See also: PDECIRC PDEELLIP PDEPOLY

%       Magnus Ringh 9-21-94, MR 07-25-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:48 $

if nargin<1
  error('PDE:pderect:nargin', 'Too few input arguments.')
end

if ~(any(size(dim)==1))
  error('PDE:pderect:InputNotVector', 'Input data must be vectors.')
end

if ~isreal(dim)
  error('PDE:pderect:ComplexInput', 'Input data must be real.')
end

if (length(dim)~=4)
  error('PDE:pderect:InputSize', 'Input must be a 4x1 vector.')
end

if ((dim(1)==dim(2)) || (dim(3)==dim(4)))
  error('PDE:pderect:RectSidesNotPos', 'Rectangle sides must be > 0.')
end

if nargin>1,
  if ~ischar(label)
    error('PDE:pderect:LabelNotString', 'Label must be a string.')
  end
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
% If PDETOOL not started, create PDETOOL interface
if isempty(pde_fig),
  pdetool
  pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
end

if nargin>1,
  if pdeisusd(label)
    error('PDE:pderect:LabelNotUnique', 'Label must be unique.')
  end
end

ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');

if nargin==1,
  % add label:
  small=100*eps*(min(diff(get(ax,'Xlim')),diff(get(ax,'Ylim'))));
  if (abs(abs(diff(dim(1:2)))-abs(diff(dim(3:4))))<small),
    % square
    numsquare=1;
    label='SQ1';
    while pdeisusd(label),              % ensure unique labels
      numsquare=numsquare+1;
      label=['SQ' int2str(numsquare)];
    end
  else
    % rectangle
    numrect=1;
    label='R1';
    while pdeisusd(label),              % ensure unique labels
      numrect=numrect+1;
      label=['R' int2str(numrect)];
    end
  end
end

pde_rect=3;

x=[dim(1) dim(2) dim(2) dim(1)];
y=[dim(3) dim(3) dim(4) dim(4)];

h=findobj(allchild(pde_fig),'flat','Tag','PDEMeshMenu');
pdegd=get(h,'UserData');
% update PDEGD matrix
m=size(pdegd,2)+1;
pdegd(1,m)=pde_rect;
pdegd(2,m)=4;
pdegd(3:6,m)=x';
pdegd(7:10,m)=y';

% Check data before proceeding:
stat=csgchk(pdegd);
err=0;
if stat(m)==1,
  pdetool('error','  Rectangle not complete')
  err=1;
elseif stat(m)>1,
  pdetool('error','  Rectangle lines must not overlap or intersect')
  err=1;
end
if err
  set(pde_fig,'Pointer','arrow');
  return;
end

set(h,'UserData',pdegd);

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

h=findobj(allchild(ax),'flat','Tag','PDELabel','UserData',m);
set(h,'Tag','PDELblSel')

pdeframe(pdegd,m)

set(pde_fig,'Pointer','arrow');

