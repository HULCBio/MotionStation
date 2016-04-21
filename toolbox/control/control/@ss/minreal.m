function [varargout] = minreal(sys,tol,dispflag)
%MINREAL  Minimal realization and pole-zero cancellation.
%
%   MSYS = MINREAL(SYS) produces, for a given LTI model SYS, an
%   equivalent model MSYS where all cancelling pole/zero pairs
%   or non minimal state dynamics are eliminated.  For state-space 
%   models, MINREAL produces a minimal realization MSYS of SYS where 
%   all uncontrollable or unobservable modes have been removed.
%
%   MSYS = MINREAL(SYS,TOL) further specifies the tolerance TOL
%   used for pole-zero cancellation or state dynamics elimination. 
%   The default value is TOL=SQRT(EPS) and increasing this tolerance
%   forces additional cancellations.
%
%   For a state-space model SYS=SS(A,B,C,D),
%      [MSYS,U] = MINREAL(SYS)
%   also returns an orthogonal matrix U such that (U*A*U',U*B,C*U') 
%   is a Kalman decomposition of (A,B,C). 
%
%   See also SMINREAL, BALREAL, MODRED.

%   J.N. Little 7-17-86
%   Revised A.C.W.Grace 12-1-89
%   Rewritten P. Gahinet 4-20-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.32 $  $Date: 2002/06/11 17:27:28 $

% Note: no balancing since nearness to non-minimal is not
% invariant under ill-conditioned transf.
% Take for instance A = [1 100;1e-14 1], B = [1;0], C=[1 1]

ni = nargin;
no = nargout;
error(nargchk(1,3,ni))
sizes = size(sys.d);
Nx0 = size(sys,'order');

if length(sizes)>2 & no==2,
   error('Syntax [MSYS,U]=MINREAL(SYS) is not available for arrays of state-space models.')
elseif ni<2 | isempty(tol),
   tol = sqrt(eps);
elseif ~isa(tol,'double')
   error('Tolerance TOL must be real valued.')
end

% Loop over each model
randstate = randn('state');
randn('state',0);
lwarn = lastwarn;warn = warning('off');
try
    if length(sizes)==2,
        [varargout{1:max(1,no)}] = SingleMinReal(sys,tol);
        sys = varargout{1};
    else
        for k=1:prod(sizes(3:end)),
            subs = substruct('()',{':' ':' k});
            sys = subsasgn(sys,subs,SingleMinReal(subsref(sys,subs),tol));
        end
    end
    warning(warn);lastwarn(lwarn);
catch 
    warning(warn);lastwarn(lwarn);
    rethrow(lasterror)
end
randn('state',randstate)

% Postprocessing when order has been reduced
Nx = size(sys,'order');
if any(Nx(:)<Nx0(:)),
   % Blow away state names
   sys.StateName(:) = {''};
   % Display warnings or order reduction info
   if length(sizes)>2,
      warning('Using different change of state coordinates for each model.')
   elseif ni<3 | dispflag,
      % Display order reduction
      Nrm = Nx0-Nx;
      if Nrm==1,
         xchar = 'state';
      else
         xchar = 'states';
      end
      disp(sprintf('%d %s removed.',Nrm,xchar))
   end
end

varargout{1} = sys;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sysr,u] = SingleMinReal(sys,tol)
% Minimal realization for single model

if ~isreal(sys)
    error('MINREAL is not supported for state-space models with complex data.')
end

% Remove structurally non-minimal states
nx = size(sys,'order');
[sys,xsm] = sminreal(sys);
xnsm = (1:nx)';
xnsm(xsm) = [];

% Extract data
[a,b,c,d,e,Ts] = dssdata(sys);
[ny,nu] = size(d);

% Unobservable poles are invariant under feedback.  Initialize 
% search for non minimal modes by computing vector FIXEDPOLES 
% of poles common to (A,E) and (A+B*K*C,E)
roundoff = norm(a,1)*eps;
Poles = mroots(eig(a,e),'roots',tol,roundoff);
K = (max([1;abs(Poles)])/(1+norm(b,1)+norm(c,1))) * randn(nu,ny); 
FixedPoles = FindCommonPoles(Poles,eig(a+b*K*c,e),1e-1);
FixedPoles = sort(FixedPoles(imag(FixedPoles)>=0));

% REVISIT: won't work with E matrix until ghess available
if ~isequal(e,eye(size(a))),
   a = e\a;  b = e\b;  e = eye(size(a));
