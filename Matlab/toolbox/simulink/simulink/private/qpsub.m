function [X,lambda,how]=qpsub(H,f,A,B,vlb,vub,X,neqcstr,verbosity,caller,...
                              ncstr,nvars,negdef,normalize)
%QP Quadratic programming subproblem helper function.
%   QP handles quadratic programming and subproblems generated from NLCONST as
%   well as constrained linear least squares problems.
%
%   X=QP(H,f,A,b) solves the quadratic programming problem:
%
%            min 0.5*x'Hx + f'x   subject to:  Ax <= b
%             x

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $
%   Andy Grace 7-9-90.

msg = nargchk(12,12,nargin);
if isempty(normalize), normalize = 1; end
if isempty(verbosity), verbosity = 0; end
if isempty(neqcstr), neqcstr = 0; end

LLS = 0;
if isequal(caller, 'conls')
  LLS = 1;
  [rowH,colH]=size(H);
  nvars = colH;
end

simplex_iter = 0;
if  norm(H,'inf')==0 | ~length(H),
  is_qp=0;
else,
  is_qp=~negdef;
end
how = 'ok';

if LLS==1
  is_qp=0;
end

normf = 1;
if normalize > 0
  % Check for lp
  if ~is_qp & ~LLS
    normf = norm(f);
    f = f./normf;
  end
end

% Handle bounds as linear constraints
lenvlb=length(vlb);
if lenvlb > 0
  A=[A;-eye(lenvlb,nvars)];
  B=[B;-vlb(:)];
end
lenvub=length(vub);
if lenvub>0
  A=[A;eye(lenvub,nvars)];
  B=[B;vub(:)];
end
ncstr=ncstr+lenvlb+lenvub;

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

