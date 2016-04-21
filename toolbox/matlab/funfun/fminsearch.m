function [x,fval,exitflag,output] = fminsearch(funfcn,x,options,varargin)
%FMINSEARCH Multidimensional unconstrained nonlinear minimization (Nelder-Mead).
%   X = FMINSEARCH(FUN,X0) starts at X0 and attempts to find a local minimizer 
%   X of the function FUN. FUN accepts input X and returns a scalar function 
%   value F evaluated at X. X0 can be a scalar, vector or matrix.
%
%   X = FMINSEARCH(FUN,X0,OPTIONS)  minimizes with the default optimization
%   parameters replaced by values in the structure OPTIONS, created
%   with the OPTIMSET function.  See OPTIMSET for details.  FMINSEARCH uses
%   these options: Display, TolX, TolFun, MaxFunEvals, MaxIter, FunValCheck,
%   and OutputFcn.
%
%   [X,FVAL]= FMINSEARCH(...) returns the value of the objective function,
%   described in FUN, at X.
%
%   [X,FVAL,EXITFLAG] = FMINSEARCH(...) returns an EXITFLAG that describes 
%   the exit condition of FMINSEARCH. Possible values of EXITFLAG and the 
%   corresponding exit conditions are
%
%    1  FMINSEARCH converged to a solution X.
%    0  Maximum number of function evaluations or iterations reached.
%   -1  Algorithm terminated by the output function.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = FMINSEARCH(...) returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations, the
%   number of function evaluations in OUTPUT.funcCount, the algorithm name 
%   in OUTPUT.algorithm, and the exit message in OUTPUT.message.
%
%   Examples
%     FUN can be specified using @:
%        X = fminsearch(@sin,3)
%     finds a minimum of the SIN function near 3.
%     In this case, SIN is a function that returns a scalar function value
%     SIN evaluated at X.
%
%     FUN can also be an anonymous function:
%        X = fminsearch(@(x) norm(x),[1;2;3])
%     returns a point near the minimizer [0;0;0].
%
%   If FUN is parameterized, you can use anonymous functions to capture the 
%   problem-dependent parameters. Suppose you want to optimize the objective     
%   given in the function MYFUN, which is parameterized by its second argument A. 
%   Here MYFUN is an M-file function such as
%
%     function F = myfun(x,a)
%     f = x(1)^2 + a*x(2)^2;
%
%   To optimize for a specific value of A, first assign the value to A. Then 
%   create a one-argument anonymous function that captures that value of A 
%   and calls MYFUN with two arguments. Finally, pass this anonymous function 
%   to FMISEARCH:
%    
%     a = 1.5; % define parameter first
%     x = fminsearch(@(x) myfun(x,a),[0.3;1])
%
%   FMINSEARCH uses the Nelder-Mead simplex (direct search) method.
%
%   See also OPTIMSET, FMINBND, FUNCTION_HANDLE.

%   Reference: Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright,
%   Paul E. Wright, "Convergence Properties of the Nelder-Mead Simplex
%   Method in Low Dimensions", SIAM Journal of Optimization, 9(1):
%   p.112-147, 1998.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.6 $  $Date: 2004/04/16 22:05:25 $


defaultopt = struct('Display','notify','MaxIter','200*numberOfVariables',...
    'MaxFunEvals','200*numberOfVariables','TolX',1e-4,'TolFun',1e-4, ...
    'FunValCheck','off','OutputFcn',[]);

% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(funfcn,'defaults')
    x = defaultopt;
    return
end

if nargin < 2,
    error('MATLAB:fminsearch:NotEnoughInputs',...
        'FMINSEARCH requires at least two input arguments');
end

if nargin<3, options = []; end

% Check for non-double inputs
if ~isa(x,'double')
  error('MATLAB:fminsearch:NonDoubleInput', ...
         'FMINSEARCH only accepts inputs of data type double.')
end

