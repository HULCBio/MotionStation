function [w,FRange] = freqpick(z,p,Ts,Td,Grade,FRange)
%FREQPICK  Generate appropriate frequency grid for frequency plots
%        
%    W = FREQPICK(Z,P,TS,TD,GRADE,FRANGE) generates a grid W of 
%    frequencies given the zeros Z and poles P for each I/O pair
%    of the LTI model.  TS and TD are the sample time and total 
%    I/O delays, respectively.  GRADE specifies the grid density (see
%    FGRID for details).  FRANGE is a user-defined frequency range
%    (when nonempty, the grid W is clipped to fit this range).

%    Author(s): P. Gahinet, 5-1-96
%    Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.26.4.1 $ $Date: 2002/11/11 22:21:54 $

% RE: Expects data for a single SISO or MIMO LTI model

% Parameters
dampfact = 0.5+0.2*(Grade==1);    % threshold for selection of resonant modes
SysOrder = max(cellfun('length',p(:)));  % system order

% FRange='decade' forces w to contain 10^k points (needed for [m,p,w]=bode(sys))
DecadeFlag = ischar(FRange);
if DecadeFlag,
   FRange = [];
end

% Nyquist freq.
nf = pi./Ts(:,Ts>0);

% Override FRANGE if extends beyond Nyquist freq.
if Ts & ~isempty(FRange) & FRange(2)>nf
   FRange(2) = nf;
   FRange(1) = min(FRange(1),nf/2);
end
   
% Gather poles and zeros
zp = cat(1,z{:},p{:});
if Ts
   % Get equivalent continuous-time roots
   zp = map2s(zp,Ts);
end
hasIntegrator = any(zp==0);

% System dynamics and their frequency
% RE: Keep only one root for each complex pair (OK for complex as 
%     long as we show only positive freqs)
zp = zp(abs(zp)>1e5*eps & imag(zp)>=0,:);
fzp = abs(zp);

% Determine dynamics range [FMIN,FMAX] 
if isempty(zp)
   fmax = min([10,nf,max(FRange)]);
   fmin = fmax/100;
elseif isempty(FRange)
   fmin = min(fzp)/50;
   fmax = min([max(fzp)*50,nf]);
else
   fmin = FRange(1);
   fmax = FRange(2);
end

% Ignore zeros and poles outside of [FMIN,FMAX] or such that
%      real(s) > 0.7 * |s|       for Nyquist
%      real(s) > 0.5 * |s|       for other plots
zp = zp(fzp>=fmin/2 & fzp<=2*fmax & abs(real(zp))<dampfact*fzp,:);

% Decade metrics
fmin = log10(fmin);
fmax = log10(fmax);
lognf = log10(nf);

% Set minimum number DNPTS of points/decade
MinTotal = 40 + 20 * (Grade==1);   % min. # of points overall
MinDec = 8 + 5 * (Grade<=2);       % min. # of points per decade
dnpts = max(MinDec,ceil(MinTotal/max(1,fmax-fmin)));

% Initialize W (frequencies expressed in DECADES)
% DL = left point density function  (DL(k) = 1/|W(k)-W(k-1)|, gap in decades)
% DR = right point density function (DR(k) = 1/|W(k)-W(k+1)|)
if Ts
   % Sparse grid from FMIN to NF/2
   hnf = log10(nf/2);     % half the Nyquist frequency 
   [w,dl,dr] = LocalInitGrid(fmin,hnf,dnpts,fzp);
   % Finer grid between NF/2 and NF
   if Grade<3,
      extra = log10(linspace(nf/2,nf,20));
   else
      extra = linspace(hnf,lognf,6);
   end
   rgaps = 1./abs(extra(:,2:end)-extra(:,1:end-1));
   w = [w , extra(2:end)];
   dl = [dl , rgaps];
   dr = [dr(:,1:end-1) , rgaps , 0];
else
   % Sparse grid from FMIN to FMAX
   [w,dl,dr] = LocalInitGrid(fmin,fmax,dnpts,fzp);
end

% Refine W near resonant poles and zeros
[wnew,dlnew,drnew] = LocalResGrid(zp(:),Ts,dnpts,Grade);
w = [w , wnew];
dl = [dl , dlnew];
dr = [dr , drnew];

