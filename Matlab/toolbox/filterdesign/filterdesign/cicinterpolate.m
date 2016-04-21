function y = cicinterpolate(M,N,R,x,q,dim)
%CICINTERPOLATE Interpolate a signal using a CIC filter. 
%   CICINTERPOLATE has been replaced by MFILT.CICINTERPZEROLAT.
%   CICINTERPOLATE still works but will be removed in the future. Use
%   MFILT.CICINTERPZEROLAT instead.   Type help MFILT for details.
%
%   See also MFILT/CICINTERP, MFILT.

%   Author(s): P. Costa and Thomas A. Bryan
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/12 23:25:21 $

%   References:
%     [1] Hogenauer, E. B.,  "An Economical Class of Digital Filters for
%     Decimation and Interpolation", IEEE Transactions on Acoustics, Speech,
%     and Signal Processing, Vol. ASSP-29, No. 2, April 1981, pp. 155-162.
%
%     [2] Meyer-Baese, U., Digital Signal Processing with Field
%     Programmable Gate Arrays, Springer, 2001 

error(nargchk(5,6,nargin));
if nargin < 6, dim = []; end

if ~isfixed(q),
    error('Valid only for fixed-point quantizers.');
end

% The maximum register growth (equation 22 from [1]) is defined as the
% maximum output magnitude resulting from the worst possible input signal 
% relative to the maximum input magnitude.
j  = ((N+1):2*N)';
G1 = 2^N;
G2 = (2.^(2*N-j).*(R*M).^(j-N))/R;
Gmax = max([G1; G2]);

% Maximum bit growth
Bmax = ceil(wordlength(q) + log2(Gmax)); % Equation 23 from [1]

% The MEX-file runs on long int data type, which is 32 bits.  Thus, if the
% maximum bit growth is greater than 32, this will cause wrong results.
if Bmax > 32,
    warning(generatemsgid('filterMSBlim'),...
        'Most significant bit at the filter output is limited to 32. Results maybe inaccurate.');
end

[x,perm,nshifts] = shiftdata(x,dim);

% The MEX-file is expecting integer input.
xin = num2int(q,x);

% Preallocate for the output signal 
[xrows,xcols] = size(x);
y = zeros(ceil(xrows*R),xcols);

% Integrator section initial conditions
zi_int = repmat(int32(zeros(N,1)),1,xcols);

% Comb section initial conditions
zi_comb = repmat(int32(zeros(N*(M+1),1)),1,xcols);

% Call the Zero-latency CIC interpolation filtering (Hogenauer) engine.
if isreal(xin),
    y = cicinterpolatemex(R,M,N,int32(xin),zi_comb,zi_int,0);
else
    yr = cicinterpolatemex(R,M,N,int32(real(xin)),zi_comb,zi_int,0);
    yi = cicinterpolatemex(R,M,N,int32(imag(xin)),zi_comb,zi_int,0);
    y = complex(yr,yi);
end

% Scale relative to the input precision.
y = double(y)*eps(q);

y = unshiftdata(y,perm,nshifts);

% [EOF]
