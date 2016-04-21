function [xf,fval,exitflag,output] = fminbnd(funfcn,ax,bx,options,varargin)
%FMINBND Scalar bounded nonlinear function minimization.
%   X = FMINBND(FUN,x1,x2) attempts to find  a local minimizer X of the function 
%   FUN in the interval x1 <= X <= x2. FUN accepts scalar input X and returns a 
%   scalar function value F evaluated at X.
%
%   X = FMINBND(FUN,x1,x2,OPTIONS) minimizes with the default optimization
%   parameters replaced by values in the structure OPTIONS, created with
%   the OPTIMSET function. See OPTIMSET for details. FMINBND uses these
%   options: Display, TolX, MaxFunEval, MaxIter, FunValCheck, and OutputFcn.
%
%   [X,FVAL] = FMINBND(...) also returns the value of the objective function,
%   FVAL, computed in FUN, at X.
%
%   [X,FVAL,EXITFLAG] = FMINBND(...) also returns an EXITFLAG that describes 
%   the exit condition of FMINBND. Possible values of EXITFLAG and the 
%   corresponding exit conditions are
%
%    1  FMINBND converged with a solution X based on OPTIONS.TolX.
%    0  Maximum number of function evaluations or iterations reached.
%   -1  Algorithm terminated by the output function.
%   -2  Bounds are inconsistent (that is, ax > bx).
%
%   [X,FVAL,EXITFLAG,OUTPUT] = FMINBND(...) also returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations, the
%   number of function evaluations in OUTPUT.funcCount, the algorithm name 
%   in OUTPUT.algorithm, and the exit message in OUTPUT.message.
%
%   Examples
%     FUN can be specified using @:
%        X = fminbnd(@cos,3,4)
%      computes pi to a few decimal places and gives a message upon termination.
%        [X,FVAL,EXITFLAG] = fminbnd(@cos,3,4,optimset('TolX',1e-12,'Display','off'))
%      computes pi to about 12 decimal places, suppresses output, returns the
%      function value at x, and returns an EXITFLAG of 1.
%
%     FUN can also be an anonymous function:
%        x = fminbnd(@(x) sin(x)+3,2,5)
%
%   If FUN is parameterized, you can use anonymous functions to capture the 
%   problem-dependent parameters. Suppose you want to minimize the objective
%   given in the function MYFUN, which is parameterized by its second argument A.
%   Here MYFUN is an M-file function such as
%
%     function f = myfun(x,a)
%     f = (x - a)^2;
%
%   To optimize for a specific value of A, first assign the value to A. Then 
%   create a one-argument anonymous function that captures that value of A 
%   and calls MYFUN with two arguments. Finally, pass this anonymous function 
%   to FMINBND:
%
%     a = 1.5; % define parameter first
%     x = fminbnd(@(x) myfun(x,a),0,1)
% 
%   See also OPTIMSET, FMINSEARCH, FZERO, FUNCTION_HANDLE.

%   Reference: "Computer Methods for Mathematical Computations",
%   Forsythe, Malcolm, and Moler, Prentice-Hall, 1976.

%   Original coding by Duane Hanselman, University of Maine.
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.6 $  $Date: 2004/04/16 22:05:24 $


defaultopt = struct('Display','notify',...
    'MaxFunEvals',500,'MaxIter',500,'TolX',1e-4,'FunValCheck','off','OutputFcn',[]);

% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(funfcn,'defaults')
    xf = defaultopt;
    return
end

if nargin < 3
    error('MATLAB:fminbnd:NotEnoughInputs',...
        'fminbnd requires three input arguments.')
end

% initialization
if nargin<4,
    options = [];
end

% Check for non-double inputs
if ~isa(ax,'double') || ~isa(bx,'double')
  error('MATLAB:fminbnd:NonDoubleInput', ...
        'FMINBND only accepts inputs of data type double.')
end

printtype = optimget(options,'Display',defaultopt,'fast');
tol = optimget(options,'TolX',defaultopt,'fast');
maxfun = optimget(options,'MaxFunEvals',defaultopt,'fast');
maxiter = optimget(options,'MaxIter',defaultopt,'fast');
funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
funccount = 0;
iter = 0;
xf = []; fx = [];

