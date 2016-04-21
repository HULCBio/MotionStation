function [dl1,bt1,dl,bt,msb]=decsg(gd,sf,ns)
%DECSG  Decompose constructive solid geometry into minimal regions.
%
%       DL=DECSG(GD,SF,NS) decomposes the solid objects GD into
%       the minimal regions DL.  The solid objects are represented by
%       the Geometry Description matrix, and the minimal regions are
%       represented by the Decomposed Geometry matrix.  DECSG returns
%       the minimal regions that evaluate to true for the set formula SF.
%       NS is a Name Space matrix that relates the columns in
%       GD to variable names in SF.
%
%       DL=DECSG(GD) returns all minimal regions.
%
%       [DL,BT]=DECSG(GD) and [DL,BT]=DECSG(GD,SF,NS) additionally returns a
%       Boolean table BT that relates the original solid objects to the
%       minimal regions.  A column in BT corresponds to the column with
%       the same index in GD.  A row in BT corresponds to the column with
%       the same index in DL.
%
%       [DL,BT,DL1,BT1,MSB1]=DECSG(GD) and [DL,BT,DL1,BT1,MSB1]=DECSG(GD)
%       return a second set of minimal regions DL1 with a corresponding
%       Boolean table BT1.  This second set of minimal regions all have
%       a connected outer boundary. These minimal regions can be plotted
%       by using MATLAB patch objects. The calling sequences
%       additionally returns a sequence MSB1 of drawing commands for
%       each second minimal region.
%
%       GEOMETRY DESCRIPTION MATRIX
%
%       The  Geometry Description matrix GD describes solid model that
%       you draw in the PDETOOL GUI.
%
%       Each column in the Geometry Description matrix corresponds to an
%       object in the solid geometry model. Four types of solid objects are
%       supported.  The object type is specified in row one:
%
%       1. For the circle solid, row one contains 1, the second and
%       third row contain the center x- and y-coordinates respectively.
%       Row four contains the radius of the circle.
%       2. For a polygon solid, row one contains 2, and the second row
%       contains the number, N, of line segments in the boundary.
%       The following N rows contain the x-coordinates of the starting points
%       of the edges, and the following N rows contain the y-coordinates of the
%       starting points of the edges.
%       3. For a rectangle solid, row one contains 3. The format is otherwise
%       identical to the polygon format.
%       4. For an ellipse solid, row one contains 4, the second and
%       third row contain the center x- and y-coordinates respectively. Row
%       four and five contain the major and minor axes of the ellipse.
%       The rotational angle of the ellipse is stored in row six.
%
%       DECOMPOSED GEOMETRY MATRIX
%
%       The Decomposed Geometry matrix DL contains a representation of
%       the minimal regions that have been constructed by the DECSG algorithm.
%       Each edge segment of the minimal regions correspond to a column
%       in DL. In each such column rows two and three contain the starting
%       and ending x-coordinate, and rows four and five the corresponding
%       y-coordinate. Rows six and seven contain left and right minimal region
%       numbers with respect to the direction induced by the start and end
%       points (counter clockwise direction on circle and ellipse segments).
%       There are three types of possible edge segments in a minimal regions:
%
%       1. For circle edge segments row one is 1. Rows eight and nine
%       contain the coordinates of the center of the circle. Row 10 contains
%       the radius.
%       2. For line edge segments row one is 2.
%       3. For ellipse edge segments row one is 4. Rows eight and nine
%       contain the coordinates of the center of the ellipse. Rows 10
%       and 11 contain the major and minor axes of the ellipse
%       respectively. The rotational angle of the ellipse is stored in
%       row 12.
%
%       SET FORMULA
%
%       SF contains a set formula expressed with the set of variables
%       listed in NS. The operators '+', '*', and '-' correspond to the
%       set operations union, intersection, and set difference respectively.
%       The precedence of the operators '+' and '*' are the same. '-' has
%       higher precedence. The precedence can be controlled with parentheses.
%
%       NAME SPACE MATRIX - NS
%
%       The Name Space matrix NS relates the columns in GD to
%       variable names in SF. Each column in NS contain a sequence of
%       characters, padded with spaces. Each such character column assigns a
%       name to the corresponding geometric object in gd. In this way we can
%       refer to a specific object in gd in the set formula SF.
%
%       It is assumed that no circles are identical or have zero radius and
%       that no lines have zero length. All polygons must have
%       non-intersecting lines.
%
%       NaN is returned if the set formula SF cannot be evaluated.
%
%       See also: PDETOOL, PDEGEOM, PDEBOUND, WGEOM, WBOUND, PDECIRC,
%       PDEELLIP, PDEPOLY, PDERECT, INITMESH

%       L. Langemyr 6-03-94, LL 2-01-1995.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.13.4.1 $  $Date: 2003/11/18 03:11:17 $

if isempty(gd), dl1=[]; bt1=[]; dl=[]; bt=[]; msb=[]; return, end

CIRC=1;
POLY=2;
RECT=3;
ELLI=4;

% make RECT similar to POLY
i=find(gd(1,:)==RECT);
gd(1,i)=POLY*ones(1,length(i));

% find indices for lines, circles and ellipses in gd
gdci=find(gd(1,:)==CIRC);
gdli=find(gd(1,:)==POLY);
gdei=find(gd(1,:)==ELLI);
gdn=size(gd,2);
gdcn=length(gdci);
gdln=length(gdli);
gden=length(gdei);

% initialize variables
cc=zeros(2,gdcn);
cr=zeros(1,gdcn);
co=zeros(1,gdcn);
ec=zeros(2,gden);
ea=zeros(1,gden);
eb=zeros(1,gden);
er=zeros(1,gden);
eo=zeros(1,gden);

% Store circle information
cn=gdcn;
if cn>0
  cc=gd(2:3,gdci);                      % circle - x and y coordinates
  cr=gd(4,gdci);                        % circle - radius
  co=gdci;                              % original circle region
end

% Store ellipse information
en=gden;
if en>0
  ec=gd(2:3,gdei);              % ellipse - x and y coordinates
  ea=gd(4,gdei);                % ellipse - a axis
  eb=gd(5,gdei);                % ellipse - b axis
  er=gd(6,gdei);                % ellipse - rotation
  eo=gdei;                      % original ellipse region
end

% Preallocate area for line segments
lsn=sum(gd(2,gdli));
lsc=zeros(4,lsn);               % line segment coordinates - x1,x2,y1,y2
lsol=zeros(gdln,lsn);           % line segment - original regions on lhs
lsor=zeros(gdln,lsn);           % line segment - original regions on rhs
lsh=ones(1,lsn);                % line segment - shadow line

% Store line segment information and
% determine the interior of each polygon.
j=1;
for i=1:gdln
  gdc=gd(:,gdli(i));                    % gdc - geometry description column.
  % determine interior of polygon
  a=atan2(diff(gdc([3+gdc(2):2+2*gdc(2),3+gdc(2)])),...
          diff(gdc([3:2+gdc(2),3])));
  % Compute angle for each line segment.
  a=diff([a; a(1)]);
  a=sign(sum(a-floor((a+pi)/2/pi)*2*pi));
  % Determine if sum of angle differences is positive or negative.
  % This determines the direction of the interior, with respect to
  % the implicit direction of the boundary line segment information
  k=j:j+gdc(2)-1;
  lsc(1,k)=gdc(3:2+gdc(2))';            % coordinates
  lsc(2,k)=gdc([4:2+gdc(2),3])';
  lsc(3,k)=gdc([3+gdc(2):2+2*gdc(2)])';
  lsc(4,k)=gdc([4+gdc(2):2+2*gdc(2),3+gdc(2)])';
  l=ones(1,gdc(2));
  if a>=0,
    lsol(i,k)=l;                        % index of original region
  else
    lsor(i,k)=l;                        % index of original region
  end
  j=j+gdc(2);
end

% Compute bounding boxes for lines
if lsn>0
  lmm=[min(lsc(1,:),lsc(2,:));max(lsc(1,:),lsc(2,:))
       min(lsc(3,:),lsc(4,:));max(lsc(3,:),lsc(4,:))];
  scale=max(max(abs(lmm)));
else
  scale=0;
  lmm=[];
end

% Compute bounding boxes for circles
if cn>0
  cmm=[cc(1,:)-cr;cc(1,:)+cr;cc(2,:)-cr;cc(2,:)+cr];
  scale=max(scale,max(max(abs(cmm))));
else
  cmm=[];
end

