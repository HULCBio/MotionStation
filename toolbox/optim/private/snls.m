function[xcurr,fvec,LAMBDA,JACOB,EXITFLAG,OUTPUT,msg]=snls(funfcn,xstart,l,u,verb,options,defaultopt,fval,JACval,YDATA,caller,Jstr,computeLambda,varargin)
%SNLS  Sparse nonlinear least squares solver.
%   
%   Locate a local solution
%   to the box-constrained nonlinear least-squares problem:
%
%              min { ||F(x)||^2 :  l <= x <= u}.
%
%   where F:R^n -> R^m, m > n, and || || is the 2-norm.
%
% x=SNLS(fname,xstart) solves the unconstrained nonlinear least
% squares problem. The vector function is 'fname' and the
% starting point is xstart. 
%
% x=SNLS(fname,xstart,options) solves the unconstrained or
% box constrained nonlinear least squares problem. Bounds and
% parameter settings are handled through the named parameter list
% options.
%
% x=SNLS(fname,xstart,options,Jstr) indicates the structure
% of the sparse Jacobian matrix -- sparse finite differencing
% is used to compute the Jacobian when Jstr is not empty.
%
% [x,fvec] =SNLS(fname,xstart, ...)  returns the final value of the
% vector function F.
%
% [x,fvec,gopt] = SNLS(fname,xstart, ...) returns the first-order
% optimality vector.
%
% [x,fvec,gopt,iter] = SNLS(fname,xstart, ...) returns the number of
% major iterations used.
%
% [x,fvec,gopt,iter,npcg] =  SNLS(fname,xstart, ...) returns the
% total number of CG iterations used.
%
% [x,fvec,gopt,iter,npcg,ex] = SNLS(fname,xstart, ...) returns the 
% termination code.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.28.4.6 $  $Date: 2004/02/07 19:13:43 $

%   Extract input parameters etc.
l=l(:); u = u(:);
xcurr=xstart;  % save shape of xstart for user function
xstart = xstart(:);  % make it a vector

%   Initialize
msg = [];
dnewt = [];
A = []; 
fvec = []; 
gopt = [];
n = length(xstart); 
iter= 0;  
numFunEvals = 1;  % done in calling function lsqnonlin
numGradEvals = 1; % done in calling function
totls = 0;
header = sprintf(['\n                                         Norm of      First-order \n',...
        ' Iteration  Func-count     f(x)          step          optimality   CG-iterations']);
formatstrFirstIter = ' %5.0f      %5.0f   %13.6g                  %12.3g';
formatstr = ' %5.0f      %5.0f   %13.6g  %13.6g   %12.3g      %7.0f';

if n == 0, 
   error('optim:snls:InvalidN','n must be positive.')
end

if isempty(l), 
   l = -inf*ones(n,1); 
end
if isempty(u), 
   u = inf*ones(n,1); 
end
arg = (u >= 1e10); 
arg2 = (l <= -1e10);
u(arg) = inf;
l(arg2) = -inf;
if any(u == l)
   error('optim:snls:EqualBounds','Equal upper and lower bounds not permitted.')
elseif min(u-l) <= 0
   error('optim:snls:InconsistentBounds','Inconsistent bounds.')
end
if min(min(u-xstart),min(xstart-l)) < 0
   xstart = startx(u,l);    
end

%
numberOfVariables = n;
% get options out
active_tol = optimget(options,'ActiveConstrTol',sqrt(eps)); % leave old optimget
pcmtx = optimget(options,'Preconditioner',@aprecon) ; % leave old optimget

gradflag =  strcmp(optimget(options,'Jacobian',defaultopt,'fast'),'on');
typx = optimget(options,'TypicalX',defaultopt,'fast') ;
mtxmpy = optimget(options,'JacobMult',defaultopt,'fast') ;
if isempty(mtxmpy)
    mtxmpy = @atamult;
