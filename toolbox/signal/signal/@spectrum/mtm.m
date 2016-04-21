function this = mtm(NW,combinemethod,nfft)
%MTM   Multitaper spectral estimation.
%   H = SPECTRUM.MTM(TIMEBW) instantiates an mtm object with the
%   time-bandwidth product set to TIMEBW. The time-bandwidth product is of
%   the discrete prolate spheroidal sequences (or Slepian sequences) used 
%   as data windows.
%
%   H = SPECTRUM.MTM(DPSS,CONCENTRATIONS) instantiates an mtm object with
%   the discrete prolate spheroidal sequences and their concentrations set
%   to DPSS and CONCENTRATIONS respectively.  Type "help dpss" for more
%   information on these two input arguments.
%
%   NOTE: Specifying DPSS and CONCENTRATIONS at object construction time
%   automatically sets the SpecifyDataWindowAs property to DPSS from its
%   default value TimeBW.
%
%   H = SPECTRUM.MTM(...,COMBINEMETHOD) specifies the algorithm for
%   combining the individual spectral estimates, it can be one of the
%   following:
%      'Adaptive'   - Thomson's adaptive non-linear combination
%      'Eigenvalue' - linear combination with eigenvalue weights.
%      'Unity'      - linear combination with unity weights.
%
%   H = SPECTRUM.MTM(...,FFTLENGTH) sets the mode of specifying the number
%   of FFT points to the string FFTLENGTH.
%
%   FFTLENGTH can be one of the following strings:
%       'InputLength' - use the length of the input signal.
%       'NextPow2'    - use next power of two greater than the input signal
%                       length (default).
%       'UserDefined' - use the NFFT specified.
%
%   EXAMPLE #1: A cosine of 200Hz plus noise.
%      Fs = 1000;   t = 0:1/Fs:.3;  
%      x = cos(2*pi*t*200)+randn(size(t)); 
%      h = spectrum.mtm(3.5);         % Specify the time-bandwidth product
%                                     % when instantiating an mtm object.
%      psd(h,x,'Fs',Fs);              % Plot the PSD.
% 
%   EXAMPLE #2: This is the same example as above, but we'll specify the
%   data tapers and their concetrations instead of the time BW product.
%      Fs = 1000;   t = 0:1/Fs:.3;
%      x = cos(2*pi*t*200)+randn(size(t)); 
%      [E,V] = dpss(length(x),3.5);
%      h = spectrum.mtm(E,V);          % Specify DPSS and concentrations
%                                      % when instantiating an mtm object.
%      psd(h,x,'Fs',Fs);               % Plot the PSD.

%   See also SPECTRUM/PSD, SPECTRUM/WELCH, SPECTRUM/PERIODOGRAM,
%   SPECTRUM/BURG, SPECTRUM/COV, SPECTRUM/MCOV, SPECTRUM/YULEAR,
%   SPECTRUM/EIGENVECTOR, SPECTRUM/MUSIC.

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/13 00:18:29 $

% Help for constructing mtm objects.

% [EOF]
