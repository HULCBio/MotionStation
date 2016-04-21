function [x,FVAL,ATTAINFACTOR,EXITFLAG,OUTPUT,LAMBDA] = fgoalattain(FUN,x,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON,options,varargin)
%FGOALATTAIN solves the multi-objective goal attainment optimization problem.
%
%   X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT)
%   tries to make the objective functions (F) supplied by the function FUN
%   attain the goals (GOAL) by varying X. The goals are weighted according to
%   WEIGHT. In doing so the following nonlinear programming problem is solved:
%            min     { LAMBDA :  F(X)-WEIGHT.*LAMBDA<=GOAL } 
%          X,LAMBDA  
%
%   FUN accepts input X and returns a vector (matrix) of function values F 
%   evaluated at X. X0 may be a scalar, vector, or matrix.  
%
%   X=FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B) solves the goal attainment problem
%   subject to the linear inequalities A*X <= B.
%
%   X=FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq) solves the goal
%   attainment problem subject to the linear equalities Aeq*X = Beq as
%   well.  
%
%   X=FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB) defines a set of lower 
%   and upper bounds on the design variables, X, so that the solution is in 
%   the range LB <= X <= UB. Use empty matrices for LB and U if no bounds 
%   exist. Set LB(i) = -Inf if X(i) is unbounded below; set UB(i) = Inf if X(i) is 
%   unbounded above.
%   
%   X=FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON) subjects the 
%   goal attainment problem to the constraints defined in NONLCON (usually an 
%   M-file: NONLCON.m). The function NONLCON should return the vectors
%   C and Ceq, representing the nonlinear inequalities and equalities respectively, 
%   when called with feval: [C, Ceq] = feval(NONLCON,X). FGOALATTAIN 
%   optimizes such that C(X)<=0 and Ceq(X)=0.
%
%   X=FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS)
%   minimizes the with default optimization parameters replaced by values
%   in the structure OPTIONS, an argument created with the OPTIMSET
%   function.  See OPTIMSET for details. Used options are Display, TolX,
%   TolFun, TolCon, DerivativeCheck, FunValCheck, GradObj, GradConstr,
%   MaxFunEvals, MaxIter, MeritFunction, GoalsExactAchieve, Diagnostics,
%   DiffMinChange, DiffMaxChange and TypicalX. Use the GradObj option to
%   specify that FUN may be called with two output arguments where the
%   second, G, is the partial derivatives of the function df/dX, at the
%   point X: [F,G] = feval(FUN,X). Use the GradConstr option to specify
%   that NONLCON may be called with four output arguments: [C,Ceq,GC,GCeq]
%   = feval(NONLCON,X) where GC is the partial derivatives of the
%   constraint vector of inequalities C an GCeq is the partial derivatives
%   of the constraint vector of equalities Ceq. Use OPTIONS = [] as a
%   place holder if no options are set.
%
%   [X,FVAL]=FGOALATTAIN(FUN,X0,...) returns the value of the objective 
%   function FUN at the solution X.
%
%   [X,FVAL,ATTAINFACTOR]=FGOALATTAIN(FUN,X0,...) returns the attainment
%   factor at the solution X. If ATTAINFACTOR is negative, the goals have
%   been over- achieved; if ATTAINFACTOR is positive, the goals have been
%   under-achieved.
%
%   [X,FVAL,ATTAINFACTOR,EXITFLAG]=FGOALATTAIN(FUN,X0,...) returns an EXITFLAG
%   that describes the exit condition of FGOALATTAIN. Possible values of EXITFLAG
%   and the corresponding exit conditions are
%
%     1  FGOALATTAIN converged to a solution X.
%     4  Magnitude of search direction smaller than the specified tolerance and
%         constraint violation less than options.TolCon.
%     5  Magnitude of directional derivative less than the specified tolerance
%         and constraint violation less than options.TolCon.
%     0  Maximum number of function evaluations or iterations reached.
%    -1  Optimization terminated by the output function.
%    -2  No feasible point found.
%   
%   [X,FVAL,ATTAINFACTOR,EXITFLAG,OUTPUT]=FGOALATTAIN(FUN,X0,...) returns a
%   structure OUTPUT with the number of iterations taken in
%   OUTPUT.iterations, the number of function evaluations in
%   OUTPUT.funcCount, the algorithm used in OUTPUT.algorithm, and the exit
%   message in OUTPUT.message.
% 
%   [X,FVAL,ATTAINFACTOR,EXITFLAG,OUTPUT,LAMBDA]=FGOALATTAIN(FUN,X0,...)
%   returns the Lagrange multiplier at the solution X: LAMBDA.lower for
%   LB, LAMBDA.upper for UB, LAMBDA.ineqlin is for the linear
%   inequalities, LAMBDA.eqlin is for the linear equalities,
%   LAMBDA.ineqnonlin is for the nonlinear inequalities, and
%   LAMBDA.eqnonlin is for the nonlinear equalities.
%
%   For more details, type the M-file FGOALATTAIN.M.
%
%   See also OPTIMSET, OPTIMGET.

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.25.6.7 $  $Date: 2004/04/16 22:09:57 $

