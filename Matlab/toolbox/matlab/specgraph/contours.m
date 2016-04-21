function [CS,msg]=contours(varargin)
%CONTOURS Contouring over non-rectangular surface.
%   CONTOURS calculates the contour matrix C for use by CONTOUR,
%       CONTOUR3, or CONTOURF to draw the actual contour plot.
%   CONTOURS(...) is the same as CONTOURC except CONTOURS(X,Y,Z,...)
%       allows the specification of parametric surfaces (as for SURF).
%   C = CONTOURS(Z) computes the contour matrix for a contour plot
%      of matrix Z treating the values in Z as heights above a plane.
%   C = CONTOURS(X,Y,Z), where X and Y are vectors, specifies the X- 
%      and Y-axes limits for Z. X and Y can also be matrices of the
%      same size as Z, in which case they specify a surface as for SURF. 
%   CONTOURS(Z,N) and CONTOURS(X,Y,Z,N) compute N contour lines, 
%      overriding the default automatic value.
%   CONTOURS(Z,V) and CONTOURS(X,Y,Z,V) compute LENGTH(V) contour 
%      lines at the values specified in vector V.
%   
%   The contour matrix C is a two row matrix of contour lines. Each
%   contiguous drawing segment contains the value of the contour, 
%   the number of (x,y) drawing pairs, and the pairs themselves.  
%   The segments are appended end-to-end as
% 
%       C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%            pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
% 
%   See also CONTOUR, CONTOUR3 and CONTOURF.
 
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $  $Date: 2004/04/10 23:31:43 $

% Author: R. Pawlowicz (IOS) rich@ios.bc.ca
%         12/12/94

error(nargchk(1,4,nargin));
msg = [];
if (nargin <=2),
  numarg_for_call = 1:nargin;
  if ~isa(varargin{1}, 'double')
    varargin{1} = double(varargin{1});
  end
  zz=varargin{1};
else
  numarg_for_call= 3:nargin;
  if ~isa(varargin{1}, 'double')
    varargin{1} = double(varargin{1});
  end
  if ~isa(varargin{2}, 'double')
    varargin{2} = double(varargin{2});
  end
  if ~isa(varargin{3}, 'double')
    varargin{3} = double(varargin{3});
  end
  zz=varargin{3};
  msg = xyzchk(varargin{1:3});
  if ~isempty(msg), CS = []; return, end
end; 

CS=contourc(varargin{numarg_for_call});
[Ny,Nx]=size(zz);
 
% Find data values and check curve orientation.
 
ii= ones(1,size(CS,2))~=0;
k=1;
while (k < size(CS,2)),
  nl=CS(2,k);
  
  % Now this is a little bit of magic needed to make the filled contours
  % work. Essentially I draw the *closed* contours so that the "high" side is
  % always on the right. To test this, I take the cross product of the
  % first vector with a vector to a corner point and test the sign
  % against the elevation change. There are several special cases:
  % (1) If the contour line goes through a point (which happen when -Infs
  % are around), and (2) when the contour level equals the level on the high
  % side (this always seems to happen in 'simple test' cases!). We take
  % care of (1) by choosing other points, and we take care of (2) by adding
  % eps to the data before comparing with the contour data.
  
  if ( CS(:,k+1)==CS(:,k+nl) & nl>1 ),
    lev=CS(1,k);

    % Use manhattan distance to find a line segment that is the
    % farthest away from being on the grid (skewd is an integer
    % when a line segment is aligned with the grid so we look
    % for the "least integer-like" distance).
    skewd=abs(diff(CS(1,k+1:k+nl)))+abs(diff(CS(2,k+1:k+nl)));
    skewd=abs(skewd-round(skewd));
    [md,t]=max(skewd);
    if isempty(t), t = 1; end
	
    x1=CS(1,k+t); y1=CS(2,k+t);
    x2=CS(1,k+t+1); y2=CS(2,k+t+1);
    vx1=x2-x1; vy1=y2-y1;
    cpx=round(x1); cpy=round(y1);
    if veryclose([cpx cpy],[x1 y1])
      cpx=round(x2); cpy=round(y2);
      if veryclose([cpx cpy],[x2 y2]),
         % If we've made it to here, the contour line is along a
         % grid line.  It is also possible we're on a ridge or valley.  
         % If so, filled ridge or valley contours will be drawn 
         % with the same color on both sides.
         if [cpx cpy]~=round([x1 y1]), % Diagonal contour
           cpx=round(x1);
         else % edge contour
           cpx=round(x1)+round(y2-y1);
           cpy=round(y1)-round(x2-x1);
           % Make sure the values stay in bounds (stay at least one pixel
           % away from the edge since filled contours put NaNs there).
           if (cpx < 2) | (cpx > size(zz,2)-1)
             cpx=round(x1)-round(y2-y1);
           end
           if (cpy < 2) | (cpy > size(zz,1)-1)
             cpy=round(y1)+round(x2-x1);
           end
         end;
       end;
    end;
    vx2=cpx-x1; vy2=cpy-y1;
    if ( sign(zz(cpy,cpx)-lev+eps) == sign(vx1*vy2-vx2*vy1)  ),
      CS(:,k+(1:nl))=fliplr(CS(:,k+(1:nl)));
    end; 
  end;
  ii(k)=0;
  k=k+1+nl;
