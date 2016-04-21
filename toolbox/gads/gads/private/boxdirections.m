function directions = boxdirections(pollmethod,x,A,LB,UB,tol)
%BOXDIRECTIONS finds search vectors when bound constraints are present.
%   POLLMETHOD: Poll method used to get search vectors.
% 	
% 	X: Point at which polling is done (usually the best point found so
% 	far).
% 	
% 	A,LB,UB: Defines the feasible region in case of linear constraints.
% 	L<=A*X<=U.
% 	
% 	TOL: Tolerance used for determining whether constraints are active or not.
% 	
% 	DIRECTIONS:  Returns direction vectors that positively span the tangent
% 	cone at the current iterate, with respect to bound and linear constraints.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/06 01:09:51 $
%   Rakesh Kumar

%Initialize co-ordinate search
I = eye(length(x));
%Check which constraints are active for LB <= AX <= UB at 'x'
[lowerbounds,upperbounds] = checkconstraints(x,A,LB,UB,tol);
active  = lowerbounds | upperbounds; 
%Include all directions parallel to active constraints
TangentCone = I(:,active);
Basis = I(:,~active);

% Form directions that positively span the tangent cone at x
if strcmpi(pollmethod,'positivebasisnp1')
    directions = [-sum(Basis,2) Basis  TangentCone -TangentCone];
elseif strcmpi(pollmethod,'positivebasis2n')
    directions = [Basis -Basis TangentCone -TangentCone];
else
    error('gads:BOXDIRECTIONS:pollmethod','Invalid choice of Poll method.');
end

