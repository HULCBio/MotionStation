function [successSearch,nextIterate,FunEval] = search(FUN,Xin,searchtype,CompleteSearch,Iterate, ...
    Successdir,pollorder,MeshSize,scale,ToL,A,LB,UB,IndIneqcstr,IndEqcstr,Iter,FunEval,maxFun,FLAG, ...
    NotVectorizedSearch,Cache,cachetol,cachelimit,searchFcnArg,varargin)
%SEARCH: Implements a generic search step (optional step) as described in GPS. 
% 		FUN: The objective function on which SEARCH step is implemented.
% 		
% 		SEARCHTYPE: User can choose different kind of search technique using
% 		psoptimset.We can choose any of the POLL techniques as SEARCH (for example
% 		'positivebasisnp1', or 'positivebasis2n' .Default search is  'none' i.e. 
%       no search is performed. 
% 		
% 		COMPLETESEARCH: If 'off' indicates that SEARCH can be called off as soon 
% 		as a better point is found i.e. no sufficient decrease condion is imposed; 
% 		Default is 'on'. 
% 		
% 		ITERATE: Incumbent point around which polling will be done. Iterate Stores 
% 		the current point 'x' and function value 'f' at this point.
% 		
% 		SUCCESSDIR: Last successful POLL/SEARCH direction. This can be used by the
% 		SEARCH step (This can atleast be used by some of POLL methods, used as
% 		SEARCH).
% 		
% 		POLLORDER: Ordering of poll directions (used by some of POLL methods,
% 		used as SEARCH).
% 		
% 		MESHSIZE: Current mesh size used in SEARCH step. 
% 		
% 		SCALE: Scale factor used to scale the design points.
% 		
% 		TOL: Tolerance used for determining whether constraints are active or not.
% 		
% 		A,LB,UB: Defines the feasible region in case of linear/bound
% 		constraints as LB<=A*X<=UB.
% 		
% 		IndIneqcstr: Logical indices of inequality constraints. A(IndIneqcstr), LB(IndIneqcstr)
% 		UB(IndIneqcstr) represents inequality constraints.
% 		
% 		IndEqcstr: Logical indices of equality constraints. A(IndEqcstr), LB(IndEqcstr)
% 		UB(IndEqcstr) represents equality constraints.
% 		
% 		FUNEVAL: Counter for number of function evaluations. FunEval is always less than 
% 		'MAXFUN', which is maximum number of function evaluation.
% 		
% 		
% 		MAXFUN: Limit on number of function evaluation. 
% 		
% 		FLAG: This flag is passed to the SEARCH routines, indicating that the
% 		problem is 'unconstrained', 'boundconstraints', 'linearconstraints'
% 		
% 		NotVectorizedSearch: A flag indicating FUN is not evaluated as
% 		vectorized.
% 		
% 		CACHE: A flag for using CACHE. If 'off', no cache is used.
% 		
% 		CACHETOL: Tolerance used in cache in order to determine whether two points 
% 		are same or not.
% 		
% 		CACHELIMIT: Limit the cache size to 'cachelimit'. 
% 		
% 		NEXTITERATE: Successful iterate after polling is done. If POLL is NOT
% 		successful, NEXTITERATE is same as ITERATE.
% 		
% 		SUCCESSSEARCH: A boolean identifier indicating whether SEARCH is
% 		successful or not.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2004/01/16 16:49:55 $
%   Rakesh Kumar

nextIterate=Iterate;
successSearch =false;
%If [], then do nothing
if isempty(searchtype)
    return;
end
%Special case to have poll methods as function handle
if isa(searchtype,'function_handle')
    if any(strcmpi(func2str(searchtype), {'positivebasisnp1', 'positivebasis2n'}))
        searchtype = func2str(searchtype);    
    end
end
%If not a function_handle 
if ~isa(searchtype,'function_handle') 
    %Must be CHAR if not a function_handle
    if ischar(searchtype) 
           %if any of predefined CHAR for 
        if any(strcmpi(searchtype,{'positivebasisnp1', 'positivebasis2n'})) && ~strcmpi(searchtype,'none') 
            [successSearch,nextIterate,FunEval,successdir] = poll(FUN,Xin,searchtype,CompleteSearch,pollorder,Iterate, ...
             Successdir,MeshSize,scale,ToL,A,LB,UB,IndIneqcstr,IndEqcstr,(Iter+1),FunEval,maxFun,FLAG,NotVectorizedSearch,Cache,cachetol,cachelimit,varargin{:});
        else %If not predefined CHAR then use FEVAL to evaluate the SEARCH function (using try-catch)
             searchOptions = struct('completesearch',CompleteSearch,'meshsize',MeshSize,'iteration',Iter,'scale',scale,'indineqcstr',IndIneqcstr, ...
                    'indeqcstr',IndEqcstr,'problemtype',FLAG,'notvectorized',NotVectorizedSearch,'cache',Cache, ...
                    'cachetol',cachetol,'cachelimit',cachelimit);
            try
               [successSearch,nextIterate,FunEval] = feval(searchtype,FUN,Xin,Iterate,ToL,A,LB,UB,FunEval,maxFun,searchOptions,varargin,searchFcnArg{:});
                
                %This should not happen; make sure that when a custom
                %search is used nextIterate is better than Iterate.
                [X1,feasible] = allfeasible(nextIterate.x(:),A,LB,UB,ToL,IndEqcstr);
                if nextIterate.f > Iterate.f || ~feasible
                    nextIterate = Iterate;
                    successSearch =0;
                end
            catch 
                error('gads:SEARCH:InvalidSearchType',['SEARCH cannot continue because SEARCH function failed with the following error:\n%s'],lasterr);
            end
        end
    else  %End isCHAR test
        error('gads:SEARCH:InvalidSearchMethod','Invalid choice of Search method: See psoptimset for SearchMethod.\n');
    end
else %This must be a function_handle.
    searchOptions = struct('completesearch',CompleteSearch,'meshsize',MeshSize,'iteration',Iter,'scale',scale,'indineqcstr',IndIneqcstr, ...
            'indeqcstr',IndEqcstr,'problemtype',FLAG,'notvectorized',NotVectorizedSearch,'cache',Cache, ...
            'cachetol',cachetol,'cachelimit',cachelimit);
    try
                
        [successSearch,nextIterate,FunEval] = feval(searchtype,FUN,Xin,Iterate,ToL,A,LB,UB,FunEval,maxFun,searchOptions,varargin,searchFcnArg{:});
        %This should not happen; make sure that when a custom
        %search is used nextIterate is better than Iterate.
        
        [X1,feasible] = allfeasible(nextIterate.x(:),A,LB,UB,ToL,IndEqcstr);
        if nextIterate.f > Iterate.f || ~feasible
            nextIterate = Iterate;
            successSearch =0;
        end
    catch 
        error('gads:SEARCH:InvalidSearchType',['SEARCH cannot continue because SEARCH function failed with the following error:\n%s'],lasterr);
    end
end


