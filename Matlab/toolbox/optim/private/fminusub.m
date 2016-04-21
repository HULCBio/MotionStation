function [x,f,grad,hessian,exitflag,output] = ...
    fminusub(funfcn,x,verbosity,options,defaultopt,f,grad,hessian,computeHessian,varargin)
%
% FMINUSUB finds the minimizer x of a function funfcn of several variables. On 
% input, x is the initial guess, f, grad and hessian are the values of the function,
% the gradient and the matrix of second derivatives respectively, all evaluated
% at the initial guess x. On output, x is the computed solution, f, grad and 
% hessian are the values of the function, the gradient and the matrix of second 
% derivatives respectively, all evaluated at the computed solution x.
 
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.22.4.6 $  $Date: 2004/02/01 22:09:25 $

%
% Initialization
%
[xRows,xCols] = size(x); % Store original user-supplied shape
x = x(:);                % Reshape x to a column vector
numberOfVariables = length(x);
initialHessIsAScalar = [];
exitflagLnSrch = [];     % define in case x0 is solution and lineSearch never called
formatstr = ' %5.0f       %5.0f    %13.6g  %13.6g   %12.3g  %s';

% Line search parameters: rho < 1/2 and rho < sigma < 1.
% Typical values are rho = 0.01 and sigma = 0.9.
rho = 0.01; sigma = 0.9;
fminimum = f - 1e8*(1+abs(f));
tolLnSrch = 10*eps;

% Read in options
gradflag =  strcmp(optimget(options,'GradObj',defaultopt,'fast'),'on');
TolX = optimget(options,'TolX',defaultopt,'fast');

HessUpdate = optimget(options,'HessUpdate',defaultopt,'fast'); 
if isequal(HessUpdate,'gillmurray')
    warning('optim:fminusub:ObsoleteHessUpdate', ...
       ['OPTION.HessUpdate = ''gillmurray'' is obsolete and will be removed\n' ...
        ' in a future release of the Optimization Toolbox.\n' ...
        ' Setting options.HessUpdate = ''bfgs'' instead. Update your code to\n' ...
        ' avoid this warning.'])
    HessUpdate = 'bfgs';
end
InitialHessType = optimget(options,'InitialHessType',defaultopt,'fast');
InitialHessMatrix = optimget(options,'InitialHessMatrix',defaultopt,'fast');

if isequal(lower(InitialHessType),'user-supplied') 
    if isempty(InitialHessMatrix)    
        warning('optim:fminusub:ResettingToInitialHessType', ...
            ['options.InitialHessType = ''user-supplied'' but options.InitialHessMatrix = [];\n' ... 
            ' resetting InitialHessType = ''identity''.'])
        InitialHessType = 'identity';    
    else
        % Determine size of InitialHessMatrix
        [ihRows,ihCols] = size(InitialHessMatrix);
        if (ihRows==numberOfVariables && ihCols==1) || (ihRows==1 && ihCols==numberOfVariables)
          initialHessIsAScalar = false;
        elseif ihRows==1 && ihCols==1
          initialHessIsAScalar = true;          
        else
          error('optim:fminusub:InitialHessMatrixSize', ...
                  ['Option ''InitialHessMatrix'' must be a scalar or a vector', ...
                  ' of length numberOfVariables.'])
        end    
    end
end

TolFun = optimget(options,'TolFun',defaultopt,'fast');
DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');
TypicalX = optimget(options,'TypicalX',defaultopt,'fast') ;
if ischar(TypicalX)
    if isequal(lower(TypicalX),'ones(numberofvariables,1)')
        TypicalX = ones(numberOfVariables,1);
    else
        error('optim:fminusub:TypicalXNumOrDefault', ... 
              'Option ''TypicalX'' must be a numeric value if not the default.')
    end
end

maxFunEvals = optimget(options,'MaxFunEvals',defaultopt,'fast');
maxIter = optimget(options,'MaxIter',defaultopt,'fast');

