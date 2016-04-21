% Optimization Toolbox
% Version 3.0 (R14) 05-May-2004 
%
% Nonlinear minimization of functions.
%   fminbnd      - Scalar bounded nonlinear function minimization.
%   fmincon      - Multidimensional constrained nonlinear minimization.
%   fminsearch   - Multidimensional unconstrained nonlinear minimization, 
%                   by Nelder-Mead direct search method.
%   fminunc      - Multidimensional unconstrained nonlinear minimization.
%   fseminf      - Multidimensional constrained minimization, semi-infinite 
%                  constraints.
%
% Nonlinear minimization of multi-objective functions.
%   fgoalattain  - Multidimensional goal attainment optimization 
%   fminimax     - Multidimensional minimax optimization.
%        
% Linear least squares (of matrix problems).
%   lsqlin       - Linear least squares with linear constraints.
%   lsqnonneg    - Linear least squares with nonnegativity constraints.
%
% Nonlinear least squares (of functions).
%   lsqcurvefit  - Nonlinear curvefitting via least squares (with bounds).
%   lsqnonlin    - Nonlinear least squares with upper and lower bounds.
%
% Nonlinear zero finding (equation solving).
%   fzero        - Scalar nonlinear zero finding.
%   fsolve       - Nonlinear system of equations solve (function solve).
%
% Minimization of matrix problems.
%   bintprog     - Binary integer (linear) programming.
%   linprog      - Linear programming.
%   quadprog     - Quadratic programming.
%
% Controlling defaults and options.
%   optimset     - Create or alter optimization OPTIONS structure. 
%   optimget     - Get optimization parameters from OPTIONS structure. 
%
% Demonstrations of large-scale methods.
%   circustent   - Quadratic programming to find shape of a circus tent.
%   molecule     - Molecule conformation solution using unconstrained nonlinear
%                  minimization.
%   optdeblur    - Image deblurring using bounded linear least-squares.
%
% Demonstrations of medium-scale methods.
%   tutdemo      - Tutorial walk-through.
%   goaldemo     - Goal attainment.
%   dfildemo     - Finite-precision filter design (requires Signal Processing
%                  Toolbox).
%   datdemo      - Fitting data to a curve.
%   officeassign - Binary integer programming to solve the office assignment
%                  problem.
% 
% Medium-scale examples from User's Guide
%   objfun       - nonlinear objective
%   confun       - nonlinear constraints
%   objfungrad   - nonlinear objective with gradient
%   confungrad   - nonlinear constraints with gradients
%   confuneq     - nonlinear equality constraints
%   optsim.mdl   - Simulink model of nonlinear plant process
%   optsiminit   - init file for optisim.mdl
%   runtracklsq  - demonstrates multiobjective function using LSQNONLIN
%   runtrackmm   - demonstrates multiobjective function using FMINIMAX 
%
% Large-scale examples from User's Guide
%   nlsf1         - nonlinear equations objective with Jacobian
%   nlsf1a        - nonlinear equations objective 
%   nlsdat1       - MAT-file of Jacobian sparsity pattern (see nlsf1a)
%   brownfgh      - nonlinear minimization objective with gradient and Hessian
%   brownfg       - nonlinear minimization objective with gradient 
%   brownhstr     - MAT-file of Hessian sparsity pattern (see brownfg)
%   tbroyfg       - nonlinear minimization objective with gradient
%   tbroyhstr     - MAT-file of Hessian sparsity pattern (see tbroyfg)
%   browneq       - MAT-file of Aeq and beq sparse linear equality constraints
%   runfleq1      - demonstrates 'HessMult' option for FMINCON with equalities
%   brownvv       - nonlinear minimization with dense structured Hessian
%   hmfleq1       - Hessian matrix product for brownvv objective
%   fleq1         - MAT-file of V, Aeq, and beq for brownvv and hmfleq1 
%   qpbox1        - MAT-file of quadratic objective Hessian sparse matrix
%   runqpbox4     - demonstrates 'HessMult' option for QUADPROG with bounds
%   runqpbox4prec - demonstrates 'HessMult' and TolPCG options for QUADPROG
%   qpbox4        - MAT-file of quadratic programming problem matrices
%   runnls3       - demonstrates 'JacobMult' option for LSQNONLIN 
%   nlsmm3        - Jacobian multiply function for runnls3/nlsf3a objective
%   nlsdat1       - MAT-file of problem matrices for runnls3/nlsf3a objective
%   runqpeq5      - demonstrates 'HessMult' option for QUADPROG with equalities
%   qpeq5         - MAT-file of quadratic programming matrices for runqpeq5
%   particle      - MAT-file of linear least squares C and d sparse matrices
%   sc50b         - MAT-file of linear programming example
%   densecolumns  - MAT-file of linear programming example
%

% Internally Used Utility Routines
%
%   Large-scale preconditioners
%   aprecon      - default banded preconditioner for least-squares problems
%   hprecon      - default banded preconditioner for minimization problems
%   pceye        - diagonal preconditioner based on scaling matrices
%
%   Large-scale utility routines
%   fzmult       - Multiplication with fundamental nullspace basis
%   gangstr      - Zero out 'small' entries subject to structural rank
%
%   Cubic interpolation routines
%   cubic        - interpolates four points to find the maximum value
%   cubici1      - interpolates 2 pts and gradients to estimate minimum
%   cubici2      - interpolates 3 points and 1 gradient
%   cubici3      - interpolates 2 pts and gradients to find step and min
%
%   Quadratic interpolation routines
%   quad2        - interpolates three points to find the maximum value
%   quadi        - interpolates three points to estimate minimum
%
%   Demonstration utility routines
%   elimone          - eliminates a variable (used by dfildemo)
%   filtobj          - frequency response norm (used by dfildemo)
%   filtcon          - frequency response roots (used by dfildemo)
%   fitfun           - return error norm in fitting data (used by datdemo)
%   fitfun2          - return vector of errors in fitting data (used by datdemo)
%   tentdata         - MAT-file of data for circustent demo
%   optdeblur        - MAT-file of data for optdeblur demo
%   molecule         - MAT-file of data for molecule demo
%   mmole            - molecular distance problem (used by molecule demo)
%   bandem           - banana function minimization demonstration
%   plotdatapoints   - helper plotting function (used by datdemo)
%   fitfun2outputfcn - output function (used by datdemo)
%
%   Semi-infinite utility routines
%   semicon      - translates semi-infinite constraints to constrained problem
%   findmax      - interpolates the maxima in a vector of data 
%   findmax2     - interpolates the maxima in a matrix of data 
%   v2sort       - sorts two vectors and then removes missing elements
%
%   Goal-attainment utility routines
%   goalfun      - translates goal-attainment problem to constrained problem
%   goalcon      - translates constraints in goal-attainment problem
%
%   Other
%   color                 - column partition for sparse finite differences
%   graderr               - used to check gradient discrepancy 
%   searchq               - line search routine for fminu and leastsq functions
%   sfd                   - sparse Hessian via finite gradient differences
%   sfdnls                - sparse Jacobian via finite differences
%   optimoptions          - display option names and values for the options in the
%                           Optimization Toolbox but not in MATLAB
%   optimoptioncheckfield - check validity of field contents
%   optimoptiongetfields  - fieldnames of options in Optimization Toolbox not in MATLAB



%   Copyright 1990-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.50.4.6  $Date: 2004/04/20 23:19:15 $
