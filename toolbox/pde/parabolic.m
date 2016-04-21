function u1=parabolic(u0,tlist,b,p,e,t,c,a,f,d,rtol,atol)
%PARABOLIC Solve parabolic PDE problem.
%
%       U1=PARABOLIC(U0,TLIST,B,P,E,T,C,A,F,D) produces the
%       solution to the FEM formulation of the scalar PDE problem
%       d*du/dt-div(c*grad(u))+a*u=f, on a mesh described by P, E,
%       and T, with boundary conditions given by B, and with initial
%       value U0.
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
%       U1=PARABOLIC(U0,TLIST,B,P,E,T,C,A,F,D,RTOL) and
%       U1=PARABOLIC(U0,TLIST,B,P,E,T,C,A,F,D,RTOL,ATOL) passes
%       absolute and relative tolerances to the ODE solver.
%
%       U1=PARABOLIC(U0,TLIST,K,F,B,UD,M) produces the solution to
%       the ODE problem B'*M*B*(dui/dt)+K*ui=F, u=B*ui+ud,
%       with initial value U0.
%
%       See also ASSEMPDE, HYPERBOLIC

%       A. Nordmark 8-01-94, AN 1-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.11.4.2 $  $Date: 2004/01/16 20:06:36 $


global pdeprbK pdeprbM pdeprbF ...
       pdeprbQ pdeprbG pdeprbH pdeprbR pdeprbMM ...
       pdeprbB pdeprbud ...
       pdeprbNu pdeprbOr ...
       pdeprbp pdeprbe pdeprbt ...
       pdeprbb pdeprbc pdeprba pdeprbf pdeprbd ...
       pdeprbqt pdeprbgt pdeprbht pdeprbrt ...
       pdeprbct pdeprbat pdeprbft pdeprbdt ...
       pdeprbpm pdeprbN pdeprbts

[ttlist,itlist]=sort(tlist);
nlist=length(tlist);

pdeprbqt=0;
pdeprbgt=0;
pdeprbht=0;
pdeprbrt=0;
pdeprbct=0;
pdeprbat=0;
pdeprbft=0;
pdeprbdt=0;

gotatol=0;
gotrtol=0;

if nargin==11
  gotrtol=1;
elseif nargin==12
  gotrtol=1;
  gotatol=1;
elseif nargin==8;
  rtol=a;
  gotrtol=1;
elseif nargin==9
  rtol=a;
  atol=f;
  gotrtol=1;
  gotatol=1;
end

if nargin==10 || nargin==11 || nargin==12

  time=NaN;
  [unused,MM]=assema(p,t,0,d,f,time);
  [K,M,F]=assema(p,t,c,a,f,time);
  [Q,G,H,R]=assemb(b,p,e,time);

  pdeprbN=size(K,2)/size(p,2);
  nu=size(K,2);
  pdeprbp=p;
  pdeprbe=e;
  pdeprbt=t;

  if any(any(isnan(MM)))
    pdeprbdt=1;
    pdeprbd=d;
  else
    pdeprbMM=MM;
    pdeprbd=0;
  end

  if any(any(isnan(K)))
    pdeprbct=1;
    pdeprbc=c;
  else
    pdeprbK=K;
    pdeprbc=0;
  end
  if any(any(isnan(M)))
    pdeprbat=1;
    pdeprba=a;
  else
    pdeprbM=M;
    pdeprba=0;
  end
  if any(isnan(F))
    pdeprbft=1;
    pdeprbf=f;
  else
    pdeprbF=F;
    pdeprbf=zeros(pdeprbN,1);
  end

  pdeprbb=b;
  if any(any(isnan(Q)))
    pdeprbqt=1;
  else
    pdeprbQ=Q;
  end
  if any(isnan(G))
    pdeprbgt=1;
  else
    pdeprbG=G;
  end
  if any(any(isnan(H)))
    pdeprbht=1;
  else
    pdeprbH=H;
  end
  if any(isnan(R))
    pdeprbrt=1;
  else
    pdeprbR=R;
  end

  [Q,G,H,R]=assemb(b,p,e,tlist(1)); % H must be free of NaN
  [KK,FF,B,ud]=assempde(K,M,F,Q,G,H,R);
  pdeprbpm=colamd(B'*MM*B+KK);%  if ~(pdeprbdt | pdeprbht)

  if ~pdeprbht
    pdeprbB=B;
    [pdeprbNu,pdeprbOr]=pdenullorth(H);
  end

  if ~(pdeprbqt || pdeprbgt || pdeprbht || pdeprbrt || ...
       pdeprbct || pdeprbat || pdeprbft)
    pdeprbK=KK(:,pdeprbpm);
    pdeprbF=FF;
  end

  if ~(pdeprbht || pdeprbrt)
    pdeprbud=ud;
  else
    pdeprbts=max(tlist)-min(tlist);
  end

  clear K M F Q G H R KK FF B ud

  % Expand initial condition
  if ischar(u0)
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
  u0=u0(:);

elseif nargin==7 || nargin==8 || nargin==9
  pdeprbK=b;
  pdeprbF=p;
  pdeprbB=e;
  pdeprbud=t;
  pdeprbMM=c;
  pdeprbpm=colamd(pdeprbB'*pdeprbMM*pdeprbB+pdeprbK);
  pdeprbK=pdeprbK(:,pdeprbpm);
  nu=size(pdeprbud,1);
else
  error('PDE:parabolic:nargin', 'Number of input arguments must be between 7 and 12.')
end


nuu=nu;

if size(u0,1)==1,
  u0=ones(nu,1)*u0;
end

if ~pdeprbht
  u0=pdeprbB'*u0;
else
  [Q,G,H,R]=assemb(b,p,e,tlist(1));
  B=pdenullorth(H);
  u0=B'*u0;
end

nu=size(u0,1);

uu0=u0(pdeprbpm);

options=odeset('Jacobian','on');
if ~(pdeprbct || pdeprbat || pdeprbqt || pdeprbht)
  options=odeset(options,'JConstant','on');
end
if ~(pdeprbdt || pdeprbht)
  options=odeset(options,'Mass','M');
else
  options=odeset(options,'Mass','M(t)');
end
if gotrtol
  options=odeset(options,'RelTol',rtol);
end
if gotatol
  options=odeset(options,'AbsTol',atol);
end
options=odeset(options,'Stats','on','OutputFcn','pdeoutfun');

[t,uu]=ode15s('pdeprbf',ttlist,uu0,options);

u1=zeros(nu,nlist);
if length(itlist)==2,
  % ODE15S behaves differently if length(tlist)==2
  if diff(itlist)>0,
    u1(pdeprbpm,:)=uu([1 size(uu,1)],:).';
  else
    u1(pdeprbpm,:)=uu([size(uu,1) 1],:).';
  end
else
  u1(pdeprbpm,:)=uu(itlist,:).';
end

if pdeprbht || pdeprbrt
  if pdeprbht
    uu1=zeros(nuu,nlist);
    for k=1:nlist
      [Q,G,H,R]=assemb(b,p,e,tlist(k));
      [null,orth]=pdenullorth(H);
      ud=full(orth*((H*orth)\R));
      uu1(:,k)=null*u1(:,k)+ud;
    end
    u1=uu1;
  else
    HH=pdeprbH*pdeprbOr;
    ud=zeros(nuu,nlist);
    for k=1:nlist
      [Q,G,H,R]=assemb(b,p,e,tlist(k));
      ud(:,k)=pdeprbOr*(HH\R);
    end
    u1=pdeprbNu*u1+ud;
  end
else
  u1=pdeprbB*u1+pdeprbud*ones(1,nlist);
end

