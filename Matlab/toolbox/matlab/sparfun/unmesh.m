function [A,xy] = unmesh(M)
%UNMESH Convert a list of edges to a graph or matrix.
%   [A,XY] = UNMESH(E) returns the Laplacian matrix A and mesh vertex
%   coordinate matrix XY for the M-by-4 edge matrix E.  Each row of
%   the edge matrix must contain the coordinates [x1 y1 x2 y2] of the
%   edge endpoints. The Laplacian matrix A is a symmetric adjacency
%   matrix with -1 for edges and degrees on the diagonal. Each row of
%   XY is a coordinate [x y] of a mesh point.
%
%   See also GPLOT.

%   John Gilbert, 1990.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/05/01 20:43:22 $

% Discretize x and y with "range" steps, 
% equating coordinates that round to the same step.


range = round(eps^(-1/3));

[m,k] = size(M);
if k ~= 4, 
  error ('MATLAB:unmesh:WrongRowForm','Mesh must have rows of the form [x1 y1 x2 y2].')
end

x = [ M(:,1) ; M(:,3) ];
y = [ M(:,2) ; M(:,4) ];
xmax = max(x);
ymax = max(y);
xmin = min(x);
ymin = min(y);
xscale = (range-1) / (xmax-xmin);
yscale = (range-1) / (ymax-ymin);

% The "name" of each (x,y) coordinate (i.e. vertex)
% is scaledx + scaledy/range .

xnames = round( (x - repmat(xmin*xscale,2*m,1)) );
ynames = round( (y - repmat(ymin*yscale,2*m,1)) );
xynames = xnames+1 + ynames/range;

% vnames = the sorted list of vertex names, duplicates removed.

vnames = sort(xynames);
f = find(diff( [-Inf; vnames] ));
vnames = vnames(f);
n = length(vnames);
disp ([int2str(n) ' vertices:']);

% x and y are the rounded coordinates, un-scaled.

x = (floor(vnames) / xscale) + xmin;
y = ((vnames-floor(vnames)) / yscale) * range + ymin;
xy = [x y];

% Fill in the edge list one vertex at a time.

ij = zeros(2*m,1);
for v = 1:n,
    if ~rem(v,10),
        disp ([int2str(v) '/' int2str(n)]);
    end;
    f = find( xynames == vnames(v) );
    ij(f) = repmat(v,length(f),1);
end;
if rem(n,10), disp ([int2str(n) '/' int2str(n)]); end;

% Fill in the edges of A.

i = ij(1:m);
j = ij(m+1:2*m);
A = sparse(i,j,1,n,n);

% Make A the symmetric Laplacian.

A = -spones(A+A');
A = A - diag(sum(A));


