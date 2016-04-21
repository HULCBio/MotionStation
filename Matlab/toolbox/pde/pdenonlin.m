function [u,res]=pdenonlin(b,p,e,t,c,a,f,p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7)
%PDENONLIN Solve nonlinear PDE problem.
%
%       [U,RES]=PDENONLIN(B,P,E,T,C,A,F) solves the nonlinear
%       PDE problem -div(c*grad(u))+a*u=f, on a mesh described by P, E, and T,
%       with boundary conditions given by the function name B, using damped
%       Newton iteration with the Armijo-Goldstein line search strategy.
%
%       The solution u is represented as the MATLAB column vector U.
%       See ASSEMPDE for details. RES is the 2-norm of the Newton step
%       residuals.
%
%       The geometry of the PDE problem is given by the triangle
%       data P, E, and T. See either INITMESH or PDEGEOM for details.
%
%       B describes the boundary conditions of the PDE problem. B
%       can either be a Boundary Condition Matrix or the name of Boundary
%       M-file. See PDEBOUND for details.
%
%       The optional arguments TOL and U0 signify a relative tolerance
%       parameter and an initial solution respectively.
%
%       The coefficients C, A, F of the PDE problem can be given in a
%       wide variety of ways. In the context of PDENONLIN the
%       coefficients can depend on U. The coefficients cannot depend
%       on T, the time.  See ASSEMPDE for details.
%
%       Fine tuning parameters may be sent to the solver in the form of
%       Parameter-Value pairs. It is possible to choose between computing
%       the full Jacobian, a "lumped" approximation or a fixed point
%       iteration and supply an initial guess of the solution.
%       The maximum number of iterations, the minimal damping factor of
%       the search vector, the size and norm of the residual at termination
%       can be controlled. These adjustments are made by setting one ore more
%       of the following property/value pairs:
%
%       Property     Value/{Default}                Description
%       ----------------------------------------------------------------------------
%       Jacobian    'lumped'|'full'|{'fixed'}          Jacobian approximation
%       U0             string|numeric {0}            Set initial guess
%       Tol             numeric scalar {1e-4}       Acceptable residual
%       MaxIter      numeric scalar {25}          Maximum iterations
%       MinStep     numeric scalar {1/2^16}    Minimal damping factor
%       Report       'on'|{'off'}                           Write convergence info.
%       Norm         numeric|{Inf}|'energy'         Residual norm
%
%       See also: ASSEMPDE, PDEBOUND
%
%       Diagnostics: If the Newton-iteration does not converge, the
%       error messages 'Too many iterations' or 'Stepsize too small' are
%       displayed.

%       M. Dorobantu 1-17-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/18 03:11:33 $

% Error checks
nargs = nargin;
if rem(nargs+1,2) || (nargs<7),
   error('PDE:pdenonlin:nargin', '7 compulsory arguments and optional parameters in pairs.')
end

