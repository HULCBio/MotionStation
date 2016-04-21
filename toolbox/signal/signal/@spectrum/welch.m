function this = welch(winName,segmentlength,overlappercent,nfft)
%WELCH   Welch spectral estimation.
%   H = SPECTRUM.WELCH(WINNAME) instantiates a welch object with WINNAME as
%   the window and default values for all other properties.
%
%   H = SPECTRUM.WELCH({WINNAME,WINPARAMETER}) specifies the window in
%   WINNAME and the window parameter value in WINPARAMETER in a cell array.
%
%   NOTE: Depending on the window specified by WINNAME a property with the
%   window parameter will be dynamically added to the welch object H. Type
%   help sigwin/WINNAME for more details.
%
%   H = SPECTRUM.WELCH(...,SEGMENTLENGTH) specifies the length of each
%   segment as SEGMENTLENGTH.
%
%   H = SPECTRUM.WELCH(...,OVERLAPPERCENT) specifies the percent of overlap
%   between each segment.
%
%   H = SPECTRUM.WELCH(...,FFTLENGTH) sets the mode of specifying the
%   number of FFT points to the string FFTLENGTH.
%
%   FFTLENGTH can be one of the following strings:
%       'InputLength' - use the length of the input signal.
%       'NextPow2'    - use next power of two greater than the input signal
%                       length (default).
%       'UserDefined' - use the NFFT specified.
%
%   EXAMPLE: Spectral analysis of a signal that contains a 200Hz cosine
%   plus noise.
%      Fs = 1000;   t = 0:1/Fs:.296;
%      x = cos(2*pi*t*200)+randn(size(t));  
%      h = spectrum.welch;                  % Instantiate a welch object. 
%      psd(h,x,'Fs',Fs);                    % Plot the PSD.
%  
%   See also SPECTRUM/PSD, SPECTRUM/MSSPECTRUM, SPECTRUM/PERIODOGRAM,
%   SPECTRUM/MTM, SPECTRUM/BURG, SPECTRUM/COV, SPECTRUM/MCOV,
%   SPECTRUM/YULEAR, SPECTRUM/EIGENVECTOR, SPECTRUM/MUSIC.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/13 00:18:34 $

% Help for constructing a welch object.

% [EOF]
