function [xsol, fval, dualvars, exitflag, niters, basicVarIdx, nonbasicVarIdx] ...
    = simplexphasetwo(c,A,b,lb,ub,basicVarIdx,nonbasicVarIdx,x0,maxiter,...
    tol,verbosity,computeLambda)
%SIMPLEXPHASETWO Phase two of simplex method for linear programming.                   
%   X = SIMPLEXPHASETWO(c,A,b,lb,ub) solves linear programming problems in
%   general form with upper bound and lower bound:
%              min  c'* x 
%              s.t. A * x = b,  
%                 lb <= x <= ub.
%
%   [X,FVAL] = SIMPLEXPHASETWO(c,A,b,lb,ub) returns the value of the 
%   objective function at X: FVAL = c'*X.
%
%   [X,FVAL,EXITFLAG] = SIMPLEXPHASETWO(c,A,b,lb,ub) returns EXITFLAG that 
%   describes the exit solution condition of SIMPLEXPHASETWO.
%   If EXITFLAG is:
%      1    then SIMPLEXPHASETWO converged with a solution X.
%      0    then the maximum number of iterations was exceeded
%      < 0  then the problem is unbounded, infeasible, or 
%                SIMPLEXPHASETWO failed to converge with a solution X.
%      -1   then the problem is infeasible
%      -2   then the problem is unbounded
%      -3   then the problem is degenerate
%
%   [X,FVAL,EXITFLAG, NITERS] = SIMPLEXPHASETWO(c,A,b) returns a number of 
%   total iterations NITERS used in the simplex method.
%
%   Input:  A  ... constraint matrix
%           b  ... the right hand side of the constraints
%           c  ... the objective function (coefficient vector)
%           lb ... the lower bound on the variable x
%           ub ... the upper bound on the variable x
%
%   Output: xsol     ... optimal solution
%           fval     ... optimal value
%           exitflag ... the status of the solution

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2004/02/01 22:09:39 $

% -------Set up a feasible basis solution (starting vertex)-------------
% Set up the input problem data: c, A, b, lb, ub and
%        basicVarIdx, nonbasicVarIdx; B, N and c_B, c_N; ub_B, lb_B; and ub_N, lb_N.
if nargin < 11
    verbosity = 0;
end

[m, n] = size(A);

if n > 0 
    if isempty(lb) 
        lb = repmat(-inf, n,1);
    end
    if isempty(ub)
        ub = repmat(inf, n,1);
    end
else
    error('optim:simplexphasetwo:EmptyA', ...
          'Exiting form SIMPLEXPHASETWO: the constraint matrix A is empty.');
end

c  = c(:);
b  = b(:);
lb = lb(:);
ub = ub(:);
x0 = x0(:);
basicVarIdx = basicVarIdx(:);
nonbasicVarIdx = nonbasicVarIdx(:);

if ( nnz(basicVarIdx) > 0 ) 
    Basis    = A(:, basicVarIdx);
    Nonbasis = A(:, nonbasicVarIdx);
    
    x_B = x0(basicVarIdx);
    x_N = x0(nonbasicVarIdx);
    
    c_B = c(basicVarIdx);
    c_N = c(nonbasicVarIdx);
    
    ub_B = ub(basicVarIdx);
    ub_N = ub(nonbasicVarIdx);
    lb_B = lb(basicVarIdx);
    lb_N = lb(nonbasicVarIdx);    
end

tol2 = tol * 1.e-2;
if verbosity >= 5
    % Check the output data
    ubcheck = max ( [x_B - ub_B; x_N - ub_N] );
    lbcheck = max ( [lb_B - x_B; lb_N - x_N] );
    if (ubcheck > tol2) || (lbcheck > tol2)
        error('optim:simplexphasetwo:BndryCondViolated', ...
              'Boundary condition is violated by %e.', max(ubcheck, lbcheck) );
    end
end

