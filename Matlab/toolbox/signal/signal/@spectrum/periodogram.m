function this = peridogram(winName,nfft)
%PERIODOGRAM   Periodogram spectral estimation.
%   H = SPECTRUM.PERIODOGRAM(WINNAME) instantiates a periodogram object
%   with WINNAME as the window.
%
%   H = SPECTRUM.PERIODOGRAM({WINNAME,WINPARAMETER}) specifies the window
%   in WINNAME and the window parameter value in WINPARAMETER in a cell
%   array.
%
%   NOTE: Depending on the window specified by WINNAME a property with the
%   window parameter will be dynamically added to the periodogram object H.
%   Type help sigwin/WINNAME for more details.
% 
%   H = SPECTRUM.PERIODOGRAM(...,FFTLENGTH) sets the mode of specifying the
%   number of FFT points to the string FFTLENGTH.  It can be one of the
%   following:
%       'InputLength' - use the length of the input signal.
%       'NextPow2'    - use next power of two greater than the input signal
%                       length (default).
%       'UserDefined' - use the NFFT specified.
%
%   EXAMPLE: Spectral analysis of a complex signal plus noise.
%      Fs = 1000;   t = 0:1/Fs:.296;
%      x = exp(i*2*pi*200*t)+randn(size(t));  
%      h = spectrum.periodogram;      % Instantiate a periodogram object. 
%      psd(h,x,'Fs',Fs);              % Plots the two-sided PSD by default.
%
%   See also SPECTRUM/PSD, SPECTRUM/MSSPECTRUM, SPECTRUM/WELCH,
%   SPECTRUM/MTM, SPECTRUM/BURG, SPECTRUM/COV, SPECTRUM/MCOV,
%   SPECTRUM/YULEAR, SPECTRUM/EIGENVECTOR, SPECTRUM/MUSIC.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/13 00:18:31 $

% Help for constructing a periodogram object.

% [EOF]
