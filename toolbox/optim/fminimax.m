function [x,FVAL,MAXFVAL,EXITFLAG,OUTPUT,LAMBDA] = fminimax(FUN,x,A,B,Aeq,Beq,LB,UB,NONLCON,options,varargin)
%FMINIMAX finds a minimax solution of a function of several variables.
%   FMINIMAX attempts to solve the following problem:
%   min (max {FUN(X} )  where FUN and X can be vectors or matrices.
%    X 
% 
%   X=FMINIMAX(FUN,X0) starts at X0 and finds a minimax solution X to 
%   the functions in FUN. FUN accepts input X and returns a vector
%   (matrix) of function values F evaluated at X. X0 may be a scalar,
%   vector, or matrix. 
%
%   X=FMINIMAX(FUN,X0,A,B) solves the minimax problem subject to the
%   linear inequalities A*X <= B.
%
%   X=FMINIMAX(FUN,X0,A,B,Aeq,Beq) solves the minimax problem
%   subject to the linear equalities Aeq*X = Beq as well.  (Set A=[] and B=[] 
%   if no inequalities exist.)
%
%   X=FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB) defines a set of lower 
%   and upper bounds on the design variables, X, so that the solution is 
%   in the range LB <= X <= UB. You may use empty matrices for LB and UB
%   if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below; 
%   set UB(i) = Inf if X(i) is unbounded above.
%   
%   X=FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON) subjects the 
%   goal attainment problem to the constraints defined in NONLCON (usually an 
%   M-file: NONLCON.m). The function NONLCON should return the vectors
%   C and Ceq, representing the nonlinear inequalities and equalities 
%   respectively, when called with feval: [C, Ceq] = feval(NONLCON,X). FMINIMAX 
%   optimizes such that C(X)<=0 and Ceq(X)=0.
%
%   X=FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS) minimizes with the
%   default optimization parameters replaced by values in the structure 
%   OPTIONS, an argument created with the OPTIMSET function. See OPTIMSET 
%   for details.  Used options are Display, TolX, TolFun, TolCon, 
%   DerivativeCheck, FunValCheck GradObj, GradConstr, MaxFunEvals, MaxIter,
%   MeritFunction, MinAbsMax, Diagnostics, DiffMinChange, DiffMaxChange
%   and TypicalX. Use the GradObj option to specify that FUN may be called
%   with two output arguments where the second, G, is the partial
%   derivatives of the function df/dX, at  the point X: [F,G] =
%   feval(FUN,X). Use the GradConstr option to specify that  NONLCON may be
%   called with four output arguments:  [C,Ceq,GC,GCeq] = feval(NONLCON,X)
%   where GC is the partial derivatives of  the constraint vector of
%   inequalities C an GCeq is the partial derivatives  of the constraint
%   vector of equalities Ceq. Use OPTIONS = [] as a place  holder if no
%   options are set.
%
%   [X,FVAL]=FMINIMAX(FUN,X0,...) returns the value of the objective 
%   functions at the solution X: FVAL=feval(FUN,X).
%
%   [X,FVAL,MAXFVAL]=FMINIMAX(FUN,X0,...) returns MAXFVAL = max { FUN(X) } 
%   at the solution X.
%
%   [X,FVAL,MAXFVAL,EXITFLAG]=FMINIMAX(FUN,X0,...) returns an EXITFLAG that 
%   describes the exit condition of FMINIMAX. Possible values of EXITFLAG and
%   the corresponding exit conditions are
%
%     1  FMINIMAX converged to a solution X.
%     4  Magnitude of search direction smaller than the specified tolerance and 
%         constraint violation less than options.TolCon.
%     5  Magnitude of directional derivative smaller than the specified tolerance
%         and constraint violation less than options.TolCon.
%     0  Maximum number of function evaluations or iterations reached.
%    -1  Optimization terminated by the output function.
%    -2  No feasible point found.
%   
%   [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT]=FMINIMAX(FUN,X0,...) returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations, the number
%   of function evaluations in OUTPUT.funcCount, the algorithm used in 
%   OUTPUT.algorithm, and the exit message in OUTPUT.message.
%
%   [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT,LAMBDA]=FMINIMAX(FUN,X0,...) returns the 
%   Lagrange multipliers at the solution X: LAMBDA.lower for LB, LAMBDA.upper 
%   for UB, LAMBDA.ineqlin is for the linear inequalities, LAMBDA.eqlin is for 
%   the linear equalities, LAMBDA.ineqnonlin is for the nonlinear inequalities, 
%   and LAMBDA.eqnonlin is for the nonlinear equalities.
%
%   Examples
%     FUN can be specified using @:
%        x = fminimax(@myfun,[2 3 4])
%
%   where MYFUN is a MATLAB function such as:
%
%       function F = myfun(x)
%       F = cos(x);
%
%   FUN can also be an anonymous function:
%
%       x = fminimax(@(x) sin(3*x),[2 5])
%
%   If FUN is parameterized, you can use anonymous functions to capture the 
%   problem-dependent parameters. Suppose you want to solve a minimax problem
%   where the objectives given in the function MYFUN are parameterized by its
%   second argument A. Here MYFUN is an M-file function such as
%
%       function F = myfun(x,a)
%       F = [x(1)^2 + a*x(2)^2;
%            x(2) - x(1)];
%
%   To optimize for a specific value of A, first assign the value to A. Then 
%   create a one-argument anonymous function that captures that value of A 
%   and calls MYFUN with two arguments. Finally pass this anonymous function 
%   to FMINIMAX:
%
%       a = 2; % define parameter first
%       x = fminimax(@(x) myfun(x,a),[1;1])
%
%   See also OPTIMSET, @, INLINE, FGOALATTAIN, LSQNONLIN.

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.25.6.7 $  $Date: 2004/04/16 22:09:59 $


