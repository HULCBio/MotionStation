function this = dspdata
%DSPDATA   DSP data object.
%   Hs = DSPDATA.DATAOBJECT(input1,...) returns a DSP data object, Hs, of
%   type DATAOBJECT. You must specify a data object with DSPDATA. Each
%   DATAOBJECT takes one or more inputs. 
%  
%   DSPDATA.DATAOBJECT can be one of the following (type help
%   DSPDATA/DATAOBJECT to get help on a specific data object - e.g. help
%   dspdata/psd):
%  
%   dspdata.msspectrum     - Mean-square Spectrum data object.
%   dspdata.psd            - Power Spectral Density (PSD) data object.
%   dspdata.pseudospectrum - Pseudospectrum data object.
%
%   
%   The following methods are available for the objects listed above (type
%   help dspdata/METHOD to get help on a specific method - e.g. help
%   dspdata/avgpower):
%
%   dspdata/avgpower       - Average power of a PSD data object.
%   dspdata/centerdc       - Shift the zero-frequency component to center
%                            of spectrum.
%   dspdata/halfrange      - Spectrum calculated over half the Nyquist
%                            interval.
%   dspdata/onesided       - Spectrum calculated over half the Nyquist
%                            interval, but contains the full power.
%   dspdata/normalizefreq  - Normalize frequency specifications.
%   dspdata/plot           - Plot the spectrum in a data object.
%   dspdata/twosided       - Spectrum calculated over the whole Nyquist
%                            interval.
%   dspdata/wholerange     - Spectrum calculated over the whole Nyquist
%                            interval.
%
%   EXAMPLE: Construct a PSD object with the results of calculating power
%            using FFT, and plot it.
%
%        Fs = 32e3;   t = 0:1/Fs:2.96;
%        x  = cos(2*pi*t*10e3)+cos(2*pi*t*1.24e3)+ randn(size(t));
%        X  = fft(x);
%        P  = (abs(X).^2)/length(x)/Fs;  % Calculate power and scale to form PSD.
%  
%        hpsd = dspdata.psd(P,'Fs',Fs,'SpectrumType','twosided');
%        plot(hpsd);                          % Plot the PSD.
%
%
%   For more information, enter doc dspdata at the MATLAB command line.
    
%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:01:03 $

% Help for instantiating a DSPDATA object.

% [EOF]














