function area = sparea(x,y,dim)
%SPAREA  Signed polygon area.
%   SPAREA(X,Y) returns the area of the polygon specified by
%   the vertices in the vectors X and Y.  If X and Y are matrices
%   of the same size, then POLYAREA returns the area of
%   polygons defined by the columns X and Y.  If X and Y are
%   arrays, POLYAREA returns the area of the polygons in the
%   first non-singleton dimension of X and Y.  Areas are positive
%   for clockwise polygons and negative for counter-clockwise
%   polygons.
%
%   The polygon edges must not intersect.  If they do, POLYAREA
%   returns the absolute value of the difference between the clockwise
%   encircled areas and the counterclockwise encircled areas.
%
%   POLYAREA(X,Y,DIM) returns the area of the polygons specified
%   by the vertices in the dimension DIM.


%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $ $Date: 2003/08/01 18:19:40 $


if nargin==1, error('Not enough inputs.'); end

if ~isequal(size(x),size(y)), error('X and Y must be the same size.'); end

if nargin==2,
  [x,nshifts] = shiftdim(x);
  y = shiftdim(y);
elseif nargin==3,
  perm = [dim:max(length(size(x)),dim) 1:dim-1];
  x = permute(x,perm);
  y = permute(y,perm);
end

siz = size(x);
if ~isempty(x),
  area = reshape(sum( (x([2:siz(1) 1],:) - x(:,:)).* ...
                 (y([2:siz(1) 1],:) + y(:,:)))/2,[1 siz(2:end)]);
else
  area = sum(x); % SUM produces the right value for all empty cases
end

if nargin==2,
  area = shiftdim(area,-nshifts);
elseif nargin==3,
  area = ipermute(area,perm);
end
