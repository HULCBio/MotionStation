function [f,count] = funevaluate(FUN,Xin,X,Cache,cachetol,cachelimit,varargin)
%FUNEVALUATE: Evaluate FUN at X.
% 	This function takes a vector or matrix X and evaluate FUN at X. 
% 	If X is a matrix then FUN must return a vector output. The caller 
%   of this function should do the error checking and make sure
% 	that FUN will be able to handle X which is being passed to this function.
% 	
% 	CACHE: A flag for using CACHE. If 'off', no cache is used.
% 	
% 	CACHETOL: Tolerance used in cache in order to determine whether two points 
% 	are same or not.
% 	
% 	CACHELIMIT: Limit the cache size to 'cachelimit'. 
% 	
% 	Example:
% 	If there are 4 points in 2 dimension space then 
%    X is     [2  1  9 -2
%              0  1 -4  5]
%   The objective function will get a transpose of X to be evaluated.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2004/01/16 16:50:13 $
%   Rakesh Kumar

persistent XCache;

%Return here if X is empty
if isempty(X)
    f = [];
    count = 0;
    return;
end

if strcmpi(Cache,'init') || strcmpi(Cache,'off')  %No CACHE use
    XCache = [];
    count = size(X,2);
    f = feval(FUN,reshapeinput(Xin,X),varargin{:});
    NotReal = ~isreal(f);
    f(NotReal) = NaN; 
elseif strcmpi(Cache,'on')
    CacheSize = size(XCache,2);
    %Reset Cache after it takes too much memory
    if prod(CacheSize*size(X,1))*8 > cachelimit 
        XCache(:,1:floor(CacheSize/4)) = [];
        CacheSize = size(XCache,2);
    end
    InCache   = false(size(X,2),1);
    count     = size(X,2);
    f = NaN*ones(count,1);
    %Initialize the cache if it is empty
    if isempty(XCache)
        XCache    = X(:,1);
    end
    %Check if the point is in the CACHE
    for i = 1:size(X,2)
        for j = CacheSize:-1:1
            if isequalpoint(X(:,i),XCache(:,j),cachetol)
                InCache(i)= 1;
                count = count - 1;
                break;
            end
        end
        %Point not found, insert in Cache
        if ~InCache(i) 
            XCache(:,end+1)    = X(:,i);
        end
    end
    
    %Evaluate the function; We will pass transpose of X (in case the function is vectorized)
    if any(~InCache)
        f(~InCache) = feval(FUN,reshapeinput(Xin,X(:,~InCache)),varargin{:});
    end
    NotReal = ~isreal(f);
    f(NotReal) = NaN; 
end

