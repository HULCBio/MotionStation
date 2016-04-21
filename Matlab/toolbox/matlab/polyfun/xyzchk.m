function [msg,x,y,z,out5,out6] = xyzchk(arg1,arg2,arg3,arg4,arg5)
%XYZCHK Check arguments to 3-D data routines.
%   [MSG,X,Y,Z,C] = XYZCHK(Z), or
%   [MSG,X,Y,Z,C] = XYZCHK(Z,C), or
%   [MSG,X,Y,Z,C] = XYZCHK(X,Y,Z), or
%   [MSG,X,Y,Z,C] = XYZCHK(X,Y,Z,C), or
%   [MSG,X,Y,Z,XI,YI] = XYZCHK(X,Y,Z,XI,YI) checks the input aguments
%   and returns either an error message in MSG or valid X,Y,Z (and
%   XI,YI) data.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.17.4.2 $  $Date: 2004/01/24 09:22:50 $

error(nargchk(1,6,nargin));

msg.message = 0;
msg.identifier = 0;
msg = msg(zeros(0,1));

out5 = []; out6 = [];
if nargin==1, % xyzchk(z)
  z = arg1;
  if ischar(z),
    msg = makeMsg('nonNumericInput', 'Input arguments must be numeric.');
    return
  end
  [m,n] = size(z);
  [x,y] = meshgrid(1:n,1:m);
  out5 = z; % Default color matrix
  return

elseif nargin==2, % xyzchk(z,c)
  z = arg1; c = arg2;
  [m,n] = size(z);
  [x,y] = meshgrid(1:n,1:m);
  if ~isequal(size(z),size(c)),
    msg = makeMsg('CAndZSizeMismatch', 'Matrix C must be the same size as Z.');
    return
  end
  out5 = c;
  return

elseif nargin>=3, % xyzchk(x,y,z,...)
  x = arg1; y = arg2; z = arg3;
  [m,n] = size(z);
  if ~isvector(z), % z is a matrix
    % Convert x,y to row and column matrices if necessary.
    if isvector(x) && isvector(y),
      [x,y] = meshgrid(x,y);
      if size(x,2)~=n && size(y,1)~=m,
        msg = makeMsg('lengthXAndYDoNotMatchSizeZ', 'The lengths of X and Y must match the size of Z.');
        return
      elseif size(x,2)~=n,
        msg = makeMsg('lengthXDoesNotMatchNumColumnsZ', 'The length of X must match the number of columns of Z.');
        return
      elseif size(y,1)~=m,
        msg = makeMsg('lengthYDoesNotMatchNumRowsZ', 'The length of Y must match the number of rows of Z.');
        return
      end
    elseif isvector(x) || isvector(y),
      msg = makeMsg('XAndYShapeMismatch', 'X and Y must both be vectors or both be matrices.');
      return
    else
      if ~isequal(size(x),size(y),size(z)),
        msg = makeMsg('XYAndZSizeMismatch', 'Matrices X and Y must be the same size as Z.');
        return
      end
    end
  else % z is a vector
    if ~isvector(x) || ~isvector(y),
      msg = makeMsg('XYAndZShapeMismatch', 'When Z is a vector, X and Y must also be vectors.');
      return
    elseif (length(x)~=length(z) || length(y)~=length(z)) && ...
           ~((length(x)==size(z,2)) && (length(y)==size(z,1)))
      msg = makeMsg('XYAndZLengthMismatch', sprintf(['X and Y must be same length as Z or the lengths \n', ...
                          'of X and Y must match the size of Z.']));
      return
    end
  end
end

if nargin==4, % xyzchk(x,y,z,c)
  c = arg4;
  if ~isequal(size(z),size(c))
    msg = makeMsg('CAndZSizeMismatch', 'Matrix C must be the same size as Z.');
    return
  end
  out5 = c;
  return
end

if nargin==5, % xyzchk(x,y,z,xi,yi)
  xi = arg4; yi = arg5;

  if automesh(xi,yi),
    [xi,yi] = meshgrid(xi,yi);
  elseif ~isequal(size(xi),size(yi)),
    msg = makeMsg('XIAndYISizeMismatch', 'XI and YI must be the same size or vectors of different orientations.');
  end
  out5 = xi; out6 = yi;
end

function tf = isvector(x)
%ISVECTOR True if x has only one non-singleton dimension.
tf = (length(x) == numel(x));

function msg = makeMsg(identifier, message)
msg.message = message;
msg.identifier = ['MATLAB:xyzchk:' identifier];

