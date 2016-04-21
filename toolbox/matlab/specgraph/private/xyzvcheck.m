function [msg,nx,ny,nz] = xyzvcheck(x,y,z,data)
%XYZVCHECK  Check arguments to 3D scalar data routines.
%   [MSG,X,Y,Z] = XYZCHK(X,Y,Z,V) checks the input aguments
%   and returns either an error message in MSG or valid X,Y,Z.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:37:48 $

msg = '';
nx = x;
ny = y;
nz = z;

sz = size(data);

if ndims(data)~=3
  msg='V must be a 3D array.';
  return
end
if min(sz)<2
  msg = 'V must be size 2x2x2 or greater.'; 
  return
end

nonempty = ~[isempty(x) isempty(y) isempty(z)];
if any(nonempty) & ~all(nonempty)
  msg = 'X,Y,Z must all be empty or all non-empty.';
  return;
end

if ~isempty(nx) & ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg='The size of X must match the size of V or the number of columns of V.';
    return
  else
    nx = repmat(nx',[sz(1) 1 sz(3)]);
  end
end

if ~isempty(ny) & ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg='The size of Y must match the size of V or the number of rows of V.';
    return
  else
    ny = repmat(ny,[1 sz(2) sz(3)]);
  end
end

if ~isempty(nz) & ~isequal(size(nz), sz)
  nz = nz(:);
  if length(nz)~=sz(3)
    msg='The size of Z must match the size of V or the number of pages of V.';
    return
  else
    nz = repmat(reshape(nz,[1 1 length(nz)]),[sz(1) sz(2) 1]);
  end
end