% Sort and discard redundant points
[w,is] = sort(w);
if Ts
   % Clip at Nyquist frequency
   idx = find(w<=lognf);  w = w(idx);  is = is(idx);
end
dl = dl(is);
dr = dr(is); 
niter = 0;
lw = length(w);
while niter<10 & lw>2,
   % Discard points s.t. max(dl(k),dr(k))<max(dr(k-1),dl(k+1))
   ikeep = find([1,max(dl(2:lw-1),dr(2:lw-1))>.99*max(dr(1:lw-2),dl(3:lw)),1]);
   if length(ikeep)==lw
      break
   else
      w = w(ikeep);   dl = dl(ikeep);  dr = dr(ikeep);  lw = length(w);
   end
   niter = niter+1;
end

% Limit number of freq. points for high-order models
NumberDecades = round(fmax-fmin);
MaxPointsPerDecade = 10 * (2 + (Grade<=2) * round(log10(1+SysOrder)));
MaxPoints = 50 + MaxPointsPerDecade * NumberDecades;
OverSampling = lw/MaxPoints;
if OverSampling>1.5,
   % Reduce density in high frequencies
   w = [w(1:MaxPoints-1) , w(MaxPoints :ceil(OverSampling):end-1) , w(end)];
end

% Make sure the Nyquist plot shows at least one phase wind-up for
% delayed models.  Cf.  sys = tf([10 1],[1 0],'iod',0.1)
if Grade==1 & any(Td(:)),
   Tdmin = min(Td(Td>0)) * (Ts + (Ts==0));  % Smallest delay
   wd = log10(min([3*pi/Tdmin , nf]));
   w = [w , wd(:,wd>w(end))];
end

% Add phase extrema
if Grade<4 & Ts==0 & prod(size(z))==1 & SysOrder<20
   w = LocalAddPhaseExtrema(w,z{1},p{1});
end

% Make sure w includes integer decades if DecadeFlag=1
if DecadeFlag
   w = sort([w , floor(fmin-0.5):min([lognf,ceil(fmax+0.5)])]);
end

% Add sparse cover toward 0 and Inf
wlow = max([-20,w(1)-12]):5:w(1)-1;
whigh = w(end)+1:5:min([20,w(end)+12,lognf]);
w = [wlow , w , whigh];

% Convert to frequencies in rad/sec 
% RE: Remove duplicates and allow for roundoff so that conversions don't reintroduce dups
w(:,find(w(2:end)-w(1:end-1)<1e3*eps)) = [];   
w = 10.^w(:);

% Clip to user-specified range if any
if ~isempty(FRange)
   gap = 1+sqrt(eps);
   w = [FRange(1) ; w(w>gap*FRange(1) & w<FRange(2)/gap) ; FRange(2)];
elseif Grade==1 & ~hasIntegrator
   % Add zero frequency for Nyquist
   w = [0;w];
end


%%%%%%%%%%%%%%%%%%%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [w,dl,dr] = LocalInitGrid(fmin,fmax,dnpts,fzp)
% Initializes grid with uniform density DNPTS (except in regions
% without any dynamics)

% Grid with uniform density DNPTS/decade
w = linspace(fmin,fmax,ceil((fmax-fmin)*dnpts));

% Reduce density in regions without dynamics
% RE: For smoothness do not leave large regions without points, cf
%       A = [-2 -1  0  0  0;1 0 0 0 0;-1 -1 -2 -1 0;0 0 1 0 0;-1 -1 -1 -1 -1];
%       B = [1 0 1 0 1]';   C = -ones(1,5);  D = 1;
%       bode(ss(A,B,C,D),{1e-6 1e2})
fzp = sort(log10(fzp));
idx = find(diff(fzp)>3.5);  % 3.5 decade gaps in pole/zero distributions
for ct=idx'
   SparseGrid = fzp(ct)+1.5:0.5:fzp(ct+1)-1.5;
   w = [w(:,w<SparseGrid(1)-0.1) , SparseGrid , w(:,w>SparseGrid(end)+0.1)];
end

% Density vectors
dl(1,1:length(w)) = dnpts;  % point density
dr = dl;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [w,dl,dr] = LocalResGrid(s,Ts,dnpts,Grade)
%RESGRID   Generates finer grid around peak frequency for resonant 
%          S-plane poles or zeros.  The grid is determined based on the 
%          response of the second-order system with poles s and conj(s).
%          RESGRID accepts a vector S of complex numbers.
%
%          DL and DR are the left and right point densities.

