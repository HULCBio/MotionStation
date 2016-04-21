function u1=hyperbolic(u0,ut0,tlist,b,p,e,t,c,a,f,d,rtol,atol)
%HYPERBOLIC Solve hyperbolic PDE problem.
%
%       U1=HYPERBOLIC(U0,UT0,TLIST,B,P,E,T,C,A,F,D) produces the
%       solution to the FEM formulation of the scalar PDE problem
%       d*d^2u/dt^2-div(c*grad(u))+a*u=f, on a mesh described by P, E,
%       and T, with boundary conditions given by B, and with initial
%       value U0 and initial derivative UT0.
%
%       For the scalar case, each row in the solution matrix U1 is the
%       solution at the coordinates given by the corresponding column in
%       P. Each column in U1 is the solution at the time given by the
%       corresponding item in TLIST.  For a system of dimension N
%       with NP node points, the first NP rows of U1 describe the first
%       component of u, the following NP rows of U1 describe the second
%       component of u, and so on.  Thus, the components of u are placed
%       in blocks U as N blocks of node point rows.
%
%       B describes the boundary conditions of the PDE problem.  B
%       can either be a Boundary Condition Matrix or the name of Boundary
%       M-file. See PDEBOUND for details.
%
%       The coefficients C, A, F, and D of the PDE problem can
%       be given in a wide variety of ways.  See ASSEMPDE for details.
%
%       U1=HYPERBOLIC(U0,UT0,TLIST,B,P,E,T,C,A,F,D,RTOL) and
%       U1=HYPERBOLIC(U0,UT0,TLIST,B,P,E,T,C,A,F,D,RTOL,ATOL) passes
%       absolute and relative tolerances to the ODE solver.
%
%       U1=HYPERBOLIC(U0,UT0,TLIST,K,F,B,UD,M) produces the solution to
%       the ODE problem B'*M*B*(d^2ui/dt^2)+K*ui=F, u=B*ui+ud,
%       with initial values U0 and UT0.
%
%       See also ASSEMPDE, PARABOLIC

%       A. Nordmark 8-01-94, AN 1-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.12.4.2 $  $Date: 2004/01/16 20:06:08 $


global pdehypK pdehypM pdehypF ...
       pdehypQ pdehypG pdehypH pdehypR pdehypMM ...
       pdehypB pdehypud ...
       pdehypNu pdehypOr ...
       pdehypp pdehype pdehypt ...
       pdehypb pdehypc pdehypa pdehypf pdehypd ...
       pdehypqt pdehypgt pdehypht pdehyprt ...
       pdehypct pdehypat pdehypft pdehypdt ...
       pdehyppm pdehypN pdehypts

[ttlist,itlist]=sort(tlist);
nlist=length(tlist);

pdehypqt=0;
pdehypgt=0;
pdehypht=0;
pdehyprt=0;
pdehypct=0;
pdehypat=0;
pdehypft=0;
pdehypdt=0;

gotatol=0;
gotrtol=0;

if nargin==12
  gotrtol=1;
elseif nargin==13
  gotrtol=1;
  gotatol=1;
elseif nargin==9
  rtol=a;
  gotrtol=1;
elseif nargin==10
  rtol=a;
  atol=f;
  gotrtol=1;
  gotatol=1;
end

if nargin==11 || nargin==12 || nargin==13

  time=NaN;
  [unused,MM]=assema(p,t,0,d,f,time);
  [K,M,F]=assema(p,t,c,a,f,time);
  [Q,G,H,R]=assemb(b,p,e,time);

  pdehypN=size(K,2)/size(p,2);
  nu=size(K,2);
  pdehypp=p;
  pdehype=e;
  pdehypt=t;

  if any(any(isnan(MM)))
    pdehypdt=1;
    pdehypd=d;
  else
    pdehypMM=MM;
    pdehypd=0;
  end

  if any(any(isnan(K)))
    pdehypct=1;
    pdehypc=c;
  else
    pdehypK=K;
    pdehypc=0;
  end
  if any(any(isnan(M)))
    pdehypat=1;
    pdehypa=a;
  else
    pdehypM=M;
    pdehypa=0;
  end
  if any(isnan(F))
    pdehypft=1;
    pdehypf=f;
  else
    pdehypF=F;
    pdehypf=zeros(pdehypN,1);
  end

  pdehypb=b;
  if any(any(isnan(Q)))
    pdehypqt=1;
  else
    pdehypQ=Q;
  end
  if any(isnan(G))
    pdehypgt=1;
  else
    pdehypG=G;
  end
  if any(any(isnan(H)))
    pdehypht=1;
  else
    pdehypH=H;
  end
  if any(isnan(R))
    pdehyprt=1;
  else
    pdehypR=R;
  end

  [Q,G,H,R]=assemb(b,p,e,tlist(1)); % H must be free of NaN
  [KK,FF,B,ud]=assempde(K,M,F,Q,G,H,R);
  nun=size(B,2);
  pdehyppm=colamd([speye(nun,nun) speye(nun,nun) ;KK+B'*MM*B B'*MM*B]);

  if ~pdehypht
     pdehypB=B;
    [pdehypNu,pdehypOr]=pdenullorth(H);
  end

  if ~(pdehypqt || pdehypgt || pdehypht || pdehyprt || ...
       pdehypct || pdehypat || pdehypft)
    pdehypK=[sparse(nun,nun) -speye(nun,nun); KK sparse(nun,nun)];
    pdehypK=pdehypK(:,pdehyppm);
    pdehypF=[zeros(nun,1);FF];
  end

  if ~(pdehypht || pdehyprt)
    pdehypud=ud;
  else
    pdehypts=max(tlist)-min(tlist);
  end

  clear K M F Q G H R KK FF B ud

  % Expand initial condition
  if ischar(u0) || ischar(ut0)
    x=p(1,:)';
    y=p(2,:)';
  end
  if ischar(u0)
    if pdeisfunc(u0)
      u0=feval(u0,x,y); % supposedly a function name
    else
      u0=eval(u0); % supposedly an expression of 'x' and 'y'
    end
  end
  if ischar(ut0)
    if pdeisfunc(ut0)
      ut0=feval(ut0,x,y); % supposedly a function name
    else
      ut0=eval(ut0); % supposedly an expression of 'x' and 'y'
    end
  end
  u0=u0(:);
  ut0=ut0(:);

