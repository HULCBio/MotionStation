function [found,nextIterate,FunEval] = nextpoint(FUN,Xin,X,Iterate,FunEval,maxFun, ...
    CompleteSearch,NotVectorized,Cache,cachetol,cachelimit,varargin)
%NEXTPOINT Returns the best iterate. 	
%   [FOUND,NEXTITERATE,FUNEVAL] = NEXTPOINT(FUN,X,ITERATE,FUNEVAL, ...
%   MAXFUN,COMPLETESEARCH,NOTVECTORIZED,CACHE,CACHETOL,CACHELIMIT) X is a 
%   collection of points at which we evaluate the function FUN. X is
%   a matrix of size n-by-m where m is the number of points and n is the
%   dimension size.
% 		
%   ITERATE: Current point around which X will be evaluated and compared. 
%   ITERATE is a structure which contains current point 'x' and the function 
%   value 'f'.
% 		
%   FUNEVAL: Counter for number of function evaluations. FUNEVAL is always
%   less than 'MAXFUN', which is maximum number of function evaluation.
% 		
%   MAXFUN: Limit on number of function evaluations.
% 		
%   COMPLETESEARCH: If 'off' indicates that POLL can be called off as soon 
%   as a better point is found, i.e., no sufficient decrease condition is
%   imposed; If 'on' then ALL the points are evaluated and the point with least
%   function value is returned. Default is 'off'. If objective function
%   is expensive, set this option to 'off'.
% 		
%   NOTVECTORIZED: A flag indicating FUN is not evaluated as vectorized 
%   function.
% 		
%   FOUND: A flag indicating that the nextIterate has a lesser function
%   value. If FOUND is 0 then a lesser function value was not found in X and
%   nextIterate is same as Iterate% 		
%   
%   NEXTITERATE: Point returned by this function. If found is 0, then
%   nextiterate is same as Iterate else a better iterate was found.
% 		
%   Example:
%     If there are 4 points(=m) in 2 dimension space (=n) then 
%        X is     [2  1  9 -2
%                  0  1 -4  5]

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2004/01/16 16:52:08 $

nextIterate = Iterate;
found =0;
if (isempty(X))    %No design sites to evaluate
    return
end
nextIterate = Iterate;
%maxeval will make sure that we respect the limit on function evaluation.
maxeval = min(size(X,2),maxFun-FunEval);

if NotVectorized
    for i = 1:maxeval   
        [f,count] = funevaluate(FUN,Xin,X(:,i),Cache,cachetol,cachelimit,varargin{:});
        FunEval = FunEval+count;
        if(Iterate.f > f)
            nextIterate.x = X(:,i);
            nextIterate.f =f;
            found =1;
            if strcmpi(CompleteSearch,'off')
                return;
            end
        end  
    end 
elseif strcmpi(CompleteSearch,'on')
    [f,count] = funevaluate(FUN,Xin,X(:,1:maxeval),Cache,cachetol,cachelimit,varargin{:});
    FunEval = FunEval+count;
    for i =1:maxeval
        if (nextIterate.f > f(i))
            nextIterate.x = X(:,i);
            nextIterate.f =f(i);
            found =1;
        end
    end
end
