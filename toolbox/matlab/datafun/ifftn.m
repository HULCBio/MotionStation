function [varargout] = ifftn(varargin)
%IFFTN N-dimensional inverse discrete Fourier transform.
%   IFFTN(F) returns the N-dimensional inverse discrete Fourier transform of
%   the N-D array F.  If F is a vector, the result will have the same
%   orientation.
%
%   IFFTN(F,SIZ) pads F so that its size vector is SIZ before performing the
%   transform.  If any element of SIZ is smaller than the corresponding
%   dimension of F, then F will be cropped in that dimension.
%
%   IFFTN(..., 'symmetric') causes IFFTN to treat F as multidimensionally
%   conjugate symmetric so that the output is purely real.  This option is
%   useful when F is not exactly conjugate symmetric merely because of
%   round-off error.  See the reference page for the specific mathematical
%   definition of this symmetry.
%
%   IFFTN(..., 'nonsymmetric') causes IFFTN to make no assumptions about the
%   symmetry of F.
%
%   See also FFT, FFT2, FFTN, FFTSHIFT, FFTW, IFFT, IFFT2.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $  $Date: 2004/04/16 22:04:47 $

if nargout == 0
  builtin('ifftn', varargin{:});
else
  [varargout{1:nargout}] = builtin('ifftn', varargin{:});
end
