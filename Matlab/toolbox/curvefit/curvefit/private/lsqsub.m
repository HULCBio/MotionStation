function [X,lambda,exitflag,output,how,msg]=lsqsub(H,f,A,B,lb,ub,X,neqcstr,verbosity,caller,ncstr,numberOfVariables,options,defaultopt)
%LSQSUB Linear least squares constrained subproblem. 

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.9.2.2 $  $Date: 2004/02/01 21:43:31 $

% Global parameter, OPT_STOP is used for canceling fits
% It is initialized and set in the Curve Fitting GUI (CreateAFit.java)
global OPT_STOP 

% Define constant strings
NewtonStep = 'Newton';
SteepDescent = 'steepest descent';
Conls = 'lsqlin';
Lp = 'linprog';
Qp = 'quadprog';
Qpsub = 'qpsub';
Nlconst = 'nlconst';
how = 'ok'; 

% Override quadprog/linprog MaxIter default limit which is
% really just for largescale, not active set methods.
defaultopt.MaxIter = Inf;  

exitflag = 1;
output = [];
iterations = 0;
if nargin < 13
    options = [];
end

lb=lb(:); ub = ub(:);

msg = nargchk(12,12,nargin);
if isempty(verbosity), verbosity = 1; end
if isempty(neqcstr), neqcstr = 0; end

LLS = 0;
if strcmp(caller, Conls)
    LLS = 1;
    [rowH,colH]=size(H);
    numberOfVariables = colH;
end
if strcmp(caller, Qpsub)
    normalize = -1;
else
    normalize = 1;
end

simplex_iter = 0;
if  norm(H,'inf')==0 || isempty(H) 
    is_qp=0; 
else 
    is_qp=1; 
end

if LLS==1
    is_qp=0;
end

normf = 1;
if normalize > 0
    % Check for lp
    if ~is_qp && ~LLS
        normf = norm(f);
        if normf > 0
            f = f./normf;
        end
    end
end

% Handle bounds as linear constraints
arglb = ~eq(lb,-inf);
lenlb=length(lb); % maybe less than numberOfVariables due to old code
if nnz(arglb) > 0     
    lbmatrix = -eye(lenlb,numberOfVariables);
    
    A=[A; lbmatrix(arglb,1:numberOfVariables)]; % select non-Inf bounds
    B=[B;-lb(arglb)];
end

argub = ~eq(ub,inf);
lenub=length(ub);
if nnz(argub) > 0
    ubmatrix = eye(lenub,numberOfVariables);
    A=[A; ubmatrix(argub,1:numberOfVariables)];
    B=[B; ub(argub)];
end 
ncstr=ncstr + nnz(arglb) + nnz(argub);

% Figure out max iteration count
% For linprog/quadprog/lsqlin/qpsub problems, use 'MaxIter' for this.
% For nlconst (fmincon, etc) problems, use 'MaxSQPIter' for this.
if isequal(caller,Nlconst)
    maxiter = optimget(options,'MaxSQPIter',defaultopt,'fast');
else
    maxiter = optimget(options,'MaxIter',defaultopt,'fast'); 
end
% Used for determining threshold for whether a direction will violate
% a constraint.
normA = ones(ncstr,1);
if normalize > 0 
    for i=1:ncstr
        n = norm(A(i,:));
        if (n ~= 0)
            A(i,:) = A(i,:)/n;
            B(i) = B(i)/n;
            normA(i,1) = n;
        end
    end
else 
    normA = ones(ncstr,1);
end
errnorm = 0.01*sqrt(eps); 

tolDep = 100*numberOfVariables*eps;      
lambda=zeros(ncstr,1);
aix=lambda;
ACTCNT=0;
ACTSET=[];
ACTIND=0;
CIND=1;
eqix = 1:neqcstr; 

%------------EQUALITY CONSTRAINTS---------------------------
Q = zeros(numberOfVariables,numberOfVariables);
R = []; 
indepInd = 1:ncstr; 