% ---------------------More Details---------------------------
% [x]=fgoalattain(F,x,GOAL,WEIGHT,[],[],[],[],[],[],[],OPTIONS)
% Solves the goal attainment problem where:
%
%  X  Is a set of design parameters which can be varied.
%  F  Is a set of objectives which are dependent on X.
%  GOAL Set of design goals. The optimizer will try to make 
%         F<GOAL, F=GOAL, or F>GOAL depending on the formulation.
%  WEIGHT Set of weighting parameters which determine the 
%         relative under or over achievement of the objectives.
%         Notes:
%           1.Setting WEIGHT=abs(GOAL)  will try to make the objectives
%             less than the goals resulting in roughly the same 
%             percentage under or over achievement of the goals.
%             Note: use WEIGHT 1 for GOALS that are 0 (see Note 3 below).
%           2. Setting WEIGHT=-abs(GOAL) will try to make the objectives
%              greater then the goals resulting in roughly the same percentage 
%              under- or over-achievement in the goals.
%             Note: use WEIGHT 1 for GOALS that are 0 (see Note 3 below).
%           3. Setting WEIGHT(i)=0  indicates a hard constraint.
%              i.e. F<=GOAL.
%  OPTIONS.GoalsExactAchieve indicates the number of objectives for which it is
%      required for the objectives (F) to equal the goals (GOAL). 
%      Such objectives should be partitioned into the first few 
%      elements of F.
%      The remaining parameters determine tolerance settings.
%          
%
%
defaultopt = struct('Display','final',...
   'TolX',1e-6,'TolFun',1e-6,'TolCon',1e-6,'DerivativeCheck','off',...
   'Diagnostics','off','FunValCheck','off',...
   'GradObj','off','GradConstr','off','MaxFunEvals','100*numberOfVariables',...
   'MaxIter',400,...
   'MaxSQPIter','10*max(numberOfVariables,numberOfInequalities+numberOfBounds)',...
   'Hessian','off','LargeScale','off',... 
   'DiffMaxChange',1e-1,'DiffMinChange',1e-8, 'MeritFunction','multiobj',...
   'GoalsExactAchieve', 0,'TypicalX','ones(numberOfVariables,1)', ...
   'OutputFcn',[]);
% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(FUN,'defaults')
   x = defaultopt;
   return
end

caller='fgoalattain';

if nargin < 12, options = [];
   if nargin < 11, NONLCON = [];
      if nargin < 10, UB = [];
         if nargin < 9, LB = [];
            if nargin < 8, Beq = [];
               if nargin < 7, Aeq = [];
                  if nargin < 6, B = [];
                     if nargin < 5, A = [];
                        if nargin < 4
                          error('optim:fgoalattain:NotEnoughInputs', ...
                                'fgoalattain requires four input arguments.')
                        end,end,end,end,end,end,end,end,end 
                        