% Compute bounding boxes for ellipses
if en>0
  ddx=abs(ea.*cos(er))+abs(eb.*sin(er)); ddy=abs(ea.*sin(er))+abs(eb.*cos(er));
  emm=[ec(1,:)-ddx;ec(1,:)+ddx;ec(2,:)-ddy;ec(2,:)+ddy];
  scale=max(scale,max(max(abs(emm))));
else
  emm=[];
end

% rescale geometry
lsc=lsc/scale;
lmm=lmm/scale;
cc=cc/scale; cr=cr/scale;
cmm=cmm/scale;
ec=ec/scale; ea=ea/scale; eb=eb/scale;
emm=emm/scale;

% determine scale and tolerance of model
fuzz=10000;
small=fuzz*eps;
small2=fuzz*sqrt(eps);

bf1=1;                                  % loop flag
bf2=1;                                  % recompute flag

while bf1

  % Check line segments for parallel intersecting lines
  % delete original line segments and create new disjoint line segments
  if lsn>1
    i1=tril(ones(lsn-1,1)*(1:lsn)); i1(find(~i1))=[];
    i2=tril((2:lsn)'*ones(1,lsn)); i2(find(~i2))=[];
    dx1=lsc(2,i1)-lsc(1,i1);            % create line equation
    dy1=lsc(4,i1)-lsc(3,i1);
    dx2=lsc(2,i2)-lsc(1,i2);
    dy2=lsc(4,i2)-lsc(3,i2);
    dx=lsc(1,i2)-lsc(1,i1);
    dy=lsc(3,i2)-lsc(3,i1);
    % check for same line
    i=find(abs(dx1.*dy2-dx2.*dy1)<small & abs(dx1.*dy-dy1.*dx)<small);
    % Construct line segment equivalence classes
    lq=sparse(i1(i),i2(i),i2(i),lsn,lsn);
    lq=lq+lq';
    ind=max(lq);
    lq=sign(lq+speye(lsn));
    ind=full(ind(1,:));
    ind=sort(ind);
    ind=ind(find([1 sign(diff(ind))]));
    ind(~ind)=[];
    del=[]; j=1;                        % split lines
    for c=ind
      q=full(find(lq(:,c)));
      del=[del;q];
      x=[lsc(1,q),lsc(2,q)];
      y=[lsc(3,q),lsc(4,q)];
      [x,i]=sort(x);
      if abs(x(1)-x(2*length(q)))<small
        y=sort(y);
        p=0;
      else
        y=y(i);
        p=1;
      end
      d=[true (abs(diff(x))>small | abs(diff(y))>small)];
      x=x(d);
      y=y(d);
      l=length(x);
      o1=ones(1,l-1);
      o2=ones(length(q),1);
      if p
        i1=lmm(2,q)'*o1-o2*x(2:l)>-small & lmm(1,q)'*o1-o2*x(1:l-1)<small;
      else
        i1=lmm(4,q)'*o1-o2*y(2:l)>-small & lmm(3,q)'*o1-o2*y(1:l-1)<small;
      end
      i2=logical(max(i1));
      i=lsn+j:length(find(i2))+lsn+j-1;
      x1=x(1:l-1); x2=x(2:l); y1=y(1:l-1); y2=y(2:l);
      lsc(:,i)=[x1(i2);x2(i2);y1(i2);y2(i2)];
      lmm(:,i)=[min(lsc(1,i),lsc(2,i))
          max(lsc(1,i),lsc(2,i))
          min(lsc(3,i),lsc(4,i))
          max(lsc(3,i),lsc(4,i))];
      if gdln>0
        lsol(:,i)=zeros(gdln,length(i));
        lsor(:,i)=zeros(gdln,length(i));
        l=1;
        for k=q'
          if (p && lsc(1,k)-lsc(2,k)<small) || (~p && lsc(3,k)-lsc(4,k)<small)
            lsol(:,i)=lsol(:,i)+lsol(:,k)*i1(l,i2);
            lsor(:,i)=lsor(:,i)+lsor(:,k)*i1(l,i2);
          else
            lsol(:,i)=lsol(:,i)+lsor(:,k)*i1(l,i2);
            lsor(:,i)=lsor(:,i)+lsol(:,k)*i1(l,i2);
          end
          l=l+1;
        end
      end
      lsh(i)=max((lsh(q)'*ones(1,length(i))) & i1(:,i2));
      j=j+length(i);
    end
    lsc(:,del)=[];
    lsh(del)=[];
    if gdln>0
      lsol(:,del)=[]; lsor(:,del)=[];
    end
    lmm(:,del)=[];
    lsn=size(lsc,2);
  end

  % Now, for all segments, determine intersections with other segments,
  % and solve for intersection points

  % Ellipse split points;
  epi=[]; epx=[]; epy=[];

  % Circle split points
  cpi=[]; cpx=[]; cpy=[];

  % Line split points
  lpi=[]; lpx=[]; lpy=[];

  % Check for intersecting ellipses
  % Determine points, at which ellipses should be split

  if en>1       % Use bounding boxes as first intersection check
    i1=tril(ones(en-1,1)*(1:en)); i1(find(~i1))=[];
    i2=tril((2:en)'*ones(1,en)); i2(find(~i2))=[];
    box1=emm(:,i1); box2=emm(:,i2);
    bis=( ( (box1(1,:)<=box2(1,:)) & (box1(2,:)+small>=box2(1,:)-small) ) |...
          ( (box1(1,:)>=box2(1,:)) & (box1(1,:)-small<=box2(2,:)+small) ) ) &...
        ( ( (box1(3,:)<=box2(3,:)) & (box1(4,:)+small>=box2(3,:)-small) ) |...
          ( (box1(3,:)>=box2(3,:)) & (box1(3,:)-small<=box2(4,:)+small) ) );
    fbis=find(~bis);
    i1(fbis)=[]; i2(fbis)=[];
  end

  rootmerror = 'PDE:decsg:RootMultGt2'; 
  interror = 'PDE:decsg:InternalError'; 
  
  if en>1 && ~isempty(i1)        % Determine split-points
    ca=cos(er(i1)); sa=sin(er(i1));
    d=ec(:,i2)-ec(:,i1);
    x0=ca.*d(1,:)+sa.*d(2,:);
    y0=-sa.*d(1,:)+ca.*d(2,:);
    r2=er(1,i2)-er(i1);
    cr2=cos(r2); sr2=sin(r2);
    a=ea(i2); b=eb(i2);
    A=b.^2.*cr2.^2+a.^2.*sr2.^2;
    B=-2*a.^2.*cr2.*sr2+2*b.^2.*cr2.*sr2;
    C=b.^2.*sr2.^2+a.^2.*cr2.^2;
    D=2*a.^2.*cr2.*sr2.*y0-2*a.^2.*sr2.^2.*x0-...
      2*b.^2.*cr2.*sr2.*y0-2*b.^2.*cr2.^2.*x0;
    E=-2*b.^2.*sr2.^2.*y0+2*a.^2.*cr2.*x0.*sr2-...
      2*b.^2.*cr2.*x0.*sr2-2*a.^2.*cr2.^2.*y0;
    F=b.^2.*cr2.^2.*x0.^2+a.^2.*sr2.^2.*x0.^2+...
      2*b.^2.*cr2.*x0.*sr2.*y0-2*a.^2.*cr2.*x0.*sr2.*y0+...
      b.^2.*sr2.^2.*y0.^2+a.^2.*cr2.^2.*y0.^2-a.^2.*b.^2;
    p1=[-C.*eb(i1).^2+A.*ea(i1).^2;D.*ea(i1);F+C.*eb(i1).^2];
    p2=[B.*ea(i1).*eb(i1);E.*eb(i1)];
    p3=[C.*eb(i1).^2-A.*ea(i1).^2;E.*eb(i1);F+A.*ea(i1).^2];
    p4=[B.*ea(i1).*eb(i1);D.*ea(i1)];
    for i=1:length(i1)
      px=conv(conv(p2(:,i),p2(:,i)),[-1 0 1]')-conv(p1(:,i),p1(:,i));
      x=roots(px);
      nx=length(x);
      j1=tril(ones(nx-1,1)*(1:nx)); if ~isempty(j1), j1(find(~j1))=[]; end
      j2=tril((2:nx)'*ones(1,nx)); if ~isempty(j2), j2(find(~j2))=[]; end
      j=find(abs(x(j1)-x(j2))<small2);
      if ~isempty(j)
        if length(j)==6
          x=0;
        elseif length(j)>2
          error(rootmerror, 'root multiplicity greater than 2.');
        else
          if length(j)==2
            if j(:)~=[1;6] & j(:)~=[2;5] & j(:)~=[3;6]
              error(rootmerror, 'root multiplicity greater than 2.');
            end
          end
          pxp=[4 3 2 1]'.*px(1:4);
          xp=roots(pxp);
          for jj=j(:)'
            jjj=find(abs(x(j1(jj))-xp)<small2);
            if length(jjj)~=1
              error(interror, 'internal decsg error.');
            end
            x(j1(jj))=xp(jjj);
            x(j2(jj))=2;
          end
        end
      end
      j=find(abs(x)<1+small&abs(imag(x))<small);
      x=x(j);
      x=ea(i1(i))*x;

      py=conv(conv(p4(:,i),p4(:,i)),[-1 0 1]')-conv(p3(:,i),p3(:,i));
      y=roots(py);
      ny=length(y);
      j1=tril(ones(ny-1,1)*(1:ny)); if ~isempty(j1), j1(find(~j1))=[]; end
      j2=tril((2:ny)'*ones(1,ny)); if ~isempty(j2), j2(find(~j2))=[]; end
      j=find(abs(y(j1)-y(j2))<small2);
      if ~isempty(j)
        if length(j)==6
          y=0;
        elseif length(j)>2
          error(rootmerror,'root multiplicity greater than 2.');
        else
          if length(j)==2
            if j(:)~=[1;6] & j(:)~=[2;5] & j(:)~=[3;6]
              error(rootmerror, 'root multiplicity greater than 2.');
            end
          end
          pyp=[4 3 2 1]'.*py(1:4);
          yp=roots(pyp);
          for jj=j(:)'
            jjj=find(abs(y(j1(jj))-yp)<small2);
            if length(jjj)~=1
              error(interror, 'internal decsg error.');
            end
            y(j1(jj))=yp(jjj);
            y(j2(jj))=2;
          end
        end
      end
      j=find(abs(y)<1+small&abs(imag(y))<small);
      y=y(j);
      y=eb(i1(i))*y;

      nx=length(x);
      ny=length(y);
      x=x(:)*ones(1,ny);
      y=ones(nx,1)*y(:)';

      j=find(abs(A(i)*x.^2+B(i)*x.*y+C(i)*y.^2+D(i)*x+E(i)*y+F(i))<small);
      x=x(j); y=y(j);

      xr=x(:)'; yr=y(:)';
      x=ec(1,i1(i))+ca(i).*xr-sa(i).*yr;
      y=ec(2,i1(i))+sa(i).*xr+ca(i).*yr;
      n=length(x);
      epi=[epi,i1(i)*ones(1,n)]; epx=[epx,x]; epy=[epy,y];
      epi=[epi,i2(i)*ones(1,n)]; epx=[epx,x]; epy=[epy,y];
    end
  end

  % Check for intersecting ellipses and circles
  % Determine points, at which ellipses and circles should be split

  if en>0 && cn>0        % Use bounding boxes as first intersection check
    i1=ones(en,1)*(1:cn); i1=i1(:)';
    i2=(1:en)'*ones(1,cn); i2=i2(:)';
    box1=cmm(:,i1); box2=emm(:,i2);
    bis=( ( (box1(1,:)<=box2(1,:)) & (box1(2,:)+small>=box2(1,:)-small) ) |...
          ( (box1(1,:)>=box2(1,:)) & (box1(1,:)-small<=box2(2,:)+small) ) ) &...
        ( ( (box1(3,:)<=box2(3,:)) & (box1(4,:)+small>=box2(3,:)-small) ) |...
          ( (box1(3,:)>=box2(3,:)) & (box1(3,:)-small<=box2(4,:)+small) ) );
    fbis=find(~bis);
    i1(fbis)=[]; i2(fbis)=[];
  end

  if en>0 && cn>0 && ~isempty(i1)         % Determine split-points
    x0=ec(1,i2)-cc(1,i1);
    y0=ec(2,i2)-cc(2,i1);
    r2=er(1,i2);
    cr2=cos(r2); sr2=sin(r2);
    a=ea(i2); b=eb(i2);
    A=b.^2.*cr2.^2+a.^2.*sr2.^2;
    B=-2*a.^2.*cr2.*sr2+2*b.^2.*cr2.*sr2;
    C=b.^2.*sr2.^2+a.^2.*cr2.^2;
    D=2*a.^2.*cr2.*sr2.*y0-2*a.^2.*sr2.^2.*x0-...
      2*b.^2.*cr2.*sr2.*y0-2*b.^2.*cr2.^2.*x0;
    E=-2*b.^2.*sr2.^2.*y0+2*a.^2.*cr2.*x0.*sr2-...
      2*b.^2.*cr2.*x0.*sr2-2*a.^2.*cr2.^2.*y0;
    F=b.^2.*cr2.^2.*x0.^2+a.^2.*sr2.^2.*x0.^2+...
      2*b.^2.*cr2.*x0.*sr2.*y0-2*a.^2.*cr2.*x0.*sr2.*y0+...
      b.^2.*sr2.^2.*y0.^2+a.^2.*cr2.^2.*y0.^2-a.^2.*b.^2;
    p1=[-C.*cr(i1).^2+A.*cr(i1).^2;D.*cr(i1);F+C.*cr(i1).^2];
    p2=[B.*cr(i1).*cr(i1);E.*cr(i1)];
    p3=[C.*cr(i1).^2-A.*cr(i1).^2;E.*cr(i1);F+A.*cr(i1).^2];
    p4=[B.*cr(i1).*cr(i1);D.*cr(i1)];
    for i=1:length(i1)
      px=conv(conv(p2(:,i),p2(:,i)),[-1 0 1]')-conv(p1(:,i),p1(:,i));
      x=roots(px);
      nx=length(x);
      j1=tril(ones(nx-1,1)*(1:nx)); if ~isempty(j1), j1(find(~j1))=[]; end
      j2=tril((2:nx)'*ones(1,nx)); if ~isempty(j2), j2(find(~j2))=[]; end
      j=find(abs(x(j1)-x(j2))<small2);
      if ~isempty(j)
        if length(j)==6
          x=0;
        elseif length(j)>2
          error(rootmerror, 'root multiplicity greater than 2.');
        else
          if length(j)==2
            if j(:)~=[1;6] & j(:)~=[2;5] & j(:)~=[3;6]
              error(rootmerror, 'root multiplicity greater than 2.');
            end
          end
          pxp=[4 3 2 1]'.*px(1:4);
          xp=roots(pxp);
          for jj=j(:)'
            jjj=find(abs(x(j1(jj))-xp)<small2);
            if length(jjj)~=1
              error(interror, 'internal decsg error.');
            end
            x(j1(jj))=xp(jjj);
            x(j2(jj))=2;
          end
        end
      end
      j=find(abs(x)<1+small&abs(imag(x))<small);
      x=x(j);
      x=cr(i1(i))*x;

      py=conv(conv(p4(:,i),p4(:,i)),[-1 0 1]')-conv(p3(:,i),p3(:,i));
      y=roots(py);
      ny=length(y);
      j1=tril(ones(ny-1,1)*(1:ny)); if ~isempty(j1), j1(find(~j1))=[]; end
      j2=tril((2:ny)'*ones(1,ny)); if ~isempty(j2), j2(find(~j2))=[]; end
      j=find(abs(y(j1)-y(j2))<small2);
      if ~isempty(j)
        if length(j)==6
          y=0;
        elseif length(j)>2
          error(rootmerror, 'root multiplicity greater than 2.');
        else
          if length(j)==2
            if j(:)~=[1;6] & j(:)~=[2;5] & j(:)~=[3;6]
              error(rootmerror, 'root multiplicity greater than 2.');
            end
          end
          pyp=[4 3 2 1]'.*py(1:4);
          yp=roots(pyp);
          for jj=j(:)'
            jjj=find(abs(y(j1(jj))-yp)<small2);
            if length(jjj)~=1
              error(interror, 'internal decsg error.');
            end
            y(j1(jj))=yp(jjj);
            y(j2(jj))=2;
          end
        end
      end
      j=find(abs(y)<1+small&abs(imag(y))<small);
      y=y(j);
      y=cr(i1(i))*y;

      nx=length(x);
      ny=length(y);
      x=x(:)*ones(1,ny);
      y=ones(nx,1)*y(:)';

      j=find(abs(A(i)*x.^2+B(i)*x.*y+C(i)*y.^2+D(i)*x+E(i)*y+F(i))<small);
      x=x(j); y=y(j);

      x=cc(1,i1(i))+x(:)';
      y=cc(2,i1(i))+y(:)';
      n=length(x);
      cpi=[cpi,i1(i)*ones(1,n)]; cpx=[cpx,x]; cpy=[cpy,y];
      epi=[epi,i2(i)*ones(1,n)]; epx=[epx,x]; epy=[epy,y];
    end
  end

  % Check for intersecting ellipse and line segments
  % Determine points, at which ellipses and lines should be split

  if en>0 && lsn>0       % Use bounding boxes as first intersection check
    i1=ones(en,1)*(1:lsn); i1=i1(:)';
    i2=(1:en)'*ones(1,lsn); i2=i2(:)';
    box1=lmm(:,i1); box2=emm(:,i2);
    bis=( ( (box1(1,:)<=box2(1,:)) & (box1(2,:)+small>=box2(1,:)-small) ) |...
          ( (box1(1,:)>=box2(1,:)) & (box1(1,:)-small<=box2(2,:)+small) ) ) &...
        ( ( (box1(3,:)<=box2(3,:)) & (box1(4,:)+small>=box2(3,:)-small) ) |...
          ( (box1(3,:)>=box2(3,:)) & (box1(3,:)-small<=box2(4,:)+small) ) );
    fbis=find(~bis);
    i1(fbis)=[]; i2(fbis)=[];
  end

  if en>0 && lsn>0 && ~isempty(i1)        % Determine split-points
    x0=ec(1,i2);
    y0=ec(2,i2);
    r2=er(1,i2);
    cr2=cos(r2); sr2=sin(r2);
    a=ea(i2); b=eb(i2);
    A=b.^2.*cr2.^2+a.^2.*sr2.^2;
    B=-2*a.^2.*cr2.*sr2+2*b.^2.*cr2.*sr2;
    C=b.^2.*sr2.^2+a.^2.*cr2.^2;
    D=2*a.^2.*cr2.*sr2.*y0-2*a.^2.*sr2.^2.*x0-...
      2*b.^2.*cr2.*sr2.*y0-2*b.^2.*cr2.^2.*x0;
    E=-2*b.^2.*sr2.^2.*y0+2*a.^2.*cr2.*x0.*sr2-...
      2*b.^2.*cr2.*x0.*sr2-2*a.^2.*cr2.^2.*y0;
    F=b.^2.*cr2.^2.*x0.^2+a.^2.*sr2.^2.*x0.^2+...
      2*b.^2.*cr2.*x0.*sr2.*y0-2*a.^2.*cr2.*x0.*sr2.*y0+...
      b.^2.*sr2.^2.*y0.^2+a.^2.*cr2.^2.*y0.^2-a.^2.*b.^2;
    x0=lsc(1,i1); x1=lsc(2,i1); y0=lsc(3,i1); y1=lsc(4,i1);
    a=A.*x0.^2-2*A.*x0.*x1+C.*y0.^2-B.*x1.*y0+A.*x1.^2+B.*x1.*y1-...
      2*C.*y0.*y1-B.*x0.*y1+B.*x0.*y0+C.*y1.^2;
    b=2*A.*x0.*x1-E.*y0+B.*x1.*y0+2*C.*y0.*y1+E.*y1-2*A.*x0.^2-...
      2*C.*y0.^2-D.*x0+B.*x0.*y1-2*B.*x0.*y0+D.*x1;
    c=A.*x0.^2+F+B.*x0.*y0+D.*x0+E.*y0+C.*y0.^2;
    d=b.^2-4*a.*c;
    i=find(abs(d)<small);
    if ~isempty(i)
      j1=i1(i)'; j2=i2(i)';
      xi=lsc(1,j1)-b(i)./a(i)/2.*(lsc(2,j1)-lsc(1,j1));
      yi=lsc(3,j1)-b(i)./a(i)/2.*(lsc(4,j1)-lsc(3,j1));
      k=find((xi-lmm(1,j1)>small & xi-lmm(2,j1)<-small) | ...
             (yi-lmm(3,j1)>small & yi-lmm(4,j1)<-small));
      lpi=[lpi,j1(k)']; lpx=[lpx,xi(k)]; lpy=[lpy,yi(k)];
      k=find((xi-lmm(1,j1)>-small & xi-lmm(2,j1)<small) & ...
             (yi-lmm(3,j1)>-small & yi-lmm(4,j1)<small));
      epi=[epi,j2(k)']; epx=[epx,xi(k)]; epy=[epy,yi(k)];
    end
    i=find(d>=small);
    if ~isempty(i)
      j1=i1(i)'; j2=i2(i)';
      xi=lsc(1,j1)+(-b(i)-sqrt(d(i)))./a(i)/2.*(lsc(2,j1)-lsc(1,j1));
      yi=lsc(3,j1)+(-b(i)-sqrt(d(i)))./a(i)/2.*(lsc(4,j1)-lsc(3,j1));
      k=find((xi-lmm(1,j1)>small & xi-lmm(2,j1)<-small) | ...
          (yi-lmm(3,j1)>small & yi-lmm(4,j1)<-small));
      lpi=[lpi,j1(k)']; lpx=[lpx,xi(k)]; lpy=[lpy,yi(k)];
      k=find((xi-lmm(1,j1)>-small & xi-lmm(2,j1)<small) & ...
             (yi-lmm(3,j1)>-small & yi-lmm(4,j1)<small));
      epi=[epi,j2(k)']; epx=[epx,xi(k)]; epy=[epy,yi(k)];
      xi=lsc(1,j1)+(-b(i)+sqrt(d(i)))./a(i)/2.*(lsc(2,j1)-lsc(1,j1));
      yi=lsc(3,j1)+(-b(i)+sqrt(d(i)))./a(i)/2.*(lsc(4,j1)-lsc(3,j1));
      k=find((xi-lmm(1,j1)>small & xi-lmm(2,j1)<-small) | ...
             (yi-lmm(3,j1)>small & yi-lmm(4,j1)<-small));
      lpi=[lpi,j1(k)']; lpx=[lpx,xi(k)]; lpy=[lpy,yi(k)];
      k=find((xi-lmm(1,j1)>-small & xi-lmm(2,j1)<small) & ...
             (yi-lmm(3,j1)>-small & yi-lmm(4,j1)<small));
      epi=[epi,j2(k)']; epx=[epx,xi(k)]; epy=[epy,yi(k)];
    end
  end

  % Check for intersecting circles
  % Determine points, at which circles should be split
  if cn>1       % Use bounding boxes as first intersection check
    i1=tril(ones(cn-1,1)*(1:cn)); i1(find(~i1))=[];
    i2=tril((2:cn)'*ones(1,cn)); i2(find(~i2))=[];
    box1=cmm(:,i1); box2=cmm(:,i2);
    bis=( ( (box1(1,:)<=box2(1,:)) & (box1(2,:)+small>=box2(1,:)-small) ) |...
          ( (box1(1,:)>=box2(1,:)) & (box1(1,:)-small<=box2(2,:)+small) ) ) &...
        ( ( (box1(3,:)<=box2(3,:)) & (box1(4,:)+small>=box2(3,:)-small) ) |...
          ( (box1(3,:)>=box2(3,:)) & (box1(3,:)-small<=box2(4,:)+small) ) );
    fbis=find(~bis);
    i1(fbis)=[]; i2(fbis)=[];
  end

  if cn>1 && ~isempty(i1)        % Determine split-points
    d=sqrt((cc(2,i2)-cc(2,i1)).^2+(cc(1,i2)-cc(1,i1)).^2);
    i=find(abs(d)<small);                       % same center
    d(i)=[]; i1(i)=[]; i2(i)=[];
    if ~isempty(d)
    b=(d.^2+cr(1,i1).^2-cr(1,i2).^2)./cr(1,i1)./d/2;
    i=find(b-(-1)>=small & b-1<=-small);
    if ~isempty(i)
      j1=i1(i); j2=i2(i); a=acos(b(i));
      c=atan2(cc(2,j2)-cc(2,j1),cc(1,j2)-cc(1,j1));
      xi=cc(1,j1)+cr(1,j1).*cos(c+a);
      yi=cc(2,j1)+cr(1,j1).*sin(c+a);
      cpi=[cpi,j1]; cpx=[cpx,xi]; cpy=[cpy,yi];
      cpi=[cpi,j2]; cpx=[cpx,xi]; cpy=[cpy,yi];
      xi=cc(1,j1)+cr(1,j1).*cos(c-a);
      yi=cc(2,j1)+cr(1,j1).*sin(c-a);
      cpi=[cpi,j1]; cpx=[cpx,xi]; cpy=[cpy,yi];
      cpi=[cpi,j2]; cpx=[cpx,xi]; cpy=[cpy,yi];
    end
    i=find(abs(b+1)<small);
    if ~isempty(i)
      j1=i1(i); j2=i2(i);
      c=atan2(cc(2,j2)-cc(2,j1),cc(1,j2)-cc(1,j1));
      xi=cc(1,j1)+cr(1,j1).*cos(c-pi);
      yi=cc(2,j1)+cr(1,j1).*sin(c-pi);
      cpi=[cpi,j1]; cpx=[cpx,xi]; cpy=[cpy,yi];
      cpi=[cpi,j2]; cpx=[cpx,xi]; cpy=[cpy,yi];
    end
    i=find(abs(b-1)<small);
    if ~isempty(i)
      j1=i1(i); j2=i2(i);
      c=atan2(cc(2,j2)-cc(2,j1),cc(1,j2)-cc(1,j1));
      xi=cc(1,j1)+cr(1,j1).*cos(c);
      yi=cc(2,j1)+cr(1,j1).*sin(c);
      cpi=[cpi,j1]; cpx=[cpx,xi]; cpy=[cpy,yi];
      cpi=[cpi,j2]; cpx=[cpx,xi]; cpy=[cpy,yi];
    end
    end
  end

  % Check for intersecting circle and line segments
  % Determine points, at which circles and lines should be split

  if cn>0 && lsn>0       % Use bounding boxes as first intersection check
    i1=ones(cn,1)*(1:lsn); i1=i1(:);
    i2=(1:cn)'*ones(1,lsn); i2=i2(:);
    box1=lmm(:,i1); box2=cmm(:,i2);
    bis=( ( (box1(1,:)<=box2(1,:)) & (box1(2,:)+small>=box2(1,:)-small) ) |...
          ( (box1(1,:)>=box2(1,:)) & (box1(1,:)-small<=box2(2,:)+small) ) ) &...
        ( ( (box1(3,:)<=box2(3,:)) & (box1(4,:)+small>=box2(3,:)-small) ) |...
          ( (box1(3,:)>=box2(3,:)) & (box1(3,:)-small<=box2(4,:)+small) ) );
    fbis=find(~bis);
    i1(fbis)=[]; i2(fbis)=[];
  end

  if cn>0 && lsn>0 && ~isempty(i1)        % Determine split-points
    a=(lsc(4,i1)-lsc(3,i1)).^2+(lsc(2,i1)-lsc(1,i1)).^2;
    b=2*(lsc(1,i1)-cc(1,i2)).*(lsc(2,i1)-lsc(1,i1))+ ...
      2*(lsc(3,i1)-cc(2,i2)).*(lsc(4,i1)-lsc(3,i1));
    c=(lsc(1,i1)-cc(1,i2)).^2+(lsc(3,i1)-cc(2,i2)).^2-cr(1,i2).^2;
    d=b.^2-4*a.*c;
    i=find(abs(d)<small);
    if ~isempty(i)
      j1=i1(i); j2=i2(i);
      xi=lsc(1,j1)-b(i)./a(i)/2.*(lsc(2,j1)-lsc(1,j1));
      yi=lsc(3,j1)-b(i)./a(i)/2.*(lsc(4,j1)-lsc(3,j1));
      k=find((xi-lmm(1,j1)>small & xi-lmm(2,j1)<-small) | ...
             (yi-lmm(3,j1)>small & yi-lmm(4,j1)<-small));
      lpi=[lpi,j1(k)']; lpx=[lpx,xi(k)]; lpy=[lpy,yi(k)];
      k=find((xi-lmm(1,j1)>-small & xi-lmm(2,j1)<small) & ...
             (yi-lmm(3,j1)>-small & yi-lmm(4,j1)<small));
      cpi=[cpi,j2(k)']; cpx=[cpx,xi(k)]; cpy=[cpy,yi(k)];
    end
    i=find(d>=small);
    if ~isempty(i)
      j1=i1(i); j2=i2(i);
      xi=lsc(1,j1)+(-b(i)-sqrt(d(i)))./a(i)/2.*(lsc(2,j1)-lsc(1,j1));
      yi=lsc(3,j1)+(-b(i)-sqrt(d(i)))./a(i)/2.*(lsc(4,j1)-lsc(3,j1));
      k=find((xi-lmm(1,j1)>small & xi-lmm(2,j1)<-small) | ...
             (yi-lmm(3,j1)>small & yi-lmm(4,j1)<-small));
      lpi=[lpi,j1(k)']; lpx=[lpx,xi(k)]; lpy=[lpy,yi(k)];
      k=find((xi-lmm(1,j1)>-small & xi-lmm(2,j1)<small) & ...
             (yi-lmm(3,j1)>-small & yi-lmm(4,j1)<small));
      cpi=[cpi,j2(k)']; cpx=[cpx,xi(k)]; cpy=[cpy,yi(k)];
      xi=lsc(1,j1)+(-b(i)+sqrt(d(i)))./a(i)/2.*(lsc(2,j1)-lsc(1,j1));
      yi=lsc(3,j1)+(-b(i)+sqrt(d(i)))./a(i)/2.*(lsc(4,j1)-lsc(3,j1));
      k=find((xi-lmm(1,j1)>small & xi-lmm(2,j1)<-small) | ...
             (yi-lmm(3,j1)>small & yi-lmm(4,j1)<-small));
      lpi=[lpi,j1(k)']; lpx=[lpx,xi(k)]; lpy=[lpy,yi(k)];
      k=find((xi-lmm(1,j1)>-small & xi-lmm(2,j1)<small) & ...
             (yi-lmm(3,j1)>-small & yi-lmm(4,j1)<small));
      cpi=[cpi,j2(k)']; cpx=[cpx,xi(k)]; cpy=[cpy,yi(k)];
    end
  end

  % Check for intersecting line segments
  % Determine points, at which lines should be split
  if lsn>1
    i1=tril(ones(lsn-1,1)*(1:lsn)); i1(find(~i1))=[];
    i2=tril((2:lsn)'*ones(1,lsn)); i2(find(~i2))=[];
    dx1=lsc(2,i1)-lsc(1,i1); dy1=lsc(4,i1)-lsc(3,i1);
    dx2=lsc(2,i2)-lsc(1,i2); dy2=lsc(4,i2)-lsc(3,i2);
    dt=dx1.*dy2-dx2.*dy1;
    i=find(abs(dt)>small);              % check for intersecting lines
    i1=i1(i);
    i2=i2(i);
    hx=dy1(i).*lsc(1,i1)-dx1(i).*lsc(3,i1);
    hy=dy2(i).*lsc(1,i2)-dx2(i).*lsc(3,i2);
    xi=(dx1(i).*hy-dx2(i).*hx)./dt(i);
    yi=(hy.*dy1(i)-hx.*dy2(i))./dt(i);
    l1=find(((xi-lmm(1,i1)>small & xi-lmm(2,i1)<-small) | ...
             (yi-lmm(3,i1)>small & yi-lmm(4,i1)<-small)) & ...
            (xi-lmm(1,i2)>-small & xi-lmm(2,i2)<small & ...
             yi-lmm(3,i2)>-small & yi-lmm(4,i2)<small));
    lpi=[lpi,i1(l1)]; lpx=[lpx,xi(l1)]; lpy=[lpy,yi(l1)];
    l1=find((xi-lmm(1,i1)>-small & xi-lmm(2,i1)<small & ...
             yi-lmm(3,i1)>-small & yi-lmm(4,i1)<small) & ...
            ((xi-lmm(1,i2)>small & xi-lmm(2,i2)<-small) | ...
             (yi-lmm(3,i2)>small & yi-lmm(4,i2)<-small)));
    lpi=[lpi,i2(l1)]; lpx=[lpx,xi(l1)]; lpy=[lpy,yi(l1)];
  end

  esi=[];                       % ellipse segment ellipse index
  est=[];                       % ellipse segment angles - from, to
  esc=[];                       % ellipse segment coordinates - x1,x2,y1,y2

  csi=[];                       % circle segment circle index
  cst=[];                       % circle segment angles - from, to
  csc=[];                       % circle segment coordinates - x1,x2,y1,y2

  px=[];                        % points - x coordinates
  py=[];                        % points - y coordinates
  px1=[];                       % points - x coordinates
  py1=[];                       % points - y coordinates

  % Split ellipses
  if en>0
    px1=[px1,epx];
    py1=[py1,epy];
    for i=1:size(ec,2)
      if ~isempty(epi)
        k=find(epi==i);
      else
        k=[];
      end
      if isempty(k)
        t=linspace(-pi,pi/2,4);
      else
        R=[cos(er(i)) sin(er(i)); -sin(er(i)) cos(er(i))];
        xy=R*[epx(k)-ec(1,i);epy(k)-ec(2,i)];
        t=atan2(xy(2,:)/eb(i),xy(1,:)/ea(i));
        t=t-floor((t+pi)/2/pi)*2*pi;
        j=find(abs(t-pi)<small);
        t(j)=-pi*ones(size(j));
        t=sort(t);
        d=[true abs(diff(t))>small];
        t=t(d);
        t1=diff([t t(1)+2*pi]);
        j=find(t1-pi/2>small&t1-pi<=small);
        if ~isempty(j)
          t2=t(j)'+t1(j)'/2;
          t=[t t2(:)'];
        end
        j=find(t1-pi>small&t1-3*pi/2<=small);
        if ~isempty(j)
          t2=t(j)'*ones(1,2)+t1(j)'*[1 2]/3;
          t=[t t2(:)'];
        end
        j=find(t1-3*pi/2>small);
        if ~isempty(j)
          t2=t(j)'*ones(1,3)+t1(j)'*[1 2 3]/4;
          t=[t t2(:)'];
        end
        t=t-floor((t+pi)/2/pi)*2*pi;
        t=sort(t);
      end
      n=length(t);
      t1=t;
      t2=[t1(2:n),t1(1)];
      R=[cos(er(i)) 0 -sin(er(i)) 0; 0 cos(er(i)) 0 -sin(er(i));
          sin(er(i)) 0 cos(er(i)) 0; 0 sin(er(i)) 0 cos(er(i))];
      esi=[esi,i*ones(1,n)];
      est=[est,[t1;t2]];
      esc=[esc, [ec(1,i);ec(1,i);ec(2,i);ec(2,i)]*ones(1,n)+...
                R*[ea(i)*cos(t1); ea(i)*cos(t2)
                eb(i)*sin(t1); eb(i)*sin(t2)]];
    end
    px=[px,esc(1,:),esc(2,:)];
    py=[py,esc(3,:),esc(4,:)];
  end
  esn=length(esi);

  % Split circles
  if cn>0
    px1=[px1,cpx];
    py1=[py1,cpy];
    if ~isempty(cpi)
      th=atan2(cpy-cc(2,cpi),cpx-cc(1,cpi));
    else
      th=[];
    end
    for i=1:size(cc,2)
      if ~isempty(cpi)
        k=find(cpi==i);
      else
        k=[];
      end
      if isempty(k)
        t=linspace(-pi,pi/2,4);
      else
        t=th(k);
        t=t-floor((t+pi)/2/pi)*2*pi;
        j=find(abs(t-pi)<small);
        t(j)=-pi*ones(size(j));
        t=sort(t);
        d=[true abs(diff(t))>small];
        t=t(d);
        t1=diff([t t(1)+2*pi]);
        j=find(t1-pi/2>small&t1-pi<=small);
        if ~isempty(j)
          t2=t(j)'+t1(j)'/2;
          t=[t t2(:)'];
        end
        j=find(t1-pi>small&t1-3*pi/2<=small);
        if ~isempty(j)
          t2=t(j)'*ones(1,2)+t1(j)'*[1 2]/3;
          t=[t t2(:)'];
        end
        j=find(t1-3*pi/2>small);
        if ~isempty(j)
          t2=t(j)'*ones(1,3)+t1(j)'*[1 2 3]/4;
          t=[t t2(:)'];
        end
        t=t-floor((t+pi)/2/pi)*2*pi;
        t=sort(t);
      end
      n=length(t);
      t1=t;
      t2=[t1(2:n),t1(1)];
      csi=[csi,i*ones(1,n)];
      cst=[cst,[t1;t2]];
      csc=[csc,[cc(1,i)+cr(i)*cos(t1);cc(1,i)+cr(i)*cos(t2)
              cc(2,i)+cr(i)*sin(t1);cc(2,i)+cr(i)*sin(t2)]];
    end
    px=[px,csc(1,:),csc(2,:)];
    py=[py,csc(3,:),csc(4,:)];
  end
  csn=length(csi);

  % Split lines
  % Delete original line segments and create non-intersecting line segments
  if ~isempty(lpi)
    [lpi,i]=sort(lpi); lpx=lpx(i); lpy=lpy(i);
    n=length(lpi); del=[]; j=1; i=1;
    while i<=n
      k=find(lpi==lpi(i));
      [x,ind]=sort(lpx(k));
      if abs(x(1)-x(length(x)))<small
        y=sort(lpy(k));
        p=0;
      else
        p=1;
        y=lpy(k);
        y=y(ind);
      end
      d=[true (abs(diff(x))>small | abs(diff(y))>small)];
      x=x(d);
      y=y(d);
      l=length(x);
      if (p & lsc(1,lpi(i))-lsc(2,lpi(i))>small) | ...
         (~p & lsc(3,lpi(i))-lsc(4,lpi(i))>small)
        x=x(l:-1:1);
        y=y(l:-1:1);
      end
      i1=j+lsn;
      if gdln>0
        lsol(1:size(lsol,1),i1:i1+l)=lsol(:,lpi(i))*ones(1,l+1);
        lsor(1:size(lsor,1),i1:i1+l)=lsor(:,lpi(i))*ones(1,l+1);
      end
      lsc(1,i1)=lsc(1,lpi(i));
      lsc(3,i1)=lsc(3,lpi(i));
      lsc(1,i1+1:i1+l)=x;
      lsc(3,i1+1:i1+l)=y;
      lsc(2,i1:i1+l-1)=x;
      lsc(4,i1:i1+l-1)=y;
      lsc(2,i1+l)=lsc(2,lpi(i));
      lsc(4,i1+l)=lsc(4,lpi(i));
      lmm(:,i1:i1+l)=[min(lsc(1,i1:i1+l),lsc(2,i1:i1+l))
          max(lsc(1,i1:i1+l),lsc(2,i1:i1+l))
          min(lsc(3,i1:i1+l),lsc(4,i1:i1+l))
          max(lsc(3,i1:i1+l),lsc(4,i1:i1+l))];
      lsh(i1:i1+l)=lsh(:,lpi(i))*ones(1,l+1);
      del=[del,lpi(i)];
      i=i+length(k); j=j+l+1;
    end
    lsc(:,del)=[];
    lmm(:,del)=[];
    lsh(:,del)=[];
    if gdln>0
      lsol(:,del)=[]; lsor(:,del)=[];
    end
    lsn=size(lsc,2);
  end

  if lsn>0
    px=[px,lsc(1,:),lsc(2,:)];
    py=[py,lsc(3,:),lsc(4,:)];
    px1=[px1,lsc(1,:),lsc(2,:)];
    py1=[py1,lsc(3,:),lsc(4,:)];
  end

  % Create point arrays px,py containing all points of the decomposition
  [px,i]=sort(px);
  py=py(i);
  i=1; n=length(px); del=[];
  while i<n
    k=find(abs(px-px(i))<small);
    py(k)=sort(py(k));
    i=i+length(k);
  end

  del=find(abs(px(1:n-1)-px(2:n))<small & abs(py(1:n-1)-py(2:n))<small);
  px(del)=[];
  py(del)=[];

  if ~isempty(px1)

    [px1,i]=sort(px1);
    py1=py1(i);
    i=1; n=length(px1); del=[];
    while i<n
      k=find(abs(px1-px1(i))<small);
      py1(k)=sort(py1(k));
      i=i+length(k);
    end

    del=find(abs(px1(1:n-1)-px1(2:n))<small & abs(py1(1:n-1)-py1(2:n))<small);
    px1(del)=[];
    py1(del)=[];

  end

  if bf2
    % first turn
    px2=px1;
    py2=py1;
  end

  % For each point - determine number of incoming segments, segment types,
  % segment numbers, angles, and curvatures.

  % pn point - number of incoming segments
  % ps point - segment number
  % pa point - angles
  % pc point - curvature

  edges=lsn+csn+esn;                    % number or edges
  em=sparse(edges,edges);               % edge matrix
  cm=sparse(2*edges,2*edges);           % connectivity matrix

  for i=1:length(px);
    x=px(i); y=py(i);
    if ~isempty(lsc)
      p1=find(abs(lsc(1,:)-x)<small & abs(lsc(3,:)-y)<small);
      a1=atan2(lsc(4,p1)-y,lsc(2,p1)-x);
      p2=find(abs(lsc(2,:)-x)<small & abs(lsc(4,:)-y)<small);
      a2=atan2(lsc(3,p2)-y,lsc(1,p2)-x);
    else
      p1=[]; a1=[];
      p2=[]; a2=[];
    end
    n1=length(p1);
    n2=length(p2);
    c1=zeros(1,n1);
    c2=zeros(1,n2);
    if ~isempty(csc)
      p3=find(abs(csc(1,:)-x)<small & abs(csc(3,:)-y)<small);
      if ~isempty(p3)
        a3=cst(1,p3)+pi/2;
        a3=a3-floor((a3+pi)/2/pi)*2*pi;
        c3=1./cr(1,csi(p3));
      else
        a3=[]; c3=[];
      end
      p4=find(abs(csc(2,:)-x)<small & abs(csc(4,:)-y)<small);
      if ~isempty(p3)
        a4=cst(2,p4)-pi/2;
        a4=a4-floor((a4+pi)/2/pi)*2*pi;
        c4=-1./cr(1,csi(p4));
      else
        a4=[]; c4=[];
      end
    else
      p3=[]; a3=[]; c3=[];
      p4=[]; a4=[]; c4=[];
    end
    n3=length(p3);
    n4=length(p4);
    if ~isempty(esc)
      p5=find(abs(esc(1,:)-x)<small & abs(esc(3,:)-y)<small);
      if ~isempty(p5)
        a=ea(esi(p5)); b=eb(esi(p5)); phi=est(1,p5);
        a5=atan2(b.*cos(phi),-a.*sin(phi))+er(esi(p5));
        a5=a5-floor((a5+pi)/2/pi)*2*pi;
        c5=sqrt(a.^2.*b.^2.*ones(1,length(phi))./...
            (a.^2.*sin(phi).^2+b.^2.*cos(phi).^2).^3);
      else
        a5=[]; c5=[];
      end
      p6=find(abs(esc(2,:)-x)<small & abs(esc(4,:)-y)<small);
      if ~isempty(p5)
        a=ea(esi(p6)); b=eb(esi(p6)); phi=est(2,p6);
        a6=atan2(-b.*cos(phi),a.*sin(phi))+er(esi(p6));
        a6=a6-floor((a6+pi)/2/pi)*2*pi;
        c6=-sqrt(a.^2.*b.^2.*ones(1,length(phi))./...
            (a.^2.*sin(phi).^2+b.^2.*cos(phi).^2).^3);
      else
        a6=[]; c6=[];
      end
    else
      p5=[]; a5=[]; c5=[];
      p6=[]; a6=[]; c6=[];
    end
    n5=length(p5);
    n6=length(p6);
    m=n1+n2+n3+n4+n5+n6;
    ps=[p1,p2,p3+lsn,p4+lsn,p5+lsn+csn,p6+lsn+csn]';
    pc=[c1,c2,c3,c4,c5,c6]';
    p1=[ones(n1,1); zeros(n2,1); ones(n3,1); zeros(n4,1)
        ones(n5,1); zeros(n6,1)];
    p2=[zeros(n1,1); ones(n2,1); zeros(n3,1); ones(n4,1)
        zeros(n5,1); ones(n6,1)];
    pa=[a1,a2,a3,a4,a5,a6]';
    k=find(abs(pa+pi)<small);
    pa(k)=pi*ones(size(k));
    [pa,j]=sort(pa);                    % sort on angles
    ps=ps(j);
    pc=pc(j);
    p1=p1(j);
    p2=p2(j);
    k=1;
    while k<=m
      l=find(abs(pa-pa(k))<small);
      if length(l)>1
        [c,j]=sort(pc(l));              % sort on curvature
        ps(l)=ps(l(j));
        p1(l)=p1(l(j));
        p2(l)=p2(l(j));
      end
      k=k+length(l);
    end
    em=em+sparse(ps,[ps(2:m);ps(1)],ones(1,m),edges,edges);
    cm=cm+sparse(ps(1:m)+edges*p1,...
                 [ps(2:m)+edges*p2(2:m);ps(1)+edges*p2(1)],...
                 ones(1,m),2*edges,2*edges);
  end

  % Determine if structure is connected
  % if it is not - add help line segments to make it connected

  % Do we know that the structure is definitely connected?
  if bf2
    pem=sparse([],[],[],edges,edges);
    while any(any(pem~=em))
      pem=em;
      em=sign(em+em*em);
    end
    if edges*edges~=sum(sum(sign(em)))  % structure not connected
      i=full(max((1:edges)'*ones(1,edges).*em));
      i=sort(i);
      k=i(logical([1 sign(diff(i))]));
      n=lsn+1;
      sc=[];
      if lsn>0
        sc=lsc(1:4,:);
      end
      if csn>0
        sc(:,lsn+1:lsn+csn)=csc(1:4,1:csn);
      end
      if esn>0
        sc(:,lsn+csn+1:edges)=esc(1:4,1:esn);
      end
      for i=[k(1:length(k)-1);k(2:length(k))]
        exit=0;
        for l1=full(find(em(i(2),:)))
          for l2=full(find(em(i(1),:)))
            if abs(sc(1,l1)-sc(1,l2))>small & abs(sc(3,l1)-sc(3,l2))>small
              x1=sc(1,l1);
              y1=sc(3,l1);
              x2=sc(1,l2);
              y2=sc(3,l2);
              exit=1;
            end
            if exit==1, break, end
          end
          if exit==1, break, end
        end
        lsc(:,n:n+3)=[x1,x2,x2,x1;x2,x2,x1,x1
            y1,y1,y2,y2;y1,y2,y2,y1];
        lmm(:,n:n+3)=[min(lsc(1,n:n+3),lsc(2,n:n+3))
            max(lsc(1,n:n+3),lsc(2,n:n+3))
            min(lsc(3,n:n+3),lsc(4,n:n+3))
            max(lsc(3,n:n+3),lsc(4,n:n+3))];
        if gdln>0
          lsol(:,n:n+3)=zeros(gdln,4);
          lsor(:,n:n+3)=zeros(gdln,4);
        end
        lsh(n:n+3)=zeros(1,4);
        n=n+4;
      end
      lsn=size(lsc,2);
      bf1=1;                            % loop once more
      bf2=0;                            % its connected now
    else
      bf1=0;                            % do not loop once more
    end
  else
    bf1=0;                              % do not loop once more
  end
end

% Walk around minimal interior two dimensional cells
% Determine minimal regions
im=cm;                                  % save initial connectivity matrix

pcm=sparse([],[],[],2*edges,2*edges);
while any(any(pcm~=cm))
  pcm=cm;
  cm=sign(cm+cm*cm);
end

eq=[]; used=zeros(1,2*edges); j=1; i=1;
while ~isempty(i)
  i=find(cm(i(1),:))';
  used(i)=ones(1,length(i));
  eq(1:length(i)+1,j)=[length(i);i];
  i=find(~used);
  j=j+1;
end

nmr=j-1;
sml=zeros(1,lsn);                       % segment - minimal region on lhs
smr=zeros(1,lsn);                       % segment - minimal region on rhs

for i=1:size(eq,2)
  j=eq(2:eq(1,i)+1,i);
  k=j(find(j<=edges));
  if ~isempty(k)
    smr(k)=i*ones(1,length(k));
  end
  k=j(find(j>edges))-edges;
  if ~isempty(k)
    sml(k)=i*ones(1,length(k));
  end
end

% analyze which minimal regions are derived from original regions
l=zeros(gdn,2*edges);
l(gdli,1:lsn)=lsor;
if lsn>0
  l(gdli,edges+(1:lsn))=lsol;
end
if csn>0
  l(:,edges+lsn+(1:csn))=full(sparse(co(csi),1:csn,ones(1,csn),gdn,csn));
end
if esn>0
  l(:,edges+lsn+csn+(1:esn))=full(sparse(eo(esi),1:esn,ones(1,esn),gdn,esn));
end
k=sign(l*cm);
p=~k;
while any(any(p~=k))
  p=k;
  j=k(:,[edges+1:2*edges,1:edges]);
  k=sign((k+(j-l-l(:,[edges+1:2*edges,1:edges])>0))*cm);
end

% build boolean table accordingly
bt=sparse([],[],[],nmr,gdn);
for i=1:gdn
  j=smr(find(k(i,1:edges)));
  bt(:,i)=sparse(j,1,1,nmr,1);
  j=sml(find(k(i,edges+1:2*edges)));
  bt(:,i)=sign(bt(:,i)+sparse(j,1,1,nmr,1));
end
bt=full(bt);

% for 3 input arguments, perform boolean evaluation
if nargin==3
  % evaluate set formula
  for i=1:gdn
    eval([deblank(char(ns(:,i)')),'=bt(:,i);']); % assumes no name collision
  end
  % transform string to make it evaluate correctly in MATLAB
  sf=strrep(sf,'-','>');                % replace '-' with '>'
  sf=strrep(sf,'*','&');                % replace '*' with '&'
  sf=strrep(sf,'+','|');                % replace '+' with '|'
  bv=eval(sf,'NaN');
  if ~islogical(bv) & isnan(bv)
    bt1=NaN; dl1=NaN; dl=NaN; bt=NaN; msb=NaN; return
  end
else
  if size(bt,2)==1
    bv=bt;
  else
    bv=sign(sum(bt')');
  end
end

si=[POLY*ones(1,lsn),CIRC*ones(1,csn),ELLI*ones(1,esn)];
sc=[lsc,csc,esc];
lsh=[lsh ones(1,csn+esn)];
if csn>0
  sa=[zeros(3,lsn),[cc(:,csi);cr(1,csi)]];
else
  sa=[];
end
if esn>0
  sa(1:5,lsn+csn+1:edges)=[ec(:,esi);ea(1,esi);eb(1,esi);er(1,esi)];
end

% remove regions that evaluate to false
del=true(edges,1);
for i=find(bv)'
  j=find(sml==i|smr==i);
  del(j)=zeros(size(j));
end
si(del)=[]; sc(:,del)=[]; sml(del)=[]; smr(del)=[]; lsh(del)=[];
im=im([~del;~del],[~del;~del]);
if csn+esn>0
  sa(:,del)=[];
end
i=find(~del);
if isempty(si), dl=[]; bt=[]; msb=[]; return, end

edges=length(si);

% remove regions outside evaluated boundary
for i=find(~bv)'
  k=find(sml==i);
  if ~isempty(k)
    sml(k)=zeros(size(k));
  end
  k=find(smr==i);
  if ~isempty(k)
    smr(k)=zeros(size(k));
  end
end

ind=[sml,smr];                          % pack indices
ind=sort(ind);
ind=ind(find([1 sign(diff(ind))]));
ind(~ind)=[];
bt=bt(ind,:);                           % -- of boolean table
j=1;                                    % -- in sml and smr
for i=ind
  k=find(sml==i);
  sml(k)=j*ones(1,length(k));
  k=find(smr==i);
  smr(k)=j*ones(1,length(k));
  j=j+1;
end
nmr=size(bt,1);

dl=[si;sc;sml;smr;sa];

% if required - compute plot command sequence
if nargout>=5
  v=sparse([],[],[],1,2*edges);
  for i=1:nmr
    j=find(smr==i);
    if ~isempty(j)
      v(1,j(1))=i;
    else
      j=find(sml==i);
      if ~isempty(j)
        v(1,j(1)+edges)=i;
      end
    end
  end
  b=zeros(nmr,1);
  j=find(v);
  msb=sparse(v(j),ones(nmr,1),j,nmr,1);
  k=2;
  while any(~b)
    v=v*im;
    j=find(v);
    msb(:,k)=sparse(v(j),ones(nmr,1),j,nmr,1);
    i=find(full(msb(:,1)==msb(:,k)) & ~b);
    b(i)=k*ones(size(i));
    k=k+1;
  end
  msb=[b'-1;full(msb')];
end

if ~bf2
  [dl1,bt1]=csgdel(dl,bt,find(~lsh));
  % construct set difference for point from first and second turn

  [x,j]=sort([px1,px2]);
  y=[py1,py2];
  y=y(j);
  i=1; n=length(x); l=[];
  while i<=n
    k=find(abs(x-x(i))<small);
    yk=sort(y(k)); yn=length(yk); y(k)=yk;
    if yn==1
      l=[l,i];
    else
      ydiff=abs(yk(1:yn-1)-yk(2:yn))>small;
      if yn==2 & ydiff==1
        l=[l,i,i+1];
      elseif yn>2
        l=[l,i+find([ydiff(1),ydiff(1:yn-2)&ydiff(2:yn-1),ydiff(yn-1)])-1];
      end
    end
    i=i+length(k);
  end
  x=x(l);
  y=y(l);
  n=length(l);
  dm=size(dl,1);
  for i=1:n
    j=find(abs(dl1(2,:)-x(i))<small&abs(dl1(4,:)-y(i))<small);
    k=find(abs(dl1(3,:)-x(i))<small&abs(dl1(5,:)-y(i))<small);
    if length(j)>2
      error(interror, 'internal decsg error.');
    elseif length(j)==2
      if length(k)>0
        error(interror, 'internal decsg error.');
      else
        dl1([2 4],j(1))=dl1([3 5],j(2));
        dl1(:,j(2))=[];
      end
    elseif length(j)==1
      if length(k)~=1
        error(interror, 'internal decsg error.');
      else
        if dl1(1,j)==CIRC & dl1(1,k)==CIRC
          th1=atan2(dl1(4,k)-dl1(9,k),dl1(2,k)-dl1(8,k));
          th2=atan2(dl1(5,k)-dl1(9,k),dl1(3,k)-dl1(8,k));
          if th2<th1, th2=th2+2*pi; end
          th3=atan2(dl1(4,j)-dl1(9,j),dl1(2,j)-dl1(8,j));
          th4=atan2(dl1(5,j)-dl1(9,j),dl1(3,j)-dl1(8,j));
          if th4<th3, th4=th4+2*pi; end
          if th2-th1<pi/4 | th4-th3<pi/4
            dl1([2 4],j)=dl1([2 4],k);
            dl1(:,k)=[];
          end
        elseif dl1(1,j)==ELLI & dl1(1,k)==ELLI
          ca=cos(dl1(12,k)); sa=sin(dl1(12,k));
          xd=dl1(2,k)-dl1(8,k);
          yd=dl1(4,k)-dl1(9,k);
          x1=ca.*xd+sa.*yd;
          y1=-sa.*xd+ca.*yd;
          th1=atan2(y1./dl1(11,k),x1./dl1(10,k));
          xd=dl1(3,k)-dl1(8,k);
          yd=dl1(5,k)-dl1(9,k);
          x1=ca.*xd+sa.*yd;
          y1=-sa.*xd+ca.*yd;
          th2=atan2(y1./dl1(11,k),x1./dl1(10,k));
          if th2<th1, th2=th2+2*pi; end
          xd=dl1(2,j)-dl1(8,j);
          yd=dl1(4,j)-dl1(9,j);
          x1=ca.*xd+sa.*yd;
          y1=-sa.*xd+ca.*yd;
          th3=atan2(y1./dl1(11,j),x1./dl1(10,j));
          xd=dl1(3,j)-dl1(8,j);
          yd=dl1(5,j)-dl1(9,j);
          x1=ca.*xd+sa.*yd;
          y1=-sa.*xd+ca.*yd;
          th4=atan2(y1./dl1(11,j),x1./dl1(10,j));
          if th4<th3, th4=th4+2*pi; end
          if th2-th1<pi/4 | th4-th3<pi/4
            dl1([2 4],j)=dl1([2 4],k);
            dl1(:,k)=[];
          end
        else
          dl1([2 4],j)=dl1([2 4],k);
          dl1(:,k)=[];
        end
      end
    else
      if length(k)>2 | length(k)==1
        error(interror, 'internal decsg error.');
      elseif length(k)==2
        dl1([3 5],k(1))=dl1([2 4],k(2));
        dl1(:,k(2))=[];
      end
    end
  end
else
  dl1=dl;
  bt1=bt;
end

% scale back
dl1(2:5,:)=dl1(2:5,:)*scale;
i=find(dl1(1,:)==CIRC);
if ~isempty(i)
  dl1(8:10,i)=dl1(8:10,i)*scale;
end
i=find(dl1(1,:)==ELLI);
if ~isempty(i)
  dl1(8:11,i)=dl1(8:11,i)*scale;
end
if nargout>=3
  dl(2:5,:)=dl(2:5,:)*scale;
  i=find(dl(1,:)==CIRC);
  if ~isempty(i)
    dl(8:10,i)=dl(8:10,i)*scale;
  end
  i=find(dl(1,:)==ELLI);
  if ~isempty(i)
    dl(8:11,i)=dl(8:11,i)*scale;
  end
end

