function scores = dejong1fcn(pop)
%DEJONG1FCN Compute DeJongs first function for GA.

%   Copyright 2004 The MathWorks, Inc. 

scores = zeros(size(pop,1),1);
for i = 1:size(pop,1)
    p = pop(i,:);
    p = max(-5.12,min(5.12,p));
    
    scores(i) = sum(p.^2);
end