w0 = abs(s);                   % natural frequency 
zeta = abs(real(s))./w0;       % damping ratio (< 0.7)
zeta2 = zeta.^2;

% Compute frequency WPEAK (in DECADES) where gain peaks
if Ts==0,
   % Continuous mode
   wpeak = w0 .* sqrt(1-2*zeta2);
else
   % S-plane equivalent to discrete mode: get exact WPEAK by mapping 
   % mode back to Z-plane
   z = exp(Ts*s);
   zmag2 = z.*conj(z);
   
   % Gain peaks either at 0, pi/Ts, or phi/Ts where
   %      cos(phi) = a(1+a^2+b^2)/2/(a^2+b^2)  ,  z=a+jb
   wpeak = zeros(length(s),1);
   wpeak(:) = pi/Ts;
   h = (real(z).*(1+zmag2)./zmag2)/2; 
   idx = find(abs(h)<1);
   th_peak = acos(h(idx,:));    % phi
   z_peak = exp(1i*th_peak);  % exp(j*phi)
   filt = (abs((z_peak-z(idx,:)).*(z_peak-conj(z(idx,:)))) < ...
      abs((z(idx,:)+1).*(conj(z(idx,:))+1)));
   wpeak(idx(filt),:) = th_peak(filt,:)/Ts;
end
wpeak = log10(wpeak);

% Handle various plot types
if Grade<3,
   % Nyquist or Nichols: generate frequencies WT for which the phase 
   % is evenly spaced
   offset = pi/90;
   if Grade==1,  % Nyquist
      spacing = -pi/45;
      angles = -offset:spacing:-pi+offset;
   else          % Nichols
      spacing = -pi/60;
      angles = [-offset:spacing:-pi/6-spacing ,...
            -pi/6:2*spacing:-5*pi/6 , ...
            -5*pi/6+spacing:spacing:-pi+offset];
   end
   ct = -cot(angles);
   
   % Pre-allocate W
   w = zeros(1,length(s)*(length(ct)+1));
   dl = zeros(size(w));
   dr = zeros(size(w));
   lw = 0;
   
   % Compute frequencies W associated with ANGLES.  Ensure separation
   % between W's doesn't fall below SQRT(EPS) to avoid huge lobes and
   % choppy plots when approaching the machine resolution EPS.  In effect
   % this amounts to limiting the gain at the frequencies nearest to WPEAK
   % to that of a model with damping ZETA+SQRT(EPS).  This is exploited
   % by the axis limits setting algorithm to remove WPEAK and the choppy
   % part of the plot.
   % RE: The max. relative separation is of order |CT(1)|*ZETA
   for k=1:length(s)
      zct = zeta(k)*ct;
      pos = (zct>0);
      zctpos = max(sqrt(eps),zct(:,pos));
      zctneg = min(-sqrt(eps),zct(:,~pos));
      wt = unique([log10(w0(k) .* (sqrt(1+zctneg.^2)-zctneg)) , ...
            log10(w0(k) ./ (sqrt(1+zctpos.^2)+zctpos)) , wpeak(k)]);
      if length(wt)==1,
         wt = wpeak(k) + [-sqrt(eps) , 0 , sqrt(eps)];
      end
      lwt = length(wt);
      w(:,lw+1:lw+lwt) = wt;
      rgaps = 1./abs(wt(2:lwt)-wt(1:lwt-1));
      dl(:,lw+2:lw+lwt) = rgaps;    % left density fcn
      dr(:,lw+1:lw+lwt-1) = rgaps;  % right density fcn
      lw = lw+lwt;
   end
   