switch printtype
    case 'notify'
        print = 1;
    case {'none','off'}
        print = 0;
    case 'iter'
        print = 3;
    case 'final'
        print = 2;
    otherwise
        print = 1;
end

% Handle the output
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    % Convert to function handle as needed.
    outputfcn = fcnchk(outputfcn,length(varargin));
end

% checkbounds
if ax > bx
    exitflag = -2;
    xf=[]; fval = [];
    msg=sprintf(['Exiting due to infeasibility: the lower bound exceeds the' ...
        ' upper bound.']);
    if print > 0
        disp(' ')
        disp(msg)
    end
    output.iterations = 0;
    output.funcCount = 0;
    output.algorithm = 'golden section search, parabolic interpolation';
    output.message = msg;
    % Have not initialized OutputFcn; do not need to call it before returning
    return
end

% Assume we'll converge
exitflag = 1;

header = ' Func-count     x          f(x)         Procedure';
procedure='       initial';

% Convert to function handle as needed.
funfcn = fcnchk(funfcn,length(varargin));

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

% Initialize the output function.
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xf,'init',funccount,iter, ...
        fx,procedure,varargin{:});
    if stop
        [xf,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
        if  print > 0
            disp(output.message)
        end
        return;
    end
end

% evaluate endpoints
fa = funfcn(ax,varargin{:});
fb = funfcn(bx,varargin{:});
funccount = funccount + 2;
% Compute the start point
seps = sqrt(eps);
c = 0.5*(3.0 - sqrt(5.0));
a = ax; b = bx;
v = a + c*(b-a);
w = v; xf = v;
d = 0.0; e = 0.0;
x= xf; fx = funfcn(x,varargin{:});
funccount = funccount + 1;
if print > 2
    disp(' ')
    disp(header)
    disp(sprintf('%5.0f   %12.6g %12.6g %s',funccount,xf,fx,procedure))
end

% OutputFcn call
xOutputfcn = xf; % Last x passed to outputfcn; has the input x's shape
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xf,'iter',funccount,iter, ...
        fx,procedure,varargin{:});
    if stop  % Stop per user request.
        [xf,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
        if  print > 0
            disp(output.message)
        end
        return;
    end
end

fv = fx; fw = fx;
xm = 0.5*(a+b);
tol1 = seps*abs(xf) + tol/3.0;
tol2 = 2.0*tol1;

% Main loop
while ( abs(xf-xm) > (tol2 - 0.5*(b-a)) )
    gs = 1;
    % Is a parabolic fit possible
    if abs(e) > tol1
        % Yes, so fit parabola
        gs = 0;
        r = (xf-w)*(fx-fv);
        q = (xf-v)*(fx-fw);
        p = (xf-v)*q-(xf-w)*r;
        q = 2.0*(q-r);
        if q > 0.0,  p = -p; end
        q = abs(q);
        r = e;  e = d;

        % Is the parabola acceptable
        if ( (abs(p)<abs(0.5*q*r)) && (p>q*(a-xf)) && (p<q*(b-xf)) )

            % Yes, parabolic interpolation step
            d = p/q;
            x = xf+d;
            procedure = '       parabolic';

            % f must not be evaluated too close to ax or bx
            if ((x-a) < tol2) || ((b-x) < tol2)
                si = sign(xm-xf) + ((xm-xf) == 0);
                d = tol1*si;
            end
        else
            % Not acceptable, must do a golden section step
            gs=1;
        end
    end
    if gs
        % A golden-section step is required
        if xf >= xm, e = a-xf;    else e = b-xf;  end
        d = c*e;
        procedure = '       golden';
    end

    % The function must not be evaluated too close to xf
    si = sign(d) + (d == 0);
    x = xf + si * max( abs(d), tol1 );
    fu = funfcn(x,varargin{:});
    funccount = funccount + 1;

    iter = iter + 1;
    if print > 2
        disp(sprintf('%5.0f   %12.6g %12.6g %s',funccount, x, fu, procedure));
    end
    % OutputFcn call
    if haveoutputfcn
        [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,'iter',funccount,iter, ...
            fu,procedure,varargin{:});
        if stop  % Stop per user request.
            [xf,fval,exitflag,output] = cleanUpInterrupt(xOutputfcn,optimValues);
            if  print > 0
                disp(output.message);
            end
            return;
        end
    end

    % Update a, b, v, w, x, xm, tol1, tol2
    if fu <= fx
        if x >= xf, a = xf; else b = xf; end
        v = w; fv = fw;
        w = xf; fw = fx;
        xf = x; fx = fu;
    else % fu > fx
        if x < xf, a = x; else b = x; end
        if ( (fu <= fw) || (w == xf) )
            v = w; fv = fw;
            w = x; fw = fu;
        elseif ( (fu <= fv) || (v == xf) || (v == w) )
            v = x; fv = fu;
        end
    end
    xm = 0.5*(a+b);
    tol1 = seps*abs(xf) + tol/3.0; tol2 = 2.0*tol1;

    if funccount >= maxfun || iter >= maxiter
        exitflag = 0;
        output.iterations = iter;
        output.funcCount = funccount;
        output.algorithm = 'golden section search, parabolic interpolation';
        fval = fx;
        msg = terminate(xf,exitflag,fval,funccount,maxfun,iter,maxiter,tol,print);
        output.message = msg;
        % OutputFcn call
        if haveoutputfcn
            callOutputFcn(outputfcn,xf,'done',funccount,iter,fval,procedure,varargin{:});
        end
        return
    end
end % while

% check that endpoints are less than the minimum found
if ( (fa < fx) && (fa <= fb) )
    xf = ax; fx = fa;
elseif fb < fx
    xf = bx; fx = fb;
end
fval = fx;
output.iterations = iter;
output.funcCount = funccount;
output.algorithm = 'golden section search, parabolic interpolation';
msg = terminate(xf,exitflag,fval,funccount,maxfun,iter,maxiter,tol,print);
output.message = msg;
% OutputFcn call
if haveoutputfcn
    callOutputFcn(outputfcn,xf,'done',funccount,iter,fval,procedure,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = terminate(x,exitflag,finalf,funccount,maxfun,iter,maxiter,tol,print)

switch exitflag
    case 1
        msg = ...
            sprintf(['Optimization terminated:\n' ...
            ' the current x satisfies the termination criteria using OPTIONS.TolX of %e \n'], tol);
        if print > 1 % only print msg if not 'off' or 'notify'
            disp(' ')
            disp(msg)
        end
    case 0
        if funccount >= maxfun
            msg = sprintf(['Exiting: Maximum number of function evaluations has been exceeded\n' ...
                '         - increase MaxFunEvals option.\n' ...
                '         Current function value: %f \n'], finalf);
            if print > 0
                disp(' ')
                disp(msg)
            end
        else
            msg = sprintf(['Exiting: Maximum number of iterations has been exceeded\n' ...
                '         - increase MaxIter option.\n' ...
                '         Current function value: %f \n'], finalf);
            if print > 0
                disp(' ')
                disp(msg)
            end
        end
    otherwise
        error('MATLAB:fminbnd:InvalidExitflag','Invalid exitflag value in TERMINATE.')
end

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,state,funccount,iter,  ...
    f,procedure,varargin)
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
optimValues.funccount = funccount;
optimValues.iteration = iter;
optimValues.fval = f;
optimValues.procedure = procedure;

xOutputfcn = x;  % Set xOutputfcn to be x
switch state
    case {'iter','init'}
        stop = outputfcn(xOutputfcn,optimValues,state,varargin{:});
    case 'done'
        stop = false;
        outputfcn(xOutputfcn,optimValues,state,varargin{:});
    otherwise
        error('MATLAB:fminbnd:InvalidState','Unknown state in CALLOUTPUTFCN.')
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
% Note: we do not check for Inf as FMINBND handles it naturally.
if isnan(f)
    error('MATLAB:fminbnd:checkfun:NaNFval', ...
        'User function ''%s'' returned NaN when evaluated at %g;\n FMINBND cannot continue.', ...
        localChar(userfcn), x);
elseif ~isreal(f)
    error('MATLAB:fminbnd:checkfun:ComplexFval', ...
        'User function ''%s'' returned a complex value when evaluated at %g;\n FMINBND cannot continue.', ...
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
