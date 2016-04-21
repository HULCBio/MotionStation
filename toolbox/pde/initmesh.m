function [p,e,t]=initmesh(g,p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7,p8,v8)
%INITMESH Build an initial PDE triangular mesh.
%
%       [P,E,T]=INITMESH(G) returns a triangular mesh using the
%       geometry specification function G. It uses a Delaunay triangulation
%       algorithm. The mesh size is determined from the shape of the geometry.
%
%       G describes the geometry of the PDE problem. See PDEGEOM for details.
%
%       The outputs P, E, and T are the mesh data.
%
%       In the point matrix P, the first and second rows contain
%       x- and y-coordinates of the points in the mesh.
%
%       In the edge matrix E, the first and second rows contain indices
%       of the starting and ending point, the third and fourth rows contain
%       the starting and ending parameter values, the fifth row contains
%       the boundary segment number, and the sixth and seventh row
%       contain the left- and right-hand side subdomain numbers.
%
%       In the triangle matrix T, the first three rows contain indices to
%       the corner points, given in counter clockwise order, and the fourth
%       row contains the subdomain number.
%
%       Valid property/value pairs include
%
%       Property        Value/{Default}         Description
%       -----------------------------------------------------------
%       Hmax            numeric {estimate}      Maximum edge size
%       Hgrad           numeric {1.3}           Triangle growth rate
%       Box             on|{off}                Preserve bounding box
%       Init            on|{off}                Boundary triangulation
%       Jiggle          off|{mean}|min          Call JIGGLEMESH
%       JiggleIter      numeric {10}            Maximum iterations
%
%       The Hmax parameter controls the size of the triangles on the
%       mesh.  INITMESH creates a mesh where no triangle side exceeds
%       Hmax.
%
%       Both the Box and Init parameters are related to the way the
%       mesh algorithm works. By turning on Box you can get a good idea
%       of how the mesh generation algorithm works within the bounding box.
%       By turning on Init you can see the initial triangulation of
%       the boundaries.
%
%       The Jiggle and JiggleIter parameters are used to control whether
%       jiggling of the mesh should be attempted. See JIGGLEMESH for
%       details.
%
%       See also DECSG, PDEGEOM, JIGGLEMESH, REFINEMESH

%       L. Langemyr 11-25-94, LL 8-24-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/01 04:27:56 $

% Analyze input arguments

% Error checks
nargs = nargin;
if rem(nargs+1,2),
   error('PDE:initmesh:NoParamPairs', 'Param value pairs expected.')
end

% Default values
Hmax=0;
Hgrad=1.3;
Box='off';
Init='off';
Jiggle='mean';
JiggleIter=-1;

