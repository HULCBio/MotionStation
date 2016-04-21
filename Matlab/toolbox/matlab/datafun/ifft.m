function [varargout] = ifft(varargin)
%IFFT Inverse discrete Fourier transform.
%   IFFT(X) is the inverse discrete Fourier transform of X.
%
%   IFFT(X,N) is the N-point inverse transform.
%
%   IFFT(X,[],DIM) or IFFT(X,N,DIM) is the inverse discrete Fourier
%   transform of X across the dimension DIM.
%
%   IFFT(..., 'symmetric') causes IFFT to treat F as conjugate symmetric
%   along the active dimension.  This option is useful when F is not exactly
%   conjugate symmetric merely because of round-off error.  See the
%   reference page for the specific mathematical definition of this
%   symmetry.
%
%   IFFT(..., 'nonsymmetric') causes IFFT to make no assumptions about the
%   symmetry of F.
%
%   See also FFT, FFT2, FFTN, FFTSHIFT, FFTW, IFFT2, IFFTN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.3 $  $Date: 2004/04/16 22:04:46 $

if nargout == 0
  builtin('ifft', varargin{:});
else
  [varargout{1:nargout}] = builtin('ifft', varargin{:});
end
