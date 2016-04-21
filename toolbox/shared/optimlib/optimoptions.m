function optimoptions
% OPTIMOPTIONS displays option names and values for the Optimization Toolbox
%   used by OPTIMSET.  Type "help optimset" for options in MATLAB and Optimization.
%
%   OPTIMOPTIONS with no input arguments and no output arguments displays
%   all option names and their possible values, with defaults shown in {}
%   when the default is the same for all functions that use that option.
%
%OPTIMIZATION OPTIONS
%BranchStrategy - Branch variable selection strategy
%                 [ mininfeas | {maxinfeas} ]
%DerivativeCheck - Compare user supplied derivatives (gradients or Jacobian)
%                  to finite-differencing derivatives  [ on | {off}]
%Diagnostics - Print diagnostic information about the function to be
%              minimized or solved [ on | {off}]
%DiffMaxChange - Maximum change in variables for finite difference gradients
%              [ positive scalar  | {1e-1} ]
%DiffMinChange - Minimum change in variables for finite difference gradients
%              [ positive scalar  | {1e-8} ]
%Display - Level of display [ off | iter | notify | final ]
%GoalsExactAchieve - Number of goals to achieve exactly (do not over- or
%                    under-achieve) [ positive scalar integer | {0} ]
%GradConstr - Gradients for the nonlinear constraints defined by user
%                    [ on | {off} ]
%GradObj - Gradient(s) for the objective function(s) defined by user
%                    [ on | {off}]
%Hessian - Hessian for the objective function defined by user  [ on | {off} ]
%HessMult - Hessian multiply function defined by user
%                    [ function | {[]} ]
%HessPattern - Sparsity pattern of the Hessian for finite-differencing
%              [ sparse matrix ]
%HessUpdate - Quasi-Newton updating scheme
%             [ {bfgs} | dfp | steepdesc ]
%InitialHessType - Initial Quasi-Newton matrix type
%                  [ identity | {scaled-identity} | user-supplied ]
%InitialHessMatrix - Initial Quasi-Newton matrix
%                    [ scalar | vector | {[]} ]
%Jacobian - Jacobian for the objective function defined by user
%                    [ on | {off} ]
%JacobMult - Jacobian multiply function defined by user
%                    [ function | {[]} ]
%JacobPattern - Sparsity pattern of the Jacobian for finite-differencing
%               [ sparse matrix ]
%LargeScale - Use large-scale algorithm if possible [ {on} | off ]
%LevenbergMarquardt - Chooses Levenberg-Marquardt over Gauss-Newton algorithm
%                     [ on | off ]
%LineSearchType - Line search algorithm choice [ cubicpoly | {quadcubic} ]
%MaxFunEvals - Maximum number of function evaluations allowed
%                     [ positive integer ]
%MaxIter - Maximum number of iterations allowed [ positive scalar ]
%MaxNodes - Maximum number of nodes to be explored
%           [ positive scalar | {1000*NumberOfVariables} ]
%MaxPCGIter - Maximum number of PCG iterations allowed [ positive integer ]
%MaxRLPIter - Maximum number of iterations for solving LP relaxation
%             problems [ positive scalar | {100*NumberOfVariables} ]
%MaxSQPIter - Maximum number of QP iterations allowed
%             [ positive scalar | {10*max(NumberOfVariables,NumberOfInequalities+NumberOfBounds} ]
%MaxTime - Maximum cpu time in seconds [ positive scalar | {7200} ]
%MeritFunction - Use goal attainment/minimax merit function
%                     [ {multiobj} | singleobj ]
%MinAbsMax - Number of F(x) to minimize the worst case absolute values
%                     [ positive scalar integer | {0} ]
%NodeDisplayInterval - Node display interval [ positive scalar | {20} ]
%NodeSearchStrategy - Node search strategy [ df | {bn} ]
%NonlEqnAlgorithm - Chooses Levenberg-Marquardt or Gauss-Newton over
%                   trust-region dogleg algorithm [ {dogleg} | lm | gn ]
%OutputFcn - Name of installable output function  [ function ]
%          This output function is called by the solver after each iteration
%PrecondBandWidth - Upper bandwidth of preconditioner for PCG
%                    [ positive integer | Inf | {0} ]
%Simplex - Chooses Simplex over active-set algorithm [ on | {off}]
%TolCon - Termination tolerance on the constraint violation [ positive scalar ]
%TolFun - Termination tolerance on the function value [ positive scalar ]
%TolPCG - Termination tolerance on the PCG iteration
%         [ positive scalar | {0.1} ]
%TolRLPFun - Termination tolerance on the function value of LP relaxation
%            problems [ positive scalar | {1e-6} ]
%TolX - Termination tolerance on X [ positive scalar ]
%TolXInteger - Tolerance within which the value of an integer variable
%              is considered to be integral [ positive scalar | {1e-8} ]
%TypicalX - Typical X values [ vector ]
%
%   To see OPTIMSET parameters that are also used in MATLAB, type
%     help optimset
%
%   See also OPTIMSET, OPTIMGET.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/01 16:18:12 $

% Future options (to be implemented):
%
%ActiveConstrTol - The tolerance used to determine which constraints are
%                  active for the interior-point methods at algorithm
%                  end [ positive scalar ]
%NoStopIfFlatInfeas - Tightens a stopping condition in FMINCON medium scale, 
%                     requiring that the iterate be feasible in addition to 
%                     the objective being flat [ on | {off} ] 
%PhaseOneTotalScaling - Also scales the constraints of auxiliary LP that finds
%                       initial feasible solution in private function QPSUB
%                       instead of only scaling the constraints of the original
%                       problem [ on | {off} ]
%Preconditioner - Alternative preconditioning function for PCG [ function ]
%RelLineSrchBnd - Relative bound on the displacement between iterates in FMINCON
%                 medium scale [ positive scalar | {[]} ] 
%RelLineSrchBndDuration - Specifies the number of iterations in which RelLineSrchBnd
%                         is enforced. It has no effect if RelLineSrchBnd = []. 
%                         [ positive scalar | {1} ]
%ShowStatusWindow - Show window of performance statistics


% This list only includes the options not in MATLAB; see optimset for the rest
fprintf('         BranchStrategy: [ mininfeas | {maxinfeas} ]\n');
fprintf('        DerivativeCheck: [ on | {off} ]\n');
fprintf('            Diagnostics: [ on | {off} ]\n');
fprintf('          DiffMaxChange: [ positive scalar {1e-1} ]\n');
fprintf('          DiffMinChange: [ positive scalar {1e-8} ]\n');
fprintf('      GoalsExactAchieve: [ positive scalar | {0} ]\n');
fprintf('             GradConstr: [ on | {off} ]\n');
fprintf('                GradObj: [ on | {off} ]\n');
fprintf('                Hessian: [ on | {off} ]\n');
fprintf('               HessMult: [ function | {[]} ]\n');
fprintf('            HessPattern: [ sparse matrix | {sparse(ones(NumberOfVariables))} ]\n');
fprintf('             HessUpdate: [ dfp | steepdesc | {bfgs} ]\n');
fprintf('        InitialHessType: [ identity | {scaled-identity} | user-supplied ]\n');
fprintf('      InitialHessMatrix: [ scalar | vector | {[]} ]\n');
fprintf('               Jacobian: [ on | {off} ]\n');
fprintf('              JacobMult: [ function | ([]) ]\n');
fprintf('           JacobPattern: [ sparse matrix | {sparse(ones(Jrows,Jcols))} ]\n');
fprintf('             LargeScale: [ {on} | off ]\n');
fprintf('     LevenbergMarquardt: [ on | off ]\n');
fprintf('         LineSearchType: [ cubicpoly | {quadcubic} ]\n');
fprintf('               MaxNodes: [ positive scalar | {1000*NumberOfVariables} ]\n');
fprintf('             MaxPCGIter: [ positive scalar | {max(1,floor(NumberOfVariables/2))} ]\n');
fprintf('             MaxRLPIter: [ positive scalar | {100*NumberOfVariables} ]\n');
fprintf('             MaxSQPIter: [ positive scalar | {10*max(NumberOfVariables,NumberOfInequalities+NumberOfBounds)} ]\n');
fprintf('                MaxTime: [ positive scalar | {7200} ]\n');
fprintf('          MeritFunction: [ singleobj | {multiobj} ]\n');
fprintf('              MinAbsMax: [ positive scalar | {0} ]\n');
fprintf('    NodeDisplayInterval: [ positive scalar | {20} ]\n');
fprintf('     NodeSearchStrategy: [ df | {bn} ]\n');
fprintf('       NonlEqnAlgorithm: [ {dogleg} | lm | gn ]\n');
fprintf('       PrecondBandWidth: [ positive scalar | {0} | Inf ]\n');
fprintf('                Simplex: [ on | {off} ]\n');
fprintf('                 TolCon: [ positive scalar ]\n');
fprintf('                 TolPCG: [ positive scalar | {0.1} ]\n');
fprintf('              TolRLPFun: [ positive scalar | {1e-6} ]\n');
fprintf('            TolXInteger: [ positive scalar | {1e-8} ]\n');
fprintf('               TypicalX: [ vector | {ones(NumberOfVariables,1)} ]\n');

