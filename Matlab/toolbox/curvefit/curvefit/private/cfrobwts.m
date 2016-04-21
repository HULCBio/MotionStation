function w = cfrobwts(robtype,r)
%CFROBWTS Compute bisquare weights for robust curve fitting.
%   W = CFROBWTS(R) computes a weight vector W as a function of a
%   scaled residual vector R.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:43:22 $

if isequal(robtype,'lar')
   w = 1 ./ max(eps,abs(r));
else
   w = (abs(r)<1) .* (1 - r.^2).^2;
   if all(w(:)==0)
      w(:) = 1;
   end
end

