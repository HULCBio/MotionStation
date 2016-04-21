function yi = griddatan(x,y,xi,method,options)
%GRIDDATAN Data gridding and hyper-surface fitting (dimension >= 2).
%   YI = GRIDDATAN(X,Y,XI) fits a hyper-surface of the form Y = F(X) to the
%   data in the (usually) nonuniformly-spaced vectors (X, Y).  GRIDDATAN
%   interpolates this hyper-surface at the points specified by XI to
%   produce YI. XI can be nonuniform.
%
%   X is of dimension m-by-n, representing m points in n-D space. Y is of
%   dimension m-by-1, representing m values of the hyper-surface F(X). XI
%   is a vector of size p-by-n, representing p points in the n-D space
%   whose surface value is to be fitted. YI is a vector of length p
%   approximating the values F(XI).  The hyper-surface always goes through
%   the data points (X,Y).  XI is usually a uniform grid (as produced by
%   MESHGRID).
%
%   YI = GRIDDATAN(X,Y,XI,METHOD) where METHOD is one of
%       'linear'    - Tessellation-based linear interpolation (default)
%       'nearest'   - Nearest neighbor interpolation
%   defines the type of surface fit to the data. 
%   All the methods are based on a Delaunay tessellation of the data.
%   If METHOD is [], then the default 'linear' method will be used.
%
%   YI = GRIDDATAN(X,Y,XI,METHOD,OPTIONS) specifies a cell array of strings 
%   OPTIONS to be used as options in Qhull via DELAUNAYN. 
%   If OPTIONS is [], the default options will be used.
%   If OPTIONS is {''}, no options will be used, not even the default.
%
%   See also GRIDDATA, GRIDDATA3, QHULL, DELAUNAYN, MESHGRID.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $  $Date: 2004/01/16 20:04:57 $

if nargin < 3
    error('MATLAB:griddatan:NotEnoughInputs','Needs at least 3 inputs.');
end
[m,n] = size(x);
if m < n+1, error('MATLAB:griddatan:NotEnoughPts','Not enough points'); end
if m ~= size(y,1)
  error('MATLAB:griddatan:InputSizeMismatch',...
        'Y must have the same number of points as X.');
end

if any(isinf(x(:)) | isnan(x(:)))
  error('MATLAB:griddatan:CannotTessellateInfOrNaN',...
        'Data containing Inf or NaN cannot be tessellated.');
end

if ( nargin < 4 || isempty(method) ), method = 'linear'; end
if ~ischar(method), 
  error('MATLAB:griddatan:InvalidMethod',...
        'METHOD must be one of ''linear'',''cubic'',''nearest'', or ''v4''.');
end

if nargin == 5
    if ~iscellstr(options)
        error('MATLAB:griddatan:OptsNotStringCell',...
              'OPTIONS should be cell array of strings.');           
    end
    opt = options;
else
    opt = [];
end

% Sort x and y so duplicate points can be averaged before passing to delaunay

[x, ind] = sortrows(x);
y = y(ind);
ind = all(diff(x)'==0);
if any(ind)
  warning('MATLAB:griddatan:DuplicateDataPoints',['Duplicate x data points ' ...
            'detected: using average of the y values.']);
  ind = [0 ind];
  ind1 = diff(ind);
  fs = find(ind1==1);
  fe = find(ind1==-1);
  if fs(end) == length(ind1) % add an extra term if the last one start at end
     fe = [fe fs(end)+1];
  end
  
  for i = 1 : length(fs)
    % averaging y values
    y(fe(i)) = mean(y(fs(i):fe(i)));
  end
  x = x(~[ind(2:end) 0],:);
  y = y(~[ind(2:end) 0]);
end

switch lower(method),
  case 'linear'
    yi = linear(x,y,xi,opt);
  case 'nearest'
    yi = nearest(x,y,xi,opt);
  otherwise
    error('MATLAB:griddatan:UnknownMethod', 'Unknown method.');
end

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
  warning('MATLAB:griddatan:CannotTriangulate','Data cannot be triangulated.');
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
%    zi(i) = y(tri(t(i),:),:)'*([onev; x(tri(t(i),:),:)']\[1; xi(i,:)']);
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
  warning('MATLAB:griddatan:CannotTriangulate','Data cannot be triangulated.');
  zi = repmat(NaN,size(xi));
  return
end

% Find the nearest vertex
k = dsearchn(x,tri,xi);

zi = k;
d = find(isfinite(k));
zi(d) = y(k(d));

%----------------------------------------------------------