elseif nargin==8 || nargin==9 || nargin==10
  pdehypK=b;
  pdehypF=p;
  pdehypB=e;
  pdehypud=t;
  pdehypMM=c;
  nun=size(pdehypK,2);
  pdehyppm=colamd([speye(nun,nun) speye(nun,nun); ...
    pdehypK+pdehypB'*pdehypMM*pdehypB pdehypB'*pdehypMM*pdehypB]);
  pdehypK=[sparse(nun,nun) -speye(nun,nun); pdehypK sparse(nun,nun)];
  pdehypK=pdehypK(:,pdehyppm);
  pdehypF=[zeros(nun,1);pdehypF];
  nu=size(pdehypud,1);
else
  error('PDE:hyperbolic:nargin', 'Number of input arguments must be between 8 and 13.')
end


nuu=nu;

if size(u0,1)==1,
  u0=ones(nu,1)*u0;
end
if size(ut0,1)==1,
  ut0=ones(nu,1)*ut0;
end

if ~(pdehypht || pdehyprt)
  u0=pdehypB'*u0;
  ut0=pdehypB'*ut0;
else
  t0=tlist(1);
  t1=t0+pdehypts*sqrt(eps);
  dt=t1-t0;
  [Q,G,H,R]=assemb(b,p,e,t0);
  [N,O]=pdenullorth(H);
  ud=O*((H*O)\R);
  [Q,G,H,R]=assemb(b,p,e,t1);
  [N1,O]=pdenullorth(H);
  ud1=O*((H*O)\R);
  u0=N'*u0;
  ut0=N'*(ut0-((N1-N)*u0-(ud1-ud))/dt);
end

nu=size(u0,1);

uuu0=[u0;ut0];
uu0=uuu0(pdehyppm);

options=odeset('Jacobian','on','MaxOrder',2);
if ~(pdehypct || pdehypat || pdehypqt || pdehypht)
  options=odeset(options,'JConstant','on');
end
if ~(pdehypdt || pdehypht)
  options=odeset(options,'Mass','M');
else
  options=odeset(options,'Mass','M(t)');
end
if gotrtol
  options=odeset(options,'RelTol',rtol);
end
if ~gotatol
  atol=1e-6; % From ode15s
end
% Mask out ut
atol=atol*ones(2*nu,1);
atol(nu+1:nu+nu)=Inf*ones(nu,1);
atol=atol(pdehyppm)';
options=odeset(options,'AbsTol',atol);
options=odeset(options,'Stats','on','OutputFcn','pdeoutfun');

[t,uu]=ode15s('pdehypf',ttlist,uu0,options);

u1=zeros(nu,nlist);
ix=find(pdehyppm<=nu);

if length(itlist)==2,
  % ODE15S behaves differently if length(tlist)==2
  if diff(itlist)>0,
    u1(pdehyppm(ix),:)=uu([1 size(uu,1)],ix).';
  else
    u1(pdehyppm(ix),:)=uu([size(uu,1) 1],ix).';
  end
else
  u1(pdehyppm(ix),:)=uu(itlist,ix).';
end

if pdehypht || pdehyprt
  if pdehypht
    uu1=zeros(nuu,nlist);
    for k=1:nlist
      [Q,G,H,R]=assemb(b,p,e,tlist(k));
      [null,orth]=pdenullorth(H);
      ud=full(orth*((H*orth)\R));
      uu1(:,k)=null*u1(:,k)+ud;
    end
    u1=uu1;
  else
    HH=pdehypH*pdehypOr;
    ud=zeros(nuu,nlist);
    for k=1:nlist
      [Q,G,H,R]=assemb(b,p,e,tlist(k));
      ud(:,k)=pdehypOr*(HH\R);
    end
    u1=pdehypNu*u1+ud;
  end
else
  u1=pdehypB*u1+pdehypud*ones(1,nlist);
end

