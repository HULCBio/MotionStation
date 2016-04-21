function vi = interp3(varargin)
%INTERP3 3-D interpolation (table lookup).
%   VI = INTERP3(X,Y,Z,V,XI,YI,ZI) interpolates to find VI, the values
%   of the underlying 3-D function V at the points in arrays XI,YI
%   and ZI. XI,YI,ZI must be arrays of the same size or vectors.
%   Vector arguments that are not the same size, and have mixed
%   orientations (i.e. with both row and column vectors) are passed
%   through MESHGRID to create the Y1,Y2,Y3 arrays. Arrays X,Y and Z
%   specify the points at which the data V is given.  
%
%   VI = INTERP3(V,XI,YI,ZI) assumes X=1:N, Y=1:M, Z=1:P 
%        where [M,N,P]=SIZE(V).
%   VI = INTERP3(V,NTIMES) expands V by interleaving interpolates
%        between every element, working recursively for NTIMES.  
%   INTERP3(V) is the same as INTERP3(V,1).
%
%   VI = INTERP3(...,'method') specifies alternate methods.  The default
%   is linear interpolation.  Available methods are:
%
%     'nearest' - nearest neighbor interpolation
%     'linear'  - linear interpolation
%     'cubic'   - cubic interpolation
%     'spline'  - spline interpolation
%
%   VI = INTERP3(...,'method',EXTRAPVAL) specifies a method and a value for
%   VI outside of the domain created by X,Y and Z.  Thus, VI will equal
%   EXTRAPVAL for any value of XI,YI or ZI that is not spanned by X,Y and Z
%   respectively.  A method must be specified for EXTRAPVAL to be used, the
%   default method is 'linear'.
%
%   All the interpolation methods require that X,Y and Z be monotonic and
%   plaid (as if they were created using MESHGRID). X,Y, and Z can be
%   non-uniformly spaced.
%
%   For example, to generate a course approximation of FLOW and
%   interpolate over a finer mesh:
%       [x,y,z,v] = flow(10); 
%       [xi,yi,zi] = meshgrid(.1:.25:10,-3:.25:3,-3:.25:3);
%       vi = interp3(x,y,z,v,xi,yi,zi); % vi is 25-by-40-by-25
%       slice(xi,yi,zi,vi,[6 9.5],2,[-2 .2]), shading flat
%      
%   See also INTERP1, INTERP2, INTERPN, MESHGRID.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.34.4.3 $  $Date: 2004/03/02 21:47:47 $

error(nargchk(1,9,nargin)); % allowing for an ExtrapVal

bypass = 0;
uniform = 1;
if (nargin>1)
  if ischar(varargin{end}),
    narg = nargin-1;
    method = [varargin{end} '    ']; % Protect against short string.
    ExtrapVal = nan; % default ExtrapVal
    index = 1;
  elseif ( ischar(varargin{end-1}) && isnumeric(varargin{end}) )
    narg = nargin-2;
    method = [varargin{end-1} '   ']; 
    ExtrapVal = varargin{end};
    index = 2;
  else
    narg = nargin;
    method = 'linear';
    ExtrapVal = nan; % protecting default
  end
    if method(1)=='*', % Direct call bypass.
        if method(2)=='l' % linear interpolation.
            vi = linear(varargin{1:end-index},ExtrapVal);
        return

        elseif method(2)=='c' % cubic interpolation
            vi = cubic(varargin{1:end-index},ExtrapVal);
        return

        elseif method(2)=='n', % Nearest neighbor interpolation
            vi = nearest(varargin{1:end-index},ExtrapVal);
        return

        elseif method(2)=='s', % Spline
            method = 'spline'; bypass = 1;

        else
            error('MATLAB:interp3:InvalidMethod',...
                  [deblank(method),' is an invalid method.']);

        end
    elseif method(1)=='s', % Spline interpolation
        method = 'spline'; bypass = 1;
    end
else
  narg = nargin;
  method = 'linear';
  ExtrapVal = nan; % protecting default
end