% Default values
maxiter=25;
MinStep=2^(-16);
tol=1e-4;
u0=0;
jacobian='fixed';
usenorm='inf';
report=0;
for i=8:2:nargs,
  Param = eval(['p' int2str((i-8)/2 +1)]);
  Value = eval(['v' int2str((i-8)/2 +1)]);
  if ~ischar(Param),
    error('PDE:pdenonlin:ParamNotString', 'Parameter must be a string.')
  elseif size(Param,1)~=1,
    error('PDE:pdenonlin:ParamNumRowsOrEmpty', 'Parameter must be a non-empty single row string.')
  end
  Param = lower(Param);
  if strcmp(Param,'jacobian'),
    jacobian=Value;
    if ~ischar(jacobian)
      error('PDE:pdenonlin:JacobianNotString', 'Jacobian must be a string.')
    elseif ~strcmp(jacobian,'lumped') && ~strcmp(jacobian,'full') && ~strcmp(jacobian,'fixed')
      error('PDE:pdenonlin:JacobianInvalidString', 'Jacobian must be lumped | full | {fixed} .')
    end
  elseif strcmp(Param,'tol'),
    tol=Value;
    if ischar(tol)
      error('PDE:pdenonlin:TolString', 'tol must not be a string.')
    elseif ~all(size(tol)==[1 1])
      error('PDE:pdenonlin:TolNotScalar', 'tol must be a scalar.')
    elseif imag(tol)
      error('PDE:pdenonlin:TolComplex', 'tol must not be complex.')
    elseif tol<=0
      error('PDE:pdenonlin:TolNotPos', 'tol must be positive.')
    end
  elseif strcmp(Param,'u0'),
    u0=Value;
  elseif strcmp(Param,'maxiter'),
    maxiter=Value;
    if ischar(maxiter)
      error('PDE:pdenonlin:MaxIterString', 'MaxIter must not be a string.')
    elseif ~all(size(maxiter)==[1 1])
      error('PDE:pdenonlin:MaxIterNotScalar', 'MaxIter must be a scalar.')
    elseif imag(maxiter)
      error('PDE:pdenonlin:MaxIterComplex', 'MaxIter must not be complex.')
    elseif maxiter<=0
      error('PDE:pdenonlin:MaxIterNotPos', 'MaxIter must be positive.')
    end
  elseif strcmp(Param,'minstep'),
    MinStep=Value;
    if ischar(MinStep)
      error('PDE:pdenonlin:MinStepString', 'MinStep must not be a string.')
    elseif ~all(size(MinStep)==[1 1])
      error('PDE:pdenonlin:MinStepNotScalar', 'MinStep must be a scalar.')
    elseif imag(MinStep)
      error('PDE:pdenonlin:MinStepComplex', 'MinStep must not be complex.')
    elseif MinStep<=0
      error('PDE:pdenonlin:MinStepNotPos', 'MinStep must be positive.')
    end
  elseif strcmp(Param,'report'),
    Value=lower(Value);
    if strcmp(Value,'off'),
      report=0;
    elseif strcmp(Value,'on'),
      report=1;
    else
      error('PDE:pdenonlin:ReportInvalidString', 'report must be ''on'' or ''off''.');
    end
  elseif strcmp(Param,'norm'),
    usenorm=Value;
    if ischar(usenorm)
      usenorm=lower(usenorm);
      if ~(strcmp(usenorm,'inf') || strcmp(usenorm,'-inf') || strcmp(usenorm,'energy'))
        error('PDE:pdenonlin:InvalidNorm', 'Norm must be a scalar or a string: {inf}|-inf|energy.')
      end
    elseif (size(usenorm)~=[1 1])|(imag(usenorm)~=0)
      error('PDE:pdenonlin:InvalidNorm', 'Norm must be a scalar or a string: {inf}|-inf|energy.')
    end

  else
    error('PDE:pdenonlin:UnknownParam', ['Unknown parameter: ' Param])
  end
end

np=size(p,2);
nt=size(t,2);
ne=size(f,1);

% Find an initial guess that satisfies the BC
nu=size(u0,1);
if nu>=np && rem(nu,np)==0
  N=nu/np;
else
  N=size(f,1);
end
u=pdeuxpd(p,u0,N);
ne=N;
[cc,aa,ff]=pdetxpd(p,t,u,c,a,f);
[K,M,F,Q,G,H,R]=assempde(b,p,e,t,cc,aa,ff,u);
if ~any(any(H))
  H=sparse(0,size(H,2));
  R=sparse(0,1);
