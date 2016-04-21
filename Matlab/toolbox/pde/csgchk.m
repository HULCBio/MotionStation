function gstat=csgchk(gd,xlim,ylim)
%CSGCHK Check validity of Geometry Description matrix.
%
%       GSTAT=CSGCHK(GD,XLIM,YLIM) checks if the solid objects in the
%       Geometry Description matrix GD are valid, given optional real numbers
%       XLIM and YLIM as current length of x- and y-axis, and using a special
%       format for polygons. For a polygon, the last vertex coordinate can now
%       be equal to the first do. to indicate a closed polygon. If XLIM and
%       YLIM are specified and if the first and the last vertices are not
%       equal, the polygon is considered as closed if these vertices are
%       within a certain "closing distance". These optional input arguments
%       are meant to be used only when calling CSGCHK from PDETOOL.
%
%       GSTAT=CSGCHK(GD) is identical to the above call, except for using
%       the same format of GD that is used by DECSG. This call is recommended
%       when using CSGCHK as a command-line function.
%
%       GSTAT, the Geometry Status vector, is a row vector of integers that
%       indicates the validity status of the corresponding solid objects,
%       i.e. columns, in GD.
%
%       For a circle solid, GSTAT=0 indicates that the circle has a positive
%       radius, 1 indicates a non-positive radius and 2 indicates that the
%       circle is not unique.
%
%       For a polygon, GSTAT=0 indicates that the polygon, is closed and do
%       not intersect itself, i.e. it has a well-defined, unique interior
%       region, 1 indicates an open and non self-intersecting polygon,
%       2 indicates a closed and self-intersecting polygon and 3 indicates
%       an open and self-intersecting polygon.
%
%       For a rectangle solid, GSTAT is identical to that of a polygon.
%       This is so because a rectangle is considered as a polygon by CSGCHK.
%
%       For an ellipse solid, GSTAT=0 indicates that the ellipse has positive
%       semiaxes, 1 indicates that at least one of the semiaxes is non
%       positive and 2 indicates that the ellipse is not unique.
%
%       If GSTAT consists of zero entries only then GD is valid and can be used
%       as input argument by DECSG.
%
%       See also DECSG.

%       B. Sjodin 29-06-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/18 03:11:16 $

CIRC=1;
POLY=2;
RECT=3;
ELLI=4;

% make RECT similar to POLY
gdri=find(gd(1,:)==RECT);
gd(1,gdri)=POLY*ones(1,length(gdri));

gstat=zeros(1,size(gd,2));         % initialize gstat
scale=0;                           % initialize scale of solid model

% determine closing distance
if nargin>1
  xtol=0.01*abs(xlim);
  ytol=0.01*abs(ylim);
end

% find circles in gd
gdci=find(gd(1,:)==CIRC);
gdcn=length(gdci);

% find polygons in gd
gdpi=find(gd(1,:)==POLY);
gdpn=length(gdpi);
if nargin==1
  % extend set of polygon vertices by a redundant
  % vertex, a copy of the first vertex, if necessary
  gd=[gd; zeros(2,size(gd,2))];
  for n=1:gdpn
    nv=gd(2,gdpi(n));
    gd(1:2+2*(nv+1),gdpi(n))=[gd(1:2+nv,gdpi(n)) ; gd(3,gdpi(n));...
                   gd(3+nv:2+2*nv,gdpi(n));gd(3+nv,gdpi(n))];
    gd(2,gdpi(n))=gd(2,gdpi(n))+1;
  end
end
gdln=sum(gd(2,gdpi))-gdpn;

% find ellipses in gd
gdei=find(gd(1,:)==ELLI);
gden=length(gdei);

% extract circle data from gd and determine scale
if gdcn>0
  cc=gd(2:3,gdci);                 % circle - x and y coordinates
  cr=gd(4,gdci);                   % circle - radius
  % determine bounding boxes for circles
  cmm=[cc(1,:)-cr;cc(1,:)+cr;cc(2,:)-cr;cc(2,:)+cr];
  scale=max(scale,max(max(abs(cmm))));