end;

% Data from integer coords to data coords. There are 3 cases
% (1) Matrix X/Y
% (2) Vector X/Y
% (3) no X/Y. (do nothing);

if nargin>2,
  x = varargin{1};  
  y = varargin{2};
end

if isempty(CS)
  % Nothing to do
elseif (nargin > 2) & (min(size(varargin{1})) > 1),
 
  X=fixrounding(CS(1,ii)');   
  Y=fixrounding(CS(2,ii)');

  cX=ceil(X);    fX=floor(X);
  cY=ceil(Y);    fY=floor(Y);


  Ibl=cY+(fX-1)*Ny;    Itl=fY+(fX-1)*Ny;
  Itr=fY+(cX-1)*Ny;    Ibr=cY+(cX-1)*Ny;
 
  dy=cY-Y; dx=X-fX;
 
  CS(1,ii) = [ x(Ibl).*(1-dx).*(1-dy) + x(Itl).* (1-dx).*dy + ...
               x(Itr).*dx.*dy + x(Ibr).*dx.*(1-dy) ]';
  CS(2,ii) = [ y(Ibl).*(1-dx).*(1-dy) + y(Itl).*(1-dx).*dy + ...
               y(Itr).*dx.*dy + y(Ibr).*dx.*(1-dy) ]';

elseif (nargin>2 & min(size(x))==1 ),
  X=fixrounding(CS(1,ii));  
  Y=fixrounding(CS(2,ii));
  
  cX=ceil(X); fX=floor(X);
  cY=ceil(Y); fY=floor(Y);

  dy=cY-Y;    dx=X-fX;

  if (size(x,2)==1), 
    CS(1,ii)=[x(fX)'.*(1-dx)+x(cX)'.*dx];
  else
    CS(1,ii)=[x(fX).*(1-dx)+x(cX).*dx];
  end;
 
  if (size(y,2)==1), 
    CS(2,ii)=[y(fY)'.*dy+y(cY)'.*(1-dy)]; 
  else
    CS(2,ii)=[y(fY).*dy+y(cY).*(1-dy)]; 
  end;
 
end;

function x = fixrounding(x)
% correct x for rounding errors
rounded = round(x); 
nearinds = eachveryclose(x,rounded);
x(nearinds) = rounded(nearinds);

function tf = veryclose(a,b)
% Return true if the two inputs are very close to each other
tf = all(eachveryclose(a,b));

function tf = eachveryclose(a,b)
% Return true where the two inputs are very close to each other
tf = abs(a-b) <= sqrt(eps)*max(abs(a),abs(b));

