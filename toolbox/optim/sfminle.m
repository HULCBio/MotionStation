function[x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN]= sfminle(funfcn,x,A,b,verb,options,defaultopt,...
    computeLambda,initialf,initialGRAD,initialHESS,Hstr,varargin)
%SFMINLE Nonlinear minimization with linear equalities.
%
% [x,val,g,iter,npcg,ex]=sfminle(fname,xstart,A,b,verb,...
%	         pcmtx,pcflags,mtxmpy,tol,itb,showstat,Hstr,options)
% Locate a local minimizer to 
%
%               min { f(x) :  Ax = b}.
%
%	where f(x) maps n-vectors to scalars.
%
% Driver function is SFMIN

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/06 01:10:33 $

%   Initialization
xcurr = x(:); % x has "the" shape; xcurr is a vector
numFunEvals = 1;  % done in calling function fmincon

n = length(xcurr); iter= 0; totls = 0;
header = sprintf(['\n                                Norm of      First-order \n',...
        ' Iteration        f(x)          step          optimality   CG-iterations']);
formatstrFirstIter = ' %5.0f      %13.6g                  %12.3g                ';
formatstr = ' %5.0f      %13.6g  %13.6g   %12.3g     %7.0f';

if n == 0, 
    error('optim:sfminle:InvalidN','n must be positive.')
end
[mm,nn] = size(A);
if n ~= nn
    error('optim:sfminle:AeqAndXInconsistent', ...
          'Column dimension of Aeq is inconsistent with length of X.')
end
m = length(b);
if m ~= mm
    error('optim:sfminle:AeqAndBeqInconsistent', ...
          'Row dimension of Aeq is inconsistent with length of beq.')
end

numberOfVariables = n;

% get options out
pcmtx = optimget(options,'Preconditioner',@preaug) ; %not default yet, so use slow optimget
mtxmpy = optimget(options,'HessMult',defaultopt,'fast') ;
if isempty(mtxmpy)
    mtxmpy = @hmult;
end
pcflags = optimget(options,'PrecondBandWidth',defaultopt,'fast') ;
tol2 = optimget(options,'TolX',defaultopt,'fast') ;
tol1 = optimget(options,'TolFun',defaultopt,'fast') ;
tol = tol1;
maxiter = optimget(options,'MaxIter',defaultopt,'fast') ;
maxfunevals = optimget(options,'MaxFunEvals',defaultopt,'fast') ;
pcgtol = optimget(options,'TolPCG',defaultopt,'fast') ;  % pcgtol = .1;
pcgtol = min(pcgtol, 1e-2);  % better default
kmax = optimget(options,'MaxPCGIter',defaultopt,'fast') ;
typx = optimget(options,'TypicalX',defaultopt,'fast') ;
if ischar(typx)
    if isequal(lower(typx),'ones(numberofvariables,1)')
        typx = ones(numberOfVariables,1);
    else
        error('optim:sfminle:InvalidTypicalX', ...
              'Option ''TypicalX'' must be a numeric value if not the default.')
    end
end
DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');

if ischar(kmax)
    if isequal(lower(kmax),'max(1,floor(numberofvariables/2))')
        kmax = max(1,floor(numberOfVariables/2));
    else
        error('optim:sfminle:InvalidMaxPCGIter', ...
              'Option ''MaxPCGIter'' must be an integer value if not the default.')
    end
