function mutationChildren = mutationuniform(parents,options,GenomeLength,FitnessFcn,state,thisScore,thisPopulation,mutationRate)
%MUTATIONUNIFORM Uniform multi-point mutation.
%   MUTATIONCHILDREN = MUTATIONUNIFORM(PARENTS,OPTIONS,GENOMELENGTH,...
%                      FITNESSFCN,STATE,THISSCORE,THISPOPULATION, ...
%                      MUTATIONRATE) Creates the mutated children using
%   uniform mutations at multiple points. Mutated genes are uniformly 
%   distributed over the range of the gene. The new value is NOT a function
%   of the parents value for the gene.
%
%   Example:
%     options = gaoptimset('MutationFcn', @mutationuniform); 
%
%   This will create an options structure specifying the mutation
%   function to be used is MUTATIONUNIFORM.  Since the MUTATIONRATE is
%   not specified, the default value of 0.01 is used.
%
%     mutationRate = 0.05;
%     options = gaoptimset('MutationFcn', {@mutationuniform, mutationRate});
%
%   This will create an options structure specifying the mutation
%   function to be used is MUTATIONUNIFORM and the MUTATIONRATE is
%   user specified to be 0.05.
%

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2004/01/16 16:52:07 $

if(nargin < 8)
    mutationRate = 0.01; % default mutation rate
end

if(strcmpi(options.PopulationType,'doubleVector'))
    mutationChildren = zeros(length(parents),GenomeLength);
    for i=1:length(parents)
        child = thisPopulation(parents(i),:);
        % Each element of the genome has mutationRate chance of being mutated.
        mutationPoints = find(rand(1,length(child)) < mutationRate);
        % each gene is replaced with a value chosen randomly from the range.
        range = options.PopInitRange;
        % range can have one column or one for each gene.
        [r,c] = size(range);
        if(c ~= 1)
            range = range(:,mutationPoints);
        end   
        lower = range(1,:);
        upper = range(2,:);
        span = upper - lower;
        
        
        child(mutationPoints) = lower + rand(1,length(mutationPoints)) .* span;
        mutationChildren(i,:) = child;
    end
elseif(strcmpi(options.PopulationType,'bitString'))
    
    mutationChildren = zeros(length(parents),GenomeLength);
    for i=1:length(parents)
        child = thisPopulation(parents(i),:);
        mutationPoints = find(rand(1,length(child)) < mutationRate);
        child(mutationPoints) = ~child(mutationPoints);
        mutationChildren(i,:) = child;
    end
    
end
