function [x,Fvec,JAC,EXITFLAG,OUTPUT,msg]=...
  trustnleqn(funfcn,x,verbosity,gradflag,options,defaultopt,Fvec,JAC,...
       YDATA,JACfindiff,varargin)
%TRUSTNLEQN Trust-region dogleg nonlinear systems of equation solver.
%
%   TRUSTNLEQN solves a system of nonlinear equations using a dogleg trust
%   region approach.  The algorithm implemented is similar in nature
%   to the FORTRAN program HYBRD1 of J.J. More', B.S.Garbow and K.E. 
%   Hillstrom, User Guide for MINPACK 1, Argonne National Laboratory, 
%   Rept. ANL-80-74, 1980, which itself was based on the program CALFUN 
%   of M.J.D. Powell, A Fortran subroutine for solving systems of
%   nonlinear algebraic equations, Chap. 7 in P. Rabinowitz, ed.,
%   Numerical Methods for Nonlinear Algebraic Equations, Gordon and
%   Breach, New York, 1970.

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.4 $  $Date: 2004/02/07 19:13:46 $
%   Richard Waltz, June 2001
%
% NOTE: 'x' passed in and returned in matrix form.
%       'Fvec' passed in and returned in vector form.
%
% Throughout this routine 'x' and 'F' are matrices while
% 'xvec', 'xTrial', 'Fvec' and 'FTrial' are vectors. 
% This was done for compatibility with the 'fsolve.m' interface.

% Define some sizes.
xvec = x(:);         % vector representation of x
nfnc = length(Fvec);  
nvar = length(xvec);

% Get user-defined options.
[maxfunc,maxit,tolf,tolx,derivCheck,DiffMinChange,...
     DiffMaxChange,mtxmpy,typx,giventypx,JACfindiff,structure,outputfcn] = ...
     getOpts(nfnc,nvar,options,defaultopt,gradflag);
if giventypx    % scaling featured only enabled when typx values provided
  scale = true;    
else
  scale = false;
end
broyden = false;    % broyden feature will be chosen by user in the future
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
end
stop = false;

% Initialize local arrays.
d       = zeros(nvar,1);
scalMat = ones(nvar,1); 
grad    = zeros(nvar,1);
JACd    = zeros(nvar,1);
xTrial  = zeros(nvar,1);
F       = zeros(size(x));
FTrial  = zeros(nvar,1);
if derivCheck
    if gradflag, 
        JACfindiff = JAC; % Initialize finite difference Jacobian with 
    else                % structure given by real Jacobian 
        if verbosity > 0              
            warning('optim:trustnleqn:DerivativeCheckOff', ...
                    ['DerivativeCheck on but analytic Jacobian not provided;\n' ...
                     '         turning DerivativeCheck off.'])
        end
        derivCheck = false;
    end
end

% Initialize some trust region parameters.
Delta    = 1e0;
DeltaMax = 1e10;
eta1     = 0.05;
eta2     = 0.9;
alpha1   = 2.5;
alpha2   = 0.25;

% Other initializations.
iter = 0;
numFevals = 1;   % computed in fsolve.m
numFDfevals = 0;
if gradflag
  numJevals = 1; % computed in fsolve.m
else
  numJevals = 0;
end 
done = false;
stepAccept = true;
numReject = 0;
exitStatus = 0;
normd = 0.0e0;
normdscal = 0.0e0;
scalemin = eps;
scalemax = 1/scalemin;
objold = 1.0e0;
broydenJac = false;
broydenStep = false;
obj = 0.5*Fvec'*Fvec;  % Initial Fvec computed in fsolve.m

% Compute initial finite difference Jacobian, objective and gradient.
if derivCheck || ~gradflag
  if structure && issparse(JACfindiff)
    group = color(JACfindiff); % only do color if given some structure and sparse
  else
    group = 1:nvar;
  end 
  [JACfindiff,numFDfevals] = sfdnls(x,Fvec,JACfindiff,group,[], ...
                      DiffMinChange,DiffMaxChange,funfcn{3},YDATA,varargin{:});
  numFevals = numFevals + numFDfevals;
end

switch funfcn{1}
case 'fun'
  JAC = JACfindiff;
case 'fungrad'         % Initial Jacobian computed in fsolve.m
  if derivCheck, graderr(JACfindiff,JAC,funfcn{3}); end
case 'fun_then_grad'   % Initial Jacobian computed in fsolve.m
  if derivCheck, graderr(JACfindiff,JAC,funfcn{4}); end