defaultopt = struct('Display','final',...
   'TolX',1e-6,'TolFun',1e-6,'TolCon',1e-6,'DerivativeCheck','off',...
   'Diagnostics','off','FunValCheck','off', ...
   'GradObj','off','GradConstr','off','MaxFunEvals','100*numberOfVariables',...
   'MaxIter',400,...
   'MaxSQPIter','10*max(numberOfVariables,numberOfInequalities+numberOfBounds)',...
   'Hessian','off','LargeScale','off',... % not used
   'DiffMaxChange',1e-1,'DiffMinChange',1e-8, 'MeritFunction','multiobj',...
   'MinAbsMax', 0,'TypicalX','ones(numberOfVariables,1)', ...
		    'OutputFcn',[]);
% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(FUN,'defaults')
   x = defaultopt;
   return
end

if nargin < 10, options = [];
   if nargin < 9, NONLCON = [];
      if nargin < 8, UB = [];
         if nargin < 7, LB = [];
            if nargin < 6, Beq = [];
               if nargin < 5, Aeq = [];
                  if nargin < 4, B = [];
                     if nargin < 3, A = [];
                        if nargin < 2
                          error('optim:fminimax:NotEnoughInputs', ...
                                'fminimax requires two input arguments.')
                        end,end,end,end,end,end,end,end,end 
                        
% Check for non-double inputs
if ~isa(x,'double') || ~isa(A,'double') || ~isa(B,'double') || ~isa(Aeq,'double') ...
     || ~isa(Beq,'double') || ~isa(LB,'double') || ~isa(UB,'double')
  error('optim:fminimax:NonDoubleInput', ...                                            
        'FMINIMAX only accepts inputs of data type double.')
end

xnew=[x(:); 0 ];

numberOfVariablesplus1 = length(xnew);
numberOfVariables = numberOfVariablesplus1 - 1;

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

[xnew(1:numberOfVariables),l,u,msg] = checkbounds(xnew(1:numberOfVariables),LB,UB,numberOfVariables);
if ~isempty(msg)
   EXITFLAG = -2;
   [FVAL,MAXFVAL,LAMBDA] = deal([]);
   OUTPUT.iterations = 0;
   OUTPUT.funcCount = 0;
   OUTPUT.stepsize = [];
   OUTPUT.algorithm = 'minimax SQP, Quasi-Newton, line_search';  
   OUTPUT.firstorderopt = [];
   OUTPUT.cgiterations = [];
   OUTPUT.message = msg;
   x(:) = xnew(1:numberOfVariables);
   if verbosity > 0
      disp(msg)
   end
   return
end

neqgoals = optimget(options, 'MinAbsMax',defaultopt,'fast');

% meritFunctionType is 1 unless changed by user to fmincon merit function;
% formerly options(7)
% 0 uses the fmincon single-objective merit and Hess; 1 is the default
meritFunctionType = strcmp(optimget(options,'MeritFunction',defaultopt,'fast'),'multiobj');
lenVarIn = length(varargin);
% goalcon and goalfun also take: neqgoals,funfcn,gradfcn,WEIGHT,GOAL,x
goalargs = 6; 

funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
usergradflag = strcmp(optimget(options,'GradObj',defaultopt,'fast'),'on');
usergradconstflag = strcmp(optimget(options,'GradConstr',defaultopt,'fast'),'on');
userhessflag = strcmp(optimget(options,'Hessian',defaultopt,'fast'),'on');
if userhessflag
   warning('optim:fminimax:UserHessNotUsed','FMINIMAX does not use user-supplied Hessian.')
   userhessflag = 0;
end

if isempty(NONLCON)
   userconstflag = 0;
else
   userconstflag = 1;
end

line_search = strcmp(optimget(options,'LargeScale',defaultopt,'fast'),'off'); % 0 means trust-region, 1 means line-search
if ~line_search
   warning('optim:fminimax:NoLargeScale','Large-scale algorithm not currently available for this problem type.')
   line_search = 1;
end

gradflag = 1; % always can compute gradient of goalfun since based on x
hessflag = 0;
% If (user) nonlinear constraints exist, need 
%  either both function and constraint gradients, or not

if userconstflag
   if usergradflag && usergradconstflag
      gradconstflag = 1;
   elseif usergradflag && ~usergradconstflag
      usergradflag = 0;
      gradconstflag = 0;
   elseif ~usergradflag && usergradconstflag
      usergradconstflag = 0;
      gradconstflag = 0;
   else
      gradconstflag = 0;
   end
else % No user nonlinear constraints
   if usergradflag
      gradconstflag = 1;
   else
      gradconstflag = 0;
   end
end

   

% Convert to inline function as needed
if ~isempty(FUN)  % will detect empty string, empty matrix, empty cell array
   funfcn = optimfcnchk(FUN,'goalcon',length(varargin),funValCheck,usergradflag,userhessflag);
else
   error('optim:fminimax:invalidFUN', ...
         'FUN must be a function handle of a cell array of two function handles.')
end
% We can always compute gradient since based only on xnew.
% Pass in false for funValCheck argument as goalfun is not a user function.
ffun = optimfcnchk(@goalfun,'fminimax',lenVarIn+goalargs,false,gradflag);

if userconstflag % NONLCON is non-empty, goalcon is the caller to NONLCON
   confcn = ...
      optimfcnchk(NONLCON,'goalcon',length(varargin),funValCheck,usergradconstflag,0,1);
else
   confcn{1} = '';
end
% Pass in false for funValCheck argument as goalfun is not a user function
cfun = optimfcnchk(@goalcon,'fminimax',lenVarIn+goalargs,false,gradconstflag,0,1); 

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
x(:) = xnew(1:end-1);

% Evaluate user function to get number of function values at x, not xnew!
switch funfcn{1}
case 'fun'
   user_f = feval(funfcn{3},x,varargin{:});
case 'fungrad'
   user_f = feval(funfcn{3},x,varargin{:});
   
case 'fungradhess'
   user_f = feval(funfcn{3},x,varargin{:});
   
case 'fun_then_grad'
   user_f = feval(funfcn{3},x,varargin{:}); 
case 'fun_then_grad_then_hess'
   user_f = feval(funfcn{3},x,varargin{:}); 
otherwise
   error('optim:fminimax:UndefinedCalltype','Undefined calltype in FMINIMAX.')
end
user_f = user_f(:);
len_user_f = length(user_f);

WEIGHT = ones(len_user_f,1);
GOAL = zeros(len_user_f,1);

GRAD=zeros(numberOfVariablesplus1,1);
HESS = [];
extravarargin= {neqgoals,funfcn,confcn,WEIGHT,GOAL,x,varargin{:}}; 
% Evaluate goal function
switch ffun{1}
case 'fun'
   f = feval(ffun{3},xnew,extravarargin{:});
case 'fungrad'
   [f,GRAD] = feval(ffun{3},xnew,extravarargin{:});
  
case 'fungradhess'
   [f,GRAD,HESS] = feval(ffun{3},xnew,extravarargin{:});

case 'fun_then_grad'
   f = feval(ffun{3},xnew,extravarargin{:}); 
   GRAD = feval(ffun{4},xnew,extravarargin{:});
  
case 'fun_then_grad_then_hess'
   f = feval(ffun{3},xnew,extravarargin{:}); 
   GRAD = feval(ffun{4},xnew,extravarargin{:});
   HESS = feval(ffun{5},xnew,extravarargin{:});
   
otherwise
   error('optim:fminimax:UndefinedCalltype','Undefined calltype in FMINIMAX.')
end