if ischar(maxFunEvals)
    if isequal(lower(maxFunEvals),'100*numberofvariables')
        maxFunEvals = 100*numberOfVariables;
    else
        error('optim:fminusub:MaxFunEvalsIntOrDefault', ...
              'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end

% Output function
if isfield(options,'OutputFcn')
    outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
else
    outputfcn = defaultopt.OutputFcn;
end
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = reshape(x,xRows,xCols); 
end
stop = false;

funcCount = 1; % function evaluated in FMINUNC
iter = 0;

% Initialize output alpha: if x0 is the solution, alpha = [] is returned 
% in output structure
alpha = []; 
fOld = []; gOld = []; 
hessUpdateMsg = [];       

% Compute finite difference gradient at initial point, if needed
if ~gradflag || DerivativeCheck
  gradFd = finitedifferences(x,reshape(x,xRows,xCols),funfcn,[],[],[],f, ...
              [],[],DiffMinChange,DiffMaxChange,TypicalX,[],'all', ...
              [],[],[],[],[],[],varargin{:});
  funcCount = funcCount + numberOfVariables;

  % Gradient check
  if DerivativeCheck && gradflag
    if isa(funfcn{4},'inline')
      graderr(gradFd,grad,formula(funfcn{4}));
    else
      graderr(gradFd,grad,funfcn{4});
    end
  else
    grad = gradFd;
  end
end

% Norm of initial gradient, used in stopping tests
g0Norm = norm(grad,Inf); 

% Initialize the output function.
if haveoutputfcn
  [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'init',iter,funcCount, ...
        f,[],grad,[],varargin{:});
  if stop
    [x,f,exitflag,output,grad,H] = cleanUpInterrupt(xOutputfcn,optimValues);
    if verbosity > 0
      disp(output.message);
    end
    return;
  end
end

% Print output header
if verbosity > 1
  disp(sprintf(['                                                         Gradient''s \n',...
  ' Iteration  Func-count       f(x)        Step-size      infinity-norm']));
end

% Display 0th iteration quantities
if verbosity > 1
  disp(sprintf(' %5.0f       %5.0f    %13.6g                  %12.3g',iter,funcCount,f,g0Norm));
end

% OutputFcn call 0th iteration
if haveoutputfcn
  [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'iter',iter,funcCount, ...
        f,[],grad,[],varargin{:});
  if stop  % Stop per user request.
    [x,f,exitflag,output,grad,H] = cleanUpInterrupt(xOutputfcn,optimValues);
    if verbosity > 0
      disp(output.message);
    end
    return;
  end
end

% Check convergence at initial point
[done,exitflag,outMessage] = initialTestStop(g0Norm,TolFun,verbosity); 

% Form initial inverse Hessian approximation
if ~done                  
  H = initialQuasiNewtonMatrix(InitialHessType,InitialHessMatrix, ...
                    HessUpdate,initialHessIsAScalar,numberOfVariables);
end                       
%                     
% Main loop
%
while ~done
    iter = iter + 1;
    
    % Form search direction
    dir = -H*grad;
    dirDerivative = grad'*dir; 
    
    % Perform line search along dir
    alpha1 = 1;
    if iter == 1 
        alpha1 = min(1/g0Norm,1); 
    end  
    xOld = x; fOld = f; gradOld = grad; alphaOld = alpha;

    % During line search, don't exceed the overall total maxFunEvals.
    maxFunEvalsLnSrch = maxFunEvals - funcCount;
    [alpha,f,gPlusTimesDir,grad,exitflagLnSrch,funcCountLnSrch] = ... 
            lineSearch(funfcn,x,xRows,xCols,numberOfVariables,dir, ...
            f,dirDerivative,alpha1,rho,sigma,fminimum,maxFunEvalsLnSrch, ...
            tolLnSrch,DiffMinChange,DiffMaxChange,TypicalX,varargin{:});
    funcCount = funcCount + funcCountLnSrch;
    
    % Break if line search didn't finish successfully
    if exitflagLnSrch < 0
      % Restore previous values
      alpha = alphaOld;  
      f = fOld;
      grad = gradOld;
      break
    end
    
    % Display iteration quantities
    if verbosity > 1
      % Print header periodically
      if mod(iter,20) == 0
        disp(sprintf(['                                                         Gradient''s \n', ...
            ' Iteration  Func-count       f(x)        Step-size      infinity-norm']));        
      end
        disp(sprintf(formatstr,iter,funcCount,f,alpha,norm(grad,inf),hessUpdateMsg))
    end

    % OutputFcn call
    if haveoutputfcn
      [xOutputfcn,optimValues,stop] = callOutputFcn(outputfcn,x,xOutputfcn,'iter',iter,funcCount, ...
           f,alpha,grad,dir,varargin{:});      
      if stop  % Stop per user request.
        [x,f,exitflag,output,grad,H] = ...
                cleanUpInterrupt(xOutputfcn,optimValues);
        if verbosity > 0
          disp('Optimization terminated prematurely by user.');
        end
        return;
      end
    end
        
    % Update iterate
    deltaX = alpha*dir;
    x = x + deltaX;

    [done,exitflag,outMessage] = testStop(x,deltaX,iter,funcCount,TolX,TolFun,maxIter, ...
                                     maxFunEvals,verbosity,grad,g0Norm);

    % Update quasi-Newton matrix.
    [H,hessUpdateMsg] = updateQuasiNewtonMatrix(H,deltaX,grad-gradOld,HessUpdate, ...
                                            InitialHessType,iter);
end % of while

% Handle cases in which line search didn't terminate normally
if exitflagLnSrch == -1
  outMessage = sprintf(['Maximum number of function evaluations exceeded;\n', ...
                        ' increase options.MaxFunEvals']);
  exitflag = 0;
elseif exitflagLnSrch == -2
  outMessage = sprintf(['Line search cannot sufficiently decrease FUN along the current\n' ...
                        ' search direction.']);
  exitflag = -2;
end

% Display final message
if verbosity > 0
  disp(outMessage);
end

% Compute finite-difference Hessian only if asked for in output
if computeHessian
  if verbosity > 0
      if ~gradflag
        fprintf('\nComputing finite-difference Hessian using user-supplied objective function.\n')          
        % If problem large, estimating the finite difference Hessian 
        % with only function values may take time
        if numberOfVariables >= 100
          fprintf(' This may take a substantial amount of time.\n')
        end
      end
  end
  hessian = finDiffHessian(funfcn,x,xRows,xCols,numberOfVariables,gradflag,f, ...
                           grad,DiffMinChange,DiffMaxChange,varargin{:});
end  

% OutputFcn call
if haveoutputfcn
  [xOutputfcn, optimValues] = callOutputFcn(outputfcn,x,xOutputfcn,'done',iter,funcCount, ...
      f,alpha,grad,dir,varargin{:});      
end   

x = reshape(x,xRows,xCols); % restore user shape
output.iterations = iter;
output.funcCount = funcCount;
output.stepsize = alpha;
output.firstorderopt = norm(grad,inf);
output.algorithm = 'medium-scale: Quasi-Newton line search';
output.message = outMessage;
%-------------------------------------------------------------------------------
function [done,exitflag,msg] = ...
                        testStop(x,deltaX,iter,funcCount,TolX, ...
                        TolFun,maxIter,maxFunEvals,verbosity,grad,g0Norm)
%
% TESTSTOP checks if the stopping conditions are met
%
if norm(grad,Inf) < TolFun*(1+g0Norm)
     msg = sprintf(['Optimization terminated: relative infinity-norm' ... 
                    ' of gradient less than options.TolFun.']);
     done = true;
     exitflag = 1;                                     
elseif norm(deltaX ./ (1 + abs(x)),inf) < TolX
    msg = sprintf(['Optimization cannot make further progress:\n', ...   
                ' relative change in x less than options.TolX.']);
    done = true;
    exitflag = 2;
elseif funcCount > maxFunEvals  
     msg = sprintf(['Maximum number of function evaluations exceeded;\n', ...
                           '   increase options.MaxFunEvals.']);
     done = true;
     exitflag = 0;
elseif iter > maxIter 
     msg = sprintf(['Maximum number of iterations exceeded;\n', ...
                        '   increase options.MaxIter.']);
     done = true;
     exitflag = 0;
else
   exitflag = [];
   done = false;
   msg = [];
end

%-------------------------------------------------------------------------------
function [done,exitflag,msg] = initialTestStop(g0Norm,TolFun,verbosity)
%
% INITIALTESTSTOP checks if the starting point satisfies a convergence
% criterion.
%
if g0Norm < TolFun*(1+g0Norm)
  msg = sprintf(['Optimization terminated at the initial point: the relative\n' ... 
                 ' magnitude of the gradient at x0 less than options.TolFun.']);     
  done = true;
  exitflag = 1;
else
  exitflag = [];
  done = false;
  msg = [];
end   

%-------------------------------------------------------------------------------
function H = initialQuasiNewtonMatrix(InitialHessType,InitialHessMatrix, ...
                           HessUpdate,initialHessIsAScalar,numberOfVariables)
%
% INITIALQNMATRIX sets the initial quasi-Newton matrix that approximates
% the inverse to the Hessian.
%

% Unless running steepest-descent, compute initial H
if ~strncmp(HessUpdate,'s',1)                         % not steepest-descent
    if isequal(lower(InitialHessType),'identity') || ...
        isequal(lower(InitialHessType),'scaled-identity')
        % Built-in initial quasi-Newton matrix. In 'scaled-identity' case,
        % the scaling occurs right after the end of the 1st iteration.
        H = eye(numberOfVariables);
    else
        % User-supplied initial approximation to the Hessian. We invert 
        % this initial matrix because we maintain an approximation H to 
        % the inverse of the Hessian. The check for InitialHessMatrix > 0 
        % was already done in optimset.m
        if initialHessIsAScalar
            % InitialHessMatrix is a scalar
            H = 1/InitialHessMatrix*eye(numberOfVariables);
        else
            % InitialHessMatrix is a vector
            H = diag(1./InitialHessMatrix);
        end
    end
else
    % Steepest-descent: H is always the identity
    H = eye(numberOfVariables);
end

%-------------------------------------------------------------------------------
function [H,msg] = updateQuasiNewtonMatrix(H,deltaX,deltaGrad,HessUpdate, ...
                                           InitialHessType,iter)
%
% UPDATEQUASINEWTONMATRIX updates the quasi-Newton matrix that approximates
% the inverse to the Hessian.

deltaXDeltaGrad = deltaX'*deltaGrad;

if iter == 1 && strncmp(InitialHessType,'scaledIdentity',2)
  % Reset the initial quasi-Newton matrix to a scaled identity
  % aimed at reflecting the size of the inverse true Hessian
  H = deltaXDeltaGrad/(deltaGrad'*deltaGrad)*eye(length(deltaX));
end

if strncmp(HessUpdate,'b',1)
  if deltaXDeltaGrad >= sqrt(eps)*norm(deltaX)*norm(deltaGrad)
    HdeltaGrad = H*deltaGrad;
    % BFGS update
    H = H + (1 + deltaGrad'*HdeltaGrad/deltaXDeltaGrad) * ...
        deltaX*deltaX'/deltaXDeltaGrad - (deltaX*HdeltaGrad' + ... 
        HdeltaGrad*deltaX')/deltaXDeltaGrad;
    msg = '';
  else
    msg = 'skipped update';
  end
elseif strncmp(HessUpdate,'d',1)
  if deltaXDeltaGrad >= sqrt(eps)*norm(deltaX)*norm(deltaGrad)
    HdeltaGrad = H*deltaGrad;
    % DFP update
    H = H + deltaX*deltaX'/deltaXDeltaGrad - HdeltaGrad*HdeltaGrad'/(deltaGrad'*HdeltaGrad);    
    msg = '';
  else
    msg = 'skipped update';
  end  
elseif strncmp(HessUpdate,'s',1)
  % Steepest descent
  H = eye(length(deltaX));
  msg = '';  
end

%-------------------------------------------------------------------------------  
function [Hessian,functionCalls] = finDiffHessian(funfcn,x,xRows,xCols, ...
            numberOfVariables,useGrad,f,grad,DiffMinChange,DiffMaxChange, ...
            varargin) 
% FINDIFFHESSIAN calculates the numerical Hessian of funfcn evaluated at x
% using finite differences. 

Hessian = zeros(numberOfVariables);

if useGrad
  % Define stepsize 
  CHG = sqrt(eps)*sign(x).*max(abs(x),1); 

  % Make sure step size lies within DiffminChange and DiffMaxChange
  CHG = sign(CHG+eps).*min(max(abs(CHG),DiffMinChange),DiffMaxChange);
  % 
  % Calculate finite difference Hessian by columns 
  % using the user's gradient. We use the forward 
  % difference formula.
  %
  % Hessian(:,j) = 1/h(j) * [grad(x+h(j)*ej) - grad(x)]               (1)
  % 
  for j = 1:numberOfVariables
    xplus = x; 
    xplus(j) = x(j) + CHG(j);
    % evaluate gradPlus 
    switch funfcn{1}          
     case 'fun'
      error('optim:fminusub:WrongUseGrad','Gradient not supplied but useGrad set to true.')
     case 'fungrad'
      [fplus,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
      gradPlus = gradPlus(:);
     case 'fun_then_grad'
      gradPlus = feval(funfcn{4},reshape(xplus,xRows,xCols),varargin{:});
      gradPlus = gradPlus(:);
     otherwise
      error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
    end    
    % Calculate jth column of Hessian
    Hessian(:,j) = (gradPlus - grad) / CHG(j);
  end
  % Symmetrize
  Hessian = 0.5*(Hessian + Hessian');
  % Function calls
  functionCalls = numberOfVariables;
else % of 'if useGrad'
  % Define stepsize  
  CHG = eps^(1/4)*sign(x).*max(abs(x),1);  
  
  % Make sure step size lies within DiffminChange and DiffMaxChange
  CHG = sign(CHG+eps).*min(max(abs(CHG),DiffMinChange),DiffMaxChange);
  %
  % Calculate the upper triangle of the finite difference 
  % Hessian element by element, using only function values.
  % The forward difference formula we use is
  %
  % Hessian(i,j) = 1/(h(i)*h(j)) * [f(x+h(i)*ei+h(j)*ej) - f(x+h(i)*ei) 
  %                          - f(x+h(j)*ej) + f(x)]                   (2) 
  % 

  % The 3rd term in (2) is common within each column of Hessian 
  % and thus can be reused. We first calculate that term for each 
  % column and store it in the row vector fplus_array.
  fplus_array = zeros(1,numberOfVariables);
  for j = 1:numberOfVariables
    xplus = x;
    xplus(j) = x(j) + CHG(j);
    % evaluate  
    switch funfcn{1}
     case 'fun'
      fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});       
     case 'fungrad'
      [fplus,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     case 'fun_then_grad'  
      fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     otherwise
      error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
    end    
    fplus_array(j) = fplus;
  end
  
  for i = 1:numberOfVariables
    % For each row, calculate the 2nd term in (4). This term is
    % common to the whole row and thus it can be reused within 
    % the current row: we store it in fplus_i.
    xplus = x;
    xplus(i) = x(i) + CHG(i);
    % evaluate  
    switch funfcn{1}
     case 'fun'
      fplus_i = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});        
     case 'fungrad'
      [fplus_i,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     case 'fun_then_grad'  
      fplus_i = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     otherwise
      error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
    end     
 
    for j = i:numberOfVariables   % start from i: only upper triangle
      % Calculate the 1st term in (2); this term is unique for
      % each element of Hessian and thus it cannot be reused.
      xplus = x;
      xplus(i) = x(i) + CHG(i);
      xplus(j) = xplus(j) + CHG(j);
      % evaluate  
      switch funfcn{1}
       case 'fun'
        fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});        
       case 'fungrad'
        [fplus,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
       case 'fun_then_grad'  
        fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
       otherwise
        error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
      end    
      Hessian(i,j) = (fplus - fplus_i - fplus_array(j) + f)/(CHG(i)*CHG(j)); 
    end 
  end % of "for i = 1:numberOfVariables"
  % Fill in the lower triangle
  Hessian = Hessian + triu(Hessian,1)';
  % Function calls
  functionCalls = 2*numberOfVariables + ...        % 2nd and 3rd terms,
      numberOfVariables*(numberOfVariables + 1)/2; % 1st term in (2)
end % of 'if useGrad'

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,state,iter,funcCount, ...
    f,alpha,grad,dir,varargin)
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
optimValues.funccount = funcCount;
optimValues.fval = f;
optimValues.stepsize = alpha;
if ~isempty(dir)
    optimValues.directionalderivative = dir'*grad;
else
    optimValues.directionalderivative = [];
end
optimValues.gradient = grad;
optimValues.searchdirection = dir;
optimValues.firstorderopt = norm(grad,Inf);
optimValues.procedure = '';
xOutputfcn(:) = x;  % Set x to have user expected size
switch state
    case {'iter','init'}
        stop = feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    case 'done'
        stop = false;
        feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    otherwise
        error('optim:fminusub:UnknownStateInCallOutputFcn','Unknown state in CALLOUTPUTFCN.')
end

%--------------------------------------------------------------------------
function [x,fval,exitflag,output,gradient,hessian] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT updates or sets all the output arguments of NLCONST when the optimization 
% is interrupted.  The HESSIAN and LAMBDA are set to [] as they may be in a
% state that is inconsistent with the other values since we are
% interrupting mid-iteration.

x = xOutputfcn;
fval = optimValues.fval;
exitflag = -1; 
output.iterations = optimValues.iteration;
output.funcCount = optimValues.funccount;
output.stepsize = optimValues.stepsize;
output.algorithm = 'medium-scale: SQP, Quasi-Newton, line-search';
output.firstorderopt = optimValues.firstorderopt; 
output.cgiterations = [];
output.message = 'Optimization terminated prematurely by user.';
gradient = optimValues.gradient;
hessian = []; % May be in an inconsistent state





