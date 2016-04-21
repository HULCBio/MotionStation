function [msg,x,y,z,v,xi,yi,zi] = xyzvchk(arg1,arg2,arg3,arg4,arg5,arg6,arg7)
%XYZVCHK Check arguments to 3-D volume data routines.
%   [MSG,X,Y,Z,V,XI,YI,ZI] = XYZVCHK(X,Y,Z,V,XI,YI,ZI), checks the
%   input aguments and returns either an error message in MSG or
%   valid X,Y,Z,V (and XI,YI,ZI) data.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/01/24 09:22:51 $

error(nargchk(7,7,nargin));

x = [];
y = [];
z = [];
v = [];
xi = [];
yi = [];
zi = [];

msg.message = '';
msg.identifier = '';
msg = msg(zeros(0,1));

if nargin>4, % xyzchk(x,y,z,v,...)
  x = arg1; y = arg2; z = arg3; v = arg4;
  if ndims(v)~=3, msg = makeMsg('VNot3D', 'V must be a 3-D array.'); return, end
  siz = size(v);
  if ~isvector(v), % v is not a vector or scalar
    % Convert x,y,z to row, column, and page matrices if necessary.
    if isvector(x) && isvector(y) && isvector(z),
      [x,y,z] = meshgrid(x,y,z);
      if ~isequal([size(y,1) size(x,2) size(z,3)],siz),
        msg = makeMsg('lengthXYAndZDoNotMatchSizeV', 'The lengths of X,Y and Z must match the size of V.');
        return
      end
    elseif isvector(x) || isvector(y) || isvector(z),
      msg = makeMsg('XYAndZShapeMismatch', 'X,Y and Z must all be vectors or all be arrays.');
      return
    else
      if ~isequal(size(x),size(y),size(z),siz),
        msg = makeMsg('XYZAndVSizeMismatch', 'Matrices X,Y and Z must be the same size as V.');
        return
      end
    end
  elseif isvector(v) % v is a vector
    if ~isvector(x) || ~isvector(y) || ~isvector(z),
      msg = makeMsg('XYZAndVShapeMismatch', 'X,Y and Z must be vectors when V is.');
      return
    elseif ~isequal(length(x),length(y),length(z),length(v)),
      msg = makeMsg('XYZAndVLengthMismatch', 'X,Y and Z must be the same length as V.');
      return
    end
  end
end

if nargin==7, % xyzchk(x,y,z,v,xi,yi,zi)
  xi = arg5; yi = arg6; zi = arg7;

  % If xi,yi and zi don't all have the same orientation, then
  % build xi,yi,zi arrays.
  if automesh(xi,yi,zi)
    [xi,yi,zi] = meshgrid(xi,yi,zi);
  elseif ~isequal(size(xi),size(yi),size(zi)),
    msg = makeMsg('XIYIAndZISizeMismatch', 'XI,YI, and ZI must be the same size or vectors of different orientations.');
  end
end

function tf = isvector(x)
%ISVECTOR True if x has only one non-singleton dimension.
tf = (sum(size(x)~=1) <= 1);

function msg = makeMsg(identifier, message)
msg.message = message;
msg.identifier = ['MATLAB:xyzvchk:' identifier];

