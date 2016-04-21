function [successSearch,nextIterate,FunEval] = searchneldermead(FUN,Xin,Iterate,ToL,A,L,U, ...
    FunEval,maxFun,searchoptions,objFcnArg,iterLimit,optionsNM)
%SEARCHNELDERMEAD: Search technique using nelder mead (FMINSEARCH).
%   [SUCCESSSEARCH,NEXTITERATE,FUNEVAL] = SEARCHNELDERMEAD(FUN,ITERATE, ...
%   TOL,A,L,U,FUNEVAL,MAXFUN,SEARCHOPTIONS,OBJFCNARG,ITERLIMIT,OPTIONSNM)
%   searches for a lower function value uses the Nelder-Mead method
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
%   FUNEVAL: Counter for number of function evaluations. FUNEVAL is always less
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
%   OPTIONSNM: Options structure for FMINSEARCH (Optional argument).
%
%   NEXTITERATE: Successful iterate after polling is done. If POLL is NOT
%   successful, NEXTITERATE is same as ITERATE.
%
%   SUCCESSSEARCH: A boolean identifier indicating whether SEARCH is
%   successful or not.
%
%   See also PATTERNSEARCH, GA, PSOPTIMSET SEARCHFCNTEMPLATE.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.10.6.3 $  $Date: 2004/04/06 01:10:05 $

if nargin < 13 || isempty(optionsNM)
   optionsNM = optimset('Display','off');
end
if nargin < 12 || isempty(iterLimit)
    iterLimit = 1;
end

nextIterate = Iterate;
successSearch =0;

%Use search step only when mesh size if greater than 1e-1 (Optional)
if searchoptions.iteration >= iterLimit
    return;
end

%Call FMINSEARCH 
Xin(:) = Iterate.x;
optionsNM = optimset(optionsNM,'MaxFunEvals',maxFun-FunEval);
[x,fval,exitflag,output] = fminsearch(FUN,Xin,optionsNM,objFcnArg{:});
FunEval = FunEval+output.funcCount;

if fval < Iterate.f
    successSearch = 1;
    nextIterate.x = x(:);
    nextIterate.f = fval;
end

    
 
