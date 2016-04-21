function [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = sfminbx(funfcn,x,l,u,verb,options,defaultopt,...
    computeLambda,initialf,initialGRAD,initialHESS,Hstr,varargin)
%SFMINBX Nonlinear minimization with box constraints.
%
% Locate a local minimizer to 
%
%               min { f(x) :  l <= x <= u}.
%
%	where f(x) maps n-vectors to scalars.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/06 01:10:32 $

%   Initialization
xcurr = x(:);  % x has "the" shape; xcurr is a vector
n = length(xcurr); 
iter = 0; 
numFunEvals = 1;  % feval of user function in fmincon or fminunc

header = sprintf(['\n                                Norm of      First-order \n',...
        ' Iteration        f(x)          step          optimality   CG-iterations']);
formatstrFirstIter = ' %5.0f      %13.6g                  %12.3g                ';
formatstr = ' %5.0f      %13.6g  %13.6g   %12.3g     %7.0f';
if n == 0, 
    error('optim:sfminbx:InvalidN','n must be positive.')
end
% If called from fminunc, need to fill in l and u.
if isempty(l)
    l = repmat(-inf,n,1);
end
if isempty(u)
    u = repmat(inf,n,1);
end
arg = (u >= 1e10); arg2 = (l <= -1e10);
u(arg) = inf;
l(arg2) = -inf;
if any(u == l) 
    error('optim:sfminbx:InvalidBounds', ...
          ['Equal upper and lower bounds not permitted in this large-scale method.\n' ...
           'Use equality constraints and the medium-scale method instead.'])
elseif min(u-l) <= 0
    error('optim:sfminbx:InconsistentBounds','Inconsistent bounds.')
end

% get options out
typx = optimget(options,'TypicalX',defaultopt,'fast') ;
% In case the defaults were gathered from calling: optimset('quadprog'):
numberOfVariables = n;
if ischar(typx)
    if isequal(lower(typx),'ones(numberofvariables,1)')
        typx = ones(numberOfVariables,1);
    else
        error('optim:sfminbx:InvalidTypicalX', ...
              'Option ''TypicalX'' must be a numeric value if not the default.')
    end
end
DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');

% Will be user-settable later:
showstat = optimget(options,'showstatuswindow','off'); % not a default yet, so use slow optimget
pcmtx = optimget(options,'Preconditioner',@hprecon) ; % not a default yet

mtxmpy = optimget(options,'HessMult',defaultopt,'fast') ;  
if isempty(mtxmpy)
    mtxmpy = @hmult; % to detect name clash with user hmult.m, need this
end

switch showstat
case 'iter'
   showstat = 2;
case {'none','off'}
   showstat = 0;
case 'final'
   showstat = 1;
case {'iterplus','iterplusbounds'}  % if no finite bounds, this is the same as 'iter'
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
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
end
stop = false;

active_tol = optimget(options,'ActiveConstrTol',sqrt(eps)); % not a default yet, so use slow optimget
pcflags = optimget(options,'PrecondBandWidth',defaultopt,'fast') ;
tol2 = optimget(options,'TolX',defaultopt,'fast') ;
tol1 = optimget(options,'TolFun',defaultopt,'fast') ;
tol = tol1;
maxiter = optimget(options,'MaxIter',defaultopt,'fast') ;
maxfunevals = optimget(options,'MaxFunEvals',defaultopt,'fast') ;
pcgtol = optimget(options,'TolPCG',defaultopt,'fast') ;  % pcgtol = .1;
kmax = optimget(options,'MaxPCGIter', defaultopt,'fast') ;
if ischar(kmax)
    if isequal(lower(kmax),'max(1,floor(numberofvariables/2))')
        kmax = max(1,floor(numberOfVariables/2));
    else
        error('optim:sfminbx:InvalidMaxPCGIter', ...
              'Option ''MaxPCGIter'' must be an integer value if not the default.')
    end
end
if ischar(maxfunevals)
    if isequal(lower(maxfunevals),'100*numberofvariables')
        maxfunevals = 100*numberOfVariables;
    else
        error('optim:sfminbx:InvalidMaxFunEvals', ...
              'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end

dnewt = [];  
ex = 0; posdef = 1; npcg = 0; 

%tol1 = tol; tol2 = sqrt(tol1)/10; 

vpos(1,1) = 1; vpcg(1,1) = 0;
nbnds = 1;
pcgit = 0; delta = 10;nrmsx = 1; ratio = 0;
if (all(u == inf) && all(l == -inf)) 
    nbnds = 0; 
end
oval = inf;  g = zeros(n,1); newgrad = g; Z = []; 

% First-derivative check
if DerivativeCheck
    %
    % Calculate finite-difference gradient
    % 
    gf=finitedifferences(xcurr,x,funfcn,[],l,u,initialf,[],...
        [],DiffMinChange,DiffMaxChange,typx,[],'all',...
        [],[],[],[],[],[],varargin{:});
    %
    % Compare user-supplied versus finite-difference gradients
    %
    disp('Function derivative')
    if isa(funfcn{4},'inline')
        graderr(gf, initialGRAD, formula(funfcn{4}));
    else 
        graderr(gf, initialGRAD, funfcn{4});
    end
    numFunEvals = numFunEvals + numberOfVariables;
end

if ~isempty(Hstr)  % use sparse finite differencing
    switch funfcn{1}
        case 'fun'
            error('optim:sfminbx:ShouldNotReachThis','should not reach this')
        case 'fungrad'
            val = initialf; g(:) = initialGRAD;
        case 'fun_then_grad'
            val = initialf; g(:) = initialGRAD;
        otherwise
            if isequal(funfcn{2},'fmincon')
                error('optim:sfminbx:UndefinedFMINCONCalltype','Undefined calltype in FMINCON.')
            else
                error('optim:sfminbx:UndefinedFMINUNCCalltype','Undefined calltype in FMINUNC.')
            end
    end
    % Determine coloring/grouping for sparse finite-differencing
    p = colamd(Hstr)'; 
    p = (n+1) - p;
    group = color(Hstr,p);
    % pass in the user shaped x
    H = sfd(x,g,Hstr,group,[],DiffMinChange,DiffMaxChange,funfcn,varargin{:});
    %
else % user-supplied computation of H or dnewt
    switch funfcn{1}
        case 'fungradhess'
            val = initialf; g(:) = initialGRAD; H = initialHESS;
        case 'fun_then_grad_then_hess'
            val = initialf; g(:) = initialGRAD; H = initialHESS;
        otherwise
            if isequal(funfcn{2},'fmincon')
                error('optim:sfminbx:UndefinedFMINCONCalltype','Undefined calltype in FMINCON.')
            else
                error('optim:sfminbx:UndefinedFMINUNCCalltype','Undefined calltype in FMINUNC.')
            end
    end
end

delbnd = max(100*norm(xcurr),1);
[nn,pp] = size(g);

%   Extract the Newton direction?
if pp == 2, dnewt = g(1:n,2); end
if showstat > 1
   figtr=display1('init',maxiter,tol,showstat,nbnds,xcurr,g(:,1),l,u); 
end
if verb > 1
    disp(header)
end

% Initialize the output function.
if haveoutputfcn
   [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xcurr,xOutputfcn,'init',iter,numFunEvals, ...
        val,[],[],[],pcgit,[],[],[],delta,varargin{:});
    if stop
        [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = cleanUpInterrupt(xOutputfcn,optimValues);
        if verb > 0
            disp(OUTPUT.message)
        end
        return;
    end
end

%   MAIN LOOP: GENERATE FEAS. SEQ.  xcurr(iter) S.T. f(x(iter)) IS DECREASING.
while ~ex
    if ~isfinite(val) || any(~isfinite(g))
        error('optim:sfminbx:InvalidUserFunction', ...
              '%s cannot continue: user function is returning Inf or NaN values.',funfcn{2})
    end
    
   %     Stop (interactive)?
   figtr = findobj('type','figure','Name','Progress Information') ;
   if ~isempty(figtr)
      lsotframe = findobj(figtr,'type','uicontrol',...
         'Userdata','LSOT frame') ;
      if get(lsotframe,'Value'), 
         ex = 10; % New exiting condition 
         outMessage = 'Exiting per request.';
         if verb > 0
            display(outMessage)
         end
      end 
   end 
    
    %     Update
    [v,dv] = definev(g(:,1),xcurr,l,u); 
    gopt = v.*g(:,1); gnrm = norm(gopt,inf);
    vgnrm(iter+1,1)=gnrm;
    r = abs(min(u-xcurr,xcurr-l)); degen = min(r + abs(g(:,1)));
    vdeg(iter+1,1) = min(degen,1); 
    bndfeas = min(min(xcurr-l,u-xcurr));
    % If no upper and lower bounds (e.g., fminunc), then set degen flag to -1.
    if all( (l == -inf) & (u == inf) )
        degen = -1; 
    end
    
    % Display
    if showstat > 1
        display1('progress',iter+1,gnrm,val,pcgit,npcg,degen,...
            bndfeas,showstat,nbnds,xcurr,g(:,1),l,u,figtr,posdef); 
    end
    if verb > 1
        if iter > 0
            currOutput = sprintf(formatstr,iter,val,nrmsx,gnrm,pcgit);
        else
            currOutput = sprintf(formatstrFirstIter,iter,val,gnrm);
        end
        disp(currOutput);
    end
    
    % OutputFcn call
    if haveoutputfcn
       [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xcurr,xOutputfcn,'iter',iter,numFunEvals, ...
            val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,varargin{:});
        if stop  % Stop per user request.
            [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = ...
                cleanUpInterrupt(xOutputfcn,optimValues);
            if verb > 0
                disp(OUTPUT.message)
            end
            return;
        end
    end
    
    %     TEST FOR CONVERGENCE
    diff = abs(oval-val); 
    oval = val; 
    if ((gnrm < tol1) && (posdef ==1) )
        ex = 3;
        outMessage = ...
          sprintf(['Optimization terminated: first-order optimality less than OPTIONS.TolFun,\n', ...
                   ' and no negative/zero curvature detected in trust region model.']);        
        if verb > 0
            disp(outMessage)
        end
    elseif (nrmsx < .9*delta) && (ratio > .25) && (diff < tol1*(1+abs(oval)))
        ex = 1;
        outMessage = sprintf(['Optimization terminated:' ... 
                  ' Relative function value changing by less than OPTIONS.TolFun.']);
        if verb > 0
            disp(outMessage)
        end
    elseif (iter > 1) && (nrmsx < tol2) 
        ex = 2;
        outMessage = sprintf(['Optimization terminated:' ...
                    ' Norm of the current step is less than OPTIONS.TolX.']);
        if verb > 0
            disp(outMessage)
        end
    elseif numFunEvals > maxfunevals
        ex = 4;
        outMessage = sprintf(['Maximum number of function evaluations exceeded;\n' ...
                            '   increase options.MaxFunEvals.']);
        if verb > 0
            disp(outMessage)
        end
    elseif iter > maxiter
        ex = 4;
        outMessage = sprintf(['Maximum number of iterations exceeded;\n' ...
                            '   increase options.MaxIter.']);
        if verb > 0
            disp(outMessage)
        end
    end
    
    %     Step computation
    if ~ex
        
        %       Determine trust region correction
        dd = abs(v); D = sparse(1:n,1:n,full(sqrt(dd))); 
        theta = max(.95,1-gnrm);  
        oposdef = posdef;
        [sx,snod,qp,posdef,pcgit,Z] = trdog(xcurr, g(:,1),H,D,delta,dv,...
            mtxmpy,pcmtx,pcflags,pcgtol,kmax,theta,l,u,Z,dnewt,'hessprecon',varargin{:});
        if isempty(posdef), posdef = oposdef; end
        nrmsx=norm(snod); npcg=npcg + pcgit;
        newx=xcurr + sx; 
        vpcg(iter+1,1)=pcgit;
        
        %       Perturb?
        [pert,newx] = perturb(newx,l,u);
        vpos(iter+1,1) = posdef;  
        
        % OutputFcn call
        if haveoutputfcn
            % Use the xOutputfcn and optimValues from last call to outputfcn (do not call
            % callOutputFcn)
            stop = feval(outputfcn,[],[],'interrupt',varargin{:});
            if stop  % Stop per user request.
                [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = ...
                    cleanUpInterrupt(xOutputfcn,optimValues);
                if verb > 0
                    disp(OUTPUT.message)
                end
                return;
            end
        end
        
        % Make newx conform to user's input x
        x(:) = newx;
        % Evaluate f, g, and H
        if ~isempty(Hstr) % use sparse finite differencing
            switch funfcn{1}
                case 'fun'
                    error('optim:sfminbx:ShouldNotReachThis','should not reach this')
                case 'fungrad'
                    [newval,newgrad(:)] = feval(funfcn{3},x,varargin{:});
                case 'fun_then_grad'
                    newval = feval(funfcn{3},x,varargin{:}); 
                    newgrad(:) = feval(funfcn{4},x,varargin{:});
                otherwise
                    if isequal(funfcn{2},'fmincon')
                        error('optim:sfminbx:UndefinedCalltypeInFMINCON', ...
                              'Undefined calltype in FMINCON.')
                    else
                        error('optim:sfminbx:UndefinedCalltypeInFMINUNC', ...
                              'Undefined calltype in FMINUNC.')
                    end
            end
            newH = sfd(x,newgrad,Hstr,group,[],DiffMinChange,DiffMaxChange, ...
                       funfcn,varargin{:});
            
        else % user-supplied computation of H or dnewt
            switch funfcn{1}
                case 'fungradhess'
                    [newval,newgrad(:),newH] = feval(funfcn{3},x,varargin{:});
                case 'fun_then_grad_then_hess'
                    newval = feval(funfcn{3},x,varargin{:}); 
                    newgrad(:) = feval(funfcn{4},x,varargin{:});
                    newH = feval(funfcn{5},x,varargin{:});
                otherwise
                    if isequal(funfcn{2},'fmincon')
                        error('optim:sfminbx:UndefinedCalltypeInFMINCON', ...
                              'Undefined calltype in FMINCON.')
                    else
                        error('optim:sfminbx:UndefinedCalltypeInFMINUNC', ...
                              'Undefined calltype in FMINUNC.')
                    end
            end
            
        end
        numFunEvals = numFunEvals + 1;
        [nn,pp] = size(newgrad);
        aug = .5*snod'*((dv.*abs(newgrad(:,1))).*snod);
        ratio = (newval + aug -val)/qp; 
        vratio(iter+1,1) = ratio;
        
        if (ratio >= .75) && (nrmsx >= .9*delta)
            delta = min(delbnd,2*delta);
        elseif ratio <= .25
            delta = min(nrmsx/4,delta/4);
        end
        if newval == inf
            delta = min(nrmsx/20,delta/20);
        end
        
        %       Update
        if newval < val
            xcurr=newx; val = newval; g= newgrad; H = newH;
            Z = [];
            
            %          Extract the Newton direction?
            if pp == 2, dnewt = newgrad(1:n,2); end
        end
        iter = iter + 1;
        vval(iter+1,1) = val;
    end % if ~ex
end % while

if showstat > 1
    display1('final',figtr); 
end
if showstat 
    xplot(iter+1,vval,vgnrm,vpos,vdeg,vpcg);
end

if haveoutputfcn
   [xOutputfcn, optimValues] = callOutputFcn(outputfcn,xcurr,xOutputfcn,'done',iter,numFunEvals, ...
        val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,varargin{:});
    % Do not check value of 'stop' as we are done with the optimization
    % already.
end
HESSIAN = H;
GRAD = g;
FVAL = val;
LAMBDA = [];

if ex == 3
  EXITFLAG = 1;  % first order optimality conditions hold
elseif ex == 1
  EXITFLAG = 3;  % relative change in f small
elseif ex == 2
  EXITFLAG = 2;  % norm of step small
elseif ex == 4   % MaxIter or MaxFunEval
  EXITFLAG = 0;
else             % ex = 10
  EXITFLAG = -1; % Exiting per request
end

OUTPUT.iterations = iter;
OUTPUT.funcCount = numFunEvals;
OUTPUT.cgiterations = npcg;
OUTPUT.firstorderopt = gnrm;
OUTPUT.algorithm = 'large-scale: trust-region reflective Newton'; 
OUTPUT.message = outMessage;

x(:) = xcurr;
if computeLambda
    g = full(g);
    
    LAMBDA.lower = zeros(length(l),1);
    LAMBDA.upper = zeros(length(u),1);
    argl = logical(abs(xcurr-l) < active_tol);
    argu = logical(abs(xcurr-u) < active_tol);
    
    LAMBDA.lower(argl) = (g(argl));
    LAMBDA.upper(argu) = -(g(argu));
    LAMBDA.ineqlin = []; LAMBDA.eqlin = []; LAMBDA.ineqnonlin=[]; LAMBDA.eqnonlin=[];
else
    LAMBDA = [];   
end

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xvec,xOutputfcn,state, ... 
    iter,numFunEvals, ...
    val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,varargin)
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
optimValues.fval = val;
optimValues.stepsize = nrmsx;
optimValues.gradient = g;
optimValues.firstorderopt = gnrm;
optimValues.cgiterations = pcgit;
optimValues.positivedefinite = posdef;
optimValues.ratio = ratio;
optimValues.degenerate = min(degen,1);
optimValues.trustregionradius = delta;
optimValues.procedure = '';
xOutputfcn(:) = xvec;  % Set x to have user expected size

switch state
    case {'iter','init'}
        stop = feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    case 'done'
        stop = false;
        feval(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    otherwise
        error('optim:sfminbx:UnknownCALLOUTPUTFCNState','Unknown state in CALLOUTPUTFCN.')
end

%--------------------------------------------------------------------------
function [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT updates or sets all the output arguments of SFMINBX when the optimization 
% is interrupted.  The HESSIAN and LAMBDA are set to [] as they may be in a
% state that is inconsistent with the other values since we are
% interrupting mid-iteration.

x = xOutputfcn; 
FVAL = optimValues.fval;
EXITFLAG = -1; 
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.stepsize = optimValues.stepsize;
OUTPUT.algorithm = 'large-scale: trust-region reflective Newton'; 
OUTPUT.firstorderopt = optimValues.firstorderopt; 
OUTPUT.cgiterations = optimValues.cgiterations;
OUTPUT.message = 'Optimization terminated prematurely by user.';
GRAD = optimValues.gradient;
HESSIAN = []; % May be in an inconsistent state
LAMBDA = []; % May be in an inconsistent state


