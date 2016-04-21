function parents = selectionremainder(expectations,nParents,options)
%SELECTIONREMAINDER Remainder stochastic sampling without replacement.
%   PARENTS = SELECTIONREMAINDER(EXPECTATIONS,NPARENTS,OPTIONS) chooses
%   PARENTS using the EXPECTATIONS and number of parents NPARENTS. 
%
%   Example:
%   Create an options structure using SELECTIONREMAINDER as the selection
%   function
%     options = gaoptimset('SelectionFcn', @selectionremainder);

%   The desired number of offspring for a member may have a fractional 
%   component like 2.3, but the actual number of offspring any member can have
%   must be an integer. We deal with this in two phases. First, each member is 
%   entered in the parents list as many times as his integer component requires
%   (2 in the case above). In the second step the rest of the parents are 
%   chosen stochastically, with a probability of selection equal to the 
%   remaining fractional portion of their desired offspring (0.3 in the above 
%   case). Returns an array of indices into the population array. Each member 
%   will be represented as many time as his score determines.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2004/01/16 16:51:26 $

parents = zeros(1,nParents);

% First we assign the integral parts deterministically.
% Load up the sure parents and leave the fractional remainder in
% newScores.
next = 1;
for i = 1:length(expectations)
    while(expectations(i) >=1)
        parents(next) = i;
        next = next + 1;
        expectations(i) = expectations(i) - 1;
    end
end

% if all newScores were integers, we are done!
if(next > nParents)
    return
end

% scale the remaining scores to be probabilities...
intervals = cumsum(expectations);
intervals = intervals / intervals(end);

% take the rest by chance.
for k = next:nParents
    r = rand;
    for i = 1:length(expectations)
        if(r <= intervals(i))
            parents(k) = i;
            
            % make sure this one doesn't get picked again
            expectations(i) = 0;
            intervals = cumsum(expectations);
            if(intervals(end) ~= 0)
                intervals = intervals / intervals(end);
            end
            break;
        end
    end
end

