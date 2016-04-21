function [x, xmask] = elimone(x, xmask, h, w, n, maxbin)
%ELIMONE Eliminates a variable.(Utility function used by DFILDEMO).
%   Eliminates a variable and places it in the discrete set of 
%   variables that are not free to vary.    

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2004/02/07 19:13:01 $

xold = x; 
Fbest = Inf; 
Fix = xmask(1);
ceilflag = 0;
for i = xmask 
    x = xold; 
    x(i)  = ceil(x(i));
    ht=abs(freqz(x(1:n), x(n+1:2*n), w));
    F = max(abs(h-ht));
    if F < Fbest  & abs(roots(x(n+1:2*n))) < 1 
        Fix = i;
        Fbest = F; 
        ceilflag =1; 
    end

    x = xold; 
    x(i)  = floor(x(i));
    ht=abs(freqz(x(1:n), x(n+1:2*n), w));
    F = max(abs(h-ht));
    if F < Fbest & abs(roots(x(n+1:2*n))) < 1 
        Fix = i;
        Fbest = F; 
        ceilflag = 0; 
    end
end 
x = xold; 
if ceilflag 
    x(Fix) = ceil(x(Fix)); 
else
    x(Fix) = floor(x(Fix)); 
end
xmask(find(xmask == Fix)) = [];