if neqcstr>0
    % call equality constraint solver
    [Q,R,A,B,CIND,X,Z,actlambda,how,...
            ACTSET,ACTIND,ACTCNT,aix,eqix,neqcstr,ncstr,remove,exitflag]= ...
        eqnsolv(A,B,eqix,neqcstr,ncstr,numberOfVariables,LLS,H,X,f,normf,normA,verbosity, ...
        aix,how,exitflag);   
    
    if ~isempty(remove)
        indepInd(remove)=[];
        normA = normA(indepInd);
    end
    
    if ACTCNT >= numberOfVariables - 1  
        simplex_iter = 1; 
    end
    [m,n]=size(ACTSET);
    
    if strcmp(how,'infeasible')
        % Equalities are inconsistent, so X and lambda have no valid values
        % Return original X and zeros for lambda.
        return
    end
    
    err = 0;
    if neqcstr > numberOfVariables
        err = max(abs(A(eqix,:)*X-B(eqix)));
        if (err > 1e-8)  % Equalities not met
            how='infeasible';
            % was exitflag = 7; 
            exitflag = -1;
            msg = sprintf(['Exiting: The equality constraints are overly stringent;\n',...
                    '         there is no feasible solution.']);
            % Equalities are inconsistent, X and lambda have no valid values
            % Return original X and zeros for lambda.
            return
        else % Check inequalities
            if (max(A*X-B) > 1e-8)
                how = 'infeasible';
                % was exitflag = 8; 
                exitflag = -1;
                msg = sprintf(['Exiting: The constraints or bounds are overly stringent;\n',...
                        '         there is no feasible solution.\n',...
                        '         Equality constraints have been met.']);
            end
        end
        if is_qp
            actlambda = -R\(Q'*(H*X+f));
        elseif LLS
            actlambda = -R\(Q'*(H'*(H*X-f)));
        else
            actlambda = -R\(Q'*f);
        end
        lambda(indepInd(eqix)) = normf * (actlambda ./normA(eqix));
        return
    end
    if isempty(Z)
        if is_qp
            actlambda = -R\(Q'*(H*X+f));
        elseif LLS
            actlambda = -R\(Q'*(H'*(H*X-f)));
        else
            actlambda = -R\(Q'*f);
        end
        lambda(indepInd(eqix)) = normf * (actlambda./normA(eqix));
        if (max(A*X-B) > 1e-8)
            how = 'infeasible';
            % was exitflag = 8; 
            exitflag = -1;
            msg = sprintf(['Exiting: The constraints or bounds are overly stringent;\n',...
                    '         there is no feasible solution.\n',...
                    '         Equality constraints have been met.']);
        end
        return
    end
    
    
    % Check whether in Phase 1 of feasibility point finding. 
    if (verbosity == -2)
        cstr = A*X-B; 
        mc=max(cstr(neqcstr+1:ncstr));
        if (mc > 0)
            X(numberOfVariables) = mc + 1;
        end
    end
else
    Z=1;
end

% Find Initial Feasible Solution
cstr = A*X-B;
mc=max(cstr(neqcstr+1:ncstr));
if mc>eps
    A2=[[A;zeros(1,numberOfVariables)],[zeros(neqcstr,1);-ones(ncstr+1-neqcstr,1)]];
    quiet = -2;
    options = struct('MaxIter',Inf);
    defaultopt = options;
    [XS,lambdaS,exitflagS,outputS] = lsqsub([],[zeros(numberOfVariables,1);1],A2,[B;1e-5], ...
        [],[],[X;mc+1],neqcstr,quiet,Qpsub,size(A2,1),numberOfVariables+1,options,defaultopt);
    X=XS(1:numberOfVariables);
    cstr=A*X-B;
    if XS(numberOfVariables+1)>eps 
        if XS(numberOfVariables+1)>1e-8 
            how='infeasible';
            % was exitflag = 4; 
            exitflag = -1;
            msg = sprintf(['Exiting: The constraints are overly stringent;\n',...
                    '         no feasible starting point found.']);
        else
            how = 'overly constrained';
            % was exitflag = 3; 
            exitflag = -1;
            msg = sprintf(['Exiting: The constraints are overly stringent;\n',...
                    ' initial feasible point found violates constraints \n',...
                    ' by more than eps.']);
        end
        lambda(indepInd) = normf * (lambdaS((1:ncstr)')./normA);
        return
    end
end

if (is_qp)
    gf=H*X+f;
    %  SD=-Z*((Z'*H*Z)\(Z'*gf));
    [SD, dirType] = compdir(Z,H,gf,numberOfVariables,f);
    
    % Check for -ve definite problems:
    %  if SD'*gf>0, is_qp = 0; SD=-SD; end
elseif (LLS)
    HXf=H*X-f;
    gf=H'*(HXf);
    HZ= H*Z;
    [mm,nn]=size(HZ);
    if mm >= nn
        %   SD =-Z*((HZ'*HZ)\(Z'*gf));
        [QHZ, RHZ] =  qr(HZ,0);
        Pd = QHZ'*HXf;
        % Now need to check which is dependent
        if min(size(RHZ))==1 % Make sure RHZ isn't a vector
            depInd = find( abs(RHZ(1,1)) < tolDep);
        else
            depInd = find( abs(diag(RHZ)) < tolDep );
        end  
    end
    if mm >= nn && isempty(depInd) % Newton step
        SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));
        dirType = NewtonStep;
    else % steepest descent direction
        SD = -Z*(Z'*gf);
        dirType = SteepDescent;
    end
else % lp
    gf = f;
    SD=-Z*Z'*gf;
    dirType = SteepDescent; 
    if norm(SD) < 1e-10 && neqcstr
        % This happens when equality constraint is perpendicular
        % to objective function f.x.
        actlambda = -R\(Q'*(gf));
        lambda(indepInd(eqix)) = normf * (actlambda ./ normA(eqix));
        return;
    end
end

oldind = 0; 

% The maximum number of iterations for a simplex type method is when ncstr >=n:
% maxiters = prod(1:ncstr)/(prod(1:numberOfVariables)*prod(1:max(1,ncstr-numberOfVariables)));

%--------------Main Routine-------------------
while iterations < maxiter && ~isequal(OPT_STOP, 1) 
    iterations = iterations + 1;
    if isinf(verbosity)
        curr_out = sprintf('Iter: %5.0f, Active: %5.0f, step: %s, proc: %s',iterations,ACTCNT,dirType,how);
        disp(curr_out); 
    end
    
    % Find distance we can move in search direction SD before a 
    % constraint is violated.
    % Gradient with respect to search direction.
    GSD=A*SD;
    
    % Note: we consider only constraints whose gradients are greater
    % than some threshold. If we considered all gradients greater than 
    % zero then it might be possible to add a constraint which would lead to
    % a singular (rank deficient) working set. The gradient (GSD) of such
    % a constraint in the direction of search would be very close to zero.
    indf = find((GSD > errnorm * norm(SD))  &  ~aix);
    
    if isempty(indf) % No constraints to hit
        STEPMIN=1e16;
        dist=[]; ind2=[]; ind=[];
    else % Find distance to the nearest constraint
        dist = abs(cstr(indf)./GSD(indf));
        [STEPMIN,ind2] =  min(dist);
        ind2 = find(dist == STEPMIN);
        % Bland's rule for anti-cycling: if there is more than one 
        % blocking constraint then add the one with the smallest index.
        ind=indf(min(ind2));
        % Non-cycling rule:
        % ind = indf(ind2(1));
    end
    %-----Update X-------------
    
    % Assume we do not delete a constraint
    delete_constr = 0;   
    
    if ~isempty(indf)&& isfinite(STEPMIN) % Hit a constraint
        if strcmp(dirType, NewtonStep)
            % Newton step and hit a constraint: LLS or is_qp
            if STEPMIN > 1  % Overstepped minimum; reset STEPMIN
                STEPMIN = 1;
                delete_constr = 1;
            end
            X = X+STEPMIN*SD;
        else
            % Not a Newton step and hit a constraint: is_qp or LLS or maybe lp
            X = X+STEPMIN*SD;          
        end              
    else %  isempty(indf) || ~isfinite(STEPMIN)
        % did not hit a constraint
        if strcmp(dirType, NewtonStep)
            % Newton step and no constraint hit: LLS or maybe is_qp
            STEPMIN = 1;   % Exact distance to the solution. Now delete constr.
            X = X + SD;
            delete_constr = 1;
        else % Not a Newton step: is_qp or lp or LLS
            if is_qp
                % Is it semi-def, neg-def or indef?
                eigoptions.disp = 0;
                ZHZ = Z'*H*Z;
                if numberOfVariables < 400 % only use EIGS on large problems
                    [VV,DD] = eig(ZHZ);
                    [smallRealEig, eigind] = min(diag(DD));
                    ev = VV(:,eigind(1));
                else
                    [ev,smallRealEig,flag] = eigs(ZHZ,1,'sr',eigoptions);
                    if flag  % Call to eigs failed
                        [VV,DD] = eig(ZHZ);
                        [smallRealEig, eigind] = min(diag(DD));
                        ev = VV(:,eigind(1));
                    end
                end
                
            else % define smallRealEig for LLS
                smallRealEig=0;
            end
            
            if (~is_qp && ~LLS) || (smallRealEig < -100*eps) % LP or neg def: not LLS
                % neg def -- unbounded
                if norm(SD) > errnorm
                    if normalize < 0
                        STEPMIN=abs((X(numberOfVariables)+1e-5)/(SD(numberOfVariables)+eps));
                    else 
                        STEPMIN = 1e16;
                    end
                    X=X+STEPMIN*SD;
                    how='unbounded'; 
                    % was exitflag = 5; 
                    exitflag = -1;
                else % norm(SD) <= errnorm
                    how = 'ill posed';
                    % was exitflag = 6; 
                    exitflag = -1;
                    
                end
                if norm(SD) > errnorm
                    msg = sprintf(['Exiting: The solution is unbounded and at infinity;\n',...
                            '         the constraints are not restrictive enough.']);
                else
                    msg = sprintf(['Exiting: The search direction is close to zero; \n',...
                            '         the problem is ill-posed.\n',...
                            '         The gradient of the objective function may be zero\n',...
                            '         or the problem may be badly conditioned.']);
                end
                return
            else % singular: solve compatible system for a solution: is_qp or LLS
                if is_qp
                    projH = Z'*H*Z; 
                    Zgf = Z'*gf;
                    projSD = pinv(projH)*(-Zgf);
                else % LLS
                    projH = HZ'*HZ; 
                    Zgf = Z'*gf;
                    projSD = pinv(projH)*(-Zgf);
                end
                
                % Check if compatible
                if norm(projH*projSD+Zgf) > 10*eps*(norm(projH) + norm(Zgf))
                    % system is incompatible --> it's a "chute": use SD from compdir
                    % unbounded in SD direction
                    if norm(SD) > errnorm
                        if normalize < 0
                            STEPMIN=abs((X(numberOfVariables)+1e-5)/(SD(numberOfVariables)+eps));
                        else 
                            STEPMIN = 1e16;
                        end
                        X=X+STEPMIN*SD;
                        how='unbounded'; 
                        % was exitflag = 5;
                        exitflag = -1;
                    else % norm(SD) <= errnorm
                        how = 'ill posed';
                        %was exitflag = 6;
                        exitflag = -1;
                    end
                    if norm(SD) > errnorm
                        msg = sprintf(['Exiting: The solution is unbounded and at infinity;\n',...
                                '         the constraints are not restrictive enough.']); 
                    else
                        msg = sprintf(['Exiting: The search direction is close to zero; \n',...
                                '         the problem is ill-posed.\n',...
                                '         The gradient of the objective function may be zero\n',...
                                '         or the problem may be badly conditioned.\n']);
                    end
                    return
                else % Convex -- move to the minimum (compatible system)
                    SD = Z*projSD;
                    dirType = 'singular';
                    % First check if constraint is violated.
                    GSD=A*SD;
                    indf = find((GSD > errnorm * norm(SD))  &  ~aix);
                    if isempty(indf) % No constraints to hit
                        STEPMIN=1;
                        delete_constr = 1;
                        dist=[]; ind2=[]; ind=[];
                    else % Find distance to the nearest constraint
                        dist = abs(cstr(indf)./GSD(indf));
                        [STEPMIN,ind2] =  min(dist);
                        ind2 = find(dist == STEPMIN);
                        % Bland's rule for anti-cycling: if there is more than one 
                        % blocking constraint then add the one with the smallest index.
                        ind=indf(min(ind2));
                    end
                    if STEPMIN > 1  % Overstepped minimum; reset STEPMIN
                        STEPMIN = 1;
                        delete_constr = 1;
                    end
                    X = X + STEPMIN*SD; 
                end
            end % if ~is_qp || smallRealEig < -eps
        end % if strcmp(dirType, NewtonStep)
    end % if ~isempty(indf)&& isfinite(STEPMIN) % Hit a constraint
    
    if delete_constr
        % Note: only reach here if a minimum in the current subspace found
        if ACTCNT>0
            if ACTCNT>=numberOfVariables-1, 
                % Avoid case when CIND is greater than ACTIND length
                if CIND <= length(ACTIND)
                    ACTSET(CIND,:)=[];
                    ACTIND(CIND)=[]; 
                end
            end
            if is_qp
                rlambda = -R\(Q'*(H*X+f));
            elseif LLS
                rlambda = -R\(Q'*(H'*(H*X-f)));
                % else: lp does not reach this point
            end
            actlambda = rlambda;
            actlambda(eqix) = abs(rlambda(eqix));
            indlam = find(actlambda < 0);
            if (~length(indlam)) 
                lambda(indepInd(ACTIND)) = normf * (rlambda./normA(ACTIND));
                return
            end
            % Remove constraint
            lind = find(ACTIND == min(ACTIND(indlam)));
            lind=lind(1);
            ACTSET(lind,:) = [];
            aix(ACTIND(lind)) = 0;
            [Q,R]=qrdelete(Q,R,lind);
            ACTIND(lind) = [];
            ACTCNT = ACTCNT - 2;
            simplex_iter = 0;
            ind = 0;
        else % ACTCNT == 0
            return
        end
        delete_constr = 0;
    end
    
    % Calculate gradient w.r.t objective at this point
    if is_qp
        gf=H*X+f;
    elseif LLS % LLS
        gf=H'*(H*X-f);
        % else gf=f still true.
    end
    
    
    % Update X and calculate constraints
    cstr = A*X-B;
    cstr(eqix) = abs(cstr(eqix));
    % Check no constraint is violated
    if normalize < 0 
        if X(numberOfVariables,1) < eps
            return;
        end
    end
    
    if max(cstr) > 1e5 * errnorm
        if max(cstr) > norm(X) * errnorm 
            if  ( exitflag == 1 )
                msg = sprintf(['Note: The problem is badly conditioned;\n',...
                        '      the solution may not be reliable.']); 
                % verbosity = 0;
            end
            how='unreliable'; 
            % exitflag = 2;
            exitflag = -1;
            if 0
                X=X-STEPMIN*SD;
                return
            end
        end
    end
    
    if ind % Hit a constraint
        aix(ind)=1;
        ACTSET(CIND,:)=A(ind,:);
        ACTIND(CIND)=ind;
        [m,n]=size(ACTSET);
        [Q,R] = qrinsert(Q,R,CIND,A(ind,:)');
    end
    if oldind 
        aix(oldind) = 0; 
    end
    if ~simplex_iter
        % Z = null(ACTSET);
        [m,n]=size(ACTSET);
        Z = Q(:,m+1:n);
        ACTCNT=ACTCNT+1;
        if ACTCNT == numberOfVariables - 1, simplex_iter = 1; end
        CIND=ACTCNT+1;
        oldind = 0; 
    else
        rlambda = -R\(Q'*gf);
        
        if isinf(rlambda(1)) && rlambda(1) < 0 
            %fprintf('         Working set is singular; results may still be reliable.\n');
            [m,n] = size(ACTSET);
            rlambda = -(ACTSET + sqrt(eps)*randn(m,n))'\gf;
        end
        actlambda = rlambda;
        actlambda(eqix)=abs(actlambda(eqix));
        indlam = find(actlambda<0);
        if length(indlam)
            if STEPMIN > errnorm
                % If there is no chance of cycling then pick the constraint 
                % which causes the biggest reduction in the cost function. 
                % i.e the constraint with the most negative Lagrangian 
                % multiplier. Since the constraints are normalized this may 
                % result in less iterations.
                [minl,CIND] = min(actlambda);
            else
                % Bland's rule for anti-cycling: if there is more than one 
                % negative Lagrangian multiplier then delete the constraint
                % with the smallest index in the active set.
                CIND = find(ACTIND == min(ACTIND(indlam)));
            end
            
            [Q,R]=qrdelete(Q,R,CIND);
            Z = Q(:,numberOfVariables);
            oldind = ACTIND(CIND);
        else
            lambda(indepInd(ACTIND))= normf * (rlambda./normA(ACTIND));
            return
        end
    end %if ACTCNT<numberOfVariables
    
    if (is_qp)
        Zgf = Z'*gf; 
        if ~isempty(Zgf) && (norm(Zgf) < 1e-15) 
            SD = zeros(numberOfVariables,1); 
        else
            [SD, dirType] = compdir(Z,H,gf,numberOfVariables,f);
        end
    elseif (LLS)
        Zgf = Z'*gf;
        HZ = H*Z;
        if (norm(Zgf) < 1e-15)
            SD = zeros(numberOfVariables,1);
        else
            HXf=H*X-f;
            gf=H'*(HXf);
            [mm,nn]=size(HZ);
            if mm >= nn
                [QHZ, RHZ] =  qr(HZ,0);
                Pd = QHZ'*HXf;
                % SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));
                % Now need to check which is dependent
                if min(size(RHZ))==1 % Make sure RHZ isn't a vector
                    depInd = find( abs(RHZ(1,1)) < tolDep);
                else
                    depInd = find( abs(diag(RHZ)) < tolDep );
                end  
            end
            if mm >= nn && isempty(depInd) % Newton step
                SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));
                dirType = NewtonStep;
            else % steepest descent direction
                SD = -Z*(Z'*gf);
                dirType = SteepDescent;
            end
        end
    else % LP
        if ~simplex_iter
            SD = -Z*(Z'*gf);
            gradsd = norm(SD);
        else
            gradsd = Z'*gf;
            if  gradsd > 0
                SD = -Z;
            else
                SD = Z;
            end
        end
        if abs(gradsd) < 1e-10  % Search direction null
            % Check whether any constraints can be deleted from active set.
            % rlambda = -ACTSET'\gf;
            if ~oldind
                rlambda = -R\(Q'*gf);
            end
            actlambda = rlambda;
            actlambda(1:neqcstr) = abs(actlambda(1:neqcstr));
            indlam = find(actlambda < errnorm);
            lambda(indepInd(ACTIND)) = normf * (rlambda./normA(ACTIND));
            if ~length(indlam)
                return
            end
            cindmax = length(indlam);
            cindcnt = 0;
            newactcnt = 0;
            while (abs(gradsd) < 1e-10) && (cindcnt < cindmax) && ~isequal(OPT_STOP, 1) 
                cindcnt = cindcnt + 1;
                if oldind
                    % Put back constraint which we deleted
                    [Q,R] = qrinsert(Q,R,CIND,A(oldind,:)');
                else
                    simplex_iter = 0;
                    if ~newactcnt
                        newactcnt = ACTCNT - 1;
                    end
                end
                CIND = indlam(cindcnt);
                oldind = ACTIND(CIND);
                
                [Q,R]=qrdelete(Q,R,CIND);
                [m,n]=size(ACTSET);
                Z = Q(:,m:n);
                
                if m ~= numberOfVariables
                    SD = -Z*Z'*gf;
                    gradsd = norm(SD);
                else
                    gradsd = Z'*gf;
                    if  gradsd > 0
                        SD = -Z;
                    else
                        SD = Z;
                    end
                end
            end
            if OPT_STOP
                error('curvefit:lsqsub:fittingCancelled', ...
                      'Fitting computation cancelled.');
            end
            if abs(gradsd) < 1e-10  % Search direction still null
                return;
            end
            lambda = zeros(ncstr,1);
            if newactcnt 
                ACTCNT = newactcnt;
            end
        end
    end
    
    if simplex_iter && oldind && ~isequal(OPT_STOP, 1) 
        % Avoid case when CIND is greater than ACTIND length
        if CIND <= length(ACTIND)
            ACTIND(CIND)=[];
            ACTSET(CIND,:)=[];
            CIND = numberOfVariables;
        end
    end 
end % while 
if OPT_STOP
    error('curvefit:lsqsub:fittingCancelled','Fitting computation cancelled.');
end
if iterations >= maxiter
    exitflag = 0;
    how = 'ill-conditioned';   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[Q,R,A,B,CIND,X,Z,actlambda,how,...
        ACTSET,ACTIND,ACTCNT,aix,eqix,neqcstr,ncstr,remove,exitflag]= ...
    eqnsolv(A,B,eqix,neqcstr,ncstr,numberOfVariables,LLS,H,X,f,normf,normA,verbosity, ...
    aix,how,exitflag)
% EQNSOLV Helper function for QPSUB.
%    Finds a feasible point with respect to the equality constraints.
%    If the equalities are dependent but not consistent, warning
%    messages are given. If the equalities are dependent but consistent, 
%    the redundant constraints are removed and the corresponding variables 
%    adjusted.

% set tolerances
tolDep = 100*numberOfVariables*eps;      
tolCons = 1e-10;

actlambda = [];
aix(eqix)=ones(neqcstr,1);
ACTSET=A(eqix,:);
ACTIND=eqix;
ACTCNT=neqcstr;
CIND=neqcstr+1;
Z=[]; Anew=[]; Bnew=[]; remove =[];

% See if the equalities form a consistent system:
%   QR factorization of A
[Qa,Ra,Ea]=qr(A(eqix,:));
% Now need to check which is dependent
if min(size(Ra))==1 % Make sure Ra isn't a vector
    depInd = find( abs(Ra(1,1)) < tolDep);
else
    depInd = find( abs(diag(Ra)) < tolDep );
end
if neqcstr > numberOfVariables
    depInd = [depInd; ((numberOfVariables+1):neqcstr)'];
end      

if ~isempty(depInd)
    msg = xlate('The equality constraints are dependent.');
    how='dependent';
    exitflag = 1;
    bdepInd =  abs(Qa(:,depInd)'*B(eqix)) >= tolDep ;
    
    if any( bdepInd ) % Not consistent
        how='infeasible';   
        exitflag = 9;exitflag = -1;
        msg = xlate('The system of equality constraints is not consistent.');
        if ncstr > neqcstr
            msg = sprintf([msg,'\nThe inequality constraints may or may not be satisfied.']);
        end
        msg = sprintf([msg,'\nThere is no feasible solution.']);
    else % the equality constraints are consistent
        numDepend = nnz(depInd);
        % delete the redundant constraints:
        % By QR factoring the transpose, we see which columns of A'
        %   (rows of A) move to the end
        [Qat,Rat,Eat]=qr(ACTSET');        
        [i,j] = find(Eat); % Eat permutes the columns of A' (rows of A)
        remove = i(depInd);
        msg = sprintf(['The system of equality constraints is consistent. Removing\n',...
                     'the following dependent constraints before continuing:\n%s'],num2str(remove));
        A(eqix(remove),:)=[];
        B(eqix(remove))=[];
        neqcstr = neqcstr - nnz(remove);
        ncstr = ncstr - nnz(remove);
        eqix = 1:neqcstr;
        aix=[ones(neqcstr,1); zeros(ncstr-neqcstr,1)];
        ACTIND = eqix;
        ACTSET=A(eqix,:);
        
        CIND = neqcstr+1;
        ACTCNT = neqcstr;
    end % consistency check
end % dependency check

if ~strcmp(how,'infeasible')
    % Find a feasible point
    if max(abs(A(eqix,:)*X-B(eqix))) > tolCons
        X = A(eqix,:)\B(eqix);  
    end
end

[Q,R]=qr(ACTSET');
Z = Q(:,neqcstr+1:numberOfVariables);

% End of eqnsolv.m




