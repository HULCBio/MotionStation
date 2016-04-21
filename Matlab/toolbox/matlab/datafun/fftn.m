function [varargout] = fftn(varargin)
%FFTN N-dimensional discrete Fourier Transform.
%   FFTN(X) returns the N-dimensional discrete Fourier transform
%   of the N-D array X.  If X is a vector, the output will have
%   the same orientation.
%
%   FFTN(X,SIZ) pads X so that its size vector is SIZ before
%   performing the transform.  If any element of SIZ is smaller
%   than the corresponding dimension of X, then X will be cropped
%   in that dimension.
%
%   See also FFT, FFT2, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2004/04/16 22:04:44 $
%   Built-in function.

if nargout == 0
  builtin('fftn', varargin{:});
else
  [varargout{1:nargout}] = builtin('fftn', varargin{:});
end
