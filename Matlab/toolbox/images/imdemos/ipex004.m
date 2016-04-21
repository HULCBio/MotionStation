function U = ipex004( X, t )
% A handle to this function, based on the conformal mapping
% (z + 1/z)/2, can be passed to MAKETFORM('custom',...) as
% its INVERSE_FCN argument.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2003/01/26 06:02:42 $

Z = complex(X(:,1),X(:,2));
R = abs(Z);
W = (Z + 1./Z)/2;
U(:,2) = imag(W);
U(:,1) = real(W);