for i=2:2:nargs,
  Param = eval(['p' int2str((i-2)/2 +1)]);
  Value = eval(['v' int2str((i-2)/2 +1)]);
  if ~ischar(Param),
    error('PDE:initmesh:ParamNotString', 'Parameter must be a string.')
  elseif size(Param,1)~=1,
    error('PDE:initmesh:ParamEmptyOrNot1row', 'Parameter must be a non-empty single row string.')
  end
  Param = lower(Param);
  if strcmp(Param,'hmax'),
    Hmax=Value;
    if ischar(Hmax)
      error('PDE:initmesh:HmaxString', 'Hmax must not be a string.')
    elseif ~all(size(Hmax)==[1 1])
      error('PDE:initmesh:HmaxNotScalar', 'Hmax must be a scalar.')
    elseif imag(Hmax)
      error('PDE:initmesh:HmaxComplex', 'Hmax must not be complex.')
    elseif Hmax<0
      error('PDE:initmesh:HmaxNeg', 'Hmax must be non negative.')
    end
  elseif strcmp(Param,'hgrad'),
    Hgrad=Value;
    if ischar(Hgrad)
      error('PDE:initmesh:HgradString', 'Hgrad must not be a string.')
    elseif ~all(size(Hgrad)==[1 1])
      error('PDE:initmesh:HgradNotScalar', 'Hgrad must be a scalar.')
    elseif imag(Hgrad)
      error('PDE:initmesh:HgradComplex', 'Hgrad must not be complex.')
    elseif Hgrad<=1 || Hgrad>=2
      error('PDE:initmesh:HgradOutOfRange', 'Hgrad must be a real number between 1 and 2.')
    end
  elseif strcmp(Param,'box'),
    Box=lower(Value);
    if ~ischar(Box)
      error('PDE:initmesh:BoxNotString', 'Box must be a string.')
    elseif ~strcmp(Init,'on') && ~strcmp(Init,'off')
      error('PDE:initmesh:BoxInvalidString', 'Box must be {off} | on .')
    end
  elseif strcmp(Param,'init'),
    Init=lower(Value);
    if ~ischar(Init)
      error('PDE:initmesh:InitNotString', 'Init must be a string.')
    elseif ~strcmp(Init,'on') && ~strcmp(Init,'off')
      error('PDE:initmesh:InitInvalidString', 'Init must be {off} | on .')
    end
  elseif strcmp(Param,'jiggle')
    Jiggle=lower(Value);
    if ~ischar(Jiggle)
      error('PDE:initmesh:JiggleNotString', 'Jiggle must be a string.')
    elseif ~strcmp(Jiggle,'on') && ~strcmp(Jiggle,'off') &&  ...
           ~strcmp(Jiggle,'minimum') && ~strcmp(Jiggle,'mean')
      error('PDE:initmesh:JiggleInvalidString', 'Jiggle must be on | off | minimum | {mean}.')
    end
  elseif strcmp(Param,'jiggleiter')
    JiggleIter=Value;
    if ischar(JiggleIter)
      error('PDE:initmesh:JiggleiterString', 'JiggleIter must not be a string.')
    elseif ~all(size(JiggleIter)==[1 1])
      error('PDE:initmesh:JiggleiterNotScalar', 'JiggleIter must be a scalar.')
    elseif imag(JiggleIter)
      error('PDE:initmesh:JiggleiterComplex', 'JiggleIter must not be complex.')
    elseif JiggleIter<0
      error('PDE:initmesh:JiggleiterNeg', 'JiggleIter must be non negative.')
    end
  else
    error('PDE:initmesh:InvalidParam', ['Unknown parameter: ' Param])
  end
end

% Start by creating a coarse mesh

% Sort out mesh geometry
[p,e,Hmin,factor]=pdemgeom(g);

% Design bounding box
x=p(1,:); y=p(2,:);
xmin=min(x); xmax=max(x);
ymin=min(y); ymax=max(y);
xdiff=xmax-xmin; ydiff=ymax-ymin;
x1=xmin-xdiff; x2=xmax+xdiff;
y1=ymin-ydiff; y2=ymax+ydiff;
p=[x1 x2 x2 x1; y1 y1 y2 y2];
e(1:2,:)=e(1:2,:)+4;
t=[1 1; 2 3; 3 4; 0 0];

if ~Hmax
  Hmax=0.1*max(xdiff,ydiff);
end

% Display warning message for large number of triangles
if Hmax~=inf
  ntg=floor(2*(xmax-xmin)*(ymax-ymin)/Hmax^2);
else
  ntg=0;
end
if ntg>1000
  fprintf(1,'\nwarning: Approximately %d triangles will be generated.\n',ntg);
end

% determine scale and tolerance of model
small=10000*eps;
scale=max(xmax-xmin,ymax-ymin);
tol=small*scale;
tol2=small*scale^2;

% Triangulate edges
[p,t,c]=pdevoron(p,t,[],Hmax,x,y,tol,Hmax,Hgrad);

% Make sure that triangulation respects boundaries
[p,e,t,c]=pderespe(g,p,e,t,c,Hmax,tol,tol2,Hmax,Hgrad);

% Do we want Hmax==inf with bounding box ?
if Hmax==inf && strcmp(Box,'on')
  return
end

% Determine internal triangles
[k,t]=pdeintrn(p,e,t);
it=t(:,k);
ic=c(:,k);

% Do we want Hmax==inf?
if Hmax==inf
  % Remove outside points
  [p,e,t]=pdermpnt(p,e,it);
  return
end

% Check for narrow geometries
h=pdehloc(p,e,it,Hmax,Hmin,Hgrad);

% Distribute edge points
[x,y,e,h]=pdedistr(g,p,e,it,Hmax,Hgrad,tol,h,factor);