end
if ischar(maxfunevals)
    if isequal(lower(maxfunevals),'100*numberofvariables')
        maxfunevals = 100*numberOfVariables;
    else
        error('optim:sfminle:InvalidMaxFunEvals', ...
              'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
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

% Will be user-settable later:
showstat = optimget(options,'showstatus','off'); %use old slow optimget since no default yet
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

dnewt = []; gopt = []; nrows = 0;
snod = [];
ex = 0; posdef = 1; npcg = 0; vpos(1,1) = 1; vpcg(1,1) = 0; 
pcgit = 0; delta = 100;nrmsx = 1; ratio = 0; degen = inf; 
DS = speye(n);   v = ones(n,1); dv = ones(n,1); del = 10*eps;
oval = inf;  gradf = zeros(n,1); newgrad = gradf; Z = []; 

% First-derivative check
if DerivativeCheck
    %
    % Calculate finite-difference gradient
    %
    gf=finitedifferences(xcurr,x,funfcn,[],[],[],initialf,[],...
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

%   Remove (numerical) linear dependencies from A
AA = A; bb = b;
[A,b] = dep(AA,[],bb);
[m,n1] = size(A); [mm,n2] = size(AA);
if verb > 1 & m ~= mm
    disp('linear dependencies'), mm-m, disp(' rows of A removed'); end

%   Get feasible: nearest feas. pt. to xstart
xcurr = feasibl(A,b,xcurr);


% Make xcurr conform to the user's input x
x(:) = xcurr;

if ~isempty(Hstr) % use sparse finite differencing
    
    switch funfcn{1}
        case 'fun'
            error('optim:sfminle:ShouldNotReachThis','should not reach this')
        case 'fungrad'
            val = initialf; gradf(:) = initialGRAD;
        case 'fun_then_grad'
            val = initialf; gradf(:) = initialGRAD;
        otherwise
            error('optim:sfminle:UndefinedCalltypeInFMINCON', ...
                  'Undefined calltype in FMINCON.')
    end
    
    %      Determine coloring/grouping for sparse finite-differencing
    p = colamd(Hstr)'; p = (n+1)*ones(n,1)-p; group = color(Hstr,p);
    H = sfd(x,gradf,Hstr,group,[],DiffMinChange,DiffMaxChange, ...
            funfcn,varargin{:});
    
else % user-supplied computation of H or dnewt
    switch funfcn{1}
        case 'fungradhess'
            val = initialf; gradf(:) = initialGRAD; H = initialHESS;
        case 'fun_then_grad_then_hess'
            val = initialf; gradf(:) = initialGRAD; H = initialHESS;
        otherwise
            error('optim:sfminle:UndefinedCalltypeInFMINCON', ...
                  'Undefined calltype in FMINCON.')
    end
end
[nn,pnewt] = size(gradf);

%   Extract the Newton direction?
if pnewt == 2, dnewt = gradf(1:n,2); end
PT = findp(A);
[g,LZ,UZ,pcolZ,PZ] = project(A,-gradf(1:n,1),PT);
gnrm = norm(g,inf);

if showstat > 1, 
    figtr=display1('init',maxiter,tol,showstat,0,xcurr,g(:,1),[],[]); 
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


%   MAIN LOOP: GENERATE FEAS. SEQ.  xcurr(iter) S.T. f(xcurr(iter)) IS DECREASING.
while ~ex
    if ~isfinite(val) | any(~isfinite(gradf))
        error('optim:sfminle:InvalidUserFunction', ...
              '%s cannot continue: user function is returning Inf or NaN values.',funfcn{2})
    end
    
    %     Stop (interactive)?
    figtr = findobj('type','figure','Name','Progress Information') ;
    if ~isempty(figtr)
        lsotframe = findobj(figtr,'type','uicontrol',...
            'Userdata','LSOT frame') ;
        if get(lsotframe,'Value'), 
            ex = 10; % New exiting condition 
            EXITFLAG = -1;
            outMessage = 'Exiting per request.';
            if verb > 0
                display(outMessage)
            end
            
        end 
    end 
    
    % Update and display
    vgnrm(iter+1,1)=gnrm;
    if showstat > 1
        display1('progress',iter+1,gnrm,val,pcgit,npcg,degen,...
            [],showstat,0,xcurr,g(:,1),[],[],figtr,posdef); 
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
    if ((gnrm < tol1) & (posdef ==1) ),
        ex = 3; EXITFLAG = 1;
        outMessage = ...
          sprintf(['Optimization terminated: first-order optimality less than OPTIONS.TolFun,\n' ...
                   ' and no negative/zero curvature detected in trust region model.']);
        if verb > 0
            disp(outMessage)
        end
    elseif (nrmsx < .9*delta)&(ratio > .25)&(diff < tol1*(1+abs(oval)))
        ex = 1; EXITFLAG = 3;
        outMessage = sprintf(['Optimization terminated:' ...
             ' Relative function value changing by less than OPTIONS.TolFun.']);        
        if verb > 0
            disp(outMessage)
        end
        
    elseif (iter > 1) & (nrmsx < tol2), 
        ex = 2; EXITFLAG = 2;
        outMessage = sprintf(['Optimization terminated:' ...
                    ' Norm of the current step is less than OPTIONS.TolX.']);
        if verb > 0
            disp(outMessage)
        end
        
    elseif iter > maxfunevals
        ex=4; EXITFLAG = 0;
        outMessage = sprintf(['Maximum number of function evaluations exceeded;\n' ...
                            '   increase options.MaxFunEvals.']);
        if verb > 0
            disp(outMessage)
        end
    elseif iter > maxiter
        ex=4; EXITFLAG = 0;
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
        grad = D*g(:,1);
        sx = zeros(n,1); theta = max(.95,1-gnrm);  
        oposdef = posdef;
        [sx,snod,qp,posdef,pcgit,Z] = trdg(xcurr,gradf(:,1),H,...
            delta,g,mtxmpy,pcmtx,pcflags,...
            pcgtol,kmax,A,zeros(m,1),Z,dnewt,options,defaultopt,...
            PT,LZ,UZ,pcolZ,PZ,varargin{:});
        
        if isempty(posdef), 
            posdef = oposdef; 
        end
        nrmsx=norm(snod); 
        npcg=npcg + pcgit;
        newx=xcurr + sx; 
        
        vpcg(iter+1,1)=pcgit;
        vpos(iter+1,1) = posdef;
        
        % OutputFcn call
        if haveoutputfcn
            stop = feval(outputfcn,xOutputfcn,optimValues,'interrupt',varargin{:});
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
        %       Evaluate f,g,  and H
        if ~isempty(Hstr) % use sparse finite differencing
            switch funfcn{1}
                case 'fun'
                    error('optim:sfminle:ShouldNotReachThis','should not reach this')
                case 'fungrad'
                    [newval,newgrad(:)] = feval(funfcn{3},x,varargin{:});
                case 'fun_then_grad'
                    newval = feval(funfcn{3},x,varargin{:}); 
                    newgrad(:) = feval(funfcn{4},x,varargin{:});
                otherwise
                    error('optim:sfminle:UndefinedCalltypeInFMINCON', ...
                          'Undefined calltype in FMINCON.')
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
                    error('optim:sfminle:UndefinedCalltypeInFMINCON', ...
                          'Undefined calltype in FMINCON.')
            end
            
        end
        numFunEvals = numFunEvals + 1;
        
        [nn,pnewt] = size(newgrad);
        if pnewt == 2, 
            dnewt = newgrad(1:n,2); 
        end
        aug = .5*snod'*((dv.*abs(newgrad(:,1))).*snod);
        ratio = (newval + aug -val)/qp; 
        vratio(iter+1,1) = ratio;
        if (ratio >= .75) & (nrmsx >= .9*delta),
            delta = 2*delta;
        elseif ratio <= .25, 
            delta = min(nrmsx/4,delta/4);
        end
        if newval == inf; 
            delta = min(nrmsx/20,delta/20);
        end
        
        %       Update
        if newval < val
            xold = xcurr; 
            xcurr=newx; 
            val = newval; 
            gradf= newgrad; 
            H = newH;
            Z = [];
            if pnewt == 2, 
                dnewt = newgrad(1:n,2); 
            end
            g = project(A,-gradf(:,1),PT,LZ,UZ,pcolZ,PZ);
            gnrm = norm(g,inf);
            
            %          Extract the Newton direction?
            if pnewt == 2, 
                dnewt = newgrad(1:n,2); 
            end
        end
        iter = iter+1; 
        vval(iter+1,1) = val;
        
    end % if ~ex
end % while

if showstat >1,
    display1('final',figtr); 
end
if showstat, 
    xplot(iter+1,vval,vgnrm,vpos,[],vpcg); 
end

if haveoutputfcn
    [xOutputfcn, optimValues] = callOutputFcn(outputfcn,xcurr,xOutputfcn,'done',iter,numFunEvals, ...
        val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,varargin{:});
end


HESSIAN = H;
GRAD = g;
FVAL = val;
if computeLambda
    LAMBDA.eqlin = -A'\gradf;
    LAMBDA.ineqlin = []; LAMBDA.upper = []; LAMBDA.lower = [];
else
    LAMBDA = [];
end
OUTPUT.iterations = iter;
OUTPUT.funcCount = numFunEvals;
OUTPUT.cgiterations = npcg;
OUTPUT.firstorderopt = gnrm;
OUTPUT.algorithm = 'large-scale: projected trust-region Newton';
OUTPUT.message = outMessage;
x(:) = xcurr;
%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputFcn(outputfcn,xvec,xOutputfcn,state,iter,numFunEvals, ...
    val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,varargin)
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
        error('optim:sfminle:UnknownStateInCALLOUTPUTFCN', ...
              'Unknown state in CALLOUTPUTFCN.')
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

