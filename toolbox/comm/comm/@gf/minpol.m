function poly = minpol(x)
%MINPOL Find the minimal polynomial of an element of a Galois field.
%   PL = MINPOL(X) produces a minimal polynomial for each entry in 
%   the Galois column vector X.  The ith row of PL represents the 
%   minimal polynomial of X(i).  The coefficients of the minimal 
%   polynomial are in the base field GF(2) and listed in order of
%   descending exponents.
%
%   See also COSETS.

%    Copyright 1996-2003 The MathWorks, Inc.
%    $Revision: 1.4.4.3 $  $Date: 2004/04/12 23:01:09 $ 

% X must be a GF object
if(~isa(x,'gf'))
    error('X must be a GF object');
end

% X must be a column vector.
if(size(x,2) >1)
    error('X must be a scalar or a column vector');
end

% get the cosets 
coset = cosets(x.m, x.prim_poly);

%initialize poly...
poly = gf(zeros(length(x),x.m+1), 1);

%need for Subsref
S.type = '()';

% do once for each element of x
for k = 1:length(x)    
    % special case
    S.subs = {k};
    if(subsref(x,S) == 0)
        S.subs = {k,x.m};
        poly = subsasgn(poly,S,1);
    elseif(subsref(x,S) == 1)
       S.subs = {k,x.m+1};
        poly = subsasgn(poly,S,1);
        S.subs = {k,x.m};
        poly = subsasgn(poly,S,1);
    else
        
        % find the coset that x belongs to.
        for i = 1:length(coset)
            S.subs  = {k};
            ind = find(coset{i} == subsref(x,S));
            if ~isempty(ind)
                cos = coset{i};
                break
            end
        end
        
        % compute the minimum polynomial
        tempPoly = 1;
        for i=1:length(cos);
            S.subs = {i};
            tempPoly = conv(tempPoly, [1 subsref(cos,S)]);
        end
        
        % store minimum polynomial in poly. Pad if needed.            
        pad = size(poly,2)-length(tempPoly);
        S.subs = {k,':'};
        poly = subsasgn(poly,S,[ zeros(1,pad), tempPoly]);
    end        
end
