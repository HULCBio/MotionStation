function [varargout] = fft(varargin)
%FFT Discrete Fourier transform.
%   FFT(X) is the discrete Fourier transform (DFT) of vector X.  For
%   matrices, the FFT operation is applied to each column. For N-D
%   arrays, the FFT operation operates on the first non-singleton
%   dimension.
%
%   FFT(X,N) is the N-point FFT, padded with zeros if X has less
%   than N points and truncated if it has more.
%
%   FFT(X,[],DIM) or FFT(X,N,DIM) applies the FFT operation across the
%   dimension DIM.
%   
%   For length N input vector x, the DFT is a length N vector X,
%   with elements
%                    N
%      X(k) =       sum  x(n)*exp(-j*2*pi*(k-1)*(n-1)/N), 1 <= k <= N.
%                   n=1
%   The inverse DFT (computed by IFFT) is given by
%                    N
%      x(n) = (1/N) sum  X(k)*exp( j*2*pi*(k-1)*(n-1)/N), 1 <= n <= N.
%                   k=1
%
%   See also FFT2, FFTN, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.3 $  $Date: 2004/04/16 22:04:43 $

%   Built-in function.



if nargout == 0
  builtin('fft', varargin{:});
else
  [varargout{1:nargout}] = builtin('fft', varargin{:});
end
