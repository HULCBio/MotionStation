function  [y, h] = resample( x, p, q, N, bta )
%RESAMPLE  Change the sampling rate of a signal.
%   Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times
%   the original sample rate using a polyphase implementation.  Y is P/Q 
%   times the length of X (or the ceiling of this if P/Q is not an integer).  
%   P and Q must be positive integers.
%
%   RESAMPLE applies an anti-aliasing (lowpass) FIR filter to X during the 
%   resampling process, and compensates for the filter's delay.  The filter 
%   is designed using FIRLS.  RESAMPLE provides an easy-to-use alternative
%   to UPFIRDN, which does not require you to supply a filter or compensate
%   for the signal delay introduced by filtering.
%
%   In its filtering process, RESAMPLE assumes the samples at times before
%   and after the given samples in X are equal to zero. Thus large
%   deviations from zero at the end points of the sequence X can cause
%   inaccuracies in Y at its end points.
%
%   Y = RESAMPLE(X,P,Q,N) uses a weighted sum of 2*N*max(1,Q/P) samples of X 
%   to compute each sample of Y.  The length of the FIR filter RESAMPLE applies
%   is proportional to N; by increasing N you will get better accuracy at the 
%   expense of a longer computation time.  If you don't specify N, RESAMPLE uses
%   N = 10 by default.  If you let N = 0, RESAMPLE performs a nearest
%   neighbor interpolation; that is, the output Y(n) is X(round((n-1)*Q/P)+1)
%   ( Y(n) = 0 if round((n-1)*Q/P)+1 > length(X) ).
%
%   Y = RESAMPLE(X,P,Q,N,BTA) uses BTA as the BETA design parameter for the 
%   Kaiser window used to design the filter.  RESAMPLE uses BTA = 5 if
%   you don't specify a value.
%
%   Y = RESAMPLE(X,P,Q,B) uses B to filter X (after upsampling) if B is a 
%   vector of filter coefficients.  RESAMPLE assumes B has odd length and
%   linear phase when compensating for the filter's delay; for even length 
%   filters, the delay is overcompensated by 1/2 sample.  For non-linear 
%   phase filters consider using UPFIRDN.
%
%   [Y,B] = RESAMPLE(X,P,Q,...) returns in B the coefficients of the filter
%   applied to X during the resampling process (after upsampling).
%
%   If X is a matrix, RESAMPLE resamples the columns of X.
%
%   See also UPFIRDN, INTERP, DECIMATE, FIRLS, KAISER, INTFILT,
%   MFILT/FIRSRC in the Filter Design Toolbox.

%   NOTE-1: digital anti-alias filter is desiged via windowing

%   Author(s): James McClellan, 6-11-93
%              Modified to use upfirdn, T. Krauss, 2-27-96
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2004/04/13 00:19:02 $

if nargin < 5,  bta = 5;  end   %--- design parameter for Kaiser window LPF
if nargin < 4,   N = 10;   end
if abs(round(p))~=p | p==0, error('P must be a positive integer.'), end
if abs(round(q))~=q | q==0, error('Q must be a positive integer.'), end
[row,col]=size(x);

[p,q] = rat( p/q, 1e-12 );  %--- reduce to lowest terms 
   % (usually exact, sometimes not; loses at most 1 second every 10^12 seconds)
if (p==1)&(q==1)
    y = x; 
    h = 1;
    return
end
pqmax = max(p,q);
if length(N)>1      % use input filter
   L = length(N);
   h = N;
else                % design filter
   if( N>0 )
      fc = 1/2/pqmax;
      L = 2*N*pqmax + 1;
      h = p*firls( L-1, [0 2*fc 2*fc 1], [1 1 0 0]).*kaiser(L,bta)' ;
      % h = p*fir1( L-1, 2*fc, kaiser(L,bta)) ;
   else
      L = p;
      h = ones(1,p);
   end
end

Lhalf = (L-1)/2;
isvect = any(size(x)==1);
if isvect
    Lx = length(x);
else
    [Lx,num_sigs]=size(x);
end

% Need to delay output so that downsampling by q hits center tap of filter.
nz = floor(q-mod(Lhalf,q));
z = zeros(1,nz);
h = [z h(:).'];  % ensure that h is a row vector.
Lhalf = Lhalf + nz;

% Number of samples removed from beginning of output sequence 
% to compensate for delay of linear phase filter:
delay = floor(ceil(Lhalf)/q);

% Need to zero-pad so output length is exactly ceil(Lx*p/q).
nz1 = 0;
while ceil( ((Lx-1)*p+length(h)+nz1 )/q ) - delay < ceil(Lx*p/q)
    nz1 = nz1+1;
end
h = [h zeros(1,nz1)];

% ----  HERE'S THE CALL TO UPFIRDN  ----------------------------
y = upfirdn(x,h,p,q);

% Get rid of trailing and leading data so input and output signals line up
% temporally:
Ly = ceil(Lx*p/q);  % output length
% Ly = floor((Lx-1)*p/q+1);  <-- alternately, to prevent "running-off" the
%                                data (extrapolation)
if isvect
    y(1:delay) = [];
    y(Ly+1:end) = [];
else
    y(1:delay,:) = [];
    y(Ly+1:end,:) = [];
end

h([1:nz (end-nz1+1):end]) = [];  % get rid of leading and trailing zeros 
                                 % in case filter is output

