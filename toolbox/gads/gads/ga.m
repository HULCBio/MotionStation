function [x,fval,exitFlag,output,population,scores] = ga(FUN,genomeLength,options)
%GA    Genetic algorithm solver.
%   X = GA(FITNESSFCN,NVARS) finds the minimum of FITNESSFCN using
%   GA. NVARS is the dimension (number of design variables) of the
%   FITNESSFCN. FITNESSFCN accepts a vector X of size 1-by-NAVRS,
%   and returns a scalar evaluated at X. 
% 		
%   X = GA(FITNESSFCN,NAVRS,OPTIONS) finds the minimum for
%   FITNESSFCN with the default optimization parameters replaced by values
%   in the structure OPTIONS. OPTIONS can be created with the GAOPTIMSET
%   function.
% 		
%   X = GA(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a structure
%   that has the following fields:
%       fitnessfcn: <Fitness Function>
%            nvars: <Number of design variables>
%          options: <Options structure created with GAOPTIMSET>
%        randstate: <Optional field to reset rand state>
%       randnstate: <Optional field to reset randn state>
% 		
%   [X, FVAL] = GA(FITNESSFCN, ...) returns FVAL, the value of the fitness
%   function FITNESSFCN at the solution X.
% 		
%   [X,FVAL,REASON] = GA(FITNESSFCN, ...) returns the REASON for stopping.
%
%   [X,FVAL,REASON,OUTPUT] = GA(FITNESSFCN, ...) returns a
%   structure OUTPUT with the following information: 
%            randstate: <State of the function RAND used before GA started>
%           randnstate: <State of the function RANDN used before GA started>
%          generations: <Total generations, excluding HybridFcn iterations>
%            funccount: <Total function evaluations>
%              message: <GA termination message>
%
%   [X,FVAL,REASON,OUTPUT,POPULATION] = GA(FITNESSFCN, ...) returns the final
%   POPULATION at termination.
% 		
%   [X,FVAL,REASON,OUTPUT,POPULATION,SCORES] = GA(FITNESSFCN, ...) returns the
%   SCORES of the final POPULATION.
% 		
%   There are several steps to the GA:
%         population generation
%         scoring
%         loop
%           fitness 
%           scaling 
%           selection 
%           crossover 
%           mutation 
%           scoring 
%           migration
%           output 
%           termination testing
%         end loop
%   Each of these steps can be controlled by the options structure created 
%   by GAOPTIMSET.
%
%   Example:
%     Minimize 'rastriginsfcn' fitness function of numberOfVariables = 2
%        x = ga(@rastriginsfcn,2)
%     Display plotting functions while GA minimizes
% 	      options = gaoptimset('PlotFcns',...
% 	      {@gaplotbestf,@gaplotbestindiv,@gaplotexpectation,@gaplotstopping});
% 	      [x,fval,reason,output] = ga(@rastriginsfcn,2,options)
%
%   See also GAOPTIMSET, FITNESSFUNCTION, PATTERNSEARCH, @.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.28.4.1 $  $Date: 2004/03/09 16:15:33 $

% If the first arg is not a gaoptimset, then it's a fitness function followed by a genome
% length. Here we make a gaoptimset from the args.
defaultopt = struct('PopulationType', 'doubleVector', ...
                    'PopInitRange', [0;1], ...
                    'PopulationSize', 20, ...
                    'EliteCount', 2, ...
                    'CrossoverFraction', 0.8, ...
                    'MigrationDirection','forward', ...
                    'MigrationInterval',20, ...
                    'MigrationFraction',0.2, ...
                    'Generations', 100, ...
                    'TimeLimit', inf, ...
                    'FitnessLimit', -inf, ...
                    'StallGenLimit', 50, ...
                    'StallTimeLimit', 20, ...
                    'InitialPopulation',[], ...
                    'InitialScores', [], ...
                    'PlotInterval',1, ...
                    'FitnessScalingFcn', @fitscalingrank, ...
                    'SelectionFcn', @selectionstochunif, ...
                    'CrossoverFcn',@crossoverscattered, ...
                    'MutationFcn',@mutationgaussian, ...
                    'PlotFcns', [], ...
                    'Display', 'final', ...
                    'OutputFcns', [], ...
                    'CreationFcn',@gacreationuniform, ...
                    'HybridFcn',[], ...
                    'Vectorized','off');   

 msg = nargchk(1,3,nargin);
if ~isempty(msg)
    error('gads:GA:numberOfInputs',msg);
end

% If just 'defaults' passed in, return the default options in X
if checkinputs && nargin == 1 && nargout <= 1 && isequal(FUN,'defaults') 
    x = defaultopt;
    return
end

%if 3 arg, options is passed
if nargin>=3
    if ~isempty(options) && ~isa(options,'struct')
        error('gads:GA:thirdInputNotStruct','Invalid Input for GA.');
    else
        FitnessFcn = FUN;
        GenomeLength = genomeLength;
    end
    if isempty(options)
        options = gaoptimset;
    end
end

%If 2 args, use default options for GA
if nargin==2
    options = gaoptimset;
    FitnessFcn = FUN;
    GenomeLength = genomeLength;
end
if nargin == 1
    try
        options = FUN.options;
        GenomeLength = FUN.nvars;
        FitnessFcn = FUN.fitnessfcn;
        if isfield(FUN, 'randstate') && isfield(FUN, 'randnstate') && ...
                isa(FUN.randstate, 'double') && isequal(size(FUN.randstate),[35, 1]) && ...
                isa(FUN.randnstate, 'double') && isequal(size(FUN.randnstate),[2, 1])
            rand('state',FUN.randstate);
            randn('state',FUN.randnstate);
        end
    catch 
        error('gads:GA:invalidStructInput',lasterr);
    end
end
x =[];fval =[];exitFlag='';population=[];scores=[];user_options = options;
%Remember the random number states used
output.randstate  = rand('state');
output.randnstate = randn('state');
output.generations = 0;
output.funccount   = 0;
output.message   = '';   
        
%Validate arguments
[GenomeLength,FitnessFcn,options] = validate(GenomeLength,FitnessFcn,options);
%Create initial state: population, scores, status data
state = makeState(GenomeLength,FitnessFcn,options);
%Give the plot/output Fcns a chance to do any initialization they need.
state = gaplot(FitnessFcn,options,state,'init');
[state,options] = gaoutput(FitnessFcn,options,state,'init');

%Print some diagnostic information if asked for
if strcmpi(options.Display,'diagnose')
   gadiagnose(FUN,GenomeLength,user_options); 
end
%Setup display header 
if  any(strcmpi(options.Display, {'iter','diagnose'}))
    fprintf('\n                               Best           Mean      Stall\n');
    fprintf('Generation      f-count        f(x)           f(x)    Generations\n');
end

exitFlag = '';
% run the main loop until some termination condition becomes true
while isempty(exitFlag)
        state.Generation = state.Generation + 1;
        %Repeat for each subpopulation (element of the populationSize vector)
        offset = 0;
        totalPop = options.PopulationSize;
        % each sub-population loop
        for pop = 1:length(totalPop)
            populationSize =  totalPop(pop);
            thisPopulation = 1 + (offset:(offset + populationSize - 1));
            population = state.Population(thisPopulation,:);
            score = state.Score( thisPopulation );
            
            [score,population,state] = stepGA(score,population,options,state,GenomeLength,FitnessFcn);
            
            % store the results for this sub-population
            state.Population(thisPopulation,:) = population;
            state.Score(thisPopulation) = score;
            offset = offset + populationSize;
        end 
        
        scores = state.Score;
        % remember the best score
        best = min(state.Score);
        generation = state.Generation;
        state.Best(generation) = best;
        
        % keep track of improvement in the best
        if((generation > 1) && finite(best))
            if(state.Best(generation-1) > best)
                state.LastImprovement = generation;
                state.LastImprovementTime = cputime;
            end
        end
        
        % do any migration
        state = migrate(FitnessFcn,GenomeLength,options,state);
        % update the Output
        state = gaplot(FitnessFcn,options,state,'iter');
        [state,options] = gaoutput(FitnessFcn,options,state,'iter');

        % check to see if any stopping criteria have been met
        exitFlag = isItTimeToStop(options,state);
   end %End while loop

% find and return the best solution
[fval,best] = min(state.Score);
x = state.Population(best,:);

%Update output structure
output.generations = state.Generation;
output.message     = exitFlag;
output.funccount   = state.Generation*length(state.Score);

% load up outputs
if(nargout > 4)
    population = state.Population;
    if(nargout > 5)
        scores = state.Score;
    end
end

% give the Output functions a chance to finish up
gaplot(FitnessFcn,options,state,'done');
gaoutput(FitnessFcn,options,state,'done');

%A hybrid scheme. Try another minimization method if there is one.
if(strcmpi(options.PopulationType,'doubleVector') && ~isempty(options.HybridFcn))
    %Who is the hybrid function
    if isa(options.HybridFcn,'function_handle')
        hfunc = func2str(options.HybridFcn);
    else 
        hfunc = options.HybridFcn;
    end
    %Inform about hybrid scheme
    if  any(strcmpi(options.Display, {'iter','diagnose','final'}))
        fprintf('%s%s%s\n','Switching to the hybrid optimization algorithm (',upper(hfunc),').');
    end

    %Determine which syntax to call
    switch hfunc
        case 'fminsearch'
            if isempty(options.HybridFcnArgs)
                [xx,ff,e,o] = feval(options.HybridFcn,FitnessFcn,x,[],options.FitnessFcnArgs{:});
            else % cell expansion {:} will change the number of input args and hence we need two syntax.
                [xx,ff,e,o] = feval(options.HybridFcn,FitnessFcn,x,options.HybridFcnArgs{:},options.FitnessFcnArgs{:});
            end
            output.funccount = output.funccount + o.funcCount;
            output.message   = [output.message sprintf('\nFMINSEARCH:\n'), o.message];
        case 'patternsearch'
            [xx,ff,e,o] = feval(options.HybridFcn,{FitnessFcn,options.FitnessFcnArgs{:}},x,[],[],[],[],[],[],options.HybridFcnArgs{:});
            output.funccount = output.funccount + o.funccount;
            output.message   = [output.message sprintf('\nPATTERNSEARCH: \n'), o.message];
        case 'fminunc'
            if isempty(options.HybridFcnArgs)
                [xx,ff,e,o] = feval(options.HybridFcn,FitnessFcn,x,[],options.FitnessFcnArgs{:});
            else
                [xx,ff,e,o] = feval(options.HybridFcn,FitnessFcn,x,options.HybridFcnArgs{:},options.FitnessFcnArgs{:});
            end
            output.funccount = output.funccount + o.funcCount;
            output.message   = [output.message sprintf('\nFMINUNC: \n'), o.message];
        otherwise
            error('gads:GA:hybridFcnError','Hybrid function must be one of the following:\n@FMINSEARCH, @FMINUNC, @PATTERNSEARCH.')
    end
    if e > 0 && ff < fval
        fval = ff;
        x = xx;
    end
    %Inform about hybrid scheme termination
    if  any(strcmpi(options.Display, {'iter','diagnose'}))
        fprintf('%s%s\n',upper(hfunc), ' terminated.');
    end
end


