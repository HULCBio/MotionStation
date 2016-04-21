function this = cov(varargin)
%COV   Covariance spectral estimation.
%   H = SPECTRUM.COV instantiates a covariance (cov) spectrum object.
%
%   H = SPECTRUM.COV(ORDER) sets the order property to ORDER.
%
%   H = SPECTRUM.COV(ORDER,FFTLENGTH) sets the mode of specifying the
%   number of FFT points to the string FFTLENGTH.
%
%   FFTLENGTH can be one of the following strings:
%       'InputLength' - use the length of the input signal.
%       'NextPow2'    - use next power of two greater than the input signal
%                       length (default).
%       'UserDefined' - use the NFFT specified.
%
%   EXAMPLE: Spectral analysis of a 4th order autoregressive (AR) process.
%      randn('state',1);  x = randn(100,1);
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x); 
%      h = spectrum.cov(4);                 % Instantiate a cov object.
%      psd(h,y,'Fs',1000);                  % Plot PSD.
%
%   See also SPECTRUM/PSD, SPECTRUM/MCOV, SPECTRUM/BURG, SPECTRUM/YULEAR,
%   SPECTRUM/MTM, SPECTRUM/WELCH, SPECTRUM/PERIODOGRAM,
%   SPECTRUM/EIGENVECTOR, SPECTRUM/MUSIC.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/13 00:18:24 $

% Help for constructing a cov object.

% [EOF]