end

% extract polygon data from gd and determine scale
if gdpn>0
  % initialize polygon data
  gstat(gdpi)=ones(1,gdpn);        % initializes polygon geometry-status to 1
  gpec=zeros(4,gdln);              % initializes coordinate matrix
                                   % for all polygon edges: (x1,x2,y1,y2)
  % store polygon data
  pp=1;                            % polygon position in gpec
  for i=1:gdpn
    gdc=gd(:,gdpi(i));             % geometry description column
    k=pp:pp+gdc(2)-2;
    gpec(1,k)=gdc(3:1+gdc(2))';    % polygon edge coordinates
    gpec(2,k)=gdc(4:2+gdc(2))';
    gpec(3,k)=gdc(3+gdc(2):1+2*gdc(2))';
    gpec(4,k)=gdc(4+gdc(2):2+2*gdc(2))';
    pp=pp+gdc(2)-1;
  end
  % determine bounding boxes for polygon edges
  gpmm=[min(gpec(1,:),gpec(2,:));max(gpec(1,:),gpec(2,:))
     min(gpec(3,:),gpec(4,:));max(gpec(3,:),gpec(4,:))];
  scale=max(scale,max(max(abs(gpmm))));
end

% extract ellipse data from gd and determine scale
if gden>0
  ec=gd(2:3,gdei);                 % ellipse - x and y coordinates
  ea=gd(4,gdei);                   % ellipse - a axis
  eb=gd(5,gdei);                   % ellipse - b axis
  er=gd(6,gdei);                   % ellipse - rotation
  % determine bounding boxes for ellipses
  dd=max(ea,eb);
  emm=[ec(1,:)-dd;ec(1,:)+dd;ec(2,:)-dd;ec(2,:)+dd];
  scale=max(scale,max(max(abs(emm))));
end

% determine scale and tolerance of model
fuzz=1000;
small=fuzz*eps;
tol=small*scale;        % linear case
tol2=small*scale^2;     % quadratic case