% Check for non-double inputs
if ~isa(x,'double') || ~isa(GOAL,'double') || ~isa(WEIGHT,'double') || ...
     ~isa(A,'double') || ~isa(B,'double') || ~isa(Aeq,'double') ...
     || ~isa(Beq,'double') || ~isa(LB,'double') || ~isa(UB,'double')
  error('optim:fgoalattain:NonDoubleInput', ...                                            
        'FGOALATTAIN only accepts inputs of data type double.')
end

xnew=[x(:);0];

numberOfVariablesplus1 = length(xnew);
numberOfVariables = numberOfVariablesplus1 - 1;
WEIGHT = WEIGHT(:);
GOAL = GOAL(:);

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
   [FVAL,ATTAINFACTOR,LAMBDA] = deal([]);
   OUTPUT.iterations = 0;
   OUTPUT.funcCount = 0;
   OUTPUT.stepsize = [];
   OUTPUT.algorithm = 'goal attainment SQP, Quasi-Newton, line_search';
   OUTPUT.firstorderopt = [];
   OUTPUT.cgiterations = [];
   OUTPUT.message = msg;
   x(:) = xnew(1:numberOfVariables);
   if verbosity > 0
      disp(msg)
   end
   return
end

neqgoals = optimget(options, 'GoalsExactAchieve',defaultopt,'fast');
% meritFunctionType is 1 unless changed by user to fmincon merit function;
% formerly options(7)
% 0 uses the fmincon single-objective merit and Hess; 1 is the default
meritFunctionType = strcmp(optimget(options,'MeritFunction',defaultopt,'fast'),'multiobj');

lenVarIn = length(varargin);
% goalcon and goalfun also take: neqgoals,funfcn,gradfcn,WEIGHT,GOAL,x
goalargs = 6; 

funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
gradflag = strcmp(optimget(options,'GradObj',defaultopt,'fast'),'on');
gradconstflag = strcmp(optimget(options,'GradConstr',defaultopt,'fast'),'on');
hessflag = strcmp(optimget(options,'Hessian',defaultopt,'fast'),'on');
if hessflag
   warning('optim:fgoalattain:UserHessNotUsed','FGOALATTAIN does not use user-supplied Hessian.')
   hessflag = 0;
end

if isempty(NONLCON)
   constflag = 0;
else
   constflag = 1;
end

line_search = strcmp(optimget(options,'LargeScale',defaultopt,'fast'),'off'); % 0 means trust-region, 1 means line-search
if ~line_search
   warning('optim:fgoalattain:NoLargeScale', ...
           'Large-scale algorithm not currently available for this problem type.')
   line_search = 1;
end

% If nonlinear constraints exist, need 
%  either both function and constraint gradients, or not
if constflag
   if gradflag && ~gradconstflag
      gradflag = 0;
   elseif ~gradflag && gradconstflag
      gradconstflag = 0;
   end
end

% Convert to inline function as needed
% FUN is called from goalcon; goalfun is based only on x
if ~isempty(FUN)  % will detect empty string, empty matrix, empty cell array
   [funfcn, msg] = optimfcnchk(FUN,'goalcon',length(varargin),funValCheck, ...
       gradflag,hessflag);
else
   error('optim:fgoalattain:InvalidFUN', ...
         'FUN must be a function handle or a cell array of two function handles.')
end
% Pass in false for funValCheck argument as goalfun is not a user function
[ffun, msg] = optimfcnchk(@goalfun,'fgoalattain',lenVarIn+goalargs,false,gradflag);


if constflag % NONLCON is non-empty
   [confcn, msg] = ...
      optimfcnchk(NONLCON,'goalcon',length(varargin),funValCheck,gradconstflag,0,1);
else
   confcn{1} = '';
