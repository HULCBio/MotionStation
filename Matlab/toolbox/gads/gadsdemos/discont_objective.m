function f = discont_objective(z)
%Objective function used by comparegadsoptim

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1 $Date: 2004/01/14 15:35:04 $


for i = 1:length(z)
    x = z(i);
    if  x < -5
        y = sin(x+rand*0.4)+1.5;
    elseif x < -3
        y = -2*x+rand*0.4;
    elseif x < 0
        y = -sin(x+rand*0.4);
    elseif x > 5
        y = sin(-x+rand*0.4) +1.5;
    elseif x > 3
        y = 2*x+rand*0.4;
    elseif x >= 0
        y = -sin(x);
    end
    f(i) = y;
end

f = f';
