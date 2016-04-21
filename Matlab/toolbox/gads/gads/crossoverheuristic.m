function xoverKids  = crossoverheuristic(parents,options,GenomeLength,FitnessFcn,thisScore,thisPopulation,ratio)
%CROSSOVERHEURISTIC Move from worst parent to slightly past best parent.
%   XOVERKIDS = CROSSOVERHEURISTIC(PARENTS,OPTIONS,GENOMELENGTH, ...
%   FITNESSFCN,THISSCORE,THISPOPULATION,RATIO) creates the crossover 
%   children XOVERKIDS of the given population THISPOPULATION using the 
%   available PARENTS, the current scores THISSCORE and a RATIO. This kind
%   of recombination will only work for real valued genomes.
%
%   Example:
%    Create an options structure using CROSSOVERHEURISTIC as the crossover
%    function with default ratio of 1.2
%     options = gaoptimset('CrossoverFcn' , @crossoverheuristic);
%
%    Create an options structure using CROSSOVERHEURISTIC as the crossover
%    function with RATIO of 1.5
%     ratio = 1.5;
%     options = gaoptimset('CrossoverFcn' , {@crossoverheuristic,ratio});

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2004/01/16 16:51:32 $

% here's the default if nothing is passed in
if(nargin < 7)
    ratio = 1.2;
end

% How many children am I being asked to produce?
nKids = length(parents)/2;

% Allocate space for the kids
xoverKids = zeros(nKids,GenomeLength);

% To move through the parents twice as fast as thekids are
% being produced, a separate index for the parents is needed
index = 1;

for i=1:nKids
    % get parents
    parent1 = thisPopulation(parents(index),:);
    score1 = thisScore(parents(index));
    index = index + 1;
    parent2 = thisPopulation(parents(index),:);
    score2 = thisScore(parents(index));
    index = index + 1;
    
    % move a little past the better away from the worst
    if(score1 < score2) % parent1 is the better of the pair
        xoverKids(i,:) = parent2 + ratio .* (parent1 - parent2);
    else % parent2 is the better one
        xoverKids(i,:) = parent1 + ratio .* (parent2 - parent1);
    end
end