% Initialize the output variables, display the starting iteration
dualvars = struct('y', [], 'z', [], 'w', []);
niters = 0;
xsol = [x_B; x_N];
fval = c_B' * x_B + c_N' * x_N;
if verbosity >= 2
    disp( sprintf('\nPhase 2: Minimize using simplex.') );
    disp( sprintf('      Iter            Objective              Dual Infeasibility ') );
    disp( sprintf('                        f''*x                   A''*y+z-w-f') );
end

if verbosity >= 5
    disp( sprintf('    [basicVarIdx      c_B      x_B      lb_B      ub_B] = ') );
    disp(              full([basicVarIdx      c_B      x_B      lb_B      ub_B]) );
    disp( sprintf('    [nonbasicVarIdx      c_N      x_N      lb_N      ub_N] = ') );
    disp(              full([nonbasicVarIdx      c_N      x_N      lb_N      ub_N]) );
    disp( sprintf('*********************************') );
end

% Test optimality condition and update Basis solution if necessary----------

% Initialization of constants for exitflag
Converged   = 1;
ExcdMaxiter = 0;
%Infeasible  = -1;
Unbounded   = -2; % Will be remapped to -3 in linprog.m
Degenerate  = -3;
Unset       = inf;

% Initialization for the while loop
exitflag = Unset;
tol2 = tol^2;

