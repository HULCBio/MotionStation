function [X,resnorm,residual,exitflag,output,lambda,convmsg]=cflsqlin(C,d,lb,ub,fitopt,varargin)
%CFLSQLIN Constrained linear least squares.
%   X=CFLSQLIN(C,d,lb,ub) solves the least-squares problem
%
%           min  0.5*(NORM(C*x-d)).^2       subject to    lb <= x <= ub
%            x
%
%   where C is m-by-n.
%
%   Use empty matrices for lb and ub if no bounds exist. Set 
%   lb(i) = -Inf if X(i) is unbounded below; set ub(i) = Inf if 
%   X(i) is unbounded above.
%
%   X=CFLSQLIN(C,d,lb,ub,OPTIONS) minimizes with the default 
%   optimization parameters replaced by values in the fitoptions object OPTIONS.
%
%   [X,RESNORM]=CFLSQLIN(C,d,lb,ub) returns the value of the squared 2-norm of the
%   residual: norm(C*X-d)^2.
%
%   [X,RESNORM,RESIDUAL]=CFLSQLIN(C,d,lb,ub) returns the residual: C*X-d.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG] = CFLSQLIN(C,d,lb,ub) returns an EXITFLAG that 
%   describes the exit condition of CFLSQLIN.  
%   If EXITFLAG is:
%      > 0 then CFLSQLIN converged with a solution X.
%      0   then the maximum number of iterations was exceeded (only occurs
%           with large-scale method).
%      < 0 then the problem is unbounded, infeasible, or 
%           CFLSQLIN failed to converge with a solution X. 
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = CFLSQLIN(C,d,lb,ub) returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations,
%   the type of algorithm used in OUTPUT.algorithm.
%
%   [x,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA]=CFLSQLIN(C,d,A,b) returns the 
%   set of Lagrangian multipliers LAMBDA, at the solution: LAMBDA.ineqlin 
%   for the linear inequalities C, LAMBDA.eqlin for the linear equalities Ceq, 
%   LAMBDA.lower for LB, and LAMBDA.upper for UB.

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.7.2.2 $  $Date: 2004/02/01 21:43:19 $

defaultopt = struct('Display','notify',...
   'TolFun',100*eps,...
   'LargeScale','off','MaxIter',[]);
convmsg = [];

% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(C,'defaults')
   X = defaultopt;
   return
end

if nargin < 2, 
    error('curvefit:cflsqlin:twoArgsRequired', ...
          'CFLSQLIN requires two input arguments.');
end

% Handle missing arguments
if nargin < 5, fitopt = [];
      if nargin < 4, ub=[]; 
         if nargin < 3, lb = []; 
                     end, end, end
% Set up constant strings
medium =  'Active-set';
unconstrained = 'QR factorization and solve';

% convert FITOPTIONS to OPTIMOPTIONS
options = optimset(get(fitopt));

% Options setup
switch optimget(options,'Display',defaultopt,'fast')
case {'notify'}
   verbosity = 1;
case {'off','none'}
   verbosity = 0;
case 'iter'
   verbosity = 3;
case 'final'
   verbosity = 2;
otherwise
   verbosity = 2;
end

if isempty(C) || isempty(d)
   error('curvefit:cflsqlin:invalidArgs', ...
         'The first two arguments to CFLSQLIN cannot be empty matrices.')
else
   numberOfVariables = size(C,2);
end

rows = size(C,1);
if length(d) ~= rows
   error('curvefit:cflsqlin:invalidNumberOfRows', ...
         'The number of rows in C must be equal to the length of d.');
end

X0=zeros(numberOfVariables,1);

% Set d, b and X to be column vectors
d = d(:);
X0 = X0(:);

% Test if C is all zeros or empty
if  norm(C,'inf')==0 || isempty(C)
   C=0; 
end

caller = 'lsqlin';

% Test for constraints
if all(isinf([lb;ub]))
    output.algorithm = unconstrained;
    % If interior-point chosen and no A,Aeq and C isn't short and fat, then call sllsbox   
else
    output.algorithm = medium;
end

switch output.algorithm;
case 'QR factorization and solve'
   X = C\d;
   residual = C*X-d;
   resnorm = sum(residual.*residual);
   lambda = [];
   exitflag = 1;
   output.iterations = 0;
   output.algorithm = unconstrained;
case 'Active-set'
    [X,lambdaqp,exitflag,output]= ...
        lsqsub(full(C),d,[],[],lb,ub,X0,0,verbosity,caller,0,numberOfVariables,options,defaultopt);
    output.algorithm = medium;  
    residual = C*X-d;
    resnorm = sum(residual.*residual);
    
    if (exitflag ==1 )
        msg = xlate('Optimization terminated successfully.');   
    end
    if verbosity > 1 || ( verbosity > 0 && exitflag <=0 )
        disp(msg);
    end
    
end

if isequal(output.algorithm , medium)
   llb = length(lb); 
   lub = length(ub);
   lambda.lower = zeros(llb,1);
   lambda.upper = zeros(lub,1);
   arglb = ~isinf(lb); lenarglb = nnz(arglb);
   argub = ~isinf(ub); lenargub = nnz(argub);
   lambda.lower(arglb) = lambdaqp(1:lenarglb);
   lambda.upper(argub) = lambdaqp(lenarglb+1:lenarglb+lenargub);
elseif isequal(output.algorithm,'slash')
   lambda.lower = [];
   lambda.upper = [];
end
