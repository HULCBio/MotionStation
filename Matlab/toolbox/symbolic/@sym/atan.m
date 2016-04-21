function Z = atan(Y,X)
%ATAN   Symbolic inverse tangent.
%       With two arguments, ATAN(Y,X) is the symbolic form of ATAN2(Y,X).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:22:04 $

if nargin < 2
   Z = maple('map','atan',Y);
else
   Y = sym(Y);
   X = sym(X);
   if ~isequal(size(X),size(Y))
      error('symbolic:sym:atan:errmsg1','Two arguments must be same size.')
   end
   Z = Y;
   for k = 1:length(Y(:))
      Z(k) = maple('atan',Y(k),X(k));
   end
end
