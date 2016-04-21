function this = music(varargin)
%MUSIC   Multiple Signal Classification (MUSIC) spectral estimation.
%   H = SPECTRUM.MUSIC(NSINUSOIDS) instantiates a music object with the
%   number of complex sinusoids set to NSINUSOIDS.
%
%   H = SPECTRUM.MUSIC(NSINUSOIDS,SEGMENTLENGTH) instantiates a music
%   object with SEGMENTLENGTH as the number of samples in each segment.
%
%   H = SPECTRUM.MUSIC(...,OVERLAPPERCENT) instantiates a music object with
%   OVERLAPPERCENT as the percentage of overlap between segments.
%
%   H = SPECTRUM.MUSIC(...,WINNAME) specifies the window in WINNAME.
%
%   H = SPECTRUM.MUSIC(...,{WINNAME,WINPARAMETER}) specifies the window in
%   WINNAME and the parameter value in WINPARAMETER in a cell array.
%
%   NOTE: Depending on the window specified by WINNAME a property with the
%   window parameter will be dynamically added to the music object H. Type
%   help sigwin/WINNAME for more details.
%
%   H = SPECTRUM.MUSIC(...,THRESHOLD) instantiates a music object and
%   THRESHOLD as the cutoff for signal and noise subspace separation.
%
%   H = SPECTRUM.EIGENVECTOR(...,FFTLENGTH) sets the mode of specifying the
%   number of FFT points to the string FFTLENGTH. It can be one of the
%   following:
%       'InputLength' - use the length of the input signal.
%       'NextPow2'    - use next power of two greater than the input signal
%                       length (default).
%       'UserDefined' - use the NFFT specified.
%
%   H = SPECTRUM.MUSIC(...,INPUTTYPE) instantiates a music object with its
%   InputType property set to INPUTTYPE.  If not specified it defaults to
%   'Vector'.  INPUTTYPE is a string and can be one of the following:
%        'Vector' 
%        'DataMatrix'
%        'CorrelationMatrix'
%
%   EXAMPLE: Spectral analysis of a signal containing complex sinusoids
%   and noise.
%      randn('state',1); n = 0:99;   
%      s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%      h = spectrum.music(3);           % Instantiate a music object.
%      pseudospectrum(h,s);             % Plot the pseudospectrum.
%
%   See also SPECTRUM/PSEUDOSPECTRUM, SPECTRUM/POWEREST,
%   SPECTRUM/EIGENVECTOR, SPECTRUM/MTM, SPECTRUM/COV, SPECTRUM/MCOV,
%   SPECTRUM/BURG, SPECTRUM/YULEAR, SPECTRUM/WELCH.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/13 00:18:30 $

% Help for constructing a music object.

% [EOF]