n = numel(x);
numberOfVariables = n;

printtype = optimget(options,'Display',defaultopt,'fast');
tolx = optimget(options,'TolX',defaultopt,'fast');
tolf = optimget(options,'TolFun',defaultopt,'fast');
maxfun = optimget(options,'MaxFunEvals',defaultopt,'fast');
maxiter = optimget(options,'MaxIter',defaultopt,'fast');
funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');

% In case the defaults were gathered from calling: optimset('fminsearch'):
if ischar(maxfun)
    if isequal(lower(maxfun),'200*numberofvariables')
        maxfun = 200*numberOfVariables;
    else
        error('MATLAB:fminsearch:OptMaxFunEvalsNotInteger',...
            'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end
if ischar(maxiter)
    if isequal(lower(maxiter),'200*numberofvariables')
        maxiter = 200*numberOfVariables;
    else
        error('MATLAB:fminsearch:OptMaxIterNotInteger',...
            'Option ''MaxIter'' must be an integer value if not the default.')
    end
end

switch printtype
    case 'notify'
        prnt = 1;
    case {'none','off'}
        prnt = 0;
    case 'iter'
        prnt = 3;
    case 'final'
        prnt = 2;
    case 'simplex'
        prnt = 4;
    otherwise
        prnt = 1;
end
% Handle the output
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
    % Convert to function handle as needed.
    outputfcn = fcnchk(outputfcn,length(varargin));
end

header = ' Iteration   Func-count     min f(x)         Procedure';

% Convert to function handle as needed.
funfcn = fcnchk(funfcn,length(varargin));
% Add a wrapper function to check for Inf/NaN/complex values
if funValCheck
    % Add a wrapper function, CHECKFUN, to check for NaN/complex values without
    % having to change the calls that look like this:
    % f = funfcn(x,varargin{:});
    % x is the first argument to CHECKFUN, then the user's function,
    % then the elements of varargin. To accomplish this we need to add the 
    % user's function to the beginning of varargin, and change funfcn to be
    % CHECKFUN.
    varargin = {funfcn, varargin{:}};
    funfcn = @checkfun;
end

n = numel(x);

% Initialize parameters
rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
onesn = ones(1,n);
two2np1 = 2:n+1;
one2n = 1:n;

% Set up a simplex near the initial guess.
xin = x(:); % Force xin to be a column vector
v = zeros(n,n+1); fv = zeros(1,n+1);
v(:,1) = xin;    % Place input guess in the simplex! (credit L.Pfeffer at Stanford)
x(:) = xin;    % Change x to the form expected by funfcn
fv(:,1) = funfcn(x,varargin{:});
func_evals = 1;
itercount = 0;
how = '';

% Initialize the output function.
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'init',itercount, ...
        func_evals, how, fv(:,1),varargin{:});
    if stop
        [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
        if  prnt > 0
            disp(output.message)
        end
        return;
    end
end

% Print out initial f(x) as 0th iteration
if prnt == 3
    disp(' ')
    disp(header)
    disp(sprintf(' %5.0f        %5.0f     %12.6g         %s', itercount, func_evals, fv(1), how));
elseif prnt == 4
    clc
    formatsave = get(0,{'format','formatspacing'});
    format compact
    format short e
    disp(' ')
    disp(how)
    v
    fv
    func_evals
end
% OutputFcn call
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'iter',itercount, ...
        func_evals, how, fv(:,1),varargin{:});
    if stop  % Stop per user request.
        [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
        if  prnt > 0
            disp(output.message)
        end
        return;
    end
end

% Following improvement suggested by L.Pfeffer at Stanford
usual_delta = 0.05;             % 5 percent deltas for non-zero terms
zero_term_delta = 0.00025;      % Even smaller delta for zero elements of x
for j = 1:n
    y = xin;
    if y(j) ~= 0
        y(j) = (1 + usual_delta)*y(j);
    else
        y(j) = zero_term_delta;
    end
    v(:,j+1) = y;
    x(:) = y; f = funfcn(x,varargin{:});
    fv(1,j+1) = f;
end

% sort so v(1,:) has the lowest function value
[fv,j] = sort(fv);
v = v(:,j);

how = 'initial simplex';
itercount = itercount + 1;
func_evals = n+1;
if prnt == 3
    disp(sprintf(' %5.0f        %5.0f     %12.6g         %s', itercount, func_evals, fv(1), how))
elseif prnt == 4
    disp(' ')
    disp(how)
    v
    fv
    func_evals
end
% OutputFcn call
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'iter',itercount, ...
        func_evals, how, fv(:,1),varargin{:});
    if stop  % Stop per user request.
        [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
        if  prnt > 0
            disp(output.message)
        end
        return;
    end
end
exitflag = 1;

% Main algorithm
% Iterate until the diameter of the simplex is less than tolx
%   AND the function values differ from the min by less than tolf,
%   or the max function evaluations are exceeded. (Cannot use OR instead of
%   AND.)
while func_evals < maxfun && itercount < maxiter
    if max(max(abs(v(:,two2np1)-v(:,onesn)))) <= tolx && ...
            max(abs(fv(1)-fv(two2np1))) <= tolf
        break
    end
    
    % Compute the reflection point
    
    % xbar = average of the n (NOT n+1) best points
    xbar = sum(v(:,one2n), 2)/n;
    xr = (1 + rho)*xbar - rho*v(:,end);
    x(:) = xr; fxr = funfcn(x,varargin{:});
    func_evals = func_evals+1;
    
    if fxr < fv(:,1)
        % Calculate the expansion point
        xe = (1 + rho*chi)*xbar - rho*chi*v(:,end);
        x(:) = xe; fxe = funfcn(x,varargin{:});
        func_evals = func_evals+1;
        if fxe < fxr
            v(:,end) = xe;
            fv(:,end) = fxe;
            how = 'expand';
        else
            v(:,end) = xr;
            fv(:,end) = fxr;
            how = 'reflect';
        end
    else % fv(:,1) <= fxr
        if fxr < fv(:,n)
            v(:,end) = xr;
            fv(:,end) = fxr;
            how = 'reflect';
        else % fxr >= fv(:,n)
            % Perform contraction
            if fxr < fv(:,end)
                % Perform an outside contraction
                xc = (1 + psi*rho)*xbar - psi*rho*v(:,end);
                x(:) = xc; fxc = funfcn(x,varargin{:});
                func_evals = func_evals+1;
                
                if fxc <= fxr
                    v(:,end) = xc;
                    fv(:,end) = fxc;
                    how = 'contract outside';
                else
                    % perform a shrink
                    how = 'shrink';
                end
            else
                % Perform an inside contraction
                xcc = (1-psi)*xbar + psi*v(:,end);
                x(:) = xcc; fxcc = funfcn(x,varargin{:});
                func_evals = func_evals+1;
                
                if fxcc < fv(:,end)
                    v(:,end) = xcc;
                    fv(:,end) = fxcc;
                    how = 'contract inside';
                else
                    % perform a shrink
                    how = 'shrink';
                end
            end
            if strcmp(how,'shrink')
                for j=two2np1
                    v(:,j)=v(:,1)+sigma*(v(:,j) - v(:,1));
                    x(:) = v(:,j); fv(:,j) = funfcn(x,varargin{:});
                end
                func_evals = func_evals + n;
            end
        end
    end
    [fv,j] = sort(fv);
    v = v(:,j);
    itercount = itercount + 1;
    if prnt == 3
        disp(sprintf(' %5.0f        %5.0f     %12.6g         %s', itercount, func_evals, fv(1), how))
    elseif prnt == 4
        disp(' ')
        disp(how)
        v
        fv
        func_evals
    end
    % OutputFcn call
    if haveoutputfcn
        [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'iter',itercount, ...
            func_evals, how, fv(:,1),varargin{:});
        if stop  % Stop per user request.
            [x,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
            if  prnt > 0
                disp(output.message)
            end
            return;
        end
    end
end   % while

x(:) = v(:,1);
if prnt == 4,
    % reset format
    set(0,{'format','formatspacing'},formatsave);
end
output.iterations = itercount;
output.funcCount = func_evals;
output.algorithm = 'Nelder-Mead simplex direct search';

fval = min(fv);

% OutputFcn call
if haveoutputfcn
    callOutputFcn(outputfcn,x,xOutputfcn,'done',itercount, func_evals, how, f, varargin{:});
end

if func_evals >= maxfun
    msg = sprintf(['Exiting: Maximum number of function evaluations has been exceeded\n' ...
                   '         - increase MaxFunEvals option.\n' ...
                   '         Current function value: %f \n'], fval);
    if prnt > 0
        disp(' ')
        disp(msg)
    end
    exitflag = 0;
elseif itercount >= maxiter
    msg = sprintf(['Exiting: Maximum number of iterations has been exceeded\n' ... 
                   '         - increase MaxIter option.\n' ...
                   '         Current function value: %f \n'], fval);
    if prnt > 0
        disp(' ')
        disp(msg)
    end
    exitflag = 0;
else
    msg = ...
      sprintf(['Optimization terminated:\n', ...
               ' the current x satisfies the termination criteria using OPTIONS.TolX of %e \n' ...
               ' and F(X) satisfies the convergence criteria using OPTIONS.TolFun of %e \n'], ...
               tolx, tolf);
    if prnt > 1
        disp(' ')
        disp(msg)
    end
    exitflag = 1;
end

output.message = msg;

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,state,iter,...
    numf,how,f,varargin)
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
optimValues.funccount = numf;
optimValues.fval = f;
optimValues.procedure = how;

xOutputfcn(:) = x;  % Set x to have user expected size
switch state
    case {'iter','init'}
        stop = outputfcn(xOutputfcn,optimValues,state,varargin{:});
    case 'done'
        stop = false;
        outputfcn(xOutputfcn,optimValues,state,varargin{:});
    otherwise
        error('MATLAB:fminsearch:InvalidState', ...
            'Unknown state in CALLOUTPUTFCN.')
end

%--------------------------------------------------------------------------
function [x,FVAL,EXITFLAG,OUTPUT] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT updates or sets all the output arguments of FMINBND when the optimization
% is interrupted.

x = xOutputfcn;
FVAL = optimValues.fval;
EXITFLAG = -1;
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.algorithm = 'golden section search, parabolic interpolation';
OUTPUT.message = 'Optimization terminated prematurely by user.';

%--------------------------------------------------------------------------
function f = checkfun(x,userfcn,varargin)
% CHECKFUN checks for complex or NaN results from userfcn.

f = userfcn(x,varargin{:});
% Note: we do not check for Inf as FMINSEARCH handles it naturally.
if isnan(f)
    error('MATLAB:fminsearch:checkfun:NaNFval', ...
        'User function ''%s'' returned NaN when evaluated at %g;\n FMINSEARCH cannot continue.', ...
        localChar(userfcn), x);  
elseif ~isreal(f)
    error('MATLAB:fminsearch:checkfun:ComplexFval', ...
        'User function ''%s'' returned a complex value when evaluated at %g;\n FMINSEARCH cannot continue.', ...
        localChar(userfcn),x);  
end

%--------------------------------------------------------------------------
function strfcn = localChar(fcn)
% Convert the fcn to a string for printing

if ischar(fcn)
    strfcn = fcn;
elseif isa(fcn,'inline')
    strfcn = char(fcn);
elseif isa(fcn,'function_handle')
    strfcn = func2str(fcn);
else
    try
        strfcn = char(fcn);
    catch
        strfcn = '(name not printable)';
    end
end


