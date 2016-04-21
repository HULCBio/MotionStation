function [XOUT,success] = initialfeasible(XIN,A,L,U)
%INITIALFEASIBLE: Finds initial feasible point subject to  L<=A*X<=U
% 	This function set-up an LP in order to make initial point feasible w.r.t. 
% 	the bounds and linear constraints. This function is private to PFMINLCON
% 	
% 	XIN: Starting guess (may be modified to satisfy the box constraints)
% 	
% 	A,L,U: Defines the feasible region in case of linear/bound constraints as
% 	L<=A*X<=U. This is used to set up the LP.
% 	
% 	IndIneqcstr: Logical indices of inequality constraints. A(IndIneqcstr), LB(IndIneqcstr)
% 	UB(IndIneqcstr) represents inequality constraints.
% 	
% 	IndEqcstr: Logical indices of equality constraints. A(IndEqcstr), LB(IndEqcstr)
% 	UB(IndEqcstr) represents equality constraints.
% 	
% 	XOUT: Feasible point w.r.t. to A, L, U is returned if LP could find a
% 	solution.
% 	
% 	SUCCESS: Indicates success or failure in finding a feasible point.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2004/01/16 16:50:14 $
%   Rakesh Kumar

%Use linear programming to get initial feasible point
[m,n] = size(A);
f = [zeros(n,1); 1];
Abig = [ eye(n)  , -1*ones(n,1); 
         -eye(n) , -1*ones(n,1); 
          A      ,  zeros(m,1);
         -A      ,  zeros(m,1)];
Bbig = [XIN; -XIN; U; -L];
%Remove infinite rows.
temp = isinf(Bbig);
Abig(temp,:) = [];
Bbig(temp)   = [];
%LINPROG 
[XOUT,fval,success] = linprog(f,Abig,Bbig,[],[],[],[],[],optimset('Display','off'));
XOUT(end) = [];