end
pcflags = optimget(options,'PrecondBandWidth',defaultopt,'fast') ;
tol2 = optimget(options,'TolX',defaultopt,'fast') ;
tol1 = optimget(options,'TolFun',defaultopt,'fast') ;
tol = tol1;
itb = optimget(options,'MaxIter',defaultopt,'fast') ;
maxfunevals = optimget(options,'MaxFunEvals',defaultopt,'fast') ;
pcgtol = optimget(options,'TolPCG',defaultopt,'fast') ;  % pcgtol = .1;
kmax = optimget(options,'MaxPCGIter',defaultopt,'fast') ;
if ischar(typx)
   if isequal(lower(typx),'ones(numberofvariables,1)')
      typx = ones(numberOfVariables,1);
   else
      error('optim:snls:InvalidTypicalX','Option ''TypicalX'' must be an integer value if not the default.')
   end
end
if ischar(kmax)
   if isequal(lower(kmax),'max(1,floor(numberofvariables/2))')
      kmax = max(1,floor(numberOfVariables/2));
   else
      error('optim:snls:InvalidMaxPCGIter','Option ''MaxPCGIter'' must be an integer value if not the default.')
   end
end
if ischar(maxfunevals)
   if isequal(lower(maxfunevals),'100*numberofvariables')
      maxfunevals = 100*numberOfVariables;
   else
      error('optim:snls:MaxFunEvals','Option ''MaxFunEvals'' must be an integer value if not the default.')
   end
end

% This will be user-settable in the future:
showstat = optimget(options,'showstatus','off'); % no default, so leave with slow optimget
switch showstat
case 'iter'
  showstat = 2;
case {'none','off'}
  showstat = 0;
case 'final'
  showstat = 1;
case 'iterplusbounds'  % if no finite bounds, this is the same as 'iter'
  showstat = 3;
otherwise
  showstat = 1;
end

% Handle the output
if isfield(options,'OutputFcn')
    outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
else
    outputfcn = defaultopt.OutputFcn;
end
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = xcurr; % Last x passed to outputfcn; has the input x's shape
end
stop = false;

ex = 0; posdef = 1; npcg = 0; pcgit = 0;
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');
DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');

%tol1 = tol; tol2 = sqrt(tol1)/10;
vpcg(1,1) = 0; vpos(1,1) = 1;
delta = 10;nrmsx = 1; ratio = 0; 
degen = inf; DS = speye(n);
v = zeros(n,1); dv = ones(n,1); del = 10*eps;
x = xstart; oval = inf;
g = zeros(n,1); nbnds = 1; Z = [];
if isinf(u) & isinf(l)
   nbnds = 0; degen = -1;
end

xcurr(:) = xstart;
%   Evaluate F and J
if ~gradflag % use sparse finite differencing
   fvec = fval;
   % Determine coloring/grouping for sparse finite-differencing
   p = colamd(Jstr)'; 
   p = (n+1)*ones(n,1)-p; 
   group = color(Jstr,p);
   xcurr(:) = x;  % reshape x for user function
   % pass in funfcn{3} since we know no gradient: not funfcn{4}
   [A,findiffevals] = sfdnls(xcurr,fvec,Jstr,group,[],DiffMinChange, ...
                             DiffMaxChange,funfcn{3},YDATA,varargin{:});
else % user-supplied computation of J or dnewt 
   %[fvec,A] = feval(fname,x);
   fvec = fval;
   A = JACval;
   findiffevals = 0;
   jacErr = 0; % difference between user-supplied and finite-difference Jacobian
   if DerivativeCheck
      if issparse(JACval)
         %
         % Use finite differences to estimate one column at a time of the
         % Jacobian (and thus avoid storing an additional matrix)
         %
         for k = 1:numberOfVariables 
            columnOfFinDiffJac = ...
                finitedifferences(xstart,xcurr,funfcn,[],l,u,fval,[],YDATA,...
                   DiffMinChange,DiffMaxChange,typx,[],k,[],[],[],[],[],[],...
                   varargin{:});
            %
            % Compare with the corresponding column of the user-supplied Jacobian
            %
            columnErr = jacColumnErr(columnOfFinDiffJac,JACval(:,k),k);
  
            % Store max error so far
            jacErr = max(jacErr,columnErr);
         end 
         fprintf('Maximum discrepancy between derivatives = %g\n',jacErr);
      else
        %
        % Compute finite differences of full Jacobian
        %
        JACfd = finitedifferences(xstart,xcurr,funfcn,[],l,u,fval,[],YDATA,...
                   DiffMinChange,DiffMaxChange,typx,[],'all',[],[],[],[],...
                      [],[],varargin{:});
        %
        % Compare with the user-supplied Jacobian
        %
        if isa(funfcn{3},'inline') 
           % if using inlines, the gradient is in funfcn{4}
           graderr(JACfd, JACval, formula(funfcn{4})); %
        else 
           % otherwise fun/grad in funfcn{3}
           graderr(JACfd, JACval, funfcn{3});
        end
      end
      findiffevals = numberOfVariables;
   end 