if narg==1, % interp3(v), % Expand V
  [nrows,ncols,npages] = size(varargin{1});
  xi = 1:.5:ncols; yi = (1:.5:nrows)'; zi = (1:.5:npages);
  x = 1:ncols; y = 1:nrows; z = 1:npages;
  [msg,x,y,z,v,xi,yi,zi] = xyzvchk(x,y,z,varargin{1},xi,yi,zi);

elseif narg==2. % interp3(v,n), Expand V n times
  [nrows,ncols,npages] = size(varargin{1});
  ntimes = floor(varargin{2}(1));
  xi = 1:1/(2^ntimes):ncols; yi = (1:1/(2^ntimes):nrows)';
  zi = 1:1/(2^ntimes):npages;
  x = 1:ncols; y = (1:nrows); z = 1:npages;
  [msg,x,y,z,v,xi,yi,zi] = xyzvchk(x,y,z,varargin{1},xi,yi,zi);

elseif narg==4, % interp3(v,xi,yi,zi)
  [nrows,ncols,npages] = size(varargin{1});
  x = 1:ncols; y = (1:nrows); z = 1:npages;
  [msg,x,y,z,v,xi,yi,zi] = xyzvchk(x,y,z,varargin{1:4});

elseif narg==3 || narg==5 || narg==6,
  error('MATLAB:interp3:nargin','Wrong number of input arguments.');

elseif narg==7, % interp3(x,y,z,v,xi,yi,zi)
  [msg,x,y,z,v,xi,yi,zi] = xyzvchk(varargin{1:7});

end

error(msg);

%
% Check for non-equally spaced data.  If so, map (x,y) and
% (xi,yi) to matrix (row,col) coordinate system.
%
if ~bypass,
  xx = x(1,:,1).'; yy = y(:,1,1); zz = squeeze(z(1,1,:)); % columns
  dx = diff(xx); dy = diff(yy); dz = diff(zz);
  xdiff = max(abs(diff(dx))); if isempty(xdiff), xdiff = 0; end
  ydiff = max(abs(diff(dy))); if isempty(ydiff), ydiff = 0; end
  zdiff = max(abs(diff(dz))); if isempty(zdiff), zdiff = 0; end
  if (xdiff > eps*max(xx)) || (ydiff > eps*max(yy)) || (zdiff > eps*max(zz))
    if any(dx < 0), % Flip orientation of data so x is increasing.
      x = flipdim(x,2); y = flipdim(y,2); 
      z = flipdim(z,2); v = flipdim(v,2);
      xx = flipud(xx); dx = -flipud(dx);
    end
    if any(dy < 0), % Flip orientation of data so y is increasing.
      x = flipdim(x,1); y = flipdim(y,1);
      z = flipdim(z,1); v = flipdim(v,1);
      yy = flipud(yy); dy = -flipud(dy);
    end
    if any(dz < 0), % Flip orientation of data so y is increasing.
      x = flipdim(x,3); y = flipdim(y,3);
      z = flipdim(z,3); v = flipdim(v,3);
      zz = flipud(zz); dz = -flipud(dz);
    end
  
    if any(dx<=0) || any(dy<=0) || any(dz<=0), 
      error('MATLAB:interp3:XYorZNotMonotonic',...
            'X, Y, and Z must be monotonic vectors or arrays produced by MESHGRID.');
    end
  
    % Bypass mapping code for cubic
    if method(1)~='c', 
      % Determine the nearest location of xi in x
      [xxi,j] = sort(xi(:));
      [dum,i] = sort([xx;xxi]);
      si(i) = (1:length(i));
      si = (si(length(xx)+1:end)-(1:length(xxi)))';
      si(j) = si;
    
      % Map values in xi to index offset (si) via linear interpolation
      si(si<1) = 1;
      si(si>length(xx)-1) = length(xx)-1;
      si = si + (xi(:)-xx(si))./(xx(si+1)-xx(si));
     
      % Determine the nearest location of yi in y
      [yyi,j] = sort(yi(:));
      [dum,i] = sort([yy;yyi]);
      ti(i) = (1:length(i));
      ti = (ti(length(yy)+1:end)-(1:length(yyi)))';
      ti(j) = ti;
    
      % Map values in yi to index offset (ti) via linear interpolation
      ti(ti<1) = 1;
      ti(ti>length(yy)-1) = length(yy)-1;
      ti = ti + (yi(:)-yy(ti))./(yy(ti+1)-yy(ti));
    
      % Determine the nearest location of zi in z
      [zzi,j] = sort(zi(:));
      [dum,i] = sort([zz;zzi]);
      wi(i) = (1:length(i));
      wi = (wi(length(zz)+1:end)-(1:length(zzi)))';
      wi(j) = wi;
    
      % Map values in zi to index offset (wi) via linear interpolation
      wi(wi<1) = 1;
      wi(wi>length(zz)-1) = length(zz)-1;
      wi = wi + (zi(:)-zz(wi))./(zz(wi+1)-zz(wi));
    
      [x,y,z] = meshgrid(ones(class(x)):size(x,2),...
                         ones(superiorfloat(y,z)):size(y,1),1:size(z,3));
      xi(:) = si; yi(:) = ti; zi(:) = wi;
    else
      uniform = 0;
    end
  end
