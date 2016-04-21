function y = gmonopuls(t,fc)
%GMONOPULS Gaussian monopulse generator.
%   Y = GMONOPULS(T,FC) returns samples of the unity-amplitude
%   Gaussian monopulse with center frequency FC (Hertz) at the
%   times indicated in array T.  By default, FC=1000 Hz.
%
%   TC = GMONOPULS('cutoff',FC) returns the time duration between
%   the maximum and minimum amplitudes of the pulse.
%
%   Default values are substituted for empty or omitted trailing input
%   arguments.
%
%   Example 1: Plot a 2 GHz Gaussian monopulse sampled at a rate
%   of 100 GHz.
%       fc = 2E9;  fs=100E9;
%       tc = gmonopuls('cutoff', fc);
%       t  = -2*tc : 1/fs : 2*tc;
%       y = gmonopuls(t,fc); plot(t,y)
%
%   Example 2: Construct a train of monopulses from Example 1
%   at a spacing of 7.5nS.
%      fc = 2E9;  fs=100E9;           % center freq, sample freq
%      D = [2.5 10 17.5]' * 1e-9;     % pulse delay times
%      tc = gmonopuls('cutoff', fc);  % width of each pulse
%      t  = 0 : 1/fs : 150*tc;        % signal evaluation time
%      yp = pulstran(t,D,@gmonopuls,fc);
%      plot(t,yp)
%
%   See also GAUSPULS, TRIPULS, PULSTRAN, CHIRP.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 01:16:43 $

% Check input parameters:
error(nargchk(1,2,nargin));
if nargin<2, fc = []; end
if isempty(fc), fc = 1E3; end

if fc<0, error('Frequency FC must be >= 0 Hz.'); end

compute_cutoff = strncmpi(t,'cutoff',length(t));

if compute_cutoff,
  % Compute time duration between minimum and maximum
  % pulse amplitudes:
  y = 1/(pi*fc);
  
else
  % Return RF pulses:
  if isempty(t),
    y=[];
    return
  end
  u = pi.*t.*fc;
  y = 2*sqrt(exp(1)) * u.*exp(-2 .* u.^2);
end

% [EOF] gmonopuls.m
