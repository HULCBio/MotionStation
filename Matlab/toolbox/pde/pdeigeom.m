function [x,y]=pdeigeom(dl,bs,s)
%PDEIGEOM Interpret PDE geometry.
%
%       The first input argument of PDEIGEOM should specify the geometry
%       description. If the first argument is a text, that text is
%       used as a function name to be called with the remaining arguments.
%       That function must then be a Geometry M-file and return the
%       same results as PDEIGEOM. If the first argument is not a text,
%       is it assumed to be a Decomposed Geometry Matrix.
%       See either DECSG or PDEGEOM for details.
%
%       NE=PDEIGEOM(DL) is the number of boundary segments
%
%       D=PDEIGEOM(DL,BS) is a matrix with one column for each boundary segment
%       specified in BS.
%       Row 1 contains the start parameter value.
%       Row 2 contains the end parameter value.
%       Row 3 contains the label of the left hand region.
%       Row 4 contains the label of the right hand region.
%
%       [X,Y]=PDEIGEOM(DL,BS,S) produces coordinates of boundary points.
%       BS specifies the boundary segments and S the corresponding
%       parameter values. BS may be a scalar.
%
%       See also INITMESH, REFINEMESH, PDEGEOM, PDEARCL

%       A. Nordmark 11-07-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:19 $

if nargin<1 || nargin>3,
  error('PDE:pdeigeom:nargin', 'pdeigeom should have 1-3 input arguments.');
end

if ischar(dl),
  if nargin==1,
    x=feval(dl);
  elseif nargin==2,
    x=feval(dl,bs);
  else                                  % nargin==3
    [x,y]=feval(dl,bs,s);
  end
  return
end

nbs=size(dl,2);

if nargin==1,
  x=nbs;                                % number of boundary segments
  return
end

d=[zeros(1,nbs);
    ones(1,nbs);
    dl(6:7,:)];

bs1=bs(:)';

if find(bs1<1 | bs1>nbs),
  error('PDE:pdeigeom:InvalidBs', 'Non-existent boundary segment number.')
end

if nargin==2,
  x=d(:,bs1);
  return
end

x=zeros(size(s));
y=zeros(size(s));
[m,n]=size(bs);
if m==1 && n==1,
  bs=bs*ones(size(s));                  % expand bs
elseif m~=size(s,1) || n~=size(s,2),
  error('PDE:pdeigeom:SizeBs', 'bs must be scalar or of same size as s.');
end

if ~isempty(s),
  for k=1:nbs,
    ii=find(bs==k);
    if ~isempty(ii),
      x0=dl(2,k);
      x1=dl(3,k);
      y0=dl(4,k);
      y1=dl(5,k);
      if dl(1,k)==1                     % Circle fragment
        xc=dl(8,k);
        yc=dl(9,k);
        r=dl(10,k);
        a0=atan2(y0-yc,x0-xc);
        a1=atan2(y1-yc,x1-xc);
        if a0>a1,
          a0=a0-2*pi;
        end
        theta=(a1-a0)*(s(ii)-d(1,k))/(d(2,k)-d(1,k))+a0;
        x(ii)=r*cos(theta)+xc;
        y(ii)=r*sin(theta)+yc;
      elseif dl(1,k)==2                 % Line fragment
        x(ii)=(x1-x0)*(s(ii)-d(1,k))/(d(2,k)-d(1,k))+x0;
        y(ii)=(y1-y0)*(s(ii)-d(1,k))/(d(2,k)-d(1,k))+y0;
      elseif dl(1,k)==4                 % Ellipse fragment
        xc=dl(8,k);
        yc=dl(9,k);
        r1=dl(10,k);
        r2=dl(11,k);
        phi=dl(12,k);
        t=[r1*cos(phi) -r2*sin(phi); r1*sin(phi) r2*cos(phi)];
        rr0=t\[x0-xc;y0-yc];
        a0=atan2(rr0(2),rr0(1));
        rr1=t\[x1-xc;y1-yc];
        a1=atan2(rr1(2),rr1(1));
        if a0>a1,
          a0=a0-2*pi;
        end
        % s should be proportional to arc length
        % Numerical integration and linear interpolation is used
        nth=100;                % The number of points in the interpolation
        th=linspace(a0,a1,nth);
        rr=t*[cos(th);sin(th)];
        theta=pdearcl(th,rr,s(ii),d(1,k),d(2,k));
        rr=t*[cos(theta);sin(theta)];
        x(ii)=rr(1,:)+xc;
        y(ii)=rr(2,:)+yc;
      else
        error('PDE:pdeigeom:InvalidSegType', 'Unknown segment type.');
      end
    end
  end
end

