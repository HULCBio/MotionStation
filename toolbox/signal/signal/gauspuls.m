function [yc,ys,ye] = gauspuls(t,fc,bw,bwr,tpr)
%GAUSPULS Gaussian-modulated sinusoidal pulse generator.
%   YI=GAUSPULS(T,FC,BW) returns samples of the unity-amplitude
%   Gaussian RF pulse with center frequency FC (Hertz) and
%   fractional bandwidth BW, at the times indicated in array T.
%   Note that BW must be > 0.  By default, FC=1000 Hz and BW=0.5.
%
%   YI=GAUSPULS(T,FC,BW,BWR) specifies the optional fractional
%   bandwidth reference level, BWR.  The pulse bandwidth is
%   100*BW percent as measured at a level of BWR dB with respect
%   to the normalized signal peak.  By default, BWR=-6 dB.  Note that
%   BWR must be < 0, as it must always indicate a reference level less
%   than the peak (unity) envelope amplitude.
%
%   [YI,YQ]=GAUSPULS(...) returns both the in-phase and quadrature
%   pulses.  [YI,YQ,YE]=GAUSPULS(...) returns the RF signal envelope.
%
%   TC=GAUSPULS('cutoff',FC,BW,BWR,TPE) returns the cutoff time TC >= 0
%   at which the trailing pulse envelope falls below TPE dB with
%   respect to the peak envelope amplitude.  By default, TPE=-60 dB.
%   Note that TPE must be < 0 for the same reason as given for BWR.
%
%   Default values are substituted for empty or omitted trailing input
%   arguments.
%
%   For example, plot a 50 kHz Gaussian RF pulse with 60% bandwidth and
%   sampled at a rate of 1 MHz.  Truncate the pulse where the envelope
%   falls 40 dB below the peak.
%       tc = gauspuls('cutoff',50E3,.6,[],-40);
%       t  = -tc : 1E-6 : tc;
%       yi = gauspuls(t,50E3,.6); plot(t,yi)
%
%   See also CHIRP, SAWTOOTH, SQUARE.

%   Author(s): D. Orofino, 3/96
%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.6 $
%   $Revision: 1.6 $  $Date: 2002/04/15 01:11:43 $

% Check input parameters:
error(nargchk(1,5,nargin));
if nargin<5, tpr = []; end
if nargin<4, bwr = []; end
if nargin<3, bw = []; end
if nargin<2, fc = []; end
if isempty(tpr), tpr = -60; end
if isempty(bwr), bwr = -6; end
if isempty(bw), bw = 0.5; end
if isempty(fc), fc = 1E3; end

if bw<=0, error('Fractional bandwidth BW must be > 0.'); end
if fc<0, error('Frequency FC must be >= 0 Hz.'); end
if bwr>=0, error('Bandwidth reference level BWR must be < 0 dB.'); end

% Determine Gaussian mean and variance in the
% frequency domain to match specifications:
r = 10.^(bwr/20);             % Ref level (fraction of max peak)
fv = -bw*bw*fc*fc/(8*log(r)); % variance is fv, mean is fc
% Determine corresponding time-domain parameters:
tv = 1/(4*pi*pi*fv);  % variance is tv, mean is 0

compute_cutoff = strncmp(lower(t),'cutoff',length(t));

if compute_cutoff,
  % Compute pulse cutoff time:
  if nargout>1, error('Too many return parameters.'); end

  % Determine extent (pulse length) of time-domain envelope:
  delta = 10.^(tpr/20);        % Ref level (fraction of max peak)
  yc = sqrt(-2*tv*log(delta)); % Pulse cutoff time

else
  % Return RF pulses:
  if nargin>4, error('Too many input arguments.'); end
  if isempty(t),
    ye=[]; yc=[]; ys=[];
    return
  end

  % Compute time-domain pulse envelope, normalized by sqrt(2*pi*tv):
  ye = exp(-t.*t/(2*tv));

  % Modulate envelope to form in-phase and quadrature components:
  yc = ye .* cos(2*pi*fc*t);    % In-phase
  if nargout>1,
    ys = ye .* sin(2*pi*fc*t);  % Quadrature
  end
end

% end of gauspuls.m
