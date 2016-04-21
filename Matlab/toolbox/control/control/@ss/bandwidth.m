function fb = bandwidth(sys,drop)
%BANDWIDTH  Computes the frequency response bandwidth. 
% 
%   FB = BANDWIDTH(SYS) returns the bandwidth FB of the 
%   SISO model SYS, defined as the first frequency where the 
%   gain drops below 70.79 percent (-3 dB) of its DC value.
%   The frequency FB is expressed in radians per second.  
%   You can create SYS using TF, SS, or ZPK, see LTIMODELS 
%   for details.
%
%   FB = BANDWIDTH(SYS,DBDROP) further specifies the critical
%   gain drop in dB.  The default value is -3 dB or a 70.79 
%   percent drop.
%
%   If SYS is a S1-by...-by-Sp array of LTI models, BANDWIDTH
%   returns an array of the same size such that
%      FB(j1,...,jp) = BANDWIDTH(SYS(:,:,j1,...,jp)) .  
%
%   See also DCGAIN, ISSISO, LTIMODELS.

%   Author(s): P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 06:02:32 $

if ~issiso(sys)
    error('BANDWIDTH is only applicable to SISO models.')
elseif nargin==1
    drop = -3;  % -3dB by default (standard definition)
elseif ~isreal(drop) | ~isequal(size(drop),[1 1]) | drop>=0
    error('Gain drop must be a real negative value expressed in dB.')
end
sizes = size(sys);

if length(sizes)==2
    [fb,WarnFlag] = LocalBandWidth(sys,drop);
else
    fb = zeros([sizes(3:end) 1 1]);
    WarnFlag = 0;
    for ct=1:prod(size(fb)),
        [fb(ct),warng] = LocalBandWidth(subsref(sys,substruct('()',{':' ':' ct})),drop);
        WarnFlag = WarnFlag | warng;
    end
end

if WarnFlag
    warning('BANDWIDTH returns NaN for models with infinite DC gain.')
end

%%%%%%%%%%%%%% Local functions %%%%%%%%%%%%%%%%%%%%%%%%

function [fb,NaNflag] = LocalBandWidth(sys,drop)
%Computes bandwidth of a single state-space model
NaNflag = 0;

% Tolerance for jw-axis mode detection
toljw1 = 100 * eps;       % for simple roots
toljw2 = 10 * sqrt(eps);  % for double root

% Compute DC gain
dc = dcgain(sys);
if isinf(dc)
    fb = NaN;   NaNflag=1;   return
elseif dc==0
    % Set to Inf using the definition: how long gain > dc - drop
    fb = Inf;  return
end

% Crossover gain value
gcross = abs(dc) * 10^(drop/20);

% Compute crossover frequency
[a,b,c,d,e,Ts] = dssdata(sys);  % scaled(sys));
nx = size(a,1);
[ny,nu] = size(d);

% Normalization to gcross=1
d = d/gcross;
b = b/gcross;

% Form related Hamiltonian/symplectic pencil (for gamma=1)
if ~any(b) | ~any(c),
    % Static gain
    fb = Inf;  return
elseif Ts
    % Discrete-time
    heigs = speig(a,b,c,d,e);
    mag = abs(heigs);
    % Detect unit-circle eigs
    uceig = heigs(abs(1-mag) < toljw2+toljw1*max(mag));
    f = abs(angle(uceig))/abs(Ts);
else
    % Continuous-time
    heigs = hpeig(a,b,c,d,e);
    mag = abs(heigs);
    % Detect jw-axis eigs
    jweig = heigs(abs(real(heigs)) < toljw2*(1+mag)+toljw1*max(mag));
    f = abs(imag(jweig));
end

% Evaluate gain at candidate frequencies
% RE: Needed because nonminimal modes may introduce parasitic jw-axis eigs
%     e.g., sys = tf([2 0 2],[1 -2 1 -2])
lwarn = lastwarn;warn = warning('off');
g = abs(freqresp(sys,f));
fb = min(f(abs(g(:)-gcross)<0.01*gcross));
if isempty(fb)
    % No crossing -> bandwidth = Inf (assuming no numerical problem with eigs)
    fb = Inf;
end
warning(warn);lastwarn(lwarn);



