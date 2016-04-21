function [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS]= ...
    nlconst(funfcn,x,lb,ub,Ain,Bin,Aeq,Beq,confcn,OPTIONS,defaultopt,...
    verbosity,gradflag,gradconstflag,hessflag,meritFunctionType,...
    fval,gval,Hval,ncineqval,nceqval,gncval,gnceqval,varargin)
%NLCONST Helper function to find the constrained minimum of a function 
%   of several variables. Called by FMINCON, FGOALATTAIN FSEMINF and FMINIMAX.
%
%   [X,OPTIONS,LAMBDA,HESS]=NLCONST('FUN',X0,OPTIONS,lb,ub,'GRADFUN',...
%   varargin{:}) starts at X0 and finds a constrained minimum to 
%   the function which is described in FUN. FUN is a four element cell array
%   set up by PREFCNCHK.  It contains the call to the objective/constraint
%   function, the gradients of the objective/constraint functions, the
%   calling type (used by OPTEVAL), and the calling function name. 
%
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.41.6.9 $  $Date: 2004/04/20 23:19:26 $

%
%   meritFunctionType==5 for fseminf
%                    ==1 for fminimax & fgoalattain (can use 0, but 1 is default)
%                    ==0 for fmincon

% Initialize some parameters
FVAL=[]; lambda_out=[]; OUTPUT=[]; lambdaNLP = []; GRADIENT = []; 

% Handle the output
if isfield(OPTIONS,'OutputFcn')
    outputfcn = optimget(OPTIONS,'OutputFcn',defaultopt,'fast');
else
    outputfcn = defaultopt.OutputFcn;
end
if isempty(outputfcn)
  haveoutputfcn = false;
else
  haveoutputfcn = true;
  xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
end
stop = false;
% For fminimax and fgoalattain, there are 6 extra varargin elements
% preceding what the user passed in. Need to get rid of these for the
% varargin passed to the  outputfcn. For fseminf this is also true, but
% only 2 extra arguments.
if strcmp(funfcn{2},'fminimax') ||  strcmp(funfcn{2},'fgoalattain')
    outputfcnVarargin = varargin(7:end);
elseif strcmp(funfcn{2},'fseminf')
    outputfcnVarargin = varargin(3:end);
else
    outputfcnVarargin = varargin;
end

iter = 0;
XOUT = x(:);
% numberOfVariables must be the name of this variable
numberOfVariables = length(XOUT);
SD = ones(numberOfVariables,1); 
Nlconst = 'nlconst';
bestf = Inf; 

%Make sure that constraints are consistent Ain,Bin,Aeq,Beq
%Only row consistentcy check. Column check is done in the caller function
if ~isempty(Aeq) && ~isequal(size(Aeq,1),length(Beq))
        error('optim:nlconst:AeqAndBeqInconsistent', ...
            'Row dimension of Aeq is inconsistent with length of beq.')
end
if ~isempty(Ain) && ~isequal(size(Ain,1),length(Bin))
        error('optim:nlconst:AinAndBinInconsistent', ...
            'Row dimension of A is inconsistent with length of b.')
end

if isempty(confcn{1})
    constflag = 0;
else
    constflag = 1;
end
stepsize = 1;
HESS=eye(numberOfVariables,numberOfVariables); % initial Hessian approximation.
done = false; 
EXITFLAG = 1;

% Get options
tolX = optimget(OPTIONS,'TolX',defaultopt,'fast');
tolFun = optimget(OPTIONS,'TolFun',defaultopt,'fast');
tolCon = optimget(OPTIONS,'TolCon',defaultopt,'fast');
DiffMinChange = optimget(OPTIONS,'DiffMinChange',defaultopt,'fast');
DiffMaxChange = optimget(OPTIONS,'DiffMaxChange',defaultopt,'fast');
if DiffMinChange >= DiffMaxChange
    error('optim:nlconst:DiffChangesInconsistent', ...
         ['DiffMinChange options parameter is %0.5g, and DiffMaxChange is %0.5g.\n' ...
          'DiffMinChange must be strictly less than DiffMaxChange.'], ...
           DiffMinChange,DiffMaxChange)  
end
DerivativeCheck = strcmp(optimget(OPTIONS,'DerivativeCheck',defaultopt,'fast'),'on');
typicalx = optimget(OPTIONS,'TypicalX',defaultopt,'fast') ;
if ischar(typicalx)
   if isequal(lower(typicalx),'ones(numberofvariables,1)')
      typicalx = ones(numberOfVariables,1);
   else
      error('optim:nlconst:InvalidTypicalX', ...
            'Option ''TypicalX'' must be a numeric value if not the default.')
   end
end
typicalx = typicalx(:); % turn to column vector
maxFunEvals = optimget(OPTIONS,'MaxFunEvals',defaultopt,'fast');
maxIter = optimget(OPTIONS,'MaxIter',defaultopt,'fast');
relLineSrchBnd = optimget(OPTIONS,'RelLineSrchBnd',[]);
relLineSrchBndDuration = optimget(OPTIONS,'RelLineSrchBndDuration',1);
hasBoundOnStep = ~isempty(relLineSrchBnd) && isfinite(relLineSrchBnd) && ...
    relLineSrchBndDuration > 0;
noStopIfFlatInfeas = strcmp(optimget(OPTIONS,'NoStopIfFlatInfeas','off'),'on');
phaseOneTotalScaling = strcmp(optimget(OPTIONS,'PhaseOneTotalScaling','off'),'on');