end % of 'if ~gradflag'
numFunEvals = numFunEvals + findiffevals;


delbnd = max(100*norm(xstart),1);

[mm,pp] = size(fvec);
if mm < n, 
   error('optim:snls:MLessThanN','The number of equations must not be less than n.')
end

%   Extract the Newton direction?
if pp == 2, 
   dnewt = fvec(1:n,2); 
end

%   Determine gradient of the nonlinear least squares function
g = feval(mtxmpy,A,fvec(:,1),-1,varargin{:});

%   Evaluate F (initial point)
val = fvec(:,1)'*fvec(:,1); 
vval(iter+1,1) = val;

%   Display
if showstat > 1 
   figtr=display1('init',itb,tol,verb,nbnds,x,g,l,u);
end
if verb > 1
    disp(header)
end

% Initialize the output function.
if haveoutputfcn
    [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'init',iter, ...
    numFunEvals,fvec,val,[],[],[],pcgit,[],[],[],delta,varargin{:});
    if stop
        [xcurr,fvec,LAMBDA,JACOB,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
        return;
    end
end


%   Main loop: Generate feas. seq. x(iter) s.t. ||F(x(iter)|| is decreasing.
while ~ex 
   if any(~isfinite(fvec)) 
      error('optim:snls:InvalidUserFunction', ...
       '%s cannot continue: user function is returning Inf or NaN values.',caller)
   end
      
   %  Stop (Interactive)?
   figtr=findobj('type','figure','Name','Progress Information');
   if ~isempty(figtr)
      lsotframe = findobj(figtr,'type','uicontrol',...
         'Userdata','LSOT frame') ;
      if get(lsotframe,'Value'), 
         ex = 10; % New exiting condition 
         EXITFLAG = -1;
         msg = sprintf('Exiting per request.');
         if verb > 0
            display(msg)
         end       
      end 
   end 
   
   % Update 
   [v,dv] = definev(g,x,l,u); 
   gopt = v.*g;
   optnrm = norm(gopt,inf);
   voptnrm(iter+1,1) = optnrm; 
   r = abs(min(u-x,x-l));
   degen = min(r + abs(g));
   vdeg(iter+1,1) = min(degen,1);
   if ~nbnds 
      degen = -1; 
   end
   bndfeas = min(min(x-l,u-x));
   % Display
   if showstat > 1
      display1('progress',iter+1,optnrm,val,pcgit,...
         npcg,degen,bndfeas,showstat,nbnds,x,g,l,u,figtr);
   end
    if verb > 1
        if iter > 0
            currOutput = sprintf(formatstr,iter,numFunEvals,val,nrmsx,optnrm,pcgit);
        else
            currOutput = sprintf(formatstrFirstIter,iter,numFunEvals,val,optnrm);
        end
        disp(currOutput);
    end
    
    % OutputFcn call
    if haveoutputfcn
        [xOutputfcn,optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,'iter',iter, ...
            numFunEvals,fvec,val,nrmsx,g,optnrm,pcgit,posdef,ratio,degen,delta,varargin{:});
        if stop  % Stop per user request.
            [xcurr,fvec,LAMBDA,JACOB,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
            return;
        end
    end
    
   %     Test for convergence
   diff = abs(oval-val); 
   prev_diff = diff; 
   oval = val; 
    if ((optnrm < tol1) && (posdef == 1) ),  
        ex = 1; EXITFLAG = 1;
        msg = sprintf(['Optimization terminated: first-order optimality less than OPTIONS.TolFun,\n' ...
                       ' and no negative/zero curvature detected in trust region model.']);
    elseif (nrmsx < .9*delta) && (ratio > .25) && (diff < tol1*(1+abs(oval)))
        ex = 2; EXITFLAG = 3;
        msg = sprintf(['Optimization terminated: relative function value\n' ... 
                ' changing by less than OPTIONS.TolFun.']);
    elseif (iter > 1) && (nrmsx < tol2), 
        ex = 3; EXITFLAG = 2;
        msg = sprintf(['Optimization terminated: norm of the current step is less\n' ... 
               ' than OPTIONS.TolX.']);
    elseif iter > itb, 
        ex = 4; EXITFLAG = 0;
        msg = sprintf(['Maximum number of iterations exceeded;\n',...
                    ' increase options.MaxIter']);
    elseif numFunEvals > maxfunevals 
        ex=4; EXITFLAG = 0;
        msg = sprintf(['Maximum number of function evaluations exceeded;\n',...
                    ' increase options.MaxFunEvals']);
    end


   %     Continue if ex = 0 (i.e., not done yet)
   if ~ex 
      %       Determine the trust region correction
      dd = abs(v); D = sparse(1:n,1:n,full(sqrt(dd))); grad = D*g;
      vpos(iter+1,1) = posdef; 
      sx = zeros(n,1); theta = max(.95,1-optnrm);  
      oposdef = posdef;
      [sx,snod,qp,posdef,pcgit,Z] = trdog(x,g,A,D,delta,dv,...
         mtxmpy,pcmtx,pcflags,pcgtol,kmax,theta,l,u,Z,dnewt,'jacobprecon',varargin{:});
      
      if isempty(posdef), 
         posdef = oposdef; 
      end
      nrmsx=norm(snod); 
      npcg=npcg+pcgit; 
      newx=x+sx;  
      vpcg(iter+1+1,1)=pcgit;
      
      %       Perturb?
      [pert,newx] = perturb(newx,l,u);
      vpos(iter+1+1,1) = posdef;
      
        % OutputFcn call
        if haveoutputfcn
            stop = feval(outputfcn,x,optimValues,'interrupt',varargin{:});
            if stop  % Stop per user request.
                [xcurr,fvec,LAMBDA,JACOB,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
                return;
            end
        end

      xcurr(:) = newx; % reshape newx for user function
      %       Evaluate F and J
      if ~gradflag %use sparse finite-differencing
         %newfvec = feval(fname,newx);
         switch funfcn{1}
         case 'fun'
            newfvec = feval(funfcn{3},xcurr,varargin{:});
            if ~isempty(YDATA)
               newfvec = newfvec - YDATA;
            end
            newfvec = newfvec(:);
         otherwise
            error('optim:snls:UndefinedCalltype','Undefined calltype in %s.',caller)
         end
         % pass in funfcn{3} since we know no gradient
         [newA, findiffevals] = sfdnls(xcurr,newfvec,Jstr,group,[], ...
                       DiffMinChange,DiffMaxChange,funfcn{3},YDATA,varargin{:});
      else % use user-supplied determination of J or dnewt
         findiffevals = 0; % no finite differencing
         %[newfvec,newA] = feval(fname,newx);
         switch funfcn{1}
         case 'fungrad'
            [newfvec,newA] = feval(funfcn{3},xcurr,varargin{:});
            numGradEvals=numGradEvals+1;
            if ~isempty(YDATA)
               newfvec = newfvec - YDATA;
               end
            newfvec = newfvec(:);
         case 'fun_then_grad'
            newfvec = feval(funfcn{3},xcurr,varargin{:});
            if ~isempty(YDATA)
               newfvec = newfvec - YDATA;
               end
            newfvec = newfvec(:);
            newA = feval(funfcn{4},xcurr,varargin{:});
            numGradEvals=numGradEvals+1;
          otherwise
            error('optim:snls:UndefinedCalltype','Undefined calltype in %s.',caller)
         end
      end
      numFunEvals = numFunEvals + 1 + findiffevals;
      
      [mm,pp] = size(newfvec);
      if mm < n, 
         error('optim:snls:MLessThanN','The number of equations must be greater than n.')
      end
      
      %       Accept or reject trial point
      newgrad = feval(mtxmpy,newA,newfvec(:,1),-1,varargin{:});  
      newval = newfvec(:,1)'*newfvec(:,1);
      aug = .5*snod'*((dv.*abs(g)).*snod); 
      ratio = (0.5*(newval-val)+aug)/qp;     % we compute val = f'*f, not val = 0.5*(f'*f)
      if (ratio >= .75) && (nrmsx >= .9*delta),
         delta = min(delbnd,2*delta);
      elseif ratio <= .25,  
         delta = min(nrmsx/4,delta/4);
      end
      if isinf(newval) 
         delta = min(nrmsx/20,delta/20); 
      end
      
      %       Update
      if newval < val
         xold = x; 
         x=newx; 
         val = newval; 
         g= newgrad; 
         A = newA; 
         Z = [];
         fvec = newfvec;
         
         %          Extract the Newton direction?
         if pp == 2, 
            dnewt = newfvec(1:n,2); 
         end
      end
      iter=iter+1; 
      vval(iter+1,1) = val;
   end % if ~ex
end % while
%
%   Display
if showstat > 1 
  display1('final',figtr);
end
if showstat 
  xplot(iter+1,vval,voptnrm,vpos,vdeg,vpcg);
end

if haveoutputfcn
[xOutputfcn, optimValues] = callOutputFcn(outputfcn,x,xOutputfcn,'done',iter, ...
    numFunEvals,fvec,val,nrmsx,g,optnrm,pcgit,posdef,ratio,degen,delta,varargin{:});
    % Optimization done, so ignore "stop"
end

JACOB = sparse(A);     % A is the Jacobian, not the gradient.
OUTPUT.firstorderopt = optnrm;
OUTPUT.iterations = iter;
OUTPUT.funcCount = numFunEvals;
OUTPUT.cgiterations = npcg;
OUTPUT.algorithm = 'large-scale: trust-region reflective Newton'; 
xcurr(:)=x;

if computeLambda
   LAMBDA.lower = zeros(length(l),1);
   LAMBDA.upper = zeros(length(u),1);
   argl = logical(abs(x-l) < active_tol);
   argu = logical(abs(x-u) < active_tol);
   
   g = full(g);
   
   LAMBDA.lower(argl) = (g(argl));
   LAMBDA.upper(argu) = -(g(argu));
else
   LAMBDA = [];
end
%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,x,xOutputfcn,state,iter, ...
    numFunEvals,fvec,val,nrmsx,g,optnrm,pcgit,posdef,ratio,degen,delta,varargin)
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
optimValues.funccount = numFunEvals;
optimValues.fval = fvec;
optimValues.residual = val;
optimValues.stepsize = nrmsx;
optimValues.gradient = g;
optimValues.firstorderopt = optnrm;
optimValues.cgiterations = pcgit;
optimValues.positivedefinite = posdef;
optimValues.ratio = ratio;
optimValues.degenerate = min(degen,1);
optimValues.trustregionradius = delta;
optimValues.procedure = '';
xOutputfcn(:) = x;  % Set x to have user expected size

switch state
    case {'iter','init'}
        stop = feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    case 'done'
        stop = false;
        feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    otherwise
        error('optim:snls:InvalidCALLOUTPUTFCN','Unknown state in CALLOUTPUTFCN.')
end
%--------------------------------------------------------------------------
function [xcurr,fvec,LAMBDA,JACOB,EXITFLAG,OUTPUT,msg] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT sets the outputs arguments to be the values at the last call
% of the outputfcn during an 'iter' call (when these values were last known to
% be consistent). 

xcurr = xOutputfcn;
fvec = optimValues.fval;
EXITFLAG = -1; 
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.algorithm = 'large-scale: trust-region reflective Newton'; 
OUTPUT.firstorderopt = optimValues.firstorderopt; 
OUTPUT.cgiterations = optimValues.cgiterations;
JACOB = []; % May be in an inconsistent state
LAMBDA = []; % May be in an inconsistent state
msg = 'Optimization terminated prematurely by user.';





