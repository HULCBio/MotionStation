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
%   $Revision: 1.12 $  $Date: 2002/04/10 05:52:26 $

if ~issiso(sys)
    error('BANDWIDTH is only applicable to SISO models.')
elseif isa(sys,'frd')
    error('BANDWIDTH is not supported for FRD models.')
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
% Computes bandwidth of a single TF or ZPK model
% Algorithm adapted from ALLMARGIN.
rtol = 1e-3;  % relative accuracy on computed crossings/margins
NaNflag = 0;

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

% Get model's ZPK data
[z,p,k,Ts] = zpkdata(sys,'v');
Ts = abs(Ts);
k = k/gcross;  % Normalize to reduce problem to finding 0dB crossings

% Cancel allpass pole/zero pairs (for better convergence)
[z,p] = cancelzp(z,p,Ts,rtol);

% Compute 0dB gain crossings
if isempty(z) & isempty(p)
    % Allpass system
    fb = Inf;
elseif Ts,
    fb = min(dgaincross(z,p,k,Ts,rtol));
else
    fb = min(gaincross(z,p,k,rtol));
end
