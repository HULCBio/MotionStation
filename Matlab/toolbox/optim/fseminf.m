function [x,FVAL,EXITFLAG,OUTPUT,LAMBDA] = fseminf(FUN,x,ntheta,SEMINFCON,A,B,Aeq,Beq,LB,UB,options,varargin) 
%FSEMINF solves semi-infinite constrained optimization problems.
%   FSEMINF attempts to solve problems of the form:
%
%          min { F(x) | C(x)<=0 , Ceq(X) = 0 , PHI(x,w)<=0 }
%            x
%   for all w in an interval. 
%
%   X=FSEMINF(FUN,X0,NTHETA,SEMINFCON) starts at X0 and finds minimum X to
%   the function FUN constrained by NTHETA semi-infinite constraints in the
%   function SEMINFCON. FUN accepts vector input X and returns the scalar
%   function value F evaluated at X. Function SEMINFCON accepts vector
%   inputs X and S and return a vector C of nonlinear inequality
%   constraints, a vector Ceq of nonlinear equality constraints and
%   NTHETA semi-infinite inequality constraint matrices, PHI_1, PHI_2, ...,
%   PHI_NTHETA, evaluated over an interval. S is a recommended sampling
%   interval, which may or may not be used. 
%
%   X=FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B) also tries to satisfy the linear 
%   inequalities A*X <= B.
%
%   X=FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq) minimizes subject to the
%   linear equalities Aeq*X = Beq as well.  (Set A=[] and B=[] if no
%   inequalities exist.)
%
%   X=FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB) defines a set of
%   lower and upper bounds on the design variables, X, so that the
%   solution is in the range LB <= X <= UB. Use empty matrices for LB and U
%   if no bounds exist.  Set LB(i) = -Inf if X(i) is unbounded below; set
%   UB(i) = Inf if X(i) is unbounded above.
%
%   X=FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB,OPTIONS) minimizes
%   with the default optimization parameters replaced by values in the
%   structure OPTIONS, an argument created with the OPTIMSET function. See
%   OPTIMSET for details. Used options are Display, TolX, TolFun, TolCon,
%   DerivativeCheck, Diagnostics, FunValCheck, GradObj, MaxFunEvals,
%   MaxIter, DiffMinChange, DiffMaxChange and TypicalX. Use the GradObj
%   option to specify that FUN may be called with two output arguments
%   where the second, G, is the partial derivatives of the function df/dX,
%   at the point X:  [F,G] = feval(FUN,X). 
%
%   [X,FVAL]=FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) returns the value of the
%   objective function FUN at the solution X.
%
%   [X,FVAL,EXITFLAG]=FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) returns an EXITFLAG
%   that describes the exit condition of FSEMINF. Possible values of EXITFLAG 
%   and the corresponding exit conditions are
%
%     1  FSEMINF converged to a solution X.
%     4  Magnitude of search direction smaller than the specified tolerance and
%         constraint violation less than options.TolCon.
%     5  Magnitude of directional derivative less than the specified tolerance
%         and constraint violation less than options.TolCon.
%     0  Maximum number of function evaluations or iterations reached.
%    -1  Optimization terminated by the output function.
%    -2  No feasible point found.   
%   
%   [X,FVAL,EXITFLAG,OUTPUT]=FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) returns a
%   structure OUTPUT with the number of iterations taken in
%   OUTPUT.iterations, the number of function evaluations in
%   OUTPUT.funcCount, the algorithm used in OUTPUT.algorithm, and the exit
%   message in OUTPUT.message.
%
%   [X,FVAL,EXITFLAG,OUTPUT,LAMBDA]=FSEMINF(FUN,X0,NTHETA,SEMINFCON,...)
%   returns the Lagrange multiplier at the solution X: LAMBDA.lower for
%   LB, LAMBDA.upper for UB, LAMBDA.ineqlin for the linear inequalities,
%   LAMBDA.eqlin is for the linear equalities, LAMBDA.ineqnonlin is for the
%   nonlinear inequalities, and LAMBDA.eqnonlin is for the nonlinear
%   equalities.
%
%   Examples
%     FUN and SEMINFCON can be specified using @:
%        x = fseminf(@myfun,[2 3 4],3,@myseminfcon)
%
%   where MYFUN is a MATLAB function such as:
%
%       function F = myfun(x)
%       F = x(1)*cos(x(2))+ x(3)^3;
%
%   and MYSEMINFCON is a MATLAB function such as:
%
%       function [C,Ceq,PHI1,PHI2,PHI3,S] = myseminfcon(X,S)
%       C = [];     % Code to compute C and Ceq: could be empty matrices if no constraints.
%       Ceq = [];
%       if isnan(S(1,1))
%          S = [...] ; % S has ntheta rows and 2 columns
%       end
%       PHI1 = ... ;       % code to compute PHI's
%       PHI2 = ... ;
%       PHI3 = ... ;
%
%   See also OPTIMSET, @, FGOALATTAIN, LSQNONLIN.

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.27.6.7 $  $Date: 2004/04/16 22:10:01 $
%       

