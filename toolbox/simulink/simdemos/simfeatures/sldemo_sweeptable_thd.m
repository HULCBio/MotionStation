function sldemo_sweeptable_thd(bits, N)
%SLDEMO_SWEEPTABLE_THD Sweep ssinthd from 1/(4*N) to N/2 frequencies
%
% synopsis:
%    sldemo_sweeptable_thd(bits,N);
%
% bits is the number of bits in the fixed length word and
% N    is the number of points per full sine wave
%
% Example:
%    sldemo_sweeptable_thd(24,256)
%
%  Calculates the error magnitude for a 24 bit fractional
%  word in a 256 point sine table at various jump sizes
%  through the table in direct and interpolated modes and 
%  plots the results.
%

% $Revision: 1.1.4.2 $
% 2002-Dec-23
% Copyright 1984-2004 The MathWorks, Inc.

if pow2(log2(N)) ~= N,
  error('number of points must be a power of 2')
end

% make an N point sine wave as a fractional number with 'bits' bits
% in 'nearest' rounding.

s  = sin(2*pi*[0:(N-1)]/N)';
is = num2fixpt( s, sfrac(bits), [], 'Nearest', 'on');

%
% Direct Lookup vs. linear lookup comparison
%
% Perform a frequency sweep of sorts by moving through
% the table D points at a time, where D is an integer
% from 1 to N/2.  Frequency is discrete and therefore
% a function of the sample rate.
%

den       = 4;
invDen    = 1.0 / den;
num       = [1:den*round(0.5*N-1)]';
numPts    = length(num);

freq       = zeros(numPts,1);
thd_chirp  = zeros(numPts,1);
thd_chirpL = zeros(numPts,1);

for k = 1:numPts,
  freq(k) = num(k) * invDen;

  div  = gcd( num(k), den );
  rpnum = num(k)/div;
  rpden = den/div;
  while div > 1,
    div = gcd( rpnum, rpden );
    rpnum = rpnum/div;
    rpden = rpden/div;
  end
  
  thd_chirp(k)  = ssinthd( is, freq(k), rpden*N, rpnum, 'direct');
  thd_chirpL(k) = ssinthd( is, freq(k), rpden*N, rpnum, 'linear');
end

loglog(freq, thd_chirp, 'bo-', freq, thd_chirpL, 'rx-'); grid;
title(sprintf('Total Harmonic Distortion for %d-bit %d point sine wave synthesis table\nusing Direct Look-Up and Linear Interpolation', bits, N));
legend({'Direct Look-Up', 'Linear Interpolation'});
xlabel('Jump size for moving through table, (points/step)');
ylabel('Total Harmonic Distortion, (fraction)');

%[EOF] sldemo_sweeptable_thd.m
