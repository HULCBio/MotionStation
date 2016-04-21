function this = eigenvector(varargin)
%EIGENVECTOR   Eigenvector spectral estimation.
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS) instantiates an eigenvector object
%   with the number of complex sinusoids set to NSINUSOIDS.
%
%   H = SPECTRUM.EIGENVECTOR(NSINUSOIDS,SEGMENTLENGTH) sets the number of
%   samples in each segment to SEGMENTLENGTH.
%
%   H = SPECTRUM.EIGENVECTOR(...,OVERLAPPERCENT) sets the percentage of
%   overlap between segments to OVERLAPPERCENT.
%
%   H = SPECTRUM.EIGENVECTOR(...,WINNAME) specifies the window in WINNAME.
%
%   H = SPECTRUM.EIGENVECTOR(...,{WINNAME,WINPARAMETER}) specifies the
%   window in WINNAME and the window parameter value in WINPARAMETER in a
%   cell array.
%
%   NOTE: Depending on the window specified by WINNAME a property with the
%   window parameter will be dynamically added to the eigenvector object H.
%   Type help sigwin/WINNAME for more details.
%
%   H = SPECTRUM.EIGENVECTOR(...,THRESHOLD) specifies the THRESHOLD as the
%   cutoff for the signal and noise subspace separation.
%
%   H = SPECTRUM.EIGENVECTOR(...,FFTLENGTH) sets the mode of specifying the
%   number of FFT points to the string FFTLENGTH. It can be one of the
%   following:
%       'InputLength' - use the length of the input signal.
%       'NextPow2'    - use next power of two greater than the input signal
%                       length (default).
%       'UserDefined' - use the NFFT specified.
%
%   H = SPECTRUM.EIGENVECTOR(...,INPUTTYPE) instantiates a music object
%   with its InputType property set to INPUTTYPE.  If not specified it
%   defaults to 'Vector'.  INPUTTYPE is a string and can be one of the
%   following:
%       'Vector'
%       'DataMatrix'
%       'CorrelationMatrix'
%
%   EXAMPLE: Spectral analysis of a signal containing complex sinusoids and
%   noise.
%      randn('state',1); n = 0:99;   
%      s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%      h = spectrum.eigenvector(3);   % Instantiate an eigenvector object.
%      pseudospectrum(h,s);           % Plot the pseudospectrum.
%
%   See also SPECTRUM/PSEUDOSPECTRUM, SPECTRUM/POWEREST, SPECTRUM/MUSIC,
%   SPECTRUM/BURG, SPECTRUM/COV, SPECTRUM/MCOV, SPECTRUM/YULEAR, 
%   SPECTRUM/WELCH, SPECTRUM/MTM.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/13 00:18:25 $

% Help for constructing an eigenvector object.

% [EOF]