defaultopt = struct('Display','final',...
   'TolX',1e-4,'TolFun',1e-4,'TolCon',1e-6,'DerivativeCheck','off',...
   'Diagnostics','off','FunValCheck','off',...
   'GradObj','off',...
   'GradConstr',[],'Hessian',[],...  % Hessian and GradConstr not used
   'MaxFunEvals','100*numberOfVariables',...
   'MaxIter',400,...
   'MaxSQPIter','10*max(numberOfVariables,numberOfInequalities+numberOfBounds)',...
   'DiffMaxChange',1e-1,'DiffMinChange',1e-8, ...
   'TypicalX','ones(numberOfVariables,1)','OutputFcn',[]);
% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(FUN,'defaults')
   x = defaultopt;
   return
end

if nargin < 11, options =[];
   if nargin < 10, UB = [];
      if nargin < 9, LB = [];
         if nargin < 8, Beq = [];
            if nargin < 7, Aeq = [];
               if nargin < 6, B = [];
                  if nargin < 5, A = [];
                     if nargin < 4 
                       error('optim:fseminf:NotEnoughInputs', ...
                             'fseminf requires four input arguments.') 
                     end,end,end,end,end,end,end,end

% Check for non-double inputs
if ~isa(x,'double') || ~isa(ntheta,'double') || ~isa(A,'double') || ...
      ~isa(B,'double') || ~isa(Aeq,'double') || ~isa(Beq,'double') || ...
      ~isa(LB,'double') || ~isa(UB,'double')
  error('optim:fseminf:NonDoubleInput', ...                                            
        'FSEMINF only accepts inputs of data type double.')
end

xnew = x(:);
numberOfVariables = length(xnew);

diagnostics = isequal(optimget(options,'Diagnostics',defaultopt,'fast'),'on');
switch optimget(options,'Display',defaultopt,'fast')
case {'off','none'}
   verbosity = 0;
case 'iter'
   verbosity = 2;
case 'final'
   verbosity = 1;
otherwise
   verbosity = 1;
end

% Set to column vectors
B = B(:);
Beq = Beq(:);

[xnew,l,u,msg] = checkbounds(xnew,LB,UB,numberOfVariables);
if ~isempty(msg)
   EXITFLAG = -2;
   [FVAL,LAMBDA] = deal([]);
   OUTPUT.iterations = 0;
   OUTPUT.funcCount = 0;
   OUTPUT.stepsize = [];
   OUTPUT.algorithm = 'semi-infinite, SQP, Quasi-Newton, line_search';
   OUTPUT.firstorderopt = [];
   OUTPUT.cgiterations = [];
   OUTPUT.message = msg;
   x(:) = xnew(1:numberOfVariables);
   if verbosity > 0
      disp(msg)
   end
   return
end

meritFunctionType = 5;  % formerly options(7)
funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
usergradflag = strcmp(optimget(options,'GradObj',defaultopt,'fast'),'on');
userhessflag = strcmp(optimget(options,'Hessian',defaultopt,'fast'),'on');
if userhessflag
   warning('optim:fseminf:UserHessNotUsed', ...
           'FSEMINF does not use user supplied Hessian.')
   userhessflag = 0;
