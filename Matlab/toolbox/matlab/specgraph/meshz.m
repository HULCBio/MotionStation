function h=meshz(varargin)
%MESHZ  3-D mesh with curtain.
%   MESHZ(...) is the same as MESH(...) except that a "curtain" or
%   reference plane is drawn beneath.
%
%   This routine only works for surfaces defined on a rectangular
%   grid.  The matrices X and Y define the axis limits only.
%
%   See also MESH, MESHC.

%   Clay M. Thompson 3-20-91
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.13.4.1 $  $Date: 2002/10/24 02:14:08 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

error(nargchk(1,4,nargs));

if nargs==1,  % Generate x,y matrices for surface z.
  x = args{1};
  if min(size(x)) == 1 | isstr(x)
      error('Invalid input argument.')
  end
  z = args{1};
  [m,n] = size(z);
  [x,y] = meshgrid(0:n-1,0:m-1);
  c = z;

elseif nargs==2,
  x = args{1};  y = args{2};
  if isstr(x) | isstr(y)
    error('Invalid input argument.')
  end
  if min(size(x)) == 1 | min(size(y)) == 1
      error('Invalid input argument.')
  end
  z = x; c = y;
  [m,n] = size(z);
  [x,y] = meshgrid(0:n-1,0:m-1);
  if ~isequal(size(c),size(z))
      error('Invalid input argument.')
  end

elseif nargs>=3,
  [x,y,z] = deal(args{1:3});
  if isstr(x) | isstr(y) | isstr(z)
      error('Invalid input argument.')
  end
  [m,n] = size(z);
  [mx,nx] = size(x);
  [my,ny] = size(y);
  if m == 1 | n == 1
      error('Invalid input argument.')
  end

  if min(mx,nx)==1 & max(mx,nx)==n
      %we have a vector of the right size
      x=x(:)';  %make sure we have a row vector
      x=x(ones(m,1),:);
  elseif ~isequal(size(x),size(z))
      xmin = min(min(x));
      xmax = max(max(x));
      
      x=[xmin:(xmax-xmin)/(n-1):xmax];
      x=x(ones(m,1),:);
  end
  
  
  if min([my,ny])==1 & max([my,ny])==m
      %we have a vector of the right size: matrixize it
      y=y(:); %make sure we have a column vector
      y = y(:,ones(1, n));
      
  elseif ~isequal(size(y),size(z))
      % Create x and y vectors that are the same size as z.
      ymin = min(min(y));
      ymax = max(max(y));
      
      y=[ymin:(ymax-ymin)/(n-1):ymax]';
      y = y(:,ones(1, n));
      
      
  end
  
  if nargs > 3
      c = args{4};
  else
      c = z;
  end
  
  if ~isequal(size(c),size(z))
      error('Invalid input argument.')
  end
  if ~isequal(size(z),size(x)) | ~isequal(size(z),size(y))
      error('Invalid input argument.')
  end
end

if isstr(c)
      error('Invalid input argument.')
end

% Define position of curtains
zref = min(min(z(isfinite(z))));

% Define new x,y,z and then call mesh.
zrow = zref*ones(1,n); zcol = zref*ones(m,1);
d = [1 1]; mm = [m m]; nn = [n n];
newZ = [zref zref   zrow   zref   zref;
        zref zref   z(1,:) zref   zref;
        zcol z(:,1) z      z(:,n) zcol;
        zref zref   z(m,:) zref   zref;
        zref zref   zrow   zref   zref];
        
newX = [x(d,d),x(d,:),x(d,nn);x(:,d),x,x(:,nn);x(mm,d),x(mm,:),x(mm,nn)];
newY = [y(d,d),y(d,:),y(d,nn);y(:,d),y,y(:,nn);y(mm,d),y(mm,:),y(mm,nn)];

%if (nargs==1) | (nargs==3),
%  hm=mesh(newX,newY,newZ);
%else
%  if size(c)==size(z),  % Expand size of color matrix
    cref = (max(max(c(isfinite(c))))+min(min(c(isfinite(c)))))/2;
    crow = cref*ones(2,n); ccol = cref*ones(m,2); cref = cref*ones(2,2);
    c = [cref,crow,cref;ccol,c,ccol;cref,crow,cref];
%    c = [c(d,d),c(d,:),c(d,nn);c(:,d),c,c(:,nn);c(mm,d),c(mm,:),c(mm,nn)];
%  end
  if isempty(cax)
      cax = gca;
  end
  hm=mesh(cax,newX,newY,newZ,c);
  set(hm,'tag','meshz');
%end
if nargout > 0
    h = hm;
end

