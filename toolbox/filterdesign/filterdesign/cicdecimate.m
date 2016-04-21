function y = cicdecimate(M,N,R,x,q,dim)
%CICDECIMATE  Decimate a signal using a CIC filter. 
%   CICDECIMATE has been replaced by MFILT.CICDECIMZEROLAT.
%   CICDECIMATE still works but will be removed in the future. Use
%   MFILT.CICDECIMZEROLAT instead.  Type help MFILT for details.
%
%   See also MFILT/CICDECIM, MFILT.

%   Author(s): Thomas A. Bryan and P. Costa
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/12 23:25:20 $
%
%   References:
%     [1] Hogenauer, E. B.,  "An Economical Class of Digital Filters for
%     Decimation and Interpolation", IEEE Transactions on Acoustics, Speech,
%     and Signal Processing, Vol. ASSP-29, No. 2, April 1981, pp. 155-162.
%
%     [2] Meyer-Baese, U., Digital Signal Processing with Field
%     Programmable Gate Arrays, Springer, 2001 

error(nargchk(5,6,nargin))
if nargin < 6, dim = []; end

if ~isfixed(q),
  error('Valid only for fixed-point quantizers.');
end

% The most significant bit at the filter output, based on the bit-growth and the
% wordlength of the input. 
msb = ceil(N*log2(R*M) + wordlength(q)); % Equation 5.27 of [2]

% The MEX-file runs on long int data type, which is 32 bits.  Thus, if the
% msb is greater than 32, then the overall sum could overflow, which will
% cause wrong results.
if msb > 32,
    msgid = generatemsgid('filterMSBlim'); 
  warning(msgid,'Most significant bit at the filter output is limited to 32. Results maybe inaccurate.');
end

[x,perm,nshifts] = shiftdata(x,dim);

% The MEX-file is expecting integer input.
xin = num2int(q,x);

% Preallocate the output signal vector
[xrows,xcols] = size(x);
y = zeros(ceil(xrows/R),xcols);

% Do not remove any bits in-between the stages.
B2RM = int32(zeros(2*N,1));

% Integrator section initial conditions
zi_int = repmat(int32(zeros(N,1)),1,xcols);

% Comb section initial conditions
zi_comb = repmat(int32(zeros(N*(M+1),1)),1,xcols);

% Call the Zero-latency CIC decimation filtering (Hogenauer) engine.
if isreal(xin),
    y = cicdecimatemex(R,M,N,int32(xin),B2RM,zi_int,zi_comb,0,0,0);
else
    yr = cicdecimatemex(R,M,N,int32(real(xin)),B2RM,zi_int,zi_comb,0,0,0);
    yi = cicdecimatemex(R,M,N,int32(imag(xin)),B2RM,zi_int,zi_comb,0,0,0);
    y = complex(yr,yi);
end

% Scale relative to the input precision.
y = double(y)*eps(q);

y = unshiftdata(y,perm,nshifts);

% [EOF]
