function [successSearch,nextIterate,FunEval] = searchfcntemplate(FUN,Xin,Iterate,ToL,A,L,U, ...
    FunEval,maxFun,searchoptions,objFcnArg,iterLimit,factors)
%SEARCHFCNTEMPLATE Template to write custom search method.		
%   [SUCCESSSEARCH,NEXTITERATE,FUNEVAL] = SEARCHFCNTEMPLATE(FUN,ITERATE, ...
%   TOL,A,L,U,FUNEVAL,MAXFUN,SEARCHOPTIONS,OBJFCNARG,ITERLIMIT,FACTORS) is
%   a template file which performs a search step on objective function
%   FUN using latin hypercube search. 
% 		
%   ITERATE: Current point in the iteration. ITERATE is a structure which 
%   contains current point 'x' and the function value 'f'.
% 		
%   TOL: Tolerance used for determining whether constraints are active or
%   not.
% 		
%   A,L,U: Defines the feasible region in case of linear/bound constraints 
%   as L<=A*X<=U.
% 		
%   FUNEVAL: Counter for number of function evaluations. FUNEVAL is always
%   less than 'MAXFUN', which is maximum number of function evaluation. 
% 		
%   MAXFUN: Limit on number of function evaluations.
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
%   FACTORS: The design level for LHS (Optional argument).
%
%   NEXTITERATE: Successful iterate after polling is done. If POLL is NOT
%   successful, NEXTITERATE is same as ITERATE.
% 		
%   SUCCESSSEARCH: A boolean identifier indicating whether SEARCH is
%   successful or not.
%                                          
%   See also PATTERNSEARCH, GA, PSOPTIMSET and PSOUTPUTFCNTEMPLATE.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/06 01:10:02 $

%Initialization

successSearch = 0;
nextIterate   = Iterate;
numberofVariables  = size(Iterate.x,1);

if nargin < 13 || isempty(factors)
    factors = 15*numberofVariables; 
end
if nargin <12 || isempty(iterLimit)
    iterLimit = 0;  
end

%Use search step only till iterLimit.
if searchoptions.iteration > iterLimit
    return;
end
%Get information from the searchoptions structure
Completesearch  = searchoptions.completesearch; 
IndEqcstr       = searchoptions.indeqcstr; 
NotVectorized   = searchoptions.notvectorized;
Cache           = searchoptions.cache; 
cachetol        = searchoptions.cachetol; 
cachelimit      = searchoptions.cachelimit; 
MeshSize        = searchoptions.meshsize;
scale           = searchoptions.scale;

%LHS design calculations for 'maximin' criterion
Points = lhspoint(factors,numberofVariables);
if ~isempty(searchoptions.indineqcstr)
    range = [L(~searchoptions.indineqcstr & ~searchoptions.indeqcstr) ...
            U(~searchoptions.indineqcstr & ~searchoptions.indeqcstr)]';
else 
    range = [L U]';
end

if ~isempty(range) & ~any(isinf(range(:)))
    limit = range(2,:) - range(1,:);
    Points = repmat(range(1,:)',1,size(Points,2)) +  repmat(limit',1,size(Points,2)) .* Points;
else 
    Points = -1 + Points*2;
end

span = size(Points,2);
%Get the trial points
sites = struct('x',cell(span,1),'f',cell(span,1));
for k = 1:span
    sites(k).x = Points(:,k);
end

%Find an iterate with lower objective 
[successSearch,nextIterate,direction,FunEval] = nextfeasible(FUN,Xin,sites,Iterate,A,L,U, ...
    FunEval,maxFun,Completesearch,ToL,IndEqcstr,NotVectorized,Cache,cachetol,cachelimit,objFcnArg{:});
