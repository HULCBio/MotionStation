function [Iterate,A,L,U,nineqcstr,neqcstr,ncstr,IndIneqcstr,IndEqcstr,msg,exitflag] = ...
    aluform(XOUT,Aineq,Bineq,Aeq,Beq,LB,UB,numberOfVariables,type,verbosity)
%ALUFORM  private to PFMINBND and PFMINLCON.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.8.6.1 $  $Date: 2004/02/01 21:44:15 $

%Initialize
Xin = XOUT;
Iterate.x = XOUT(:);
msg = '';
exitflag = 1;

%If called from PFMINBND, do this bound check
if strcmpi(type,'boundconstraints')
    A = eye(numberOfVariables);
    %Check the box constraints (bounds) first.
    XOUT = Iterate.x;
    lbound   = A*XOUT-LB>=0;
    ubound   = A*XOUT-UB<=0;
    feasible = all(lbound) && all(ubound);
    if ~feasible
        Iterate.x(~lbound) = LB(~lbound);
        Iterate.x(~ubound) = UB(~ubound);
        if verbosity>2
            warning('gads:ALUFORM:infeasibleInitialPoint','Infeasible initial point\nInitial point modified to satisfy bounds.\n');
        end
    end     
    return;
end

%We allow row or column vectors for Beq and Bineq
Bineq = Bineq(:);
Beq   = Beq(:);
%Set the constraints up: defaults and check size
[nineqcstr,n] = size(Aineq);
[neqcstr,m]   = size(Aeq);
if ~isempty(Aineq)
    if ~isequal(length(Bineq),nineqcstr)
        error('gads:ALUFORM:inconsistentAineqAndBineq','The number of rows in A must be the same as the length of b.')
    elseif ~isequal(numberOfVariables,n)
        error('gads:ALUFORM:inconsistentAineqAndX0','The number of columns in A must be the same as the length of X0.')
    end
elseif ~isempty(Bineq)
    error('gads:ALUFORM:emptyAineqNotBineq','The constraint matrices A and b are not consistent.')
end
if ~isempty(Aeq)
    if ~isequal(length(Beq),neqcstr)
        error('gads:ALUFORM:inconsistentAeqAndBeq','The number of rows in Aeq must be the same as the length of beq.')
    elseif ~isequal(numberOfVariables,m)
        error('gads:ALUFORM:inconsistentAeqAndX0','The number of columns in Aeq must be the same as the length of X0.')
    end
elseif ~isempty(Beq)
    error('gads:ALUFORM:emptyAeqNotBeq','The constraint matrices Aeq and beq are not consistent.')
end
%Remove dependent constraint, if any and find a basic solution w.r.t. A,L,U
[Iterate.x,Aineq,Bineq,Aeq,Beq,msg,how,exitflag]= eqnsolv(Iterate.x,Aineq,Bineq,Aeq,Beq,LB,UB,verbosity);

%Reinitialize these
nineqcstr = size(Aineq,1);
neqcstr   = size(Aeq,1);
ncstr     = nineqcstr + neqcstr;   

%Create A, as described in L & T  L <= AX <=U. 
Abox = eye(numberOfVariables);
A    = full([Aeq;Aineq;Abox]);
U    = full([Beq;Bineq;UB]);
L    = full([Beq;repmat(-Inf,nineqcstr,1);LB]);

%logical indices of constraints.
IndIneqcstr = false(size(A,1),1);
IndEqcstr   = false(size(A,1),1);
IndEqcstr(1:neqcstr) = 1;   
IndIneqcstr(neqcstr+1:ncstr) = 1;

%Is initial point feasible?
if strcmp(how,'infeasible')
    % Equalities are inconsistent, so return original X
    Iterate.x = Xin;
     return
end
%Check the box constraints (bounds) first.
XOUT = Iterate.x;
lbound   = Abox*XOUT-LB>=0;
ubound   = Abox*XOUT-UB<=0;
feasible = all(lbound) && all(ubound);
if ~feasible
    Iterate.x(~lbound) = LB(~lbound);
    Iterate.x(~ubound) = UB(~ubound);
    XOUT = Iterate.x;
    if verbosity>2
        warning('gads:ALUFORM:infeasibleInitialPoint','Infeasible initial point\nInitial point modified to satisfy bounds.\n');
    end
end     

%Now add the linear constraints too and check it. 
lbound   = A*XOUT-L>=0;
ubound   = A*XOUT-U<=0;
feasible = all(lbound) && all(ubound);

%Not a feasible point? find an initial feasible point using LP 
if ~feasible
    if verbosity>2
        warning('gads:ALUFORM:infeasibleInitialPoint','Infeasible initial point\nTrying to satisfy the linear constraints.\n');
    end
    [Iterate.x,success] = initialfeasible(Iterate.x,A,L,U);
    if success<=0
        Iterate.x = Xin;
        msg = sprintf('Could not find a feasible initial point.');
        exitflag = -2;
        return;
    end
end

