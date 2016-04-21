function thd = ssinthd(is, delta, bn, a, outtype, bits)
%SSINTHD calculate total harmonic distortion for a sampled sine wave
%
% synopsis:
%
%  thd = ssinthd(is, delta, bn, a, outtype, bits)
%
%  Calculate total harmonic distortion (THD) for digital sine
%  wave generation with or without interpolation.  This THD
%  algorithm proceeds over an integral number of waves to achieve
%  accurate results.  The number of wave cycles used is A,
%  since delta is A/B and traversing A waves will hit all points
%  in the table at least one time, which is needed to accurately
%  find the average THD.
%
%  The relationship used to calculate THD is:
%
%      THD = (ET - EF) / ET
%
%  where ET = total energy
%        EF = fundamental frequency energy
%
%  thd = ssinthd(isin, delta, bn, a)
%
%
% The optional argument configuration is:
%
%  thd = ssinthd(is, delta, bn, a, outtype, bits)
%
%  IS      is the sine table, length must be a power of two
%  DELTA   is the spacing between points A/B where A and B
%          are relatively prime.  For example, DELTA = 2.25
%          means jumping 2.25 points per output, A=9, B=4.
%  BN      is B*N, b is the minimum number of cycles needed to
%          synthesize a full cycle and N is the table length.
%  A       is the numerator of the ratio delta
%  OUTTYPE is optional: 'direct', 'linear', or 'fixptlinear':
%          'direct' for direct table access (floor index, no interp.)
%          'linear' for floating point linear interpolation
%          'fixptlinear' for fixed point linear interpolation
%  BITS    is optional: for fixptlinear, choose number of fractional
%          bits.  The default is 24.
%
% and returns total harmonic distortion for optional table processing 
% according to the outtype argument:
%
%
%  Reference:
%  "Digital Sine-Wave Synthesis Using the DSP56001/DAP56002",
%   Andreas Chrysafis, Motorola, Inc. 1988
%

% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/04/01 16:23:04 $

if nargin < 5,
    outtype = 'direct';
end

if nargin < 6,
    bits = 24;
end

numPts = length(is);

% --- Get the data out of the table that is being used

switch(lower(outtype))
    case 'direct'
        % Direct lookup points
        index = floor(mod(delta*(0:(bn-1)),numPts));
        s     = reshape( is(index+1), length(index), 1);
    case 'linear'
        % Linear interpolation lookup points
        xs    = repmat(is, a, 1);
        nxs   = length(xs);
        upts  = (0:(nxs-1))'/nxs;
        index = (0:delta:a*numPts)'; 
        index = index(1:end-1);
        s = interp1( upts, xs, index/nxs );
    case 'fixptlinear'
        % Fixed point linear interpolation lookup points
        xs    = repmat(is, a, 1);
        nxs   = length(xs);
        upts  = (0:(nxs-1))'/nxs;
        index = (0:delta:a*numPts)'; 
        index = index(1:end-1);
        if exist('fixpt_interp1') == 2
            s = fixpt_interp1( upts, xs, index/nxs, ...
                sfrac(bits),[], sfrac(bits),[],'nearest');
        else
            error('Fixed point analysis requires Simulink Fixed Point license');
        end
    otherwise
        error('Table processing option must be ''direct'', ''linear'' or ''fixptlinear''');
end


% --- evaulate THD as spurious energy / total energy

x = fft(s,bn);

k  = (0:(bn-1))';
k3 = find(k~=a & k~=(bn-a));
Espur = abs(x(k3));
Espur = sum(Espur .* Espur) / bn;

thd = Espur / sum(s.*s);

%[EOF] ssinthd.m
