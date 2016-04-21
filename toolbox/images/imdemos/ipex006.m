function U = ipex006( X, t )
% A handle to this function, based on the conformal mapping
% (z + 1/z)/2, can be passed to MAKETFORM('custom',...) as
% its INVERSE_FCN argument.  Points in X inside the circle
% of radius 1/2 or outside the circle of radius 2 map to
% NaN + i*NaN.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2003/01/26 06:02:44 $

Z = complex(X(:,1),X(:,2));
W = (Z + 1./Z)/2;
q = 0.5 <= abs(Z) & abs(Z) <= 2;
W(~q) = complex(NaN,NaN);
U(:,2) = imag(W);
U(:,1) = real(W);