end

% Eliminate the uncontrollable modes
[ac,bc,cc,ec,uc,FixedPoles] = minobs(a',c',b',d',e',Ts,FixedPoles,tol);

% Eliminate the unobservable modes
[am,bm,cm,em,uo] = minobs(ac',cc',bc',d,ec',Ts,FixedPoles,tol);

% Form reduced model
if size(am,1)<size(a,1),
   sysr = ss(am,bm,cm,d,sys);
else
   sysr = sys;
end

% Compute similarity transformation u
if nargout>1,
   % Permutation for MINSTRUCT reduction
   u = eye(nx);
   u = u([xsm ; xnsm],:);
   % Product Uc*Uo
   nc = size(ac,1);
   uc(:,1:nc) = uc(:,1:nc) * uo;
   % Product (Uc*Uo)'* U
   nsm = length(xsm);
   u(1:nsm,:) = uc' * u(1:nsm,:);
end
   

%%%%%%%%%%%% SUBFUNCTION: MINOBS  %%%%%%%%%%%%%%%

function [a,b,c,e,u,ObsFixedPoles] = minobs(a,b,c,d,e,Ts,FixedPoles,tol)
%MINOBS  Removes unobservable modes
%
%  [Ao,Bo,Co,Eo,U] = MINOBS(A,B,C,D,E,Ts,FIXEDPOLES,TOL)  computes 
%  an orthogonal similarity U such that
%
%                    [ Ao-sEo   0  ]             [ Bo ]
%     U' (A-sE) U  = [   *      *  ]      U' B = [  * ]
%
%             C U  = [ Co , 0]
%
%  The vector FIXEDPOLES contains the poles invariant under feedback.

% Dimensions
[ny,nx] = size(c);
nu = size(b,2);
magb = norm(b,1);
magc = norm(c,1);

% Initialization
PoleList = [];
ObsFixedPoles = [];
u = eye(nx);

% Quick exit if B=0 or C=0
if magb==0 | magc==0,
   a = [];  e = [];  b = zeros(0,nu);  c = zeros(ny,0);
   return
end
   
% Main loop: iterative model reduction algorithm
while ~isempty(PoleList) | ~isempty(FixedPoles),
   
   % Initialize new reduction cycle if POLELIST=[]
   if isempty(PoleList),
      PoleList = FixedPoles;
      np = length(PoleList);
      FixedPoles = zeros(0,1);
      % Hessenberg reduction to speed up inverse power iterations
      [Ph,ah] = hess(a);  
      bh = Ph' * b;
      ch = c  * Ph;
      % Carry PBH test for poles in POLELIST
      is2 = zeros(np,1);
      PBHDir = zeros(size(a,1),np);
      for ct=1:np
         [is2(ct),PBHDir(:,ct)] = PBHTest(PoleList(ct),ah,ch);
      end
      % Sort poles from most to least unobservable (according to PBH criterion)
      % to make sure that minimal poles don't get eliminated in place of nearby
      % nonminimal ones.
      [junk,idxs] = sort(-is2);  % sqrt(1/IS2) = min svd([C;A-pI])
      PoleList = PoleList(idxs);
      PBHDir = PBHDir(:,idxs);
      PBHPass = (is2(idxs) * (tol^2) >= 1);  % 1 if min svd([C;A-pI]) << 1
      % Other variables
      Wred = [];  % orthogonal similarity for obs./unobs. decomposition
      R = [];
      Ncancel = 0;
   end
   
   % Process first pole: determine whether it is unobservable and can 
   % be cancelled
   p = PoleList(1);
   [Pcancel,Wred,R] = CheckObs(p,PBHDir(:,1),PBHPass(1),Wred,R,ah,bh,ch,d,Ts,tol);
   switch Pcancel,
   case 0,
      % P is observable: delete it
      ip = find(PoleList==p);
      ObsFixedPoles = [ObsFixedPoles ; PoleList(ip)];
      PoleList(ip) = [];   PBHDir(:,ip) = [];   PBHPass(ip) = [];
   case -1,
      % P can be cancelled, but corresponding unobs. direction does
      % not contribute to Wno (Multiple pole/Jordan block case).  
      % Move remaining copies of P to FIXEDPOLES for further processing
      % in next reduction cycle
      ip = find(PoleList==p);
      FixedPoles = [FixedPoles ; PoleList(ip)];
      PoleList(ip) = [];   PBHDir(:,ip) = [];   PBHPass(ip) = [];
   case 1/2
      % (P,CONJ(P)) close to a pair of real roots in a Jordan block
      % Cancel one copy and keep REAL(P) for processing in next cycle
      PoleList(1) = [];   PBHDir(:,1) = [];   PBHPass(1) = [];
      FixedPoles = [FixedPoles ; real(p)];
      Ncancel = Ncancel + 1;
   otherwise
      % P can be cancelled: delete one copy
      PoleList(1) = [];   PBHDir(:,1) = [];   PBHPass(1) = [];
      Ncancel = Ncancel + Pcancel;
   end
   
   % If cycle completed, delete unoservable subspace generated 
   % during this cycle
   if isempty(PoleList) & Ncancel,
      Wred = Ph * Wred;
      % Wo = orth. complement of unobs. subspace
      Wo = Wred(:,Ncancel+1:end); 
      % Update overall orthogonal similarity U
      u(:,1:nx) = u(:,1:nx) * Wred(:,[Ncancel+1:nx,1:Ncancel]);
      b = Wo' * b;  
      c = c * Wo;  
       
      if norm(b,1)<1e3*eps*magb | norm(c,1)<1e3*eps*magc,
         % B=0 or C=0 after reduction
         a = [];   e = [];  
         b = zeros(0,nu);  
         c = zeros(ny,0);
         ObsFixedPoles = [];
         FixedPoles = [];  % force termination
      else
         a = Wo' * a * Wo;  
         e = Wo' * e * Wo;  
         nx = size(a,1);  
      end
   end     
   
end % while 
      

%%%%%%%% SUBFUNCTION PBHTEST %%%%%%%%%%%%%%

function [is2,v] = PBHTest(p,a,c)
% Estimates 1/smin^2 where smin := min(svd([C;A-pI])) as well as the 
% associated normalized right singular vector V.

% Norms and sizes
maga = 1+norm(a,1);
magc = norm(c,1);  % Note: can't be zero at this point
nx = size(a,1);

% Compute triangular matrix T for inverse power iterations
% Note: Putting slightly more weight on |(A-pI)*v|<<1 reduces
%       the norm of Wo'*A*Wno
[junk,T] = qr([1e-2*c/magc ; (a-p*eye(nx))/maga],0);
idiag = 1+(0:nx+1:(nx+1)*(nx-1));   
T(idiag(~T(idiag))) = eps;  % to avoid divide by zero

% Inverse power iterations to estimate min svd([C;A-pI])
% REVISIT: refine this test (risk when ||A||/rho(A)>>1 that all SV except 
% s(1) are below TOL??
v = randn(nx,1);
v = T\(T'\v);
v = v/norm(v);
v = T\(T'\v);  
is2 = norm(v);  % sqrt(1/is2) estimates min svd([C;A-pE])
v = v/is2;


%%%%%%%% SUBFUNCTION CHECKOBS %%%%%%%%%%%%%%

function [Pcancel,W,R] = CheckObs(p,v,RankDef,W,R,ah,bh,ch,d,Ts,tol)

% Tolerances
tolsub = 1e-3;       % for growing unobservable subspace
tolerr = min(0.1,1e3*tol);  % acceptable rel. error on freq. response
tolround = 1e4*eps;  % relative round-off level
nx = size(ah,1);

% If [C;A-pI] is nearly rank-deficient, compute the error in the
% freq. response at w=|p| incurred by cancelling p
if RankDef,
    s = LocalTestFrequency(ah,p,Ts);  % guard against p=0 or p = 10j...
    % Response at s=jw or exp(jwTs) is D+Ch*(sI-Ah)\Bh
    Ab = (s*eye(nx)-ah)\bh;
    FrespMag = abs(d+ch*Ab);                     
    % Estimate error FRESPGAP when cancelling:
    % FrespGap = (Ch*(sI-Ah)\V) * (V'*Ab) / (V'*(sI-Ah)\V)
    Av = (s*eye(nx)-ah)\v;
    FrespGap = abs((ch*Av)*(v'*Ab)/(v'*Av));
    % Check if gap acceptable
    RoundOffLevel = tolround*max(abs(ch)*abs(Ab),max(FrespMag(:)));
    OKgap = (FrespGap < max(RoundOffLevel,tolerr*FrespMag));
end

% Set PCANCEL and update unobs. subspace data (W,R)
if ~RankDef | any(OKgap(:)==0),
   Pcancel = 0;
else
   % Cancellable real pole or pair of complex poles
   if norm(real(v))<norm(imag(v)),
      v = j*v;
   end
   vr = real(v);   
   vi = imag(v);
   
   % Add VR to unobservable subspace
   [NewDir,Wup,Rup] = qrup(W,R,vr/norm(vr),tolsub);
   nc = size(Rup,2);
   if ~NewDir,
      % VR nearly parallel to current subspace 
      Pcancel = -1;
   elseif isreal(p),
      % Cancel real pole
      Pcancel = 1;  W = Wup;  R = Rup;
   elseif vi'*vi-(vi'*vr)^2/(vr'*vr)<tolsub^2,
      % Complex pole with (vr,vi) nearly collinear
      % (P,CONJ(P)) close to double real pole in Jordan block
      Pcancel = 1/2;  W = Wup;  R = Rup;
   else
      % Add VI to unobservable subspace
      [NewDir,Wup,Rup] = qrup(Wup,Rup,vi/norm(vi),tolsub);   
      nc = size(Rup,2);
      if NewDir,
         % Cancel pair of complex poles
         Pcancel = 2;  W = Wup;  R = Rup;
      else
         Pcancel = -1;
      end
   end
end

%%%%%%% SUBFUNCTION FINDCOMMONPOLES  %%%%%%%%%%%%%%%

function [NewDir,Q,R] = qrup(Q,R,x,tol)
%QRUP  Update QR factorization when adding a column X
%      to the original matrix. Q,R are the QR factors 
%      and iR keeps track of the inverse of R.
NewDir = 1; % 1 if x contributes a new direction to unobs. subspace

% Quick exit for initial step
if isempty(R),
   [Q,R] = qr(x);
   R = R(1,1);
   return
end

%  Q' [U,x] = [R x1;0 x2]
ncr = size(R,2);
lx = size(Q,2);
x = Q'*x;
x1 = x(1:ncr);
x2 = x(ncr+1:lx);

% Compute Householder reflection H = I-t*h*h'  s.t. H*x2 = -s*e1
s = norm(x2) * (sign(x2(1)) + (x2(1)==0));  % Modification for sign(0)=1.
h = x2;
if abs(s)<tol*min(1,norm(R\x1)),
   % x is in range(Q(:,1:nc)) and should be discarded
   % Note inv(R) -> [inv(R) (R\x1)/s ; 0 -1/s] so growth in ||inv(R)||
   % essentially determined by (1+norm(R\x1))/s
   NewDir = 0;
else
   h(1) = h(1) + s;
   t = 1/(s'*h(1));
   R = [R x1 ; zeros(1,ncr) -s];
   Q(:,ncr+1:lx) = Q(:,ncr+1:lx) - t * (Q(:,ncr+1:lx) * h) * h';
end



%%%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%

function r = FindCommonPoles(r1,r2,tolsep)
% Note: r2 should be the smallest set of the two.

lr1 = length(r1);
lr2 = length(r2);
rep1 = r1(:,ones(1,lr2));
rep2 = r2(:,ones(1,lr1));
sepmat = abs(rep1-rep2.')./(1+min(abs(rep1),abs(rep2)'));
[mingap,minrow] = min(sepmat,[],1);
r = r1(minrow(mingap<tolsep),:);


function s = LocalTestFrequency(a,p,Ts)
% Finds test frequency away from singularity
magp = abs(p);
if Ts
   % Discrete time
   s = exp(1i*min(abs(log(p+eps*(magp==0))),pi));
   dth = pi/1000;
   if abs(1-magp)<0.01
      % p is near unit circle axis --> a-s*I is ill conditioned
      % Move test frequency away from singularity
      while rcond(a-s*eye(size(a))) < 1e3*eps
         s = s * exp(1i*dth);
         dth = dth * 10;
      end
   end
else
   % Continuous time
   s = 1.001i * magp;
   ar = abs(real(p));
   if ar < 0.01*(1+magp)
      % p is near imaginary axis --> a-s*I is ill conditioned (happens for multiple roots)
      % Move test frequency away from singularity
      while rcond(a-s*eye(size(a))) < 1e3*eps
         ar = max(1e-3,10*ar);
         s = s + 1i*ar;
      end
   end
end



