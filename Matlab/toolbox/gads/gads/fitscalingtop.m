function expectation = fitscalingtop(scores,nParents,quantity)
%FITSCALINGTOP Top individuals reproduce equally.
%   EXPECTATION = FITSCALINGTOP(SCORES,NPARENTS,QUANTITY) calculates the
%   EXPECTATION using the SCORES and number of parents NPARENTS as well as 
%   QUANTITY.  QUANTITY represents either the number of expectations or 
%   the number of expectations in terms of the population size. If QUANTITY 
%   is not specified a default value of 0.4 is used. This function chooses the  
%   best QUANTITY scores for parents. QUANTITY can be an integer or a fraction
%   of the populationSize.
%
%   Example:
%   Create an options structure that uses FITSCALINGTOP as the fitness
%   scaling function and 0.5 as the QUANTITY
%     quantity = 0.5;
%     options = gaoptimset('FitnessScalingFcn',{@fitscalingtop, quantity}); 

% 	 Each of the best n individuals have an equal chance of reproducing.
% 	 The rest have zero expectation. Expectation looks like:
% 	 [ 0 1/n 1/n 0 0 1/n 0 0 1/n ...]
% 	 this is called "Top fitness scaling" or "Truncation fitness scaling."
% 	 If quantity is set to 1, this is called "Best fitness scaling."

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2004/01/16 16:51:44 $

if(nargin < 3)
    quantity = 0.4;
end

% if less than one, it's a fraction, not the absolute number.
if(quantity < 1)
    quantity = round(quantity * length(scores));
end

expectation = zeros(1,length(scores));

% find the best ones
[unused,i] = sort(scores);
expectation(i(1:quantity)) = nParents / quantity;
