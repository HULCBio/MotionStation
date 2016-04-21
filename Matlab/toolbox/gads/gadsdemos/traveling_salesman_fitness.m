function scores = traveling_salesman_fitness(x,distances)
%   A custom fitness function. 
%   SCORES = TRAVELING_SALESMAN_FITNESS(X,DISTANCES) Calculate the fitness 
%   of an individual. The fitness is the total distance traveled for an
%   ordered set of cities in X. DISTANCE(A,B) is the distance from the city
%   A to the city B.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/26 13:26:13 $

scores = zeros(size(x,1),1);
for j = 1:size(x,1)
    % here is where the special knowledge that the population is a cell
    % array is used. Normally, this would be pop(j,:);
    p = x{j}; 
    f = distances(p(end),p(1));
    for i = 2:length(p)
        f = f + distances(p(i-1),p(i));
    end
    scores(j) = f;
end
