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
% [x,fvec,gopt,it] = SNLS(fname,xstart, ...) returns the number of
% major iterations used.
%
% [x,fvec,gopt,it,npcg] =  SNLS(fname,xstart, ...) returns the
% total number of CG iterations used.
%
% [x,fvec,gopt,it,npcg,ex] = SNLS(fname,xstart, ...) returns the 
% termination code.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.15.2.3 $  $Date: 2004/02/01 21:43:39 $

% Global parameter, OPT_STOP is used for canceling fits
% It is initialized and set in the Curve Fitting GUI (CreateAFit.java)
global OPT_STOP 

%   Extract input parameters etc.
l=l(:); u = u(:);
xcurr=xstart;  % save shape of xstart for user function
xstart = xstart(:);  % make it a vector

%   Initialize
msg = '';
dnewt = [];
A = []; 
fvec = []; 
gopt = [];
n = length(xstart); 
it= 1;  
numFunEvals = 1;  % done in calling function lsqnonlin
numGradEvals = 1; % done in calling function
totls = 0;
header = sprintf(['\n                                         Norm of      First-order \n',...
                    ' Iteration  Func-count     f(x)          step          optimality   CG-iterations']);
formatstr = ' %5.0f      %5.0f   %13.6g  %13.6g   %12.3g      %7.0f';

if n == 0, 
   error('curvefit:snls:nMustBePositive', 'N must be positive.'); 
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
   error('curvefit:snls:boundsMustNotBeEqual',...
         'Equal upper and lower bounds not permitted.');
elseif min(u-l) <= 0
   error('curvefit:snls:inconsistentBounds', 'Bounds are inconsistent.')
end
if min(min(u-xstart),min(xstart-l)) < 0
   xstart = startx(u,l);    
end

%
numberOfVariables = n;
% get options out
active_tol = optimget(options,'ActiveConstrTol',sqrt(eps)*100); % leave old optimget
pcmtx = optimget(options,'Preconditioner','aprecon') ; % leave old optimget

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
      error('curvefit:snls:typicalXmustBeInt', ...
            'Option ''TypicalX'' must be an integer value if not the default.')
   end
end
if ischar(kmax)
   if isequal(lower(kmax),'max(1,floor(numberofvariables/2))')
      kmax = max(1,floor(numberOfVariables/2));
   else
      error('curvefit:snls:maxpcginterMustBeInt', ...
         'Option ''MaxPCGIter'' must be an integer value if not the default.')
   end
end
if ischar(maxfunevals)
   if isequal(lower(maxfunevals),'100*numberofvariables')
      maxfunevals = 100*numberOfVariables;
   else
      error('curvefit:snls:maxFunEvalsMustBeInt', ...
         'Option ''MaxFunEvals'' must be an integer value if not the default.')
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

ex = 0; posdef = 1; npcg = 0; pcgit = 0;
if strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on')
   warning('curvefit:snls:ignoringDerivativeCheckOption', ...
          ['Trust region algorithm does not currently check user-supplied ',...
           'derivatives;\n  ignoring OPTIONS.DerivativeCheck.\n']);
end

%tol1 = tol; tol2 = sqrt(tol1)/10;
vpcg(1,1) = 0; vpos(1,1) = 1;
delta = 10;nrmsx = 1; ratio = 0; 
degen = inf; DS = speye(n);
v = zeros(n,1); dv = ones(n,1); del = 10*eps;
x = xstart; oval = inf;
g = zeros(n,1); nbnds = 1; Z = [];

% If no upper and lower bounds, then set degen flag to -1.
if all( (l == -inf) & (u == inf) )
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
      [A,findiffevals] = sfdnls(xcurr,fvec,Jstr,group,[],funfcn{3},YDATA,varargin{:});
   else % user-supplied computation of J or dnewt 
      %[fvec,A] = feval(fname,x);
      fvec = fval;
      A = JACval;
      findiffevals = 0;
   end
   numFunEvals = numFunEvals + 1 + findiffevals;


delbnd = max(100*norm(xstart),1);

[mm,pp] = size(fvec);
if mm < n, 
   error('curvefit:snls:moreEquationsNeeded', ...
         'The number of equations must not be less than n.'); 
end

%   Extract the Newton direction?
if pp == 2, 
   dnewt = fvec(1:n,2); 
end

%   Determine gradient of the nonlinear least squares function
g = feval(mtxmpy,A,fvec(:,1),-1,varargin{:});

%   Evaluate F (initial point)
val = fvec(:,1)'*fvec(:,1); vval(it,1) = val;

%   Display
if showstat > 1 
   figtr=display1('init',itb,tol,verb,nbnds,x,g,l,u);
end
if verb > 2
   disp(header)
end

