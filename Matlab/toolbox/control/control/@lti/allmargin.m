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
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.25.4.2 $  $Date: 2004/04/10 23:13:13 $

error(nargchk(1,1,nargin))

% Get dimensions and check SYS
sizes = size(sys);
if any(sizes(1:2)~=1),
    error('Open-loop model SYS must be SISO.')
end

% Compute margins and related frequencies
s = struct('GMFrequency',cell([sizes(3:end) 1 1]),...
    'GainMargin',[],...
    'PMFrequency',[],...
    'PhaseMargin',[],...
    'DMFrequency',[],...   
    'DelayMargin',[],...
    'Stable',[]);
try
    for k=1:prod(sizes(3:end)),
        s(k) = LocalGetMargins(s(k),sys(:,:,k));
    end
catch
    rethrow(lasterror)
end

%------------------- Local functions ---------------------------

%%%%%%%%%%%%%%%%%%%
% LocalGetMargins %
%%%%%%%%%%%%%%%%%%%
function s = LocalGetMargins(s,sys)

% Tolerance parameters
rtol = 1e-3;  % relative accuracy on computed crossings/margins

% Only supported for real systems
if ~isreal(sys)
    error('Not supported for models with complex data.')
end

% Get model's ZPK data
zsys = zpk(sys);
[z,p,k,Ts] = zpkdata(zsys,'v');
Ts = abs(Ts);
Td = totaldelay(zsys);
if Ts,
    Td = Td*Ts;
    % g198224: watch for roundoff errors near z=1
    p(abs(p-1)<1e3*eps) = 1;
    z(abs(z-1)<1e3*eps) = 1;
end

% Quick exit if k=0
if k==0
    s.GainMargin = zeros(1,0);    s.GMFrequency = zeros(1,0);
    s.PhaseMargin = zeros(1,0);   s.PMFrequency = zeros(1,0);
    s.DelayMargin = zeros(1,0);   s.DMFrequency = zeros(1,0);
    s.Stable = true;
    return
end

% Protect against warnings in FREQRESP
lwarn = lastwarn;warn = warning('off');

% Carry out pole/zero cancellations (for better convergence)
%   * 0dB crossings: cancel allpass pole/zero pairs
%   * -180 crossings: cancel matching pole/zero pairs
[z0,p0,z180,p180] = cancelzp(z,p,Ts,rtol);

% Phase margins
if isempty(z0) & isempty(p0)
    % Allpass system
    [wc0,Pm] = LocalAllPass(zsys,k,Ts,Td,rtol);
else
    % Compute all 0dB crossings WC0
    if Ts,
        wc0 = dgaincross(z0,p0,k,Ts,rtol);
    else
        wc0 = gaincross(z0,p0,k,rtol);
    end
    
    if isempty(wc0)
        % No 0dB crossings
        wc0 = zeros(1,0);
        Pm = zeros(1,0);  
    else
        % Compute phase at crossing frequencies WC
        ph = angle(freqresp(zsys,wc0));
        ph = reshape(ph,size(wc0));
        ph(ph<0 & ph>-1e3*eps) = 0;  % prevent getting Pm=180 when ph=-eps
        Pm = mod(ph,2*pi) - pi;      % phase margins in radians
    end
end
s.PMFrequency = wc0;
s.PhaseMargin = (180/pi)*Pm;  % phase margins in degrees


% Delay margins: contributions from jw-axis or unit circle
Dm = zeros(size(Pm));
posf = (wc0>0);
Dm(:,~posf) = Inf;
Dm(:,~posf & abs(Pm)<rtol) = 0;   % for Pm=0 at wc0=0
Dm(:,posf) = Pm(:,posf) ./ wc0(:,posf);  % where wc0>0...
acausal = (posf & Pm<-Td*wc0-rtol);  % allow for roundoff
Dm(:,acausal) = Dm(:,acausal) + 2*pi./wc0(:,acausal);  % enforce Dm>=-Td
Dm(:,~acausal) = max(-Td,Dm(:,~acausal));
if Ts
   % Express Dm has a (fractional) multiple of the sample period
   Dm = Dm/Ts;
end
s.DMFrequency = wc0;
s.DelayMargin = Dm;


% Gain margins
if Ts
    wc180 = dphasecross(z180,p180,k,Ts,Td,rtol,wc0);
else
    wc180 = phasecross(z180,p180,k,Td,rtol,wc0);
end

if isempty(wc180)
    % No 180 degree crossings
    s.GMFrequency = zeros(1,0);
    s.GainMargin = zeros(1,0);  
