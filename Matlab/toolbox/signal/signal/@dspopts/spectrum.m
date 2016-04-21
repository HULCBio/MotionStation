function spectrum(this)
%SPECTRUM   Options object for spectral analysis.
%   OPTS = DSPOPTS.SPECTRUM is an object that can be used as an input
%   argument for certain spectral analysis methods in order to specify
%   optional input arguments for that method.
%
%   OPTS contains the following optional arguments:
%
%   Parameter              Default      Description/Valid values
%   ---------              -------      ------------------------
%   'NFFT'                 8192         Number of FFT points.
%   'NormalizedFrequency'  true         {true,false}
%   'Fs'                   'Normalized' Sampling frequency. Only used when
%                                       'NormalizedFrequency' is false.
%   'SpectrumType'         'Onesided'   {'Onesided','Twosided'}
%
%   Note that one usually doesn't construct OPTS directly. Instead, OPTS
%   can be obtained from other methods. In some cases, when using a method
%   to construct OPTS, the default values will be different to those listed
%   above.
%
%   EXAMPLE: Create a DSPOPTS.SPECTRUM object for a SPECTRUM.WELCH object
%   s = spectrum.welch; 
%   n = 0:199;  
%   Fs = 48e3;
%   x = sin(2*pi*n*10e3/Fs)+2*sin(2*pi*n*20e3/Fs)+randn(1,200);
%   opts = psdopts(s,x);
%   opts.Fs = Fs;  % Sets opts.NormalizedFrequency to false
%   d = psd(s,x,opts);
%
%   See also SPECTRUM/SPECTRUMOPTS, SPECTRUM/PSD, SPECTRUM/MSSPECTRUM.



%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:07:12 $



% [EOF]