% Triangulate edges
[p,t,c,h]=pdevoron(p,t,[],h,x,y,tol,Hmax,Hgrad);

% Make sure that triangulation respects boundaries
[p,e,t,c,h]=pderespe(g,p,e,t,c,h,tol,tol2,Hmax,Hgrad);

% Determine internal triangles
[k,t]=pdeintrn(p,e,t);

it=t(:,k);
ic=c(:,k);

% Do we want initial mesh with bounding box?
if strcmp(Init,'on') && strcmp(Box,'on')
  return
end

% Do we want initial mesh?
if strcmp(Init,'on')
  % Remove outside points
  [p,e,t]=pdermpnt(p,e,it);
  return
end

t(:,k)=[];
c(:,k)=[];
ne=size(t,2);
t=[t,it];
c=[c,ic];

% Determine large triangles inside geometry and refine
while 1

  it1=it(1,:);
  it2=it(2,:);
  it3=it(3,:);

  % Triangle side lengths
  l1=(p(1,it2)-p(1,it1)).^2+(p(2,it2)-p(2,it1)).^2;
  l2=(p(1,it3)-p(1,it2)).^2+(p(2,it3)-p(2,it2)).^2;
  l3=(p(1,it1)-p(1,it3)).^2+(p(2,it1)-p(2,it3)).^2;

  % Triangle size
  l=sqrt(max(l1,max(l2,l3)));

  % Compute angles
  a=pdehloc(p,e,it);

  % Finished?
  if size(h,2)>1
    hh=prod([h(it1);h(it2);h(it3)]).^(1/3);
    k=find(l>=1.2*hh & min(abs(a-pi/2))>pi/8);
  else
    k=find(l>=1.2*h & min(abs(a-pi/2))>pi/8);
  end

  if isempty(k), break, end

  % Remaining triangles
  it=it(:,k);
  ic=ic(:,k);
  l=l(k);

  % Choose center of circumscribed circle of largest triangles
  % Ensure that we do not select points inside previous circles
  [l,si]=sort(l);
  n=length(l); i=n-1; j=1;
  sj=si(n);
  while i>0
    if isempty(find((ic(1,sj)-ic(1,si(i))).^2+...
                    (ic(2,sj)-ic(2,si(i))).^2-ic(3,sj).^2<=tol))
      j=j+1;
      sj(j)=si(i);
    end
    i=i-1;
  end
  x=ic(1,sj);
  y=ic(2,sj);

  % Something is going wrong - ignore!
  i=find(x>x2 | x<x1 | y>y2 | y<y1);
  x(i)=[];
  y(i)=[];
  if isempty(x), break, end

  % Triangulate
  [p,t1,c1,h]=pdevoron(p,t,c,h,x,y,tol,Hmax,Hgrad);

  % Check if outer triangles changed (internal boundaries may not be
  % respected).
  if any(any(t(:,1:ne)~=t1(:,1:ne)))
    % Make sure that triangulation respects boundaries
    [p,e,t,c,h]=pderespe(g,p,e,t1,c1,h,tol,tol2,Hmax,Hgrad);

    % Determine internal triangles
    k=pdeintrn(p,e,t);

    it=t(:,k);
    ic=c(:,k);
    t(:,k)=[];
    c(:,k)=[];
    ne=size(t,2);
    t=[t,it];
    c=[c,ic];
  else
    t=t1;
    c=c1;
    it=t(:,ne+1:size(t,2));
    ic=c(:,ne+1:size(t,2));
  end

end

% Make sure that triangulation respects internal boundaries
[p,e,t,c,h]=pderespe(g,p,e,t,c,h,tol,tol2,Hmax,Hgrad);

% Select internal triangles
[k,t]=pdeintrn(p,e,t);

if strcmp(Box,'on')
  return
end

% Remove outside points
t=t(:,k);
[p,e,t]=pdermpnt(p,e,t);

if ~strcmp(Jiggle,'off')
  if strcmp(Jiggle,'on')
    Opt='off';
  else
    Opt=Jiggle;
  end
  p=jigglemesh(p,e,t,'Iter',JiggleIter,'Opt',Opt);
end