else
   % Bode or sigma
   Extent = 0.30103;  % log10(2) (set grid extent to [WPEAK/2,2*WPEAK])
   
   % Generate refined grid WT with points accumulating exponentially
   % around WPEAK.  The frequency points (in DECADES) are generated by
   %    w(k+1) = w(k) + a * exp(b*k),   w(0) = wpeak
   % where a,b are determined by the constraints:
   %    (1) the log. spacing at WPEAK is of order GAP
   %    (2) the spacing matches the default spacing of DNPTS/decade
   %        at the grid bounds WPEAK+/-EXTENT 
   delta = 1/max(1,dnpts);
   a = (0.7*delta) * sqrt(max(5e-3,zeta));  % adhoc initial spacing near WPEAK
   b = log(1+(delta-a)/Extent);
   npts = round(log(delta./a)./b);  % number of points left/right of WPEAK
   theta = a./(1-exp(b));
   
   % Pre-allocate W
   w = zeros(1,sum(2*npts+1));
   dl = zeros(size(w));
   dr = zeros(size(w));
   lw = 0;
   
   % Generate grids to the left and right of WPEAK
   for k=1:length(s)
      grid = 1-exp(b(k)*(1:npts(k)));
      wl = wpeak(k) - theta(k) * grid(end:-1:1);
      wr = wpeak(k) + theta(k) * grid;
      % Put grids together
      % If zeta<1e-8, perturb wpeak to avoid singularity (no point drawn)
      % and limit peak value to about 1e8 (cf. 100/(s^2+100))
      wt = [wl , wpeak(k)-sqrt(eps)*(zeta(k)<sqrt(eps)) , wr];
      lwt = length(wt);
      w(:,lw+1:lw+lwt) = wt;
      rgaps = 1./abs(wt(2:lwt)-wt(1:lwt-1));
      dl(:,lw+2:lw+lwt) = rgaps;    % left density fcn
      dr(:,lw+1:lw+lwt-1) = rgaps;  % right density fcn
      lw = lw+lwt;
   end        
end

% Discard zero padding
w = w(1:lw);
dl = dl(1:lw);
dr = dr(1:lw);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function w = LocalAddPhaseExtrema(w,z,p)
% Computes frequencies of phase extrema for continuous-time systems

% Get NUM and DEN 
num = poly(z);
den = poly(p);

% Normalize to avoid overflow (see tbode for example)
num = num/(1+max(abs(num)));
den = den/den(1);
% Avoid empty N2,D2 below
num = [zeros(1,length(num)==1) , num]; 
den = [zeros(1,length(den)==1) , den]; 

% Write NUM(jw) = N1(x) + jw N2(x) 
%       DEN(jw) = D1(x) + jw D2(x)  with x = w^2
altsgn = ones(1,max(length(num),length(den)));
altsgn(2:2:end) = -1;
n1 = num(end:-2:1);     n1 = fliplr(n1 .* altsgn(1:length(n1)));
n2 = num(end-1:-2:1);   n2 = fliplr(n2 .* altsgn(1:length(n2)));
d1 = den(end:-2:1);     d1 = fliplr(d1 .* altsgn(1:length(d1)));
d2 = den(end-1:-2:1);   d2 = fliplr(d2 .* altsgn(1:length(d2)));

% Extrema are solutions x>0 of 
%    [N1*N2+2x*(N2'N1-N1'N2)] * [D1^2+x*D2^2] = 
%    [D1*D2+2x*(D2'D1-D1'D2)] * [N1^2+x*N2^2]
lhs1 = psum(conv(n1,n2),2*[psum(conv(polyder(n2),n1),-conv(polyder(n1),n2)) 0]);
lhs2 = psum(conv(d1,d1),[conv(d2,d2) 0]);
rhs1 = psum(conv(d1,d2),2*[psum(conv(polyder(d2),d1),-conv(polyder(d1),d2)) 0]);
rhs2 = psum(conv(n1,n1),[conv(n2,n2) 0]);
p = psum(conv(lhs1,lhs2),-conv(rhs1,rhs2));
try % overflow protection
   x = roots(p);
catch
   x = zeros(0,1);
end

% wp = frequencies of phase extrema (in decades)
wp = log10(real(x(real(x)>0 & abs(imag(x))<10*sqrt(eps)*real(x))))/2;
if ~isempty(wp)
   w = sort([w , wp']);   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  p = psum(p1,p2)
%PSUM   Sums two polynomials
l1 = length(p1);
l2 = length(p2);
p = [zeros(1,l2-l1) p1] + [zeros(1,l1-l2) p2];

function r = map2s(r,Ts)
% Map to S plane if system is discrete
zr = (abs(r)<1e-2);  % roots near z=0
r(zr,:) = pi/Ts;     % show phase shift up to Nyquist freq. for pseudo delays
r(~zr,:) = log(r(~zr,:))/Ts;

