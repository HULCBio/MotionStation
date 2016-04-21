function w = griddata3(x,y,z,v,xi,yi,zi,method,options)
%GRIDDATA3 Data gridding and hyper-surface fitting for 3-dimensional data.
%   W = GRIDDATA3(X,Y,Z,V,XI,YI,ZI) fits a hyper-surface of the form
%   W = F(X,Y,Z) to the data in the (usually) nonuniformly-spaced vectors
%   (X,Y,Z,V).  GRIDDATA3 interpolates this hyper-surface at the points
%   specified by (XI,YI,ZI) to produce W.
%
%   (XI,YI,ZI) is usually a uniform grid (as produced by MESHGRID) and is
%   where GRIDDATA3 gets its name. 
%
%   [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD) where METHOD is one of
%       'linear'    - Tessellation-based linear interpolation (default)
%       'nearest'   - Nearest neighbor interpolation
%
%   defines the type of surface fit to the data. 
%   All the methods are based on a Delaunay triangulation of the data.
%   If METHOD is [], then the default 'linear' method will be used.
%
%   [...] = GRIDDATA3(X,Y,Z,V,XI,YI,ZI,METHOD,OPTIONS) specifies a cell 
%   array of strings OPTIONS to be used as options in Qhull via DELAUNAYN.
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%
%   Class support for inputs X,Y,Z,V,XI,YI,ZI: double
%
%   See also GRIDDATA, GRIDDATAN, QHULL, DELAUNAYN, MESHGRID.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.4 $  $Date: 2004/03/02 21:47:42 $

if nargin < 7
  error('MATLAB:griddata3:NotEnoughInputs', 'Needs at least 7 inputs.');
end
if ( nargin < 8 || isempty(method) ), method = 'linear'; end
if ~isequal(method(1),'l') && ~isequal(method(1),'n')
  error('MATLAB:griddata3:InvalidMethod',...
        'METHOD must be one of ''linear'', or ''nearest''.');
end
if nargin == 8
    if ~iscellstr(options)
        error('MATLAB:griddata3:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');           
    end
    opt = options;
else
    opt = [];
end

x = x(:); y=y(:); z=z(:); v = v(:);
m = length(x);
if m < 3, error('MATLAB:griddata3:NotEnoughPts','Not enough points.'); end
if m ~= length(y) || m ~= length(z) || m ~= length(v)
  error('MATLAB:griddata3:InputSizeMismatch',...
        'X,Y,Z,V must all have the same size.');
end

X = [x y z];

% Sort (x,y,z) so duplicate points can be averaged before passing to delaunay

[X, ind] = sortrows(X);
v = v(ind);
ind = all(diff(X)'==0);
if any(ind)
  warning('MATLAB:griddata3:DuplicateDataPoints',['Duplicate x data points ' ...
            'detected: using average of the v values.']);
  ind = [0 ind];
  ind1 = diff(ind);
  fs = find(ind1==1);
  fe = find(ind1==-1);
  if fs(end) == length(ind1) % add an extra term if the last one start at end
     fe = [fe fs(end)+1];
  end
  
  for i = 1 : length(fs)
    % averaging v values
    v(fe(i)) = mean(v(fs(i):fe(i)));
  end
  X = X(~ind(2:end),:);
  v = v(~ind(2:end));
end

switch lower(method(1)),
  case 'l'
    w = linear(X,v,[xi(:) yi(:) zi(:)],opt);
  case 'n'
    w = nearest(X,v,[xi(:) yi(:) zi(:)],opt);
  otherwise
    error('MATLAB:griddata3:UnknownMethod', 'Unknown method.');
end
w = reshape(w,size(xi));


%------------------------------------------------------------
function zi = linear(x,y,xi,opt)
%LINEAR Triangle-based linear interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
if isempty(opt)
  tri = delaunayn(x);
else
  tri = delaunayn(x,opt);
end
if isempty(tri),
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  zi = NaN*zeros(size(xi));
  return
end

% Find the nearest triangle (t)
[t,p] = tsearchn(x,tri,xi);

m1 = size(xi,1);
onev = ones(1,size(x,2)+1);
zi = NaN*zeros(m1,1);

for i = 1:m1
  if ~isnan(t(i))
     zi(i) = p(i,:)*y(tri(t(i),:));
  end
end

%------------------------------------------------------------
function zi = nearest(x,y,xi,opt)
%NEAREST Triangle-based nearest neightbor interpolation

%   Reference: David F. Watson, "Contouring: A guide
%   to the analysis and display of spacial data", Pergamon, 1994.

% Triangularize the data
if isempty(opt)
  tri = delaunayn(x);
else
  tri = delaunayn(x,opt);
end
if isempty(tri), 
  warning('MATLAB:griddata3:CannotTriangulate','Data cannot be triangulated.');
  zi = repmat(NaN,size(xi));
  return
end

% Find the nearest vertex
k = dsearchn(x,tri,xi);

zi = k;
d = find(isfinite(k));
zi(d) = y(k(d));

%----------------------------------------------------------

