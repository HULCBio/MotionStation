function [successSearch,nextIterate,FunEval] = searchga(FUN,Xin,Iterate,ToL,A,L,U, ...
    FunEval,maxFun,searchoptions,objFcnArg,iterLimit,optionsGA)
%SEARCHGA Custom search method using Genetic Algorithm.
%   [SUCESSSEARCH,NEXTITERATE,FUNEVAL] = SEARCHGA(FUN,ITERATE,TOL,A,L, ...
%   U,FUNEVAL,MAXFUN,SEARCHOPTIONS,OBJFCNARG,ITERLIMIT,OPTIONSGA) uses GA
%   to search for the next iterate for patternsearch. GA does not accept an
%   initial point, therefore SEARCHGA is only used for the first iteration
%   (iteration == 1) by default. 
%
%   FUN: The objective function on which SEARCH step is implemented.
% 		
%   ITERATE: Current point in the iteration. ITERATE is a structure which 
%   contains current point 'x' and the function value 'f'.
% 		
%   TOL: Tolerance used for determining whether constraints are active or not.
% 		
%   A,L,U: Defines the feasible region in case of linear/bound constraints 
%   as L<=A*X<=U.
% 		
%   FUNEVAL: Counter for number of function evaluations. FunEval is always less
%   than 'MAXFUN', which is maximum number of function evaluation.
% 		
%   MAXFUN: Limit on number of function evaluation.
% 		
%   SEARCHOPTIONS is a structure containing the following information:
%      completesearch: If 'off' indicates that SEARCH can be called off as
%                      soon as a better point is found, i.e., no sufficient
%                      decrease condition is imposed; Default
%                      is 'on'. See PSOPTIMSET for a description.
%            meshsize: Current mesh size used in SEARCH step.
%           iteration: Current iteration number.
%               scale: Scale factor used to scale the design points.
%         indineqcstr: Indices of inequality constraints.
%           indeqcstr: Indices of equality constraints.
%         problemtype: This flag is passed to the SEARCH routines, indicating
%                      that the problem is 'unconstrained', 'boundconstraints',
%                      or 'linearconstraints'.
%       notvectorized: A flag indicating FUN is not evaluated as vectorized.
%               cache: A flag for using CACHE. If 'off', no cache is used.
%            cachetol: Tolerance used in cache in order to determine whether 
%                      two points are same or not.
%          cachelimit: Limit the cache size to 'cachelimit'. 
% 		
%   OBJFCNARG: Cell array of additional arguments for objective function. 
%
%   ITERLIMIT: No search above this iteration number (Optional argument).
%
%   OPTIONSGA: options structure for GA (Optional argument).
%
%   NEXTITERATE: Successful iterate after polling is done. If POLL is NOT
%   successful, NEXTITERATE is same as ITERATE.
% 		
%   SUCCESSSEARCH: A boolean identifier indicating whether SEARCH is
%   successful or not.
%                                                      
%   See also PATTERNSEARCH, GA, PSOPTIMSET SEARCHFCNTEMPLATE.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.14.6.4 $  $Date: 2004/04/06 01:10:03 $

if nargin < 13 || isempty(optionsGA)
    optionsGA = gaoptimset;
    optionsGA.PopulationSize = 5*length(Iterate.x);
    optionsGA.Generations    = 10*length(Iterate.x);
    optionsGA.StallGenLimit  = 5*length(Iterate.x);
    %No time limit by default
    optionsGA.TimeLimit      = inf;
    optionsGA.StallTimeLimit = inf;
    %Handle range for GA.
    if ~isempty(searchoptions.indineqcstr)
        range = [L(~searchoptions.indineqcstr & ~searchoptions.indeqcstr) ...
                U(~searchoptions.indineqcstr & ~searchoptions.indeqcstr)]';
    else 
        range = [L U]';
    end

    if ~isempty(range) & ~any(isinf(range(:)))
        optionsGA.PopInitRange = range;
    end
end
if nargin < 12 || isempty(iterLimit)
    %GA search is performed only in 1st iteration
    iterLimit = 1;
end

%Initialization
nextIterate = Iterate;
successSearch =0;
%I want to use GA for some initial iterations only
if searchoptions.iteration >= iterLimit
    return;
end

%GA setup
GenomeLength = length(Iterate.x);
FitnessFcn = @fitnessWrapper; % A wrapper to fitness function

%Call GA  if you are using GA search make sure that FUN is compatible with
%GA syntax.
[x,fval,exitFlag,output,pop,scores] = ga({FitnessFcn,objFcnArg{:}},GenomeLength,optionsGA);
if fval < Iterate.f
    successSearch = 1;
    nextIterate.x(:) = x; 
    nextIterate.f = fval;
end
FunEval = FunEval+output.funccount;
%GA always uses row major input. A wrapper around the fitness function
%to take care of shape of the input vector. 
    function f = fitnessWrapper(pop,varargin)
        %fitnessWrapper is a nested function. We know what is the Xin (the
        %shape of start point)
        if size(Xin,1) ~= 1
            f = feval(FUN,pop',objFcnArg{:});
        else
            f = feval(FUN,pop ,objFcnArg{:});
        end
    end
end