end

% Now do the interpolation based on method.
method = [lower(method),'   ']; % Protect against short string

if method(1)=='l', % linear interpolation.
  vi = linear(x,y,z,v,xi,yi,zi,ExtrapVal);

elseif method(1)=='c', % cubic interpolation
  if uniform
    vi = cubic(x,y,z,v,xi,yi,zi,ExtrapVal);
  else
    d = find(xi < min(x(:)) | xi > max(x(:)) | ...
             yi < min(y(:)) | yi > max(y(:)) | ...
             zi < min(z(:)) | zi > max(z(:)));
    vi = spline3(x,y,z,v,xi,yi,zi);
    vi(d) = NaN;
  end

elseif method(1)=='n', % Nearest neighbor interpolation
  vi = nearest(x,y,z,v,xi,yi,zi,ExtrapVal);

elseif method(1)=='s', % Spline interpolation
  vi = spline3(x,y,z,v,xi,yi,zi,ExtrapVal);

else
  error('MATLAB:interp3:InvalidMethod',...
        [deblank(method),' is an invalid method.']);

end

%------------------------------------------------------
function F = linear(arg1,arg2,arg3,arg4,arg5,arg6,arg7,ExtrapVal)
%LINEAR 3-D trilinear data interpolation.
%   VI = LINEAR(X,Y,Z,V,XI,YI,ZI) uses trilinear interpolation
%   to find VI, the values of the underlying 3-D function in V
%   at the points in arrays XI, YI and ZI.  Arrays X, Y, and
%   Z specify the points at which the data V is given.  X, Y,
%   and Z can also be vectors specifying the abscissae for the
%   matrix V as for MESHGRID. In both cases, X, Y, and Z must be
%   equally spaced and monotonic.
%
%   Values of NaN are returned in VI for values of XI, YI and ZI
%   that are outside of the range of X, Y, and Z.
%
%   If XI, YI, and ZI are vectors, LINEAR returns vector VI
%   containing the interpolated values at the corresponding
%   points (XI,YI,ZI).
%
%   VI = LINEAR(V,XI,YI,ZI) assumes X = 1:N, Y = 1:M, and
%   Z = 1:P where [M,N,P] = SIZE(V).
%
%   VI = LINEAR(V,NTIMES) returns the matrix VI expanded by
%   interleaving bilinear interpolates between every element,
%   working recursively for NTIMES.  LINEAR(V) is the same
%   as LINEAR(V,1).
%
%   This function needs about 4 times SIZE(XI) memory to be
%   available.
%
%   See also INTERP3.

% find extrapolation value
switch nargin
    case 1
        ExtrapVal = arg1;
    case 2
        ExtrapVal = arg2;
    case 3
        ExtrapVal = arg3;
    case 4
        ExtrapVal = arg4;
    case 5
        ExtrapVal = arg5;
    case 6
        ExtrapVal = arg6;
    case 7
        ExtrapVal = arg7;
    % case 8 is implicit
end