% sameBasis=true signals whether the entering variable switches between its bounds
sameBasis = false;  
while (niters < maxiter)
    % Solve the system y * Basis = c_B', 
    if ~sameBasis
        y = c_B' / Basis;
    end
    
    % Choose the entering variable and check the optimality condition
    dualf = c_N - (y * Nonbasis)';
    
    enteringCandidates = find( ((dualf >= tol) & (x_N - lb_N > tol2)) | ((dualf <= -tol) & (tol2 < ub_N - x_N)) );
    
    if verbosity >= 2
        disp( sprintf('%8d         %12.6g                %12.6g', niters, full(fval), norm(dualf(enteringCandidates))) );
    end
    
    if isempty( enteringCandidates ) % No entering variable exists, already optimal                                                       
        exitflag = Converged;
        % Final output information
        if verbosity >= 4
            disp('  Converged to the optimal solution.');  
        end
        % Sort the optimal solution according to the original problem
        [tmp, order] = sort([basicVarIdx; nonbasicVarIdx]);
        xsol = xsol(order);
        
        % Dual variables for lambda: y, zdual, wdual
        if computeLambda == 1
            y = y(:); % Corresponding to both inequalities and equalities
            dualvars.y = y;
            
            tol3 = 1.0e-10;
            indgtlo = (xsol > lb + tol3);
            nnzgtlo = nnz(indgtlo);
            zdual = zeros(size(indgtlo)); % Set the size of zdual right, catch the zeros.
            zdual(indgtlo,1) = zeros(nnzgtlo, 1);
            indeqlo = ( abs(x_N -lb_N) < tol3 );
            zdual(nonbasicVarIdx(indeqlo), 1) = dualf(indeqlo);
            dualvars.z = zdual;
            
            indltup = (xsol < ub - tol3); 
            nnzltup = nnz(indltup); 
            wdual = zeros(size(indltup)); % Make assignment to zeros that the size is right
            wdual(indltup,1) = zeros(nnzltup,1);
            indequp = ( abs(x_N - ub_N) < tol3 );
            wdual(nonbasicVarIdx(indequp), 1) = -dualf(indequp);
            dualvars.w = wdual;
            
            if verbosity >= 4
                disp( sprintf('  The norm of the dual feasibility norm(A''y-w +z -c) = %8.2e', ...
                    norm(A'*y - wdual + zdual - c) ) );
            end
        end
        return; 
    end
    
    % indexEnter is the chosen index of the entering variable 
    indexEnter = min(enteringCandidates);  % choose by the smallest-subscript rule
    niters = niters + 1;
    
    % Solve the system Basis * z = N_{.,k}  
    N_indexEnter = Nonbasis(:, indexEnter);
    z = Basis \ N_indexEnter; 
    
    % Choose the leaving variable and update-------------
    indexLeave = 0;
    minUb      = inf;
    zind       = find( abs(z) > tol);  
    
    indnegz     = z(zind) < - tol;
    if ( dualf(indexEnter) <= -tol)  && ( tol2 < ub_N(indexEnter) - x_N(indexEnter) )   
        ub_delta = ub_N(indexEnter) - x_N(indexEnter);
        
        % Find index that gives the tightest upper bound
        if ~isempty(zind)
            bounds = lb_B(zind);
            bounds(indnegz) = ub_B( zind(indnegz) ); 
            tB = (x_B(zind) - bounds)./ z(zind);
            minUb = min(tB);
            candtB = find(minUb == tB);
            indexLeave = min(candtB);
            % Choose indexLeave by the smallest-script rule
            indexLeave = zind(indexLeave);
        end
        
        if minUb < ub_delta
            delta = minUb;
            sameBasis = false;
        else 
            delta = ub_delta;
            sameBasis = true;    
        end
        
        % Update on solution x_N and x_B
        if delta < inf && delta > tol2 
            x_N(indexEnter) = x_N(indexEnter) + delta;
            x_B = x_B - delta * z;
        end
        
    elseif ( dualf(indexEnter) >= tol )  &&  ( x_N(indexEnter) - lb_N(indexEnter) > tol2 )     
        ub_delta =  x_N(indexEnter) - lb_N(indexEnter);
        
        % Find the index that gives the tightest upper bound
        if ~isempty(zind)
            bounds = ub_B(zind);
            bounds(indnegz) = lb_B( zind(indnegz) ); 
            tB = (bounds - x_B(zind))./ z(zind);
            minUb = min(tB);
            candtB = find(minUb == tB);
            indexLeave = min(candtB);
            % Choose by the smallest-script rule
            indexLeave = zind(indexLeave);
        end
        
        if minUb < ub_delta   
            delta = minUb;
            sameBasis = false;
        else  
            delta = ub_delta;
            sameBasis = true;
        end
        
        % Update the solution x_N and x_B
        if delta < inf && delta > tol2
            x_N(indexEnter) = x_N(indexEnter) - delta;
            x_B = x_B + delta * z;
        end
    end
    
    if ( abs( dualf(indexEnter) ) > tol )    
        if isinf(delta)
            exitflag = Unbounded;
            % Set the delta to be 1.0e+16 in unbounded case.
            delta = 1.0e+16;
            if dualf(indexEnter) >= tol
                x_N(indexEnter) = x_N(indexEnter) - delta;
                x_B = x_B + delta * z;
            elseif dualf(indexEnter) <= -tol
                x_N(indexEnter) = x_N(indexEnter) + delta;
                x_B = x_B - delta * z;
            end
            xsol = [x_B; x_N];
            [tmp, order] = sort([basicVarIdx; nonbasicVarIdx]);
            xsol = xsol(order); 
            fval = c'*xsol;
            % Note niters is updated but the last iteration is not executed
            % completely, so niters needs to be adjusted by -1.
            niters = niters - 1;
            return; 
        elseif  delta < tol2   
            exitflag = Degenerate; 
            dcount = nnz( x_B == lb_B | x_B == ub_B );
            if verbosity >= 5
                disp( sprintf('******%8d degenerating already.', dcount) );
                disp( sprintf('indexEnter=%d, \t nonbasicVarIdx(indexEnter) = %d', indexEnter, nonbasicVarIdx(indexEnter) ) );
                disp( sprintf('indexLeave=%d, \t basicVarIdx(indexLeave) = %d', indexLeave, basicVarIdx(indexLeave) ) );
                disp( sprintf('    [basicVarIdx      c_B      x_B      lb_B      ub_B] = ') );
                disp(              full([basicVarIdx      c_B      x_B      lb_B      ub_B]) );
                disp( sprintf('    [nonbasicVarIdx      c_N      x_N      lb_N      ub_N] = ') );
                disp(              full([nonbasicVarIdx      c_N      x_N      lb_N      ub_N]) );
            end
        end
    else
        error('optim:simplexphasetwo:WrongEnteringVar', ...
              'The choice of the entering variable is wrong.');
    end
    
    % Update Basis, Nonbasis; basicVarIdx, nonbasicVarIdx; and c_B, c_N; ub_B, ub_N; lb_B, lb_N; 
    % x_B(indexLeave), x_N(indexEnter) after each iteration on basis
    % Basis(:,indexLeave) <--> Nonbasis(:, indexEnter);
    % basicVarIdx(indexLeave)   <--> nonbasicVarIdx(indexEnter);
    % c_B(indexLeave)     <--> c_N(indexEnter);
    % ub_B(indexLeave)    <--> ub_N(indexEnter);
    % lb_B(indexLeave)    <--> lb_N(indexEnter);
    % x_B(indexLeave)     <--> x_N(indexEnter);
    
    if ~sameBasis
        Nonbasis(:,indexEnter) = Basis(:,indexLeave);
        Basis(:,indexLeave)    = N_indexEnter;
        
        swaptmp           = basicVarIdx(indexLeave);
        basicVarIdx(indexLeave) = nonbasicVarIdx(indexEnter);
        nonbasicVarIdx(indexEnter) = swaptmp;
        
        swaptmp           = c_B(indexLeave); 
        c_B(indexLeave)   = c_N(indexEnter);
        c_N(indexEnter)   = swaptmp; 
        
        swaptmp           = ub_B(indexLeave);
        ub_B(indexLeave)  = ub_N(indexEnter);
        ub_N(indexEnter)  = swaptmp;
        
        swaptmp           = lb_B(indexLeave);
        lb_B(indexLeave)  = lb_N(indexEnter);
        lb_N(indexEnter)  = swaptmp;
        
        swaptmp           = x_B(indexLeave);
        x_B(indexLeave)   = x_N(indexEnter);
        x_N(indexEnter)   = swaptmp;
    end % end of "if ~sameBasis"
    
    xsol = [x_B; x_N];
    fval = c_B' * x_B + c_N' * x_N;
    
    % When maxiter reached, print last iteration and set exitflag = 0.
    if (niters ==  maxiter)
        exitflag = ExcdMaxiter;
        [tmp, order] = sort([basicVarIdx; nonbasicVarIdx]);
        xsol = xsol(order);
        
        % Compute the dual infeasibility when niters == maxiter, 
        % only for display iteration purpose
        if (verbosity >=2) 
            if ~sameBasis
                y = c_B' / Basis;
            end
            dualf = c_N - (y * Nonbasis)';
            enterCandidates = ((dualf >= tol) & (x_N - lb_N > tol2)) | ((dualf <= -tol) & (tol2 < ub_N - x_N));
            disp( sprintf('%8d         %12.6g                %12.6g', niters, full(fval), norm(dualf(enterCandidates))) );
        end
    end
    
    if verbosity >= 5
        % For checking purpose 
        fcheck = max (abs( A(:, basicVarIdx)*xsol(1:m) + A(:,nonbasicVarIdx)*xsol(m+1: n) - b ) );  
        if fcheck > 1.0e-8
            disp( sprintf('  Feasibility is broken in this iteration. %e.', fcheck) );       
        end
        ubcheck = max ( [x_B - ub_B; x_N - ub_N] );
        lbcheck = max ( [lb_B - x_B; lb_N - x_N] );
        if (ubcheck > tol2) || (lbcheck > tol2)
            disp( sprintf('  Boundary condition is violated by %e.', max(ubcheck, lbcheck) ) );
        end
    end
    
end % while (niters < maxiter)

if (niters == maxiter) 
    exitflag = ExcdMaxiter;
end
%END of SIMPLEXPHASETWO