%   Main loop: Generate feas. seq. x(it) s.t. ||F(x(it)|| is decreasing.
while ~ex && ~isequal(OPT_STOP, 1) 
   if any(~isfinite(fvec)) 
      error('curvefit:snls:fncReturningInfsOrNaNs', ...
            ['%s cannot continue: user function '...
             'is returning Inf or NaN values.'], caller)
   end
      
   %  Stop (Interactive)?
   figtr=findobj('type','figure','Name','Progress Information');
   if ~isempty(figtr)
      lsotframe = findobj(figtr,'type','uicontrol',...
         'Userdata','LSOT frame') ;
      if get(lsotframe,'Value'), 
         ex = 10 % New exiting condition 
         EXITFLAG = -1;
         if verb > 0
            display('Exiting per request.')
         end       
      end 
   end 
   
   % Update 
   [v,dv] = definev(g,x,l,u); 
   gopt = v.*g;
   optnrm = norm(gopt,inf);
   voptnrm(it,1) = optnrm; 
   r = abs(min(u-x,x-l));
   degen = min(r + abs(g));
   vdeg(it,1) = min(degen,1);
   if ~nbnds 
      degen = -1; 
   end
   bndfeas = min(min(x-l,u-x));
   % Display
   if showstat > 1
      display1('progress',it,optnrm,val,pcgit,...
         npcg,degen,bndfeas,showstat,nbnds,x,g,l,u,figtr);
   end
   if verb > 2
      currOutput = sprintf(formatstr,it,numFunEvals,val,nrmsx,optnrm,pcgit);
      disp(currOutput);
   end
   
   %     Test for convergence
   diff = abs(oval-val); 
   oval = val; 
   if (nrmsx < .9*delta)&&(ratio > .25)&&(diff < tol1*(1+abs(oval)))
      ex = 1;
      msg = sprintf(['Optimization terminated successfully:\n',...
                        ' Relative function value changing by less than TolFun.']);
      EXITFLAG = 1;
   elseif (it > 1) && (nrmsx < tol2), 
      ex = 2;   EXITFLAG = 1;
      msg = sprintf(['Optimization terminated successfully:\n',...
                        ' Norm of the current step is less than TolX.']);
      
   elseif ((optnrm < tol1) && (posdef ==1) ),  
      ex = 3;   EXITFLAG = 1;
      msg = sprintf(['Optimization terminated successfully:\n',...
                        ' First-order optimality less than TolFun, and no negative/zero curvature detected.']);
      
   elseif it > itb, 
      ex = 4;    EXITFLAG = 0;
       msg = sprintf(['Maximum number of iterations exceeded. Increasing MaxIter\n',...
                      '(in fit options) may allow for a better fit, or the current\n',...
                      'equation may not be a good model for the data.']);
   end
   
   %     Continue if ex = 0 (i.e., not done yet)
   if ~ex 
      %       Determine the trust region correction
      dd = abs(v); D = sparse(1:n,1:n,full(sqrt(dd))); 
      vpos(it,1) = posdef;
      theta = max(.95,1-optnrm);  
      oposdef = posdef;
      [sx,snod,qp,posdef,pcgit,Z] = trdog(x,g,A,D,delta,dv,...
         mtxmpy,pcmtx,pcflags,pcgtol,kmax,theta,l,u,Z,dnewt,'jacobprecon',varargin{:});
      
      if isempty(posdef), 
         posdef = oposdef; 
      end
      nrmsx=norm(snod); 
      npcg=npcg+pcgit; 
      newx=x+sx;  
      vpcg(it+1,1)=pcgit;
      
      %       Perturb?
      [pert,newx] = perturb(newx,l,u);
      vpos(it+1,1) = posdef;
      
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
            error('curvefit:snls:undefinedCalltype', ...
                  'Undefined calltype in %s.',caller);
         end
         % pass in funfcn{3} since we know no gradient
         [newA, findiffevals] = sfdnls(xcurr,newfvec,Jstr,group,[],funfcn{3},YDATA,varargin{:});
      else % use user-supplied detrmination of J or dnewt
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
            error('curvefit:snls:undefinedCalltype', ...
                  'Undefined calltype in %s.',caller);
         end
      end
      numFunEvals = numFunEvals + 1 + findiffevals;
      
      [mm,pp] = size(newfvec);
      if mm < n, 
         error('curvefit:snls:undefinedCalltype', ...
               'The number of equations must be greater than n.'); 
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
      it=it+1; 
      vval(it,1) = val;
   end
   if it > itb 
      ex=4; EXITFLAG = 0;
      it = it-1; 
       msg = sprintf(['Maximum number of iterations exceeded. Increasing MaxIter\n',...
                      '(in fit options) may allow for a better fit, or the current\n',...
                      'equation may not be a good model for the data.']);
   end
   if numFunEvals > maxfunevals 
      ex=4; EXITFLAG = 0;
      it = it - 1;
             msg = sprintf(['Maximum number of function evaluations exceeded. Increasing\n',...
                            'MaxFunEvals (in fit options) may allow for a better fit, or \n',...
                            'the current equation may not be a good model for the data.']);
   end
end
if OPT_STOP
    error('curvefit:snsls:fittingCancelled', 'Fitting computation cancelled.');
end
%
%   Display
if showstat > 1 
   display1('final',figtr);
end
if showstat 
   xplot(it,vval,voptnrm,vpos,vdeg,vpcg);
end
JACOB = sparse(A);     % A is the Jacobian, not the gradient.
OUTPUT.iterations = it;
OUTPUT.funcCount = numFunEvals;
OUTPUT.firstorderopt = optnrm;
OUTPUT.algorithm = 'Trust-Region Reflective Newton'; 
xcurr(:)=x;

if computeLambda
   LAMBDA.lower = zeros(length(l),1);
   LAMBDA.upper = zeros(length(u),1);
   argl = (abs((x-l)./(1+x)) < active_tol);
   argu = (abs((x-u)./(1+x)) < active_tol);
   
   g = full(g);
   
   LAMBDA.lower(argl) = (g(argl));
   LAMBDA.upper(argu) = -(g(argu));
else
   LAMBDA = [];
end






