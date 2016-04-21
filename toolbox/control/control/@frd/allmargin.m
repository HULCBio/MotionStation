function s = allmargin(sys)
%ALLMARGIN  All stability margins and crossover frequencies.
%
%   S = ALLMARGIN(SYS) provides detailed information about the  
%   gain, phase, and delay margins and the corresponding 
%   crossover frequencies of the SISO open-loop model SYS.
%
%   The output S is a structure with the following fields:
%     * GMFrequency: all -180 deg crossover frequencies (in rad/sec)
%     * GainMargin: corresponding gain margins (g.m. = 1/G where 
%       G is the gain at crossover)
%     * PMFrequency: all 0 dB crossover frequencies (in rad/sec)
%     * PhaseMargin: corresponding  phase margins (in degrees)
%     * DelayMargin, DMFrequency: delay margins (in seconds for
%       continuous-time systems, and multiples of the sample time for
%       discrete-time systems) and corresponding critical frequencies
%     * Stable: 1 if nominal closed loop is stable, 0 otherwise.
%
%   See also MARGIN, LTIVIEW, LTIMODELS.

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 06:18:41 $

error(nargchk(1,1,nargin))

% Get dimensions and check SYS
sizes = size(sys);
if any(sizes(1:2)~=1),
   error('Open-loop model SYS must be SISO.')
end

% Convert FRD units to rad/s (expected units for IMARGIN)
sys = chgunits(sys,'rad/s');

% Delays and sample time
Td = totaldelay(sys);
Ts = get(sys,'Ts');

% Compute frequency response (will factor delays in)
h = freqresp(sys,sys.Frequency);
mag = abs(h);
phase = (180/pi)*unwrap(atan2(imag(h),real(h)),[],3);

% Compute margins and related frequencies
s = struct('GMFrequency',cell([sizes(3:end) 1 1]),...
   'GainMargin',[],...
   'PMFrequency',[],...
   'PhaseMargin',[],...
   'DMFrequency',[],...
   'DelayMargin',[],...
   'Stable',NaN);

for k=1:prod(sizes(3:end)),
   % Compute gain and phase margins for k=th model
   [Gm,Pm,Wcg,Wcp] = imargin(mag(1,1,:,k),phase(1,1,:,k),sys.Frequency,'all');
   
   % Eliminate NaN crossings
   idxf = isfinite(Wcg);
   Wcg = Wcg(:,idxf);     Gm = Gm(:,idxf);
   idxf = isfinite(Wcp);
   Wcp = Wcp(:,idxf);     Pm = Pm(:,idxf);

   % Delay margins
   Dm = zeros(size(Pm));
   Dm(Wcp==0) = Inf;
   Dm(Wcp>0) = (pi/180) * (Pm(Wcp>0) ./ Wcp(Wcp>0));
   acausal = (Dm<-Td(min(k,end)));
   Dm(acausal) = Dm(acausal) + 2*pi./Wcp(acausal);  % enforce Dm>=-Td
   if Ts
      Dm = Dm/Ts;
   end
   
   s(k).GMFrequency = Wcg;
   s(k).GainMargin = Gm;
   s(k).PMFrequency = Wcp;
   s(k).PhaseMargin = Pm; 
   s(k).DMFrequency = Wcp;
   s(k).DelayMargin = Dm;
end
