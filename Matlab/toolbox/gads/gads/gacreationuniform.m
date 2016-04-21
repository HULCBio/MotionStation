function Population = gacreationuniform(GenomeLength,FitnessFcn,options)
%GACREATIONUNIFORM Creates the initial population for genetic algorithm.
%   POP = GACREATIONUNIFORM(NVARS,FITNESSFCN,OPTIONS) Creates the
%   initial population that GA will then evolve into a solution.
%
%   Population size can be a vector of separate populations.
%   Here, we are only interested in the total number.
%
%   Example: 
%     options = gaoptimset('PopulationType','bitString'); 
%            NVARS = 1; FitnessFcn = @ackelyfcn;
%
%     pop = gacreationuniform(NVARS,FitnessFcn,options);
%
%   pop will be a 20-by-1 logical column vector.  Note that the 
%   default Population Size in GAOPTIMSET is 20.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2004/01/16 16:51:45 $
%
totalpopulation = sum(options.PopulationSize);

if(strcmpi(options.PopulationType,'doubleVector'))
    range = options.PopInitRange;
    lowerBound = range(1,:);
    span = range(2,:) - lowerBound;
    Population = repmat(lowerBound,totalpopulation,1) +  repmat(span,totalpopulation,1) .* rand(totalpopulation,GenomeLength);
elseif(strcmpi(options.PopulationType,'bitString'))
    Population = logical(0.5 > rand(totalpopulation,GenomeLength));
else
    msg = sprintf('Unknown population type ''%s'' in problem.',options.PopulationType);
    error('gads:GACREATIONUNIFORM:unkownPopulationType',msg);
end

if all(isnan(Population))
    msg = sprintf(['Initial population contains NaN;','OPTIONS.PopInitRange is possibly too big.']);
    error('gads:GACREATIONUNIFORM:populationIsNaN',msg);
elseif all(isinf(Population))
    msg = sprintf(['Initial population contains Inf;','OPTIONS.PopInitRange is possibly too big.']);
    error('gads:GACREATIONUNIFORM:populationIsInf',msg);
end
    