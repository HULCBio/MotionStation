function y = fftfilt(b,x,nfft)
%FFTFILT Overlap-add method of FIR filtering using FFT.
%   Y = FFTFILT(B,X) filters X with the FIR filter B using
%   the overlap/add method, using internal parameters (FFT
%   size and block length) which guarantee efficient execution.
%   
%   Y = FFTFILT(B,X,N) allows you to have some control over the
%   internal parameters, by using an FFT of at least N points.
%
%   If X is a matrix, FFTFILT filters its columns.  If B is a matrix,
%   FFTFILT applies the filter in each column of B to the signal vector X.
%   If B and X are both matrices with the same number of columns, then
%   the i-th column of B is used to filter the i-th column of X.
%
%   See also FILTER, FILTFILT.

%   --- Algorithmic details ---
%   The overlap/add algorithm convolves B with blocks of X, and adds
%   the overlapping output blocks.  It uses the FFT to compute the
%   convolution.
% 
%   Particularly for long FIR filters and long signals, this algorithm is 
%   MUCH faster than the equivalent numeric function FILTER(B,1,X).
%
%   Y = FFTFILT(B,X) -- If you leave N unspecified:   (RECOMMENDED)
%       Usually, length(X) > length(B).  Here, FFTFILT chooses an FFT 
%       length (N) and block length (L) which minimize the number of 
%       flops required for a length-N FFT times the number of blocks
%       ceil(length(X)/L).  
%       If length(X) <= length(B), FFTFILT uses a single FFT of length
%       nfft = 2^nextpow2(length(B)+length(X)-1), essentially computing 
%       ifft(fft(B,nfft).*fft(X,nfft)).
%
%   Y = FFTFILT(B,X,N) -- If you specify N:
%       In this case, N must be at least length(B); if it isn't, FFTFILT 
%       sets N to length(B).  Then, FFTFILT uses an FFT of length 
%       nfft = 2^nextpow2(N), and block length L = nfft - length(B) + 1. 
%       CAUTION: this can be VERY inefficient, if L ends up being small.

%   Author(s): L. Shure, 7-27-88
%              L. Shure, 4-25-90, revised
%              T. Krauss, 1-14-94, revised
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:18:46 $

%   Reference:
%      A.V. Oppenheim and R.W. Schafer, Digital Signal 
%      Processing, Prentice-Hall, 1975.

error(nargchk(2,3,nargin));

[m,n] = size(x);
if m == 1
    x = x(:);    % turn row into a column
end

nx = size(x,1);

if min(size(b))>1
   if (size(b,2)~=size(x,2))&(size(x,2)>1)
      error('Filter matrix B must have same number of columns as X.')
   end
else
   b = b(:);   % make input a column
end
nb = size(b,1);

if nargin < 3
% figure out which nfft and L to use
    if nb >= nx     % take a single FFT in this case
        nfft = 2^nextpow2(nb+nx-1);
        L = nx;
    else
        fftflops = [ 18 59 138 303 660 1441 3150 6875 14952 32373 69762 ...
       149647 319644 680105 1441974 3047619 6422736 13500637 28311786 59244791];
        n = 2.^(1:20); 
        validset = find(n>(nb-1));   % must have nfft > (nb-1)
        n = n(validset); 
        fftflops = fftflops(validset);
        % minimize (number of blocks) * (number of flops per fft)
        L = n - (nb - 1);
        [dum,ind] = min( ceil(nx./L) .* fftflops );
        nfft = n(ind);
        L = L(ind);
    end

else  % nfft is given
    if nfft < nb
        nfft = nb;
    end
    nfft = 2.^(ceil(log(nfft)/log(2))); % force this to a power of 2 for speed
    L = nfft - nb + 1;
end

B = fft(b,nfft);
if length(b)==1,
     B = B(:);  % make sure fft of B is a column (might be a row if b is scalar)
end
if size(b,2)==1
    B = B(:,ones(1,size(x,2)));  % replicate the column B 
end
if size(x,2)==1
    x = x(:,ones(1,size(b,2)));  % replicate the column x 
end
y = zeros(size(x));

istart = 1;
while istart <= nx
    iend = min(istart+L-1,nx);
    if (iend - istart) == 0
        X = x(istart(ones(nfft,1)),:);  % need to fft a scalar
    else
        X = fft(x(istart:iend,:),nfft);
    end
    Y = ifft(X.*B);
    yend = min(nx,istart+nfft-1);
    y(istart:yend,:) = y(istart:yend,:) + Y(1:(yend-istart+1),:);
    istart = istart + L;
end

if ~any(imag(b)) & ~any(imag(x))
	y = real(y);
end

if (m == 1)&(size(y,2) == 1)
    y = y(:).';    % turn column back into a row
end

