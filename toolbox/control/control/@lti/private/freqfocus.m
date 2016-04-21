function FocusInfo = freqfocus(w,h,z,p,Ts)
%FREQFOCUS  Computes frequency focus for single MIMO model.
%
%  FOCUS = FREQFOCUS(W,H,Z,P,TS) determines an adequate frequency
%  range for the MIMO response (W,H).  Z and P contain the model's 
%  zeros and poles (for each I/O pair) and TS is the sample time.
%  Time delays must be EXCLUDED from the frequency response H.
%
%  See also MRGFOCUS.

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.16 $ $Date: 2002/04/10 05:54:26 $

% Compute range for each I/O pair
nios = prod(size(z));
FRanges = cell(nios,1);
SoftRangeFlags = false(nios,1);
for ct=1:nios
   fz = damp(z{ct},Ts);
   fp = damp(p{min(ct,end)},Ts);
   [FRanges{ct,1},SoftRangeFlags(ct,1)] = LocalGetRange(fz,fp,w,h(:,ct),Ts);
end

% Merge these ranges
focus = mrgfocus(FRanges,SoftRangeFlags);

% Extend range up to asymptotes
if isempty(focus)
   focus = zeros(4,0);
else
   h = h(:,:);
   LowerLimits = LocalRefineFocus(focus(1),w,h,Ts,'low');
   UpperLimits = LocalRefineFocus(focus(2),w,h,Ts,'high');
   focus = [LowerLimits,UpperLimits];  % k-th row = focus for Grade=k
end

% Return focus info
FocusInfo = struct('Range',focus,'Soft',all(SoftRangeFlags));

%--------------- Local Functions ----------------------------

function [FRange,SoftRange] = LocalGetRange(fz,fp,w,h,Ts)
% Determines frequency range (focus) for a single response (SISO case)
%
% The range is defined as the smallest interval containing all poles 
% and zeros except for the following adjustments:
%   * Discard low-frequency pole/zero clusters C that are 3 decades away from 
%     next cluster, and such that |log10(gain)|>LFGAIN for all freq<=max(C) 
%     [eliminates parasitic poles and zeros near s=0]
%   * Discard high-frequency zero clusters C that are 3 decades away from
%     last cluster containing a pole, and such that |log10(gain)|>HFGAIN
%     for all freq>=min(C) [eliminates parasitic zeros near s=Inf]
% SOFTRANGE=1 indicates that the response either has no dynamics, or can be 
% assimilated to a pure integrator or differentiator (|log10(gain)|>LFGAIN 
% for all freq<=FRANGE(2)), in which case it may not contribute to the 
% overall range (see MRGFOCUS).

% Parameters
FGAP = 3;     % 3-decade gap (used in scheme for discarding LF dynamics and HF zeros)
LFGAIN = 3;   % Gain threshold (log scale) for identifying pseudo integrator/differentiator
HFGAIN = 4;   % Gain threshold (log scale) for discarding HF zeros
SOFTGAIN = 4; % Gain threshold for SoftFocus

% Delete poles and zeros near s=0
% RE: Also discard roots beyond MAX(W) (only active when MAX(W) = Nyquist frequency) 
fp = fp(fp>1e3*eps & fp<=w(end),:);
fz = fz(fz>1e3*eps & fz<=w(end),:);
fzp = sort([fz;fp]);
fpmax = max(fp);

% Prepare for clustering
widegap = (diff(log10(fzp))>FGAP);
fkeep = logical(ones(size(fzp)));
mag = abs(log10(max(eps,abs(h))));
mag(~isfinite(mag)) = Inf;