otherwise
  error('optim:trustnleqn:UndefinedCalltype','Undefined calltype in FSOLVE.')
end 
grad = feval(mtxmpy,JAC,Fvec,-1,varargin{:});  % compute JAC'*Fvec
normgradinf = norm(grad,inf);

% Print header.
header = sprintf(['\n                                         Norm of      First-order   Trust-region\n',...
                    ' Iteration  Func-count     f(x)          step         optimality    radius']);
formatstr = ' %5.0f      %5.0f   %13.6g  %13.6g   %12.3g    %12.3g';
if verbosity > 1
  disp(header);
end

% Initialize the output function.
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xvec,xOutputfcn,'init',iter, ...
        numFevals,Fvec,obj,[],[],[],Delta,stepAccept,varargin{:});
    if stop
        [x,Fvec,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
        return;
    end
end

% If using Broyden updates need to provide an initial inverse Jacobian.
if broyden, 
  ws = warning('off');
  invJAC = JAC\speye(nfnc);
  warning(ws);
else
  invJAC = [];
end

% Compute initial diagonal scaling matrix.
if scale
  if giventypx && ~isempty(typx) % scale based on typx values
    typx(typx==0) = 1; % replace any zero entries with ones
    scalMat = 1./abs(typx);
  else         % scale based on norm of the Jacobian (not currently active)  
    scalMat = getscalMat(nvar,JAC,scalemin,scalemax);
  end
end

% Display initial iteration information.
formatstr0 = ' %5.0f      %5.0f   %13.6g                  %12.3g    %12.3g';
% obj is 0.5*F'*F but want to display F'*F
iterOutput0 = sprintf(formatstr0,iter,numFevals,2*obj,normgradinf,Delta);
if verbosity > 1
   disp(iterOutput0);
end
% OutputFcn call
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xvec,xOutputfcn,'iter',iter, ...
        numFevals,Fvec,obj,normd,grad,normgradinf,Delta,stepAccept,varargin{:});
    if stop
        [x,Fvec,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
        return;
    end
end


% Test convergence at initial point.
[exitStatus,done,EXITFLAG,msg] = testStop(normgradinf,tolf,tolx,...
     stepAccept,iter,maxit,numFevals,maxfunc,Delta,normd,...
     obj,objold,d,xvec,broydenStep);

% Beginning of main iteration loop.
while ~done
  iter = iter + 1;

  % Compute step, d, using dogleg approach.
  [d,quadObj,normd,normdscal,illcondition] = ...
       dogleg(nvar,nfnc,Fvec,JAC,grad,Delta,d,invJAC,broyden, ...
       scalMat,mtxmpy,varargin);
  if broydenJac 
    broydenStep = true; 
  else
    broydenStep = false;
  end

  % Compute the model reduction given by d (pred).
  pred = -quadObj;

  % Compute the trial point, xTrial.
  xTrial = xvec + d;

  % Evaluate nonlinear equations and objective at trial point.
  x(:) = xTrial; % reshape xTrial to a matrix for evaluations. 
  switch funfcn{1}
  case 'fun'
    F = feval(funfcn{3},x,varargin{:});
  case 'fungrad'
    [F,JACTrial] = feval(funfcn{3},x,varargin{:});
    numJevals = numJevals + 1;
  case 'fun_then_grad'
    F = feval(funfcn{3},x,varargin{:}); 
  otherwise
    error('optim:trustnleqn:UndefinedCalltype','Undefined calltype in FSOLVE.')
  end  
  numFevals = numFevals + 1;
  FTrial = F(:); % make FTrial a vector
  objTrial = 0.5*FTrial'*FTrial; 

  % Compute the actual reduction given by xTrial (ared).
  ared = obj - objTrial;

  % Compute ratio = ared/pred.
  if pred <= 0 % reject step
    ratio = 0;
  else
    ratio = ared/pred;
  end
  
  % OutputFcn call
  if haveoutputfcn
      stop = feval(outputfcn,xOutputfcn,optimValues,'interrupt',varargin{:});
      if stop  % Stop per user request.
          [x,Fvec,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
          return;
      end
  end
  
  if ratio > eta1 % accept step.

    % Update information.
    if broyden, numReject = 0; Fdiff = FTrial - Fvec; end
    xvec = xTrial; Fvec = FTrial; objold = obj; obj = objTrial;
    x(:) = xvec; % update matrix representation

    % Compute JAC at new point. (already computed with F if 'fungrad')

    % Broyden update.
    if broyden && ~illcondition
      normd2 = normd^2;
      denom = d'*(invJAC*Fdiff);
      if abs(denom) < 0.1*normd2
        alpha = 0.8;
        denom = alpha*denom + (1-alpha)*normd2;
      else
        alpha = 1.0;
      end  
      JACd = feval(mtxmpy,JAC,d,1,varargin{:});  % compute JAC*d        
      JACbroyden = JAC + alpha*((Fdiff - JACd)*d')/(normd^2);
      invJAC = invJAC + alpha*((d - invJAC*Fdiff)*(d'*invJAC))/denom;
    end

    % Compute sparse finite difference Jacobian if needed.
    if ~gradflag && (~broyden || (broyden && illcondition))
      [JACfindiff,numFDfevals] = sfdnls(x,Fvec,JACfindiff,group,[], ...
                  DiffMinChange,DiffMaxChange,funfcn{3},YDATA,varargin{:});
      numFevals = numFevals + numFDfevals;
    end

    if broyden && ~illcondition
      JAC = JACbroyden; broydenJac = true;
    else
      switch funfcn{1}
      case 'fun'
        JAC = JACfindiff;
      case 'fungrad'
        JAC = JACTrial;
      case 'fun_then_grad'
        JAC = feval(funfcn{4},x,varargin{:});
        numJevals = numJevals + 1;
      otherwise
        error('optim:trustnleqn:UndefinedCalltype','Undefined calltype in FSOLVE.')
      end
      broydenJac = false;
    end 
    grad = feval(mtxmpy,JAC,Fvec,-1,varargin{:});  % compute JAC'*Fvec     
    normgradinf = norm(grad,inf);

    if broyden && illcondition % update inverse Jacobian
      ws = warning('off');
      invJAC = JAC\speye(nfnc);
      warning(ws);
    end

    % Update internal diagonal scaling matrix (dynamic scaling).
    if scale && ~giventypx
      scalMat = getscalMat(nvar,JAC,scalemin,scalemax);
    end

    stepAccept = true;

  else % reject step.
 
    if broyden, numReject = numReject + 1; end
    stepAccept = false;

  end 

  % Print iteration statistics.
  if verbosity > 1
      % obj is 0.5*F'*F but want to display F'*F
      iterOutput = sprintf(formatstr,iter,numFevals,2*obj,normd,normgradinf,Delta);
      disp(iterOutput);
  end
  % OutputFcn call
  if haveoutputfcn
      [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xvec,xOutputfcn,'iter',iter, ...
        numFevals,Fvec,obj,normd,grad,normgradinf,Delta,stepAccept,varargin{:});
      if stop
          [x,Fvec,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
          return;
      end
  end

  % Update trust region radius.
  Delta = updateDelta(Delta,ratio,normdscal,eta1,eta2,...
                      alpha1,alpha2,DeltaMax);

  % Check for termination.
  [exitStatus,done,EXITFLAG,msg] = testStop(normgradinf,tolf,tolx,...
       stepAccept,iter,maxit,numFevals,maxfunc,Delta,normd,...
       obj,objold,d,xvec,broydenStep);
  
  % If using Broyden updating to compute the Jacobian and the last two steps
  % were rejected or the Broyden Jacobian is ill-conditioned this may indicate 
  % that the Jacobian approximation is not accurate.  Compute a new finite 
  % difference or analytic Jacobian.  
  if broydenJac
    if (numReject == 2 && ~done) || (illcondition && ~done)
      EXITFLAG = 0;
      % Compute new finite difference or analytic Jacobian.
      x(:) = xvec; % reset matrix representation of x to current value in xvec
      if ~gradflag
        [JACfindiff,numFDfevals] = sfdnls(x,Fvec,JACfindiff,group,[], ...
                   DiffMinChange,DiffMaxChange,funfcn{3},YDATA,varargin{:});
        numFevals = numFevals + numFDfevals;
      end
      switch funfcn{1}
      case 'fun'
        JAC = JACfindiff;
      case 'fungrad'
        [F,JAC] = feval(funfcn{3},x,varargin{:});
        numFevals = numFevals + 1;
        numJevals = numJevals + 1;
      case 'fun_then_grad'
        JAC = feval(funfcn{4},x,varargin{:});
        numJevals = numJevals + 1;
      otherwise
        error('optim:trustnleqn:UndefinedCalltype','Undefined calltype in FSOLVE.')
      end
      grad = feval(mtxmpy,JAC,Fvec,-1,varargin{:});  % compute JAC'*Fvec
      normgradinf = norm(grad,inf);
      broydenJac = false;
      ws = warning('off');
      invJAC = JAC\speye(nfnc);
      warning(ws);
      if scale && ~giventypx     % Update internal scaling matrix.
        scalMat = getscalMat(nvar,JAC,scalemin,scalemax);
      end
    end
  end
end

if haveoutputfcn
    [xOutputfcn, optimValues] = callOutputFcn(outputfcn,xvec,xOutputfcn,'done',iter, ...
        numFevals,Fvec,obj,normd,grad,normgradinf,Delta,stepAccept,varargin{:});
    % Optimization done, so ignore "stop"
end


% Optimization is finished.

% Assign output statistics.
OUTPUT.iterations = iter;
OUTPUT.funcCount = numFevals;
OUTPUT.algorithm = 'trust-region dogleg';
OUTPUT.firstorderopt = normgradinf;

% TRUSTNLEQN finished

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maxfunc,maxit,tolf,tolx,derivCheck,DiffMinChange,...
          DiffMaxChange,mtxmpy,typx,giventypx,JACfindiff,structure,outputfcn] = ...
          getOpts(nfnc,nvar,options,defaultopt,gradflag)
%getOpts gets the user-defined options for TRUSTNLEQN.

% Both Medium and Large-Scale options.
maxfunc = optimget(options,'MaxFunEvals',defaultopt,'fast');
if ischar(maxfunc)
  if isequal(lower(maxfunc),'100*numberofvariables')
    maxfunc = 100*nvar;
  else
    error('optim:trustnleqn:InvalidMaxFunEvals', ...
          'Option ''MaxFunEvals'' must be an integer value if not the default.')
  end
end
maxit = optimget(options,'MaxIter',defaultopt,'fast');
tolf = optimget(options,'TolFun',defaultopt,'fast');
tolx = optimget(options,'TolX',defaultopt,'fast');
if isfield(options,'OutputFcn')
    outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
else
    outputfcn = defaultopt.OutputFcn;
end

% Medium-Scale only options.
derivCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');
DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');

% Large-Scale only options.
mtxmpy = optimget(options,'JacobMult',defaultopt,'fast');
if isempty(mtxmpy)
  mtxmpy = @atamult;
end
giventypx = true;
typx = optimget(options,'TypicalX',defaultopt,'fast');
if ischar(typx)
  if isequal(lower(typx),'ones(numberofvariables,1)')
    typx = ones(nvar,1);
    giventypx = false;
  else
    error('optim:trustnleqn:InvalidTypicalX', ...
          'Option ''TypicalX'' must be an integer value if not the default.')
  end
end
structure = true;
if ~gradflag
  JACfindiff = optimget(options,'JacobPattern',defaultopt,'fast');
  if ischar(JACfindiff) 
    if isequal(lower(JACfindiff),'sparse(ones(jrows,jcols))')
      JACfindiff = sparse(ones(nfnc,nvar));
      structure = false;
    else
      error('optim:trustnleqn:InvalidJacobPattern', ...
            'Option ''JacobPattern'' must be a matrix if not the default.')
    end
  end
else
  JACfindiff = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [exitStatus,done,EXITFLAG,msg] = testStop(normgradinf,tolf,tolx,...
     stepAccept,iter,maxit,numFevals,maxfunc,Delta,normd,...
     obj,objold,d,xvec,broydenStep)
%testStop checks the termination criteria for TRUSTNLEQN.

exitStatus = 0;
done = false;
EXITFLAG = 0;
msg = '';

% Check termination criteria.
if stepAccept && normgradinf < tolf
  msg = sprintf('Optimization terminated: first-order optimality is less than options.TolFun.');
  exitStatus = 1;
  done = true;
  EXITFLAG = 1;
elseif iter > 1 && max(abs(d)./(abs(xvec)+1)) < max(tolx^2,eps) 
   if 2*obj < sqrt(tolf) % fval'*fval < sqrt(tolf)
      msg = sprintf(['Optimization terminated: norm of relative change in X is less\n' ...
                     ' than max(options.TolX^2,eps) and  sum-of-squares of function \n' ...
                     ' values is less than sqrt(options.TolFun).']);
      exitStatus = 2;
      EXITFLAG = 2;
   else
      msg = sprintf(['Optimizer appears to be converging to a point which is not a root.\n',...
         ' Norm of relative change in X is less than max(options.TolX^2,eps) but\n',...
         ' sum-of-squares of function values is greater than or equal to sqrt(options.TolFun)\n',...  
         ' Try again with a new starting guess.']);
      exitStatus = 3;
      EXITFLAG = -2;
    end
    done = true;
elseif iter > 1 && stepAccept && normd < 0.9*Delta ...
                && abs(objold-obj) < max(tolf^2,eps)*(1+abs(objold))
  if 2*obj < sqrt(tolf) % fval'*fval < sqrt(tolf)
     msg = sprintf(['Optimization terminated: relative function value changing by less\n' ...
                    ' than max(options.TolFun^2,eps) and sum-of-squares of function\n' ... 
                    ' values is less than sqrt(options.TolFun).']);
     exitStatus = 4;
     EXITFLAG = 3;
  else
      msg = sprintf(['Optimizer appears to be converging to a point which is not a root.\n',...
         ' Relative function value changing by less than max(options.TolFun^2,eps) but\n',...
         ' sum-of-squares of function values is greater than or equal to sqrt(options.TolFun)\n',...  
        ' Try again with a new starting guess.']);
      exitStatus = 5;
      EXITFLAG = -2; 
  end
  done = true;
elseif Delta < 2*eps
  msg = sprintf(['Optimization terminated: no further progress can be made.\n',...
         ' Trust-region radius less than 2*eps.\n',...
         ' Problem may be ill-conditioned or Jacobian may be inaccurate.\n',...
         ' Try using exact Jacobian or check Jacobian for errors.']);
  exitStatus = 6;
  done = true;
  EXITFLAG = -3;
elseif iter >= maxit
  msg = sprintf(['Maximum number of iterations reached:\n',...
                 ' increase options.MaxIter.']);
  exitStatus = 7;
  done = true;
  EXITFLAG = 0;
elseif numFevals >= maxfunc
  msg = sprintf(['Maximum number of function evaluations reached:\n',...
                 ' increase options.MaxFunEvals.']);
  exitStatus = 8;
  done = true;
  EXITFLAG = 0;  
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Delta = updateDelta(Delta,ratio,normdscal,eta1,eta2,...
                             alpha1,alpha2,DeltaMax)
%updateDelta updates the trust region radius in TRUSTNLEQN.
%
%   updateDelta updates the trust region radius based on the value of
%   ratio and the norm of the scaled step.

if ratio < eta1
  Delta = alpha2*normdscal;
elseif ratio >= eta2
  Delta = max(Delta,alpha1*normdscal);
end
Delta = min(Delta,DeltaMax);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scalMat = getscalMat(nvar,JAC,scalemin,scalemax)
%getscalMat computes the scaling matrix in TRUSTNLEQN.
%
%   getscalMat computes the scaling matrix based on the norms 
%   of the columns of the Jacobian.

scalMat = ones(nvar,1);
for i=1:nvar
  scalMat(i,1) = norm(JAC(:,i));
end
scalMat(scalMat<scalemin) = scalemin;  % replace small entries
scalMat(scalMat>scalemax) = scalemax;  % replace large entries

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xvec,xOutputfcn,state,iter,numFevals, ...
    Fvec,obj,normd,grad,normgradinf,Delta,stepAccept,varargin)
% CALLOUTPUTFCN assigns values to the struct OptimValues and then calls the
% outputfcn.  
%
% state - can have the values 'init','iter', or 'done'. 
% We do not handle the case 'interrupt' because we do not want to update
% xOutputfcn or optimValues (since the values could be inconsistent) before calling
% the outputfcn; in that case the outputfcn is called directly rather than
% calling it inside callOutputFcn.

% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.

optimValues.iteration = iter;
optimValues.funccount = numFevals;
optimValues.fval = Fvec;
optimValues.residual = 2*obj;
optimValues.stepsize = normd; 
optimValues.gradient = grad; 
optimValues.firstorderopt = normgradinf;
optimValues.trustregionradius = Delta;
optimValues.stepaccept = stepAccept;
optimValues.procedure = '';
xOutputfcn(:) = xvec;  % Set xvec to have user expected size

switch state
    case {'iter','init'}
        stop = feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    case 'done'
        stop = false;
        feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    otherwise
        error('optim:trustnleqn:InvalidCALLOUTPUTFCN','Unknown state in CALLOUTPUTFCN.')
end

%--------------------------------------------------------------------------
function [x,Fvec,JAC,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT sets the outputs arguments to be the values at the last call
% of the outputfcn during an 'iter' call (when these values were last known to
% be consistent). 

x = xOutputfcn; 
Fvec = optimValues.fval;
EXITFLAG = -1; 
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.algorithm = 'trust-region dogleg';
OUTPUT.firstorderopt = optimValues.firstorderopt; 
JAC = []; % May be in an inconsistent state
msg = 'Optimization terminated prematurely by user.';