% check status of circles
if gdcn>0
  % check if degenerated circle, i.e. radius zero
  cf=find(cr<tol);
  % indicate degenerated circles
  if ~isempty(cf)
    gstat(gdci(cf))=ones(1,length(cf));
  end
  % check if circle is not unique
  if gdcn>1
    i1=tril(ones(gdcn-1,1)*(1:gdcn)); i1(find(~i1))=[];
    i2=tril((2:gdcn)'*ones(1,gdcn)); i2(find(~i2))=[];
    cf=find(abs(cr(i2)-cr(i1))<tol & abs(cc(1,i2)-cc(1,i1))<tol & ...
          abs(cc(2,i2)-cc(2,i1))<tol);
    % indicate non-unique circles
    if ~isempty(cf)
      gstat(gdci(i1(cf)))=2*ones(1,length(cf));
      gstat(gdci(i2(cf)))=2*ones(1,length(cf));
    end
  end
end % "if gdcn>0"

% check status of polygons
if gdpn>0
  for pln=1:gdpn                   % scan all polygons
    gdc=gd(:,gdpi(pln));           % geometry description column
    ned=gdc(2)-1;                  % number of edges in polygon
    if ned>1
      pec=zeros(4,ned);    % initializes coordinate matrix for polygon
      if nargin>1
        if (((abs(gdc(3+ned)-gdc(3))<xtol)) && ...
            ((abs(gdc(4+2*ned)-gdc(4+ned)))<ytol))
          gstat(gdpi(pln))=0;      % indicate closed polygon, ok so far
        end
      else
        gstat(gdpi(pln))=0;        % indicate pre-defined closing
      end

      % check if self-intersecting polygon by determining line equations
      % for the edges and then count the number of intersections between
      % each edge
      k=1:ned;
      pec(1,k)=gdc(3:2+ned)';      % polygon edge coordinates
      pec(2,k)=gdc(4:3+ned)';
      pec(3,k)=gdc(4+ned:1+2*(ned+1))';
      pec(4,k)=gdc(5+ned:2+2*(ned+1))';
      % determine bounding boxes for polygon edges
      pmm=[min(pec(1,:),pec(2,:));max(pec(1,:),pec(2,:))
           min(pec(3,:),pec(4,:));max(pec(3,:),pec(4,:))];
      % determine line equations for polygon edges
      i1=tril(ones(ned-1,1)*(1:ned)); i1(find(~i1))=[];
      i2=tril((2:ned)'*ones(1,ned)); i2(find(~i2))=[];
      dx1=pec(2,i1)-pec(1,i1); dy1=pec(4,i1)-pec(3,i1);
      dx2=pec(2,i2)-pec(1,i2); dy2=pec(4,i2)-pec(3,i2);
      dt=dx1.*dy2-dx2.*dy1;
      dx=pec(1,i2)-pec(1,i1);
      dy=pec(3,i2)-pec(3,i1);
      istr=[];
      % find intersecting crossing lines
      i=find(abs(dt)>tol2);
      if ~isempty(i)
        j1=i1(i);
        j2=i2(i);
        hx=dy1(i).*pec(1,j1)-dx1(i).*pec(3,j1);
        hy=dy2(i).*pec(1,j2)-dx2(i).*pec(3,j2);
        xi=(dx1(i).*hy-dx2(i).*hx)./dt(i);
        yi=(hy.*dy1(i)-hx.*dy2(i))./dt(i);
        l1=find(xi-pmm(1,j1)>-tol & xi-pmm(2,j1)<tol & ...
            yi-pmm(3,j1)>-tol & yi-pmm(4,j1)<tol & ...
            xi-pmm(1,j2)>-tol & xi-pmm(2,j2)<tol & ...
            yi-pmm(3,j2)>-tol & yi-pmm(4,j2)<tol);
        istr=j1(l1);               % polygon intersection structure
      end
      % find intersecting parallel lines
      j=find(abs(dx1.*dy2-dx2.*dy1)<tol2 & abs(dx1.*dy-dy1.*dx)<tol2);
      j1=i1(j);
      j2=i2(j);
      % if there are parallel intersecting lines, extend istr and
      % if there are parallel intersecting lines that overlap,
      % extend istr such that this type of intersection counts as two
      if ~isempty(j)
        dx1=dx1(j); dy1=dy1(j);
        dx2=dx2(j); dy2=dy2(j);
        box1=pmm(:,j1);
        box2=pmm(:,j2);
        bis=( ( (box1(1,:)<=box2(1,:)) & (box1(2,:)+tol>=box2(1,:)-tol) ) |...
              ( (box1(1,:)>=box2(1,:)) & (box1(1,:)-tol<=box2(2,:)+tol) ) ) &...
            ( ( (box1(3,:)<=box2(3,:)) & (box1(4,:)+tol>=box2(3,:)-tol) ) |...
              ( (box1(3,:)>=box2(3,:)) & (box1(3,:)-tol<=box2(4,:)+tol) ) );
        l2=find(bis);
        l3=find(bis & ((abs(dx1)>tol & abs(dx2)>tol & dx1.*dx2<-tol2)|...
                       (abs(dy1)>tol & abs(dy2)>tol & dy1.*dy2<-tol2)));
        istr=[istr,j1(l2),j1(l3)];
      end

      for k=1:ned-1                % count number of intersections
        if isempty(istr)
          nofi(k) = 0;
        else
          nofi(k)=length(find(istr==k));
        end
      end

      % check if closed polygon is self-intersecting, while taking
      % account of closing distance
      if gstat(gdpi(pln))==0
        ok0=(nofi(1)<=2)&(max(nofi(2:ned-1))==1);
        if ~ok0, gstat(gdpi(pln))=2; end     % indicate closed & self-isect
        % check if degenerated edge
        fi=find((pmm(2,:)-pmm(1,:))<tol & (pmm(4,:)-pmm(3,:))<tol);
        if ~isempty(fi), gstat(gdpi(pln))=2; end
      end

      % check if open polygon is self-intersecting
      if gstat(gdpi(pln))==1
        ok1=max(nofi(1:ned-1))==1;
        if ~ok1, gstat(gdpi(pln))=3; end     % indicate open & self-isect
        % check if degenerated edge
        fi=find((pmm(2,:)-pmm(1,:))<tol & (pmm(4,:)-pmm(3,:))<tol);
        if ~isempty(fi), gstat(gdpi(pln))=3; end
      end
    else
      % check if one-edge polygon is degenerated
      fi=find((gpmm(2,:)-gpmm(1,:))<tol & (gpmm(4,:)-gpmm(3,:))<tol);
      if ~isempty(fi), gstat(gdpi(pln))=2; end
    end % "if ned>1"
  end % "for pln=1:gdpn"
end % "if gdpn>0"

% check status of ellipses
if gden>0
  % check if degenerated ellipse
  ef=find(ea<tol | eb<tol);
  gstat(gdei(ef))=ones(1,length(ef));        % indicate deg. ellipses

  % check if ellipse is not unique
  if gden>1
    i1=tril(ones(gden-1,1)*(1:gden)); i1(find(~i1))=[];
    i2=tril((2:gden)'*ones(1,gden)); i2(find(~i2))=[];
    adif=abs(er(i2)-er(i1));                 % angle distance
    awin=fix(adif./(2*pi));                  % winding difference
    adif=adif-awin*2*pi;                     % unwind to interval [0,2*pi)
    sc=abs(ec(1,i2)-ec(1,i1))<tol & abs(ec(2,i2)-ec(2,i1))<tol; % eq. center
    sab=abs(ea(i2)-ea(i1))<tol & abs(eb(i2)-eb(i1))<tol; % eq. semi-axes
    sba=abs(ea(i2)-eb(i1))<tol & abs(eb(i2)-ea(i1))<tol; % eq. semi-axes
    rt1=adif<tol | abs(adif-pi)<tol | abs(eb(i1)-ea(i1))<tol; % eq. ellipse
    rt2=abs(adif-pi/2)<tol | abs(adif-3*pi/2)<tol;            % eq. ellipse
    ef=find(sc & ( (sab & rt1) | (sba & rt2) ));
    % indicate non-unique ellipses
    gstat(gdei(i1(ef)))=2*ones(1,length(ef));
    gstat(gdei(i2(ef)))=2*ones(1,length(ef));
  end

  % check if ellipse is identical to circle
  if gdcn>0 && gden>0
    i1=ones(gden,1)*(1:gdcn); i1=i1(:)';     % circles
    i2=(1:gden)'*ones(1,gdcn); i2=i2(:)';    % ellipses

    % prevent boolean interpretation
    if max(i1)==1 & size(cc,2)==length(i1)
      cc(1:2,size(cc,2)+1)=[NaN;NaN]; cr(length(cr)+1)=NaN;
    end
    if max(i2)==1 & size(ec,2)==length(i1)
      ec(1:2,size(ec,2)+1)=[NaN;NaN]; ea(length(ea)+1)=NaN;
      eb(length(eb)+1)=NaN; er(length(er)+1)=NaN;
    end

    ecf=find(abs(ec(1,i2)-cc(1,i1))<tol & abs(ec(2,i2)-cc(2,i1))<tol & ...
             abs(ea(i2)-cr(i1))<tol & abs (eb(i2)-cr(i1))<tol);
    % indicate identical circles-ellipses
    gstat(gdci(i1(ecf)))=2*ones(1,length(ecf));
    gstat(gdei(i2(ecf)))=2*ones(1,length(ecf));
  end

end % "if gden>0"

