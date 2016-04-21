function multiobjective
%Working with more than one objective function.
% 	This example has two objective functions.
% 	We evaluate each for each individual and then score all dominated
% 	individuals lower than all nondominated individuals. One individual
% 	dominates another if it scores lower on every objective function.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2004/01/16 16:52:49 $

options = gaoptimset;
options.PopulationSize = 200;
options.StallGenLimit = inf;
options.PlotFcns = {@gaplotscores,@gaplotbestf,@gaplotstopping,@multiobjectivedisplay};

ga(@fitness,1,options)
  
function scores = fitness(pop)
% find scores for each seperate objective function
multiScores(:,1) = pop .^ 2;
multiScores(:,2) = (pop - 2) .^ 2;

% determine which individuals are dominated by other individuals
dominated = findDominated(multiScores);

% all non dominated individuals score the same.
f = find(dominated == false);
scores = 1/mean(mean(multiScores(f,:))) + dominated;

% which rows are dominated by some other row?
% A row X is dominated if there exists another row Y
% in which every element of Y is less than the corresponding
% element in X. Y dominates X by outperforming it on every
% objective function. Remember, we are minimizing here, so less is better.
function dominated = findDominated(multiScores)
[rows,cols] = size(multiScores);
dominated = false(rows,1);
for i = 1:rows
    if(0 == dominated(i))
        for j = 1:rows
            if(0 == dominated(j))
                shadow = true;
                for k = 1:cols
                    if(multiScores(i,k) >= multiScores(j,k))
                        shadow = false;
                        break;
                    end
                end
                dominated(j) = shadow;
            end
        end
    end
end

function state = multiobjectivedisplay(options,state,flag)
% find the best
pop = state.Population;
scatter(pop(:,1).^2,(pop(:,1)-2).^2,'rx')
hold on
f = find(state.Score == min(state.Score));
scatter(pop(f,1).^2,(pop(f,1)-2).^2,'bo');
hold off
