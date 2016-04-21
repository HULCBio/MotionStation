function f = ps_example(x)
%PS_EXAMPLE objective function for pattern search.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2004/01/16 16:53:18 $


for i = 1:size(x,1)
    if  x(i,1) < -5
        f(i) = (x(i,1)+5)^2 + abs(x(i,2));
    elseif x(i,1) < -3
        f(i) = -2*sin(x(i,1)) + abs(x(i,2));
    elseif x(i,1) < 0
        f(i) = 0.5*x(i,1) + 2 + abs(x(i,2));
    elseif x(i,1) >= 0
        f(i) = .3*sqrt(x(i,1)) + 5/2 +abs(x(i,2));
    end
end




