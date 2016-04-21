function [k,r] = gainrloc(a,b,c,d,Zero,Pole,Gain)
%GAINRLOC Adaptively generates root locus gain for system.
%
%   [K,R] = GAINRLOC(A,B,C,D,ZEROS,POLES,GAIN) adaptively picks 
%   root locus gains to produce a smooth and accurate plot.  
%   The matrix R of closed-loop poles has length(K) columns 
%   and K is a row vector.
%
%   See also RLOCUS, SISOTOOL.

%   Author(s): A. Potvin, 12-1-93
%              P. Gahinet 97-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.32.4.1 $  $Date: 2002/11/11 22:21:55 $   

% Definitions
InfMat = Inf;

% Number of poles and zeros
np = length(Pole);
nz = length(Zero);
m = np-nz;  % relative degree = asymptote index (>=0)

% Find positive gains KMULT where locus branches intersect
kmult = rlocmult(Zero,Pole,Gain,a,b,c);

% Handle various cases
if m | Gain>0,
   % No pole escapes to infinity for finite values of k 
   % Compute asymptote angles and limit roots
   AsymptoteAngles = (2*(0:m-1)' + (Gain>=0)) * (pi/max(1,m));
   rinf= [Zero ; InfMat(ones(1,m),1)];
   
   % Determine appropriate initial interval [kStart,kEnd] in (0,inf)
   kStart = log10(initgain(Zero,Pole,Gain,[]));
   kEnd = -log10(initgain(Pole,Zero,1/Gain,AsymptoteAngles));
      
   % Generate initial vector of gains K
   if m>0,
      % Asymptotes at K=Inf
      kmax = max([kEnd,log10(2*kmult)]);   
      kmin = min(kStart,kmax-1);
   else
      % No asymptote
      kmin = kStart;   
      kmax = max(kEnd,kmin+1);
   end
   kinit = [0 logspace(kmin,kmax,10)];
   
   % Refine this initial K-grid and make sure asymptotes are reached
   [k,r] = smoothloc(a,b,c,d,kinit,Inf,kmult,rinf,Zero,Pole,Gain,AsymptoteAngles);
   
else
   % Some poles escape to Inf for 0<KSING<Inf
   % The finite poles approach the zeros of (A,B,C,0)
   ksing = -1/d;  % Gain = d
   [PoleSing,GainSing] = sisozero([0 c;b a],[],100*eps);
   if GainSing==0
      % DEN = scalar * NUM
      k = [0 1];
      r = [Pole , Pole];
      return
   end
   
   % Get asymptote number and direction info
   m = length(Pole)-length(PoleSing);
   rsing = [PoleSing ; InfMat(ones(m,1),1)]; 
   Theta = GainSing/d^2;   % roots going to Inf behave as (Theta/(k-ksing))^(1/m)
   
   % Compute locus for K in [0,ksing]
   % Parameterize K = KSING * x/(1+x) with x in (0,inf) and K(x)->KSING as x->inf
   % and compute the roots of  DEN + x * (DEN + KSING * NUM) = 0
   % RE: * A realization of (DEN + KSING * NUM)/DEN is (A,B,-C/D,0)
   %     * Watch for multiple roots near ksing. Ex: n = [-6 2 5];  d = [1 3 100];
   AsymptoteAngles = (2*(0:m-1)' + (Theta>=0)) * (pi/max(1,m));
   Gtmp = -GainSing/d;     % gain of (DEN + KSING * NUM)/DEN
   xStart = log10(initgain(PoleSing,Pole,Gtmp,[]));
   xEnd = -log10(initgain(Pole,PoleSing,1/Gtmp,AsymptoteAngles));
   xmult = 1 ./ (ksing ./ kmult(:,kmult<ksing) - 1);
   xmax = max([xEnd,log10(2*xmult)]);   
   xmin = min(xStart,xmax-1);
   xinit = [0 logspace(xmin,xmax,10)];
   
   % RE: keep x<1e-3/eps so that x/(1+x)<1 after roundoff
   [x,r] = smoothloc(a,b,-c/d,0,...
      xinit,1e-3/eps,xmult,rsing,PoleSing,Pole,Gtmp,AsymptoteAngles);
   kl = [ksing * (x(:,1:end-1) ./ (1+x(:,1:end-1))) , ksing];
   rl = r;
        
   % Compute locus for K in [ksing,Inf]
   % Parameterize K = KSING + 1/x  with x in (0,inf) and K(x)->KSING as x->inf
   % and compute the roots of  NUM + x * (DEN + KSING * NUM) = 0
   % RE: * A realization of (DEN + KSING * NUM)/NUM is (A-BC/D,B/D,-C/D,0)
   AsymptoteAngles = (2*(0:m-1)' + (Theta<0)) * (pi/max(1,m));
   Gtmp = -GainSing/d^2;
   xStart = log10(initgain(PoleSing,Zero,Gtmp,[]));
   xEnd = -log10(initgain(Zero,PoleSing,1/Gtmp,AsymptoteAngles));
   xmult = 1 ./ (kmult(:,kmult>ksing) - ksing);
   xmax = max([xEnd,log10(2*xmult)]);
   xmin = min(xStart,xmax-1);
   xinit = [0 logspace(xmin,xmax,10)];
      
   % RE: keep x<1e-3/eps/KSING so that KSING+1/x > KSING after roundoff
   [x,r] = smoothloc(a-b*c/d,b/d,-c/d,0,...
      xinit,1e-3/eps/ksing,xmult,rsing,PoleSing,Zero,Gtmp,AsymptoteAngles);
   kr = [fliplr(ksing + 1./x(:,2:end-1)) , Inf];   % excludes KSING
   rr = fliplr(r(:,1:end-1));
   
   % Put result together
   k = [kl kr];
   r = [rl matchlsq(rl(:,end),rr)];
   
end


%--------------------Internal Functions----------------------


%%%%%%%%%%%%%%%%%
%%% initgain  %%% 
%%%%%%%%%%%%%%%%%

function dk = initgain(Zero,Pole,Gain,AsymptoteAngles)
%INITGAIN  Computes small initial gain value near K=0.
%
%   DK = INITGAIN(ZEROS,POLES,GAIN,ASYMPTOTEANGLES) 
%   computes the largest perturbation DK of K=0 such that
%     * The finite roots of 
%           DEN(s) + K * NUM(s) = 0
%       are displaced by at most 10% when K varies from 0 to DK.
%     * The roots going to infinity as K->0 are all outside the
%       disk of radius 2*MAX(|ZEROS|) for K>DK.
%   ASYMPTOTEANGLES specifies the angles of the infinite branches
%   for K->0.  

nz = length(Zero);
np = length(Pole);
IsAtZero = (abs(Pole)<1e3*eps);   % 1 for poles at the origin

% Parameters
THRESH = 0.1;        % 10% deviation from nominal position 
ZRADIUS = max([1;2*abs(Zero)]);

% To estimate largest acceptable perturbation for finite roots, 
% apply perturbation of size THRESH to each pole, and evaluate  
% |DEN(S)/NUM(S)| for resulting pole values
ds = THRESH * abs(Pole) + IsAtZero * max(eps,THRESH^sum(IsAtZero));
s = Pole + ds .* exp(j*100*angle(Pole));

% To estimate largest acceptable perturbation for infinite roots,
% evaluate |DEN(S)/NUM(S)| for S = ZRADIUS * EXP(j*ASYMPTOTEANGLES) 
s = [s ; ZRADIUS * exp(j*AsymptoteAngles(:))];

% Compute DK by evaluating |DEN(S)/NUM(S)|
s = s.';
NumVals = prod(s(ones(1,nz),:)-Zero(:,ones(1,length(s))),1);
DenVals = prod(s(ones(1,np),:)-Pole(:,ones(1,length(s))),1);
dk = min(abs(DenVals./NumVals)) / abs(Gain);
dk = max(1e3*realmin,dk);  % Beware of underflow, e.g., for zpk([],.1,1,1,'inputd',40)


%%%%%%%%%%%%%%%%%
%%% smoothloc %%% 
%%%%%%%%%%%%%%%%%

function [k,r] = smoothloc(a,b,c,d,kinit,kmax,kmult,rinf,Zero,Pole,Gain,AsymptoteAngles)
%SMOOTHLOC  Generates a smooth locus given some initial gain vector KINIT
%
%  [K,R] = SMOOTHLOC(A,B,C,D,KINIT,KMAX,KMULT,RINF,Z,P,ANGLES) generates 
%  a set of gains K in [0,KMAX) and closed-loop poles R that produce a 
%  smooth locus in (0,INF).  The open-loop state-space model is (A,B,C,D).
% 
%  The other inputs include:
%    * KINIT: initial set of gain values, sorted in increasing order
%    * KMAX : maximum gain value (used for finite gain escape)
%    * KMULT: set of gain producing multiple poles
%    * RINF : limit pole values as K->Inf  
%    * ZERO,POLE,GAIN : open-loop zero/pole/gain data
%    * ANGLES: asymptote directions (in radians).

AsyTol = pi/60;   % 3 degree tolerance for asymptote tracking

% Insert gain values KMULT yielding multiple roots
km = [0.999*kmult , kmult , 1.001*kmult];
kinit = sort([kinit , km]);
kinit(:,abs(diff(kinit))==0)=[];

% Compute roots at initial gain points KINIT
rinit = genrloc(a,b,c,d,kinit,Zero,Pole);

% Initial scale parameter
% RE: Don't base it on RINIT! Large roots for K>>1 will produce rugged plot near K=0
Scale = max(max(abs(rinit(:,1:3))));   

% Pre-allocate space for K,R and initialize loop
k = zeros(1,60);
r = zeros(size(rinit,1),60);
k(1:2) = kinit(1:2);   
r(:,1) = rinit(:,1);
r(:,2) = matchlsq(r(:,1),rinit(:,2));
kinit(:,1:2) = [];  
rinit(:,1:2) = [];
i = 3;

% Main refinement loop
Done = 0;             % Termination flag
kCheck = kinit(end);  % Check if reached zeros/asymptotes when K>KCHECK

while ~Done & kinit(1)<kmax & i<200
   % Sort roots for next gain KINIT(1)
   knext = kinit(1);
   rinit(:,1) = matchlsq(r(:,i-1),rinit(:,1));
   
   % Check if next point smoothly links to last two points
   % RE: The values KMULT are skipped since multiple roots 
   %     give rise to kinks
   if any(k(i-1)==kmult) | ...
         knext<1.001*k(i-1) | ...
         issmooth(r(:,i-2),r(:,i-1),rinit(:,1),Scale),
      % Add next point to K,R and move to next point
      k(i) = knext;          kinit(1) = [];
      r(:,i) = rinit(:,1);   rinit(:,1) = [];
      Scale = max(Scale,max(abs(r(:,i))));
      
      % Check for termination
      if knext>=kCheck,
         % Close enough to limit poles RINF for K=inf ?
         rinf = matchlsq(r(:,i),rinf);
         ifin = isfinite(rinf);
         Done = issmooth(r(ifin,i-1),r(ifin,i),rinf(ifin),Scale);
         
         % Reached asymptotes for K->Inf ?
         CurDirect = mod(angle(r(~ifin,i)-r(~ifin,i-1)),2*pi);
         DirGap = abs(sort(CurDirect)-AsymptoteAngles);
         Done = Done & ~any(DirGap > AsyTol);
      end
      i = i+1;
   else
      % Replace next point by average of K(end) and KINIT(1)
      if knext>10*k(i-1),
         % RE: Requires KNEXT>0, and K(i-1)>0 since i-1>=2
         midK = sqrt(k(i-1)*knext);
      else
         midK = (k(i-1)+knext)/2;
      end
      kinit = [midK , kinit];
      rinit = [genrloc(a,b,c,d,midK,Zero,Pole) , rinit];
   end
   
   % Generate more points if KINIT=[] and ~DONE
   if isempty(kinit) & ~Done,
      lk = log10(k(i-1));
      if isinf(kmax)
         kinit = logspace(lk+0.1,lk+1.1,3);
      else
         kinit = logspace(lk+0.1,log10(kmax),3);
      end
      rinit = genrloc(a,b,c,d,kinit,Zero,Pole);
   end
   
end % while ~Done


% SISO Tool optimization: extend asymptotes for K->Inf 
% to at least 20 x SCALE
m = length(AsymptoteAngles);
if m, 
   klarge = (20 * Scale)^m / abs(Gain);
   if klarge>k(i-1)
      k(i) = klarge;
      r(:,i) = matchlsq(r(:,i-1),genrloc(a,b,c,d,k(i),Zero,Pole));
      i = i+1;
   end
end

% Add k=Inf and delete extra entries in K,R
k(i) = Inf;
r(:,i) = matchlsq(r(:,i-1),rinf);
k(:,i+1:end) = [];
r(:,i+1:end) = [];


%%%%%%%%%%%%%%%%%
%%% issmooth  %%% 
%%%%%%%%%%%%%%%%%

function boo = issmooth(v1,v2,v3,Scale)
% Check if the curves joining the three sets of roots v1,v2,v3 are smooth enough

if isempty(v1) | isempty(v2)
   % Trivial case
   boo = 1;
   
else
   % Define max. admissible angle between (V1,V2) and (V2,V3)
   MinCos = 0.985;  % cosine of 10 degrees
   
   % Geometric variables
   v12 = v2-v1;  
   v23 = v3-v2; 
   d12s = real(v12).^2 + imag(v12).^2;
   d23s = real(v23).^2 + imag(v23).^2;
   rho = (real(v12).*real(v23) + imag(v12).*imag(v23))/MinCos;
   
   % The plot at (v1,v2,v3) is considered smooth if either
   %    * The angle (v2-v1,v3-v2) is < ACOS(MINCOS)
   %    * |v3-v2| is shorter than SCALE/100  (prevents bisection to go 
   %      on forever when angle with tangent at V2 is > ACOS(MINCOS))
   boo = all( d23s < (Scale/100)^2 | (rho>=0 & rho.^2 >= d12s .* d23s) );
end