end

if isempty(SEMINFCON)
   userconstflag = 0;
else
   userconstflag = 1;
end
usergradconstflag = strcmp(optimget(options,'GradConstr',defaultopt,'fast'),'on');
if usergradconstflag
   warning('optim:fseminf:UserConstrGradNotUsed', ...
           'FSEMINF does not use user supplied constraint gradients.')
   usergradconstflag = 0;
end
gradconstflag = 0;

gradflag = usergradflag; 
hessflag = userhessflag;
lenVarIn = length(varargin);
line_search = 1;
% semicon also needs ntheta and FunStr
semargs = 2;

% Convert to inline function as needed
if ~isempty(FUN)  % will detect empty string, empty matrix, empty cell array
   
   funfcn = optimfcnchk(FUN,'fseminf',lenVarIn,funValCheck,usergradflag,userhessflag);
else
   error('optim:fseminf:InvalidFUN', ...
         'FUN must be a function handle of a cell array of two function handles.')
end

if ~isempty(SEMINFCON)
    % SEMINFCON cannot be an inline since variable number of output arguments
    % Use optimfcnchk to figure out if SEMINFCON is an inline or expression
    [userconfcn, msg] = optimfcnchk(SEMINFCON,'fseminf',lenVarIn,funValCheck,false,false,false,ntheta);
    if isa(SEMINFCON,'inline') % an inline object
        error('optim:fseminf:NoInlineSEMINFCON', ...
              'SEMINFCON must be a function, not an inline object.')
    elseif isa(userconfcn,'inline') % an expression turned into an inline by fcnchk
        error('optim:fseminf:NoExprSEMINFCON', ...
              'SEMINFCON must be a function, not an expression.')
    elseif ~isempty(msg)
        error('optim:fseminf:InvalidSEMINFCON','SEMINFCON must be a function.')
    end
   %  semicon is actually called directly by nlconst, but to be
   %   compatible with the other calls to nlconst, call optimfcnchk.
   % Pass 'false' for funValCheck argument as we don't need to check this call.
   [confcn, msg] = optimfcnchk(@semicon,'fseminf',lenVarIn+semargs,false,gradconstflag,false,true);
   if ~isempty(msg)
      error('optim:fseminf:Optimfcnchk',msg)
   end
else
   error('optim:fseminf:NoSeminfConstr', ...
         'No semi-infinite constraint function provided. Use FMINCON instead.')
end

if ntheta < 1
   error('optim:fseminf:IvalidNumOfConstr', ...
         'The number of semi-infinite constraints must be positive.')
end

lenvlb=length(l);
lenvub=length(u);

i=1:lenvlb;
lindex = xnew(i)<l(i);
if any(lindex),
   xnew(lindex)=l(lindex)+1e-4; 
end
i = 1:lenvub;
uindex = xnew(i)>u(i);
if any(uindex)
   xnew(uindex)=u(uindex);
end
x(:) = xnew;

if xnew(i)<l(i),xnew(i)=l(i)+1e-4; end
if xnew(i)>u(i),xnew(i)=u(i);end

x(:) = xnew; s = NaN; GRAD = zeros(numberOfVariables,1); HESS = [];
% Evaluate user function to get number of function values at x
switch funfcn{1}
case 'fun'
   f= feval(funfcn{3},x,varargin{:});
case 'fungrad'
   [f,GRAD(:)]= feval(funfcn{3},x,varargin{:});
case 'fungradhess'
   [f,GRAD(:)]= feval(funfcn{3},x,varargin{:});
case 'fun_then_grad'
   f= feval(funfcn{3},x,varargin{:});
   GRAD(:) = feval(funfcn{4},x,varargin{:});
case 'fun_then_grad_then_hess'
   f= feval(funfcn{3},x,varargin{:}); 
   GRAD(:) = feval(funfcn{4},x,varargin{:});
otherwise
   error('optim:fseminf:InvalidCalltype','Undefined calltype in FSEMINF.')