else
    % Compute gain at crossing frequencies WC
    g = abs(freqresp(zsys,wc180)); 
    g = reshape(g,size(wc180));
    iszero = (~g);
    g(iszero) = Inf;
    g(~iszero) = 1./g(~iszero);
    
    s.GMFrequency = wc180;
    s.GainMargin = g;  
end


% Stability assessment
if Td>0
   % Use Nyquist criterion for systems with delay
   s.Stable = LocalNyquistStability(z,p,k,Ts,Td,s);
elseif isempty(z) && isempty(p)   
   % No dynamics: watch for algebraic loops with pure gains
   s.Stable = (k~=-1);
else
   % No delay: compute closed-loop poles and zeros
   % REVISIT: remove LocalClosedLoop when descriptor available
   clp = pole(LocalClosedLoop(sys));
   if Ts
      % Discrete time 
      s.Stable = all(abs(clp)<1);
   else
      % Continuous time
      s.Stable = all(real(clp)<0);
   end
end


% Delay margin: add contribution from other portions of the analycity boundary
if s.Stable
    reldeg = length(z)-length(p);
    if (reldeg>0 || (reldeg==0 && abs(k)>=1)) && ~any(isinf(s.DMFrequency))
        % 1) Contribution from infinity: zero delay margin at Inf if |H(inf)|>=1 
        s.DMFrequency = [s.DMFrequency,Inf];
        s.DelayMargin = [s.DelayMargin,0];
    elseif Ts && (abs(evalfr(sys,-1))>=1 || ~LocalNyquistStability(z,p,k,Ts,Td+Ts,s))
        % 2) Contribution of (-Inf,-1] in discrete time: add delay margin of one sample
        %    period if H(z)/z is closed-loop unstable (sufficient condition is |H(-1)|>=1)
        % RE: looking at positive delays only...
        s.DMFrequency = [s.DMFrequency,pi/Ts];
        s.DelayMargin = [s.DelayMargin,1];
    end
end

% Reinstate initial warning state
warning(warn);lastwarn(lwarn);


%--------------------- Local Functions --------------------

%%%%%%%%%%%%%%%%
% LocalAllPass %
%%%%%%%%%%%%%%%%
function [wc0,Pm] = LocalAllPass(sys,k,Ts,Td,rtol)
% Computes phase margins for allpass system

if abs(1-abs(k))>rtol,
    % Gain is not 0dB
    wc0 = zeros(1,0);
    Pm = zeros(1,0);
    
elseif Ts & k<0
    % DT with pure negative gain
    wc0 = 0;
    Pm = 0;
    
elseif Ts==0 & (k<0 | Td)
    % Continuous time: phase is -180 at Inf or crosses -180 for w large enough when Td>0
    wc0 = Inf;
    Pm = 0;
    
else
    % Absorb delay into system and use that phase margin is min. 
    % where S=1/(1+sys) peaks
    if Ts
        sys = delay2z(sys);
    end
    [junk,wc0] = norm(feedback(1,sys),inf);
    Pm = mod(angle(freqresp(sys,wc0)),2*pi)-pi;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalNyquistStability %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function isStable = LocalNyquistStability(z,p,k,Ts,Td,s)
% Assesses stability of continuous-time model w/ delay using Nyquist criterion

% System is unstable if phase margin is zero
if any(abs(s.PhaseMargin(isfinite(s.PhaseMargin)))<180*sqrt(eps))
   isStable = false;
   return
end

% Compute (counterclockwise) winding number of H(jw) around (-1,0)
Wcg = s.PMFrequency;
Wcg = Wcg(:,isfinite(Wcg));
Wcg = unique([-Wcg,Wcg]);    % 0dB crossovers
if Ts==0
   N = winding(z,p,k,Td,Wcg);
   P = sum(real(p)>0);   % number of unstable open-loop poles
else
   N = dwinding(z,p,k,Ts,Td/Ts,Wcg);
   P = sum(abs(p)>1);    % number of unstable open-loop poles
end
isStable = (N==P);    % Nyquist criterion


%%%%%%%%%%%%%%%%%%%
% LocalClosedLoop %
%%%%%%%%%%%%%%%%%%%
function clsys = LocalClosedLoop(sys)
% Forms closed-loop model
if abs(1+evalfr(sys,Inf))<1e3*eps,
   % Use TF format if algebraic loop
   clsys = feedback(tf(sys),1);
else
   clsys = feedback(sys,1);
end