lambda=zeros(ncstr,1);
aix=lambda;
ACTCNT=0;
ACTSET=[];
ACTIND=0;
CIND=1;
eqix = 1:neqcstr;
%------------EQUALITY CONSTRAINTS---------------------------
Q = zeros(nvars,nvars);
R = [];
if neqcstr>0
  aix(eqix)=ones(neqcstr,1);
  ACTSET=A(eqix,:);
  ACTIND=eqix;
  ACTCNT=neqcstr;
  if ACTCNT >= nvars - 1, simplex_iter = 1; end
  CIND=neqcstr+1;
  [Q,R] = qr(ACTSET');
  if max(abs(A(eqix,:)*X-B(eqix)))>1e-10
    X = ACTSET\B(eqix);
    % X2 = Q*(R'\B(eqix)); does not work here !
  end
  %   Z=null(ACTSET);
  [m,n]=size(ACTSET);
  Z = Q(:,m+1:n);
  err = 0;
  if neqcstr > nvars
    err = max(abs(A(eqix,:)*X-B(eqix)));
    if (err > 1e-8)
      how='infeasible';
      if verbosity > -1
        warning(['The equality constraints are overly stringent -' ...
              'there is no feasible solution.'])
      end
    end
    if ~LLS
      actlambda = -R\(Q'*(H*X+f));
    else
      actlambda = -R\(Q'*(H'*(H*X-f)));
    end
    lambda(eqix) = normf * (actlambda ./normA(eqix));
    return
  end
  if ~length(Z)
    if ~LLS
      actlambda = -R\(Q'*(H*X+f));
    else
      actlambda = -R\(Q'*(H'*(H*X-f)));
    end
    lambda(eqix) = normf * (actlambda./normA(eqix));
    if (max(A*X-B) > 1e-8)
      how = 'infeasible';
      warning(['The equality constraints are overly stringent -' ...
            'there is no feasible solution.  Equality constraints have '...
            'been met.'])
    end
    return
  end
  % Check whether in Phase 1 of feasibility point finding.
  if (verbosity == -2)
    cstr = A*X-B;
    mc=max(cstr(neqcstr+1:ncstr));
    if (mc > 0)
      X(nvars) = mc + 1;
    end
  end
else
  Z=1;
end

% Find Initial Feasible Solution
cstr = A*X-B;
mc=max(cstr(neqcstr+1:ncstr));
if mc>eps
  A2=[[A;zeros(1,nvars)],[zeros(neqcstr,1);-ones(ncstr+1-neqcstr,1)]];
  [XS,lambdas] = qpsub([],[zeros(nvars,1);1],A2,[B;1e-5], ...
      [],[],[X;mc+1],neqcstr,-2,'qpsub',size(A2,1),nvars+1,0,-1);

  X=XS(1:nvars);
  cstr=A*X-B;
  if XS(nvars+1)>eps
    if XS(nvars+1)>1e-8
      how='infeasible';
      if verbosity > -1
        warning(['The constraints are overly stringent - there is no' ...
              'feasible solution.'])
      end
    else
      how = 'overly constrained';
    end
    lambda = normf * (lambdas((1:ncstr)')./normA);
    return
  end
end

if (is_qp)
  gf=H*X+f;
  SD=-Z*((Z'*H*Z)\(Z'*gf));
  % Check for -ve definite problems:
  %  if SD'*gf>0, is_qp = 0; SD=-SD; end
elseif (LLS)
  HXf=H*X-f;
  gf=H'*(HXf);
  HZ= H*Z;
  [mm,nn]=size(HZ);
  %   SD =-Z*((HZ'*HZ)\(Z'*gf));
  [QHZ, RHZ] =  qr(HZ);
  Pd = QHZ'*HXf;

  SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));

else
  gf = f;
  SD=-Z*Z'*gf;
  if norm(SD) < 1e-10 & neqcstr
    % This happens when equality constraint is perpendicular
    % to objective function f.x.
    if ~LLS
      actlambda = -R\(Q'*(H*X+f));
    else
      actlambda = -R\(Q'*(H'*(H*X-f)));
    end
    lambda(eqix) = normf * (actlambda ./ normA(eqix));
    return;
  end
end

% Sometimes the search direction goes to zero in negative
% definite problems when the initial feasible point rests on
% the top of the quadratic function. In this case we can move in
% any direction to get an improvement in the function so try
% a random direction.
if negdef
  if norm(SD) < sqrt(eps)
    SD = -Z*Z'*(rand(nvars,1) - 0.5);
  end
end
oldind = 0;

t=zeros(10,2);
tt = zeros(10,1);

% The maximum number of iterations for a simplex type method is:
% maxiters = prod(1:ncstr)/(prod(1:nvars)*prod(1:max(1,ncstr-nvars)));

%--------------Main Routine-------------------
while 1
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

  if ~length(indf)
    STEPMIN=1e16;
  else
    dist = abs(cstr(indf)./GSD(indf));
    [STEPMIN,ind2] =  min(dist);
    ind2 = find(dist == STEPMIN);
    % Bland's rule for anti-cycling: if there is more than one blocking 
    % constraint then add the one with the smallest index.
    ind=indf(min(ind2));
    % Non-cycling rule:
    % ind = indf(ind2(1));
  end
  %------------------QP-------------
  if (is_qp) | LLS
    % If STEPMIN is 1 then this is the exact distance to the solution.
    if STEPMIN>=1
      X=X+SD;
      if ACTCNT>0
        if ACTCNT>=nvars-1,
          % Avoid case when CIND is greater than ACTCNT
          if CIND <= ACTCNT
            ACTSET(CIND,:)=[];
            ACTIND(CIND)=[];
          end
        end

        if ~LLS
          rlambda = -R\(Q'*(H*X+f));
        else
          rlambda = -R\(Q'*(H'*(H*X-f)));
        end
        actlambda = rlambda;
        actlambda(eqix) = abs(rlambda(eqix));
        indlam = find(actlambda < 0);
        if (~length(indlam))
          lambda(ACTIND) = normf * (rlambda./normA(ACTIND));
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
      else
        return
      end
    else
      X=X+STEPMIN*SD;
    end
    % Calculate gradient w.r.t objective at this point
    if is_qp
      gf=H*X+f;
    else % LLS
      gf=H'*(H*X-f);
    end

  else
    % Unbounded Solution
    if ~length(indf) | ~isfinite(STEPMIN)
      if norm(SD) > errnorm
        if normalize < 0
          STEPMIN=abs((X(nvars)+1e-5)/(SD(nvars)+eps));
        else
          STEPMIN = 1e16;
        end
        X=X+STEPMIN*SD;
        how='unbounded';
      else
        how = 'ill posed';
      end
      if verbosity > -1
        if norm(SD) > errnorm
          warning(['The solution is unbounded and at infinity - the '...
                'constraints are not restrictive enough.'])
        else
          warning(['The search direction is close to zero - the problem is '...
              'ill posed.  The gradient of the objective function may be '...
              'zero or the problem may be badly conditioned.'])
        end
      end
      return
    else
      X=X+STEPMIN*SD;
    end
  end %if (qp)

  % Update X and calculate constraints
  cstr = A*X-B;
  cstr(eqix) = abs(cstr(eqix));
  % Check no constraint is violated
  if normalize < 0
    if X(nvars,1) < eps
      return;
    end
  end

  if max(cstr) > 1e5 * errnorm
    if max(cstr) > norm(X) * errnorm
      if verbosity > -1
        warning(['The problem is badly conditioned - the solution is not '...
              'reliable'])
        verbosity = -1;
      end
      how='unreliable';
      if 0
        X=X-STEPMIN*SD;
        return
      end
    end
  end


  % Sometimes the search direction goes to zero in negative
  % definite problems when the current point rests on
  % the top of the quadratic function. In this case we can move in
  % any direction to get an improvement in the function so
  % foil search direction by giving a random gradient.
  if negdef
    if norm(gf) < sqrt(eps)
      gf = randn(nvars,1);
    end
  end
  if ind
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
    if ACTCNT == nvars - 1, simplex_iter = 1; end
    CIND=ACTCNT+1;
    oldind = 0;
  else
    rlambda = -R\(Q'*gf);

    if isinf(rlambda(1)) & rlambda(1) < 0
      fprintf('    Working set is singular; results may still be reliable.\n');
      [m,n] = size(ACTSET);
      rlambda = -(ACTSET + sqrt(eps)*randn(m,n))'\gf;
    end
    actlambda = rlambda;
    actlambda(eqix)=abs(actlambda(eqix));
    indlam = find(actlambda<0);
    if length(indlam)
      if STEPMIN > errnorm
        % If there is no chance of cycling then pick the constraint which causes
        % the biggest reduction in the cost function. i.e the constraint with
        % the most negative Lagrangian multiplier. Since the constraints
        % are normalized this may result in less iterations.
        [minl,CIND] = min(actlambda);
      else
        % Bland's rule for anti-cycling: if there is more than one
        % negative Lagrangian multiplier then delete the constraint
        % with the smallest index in the active set.
        CIND = find(ACTIND == min(ACTIND(indlam)));
      end

      [Q,R]=qrdelete(Q,R,CIND);
      Z = Q(:,nvars);
      oldind = ACTIND(CIND);
    else
      lambda(ACTIND)= normf * (rlambda./normA(ACTIND));
      return
    end
  end %if ACTCNT<nvars
  if (is_qp)
    Zgf = Z'*gf;
    if (norm(Zgf) < 1e-15)
      SD = zeros(nvars,1);
    elseif ~length(Zgf)
      % Only happens in -ve semi-definite problems
      warning('QP problem is -ve semi-definite.')
      SD = zeros(nvars,1);
    else
      SD=-Z*((Z'*H*Z)\(Zgf));
    end
    % Check for -ve definite problems
    % if SD'*gf>0, is_qp = 0; SD=-SD; end
  elseif (LLS)
    Zgf = Z'*gf;
    if (norm(Zgf) < 1e-15)
      SD = zeros(nvars,1);
    elseif ~length(Zgf)
      % Only happens in -ve semi-definite problems
      warning('QP problem is -ve semi-definite.')
      SD = zeros(nvars,1);
    else
      %           HZ= H*Z;
      %           SD=-Z*((HZ'*HZ)\(Zgf));
      HXf=H*X-f;
      gf=H'*(HXf);
      HZ= H*Z;
      [mm,nn]=size(HZ);

      [QHZ, RHZ] =  qr(HZ);
      Pd = QHZ'*HXf;

      SD = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));

    end
  else % LP
    if ~simplex_iter
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
    if abs(gradsd) < 1e-10  % Search direction null
      % Check whether any constraints can be deleted from active set.
      % rlambda = -ACTSET'\gf;
      if ~oldind
        rlambda = -R\(Q'*gf);
      end
      actlambda = rlambda;
      actlambda(1:neqcstr) = abs(actlambda(1:neqcstr));
      indlam = find(actlambda < errnorm);
      lambda(ACTIND) = normf * (rlambda./normA(ACTIND));
      if ~length(indlam)
        return
      end
      cindmax = length(indlam);
      cindcnt = 0;
      newactcnt = 0;
      while (abs(gradsd) < 1e-10) & (cindcnt < cindmax)

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

        if m ~= nvars
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
      if abs(gradsd) < 1e-10  % Search direction still null
        return;
      end
      lambda = zeros(ncstr,1);
      if newactcnt
        ACTCNT = newactcnt;
      end
    end
  end

  if simplex_iter & oldind
    % Avoid case when CIND is greater than ACTCNT
    if CIND <= ACTCNT
      ACTIND(CIND)=[];
      ACTSET(CIND,:)=[];
      CIND = nvars;
    end
  end
end % while 1