end
u=[u;H'\((F+G)-(K+M+Q)*u)];
nu=size(u,1);
if all(all(finite(u)))~=1
  error('PDE:pdenonlin:InvalidInitGuess', 'Unsuitable initial guess U0  (default: U0=0).')
end

global pdenonb pdenonp pdenone pdenont pdenonc pdenona pdenonf pdenonn
pdenonb=b;pdenonp=p;pdenone=e;pdenont=t;pdenonc=c;pdenona=a;pdenonf=f;
pdenonn=np*ne;
global  pdenonK pdenonF

r=pderesid(0,u);
K=pdenonK; % pdenonK may change after call to pderesid or numjac
if ischar(usenorm)
  if strcmp(usenorm,'energy')
    nr2=r'*K*r;
  else
    nr2=norm(r,usenorm)^2;
  end;
else
  nr2=(norm(r,usenorm)/length(r)^(1/usenorm))^2;
end
res=sqrt(nr2);
if report
  disp(['Iteration     Residual     Step size  Jacobian: ',jacobian])
  disp(sprintf('%4i%20.10f',0,res))
end


if strcmp(jacobian,'full') && (sqrt(nr2)> tol)
  [a1,a2,a3,a4,a5,a6,a7]=assempde(b,p,e,t,0,ones(ne*ne,1),0,ones(np*ne,1));
  if ~any(any(a6))
    a6=sparse(0,size(a6,2));
  end
  S=([a2 a6';a6 zeros(size(a6,1))]~=0);
  thresh=zeros(size(u));
  if all(u(1:np*ne)==0)
    thresh(1:np*ne)=sqrt(eps)*ones(ne*np,1);
  else
    thresh(1:np*ne)=sqrt(eps)*max(abs(u(1:np*ne)))*ones(ne*np,1);
  end
  if all(u(np*ne+1:nu)==0)
    thresh(np*ne+1:nu)=sqrt(eps)*ones(nu-ne*np,1);
  else
    thresh(np*ne+1:nu)=sqrt(eps)*max(abs(u(np*ne+1:nu)))*ones(nu-ne*np,1);
  end
  [dfdu0,fac,G]=numjac('pderesid',0,u,r,thresh,[],0,S,[]);
  first_time=1;
end

tmp=u;cor=zeros(size(u));iter=0;     % Gauss-Newton iteration
while sqrt(nr2)> tol
  iter=iter+1;
  if iter>maxiter,error('PDE:pdenonlin:TooManyIter', 'Too many iterations.'),end
  J=K;
  if strcmp(jacobian,'lumped')
    % Find dc/du da/du df/du
    v=full(u(1:np*ne));
    du=(max(abs(v))-min(abs(v)))/max(100,sqrt(np));
    if du==0, du=1e-5; end
    [dcc,daa,dff]=pdetxpd(p,t,du+v,c,a,f);
    [dccm,daam,dffm]=pdetxpd(p,t,v-du,c,a,f);
    dcc=(dcc-dccm)/2/du;
    daa=(daa-daam)/2/du;
    dff=(dff-dffm)/2/du;
    [J1,J3,a1]=assema(p,t,dcc,-dff,zeros(ne,1));
    [a2,J2,a3]=assema(p,t,0,daa,zeros(ne,1));
    J(1:np*ne,1:np*ne)=K(1:np*ne,1:np*ne)+spdiags((J1+J2)*v,0,np*ne,np*ne)+J3;
  elseif strcmp(jacobian,'full')
    if ~first_time
      thresh(1:np*ne)=sqrt(eps)*max(abs(u(1:np*ne)))*ones(ne*np,1);
      thresh(np*ne+1:nu)=sqrt(eps)*max(abs(u(np*ne+1:nu)))*ones(nu-ne*np,1);
      [J,fac,G]=numjac('pderesid',0,u,r,thresh,fac,0,S,G);
    else
      J=dfdu0;
    end
    first_time=0;
  end
  alfa=1;
  cor=-J\r;
  while 1
    if alfa<MinStep, error('PDE:pdenonlin:SmallStepSize', 'Stepsize too small.'), end
    tmp=u+alfa*cor;
    rr=pderesid(0,tmp);
    if ischar(usenorm)
      if strcmp(usenorm,'energy')
        nrr=rr'*K*rr;
      else
        nrr=norm(rr,usenorm)^2;
      end;
    else
      nrr=(norm(rr,usenorm)/length(rr)^(1/usenorm))^2;
    end
    if nr2-nrr < alfa/2*nr2
      alfa=alfa/2;
    else
      u=tmp;
      r=rr;
      nr2=nrr;
      K=pdenonK;
      if report
        disp(sprintf('%4i%20.10f%12.7f',iter,sqrt(nr2),alfa))
      end
      break
    end
  end
  res=[res;sqrt(nr2)];
end

u=full(u(1:pdenonn));
clear global pdenonb pdenonp pdenone pdenont pdenonc pdenona pdenonf
clear global  pdenonK pdenonF pdenonn

