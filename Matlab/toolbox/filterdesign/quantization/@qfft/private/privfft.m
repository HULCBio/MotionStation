function x = privfft(ffttype,F,x,dim)
%PRIVFFT  Quantized FFT or IFFT.
%   Y = PRIVFFT(FFTTYPE,F,X,DIM) is the quantized Fast Fourier Transform (FFT) or
%   Inverse FFT (IFFT) of X.  For FFT, FFTTYPE = 'fft'.  For IFFT, FFTTYPE =
%   'ifft'. The parameters of the quantized FFT are specified in QFFT object F.
%   If the length of X is less than F.length, then X is padded with zeros.  If
%   the length of X is greater than F.length, then X is truncated.  For
%   matrices, the FFT operation is applied to each column.  For N-D arrays, the
%   FFT operation operates on the first non-singleton dimension.  If DIM is
%   nonempty, the FFT operation is applied across the dimension DIM.
%
%   PRIVFFT is called by FFT and IFFT.
%
%   See also QFFT, QFFT/FFT, QFFT/IFFT.

%   Thomas A. Bryan, 28 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.24 $  $Date: 2002/04/14 15:25:29 $

if isempty(dim)
  % Work along the first nonsingleton dimension
  [x,nshifts] = shiftdim(x);
else
  % Put DIM in the first dimension (this matches the order that the built-in
  % filter uses - attfcn:mfDoDimsPerm)
  perm = [dim,1:dim-1,dim+1:ndims(x)];
  x = permute(x,perm);
end

% Do the FFT
% The input in each dimension is x(:,k).
% Note that x is still an N-D array, 
% but the indexing will work right.

% Only warn at the FFT level, but not during the operations
warn = warning;
warning off
% Extract the quantizer objects and reset overflows, underflows, max, min.
[qcoefficient, qinput, qoutput, qmultiplicand, qproduct, qsum] = ...
    quantizer(F,'coefficient', 'input', 'output', 'multiplicand', ...
    'product', 'sum'); 
reset(qcoefficient, qinput, qoutput, qmultiplicand, qproduct, qsum);

% Quantize the input
x = quantize(qinput,x);

radix = get(F,'radix');
len = get(F,'length');

% Get the scale values.  Scalar expand if necessary.  The IFFT has additional
% scaling. 
error(scalevaluescheck(F));
scalevalues = get(F,'scalevalues');
if prod(size(scalevalues))==1
  % Scalar expand scalevalues
  scalevalues = [scalevalues, ones(1,numberofsections(F)-1)];
end

switch ffttype
  case 'ifft'
    % IFFT(X) = 1/N*sum(X*conj(W)) = 1/N*conj(sum(conj(X)*W)) =
    % 1/N*conj(FFT(conj(X))), so we conjugate the input so we can use the same
    % FFT aglrithm for the the IFFT, and then conjugate the output.
    x = conj(x);
    % The IFFT is scaled by 1/F.length.  This scale factor is distributed
    % between sections.   
    scalevalues = scalevalues/radix;
end

% Compute twiddle factors.
W = twiddles(F);

siz = size(x);
N = siz(1);
if N < len
  % Zero pad
  x = [x; zeros([len-N,siz(2:end)])];
elseif N > len
  % Truncate
  x = x(1:len,:);
end
  % The FFT and IFFT use the same algorithm with different twiddle factors
% and scale values, which were specified in the fft constructor.
switch radix
  case 2
    x = qradix2fft(x,W,scalevalues,qcoefficient,qinput,qoutput,...
        qmultiplicand,qproduct,qsum);
  case 4
    x = qradix4fft(x,W,scalevalues,qcoefficient,qinput,qoutput,...
        qmultiplicand,qproduct,qsum);
end

switch ffttype
  case 'ifft'
    % IFFT(X) = 1/N*sum(X*conj(W)) = 1/N*conj(sum(conj(X)*W)) =
    % 1/N*conj(FFT(conj(X))), so we conjugate the input so we can use the same
    % FFT aglrithm for the the IFFT, and then conjugate the output.
    x = conj(x);
end

% Convert back to the original shape
if isempty(dim)
  x = shiftdim(x, -nshifts);
else
  x = ipermute(x,perm);
end

% Quantize the output
x = quantize(qoutput,x);

warning(warn)
nover = noverflows(F);
wrec = warning('query', 'FilterDesign:Qfft:Overflows');
if nover>0 & ~strcmpi(wrec.state, 'off')
  warning('FilterDesign:Qfft:Overflows', '%s overflows in quantized %s.', ...
         num2str(nover), ffttype);
  qfftreport(F)
end
