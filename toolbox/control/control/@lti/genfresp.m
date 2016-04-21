function [mag,ph,w,FocusInfo] = genfresp(sys,Grade,w,z,p,k)
%GENFRESP   Generates frequency grid and response data for MIMO model.
%
%  [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC) computes the 
%  frequency response magnitude MAG and phase PH (in radians) of a single 
%  MIMO model SYS on some auto-generated frequency grid W.  
%
%  GRADE and FGRIDSPEC control the grid density and span as follows:
%    GRADE          1 :  Nyquist plot (finest)
%                   2 :  Nichols plot  
%                   3 :  Bode plot
%                   4 :  Sigma plot
%    FGRIDSPEC     [] :  auto-ranging
%            'decade' :  auto-ranging + grid includes 10^k points 
%         {fmin,fmax} :  user-defined range (grid spans this range)
%
%  The structure FOCUSINFO contains the preferred frequency ranges for 
%  displaying each grade of response (FOCUSINFO.Range(k,:) is the preferred
%  range for the k-th grade).
%
%  [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC,Z,P,K) also supplies 
%  the zeros, poles, and gains for each I/O pair of SYS.
%
%  See also FREQRESP, BODE, NYQUIST, NICHOLS.

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.14 $ $Date: 2002/04/10 05:52:34 $

% RE: 1) Never call with fully specified grid
%     2) Phase is unwrapped and adjusted to account for DC characteristics
%     3) MAG and PH are of size Nf-by-Ny-by-Nu

% Compute ZPK model if not supplied (also needed for DC gain call below)
if nargin<4
   [z,p,k] = zpkdata(sys);
end
if prod(size(p))>1 & isequal(p{:})
   p = p(1);
end

% Sample time, total I/O delays
Ts = abs(sys.Ts);
Td = totaldelay(sys);

% Generate frequency grid
if isempty(w) | ischar(w)
   % No frequency range/vector supplied (RE: supports w='decade')
   FRange = w;
else
   FRange = [w{:}];
end
% RE: FREQPICK adjusts FRANGE if it extends beyond Nyquist frequency
[w,FRange] = freqpick(z,p,Ts,Td,Grade,FRange);

% Remove delays to facilitate phase unwrapping and focus computation
if any(Td(:))
   sys = LocalClearDelays(sys);
end

% Compute frequency response
h = permute(freqresp(sys,w),[3 1 2]);

% Determine focus (frequency range) for each response grade
% RE: Assumes no delay when checking phase variation
if isempty(FRange)
   FocusInfo = freqfocus(w,h,z,p,Ts);
else
   FocusInfo = struct('Range',FRange(ones(4,1),:),'Soft',false);
end

% Compute magnitude and 
mag = abs(h);
ph = angle(h);
ph(~isfinite(mag)) = NaN;  % phase if NaN for infinite gain

% Phase adjustment 
if Grade<4
   % Unwrap phase
   ph = unwrap(ph,[],1);
   
   % Correct 360 phase shifts due, e.g., to multiple (quasi) integrators
   % RE: Uses Z,P,K data to estimate & match true phase at frequency near Focus(1)
   if isempty(FocusInfo.Range)
      idx = find(all(isfinite(ph(:,:)),2));
   else
      idx = find(w>0.9*FocusInfo.Range(3,1) & all(isfinite(ph(:,:)),2));
   end
   ph = LocalCorrectPhase(ph,z,p,k,Ts,w(idx(1)),ph(idx(1),:));
end

% Add delay contribution
% RE: May increase number of frequency points
if any(Td(:))
   [mag,ph,w] = LocalAddDelays(mag,ph,w,Ts,Td,Grade,FRange);
end

%---------------------- Local Functions -----------------------

function sys = LocalClearDelays(sys)
% Clear all delays
[ny,nu] = size(sys);
sys.ioDelay = zeros(ny,nu);
sys.InputDelay = zeros(nu,1);
sys.OutputDelay = zeros(ny,1);


function [mag,ph,w] = LocalAddDelays(mag,ph,w,Ts,Td,Grade,FRange)
% Adds delay contribution. For Nyquist and Nichols plots, the frequency grid is refined 
% using interpolation to track rapid phase changes (except in calls with output arguments)

% Refine grid for nyquist/nichols and FRANGE~='decade' (no output arguments)
% in order to capture rapid phase wind-up due to delays
if Grade<3 & ~ischar(FRange)
   % Parameters
   MAXPTS = 5000;   % max number of additional points
   if Grade==1  
      npts = 30;  %nyquist: add 30 point per 1/2 phase revolution for delayed I/Os
   else
      npts = 2;   %nichols: add 2 point per 1/2 phase revolution
   end
   
   % In band where |H|>0.1, superimpose fine linear grid to track rapid 
   % phase variations due to delays
   fband = find(any(mag(:,:)>0.1,2) & w>0);  % f-band where w>0 & |H|>0.1
   if ~isempty(fband),
      % Determine adequate sampling for additional linearly-spaced frequency grid
      wmin = w(fband(1));
      wmax = w(fband(end));
      wstep = pi/npts/max(Td(:));
      % Shift w=0 to avoid log(0) in nyquist (RE: wmin>=w(2) when w(1)=0)
      minpos = pow2(nextpow2(realmin));
      idxz = find(w(1)==0);
      w(idxz) = minpos;
      % Form augmented grid
      waug = unique([w ; (wmin:wstep:min(wmax,wmin+MAXPTS*wstep)).']);
      % Interpolate log(h) = log(mag) + i * phase = f(log(w)) over new grid
      % RE: Beware of log(0) for both frequency and mag
      logh = interp1(log2(w), log2(mag+minpos)+1i*ph, log2(waug));
      % REVISIT: work around g117763
      s = size(mag);
      logh = reshape(logh,[length(waug) s(2:end)]);
      % END REVISIT
      mag = pow2(real(logh))-minpos; 
      ph = imag(logh); 
      w = waug; 
      % Unshift w(1) if zero
      w(idxz) = 0;
   end
end

% Add delay contribution
D = (Ts + (~Ts)) * Td(:);
ph = ph - reshape(w * D',size(ph));


function ph = LocalCorrectPhase(ph,Zeros,Poles,Gains,Ts,w0,ph0);
% Estimates the true phase at W0 using ZPK data, and globally shifts phase 
% to best match this value at W0.  PH0 is the computed phase at W0.
% RE: The trick is to write each term (jW0-(a+jb)) as j((W0-b)+ja) and 
%     evaluate its contribution as pi/2 + angle((W0-b)+ja) (this angle 
%     varies in [pi,0] if a>0, [-pi,0] otherwise, and tends to 0 as W0->Inf
if Ts
   w0 = exp(1i*w0*Ts)/1i;  % (z0-1)/j is nearly w0*Ts for w0*Ts<<pi
end

for ct=1:prod(size(Gains))
   z = Zeros{ct};  
   p = Poles{min(ct,end)};
   g = Gains(ct);
   % RE: * Set phase(negative gain) = 180 in a roundoff-proof fashion 
   %     * Beware that gain can be complex
   if abs(imag(g))<1e3*eps*abs(g)
      phg = pi * (real(g)<0);  % 0 for g>0, pi for g<0
   else
      phg = atan2(imag(g),real(g));
   end
   % Compute true phase at w0
   ph0e = phg + (length(z)-length(p))*(pi/2) + sum(angle(w0+1i*z)) - sum(angle(w0+1i*p));
   % Apply correction
   shift = ph0e-ph0(ct);
   ph(:,ct) = ph(:,ct) + (2*pi) * round(shift/2/pi);
end