end
f= f(:);
K = cell(1,ntheta);

try
    switch userconfcn{1}
    case 'fun'
        [ctmp,ceqtmp,K{:},stmp] = feval(userconfcn{3},x,s,varargin{:});
        c = ctmp(:); ceq = ceqtmp(:);
    otherwise
        error('optim:fseminf:InvalidCalltype','Undefined calltype in FSEMINF.')
    end
catch
    if isa(userconfcn{3},'function_handle')
        funstr = func2str(userconfcn{3});
    else
        funstr = userconfcn{3};
    end
    error('optim:fseminf:BadUserFcn', ...
          'Error evaluating user supplied function %s:\n%s',funstr,lasterr)
end

just_user_constraints = length(c(:));

POINT =[]; NEWLAMBDA =[]; LAMBDA = []; NPOINT =[]; FLAG = 2;
OLDLAMBDA = [];
switch confcn{1}
case 'fun'
   [ctmp,ceqtmp,NPOINT,NEWLAMBDA,OLDLAMBDA,LOLD,s] =...
      feval(confcn{3},xnew,LAMBDA,NEWLAMBDA,OLDLAMBDA,...
      POINT,FLAG,s,ntheta,userconfcn,varargin{:});
   c = ctmp(:); ceq = ceqtmp(:);
   cGRAD = zeros(numberOfVariables,length(c));
   ceqGRAD = zeros(numberOfVariables,length(ceq));
otherwise
   error('optim:fseminf:UndefinedCalltype','Undefined calltype in FSEMINF.')
end

non_eq = length(ceq);
non_ineq = length(c);
[lin_eq,Aeqcol] = size(Aeq);
[lin_ineq,Acol] = size(A);
[cgrow, cgcol]= size(cGRAD);
[ceqgrow, ceqgcol]= size(ceqGRAD);

if ~isempty(Aeq) && Aeqcol ~= numberOfVariables
   error('optim:fseminf:InvalidSizeOfAeq','Aeq has the wrong number of columns.')
end
if ~isempty(A) && Acol ~= numberOfVariables
   error('optim:fseminf:InvalidSizeOfA','A has the wrong number of columns.')
end
if  cgrow~=numberOfVariables && cgcol~=non_ineq
   error('optim:fseminf:InvalidSizeOfGC','Gradient of the nonlinear inequality constraints is the wrong size.')
end
if ceqgrow~=numberOfVariables && ceqgcol~=non_eq
   error('optim:fseminf:InvalidSizeOfGCeq','Gradient of the nonlinear equality constraints is the wrong size.')
end

OUTPUT.algorithm = 'semi-infinite, SQP, Quasi-Newton, line_search';  % override nlconst output
if diagnostics > 0
   % Do diagnostics on information so far
   diagnose('fseminf',OUTPUT,usergradflag,userhessflag,userconstflag,usergradconstflag,...
      line_search,options,defaultopt,x,non_eq,...
      just_user_constraints,lin_eq,lin_ineq,LB,UB,funfcn,confcn,f,GRAD,HESS, ...
      c(1:just_user_constraints),ceq,cGRAD(:,1:just_user_constraints),ceqGRAD);
end

GRAD=zeros(numberOfVariables,1);
HESS = [];

[x,FVAL,lambda,EXITFLAG,OUTPUT]=...
   nlconst(funfcn,x,l,u,full(A),B,full(Aeq),Beq,confcn,options,defaultopt, ...
   verbosity,gradflag,gradconstflag,hessflag,meritFunctionType,...
   f,GRAD,HESS,c,ceq,cGRAD,ceqGRAD,ntheta,userconfcn,varargin{:});
LAMBDA = lambda;
LAMBDA.ineqnonlin = lambda.ineqnonlin(1:just_user_constraints);
% Unimplemented feature: multipliers of semi-inf constraints 
% LAMBDA.semi_infinite = lambda.ineqnonlin(just_user_constraints+1:end);
OUTPUT.algorithm = 'semi-infinite, SQP, Quasi-Newton, line_search';  % override nlconst output

% end seminf
