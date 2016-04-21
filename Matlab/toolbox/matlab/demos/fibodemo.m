function nterms = fibodemo(dtype)
%FIBODEMO Used by SINGLEMATH demo.
% Calculate number of terms in Fibonacci sequence.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.4.1 $  $Date: 2004/03/22 23:53:55 $

fcurrent = ones(dtype);
fnext = fcurrent;
goldenMean = (ones(dtype)+sqrt(5))/2;
tol = eps(goldenMean);
nterms = 2;
while abs(fnext/fcurrent - goldenMean) >= tol
    nterms = nterms + 1;
    temp  = fnext;
    fnext = fnext + fcurrent;
    fcurrent = temp;
end
