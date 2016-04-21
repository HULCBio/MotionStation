function [y,idx] = digitrevorder(x,radixbase)
%DIGITREVORDER Permute input into digit-reversed order.
%   Y = DIGITREVORDER(X, R) returns an array Y of the same size as X, with its
%   first non-singleton dimension permuted to be in digit-reversed order.
%   The length of the permuted dimension is assumed to be a power of R, the
%   radix base.  For radix-2 inputs, this sequence perfoms bit-reversal of
%   the input elements.
%
%   [Y,I] = DIGITREVORDER(X, R) returns the digit-reversed index vector I, such
%   that, for a vector Y, Y=X(I).
%
%   This operation is useful to pre-order a vector of filter coefficients
%   for use in frequency-domain filtering algorithms, in which the FFT and
%   IFFT transforms are computed without digit-reversed ordering for improved
%   run-time efficiency.
%
%   EXAMPLE:
%       x  = [0:15].';
%       y2 = digitrevorder(x, 2); % radix-2 (bit-reversed) ordering of x
%       y4 = digitrevorder(x, 4); % radix-4 (digit-reversed) ordering of x
%       [x y2 y4]
%
%   See also BITREVORDER, FFT, IFFT.

% Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2002/01/17 16:52:56 $

% Steps to compute digit-reversed indices:
%  - Create vector of input indices, assuming 0-based indexing
%  - Compute the digit representation of the index vector, based on radixbase
%  - Reverse the digit sequences
%  - Convert from digit representation back to decimal
%  - Convert to 1-based indices
%  - Index into the input

%% Perform validations:
% R must be a scalar, real, integer between 2 and 36:
if ((length(radixbase) > 1)       | ...
    (~isreal(radixbase))          | ...
    (fix(radixbase) ~= radixbase) | ...
    ((radixbase < 2) | (radixbase > 36)))
  error('The specified radix must be a scalar, real, integer between 2 and 36 inclusive.');
end

%% Shift dimensions of X until the first non-singleton dimension is reached:
[x, nshifts] = shiftdim(x);
N = size(x,1);

% Check to make sure N is an integer power of radixbase:
% Compute integer power radixpow such that (radixbase ^ radixpow) <= N
radixpow = floor(log10(N) / log10(radixbase));
if ((radixbase ^ radixpow) ~= N)
  error(['The length of the input X must be an integer power of ' num2str(radixbase) '.']);
end

%% Compute flipped digit indices:
idx = base2dec(fliplr(dec2base([0:N-1],radixbase)), radixbase) + 1;

%% Use flipped indices to index into input array:
y=shiftdim(x(idx,:),-nshifts);
