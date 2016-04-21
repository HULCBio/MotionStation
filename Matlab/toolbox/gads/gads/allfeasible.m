function [XOUT,feasible] = allfeasible(X,A,L,U,tol,IndEqcstr)
%ALLFEASIBLE Filters all infeasible points in X and returns feasible points.
%   [XOUT,FEASIBLE] = ALLFEASIBLE(X,A,L,U,TOL,INDEQCSTR) where X is a 
%   collection of points for which we check feasibility. A,L,U defines the 
%   feasible region in case of linear/bound constraints L<=A*X<=U. TOL is 
%   the tolerance used to determine feasibility (See the explanation of TolBind 
%   in PSOPTIMSET). X is a matrix of size n-by-m where m is the number of points
%   and n is the dimension size. XOUT is a matrix of feasible points. 
% 	
%   INDEQCSTR: Logical indices of equality constraints. A(IndEqcstr), 
%   L(IndEqcstr), U(IndEqcstr) represents equality constraints.
% 	
%   XOUT: All the feasible points is returned.
% 	
%   FEASIBLE: A logical array indicating if the point is feasible (TRUE), or
%   infeasible (FALSE).
% 	
%   Example:
%     If there are 4 points in 2 dimension space, [2;-4],[1;5],[9;0] 
%     and [-2;1] then 
%
%     X  =   [2  1 9 -2
%            -4  5 0  1 ] 
%
%     and if A = diag([-2,2]), L = zeros(2,1); U = inf*ones(2,1); 
%     tol = 1e-6; we obtain [Xout,feasible] = allfeasible(X,A,L,U,tol,[])
%
%     Xout = [-2;1]
%
%   This is the only point in X that is within the feasible region defined
%   as L<=A*X(:,pt)<=U where pt is the column index of X.
              
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2004/01/16 16:51:31 $
%
feasible = true(size(X,2),1);
XOUT=[];
if ~isempty(A);
    for i = 1:size(X,2)
        feasible(i) = isfeasible(X(:,i),A,L,U,tol,IndEqcstr);
        if feasible(i)
            XOUT(:,end+1) = X(:,i);
        end
    end
else
    XOUT = X;
end