if nargin==2, % linear(v), Expand V
  if ndims(arg1)~=3 
    error('MATLAB:interp3:linear:Vnot3Dnarg2', 'V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1);
  [s,t,w] = meshgrid(1:.5:ncols,1:.5:nrows,1:.5:npages);

elseif nargin==3, % linear(v,n), Expand V n times
  if ndims(arg1)~=3 
    error('MATLAB:interp3:linear:Vnot3Dnarg2', 'V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1);
  ntimes = floor(arg2); delta = 1/(2^ntimes);
  [s,t,w] = meshgrid(1:delta:ncols,1:delta:nrows,1:delta:npages);

elseif nargin==4 || nargin==6 || nargin==7
  error('MATLAB:interp3:linear:ninput','Wrong number of input arguments.');

elseif nargin==5, % linear(v,s,t,w), No X, Y or Z specified.
  if ndims(arg1)~=3 
    error('MATLAB:interp3:linear:Vnot3Dnarg5','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1);
  s = arg2; t = arg3; w = arg4;

elseif nargin==8, % linear(x,y,z,v,s,t,w), X, Y and Z specified.
  if ndims(arg4)~=3 
    error('MATLAB:interp3:linear:Vnot3Dnarg8','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg4);
  mx = numel(arg1); my = numel(arg2); mz = numel(arg3);
  if ~isequal([my mx mz],size(arg4)) && ...
     ~isequal(size(arg1),size(arg2),size(arg3),size(arg4))
    error('MATLAB:interp3:linear:XYZLengthMismatchV',...
          'The lengths of the X,Y,Z vectors must match V.');
  end
  s = 1 + (arg5-arg1(1))/(arg1(mx)-arg1(1))*(ncols-1);
  t = 1 + (arg6-arg2(1))/(arg2(my)-arg2(1))*(nrows-1);
  w = 1 + (arg7-arg3(1))/(arg3(mz)-arg3(1))*(npages-1);
  
end

if any([nrows ncols npages]<[2 2 2]), 
  error('MATLAB:interp3:linear:Vsize','V must be at least 2-by-2-by-2.');
end
if ~isequal(size(s),size(t),size(w))
  error('MATLAB:interp3:linear:XIYIZISizeMismatch',...
        'XI, YI and ZI must be the same size.');
end

% Check for out of range values of s and set to 1
sout = find((s<1)|(s>ncols));
if length(sout)>0, s(sout) = ones(size(sout)); end

% Check for out of range values of t and set to 1
tout = find((t<1)|(t>nrows));
if length(tout)>0, t(tout) = ones(size(tout)); end

% Check for out of range values of w and set to 1
wout = find((w<1)|(w>npages));
if length(wout)>0, w(wout) = ones(size(wout)); end

% Matrix element indexing
nw = nrows*ncols;
ndx = floor(t)+floor(s-1)*nrows+floor(w-1)*nw;

% Compute intepolation parameters, check for boundary value.
if isempty(s), d = s; else d = find(s==ncols); end
s(:) = (s - floor(s));
if length(d)>0, s(d) = s(d)+1; ndx(d) = ndx(d)-nrows; end

% Compute intepolation parameters, check for boundary value.
if isempty(t), d = t; else d = find(t==nrows); end
t(:) = (t - floor(t));
if length(d)>0, t(d) = t(d)+1; ndx(d) = ndx(d)-1; end

% Compute intepolation parameters, check for boundary value.
if isempty(w), d = w; else d = find(w==npages); end
w(:) = (w - floor(w));
if length(d)>0, w(d) = w(d)+1; ndx(d) = ndx(d)-nw; end

d = []; % Reclaim memory

% Now interpolate.
if nargin==8,
  F =  (( arg4(ndx).*(1-t) + arg4(ndx+1).*t ).*(1-s) + ...
        ( arg4(ndx+nrows).*(1-t) + arg4(ndx+(nrows+1)).*t ).*s).*(1-w) +...
       (( arg4(ndx+nw).*(1-t) + arg4(ndx+1+nw).*t ).*(1-s) + ...
        ( arg4(ndx+nrows+nw).*(1-t) + arg4(ndx+(nrows+1+nw)).*t ).*s).*w;
else
  F =  (( arg1(ndx).*(1-t) + arg1(ndx+1).*t ).*(1-s) + ...
        ( arg1(ndx+nrows).*(1-t) + arg1(ndx+(nrows+1)).*t ).*s).*(1-w) +...
       (( arg1(ndx+nw).*(1-t) + arg1(ndx+1+nw).*t ).*(1-s) + ...
        ( arg1(ndx+nrows+nw).*(1-t) + arg1(ndx+(nrows+1+nw)).*t ).*s).*w;
end

% Now set out of range values to NaN.
if length(sout)>0, F(sout) = ExtrapVal; end
if length(tout)>0, F(tout) = ExtrapVal; end
if length(wout)>0, F(wout) = ExtrapVal; end


%------------------------------------------------------
function F = cubic(arg1,arg2,arg3,arg4,arg5,arg6,arg7,ExtrapVal)
%CUBIC 3-D Tricubic data interpolation.
%   CUBIC(...) is the same as LINEAR(....) except that it uses
%   cubic interpolation.
%   
%   See also INTERP3.

%   Based on "Cubic Convolution Interpolation for Digital Image
%   Processing", Robert G. Keys, IEEE Trans. on Acoustics, Speech, and
%   Signal Processing, Vol. 29, No. 6, Dec. 1981, pp. 1153-1160.

% find extrapolation value
switch nargin
    case 1
        ExtrapVal = arg1;
    case 2
        ExtrapVal = arg2;
    case 3
        ExtrapVal = arg3;
    case 4
        ExtrapVal = arg4;
    case 5
        ExtrapVal = arg5;
    case 6
        ExtrapVal = arg6;
    case 7
        ExtrapVal = arg7;
    % case 8 is implicit
end

if nargin==2, % cubic(v), Expand V
  if ndims(arg1)~=3 
    error('MATLAB:interp3:cubic:Vnot3D','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1); 
  [s,t,w] = meshgrid(1:.5:ncols,1:.5:nrows,1:.5:npages);

elseif nargin==3, % cubic(v,n), Expand V n times
  if ndims(arg1)~=3 
    error('MATLAB:interp3:cubic:Vnot3Dnarg3','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1);
  ntimes = floor(arg2); delta = 1/(2^ntimes);
  [s,t,w] = meshgrid(1:delta:ncols,1:delta:nrows,1:delta:npages);

elseif nargin==4 || nargin==6 || nargin==7
  error('MATLAB:interp3:cubic:WrongInputNum','Wrong number of input arguments.');

elseif nargin==5, % cubic(v,s,t,w), No X, Y or Z specified.
  if ndims(arg1)~=3 
    error('MATLAB:interp3:cubic:Vnot3Dnarg5','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1);
  s = arg2; t = arg3; w = arg4;

elseif nargin==8, % cubic(x,y,z,v,s,t,w), X, Y and Z specified.
  if ndims(arg4)~=3 
    error('MATLAB:interp3:cubic:Vnot3Dnarg8','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg4);
  mx = numel(arg1); my = numel(arg2); mz = numel(arg3);
  if ~isequal([my mx mz],size(arg4)) && ...
     ~isequal(size(arg1),size(arg2),size(arg3),size(arg4)),
    error('MATLAB:interp3:cubic:XYZLengthMismatchV',...
          'The lengths of the X,Y,Z vectors must match V.');
  end
  s = 1 + (arg5-arg1(1))/(arg1(mx)-arg1(1))*(ncols-1);
  t = 1 + (arg6-arg2(1))/(arg2(my)-arg2(1))*(nrows-1);
  w = 1 + (arg7-arg3(1))/(arg3(mz)-arg3(1))*(npages-1);
end

if any([nrows ncols npages]<[3 3 3]),
  error('MATLAB:interp3:cubic:Vsize','V must be at least 3-by-3-by-3.');
end
if ~isequal(size(s),size(t),size(w)),
  error('MATLAB:interp3:cubic:XIYIZISizeMismatch',...
        'XI, YI and ZI must be the same size.');
end

% Check for out of range values of s and set to 1
sout = find((s<1)|(s>ncols));
if length(sout)>0, s(sout) = ones(size(sout)); end

% Check for out of range values of t and set to 1
tout = find((t<1)|(t>nrows));
if length(tout)>0, t(tout) = ones(size(tout)); end

% Check for out of range values of w and set to 1
wout = find((w<1)|(w>npages));
if length(wout)>0, w(wout) = ones(size(wout)); end

% Matrix element indexing
nw = (nrows+2)*(ncols+2);
ndx = floor(t)+floor(s-1)*(nrows+2)+floor(w-1)*nw;

% Compute intepolation parameters, check for boundary value.
if isempty(s), d = s; else d = find(s==ncols); end
s(:) = (s - floor(s));
if length(d)>0, s(d) = s(d)+1; ndx(d) = ndx(d)-nrows-2; end

% Compute intepolation parameters, check for boundary value.
if isempty(t), d = t; else d = find(t==nrows); end
t(:) = (t - floor(t));
if length(d)>0, t(d) = t(d)+1; ndx(d) = ndx(d)-1; end

% Compute intepolation parameters, check for boundary value.
if isempty(w), d = w; else d = find(w==npages); end
w(:) = (w - floor(w));
if length(d)>0, w(d) = w(d)+1; ndx(d) = ndx(d)-nw; end

d = []; % Reclaim memory

% Expand v so interpolation is valid at the boundaries.
if nargin==8,
  vv = zeros(size(arg4)+2);
  vv(2:nrows+1,2:ncols+1,2:npages+1) = arg4;
else
  vv = zeros(size(arg1)+2);
  vv(2:nrows+1,2:ncols+1,2:npages+1) = arg1;
end
vv(1,:,:)        = 3*vv(2,:,:)       -3*vv(3,:,:)     +vv(4,:,:); % Y edges
vv(nrows+2,:,:)  = 3*vv(nrows+1,:,:) -3*vv(nrows,:,:) +vv(nrows-1,:,:);
vv(:,1,:)        = 3*vv(:,2,:)       -3*vv(:,3,:)     +vv(:,4,:); % X edges
vv(:,ncols+2,:)  = 3*vv(:,ncols+1,:) -3*vv(:,ncols,:) +vv(:,ncols-1,:);
vv(:,:,1)        = 3*vv(:,:,2)       -3*vv(:,:,3)     +vv(:,:,4); % Z edges
vv(:,:,npages+2) = 3*vv(:,:,npages+1)-3*vv(:,:,npages)+vv(:,:,npages-1);
nrows = nrows+2; ncols = ncols+2; npages = npages+2;

% Now interpolate using computationally efficient algorithm.
F = zeros(size(s));
for iw = 0:3,
  ww = localevaluate(w,iw);
  for is = 0:3,
    ss = localevaluate(s,is);
    for it = 0:3,
      tt = localevaluate(t,it);
      F(:) = F + vv(ndx+(it+is*nrows+iw*nw)).*ss.*tt.*ww;
    end
  end
end
F(:) = F/8;

% Now set out of range values to NaN.
if length(sout)>0, F(sout) = ExtrapVal; end
if length(tout)>0, F(tout) = ExtrapVal; end
if length(wout)>0, F(wout) = ExtrapVal; end

function X = localevaluate(x,iter)
switch iter
 case 0
  X = ((2-x).*x-1).*x;
 case 1
  X = (3*x-5).*x.*x+2;
 case 2
  X = ((4-3*x).*x+1).*x;
 case 3
  X = (x-1).*x.*x;
end

%------------------------------------------------------
function F = nearest(arg1,arg2,arg3,arg4,arg5,arg6,arg7,ExtrapVal)
%NEAREST 3-D Nearest neighbor interpolation.
%   NEAREST(...) is the same as LINEAR(...) except that it uses
%   nearest neighbor interpolation.
%
%   See also INTERP3.

% find extrapolation value
switch nargin
    case 1
        ExtrapVal = arg1;
    case 2
        ExtrapVal = arg2;
    case 3
        ExtrapVal = arg3;
    case 4
        ExtrapVal = arg4;
    case 5
        ExtrapVal = arg5;
    case 6
        ExtrapVal = arg6;
    case 7
        ExtrapVal = arg7;
    % case 8 is implicit
end


if nargin==2, % nearest(v), Expand V
  if ndims(arg1)~=3 
    error('MATLAB:interp3:nearest:Vnot3D','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1); 
  [s,t,w] = meshgrid(1:.5:ncols,1:.5:nrows,1:.5:npages);

elseif nargin==3, % nearest(v,n), Expand V n times
  if ndims(arg1)~=3 
    error('MATLAB:interp3:nearest:Vnot3Dnarg3','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1);
  ntimes = floor(arg2); delta = 1/(2^ntimes);
  [s,t,w] = meshgrid(1:delta:ncols,1:delta:nrows,1:delta:npages);

elseif nargin==4 || nargin==6 || nargin==7
  error('MATLAB:interp3:nearest:WrongInputNum','Wrong number of input arguments.');

elseif nargin==5, % nearest(v,s,t,w), No X, Y or Z specified.
  if ndims(arg1)~=3 
    error('MATLAB:interp3:nearest:Vnot3Dnarg5','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg1);
  s = arg2; t = arg3; w = arg4;

elseif nargin==8, % nearest(x,y,z,v,s,t,w), X, Y and Z specified.
  if ndims(arg4)~=3 
    error('MATLAB:interp3:nearest:Vnot3Dnarg8','V must be a 3-D array.'); 
  end
  [nrows,ncols,npages] = size(arg4);
  mx = numel(arg1); my = numel(arg2); mz = numel(arg3);
  if ~isequal([my mx mz],size(arg4)) && ...
     ~isequal(size(arg1),size(arg2),size(arg3),size(arg4)),
    error('MATLAB:interp3:nearest:XYZLengthMismatchV',...
          'The lengths of the X,Y,Z vectors must match V.');
  end
  if all([nrows,ncols,npages]>[1 1 1]),
    s = 1 + (arg5-arg1(1))/(arg1(mx)-arg1(1))*(ncols-1);
    t = 1 + (arg6-arg2(1))/(arg2(my)-arg2(1))*(nrows-1);
    w = 1 + (arg7-arg3(1))/(arg3(mz)-arg3(1))*(npages-1);
  else
    s = 1 + (arg5-arg1(1));
    t = 1 + (arg6-arg2(1));
    w = 1 + (arg7-arg3(1));
  end
end

if ~isequal(size(s),size(t),size(w)),
  error('MATLAB:interp3:nearest:XIYIZISizeMismatch',...
        'XI, YI and ZI must be the same size.');
end

% Check for out of range values of s and set to 1
sout = find((s<.5)|(s>=ncols+.5));
if length(sout)>0, s(sout) = ones(size(sout)); end

% Check for out of range values of t and set to 1
tout = find((t<.5)|(t>=nrows+.5));
if length(tout)>0, t(tout) = ones(size(tout)); end

% Check for out of range values of w and set to 1
wout = find((w<.5)|(w>=npages+.5));
if length(wout)>0, w(wout) = ones(size(wout)); end

% 
% Now interpolate
ndx = round(t) + (round(s)-1)*nrows + (round(w)-1)*(nrows*ncols);
if nargin==8,
  F = arg4(ndx);
else
  F = arg1(ndx);
end

% Now set out of range values to NaN.
if length(sout)>0, F(sout) = ExtrapVal; end
if length(tout)>0, F(tout) = ExtrapVal; end
if length(wout)>0, F(wout) = ExtrapVal; end

%----------------------------------------------------------
function F = spline3(varargin)
%3-D spline interpolation

% Determine abscissa vectors 
varargin{1} = varargin{1}(1,:,1);
varargin{2} = varargin{2}(:,1,1).';
varargin{3} = reshape(varargin{3}(1,1,:),1,size(varargin{3},3));

%
% Check for plaid data.
%
xi = varargin{5}; yi = varargin{6}; zi = varargin{7};
xxi = xi(1,:,1); yyi = yi(:,1,1); zzi = zi(1,1,:);
if ~automesh(xi,yi,zi) | ...
   (size(xi,2)>1 && ~isequal(repmat(xxi,[size(xi,1),1,size(xi,3)]),xi)) || ...
   (size(yi,1)>1 && ~isequal(repmat(yyi,[1,size(yi,2),size(yi,3)]),yi)) || ...
   (size(zi,3)>1 && ~isequal(repmat(zzi,[size(zi,1),size(zi,2),1]),zi)),
  F = splncore(varargin([2 1 3]),varargin{4},varargin([6 5 7]));
else
  F = splncore(varargin([2 1 3]),varargin{4},{yyi(:).' xxi zzi(:).'},'gridded');
end