% Discard LF clusters (below f=1) that are
%   * well separated from next cluster
%   * have very high or very low gain toward f=0 (use 2*LFGAIN if there
%     are no poles to the right of the cluster)
fub = min([1;max(fzp)]);    % limit search to F<1
idx = find(widegap(:) & fzp(1:end-1,:)<fub);
for i=fliplr(idx')
   f = fzp(i);  % cluster's highest frequency 
   Penalty = 1 + (f>=fpmax);
   if all(mag(w<f)>Penalty*LFGAIN)
      fkeep(1:i) = 0;
      break
   end
end

% Discard HF zero clusters (above f=1) that are
%   * well separated from last cluster containing a pole
%   * have very high or very low gain toward f=Inf
flb = max([1;fpmax]);
idx = 1+find(widegap(:) & fzp(2:end,:)>flb);
for i=idx'
   f = fzp(i);  % lowest frequency of zero cluster
   if all(mag(w>f)>HFGAIN)
      fkeep(i:end) = 0;
      break
   end
end

% Build range
fzp = fzp(fkeep,:);
FRange = [min(fzp) , max(fzp)];

% Soft range indicator
if isempty(FRange) | ...
      (all(mag(w<FRange(2))>SOFTGAIN) & (Ts==0 | FRange(2)<1e-3*pi/Ts))
   % Do not set SoftFocus=1 when FRANGE near Nyquist frequency, 
   % cf. nyquist(zpk(.1, [.5 .2], 1455, 0.01))
   SoftRange = logical(1);
else
   SoftRange = logical(0);
end


%%%%%%%%%%%%%%%

function Limits = LocalRefineFocus(RangeLim,w,h,Ts,side)
% Extends focus up to beginning of the asymptotes
% Extends up to frequencies where response behaves approximately as s^n
% FOCUS = lower or upper limit
if strcmp(side(1),'l')
   % low frequency
   idx = find(w>RangeLim/100 & w<RangeLim);
   sep = find(w(idx)>2*min(w(idx)));
else
   % high frequency
   idx = flipud(find(w>RangeLim & w<RangeLim*100));
   sep = find(w(idx)<max(w(idx))/2);
end

% Abort if insufficient data (happens, e.g., when w(end) = Nyquist frequency)
if isempty(idx) | isempty(sep)
   Limits = RangeLim(ones(1,4),:);
   return
end

% Fit model H = a * W^n to first two points
idx1 = idx(1);
idx2 = idx(sep(1));
h(:,h(idx1,:)==0) = [];
n = round(real(log(h(idx1,:)./h(idx2,:))/log(w(idx1)/w(idx2))));
a = h(idx1,:) ./ w(idx1).^n;

% Find clipping point
if isempty(h)
   % Can happen, e.g., for nyquist(ss(1,1,0,0)) (all zero response)
   idxf = idx(end);
else
   % Get worst prediction error across I/O pairs for each frequency in W(IDX)
   % and set focus to last frequency where error < 5%
   emax = zeros(length(idx),1);
   for ct=1:length(idx)
      ctx = idx(ct);
      emax(ct) = max(abs(1 - h(ctx,:) ./ (a .* w(ctx).^n)));
   end
   idxf = find(emax<0.05);
   idxf = idx(max([1;idxf]));
end

% Update FOCUS
Limits = RangeLim(ones(1,4),1);
if strcmp(side(1),'l')
   Limits = min(Limits,w(idxf));
   if Ts>0
      Limits = min(Limits,pi/Ts/50);  % Don't clip too close to Nyquist freq.
   end
   % Nyquist: include w=0 if no unbounded asymptote near zero frequency
   if all(n>=0)
      Limits(1) = 0;
   end
   % Nichols: * include w=0 if no unbounded asymptote near zero frequency
   %          * add 1/2 decade on each side for Nichols (dB scale warrants longer 
   %            asymptotes) e.g., nichols(tf(1,conv([1/81 2*0.1/9 1],[1 0])))
   if all(n==0)
      Limits(2) = 0;
   else
      Limits(2) = 0.316 * Limits(2);
   end
else
   Limits = max(Limits,w(idxf));
   % Nyquist: include w=Inf if no unbounded asymptote near Inf
   if all(n<=0)
      Limits(1) = Inf;
   end
   % Nichols: * include w=Inf if no unbounded asymptote near Inf
   %          * add 1/2 decade on each side for Nichols 
   if all(n==0)
      Limits(2) = Inf;
   else
      Limits(2) = 2 * Limits(2);
   end
   % Clip at Nyquist frequency
   if Ts>0
      Limits = min(Limits,pi/Ts);
   end
end