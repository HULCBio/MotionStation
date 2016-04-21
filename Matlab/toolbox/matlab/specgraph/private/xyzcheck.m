function [msg,nx,ny] = xyzcheck(x,y,z)
%XYZCHECK  Check arguments to 2.5D data routines.
%   [MSG,X,Y] = XYZCHK(X,Y,Z) checks the input aguments
%   and returns either an error message in MSG or valid X,Y.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:37:46 $

msg = '';
nx = x;
ny = y;

sz = size(z);

if ndims(z)~=2
  msg='Z must be a 2D array.';
  return
end
if min(sz)<2
  msg = 'Z must be size 2x2 or greater.'; 
  return
end

nonempty = ~[isempty(x) isempty(y)];
if any(nonempty) & ~all(nonempty)
  msg = 'X,Y must both be empty or both non-empty.';
  return;
end

if ~isempty(nx) & ~isequal(size(nx), sz)
  nx = nx(:);
  if length(nx)~=sz(2)
    msg='The size of X must match the size of Z or the number of columns of Z.';
    return
  else
    nx = repmat(nx',[sz(1) 1]);
  end
end

if ~isempty(ny) & ~isequal(size(ny), sz)
  ny = ny(:);
  if length(ny)~=sz(1)
    msg='The size of Y must match the size of Z or the number of rows of Z.';
    return
  else
    ny = repmat(ny,[1 sz(2)]);
  end
end