% In case the defaults were gathered from calling: optimset('fmincon'):
if ischar(maxFunEvals)
    if isequal(lower(maxFunEvals),'100*numberofvariables')
        maxFunEvals = 100*numberOfVariables;
    else
        error('optim:nlconst:InvalidMaxFunEvals', ...
              'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end

% Handle bounds as linear constraints
arglb = ~isinf(lb);
lenlb=length(lb); % maybe less than numberOfVariables due to old code
argub = ~isinf(ub);
lenub=length(ub);
boundmatrix = eye(max(lenub,lenlb),numberOfVariables);
if nnz(arglb) > 0     
    lbmatrix = -boundmatrix(arglb,1:numberOfVariables);% select non-Inf bounds 
    lbrhs = -lb(arglb);
else
    lbmatrix = []; lbrhs = [];
end
if nnz(argub) > 0
    ubmatrix = boundmatrix(argub,1:numberOfVariables);
    ubrhs=ub(argub);
else
    ubmatrix = []; ubrhs=[];
end 

% For fminimax and fgoalattain, an extra "slack" 
% variable (gamma) is added to create the minimax/goal attain
% objective function.  Add an extra element to lb/ub so
% that gamma is unconstrained but we can avoid out of index
% errors for lb/ub (when doing finite-differencing).
if  strcmp(funfcn{2},'fminimax') ||  strcmp(funfcn{2},'fgoalattain')
    lb(end+1) = -Inf;
    ub(end+1) = Inf;
end

% Update constraint matrix and right hand side vector with bound constraints.
A = [lbmatrix;ubmatrix;Ain];
B = [lbrhs;ubrhs;Bin];
if isempty(A)
    A = zeros(0,numberOfVariables); B=zeros(0,1);
end
if isempty(Aeq)
    Aeq = zeros(0,numberOfVariables); Beq=zeros(0,1);
end

% Used for semi-infinite optimization:
s = nan; POINT =[]; NEWLAMBDA =[]; LAMBDA = []; NPOINT =[]; FLAG = 2;
OLDLAMBDA = [];

x(:) = XOUT;  % Set x to have user expected size
% Compute the objective function and constraints
if strcmp(funfcn{2},'fseminf')
    f = fval;
    [ncineq,nceq,NPOINT,NEWLAMBDA,OLDLAMBDA,LOLD,s] = ...
        semicon(x,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s,varargin{:});
else
    f = fval;
    nceq = nceqval; ncineq = ncineqval;  % nonlinear constraints only
end
nc = [nceq; ncineq];
c = [ Aeq*XOUT-Beq; nceq; A*XOUT-B; ncineq];

% Get information on the number and type of constraints.
non_eq = length(nceq);
non_ineq = length(ncineq);
[lin_eq,Aeqcol] = size(Aeq);
[lin_ineq,Acol] = size(A);  % includes upper and lower bounds
eq = non_eq + lin_eq;
ineq = non_ineq + lin_ineq;
ncstr = ineq + eq;
% Boolean inequalitiesExist = true if and only if there exist either
% finite bounds or linear inequalities or nonlinear inequalities. 
% Used only for printing indices of active inequalities at the solution
inequalitiesExist = any(arglb) || any(argub) || size(Ain,1) > 0 || non_ineq > 0;

% Compute the initial constraint violation.
ga=[abs(c( (1:eq)' )) ; c( (eq+1:ncstr)' ) ];
if ~isempty(c)
   mg=max(ga);
else
   mg = 0;
end

if isempty(f)
    error('optim:nlconst:InvalidFUN', ...
          'FUN must return a non-empty objective function.')
end

% Evaluate initial analytic gradients and check size.
if gradflag || gradconstflag
    if gradflag
        gf_user = gval;
    end
    if gradconstflag
        gnc_user = [gnceqval, gncval];   % Don't include A and Aeq yet
    else
        gnc_user = [];
    end
    if isempty(gnc_user) && isempty(nc)
        % Make gc compatible
        gnc = nc'; gnc_user = nc';
    end % isempty(gnc_user) & isempty(nc)
end

OLDX=XOUT;
OLDC=c; OLDNC=nc;
OLDgf=zeros(numberOfVariables,1);
gf=zeros(numberOfVariables,1);
OLDAN=zeros(ncstr,numberOfVariables);
LAMBDA=zeros(ncstr,1);
if strcmp(funfcn{2},'fseminf')
   lambdaNLP = NEWLAMBDA; 
else
   lambdaNLP = zeros(ncstr,1);
end
numFunEvals=1;
numGradEvals=1;

% Display header information.
if meritFunctionType==1
    if isequal(funfcn{2},'fgoalattain')
        header = sprintf(['\n                    Attainment                 Directional \n',...
                ' Iter   F-count       factor      Step-size     derivative    Procedure ']);
        
    else % fminimax
        header = sprintf(['\n                       Max                     Directional \n',...
                ' Iter   F-count  {F,constraints}  Step-size     derivative    Procedure ']);
    end
    formatstrFirstIter = '%5.0f  %5.0f   %12.6g                                            %s';
    formatstr = '%5.0f  %5.0f   %12.4g %12.3g    %12.3g   %s  %s';
else % fmincon or fseminf is caller
    header = sprintf(['\n                               max                   Directional   First-order \n',...
            ' Iter F-count        f(x)   constraint    Step-size   derivative   optimality Procedure ']);
    formatstrFirstIter = '%5.0f  %5.0f %12.6g %12.4g                                         %s';
    formatstr = '%5.0f  %5.0f %12.6g %12.4g %12.3g %12.3g %12.3g %s  %s';
end

how = ''; 
optimError = []; % In case we have convergence in 0th iteration, this needs a value.
%---------------------------------Main Loop-----------------------------
while ~done 
   %----------------GRADIENTS----------------
   
   if ~gradconstflag || ~gradflag || DerivativeCheck
      % Finite Difference gradients (even if just checking analytical)
      POINT = NPOINT; 
      len_nc = length(nc);
      ncstr =  lin_eq + lin_ineq + len_nc;     
      FLAG = 0; % For semi-infinite

      % Compute finite difference gradients
      %
      if DerivativeCheck || ~gradconstflag 
         [gf,gnc,NEWLAMBDA,OLDLAMBDA,s]=finitedifferences(XOUT,x,funfcn,confcn,lb,ub,f,nc, ...
                               [],DiffMinChange,DiffMaxChange,typicalx,[],'all', ...
                               LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s, ...
                                                  varargin{:});
         gnc = gnc'; % nlconst requires the transpose of the Jacobian
      else
         % no derivative check and user-supplied constraint gradients.             
         % Estimate objective gradient only.
         gf=finitedifferences(XOUT,x,funfcn,[],lb,ub,f,[],[], ...   
                         DiffMinChange,DiffMaxChange,typicalx,[], ...
                         'all',[],[],[],[],[],varargin{:});
      end

      % Gradient check
      if DerivativeCheck && (gradflag || gradconstflag) % analytic exists
                           
         disp('Function derivative')
         if gradflag
            gfFD = gf;
            gf = gf_user;
            
            if isa(funfcn{4},'inline')
               graderr(gfFD, gf, formula(funfcn{4}));
            else
               graderr(gfFD, gf, funfcn{4});
            end
         end
         
         if gradconstflag
            gncFD = gnc; 
            gnc = gnc_user;
            
            disp('Constraint derivative')
            if isa(confcn{4},'inline')
               graderr(gncFD, gnc, formula(confcn{4}));
            else
               graderr(gncFD, gnc, confcn{4});
            end
         end         
         DerivativeCheck = 0;
      elseif gradflag || gradconstflag
         if gradflag
            gf = gf_user;
         end
         if gradconstflag
            gnc = gnc_user;
         end
      end % DerivativeCheck == 1 &  (gradflag | gradconstflag)
      
      FLAG = 1; % For semi-infinite
      numFunEvals = numFunEvals + numberOfVariables;

   else% gradflag & gradconstflag & no DerivativeCheck 
      gnc = gnc_user;
      gf = gf_user;
   end  
   
   % Now add in Aeq, and A
   if ~isempty(gnc)
      gc = [Aeq', gnc(:,1:non_eq), A', gnc(:,non_eq+1:non_ineq+non_eq)];
   elseif ~isempty(Aeq) || ~isempty(A)
      gc = [Aeq',A'];
   else
      gc = zeros(numberOfVariables,0);
   end
   AN=gc';
   
   % Iteration 0 is handled separately below
   if iter > 0 % All but 0th iteration ----------------------------------------
       % Compute the first order KKT conditions.
       if meritFunctionType == 1 
           % don't use this stopping test for fminimax or fgoalattain
           optimError = inf;
       else
           if strcmp(funfcn{2},'fseminf'), lambdaNLP = NEWLAMBDA; end
           normgradLag = norm(gf + AN'*lambdaNLP,inf);
           normcomp = norm(lambdaNLP(eq+1:ncstr).*c(eq+1:ncstr),inf);
           if isfinite(normgradLag) && isfinite(normcomp)
               optimError = max(normgradLag, normcomp);
           else
               optimError = inf;
           end
       end
       feasError  = mg;
       optimScal = 1; feasScal = 1; 
       
       % Print iteration information starting with iteration 1
       if verbosity > 1
           if meritFunctionType == 1,
               gamma = mg+f;
               CurrOutput = sprintf(formatstr,iter,numFunEvals,gamma,...
                   stepsize,gf'*SD,how,howqp); 
               disp(CurrOutput)
           else
               CurrOutput = sprintf(formatstr,iter,numFunEvals,f,mg,...
                   stepsize,gf'*SD,optimError,how,howqp); 
               disp(CurrOutput)
           end
       end
       % OutputFcn call
       if haveoutputfcn
           [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,XOUT,xOutputfcn,'iter',iter,numFunEvals, ...
               f,mg,stepsize,gf,SD,meritFunctionType,optimError,how,howqp,outputfcnVarargin{:});
           if stop  % Stop per user request.
               [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                   cleanUpInterrupt(xOutputfcn,optimValues);
               if verbosity > 0
                   disp(OUTPUT.message)
               end
               return;
           end
       end
       
       %-------------TEST CONVERGENCE---------------
       % If NoStopIfFlatInfeas option is on, in addition to the objective looking
       % flat, also require that the iterate be feasible (among other things) to 
       % detect that no further progress can be made.
       if ~noStopIfFlatInfeas
         noFurtherProgress = ( max(abs(SD)) < 2*tolX || abs(gf'*SD) < 2*tolFun ) && ...
               (mg < tolCon || infeasIllPosedMaxSQPIter);
       else
         noFurtherProgress = ( max(abs(SD)) < 2*tolX || (abs(gf'*SD) < 2*tolFun && ...
               feasError < tolCon*feasScal) ) && ( mg < tolCon || infeasIllPosedMaxSQPIter );
       end
         
       if optimError < tolFun*optimScal && feasError < tolCon*feasScal
           outMessage = ...
             sprintf(['Optimization terminated: first-order optimality measure less\n' ...
                      ' than options.TolFun and maximum constraint violation is less\n' ...
                      ' than options.TolCon.']);
           if verbosity > 0
               disp(outMessage) 
           end
           EXITFLAG = 1;
           done = true;

           if inequalitiesExist
              % Report active inequalities
              [activeLb,activeUb,activeIneqLin,activeIneqNonlin] = ...
                  activeInequalities(c,tolCon,arglb,argub,lin_eq,non_eq,size(Ain));           

              if any([activeLb;activeUb;activeIneqLin;activeIneqNonlin])
                 if verbosity > 0
                    fprintf('Active inequalities (to within options.TolCon = %g):\n',tolCon)
                    disp('  lower      upper     ineqlin   ineqnonlin')
                    printColumnwise(activeLb,activeUb,activeIneqLin,activeIneqNonlin);
                 end
              else
                 if verbosity > 0
                    disp('No active inequalities')
                 end 
              end 
           end   
       elseif noFurtherProgress
           % The algorithm can make no more progress.  If feasible, compute 
           % the new up-to-date Lagrange multipliers (with new gradients) 
           % and recompute the KKT error.  Then output appropriate termination
           % message.
           if mg < tolCon
               if meritFunctionType == 1
                   optimError = inf;
               else
                   lambdaNLP(:,1) = 0;
                   [Q,R] = qr(AN(ACTIND,:)');
                   ws = warning('off');
                   lambdaNLP(ACTIND) = -R\Q'*gf;
                   warning(ws);
                   lambdaNLP(eq+1:ncstr) = max(0,lambdaNLP(eq+1:ncstr));
                   if strcmp(funfcn{2},'fseminf'), lambdaNLP = NEWLAMBDA; end
                   normgradLag = norm(gf + AN'*lambdaNLP,inf);
                   normcomp = norm(lambdaNLP(eq+1:ncstr).*c(eq+1:ncstr),inf);
                   if isfinite(normgradLag) && isfinite(normcomp)
                       optimError = max(normgradLag, normcomp);
                   else
                       optimError = inf;
                   end
               end
               optimScal = 1;
               if optimError < tolFun*optimScal
                   outMessage = ...
                     sprintf(['Optimization terminated: first-order optimality ' ...
                              'measure less than options.TolFun\n and maximum ' ...
                              'constraint violation is less than options.TolCon.']);
                   if verbosity > 0
                       disp(outMessage)
                   end
                   EXITFLAG = 1;
               elseif max(abs(SD)) < 2*tolX
                   outMessage = ...
                     sprintf(['Optimization terminated: Search direction less than 2*options.TolX\n' ...
                              ' and maximum constraint violation is less than options.TolCon.']);
                   if verbosity > 0
                       disp(outMessage)
                   end
                   EXITFLAG = 4;
               else 
                   outMessage = ...
                      sprintf(['Optimization terminated: Magnitude of directional derivative in search\n' ... 
                               ' direction less than 2*options.TolFun and maximum constraint violation\n' ...
                               '  is less than options.TolCon.']);
                   if verbosity > 0 
                       disp(outMessage) 
                   end
                   EXITFLAG = 5;
               end 
               
               if inequalitiesExist
                  % Report active inequalities
                  [activeLb,activeUb,activeIneqLin,activeIneqNonlin] = ...
                      activeInequalities(c,tolCon,arglb,argub,lin_eq,non_eq,size(Ain));  

                  if any([activeLb;activeUb;activeIneqLin;activeIneqNonlin])
                     if verbosity > 0
                        fprintf('Active inequalities (to within options.TolCon = %g):\n', tolCon)
                        disp('  lower      upper     ineqlin   ineqnonlin')
                        printColumnwise(activeLb,activeUb,activeIneqLin,activeIneqNonlin);
                     end
                  else
                     if verbosity > 0
                        disp('No active inequalities')
                     end
                  end
               end
           else                         % if mg >= tolCon
               if max(abs(SD)) < 2*tolX
                   outMessage = sprintf(['Optimization terminated: No feasible solution found.\n', ...
                      ' Search direction less than 2*options.TolX but constraints are not satisfied.']);
               else
                   outMessage = sprintf(['Optimization terminated: No feasible solution found.\n' ...
                                        '  Magnitude of directional derivative in search direction\n', ...
                                        '  less than 2*options.TolFun but constraints are not satisfied.']);
               end
               if strcmp(howqp,'MaxSQPIter')
                   outMessage = sprintf(['Optimization terminated: No feasible solution found.\n' ...
                           ' During the solution to the last quadratic programming subproblem, the\n' ...
                           ' maximum number of iterations was reached. Increase options.MaxSQPIter.']);
               end 
               EXITFLAG = -2;
               if verbosity > 0
                 disp(outMessage)
               end
           end                          % of "if mg < tolCon"
           done = true;
       else % continue
           % NEED=[LAMBDA>0] | G>0
           if numFunEvals > maxFunEvals
               XOUT = MATX;
               f = OLDF;
               gf = OLDgf;
               outMessage = sprintf(['Maximum number of function evaluations exceeded;\n' ...
                                         ' increase OPTIONS.MaxFunEvals.']);
               if verbosity > 0
                   disp(outMessage)
               end
               EXITFLAG = 0;
               done = true;
           end
           if iter > maxIter
               XOUT = MATX;
               f = OLDF;
               gf = OLDgf;
               outMessage = sprintf(['Maximum number of iterations exceeded;\n' ...
                                         ' increase OPTIONS.MaxIter.']);
               if verbosity > 0
                   disp(outMessage)
               end
               EXITFLAG = 0;
               done = true;
           end
       end 
   else % ------------------------0th Iteration----------------------------------
       if verbosity > 1
           disp(header)
           % Print 0th iteration information (some columns left blank)
           if meritFunctionType == 1,
               gamma = mg+f;
               CurrOutput = sprintf(formatstrFirstIter,iter,numFunEvals,gamma,how); 
               disp(CurrOutput)
           else
               if mg > 0
                   how = 'Infeasible start point';
               else
                   how = '';
               end
               CurrOutput = sprintf(formatstrFirstIter,iter,numFunEvals,f,mg,how); 
               disp(CurrOutput)
           end
       end
       
       % Initialize the output function.
       if haveoutputfcn
           [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,XOUT,xOutputfcn,'init', iter,numFunEvals, ...
               f,mg,[],gf,[],meritFunctionType,[],[],[],outputfcnVarargin{:});
           if stop
               [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = cleanUpInterrupt(xOutputfcn,optimValues);
               if verbosity > 0
                   disp(OUTPUT.message)
               end
               return;
           end
           
           % OutputFcn call for 0th iteration
           [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,XOUT,xOutputfcn,'iter',iter,numFunEvals, ...
               f,mg,[],gf,[],meritFunctionType,[],how,'',outputfcnVarargin{:});
           if stop  % Stop per user request.
               [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                   cleanUpInterrupt(xOutputfcn,optimValues);
               if verbosity > 0
                   disp(OUTPUT.message)
               end
               return;
           end
           
       end % if haveoutputfcn
   end % if iter > 0
   
   % Continue if termination criteria do not hold or it is the 0th iteration-------------------------------------------
   if ~done 
      how=''; 
      iter = iter + 1;

      %-------------SEARCH DIRECTION---------------
      % For equality constraints make gradient face in 
      % opposite direction to function gradient.
      for i=1:eq 
         schg=AN(i,:)*gf;
         if schg>0
            AN(i,:)=-AN(i,:);
            c(i)=-c(i);
         end
      end
   
      if numGradEvals>1  % Check for first call    
         if meritFunctionType~=5,   
            NEWLAMBDA=LAMBDA; 
         end
         [ma,na] = size(AN);
         GNEW=gf+AN'*NEWLAMBDA;
         GOLD=OLDgf+OLDAN'*LAMBDA;
         YL=GNEW-GOLD;
         sdiff=XOUT-OLDX;

         % Make sure Hessian is positive definite in update.
         if YL'*sdiff<stepsize^2*1e-3
            while YL'*sdiff<-1e-5
               [YMAX,YIND]=min(YL.*sdiff);
               YL(YIND)=YL(YIND)/2;
            end
            if YL'*sdiff < (eps*norm(HESS,'fro'));
               how=' Hessian modified twice';
               FACTOR=AN'*c - OLDAN'*OLDC;
               FACTOR=FACTOR.*(sdiff.*FACTOR>0).*(YL.*sdiff<=eps);
               WT=1e-2;
               if max(abs(FACTOR))==0; FACTOR=1e-5*sign(sdiff); end
               while YL'*sdiff < (eps*norm(HESS,'fro')) && WT < 1/eps
                  YL=YL+WT*FACTOR;
                  WT=WT*2;
               end
            else
               how=' Hessian modified';
            end
         end
         
         if haveoutputfcn
             % Use the xOutputfcn and optimValues from last call to outputfcn (do not call
             % callOutputFcn)
             stop = feval(outputfcn,xOutputfcn,optimValues,'interrupt',outputfcnVarargin{:});
             if stop
                 [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                     cleanUpInterrupt(xOutputfcn,optimValues);
                 if verbosity > 0
                     disp(OUTPUT.message)
                 end
                 return;
             end
         end
         
         %----------Perform BFGS Update If YL'S Is Positive---------
         if YL'*sdiff>eps
             HESS=HESS ...
                 +(YL*YL')/(YL'*sdiff)-((HESS*sdiff)*(sdiff'*HESS'))/(sdiff'*HESS*sdiff);
             % BFGS Update using Cholesky factorization  of Gill, Murray and Wright.
             % In practice this was less robust than above method and slower. 
             %   R=chol(HESS); 
             %   s2=R*S; y=R'\YL; 
             %   W=eye(numberOfVariables,numberOfVariables)-(s2'*s2)\(s2*s2') + (y'*s2)\(y*y');
             %   HESS=R'*W*R;
         else
            how=' Hessian not updated';
         end
      else % First call
         OLDLAMBDA=repmat(eps+gf'*gf,ncstr,1)./(sum(AN'.*AN')'+eps);
         ACTIND = 1:eq;     
      end % if numGradEvals>1
      numGradEvals=numGradEvals+1;
   
      LOLD=LAMBDA;
      OLDAN=AN;
      OLDgf=gf;
      OLDC=c;
      OLDF=f;
      OLDX=XOUT;
      XN=zeros(numberOfVariables,1);
      if (meritFunctionType>0 && meritFunctionType<5)
         % Minimax and attgoal problems have special Hessian:
         HESS(numberOfVariables,1:numberOfVariables)=zeros(1,numberOfVariables);
         HESS(1:numberOfVariables,numberOfVariables)=zeros(numberOfVariables,1);
         HESS(numberOfVariables,numberOfVariables)=1e-8*norm(HESS,'inf');
         XN(numberOfVariables)=max(c); % Make a feasible solution for qp
      end
   
      GT =c;
   
      HESS = (HESS + HESS')*0.5;
   
      [SD,lambda,exitflagqp,outputqp,howqp,ACTIND] ...
         = qpsub(HESS,gf,AN,-GT,[],[],XN,eq,-1, ...
         Nlconst,size(AN,1),numberOfVariables,OPTIONS,defaultopt,ACTIND,phaseOneTotalScaling);
    
      lambdaNLP(:,1) = 0;
      lambdaNLP(ACTIND) = lambda(ACTIND);
      lambda((1:eq)') = abs(lambda( (1:eq)' ));
      ga=[abs(c( (1:eq)' )) ; c( (eq+1:ncstr)' ) ];
      if ~isempty(c)
          mg = max(ga);
      else
          mg = 0;
      end

      if strncmp(howqp,'ok',2); 
          howqp =''; 
      end
      if ~isempty(how) && ~isempty(howqp) 
          how = [how,'; '];
      end

      LAMBDA=lambda((1:ncstr)');
      OLDLAMBDA=max([LAMBDA';0.5*(LAMBDA+OLDLAMBDA)'])' ;

      %---------------LINESEARCH--------------------
      MATX=XOUT;
      MATL = f+sum(OLDLAMBDA.*(ga>0).*ga) + 1e-30;

      infeasIllPosedMaxSQPIter = strcmp(howqp,'infeasible') || ...
          strcmp(howqp,'ill posed') || strcmp(howqp,'MaxSQPIter');
      if meritFunctionType==0 || meritFunctionType == 5
         % This merit function looks for improvement in either the constraint
         % or the objective function unless the sub-problem is infeasible in which
         % case only a reduction in the maximum constraint is tolerated.
         % This less "stringent" merit function has produced faster convergence in
         % a large number of problems.
         if mg > 0
            MATL2 = mg;
         elseif f >=0 
            MATL2 = -1/(f+1);
         else 
            MATL2 = 0;
         end
         if ~infeasIllPosedMaxSQPIter && f < 0
            MATL2 = MATL2 + f - 1;
         end
      else
         % Merit function used for MINIMAX or ATTGOAL problems.
         MATL2=mg+f;
      end
      if mg < eps && f < bestf
         bestf = f;
         bestx = XOUT;
         bestHess = HESS;
         bestgrad = gf;
         bestlambda = lambda;
         bestmg = mg;
         bestOptimError = optimError;
      end
      MERIT = MATL + 1;
      MERIT2 = MATL2 + 1; 
      stepsize=2;
      while  (MERIT2 > MATL2) && (MERIT > MATL) ...
            && numFunEvals < maxFunEvals
         stepsize=stepsize/2;
         if stepsize < 1e-4,  
            stepsize = -stepsize; 
         
            % Semi-infinite may have changing sampling interval
            % so avoid too stringent check for improvement
            if meritFunctionType == 5, 
               stepsize = -stepsize; 
               MATL2 = MATL2 + 10; 
            end
         end
         if hasBoundOnStep && (iter <= relLineSrchBndDuration)
           % Bound total displacement:
           % |stepsize*SD(i)| <= relLineSrchBnd*max(|x(i)|, |typicalx(i)|)
           % for all i.
           indxViol = abs(stepsize*SD) > relLineSrchBnd*max(abs(MATX),abs(typicalx));
           if any(indxViol)
             stepsize = sign(stepsize)*min(  min( abs(stepsize), ...
                  relLineSrchBnd*max(abs(MATX(indxViol)),abs(typicalx(indxViol))) ...
                  ./abs(SD(indxViol)) )  );
           end   
         end
         
         XOUT = MATX + stepsize*SD;
         x(:)=XOUT; 
      
         if strcmp(funfcn{2},'fseminf')
            f = feval(funfcn{3},x,varargin{3:end});
         
            [nctmp,nceqtmp,NPOINT,NEWLAMBDA,OLDLAMBDA,LOLD,s] = ...
               semicon(x,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s,varargin{:});
            nctmp = nctmp(:); nceqtmp = nceqtmp(:);
            non_ineq = length(nctmp);  % the length of nctmp can change
            ineq = non_ineq + lin_ineq;
            ncstr = ineq + eq;
            % Possibly changed constraints, even if same number,
            % so ACTIND may be invalid.
            ACTIND = 1:eq;
         else
            f = feval(funfcn{3},x,varargin{:});
            if constflag
               [nctmp,nceqtmp] = feval(confcn{3},x,varargin{:});
               nctmp = nctmp(:); nceqtmp = nceqtmp(:);
            else
               nctmp = []; nceqtmp=[];
            end
         end
            
         nc = [nceqtmp(:); nctmp(:)];
         c = [Aeq*XOUT-Beq; nceqtmp(:); A*XOUT-B; nctmp(:)];  

         numFunEvals = numFunEvals + 1;
         ga=[abs(c( (1:eq)' )) ; c( (eq+1:length(c))' )];
         if ~isempty(c)
            mg=max(ga);
         else
            mg = 0;
         end

         MERIT = f+sum(OLDLAMBDA.*(ga>0).*ga);
         if meritFunctionType == 0 || meritFunctionType == 5
            if mg > 0
               MERIT2 = mg;
            elseif f >=0 
               MERIT2 = -1/(f+1);
            else 
               MERIT2 = 0;
            end
            if ~infeasIllPosedMaxSQPIter && f < 0
               MERIT2 = MERIT2 + f - 1;
            end
         else
            MERIT2=mg+f;
         end
         if haveoutputfcn
             stop = feval(outputfcn,xOutputfcn,optimValues,'interrupt',outputfcnVarargin{:});
             if stop
                 [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                     cleanUpInterrupt(xOutputfcn,optimValues);
                 if verbosity > 0
                     disp(OUTPUT.message)
                 end
                 return;
             end
             
         end

                                                                                                                                                                                                                            end  % line search loop
      %------------Finished Line Search-------------
   
      if meritFunctionType~=5
         mf=abs(stepsize);
         LAMBDA=mf*LAMBDA+(1-mf)*LOLD;
      end

      x(:) = XOUT;
      switch funfcn{1} % evaluate function gradients
      case 'fun'
         ;  % do nothing...will use finite difference.
      case 'fungrad'
         [f,gf_user] = feval(funfcn{3},x,varargin{:});
         gf_user = gf_user(:);
         numGradEvals=numGradEvals+1;
      case 'fun_then_grad'
         gf_user = feval(funfcn{4},x,varargin{:});
         gf_user = gf_user(:);
         numGradEvals=numGradEvals+1;
      otherwise
         error('optim:nlconst:UndefinedCalltypeInFMINCON', ...
               'Undefined calltype in FMINCON.');
      end
      numFunEvals=numFunEvals+1;
   
   
      % Evaluate constraint gradients
      switch confcn{1}
      case 'fun'
         gnceq=[]; gncineq=[];
      case 'fungrad'
         [nctmp,nceqtmp,gncineq,gnceq] = feval(confcn{3},x,varargin{:});
         nctmp = nctmp(:); nceqtmp = nceqtmp(:);
         numGradEvals=numGradEvals+1;
      case 'fun_then_grad'
         [gncineq,gnceq] = feval(confcn{4},x,varargin{:});
         numGradEvals=numGradEvals+1;
      case ''
         nctmp=[]; nceqtmp =[];
         gncineq = zeros(numberOfVariables,length(nctmp));
         gnceq = zeros(numberOfVariables,length(nceqtmp));
      otherwise
         error('optim:nlconst:UndefinedCalltypeInFMINCON', ...
               'Undefined calltype in FMINCON.');
      end
      gnc_user = [gnceq, gncineq];
      gc = [Aeq', gnceq, A', gncineq];
   
   end % if ~done   
end % while ~done


% Update 
numConstrEvals = numGradEvals;

% Gradient is in the variable gf
GRADIENT = gf;

% If a better solution was found earlier, use it:
if f > bestf 
   XOUT = bestx;
   f = bestf;
   HESS = bestHess;
   GRADIENT = bestgrad;
   lambda = bestlambda;
   mg = bestmg;
   gf = bestgrad;
   optimError = bestOptimError;
end

FVAL = f;
x(:) = XOUT;

if haveoutputfcn
    [xOutputfcn, optimValues] = callOutputFcn(outputfcn,XOUT,xOutputfcn,'done',iter,numFunEvals, ...
        f,mg,stepsize,gf,SD,meritFunctionType,optimError,how,howqp,outputfcnVarargin{:});
    % Do not check value of 'stop' as we are done with the optimization
    % already.
end

OUTPUT.iterations = iter;
OUTPUT.funcCount = numFunEvals;
OUTPUT.stepsize = stepsize;
OUTPUT.algorithm = 'medium-scale: SQP, Quasi-Newton, line-search';
if meritFunctionType == 1
   OUTPUT.firstorderopt = [];
else   
   OUTPUT.firstorderopt = optimError;
end
OUTPUT.cgiterations = [];
OUTPUT.message = outMessage;

[lin_ineq,Acol] = size(Ain);  % excludes upper and lower

lambda_out.lower=zeros(lenlb,1);
lambda_out.upper=zeros(lenub,1);

lambda_out.eqlin = lambdaNLP(1:lin_eq);
ii = lin_eq ;
lambda_out.eqnonlin = lambdaNLP(ii+1: ii+ non_eq);
ii = ii+non_eq;
lambda_out.lower(arglb) = lambdaNLP(ii+1 :ii+nnz(arglb));
ii = ii + nnz(arglb) ;
lambda_out.upper(argub) = lambdaNLP(ii+1 :ii+nnz(argub));
ii = ii + nnz(argub);
lambda_out.ineqlin = lambdaNLP(ii+1: ii + lin_ineq);
ii = ii + lin_ineq ;
lambda_out.ineqnonlin = lambdaNLP(ii+1 : end);

% NLCONST finished
%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,state,iter,numFunEvals, ...
    f,mg,stepsize,gf,SD,meritFunctionType,optimError,how,howqp,varargin)
% CALLOUTPUTFCN assigns values to the struct OptimValues and then calls the
% outputfcn.  
%
% The input STATE can have the values 'init','iter', or 'done'. 
% We do not handle the case 'interrupt' because we do not want to update
% xOutputfcn or optimValues (since the values could be inconsistent) before calling
% the outputfcn; in that case the outputfcn is called directly rather than
% calling it inside callOutputFcn.
%
% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.

optimValues.iteration = iter;
optimValues.funccount = numFunEvals;
optimValues.fval = f;
optimValues.constrviolation = mg;
optimValues.stepsize = stepsize;
if ~isempty(SD)
    optimValues.directionalderivative = gf'*SD;  
else
    optimValues.directionalderivative = [];
end
optimValues.gradient = gf;
optimValues.searchdirection = SD;
if meritFunctionType == 1
    optimValues.firstorderopt = [];
else
    optimValues.firstorderopt = optimError;
end
optimValues.procedure = [how,'  ',howqp];
xOutputfcn(:) = x;  % Set x to have user expected size
switch state
    case {'iter','init'}
        stop = feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    case 'done'
        stop = false;
        feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    otherwise
        error('optim:nlconst:UnknownStateInCALLOUTPUTFCN', ...
              'Unknown state in CALLOUTPUTFCN.')
end

%--------------------------------------------------------------------------
function [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT updates or sets all the output arguments of NLCONST when the optimization 
% is interrupted.  The HESSIAN and LAMBDA are set to [] as they may be in a
% state that is inconsistent with the other values since we are
% interrupting mid-iteration.

x = xOutputfcn;
FVAL = optimValues.fval;
EXITFLAG = -1; 
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.stepsize = optimValues.stepsize;
OUTPUT.algorithm = 'medium-scale: SQP, Quasi-Newton, line-search';
OUTPUT.firstorderopt = optimValues.firstorderopt; 
OUTPUT.cgiterations = [];
OUTPUT.message = 'Optimization terminated prematurely by user.';
GRADIENT = optimValues.gradient;
HESS = []; % May be in an inconsistent state
lambda_out = []; % May be in an inconsistent state

%--------------------------------------------------------------------------
function [activeLb,activeUb,activeIneqLin,activeIneqNonlin] = ...
    activeInequalities(c,tol,arglb,argub,linEq,nonlinEq,linIneq)
% ACTIVEINEQUALITIES returns the indices of the active inequalities
% and bounds.
% INPUT:
% c                 vector of constraints and bounds (see nlconst main code)
% tol               tolerance to determine when an inequality is active
% arglb, argub      boolean vectors indicating finite bounds (see nlconst
%                   main code)
% linEq             number of linear equalities
% nonlinEq          number of nonlinear equalities
% linIneq           number of linear inequalities
%
% OUTPUT
% activeLB          indices of active lower bounds
% activeUb          indices of active upper bounds  
% activeIneqLin     indices of active linear inequalities
% activeIneqNonlin  indices of active nonlinear inequalities
%

% We check wether a constraint is active or not using '< tol'
% instead of '<= tol' to be onsistent with nlconst main code, 
% where feasibility is checked using '<'.
finiteLb = nnz(arglb); % number of finite lower bounds
finiteUb = nnz(argub); % number of finite upper bounds

indexFiniteLb = find(arglb); % indices of variables with LB
indexFiniteUb = find(argub); % indices of variables with UB

% lower bounds
i = linEq + nonlinEq; % skip equalities

% Boolean vector that indicates which among the finite
% bounds is active
activeFiniteLb = abs(c(i + 1 : i + finiteLb)) < tol;

% indices of the finite bounds that are active
activeLb = indexFiniteLb(activeFiniteLb);

% upper bounds
i = i + finiteLb;

% Boolean vector that indicates which among the finite
% bounds is active
activeFiniteUb = abs(c(i + 1 : i + finiteUb)) < tol;

% indices of the finite bounds that are active
activeUb = indexFiniteUb(activeFiniteUb);

% linear inequalities
i = i + finiteUb;
activeIneqLin = find(abs(c(i + 1 : i + linIneq)) < tol); 
% nonlinear inequalities
i = i + linIneq;
activeIneqNonlin = find(abs(c(i + 1 : end)) < tol);   

%--------------------------------------------------------------------------
function printColumnwise(a,b,c,d)
% PRINTCOLUMNWISE prints vectors a, b, c, d (which
% in general have different lengths) column-wise.
% 
% Example: if a = [1 2], b = [4 6 7], c = [], d = [8 11 13 15]
% then this function will produce the output (without the headers):
%
% a  b  c   d
%-------------
% 1  4      8
% 2  6     11
%    7     13
%          15
%
length1 = length(a); length2 = length(b);
length3 = length(c); length4 = length(d);

for k = 1:max([length1,length2,length3,length4])
    % fprintf stops printing numbers as soon as it encounters [].
    % To avoid this, we convert all numbers to string
    % (fprintf doesn't stop when it comes across the blank
    % string ' '.)
   if k <= length1
      value1 = num2str(a(k));
   else
      value1 = ' ';
   end
   if k <= length2
      value2 = num2str(b(k));
   else
      value2 = ' ';
   end   
   if k <= length3
      value3 = num2str(c(k));
   else
      value3 = ' ';
   end      
   if k <= length4
      value4 = num2str(d(k));
   else
      value4 = ' ';
   end  
   fprintf('%5s %10s %10s %10s\n',value1,value2,value3,value4);
end








