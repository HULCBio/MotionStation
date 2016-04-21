function [DH,DW] = differentiator(N, F, GF, W, Fsamp, delay)
%DIFFERENTIATOR Desired frequency response for differentiator filters.
%  CFIRPM(N,F,'differentiator', ...) designs a linear-phase
%  differentiator filter response using CFIRPM.
%
%  CFIRPM(N,F,{'differentiator', Fs}, ...) specifies the sample rate
%  Fs of the filter in Hertz.  By default, Fs=1.
%
%  CFIRPM(N,F,{'differentiator', Fs, D}, ...) specifies group-delay
%  offset D such that the filter response will have a group delay of
%  N/2 + D in units of the sample interval, where N is the filter
%  order.  Negative values create less delay, while positive values
%  create more delay.  By default, D=0.
%
%  Note that DC must be in a transition band, and band weighting is
%  computed to be inversely proportional to frequency.
%
%  The symmetry option SYM defaults to 'odd' if unspecified in the
%  call to CFIRPM, if no negative band edge frequencies are
%  specified in F.
%
%  EXAMPLE: Derivative of a ramp
%    Fs = 10;                   % Sample rate
%    t = 0:1/Fs:100;            % Sample times
%    x = 1:length(t);           % x(t) has slope = 10
%    b = cfirpm(31,[.1 .9],{'differentiator',Fs});
%    y = filter(b,1,x);         % Compute derivative
%    slope = mean(y(32:end))
%
%  See also CFIRPM.

%   Authors: L. Karam, J. McClellan
%   Revised: October 1996, D. Orofino
%
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/13 00:18:43 $

%  [DH,DW]=DIFFERENTIATOR(M,F,F,W,FSAMP,DELAY)
%       N: filter order (length minus one)
%       F: vector of band edges
%      GF: vector of frequencies at which to evaluate
%       W: vector of weights, one per band
%   FSAMP: sampling frequency used to scale DH(f)
%   DELAY: negative slope of the phase.
%           N/2=(L-1)/2 for exact linear phase.
%
%      DH: vector of desired filter response (mag & phase)
%      DW: vector of weights (positive)
%
% NOTE: DH(f) and DW(f) are specified as functions of frequency

% Support query by CFIRPM for the default symmetry option:
if nargin==2,
  % Return symmetry default:
  if strcmp(N,'defaults'),
    % Second arg (F) is cell-array of args passed later to function:
    num_args = length(F);
    % Get the delay value:
    if num_args<6, delay=0; else delay=F{6}; end
    % Use delay arg to base symmetry decision:
    if isequal(delay,0), DH='odd'; else DH='real'; end
    return
  end
end

% Standard call:
error(nargchk(4,6,nargin));
if nargin<5, Fsamp = 1; end
if nargin<6, delay = 0; end
delay = delay + N/2;  % adjust for linear phase

if Fsamp<=0,
  error('Sample rate Fs must be > 0');
end

Le = length(F);
if Le==2,
  if any(F <= 0),
    error(['Band edges must be strictly positive for ' ...
           'single-band Differentiator designs']);
  end
elseif Le == 4,
  if F(2)*F(3) > 0,
    error(['Transition band must include DC for 2-band ' ...
           'Differentiator designs']);
  end
else
  error('There must be either 2 or 4 band edges for differentiator designs.')
end

mags = pi*Fsamp*F;
DH   = interp1(F(:), mags(:), GF) .* 1i .* exp(-1i*pi*GF*delay);
jkl  = find( (GF >= F(1)) & (GF <= F(2)) );
DW   = W(1)./GF(jkl);
for jj = 3:2:Le,
  jkl = find( (GF > F(jj)) & (GF <= F(jj+1)) );
  DW  = [ DW; W(jj)./GF(jkl) ];
end

% end of differentiator.m
