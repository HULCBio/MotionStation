function directions = uncondirections(pollmethod,x)
%UNCONDIRECTIONS: finds search vectors when no constraints are present.
%   POLLMETHOD: Poll method used to get search vectors.
%
% 	X: Point at which polling is done (usually the best point found so
% 	far).
% 	
% 	DIRECTIONS:  Returns direction vectors that positively span the tangent
% 	cone at the current iterate, with respect to bound and linear constraints.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/06 01:09:55 $
%   Rakesh Kumar
vars = length(x);
Basis  = eye(vars);
% Form directions that forms the positive basis
if strcmpi(pollmethod,'positivebasisnp1')            %Minimal positive basis (n+1 vectors)
    directions = [-1*ones(vars,1) Basis];
elseif strcmpi(pollmethod,'positivebasis2n')         %Maximal positive basis (2n vectors)
    directions = [Basis -Basis];
else
    error('gads:UNCONDIRECTIONS:pollmethod','Invalid choice of Poll method.');
end
