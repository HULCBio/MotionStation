function directions = lcondirections(pollmethod,x,A,LB,UB,tol,IndEqcstr)
%LCONDIRECTIONS finds search vectors when linear constraints and bounds are present.
% 	POLLMETHOD: Poll method used to get search vectors.
% 	
% 	X: Point at which polling is done (usually the best point found so far)
% 	
% 	A,LB,UB: Defines the feasible region in case of linear/bound constraints as L<=A*X<=U.
% 	
% 	TOL: Tolerance used for determining whether constraints are active or not.
% 	
% 	IndIneqcstr: Logical indices of inequality constraints. A(IndIneqcstr), LB(IndIneqcstr)
% 	UB(IndIneqcstr) represents inequality constraints.
% 	
% 	IndEqcstr: Logical indices of equality constraints. A(IndEqcstr), LB(IndEqcstr)
% 	UB(IndEqcstr) represents equality constraints.
% 	
% 	DIRECTIONS:  Returns direction vectors that positively span the tangent
% 	cone at the current iterate, with respect to bound and linear constraints.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/06 01:09:53 $
%   Rakesh Kumar


%Initialization
LB(IndEqcstr) = -inf;
TangentCone = [];
vars = length(x);
Basis = eye(vars);
Normals = zeros(vars,1);
tol = tol*ones(size(A,1),1);
tolDep = 100*vars*eps;

%The cone generators for minimumm epsilon is in active set 
%(Lewis & Torczon section 8.2)
while rank(Normals) ~= min(size(Normals)) 
    if tol < tolDep
        error('gads:LCONDIRECTIONS:degenconstr','Constraints are dependent at current iterate\nTry increasing OPTIONS.TolBind (<eps).'); 
    end
    [lowerbounds,upperbounds] = checkconstraints(x,A,LB,UB,tol);
    Normals = [A(upperbounds,:); -A(lowerbounds,:)]';
    tol = tol/2;
end

%Lewis & Torczon section 8.2. T = V*inv(V'V), which is computed using QR
%decomposition
if (~isempty(Normals))
    [Q,R] = qr(Normals,0);
    TangentCone = Q/R';
    Basis = Basis - TangentCone*Normals';
end

% Form directions that positively span the tangent cone at x
if strcmpi(pollmethod,'positivebasisnp1')
    directions = [-sum(Basis,2) Basis  TangentCone -TangentCone];
elseif strcmpi(pollmethod,'positivebasis2n')
    directions = [Basis -Basis TangentCone -TangentCone];
else
    error('gads:LCONDIRECTIONS:pollmethod','Invalid choice of Poll method.');
end