% Evaluate goal constraints
switch cfun{1}
case 'fun'
   [ctmp,ceqtmp] = feval(cfun{3},xnew,extravarargin{:});
   c = ctmp(:); ceq = ceqtmp(:);
   cGRAD = zeros(numberOfVariablesplus1,length(c));
   ceqGRAD = zeros(numberOfVariablesplus1,length(ceq));
case 'fungrad'
   [ctmp,ceqtmp,cGRAD,ceqGRAD] = feval(cfun{3},xnew,extravarargin{:});
   c = ctmp(:); ceq = ceqtmp(:);
  
case 'fun_then_grad'
   [ctmp,ceqtmp] = feval(cfun{3},xnew,extravarargin{:});
   c = ctmp(:); ceq = ceqtmp(:);
   [cGRAD,ceqGRAD] = feval(cfun{4},xnew,extravarargin{:});
   
case ''
   c=[]; ceq =[];
   cGRAD = zeros(numberOfVariablesplus1,length(c));
   ceqGRAD = zeros(numberOfVariablesplus1,length(ceq));
otherwise
   error('optim:fminimax:UndefinedCalltype','Undefined calltype in FMINIMAX.')
end

non_eq = length(ceq);
non_ineq = length(c);
[lin_eq,Aeqcol] = size(Aeq);
[lin_ineq,Acol] = size(A);
[cgrow, cgcol]= size(cGRAD);
[ceqgrow, ceqgcol]= size(ceqGRAD);

if ~isempty(Aeq) && Aeqcol ~= numberOfVariables
   error('optim:fminimax:InvalidSizeOfAeq','Aeq has the wrong number of columns.')
end
if ~isempty(A) && Acol ~= numberOfVariables
   error('optim:fminimax:InvalidSizeOfA','A has the wrong number of columns.')
end
if  cgrow~=numberOfVariables && cgcol~=non_ineq
   error('optim:fminimax:InvalidSizeOfGC','Gradient of the nonlinear inequality constraints is the wrong size.')
end
if ceqgrow~=numberOfVariables && ceqgcol~=non_eq
   error('optim:fminimax:InvalidSizeOfGCeq','Gradient of the nonlinear equality constraints is the wrong size.')
end

just_user_constraints = non_ineq - len_user_f - neqgoals;

OUTPUT.algorithm = 'minimax SQP, Quasi-Newton, line_search';
if diagnostics > 0
   % Do diagnostics on information so far
   diagnose('fminimax',OUTPUT,usergradflag,userhessflag,userconstflag,usergradconstflag,...
      line_search,options,defaultopt,xnew(1:end-1),non_eq,...
      just_user_constraints,lin_eq,lin_ineq,l,u,funfcn,confcn,f,GRAD,HESS, ...
      c(1:just_user_constraints),ceq,cGRAD(1:just_user_constraints,:),ceqGRAD);
end


% add extra column to account for extra xnew component
A =[A,zeros(lin_ineq,1)];
Aeq =[Aeq,zeros(lin_eq,1)];

[xnew,MAXFVAL,lambda,EXITFLAG,OUTPUT]=...
   nlconst(ffun,xnew,l,u,full(A),B,full(Aeq),Beq,cfun,options,defaultopt, ...
   verbosity,gradflag,gradconstflag,hessflag,meritFunctionType,...
   f,GRAD,HESS,c,ceq,cGRAD,ceqGRAD,neqgoals,funfcn,confcn,WEIGHT,GOAL,x,varargin{:});
if ~isempty(lambda)
    just_user_constraints = length(lambda.ineqnonlin) - len_user_f - neqgoals;
    lambda.ineqnonlin = lambda.ineqnonlin(1:just_user_constraints);
end
LAMBDA=lambda;

OUTPUT.algorithm = 'minimax SQP, Quasi-Newton, line_search';  % override nlconst output

% compute FVAL since it is lambda instead of F(x)
% Evaluate user function to get number of function values at x, not xnew!
x(:)=xnew(1:end-1);
switch funfcn{1}
case 'fun'
   user_f = feval(funfcn{3},x,varargin{:});
case 'fungrad'
   user_f = feval(funfcn{3},x,varargin{:});
   
case 'fungradhess'
   user_f = feval(funfcn{3},x,varargin{:});
   
case 'fun_then_grad'
   user_f = feval(funfcn{3},x,varargin{:}); 
case 'fun_then_grad_then_hess'
   user_f = feval(funfcn{3},x,varargin{:}); 
otherwise
   error('optim:fminimax:UndefinedCalltype','Undefined calltype in FMINIMAX.')
end
FVAL = user_f;