end
% Pass in false for funValCheck argument as goalfun is not a user function
[cfun, msg]= optimfcnchk(@goalcon,'fgoalattain',lenVarIn+goalargs,false,gradconstflag,0,1); 

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
   error('optim:fgoalattain:UndefinedCalltype','Undefined calltype in FGOALATTAIN.')
end
user_f = user_f(:);
len_user_f = length(user_f);

% error checking
if length(GOAL) ~= len_user_f
    error('optim:fgoalattain:InvalidGoalAndFunSizes', ...
          'Size of GOAL must be equal to the size of F returned by FUN.')
end
if length(WEIGHT) ~= length(GOAL)
    error('optim:fgoalattain:InvalidWeigthAndGoalSizes', ...
          'Size of WEIGHT must be equal to the size of GOAL.')
end    

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
   error('optim:fgoalattain:InvalidCalltype','Undefined calltype in FGOALATTAIN.')
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
   error('optim:fgoalattain:InvalidCalltype','Undefined calltype in FGOALATTAIN.')
end

non_eq = length(ceq);
non_ineq = length(c);
[lin_eq,Aeqcol] = size(Aeq);
[lin_ineq,Acol] = size(A);
[cgrow, cgcol]= size(cGRAD);
[ceqgrow, ceqgcol]= size(ceqGRAD);

eq = non_eq + lin_eq;
ineq = non_ineq + lin_ineq;

if ~isempty(Aeq) && Aeqcol ~= numberOfVariables
   error('optim:fgoalattain:InvalidSizeOfAeq','Aeq has the wrong number of columns.')
end
if ~isempty(A) && Acol ~= numberOfVariables
   error('optim:fgoalattain:InvalidSizeOfA','A has the wrong number of columns.')
end
if  cgrow~=numberOfVariables && cgcol~=non_ineq
   error('optim:fgoalattain:InvalidSizeOfGC','Gradient of the nonlinear inequality constraints is the wrong size.')
end
if ceqgrow~=numberOfVariables && ceqgcol~=non_eq
   error('optim:fgoalattain:InvalidSizeOfGCeq','Gradient of the nonlinear equality constraints is the wrong size.')
end

just_user_constraints = non_ineq - len_user_f - neqgoals;
OUTPUT.algorithm = 'goal attainment SQP, Quasi-Newton, line_search';  % override nlconst output

if diagnostics > 0
   % Do diagnostics on information so far
   msg = diagnose('fgoalattain',OUTPUT,gradflag,hessflag,constflag,gradconstflag,...
      line_search,options,defaultopt,xnew(1:end-1),non_eq,...
      just_user_constraints,lin_eq,lin_ineq,LB,UB,funfcn,confcn,f,GRAD,HESS, ...
      c(1:just_user_constraints),ceq,cGRAD(1:just_user_constraints,:),ceqGRAD);
end

% add extra column to account for extra xnew component
A =[A,zeros(lin_ineq,1)];
Aeq =[Aeq,zeros(lin_eq,1)];

[xnew,ATTAINFACTOR,lambda,EXITFLAG,OUTPUT]=...
   nlconst(ffun,xnew,l,u,full(A),B,full(Aeq),Beq,cfun,options,defaultopt, ...
   verbosity,gradflag,gradconstflag,hessflag,meritFunctionType, ...
   f,GRAD,HESS,c,ceq,cGRAD,ceqGRAD,neqgoals,funfcn,confcn,WEIGHT,GOAL,x,varargin{:});
if ~isempty(lambda)
    just_user_constraints = length(lambda.ineqnonlin) - len_user_f - neqgoals;
    lambda.ineqnonlin = lambda.ineqnonlin(1:just_user_constraints);
end
LAMBDA=lambda;

OUTPUT.algorithm = 'goal attainment SQP, Quasi-Newton, line_search';  % override nlconst output

% compute FVAL since it is attainfactor instead of F(x)
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
   error('optim:fgoalattain:InvalidCalltype','Undefined calltype in FGOALATTAIN.');
end
FVAL = user_f;

