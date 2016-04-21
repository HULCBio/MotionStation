function expectation = fitscalingrank(scores,nParents)
% FITSCALINGRANK Rank based fitness scaling.
%   EXPECTATION = FITSCALINGRANK(SCORES,NPARENTS) calculates the
%   EXPECTATION using the SCORES and number of parents NPARENTS.
%   This relationship can be linear or nonlinear.
%
%   Example:
%   Create an options structure using FITSCALINGRANK as 
%   the fitness scaling function
%     options = gaoptimset('FitnessScalingFcn',@fitscalingrank);

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2004/01/16 16:51:41 $

[unused,i] = sort(scores);

expectation = zeros(size(scores));
expectation(i) = 1 ./ ((1:length(scores))  .^ 0.5);

expectation = nParents * expectation ./ sum(expectation);
