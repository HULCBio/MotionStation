function scores = dejong2fcn(pop)
%DEJONG2FCN Compute DeJongs second function.
%This function is also known as Rosenbrock's function

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/04 03:24:13 $

scores = zeros(size(pop,1),1);
for i = 1:size(pop,1)
    p = pop(i,:);
    scores(i) = 100 * (p(1)^2 - p(2)) ^2 + (1 - p(1))^2;
end
